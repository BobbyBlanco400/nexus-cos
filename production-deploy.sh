#!/bin/bash

# Nexus COS Production Deployment Script
# This script deploys the complete Nexus COS to production environment
# MUST BE RUN AS ROOT or with sudo

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)"
   exit 1
fi

# Configuration
DOMAIN="nexuscos.online"
FRONTEND_DIR="/var/www/nexus-cos"
PROJECT_DIR="/opt/nexus-cos"
NODE_PORT=3000
PYTHON_PORT=3001

log_info "Starting Nexus COS Production Deployment..."
log_info "Domain: ${DOMAIN}"
log_info "Frontend Directory: ${FRONTEND_DIR}"
log_info "Project Directory: ${PROJECT_DIR}"

# Step 1: Update system and install dependencies
log_info "Installing system dependencies..."
apt update -y
apt install -y nginx certbot python3-certbot-nginx nodejs npm python3 python3-pip python3-venv curl git software-properties-common

# Install PM2 globally for process management
npm install -g pm2

log_success "System dependencies installed"

# Step 2: Clone/update project
log_info "Setting up project directory..."
if [ ! -d "$PROJECT_DIR" ]; then
    mkdir -p "$PROJECT_DIR"
    git clone https://github.com/BobbyBlanco400/nexus-cos.git "$PROJECT_DIR"
else
    cd "$PROJECT_DIR"
    git pull origin main
fi

cd "$PROJECT_DIR"
log_success "Project directory ready"

# Step 3: Setup Node.js backend
log_info "Setting up Node.js backend..."
cd "$PROJECT_DIR/backend"
npm install --production
npm run build 2>/dev/null || log_warning "No build script found for Node.js backend"
log_success "Node.js backend setup complete"

# Step 4: Setup Python backend
log_info "Setting up Python backend..."
cd "$PROJECT_DIR/backend"
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi
source .venv/bin/activate
pip install fastapi uvicorn
deactivate
log_success "Python backend setup complete"

# Step 5: Build frontend
log_info "Building frontend..."
cd "$PROJECT_DIR/frontend"
npm install --production
npm run build
log_success "Frontend built successfully"

# Step 6: Deploy frontend
log_info "Deploying frontend to ${FRONTEND_DIR}..."
mkdir -p "$FRONTEND_DIR"
cp -r dist/* "$FRONTEND_DIR/"
chown -R www-data:www-data "$FRONTEND_DIR"
chmod -R 755 "$FRONTEND_DIR"
log_success "Frontend deployed"

# Step 7: Setup nginx configuration
log_info "Configuring Nginx..."
cp "$PROJECT_DIR/deployment/nginx/nexuscos.online.conf" /etc/nginx/sites-available/
ln -sf /etc/nginx/sites-available/nexuscos.online.conf /etc/nginx/sites-enabled/

# Remove default nginx site
rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
if nginx -t; then
    log_success "Nginx configuration is valid"
else
    log_error "Nginx configuration test failed"
    exit 1
fi

# Step 8: Setup SSL with Let's Encrypt
log_info "Setting up SSL certificates..."
# Stop nginx temporarily for certificate generation
systemctl stop nginx 2>/dev/null || true

# Generate certificates
if certbot certonly --standalone -d "$DOMAIN" -d "www.$DOMAIN" --agree-tos --non-interactive --email admin@"$DOMAIN"; then
    log_success "SSL certificates generated successfully"
else
    log_warning "SSL certificate generation failed, continuing without SSL"
    # Create a temporary nginx config without SSL for testing
    cat > /etc/nginx/sites-available/nexuscos.online.conf << 'EOF'
server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    
    # Frontend static files
    location / {
        root /var/www/nexus-cos;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # Health endpoints
    location /health {
        proxy_pass http://localhost:3000/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Node.js API endpoints
    location /api/ {
        proxy_pass http://localhost:3000/api/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Python FastAPI endpoints
    location /py/ {
        proxy_pass http://localhost:3001/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
fi

# Step 9: Setup PM2 process management
log_info "Setting up PM2 process management..."
cd "$PROJECT_DIR"

# Create PM2 ecosystem file
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'nexus-node-backend',
      script: 'npx',
      args: 'ts-node src/server.ts',
      cwd: './backend',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      }
    },
    {
      name: 'nexus-python-backend',
      script: '.venv/bin/uvicorn',
      args: 'app.main:app --host 0.0.0.0 --port 3001',
      cwd: './backend',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        PYTHONPATH: './backend'
      }
    }
  ]
};
EOF

# Stop any existing PM2 processes
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Start applications with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup

log_success "PM2 process management configured"

# Step 10: Start services
log_info "Starting services..."
systemctl start nginx
systemctl enable nginx

log_success "Services started"

# Step 11: Validate deployment
log_info "Validating deployment..."

# Wait for services to start
sleep 5

# Test health endpoints
NODE_HEALTH=$(curl -s http://localhost:3000/health 2>/dev/null || echo "failed")
PYTHON_HEALTH=$(curl -s http://localhost:3001/health 2>/dev/null || echo "failed")

if [[ "$NODE_HEALTH" == *"ok"* ]]; then
    log_success "Node.js backend health check passed"
else
    log_error "Node.js backend health check failed: $NODE_HEALTH"
fi

if [[ "$PYTHON_HEALTH" == *"ok"* ]]; then
    log_success "Python backend health check passed"
else
    log_error "Python backend health check failed: $PYTHON_HEALTH"
fi

# Test nginx
if curl -s -o /dev/null -w "%{http_code}" http://localhost/ | grep -q "200\|301\|302"; then
    log_success "Nginx is serving content"
else
    log_error "Nginx is not responding correctly"
fi

# Step 12: Setup monitoring and automatic restart
log_info "Setting up monitoring..."

# Create a simple health monitoring script
cat > /opt/nexus-cos/monitor.sh << 'EOF'
#!/bin/bash

# Simple health monitoring script
check_service() {
    local service=$1
    local url=$2
    
    if curl -s --max-time 10 "$url" | grep -q "ok"; then
        echo "$(date): $service is healthy"
        return 0
    else
        echo "$(date): $service is unhealthy, restarting..."
        pm2 restart "$service"
        return 1
    fi
}

# Check both backends
check_service "nexus-node-backend" "http://localhost:3000/health"
check_service "nexus-python-backend" "http://localhost:3001/health"
EOF

chmod +x /opt/nexus-cos/monitor.sh

# Add to crontab for periodic health checks
(crontab -l 2>/dev/null; echo "*/5 * * * * /opt/nexus-cos/monitor.sh >> /var/log/nexus-cos-monitor.log 2>&1") | crontab -

log_success "Monitoring setup complete"

# Step 13: Generate deployment report
log_info "Generating deployment report..."

DEPLOYMENT_LOG="/opt/nexus-cos/deployment-$(date +%Y%m%d-%H%M%S).log"

cat > "$DEPLOYMENT_LOG" << EOF
=== Nexus COS Deployment Report ===
Date: $(date)
Domain: $DOMAIN
Project Directory: $PROJECT_DIR
Frontend Directory: $FRONTEND_DIR

=== Service Status ===
Node.js Backend (Port $NODE_PORT): $NODE_HEALTH
Python Backend (Port $PYTHON_PORT): $PYTHON_HEALTH
Nginx: $(systemctl is-active nginx)

=== PM2 Processes ===
$(pm2 list)

=== Nginx Status ===
$(nginx -t 2>&1)

=== SSL Certificate Status ===
$(certbot certificates 2>/dev/null || echo "No SSL certificates found")

=== URLs ===
Main Site: http://$DOMAIN
HTTPS Site: https://$DOMAIN (if SSL is configured)
Node.js Health: http://$DOMAIN/health
Python Health: http://$DOMAIN/py/health

=== Next Steps ===
1. Test the website at http://$DOMAIN
2. If SSL failed, run: certbot --nginx -d $DOMAIN -d www.$DOMAIN
3. Monitor logs: pm2 logs
4. Health monitoring: tail -f /var/log/nexus-cos-monitor.log
EOF

log_success "Deployment report saved to: $DEPLOYMENT_LOG"

# Final status
echo ""
echo "=================================================================="
log_success "🎉 Nexus COS Production Deployment Complete!"
echo "=================================================================="
echo ""
echo "📋 Quick Status:"
echo "  🌐 Website: http://$DOMAIN"
echo "  🔧 Node.js Health: http://$DOMAIN/health"
echo "  🐍 Python Health: http://$DOMAIN/py/health"
echo "  📊 PM2 Dashboard: pm2 monit"
echo "  📝 Deployment Log: $DEPLOYMENT_LOG"
echo ""
echo "🔧 Management Commands:"
echo "  View PM2 processes: pm2 list"
echo "  View PM2 logs: pm2 logs"
echo "  Restart services: pm2 restart all"
echo "  Nginx status: systemctl status nginx"
echo "  SSL setup (if needed): certbot --nginx -d $DOMAIN -d www.$DOMAIN"
echo ""
log_info "Deployment completed successfully!"