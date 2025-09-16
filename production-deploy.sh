#!/bin/bash
# Nexus COS Production Deployment and Recovery Script
# Fully automated production deployment with error recovery
# Designed for nexuscos.online VPS recovery

set -e

# Configuration
DOMAIN="nexuscos.online"
WWW_DOMAIN="www.nexuscos.online"
FRONTEND_DIR="/var/www/nexus-cos"
BACKEND_PORT=3000
PYTHON_PORT=3001
LOG_FILE="/tmp/nexus-deployment.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log "INFO: $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log "SUCCESS: $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log "WARNING: $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log "ERROR: $1"
}

# Cleanup function for graceful exit
cleanup() {
    if [ -n "$NODE_PID" ]; then
        kill "$NODE_PID" 2>/dev/null || true
    fi
    if [ -n "$PYTHON_PID" ]; then
        kill "$PYTHON_PID" 2>/dev/null || true
    fi
}

trap cleanup EXIT

echo "🚀 Starting Nexus COS Production Deployment and Recovery..."
log "=== NEXUS COS PRODUCTION DEPLOYMENT STARTED ==="

# Step 1: System Dependencies and Prerequisites
print_status "Installing system dependencies..."
if ! command -v nginx >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y nginx certbot python3-certbot-nginx nodejs npm python3 python3-pip python3-venv curl wget
    print_success "System dependencies installed"
else
    print_success "System dependencies already available"
fi

# Step 2: Install and configure PM2 for process management
print_status "Setting up PM2 for process management..."
if ! command -v pm2 >/dev/null 2>&1; then
    sudo npm install -g pm2
    print_success "PM2 installed globally"
else
    print_success "PM2 already installed"
fi

# Step 3: Stop any existing services
print_status "Stopping existing services..."
sudo systemctl stop nginx 2>/dev/null || true
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true
print_success "Existing services stopped"

# Step 4: Backend Setup (Node.js)
print_status "Setting up Node.js backend..."
cd backend
if [ ! -f package.json ]; then
    print_error "Backend package.json not found"
    exit 1
fi

# Clean install dependencies
rm -rf node_modules package-lock.json 2>/dev/null || true
npm install --production
print_success "Node.js backend dependencies installed"

# Test backend can start
print_status "Testing Node.js backend..."
timeout 10s npx ts-node src/server.ts &
NODE_PID=$!
sleep 5

if ps -p $NODE_PID > /dev/null; then
    print_success "Node.js backend test successful"
    kill $NODE_PID 2>/dev/null || true
else
    print_error "Node.js backend failed to start"
    exit 1
fi

cd ..

# Step 5: Python Backend Setup
print_status "Setting up Python FastAPI backend..."
cd backend

# Setup virtual environment
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi

source .venv/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install fastapi uvicorn[standard] python-multipart pydantic

# Test Python backend
print_status "Testing Python backend..."
timeout 10s uvicorn app.main:app --host 0.0.0.0 --port $PYTHON_PORT &
PYTHON_PID=$!
sleep 5

if ps -p $PYTHON_PID > /dev/null; then
    print_success "Python backend test successful"
    kill $PYTHON_PID 2>/dev/null || true
else
    print_error "Python backend failed to start"
    exit 1
fi

deactivate
cd ..

# Step 6: Frontend Build and Deployment
print_status "Building and deploying frontend..."
cd frontend

# Clean build
rm -rf dist node_modules package-lock.json 2>/dev/null || true
npm install
npm run build

if [ ! -d "dist" ] || [ ! -f "dist/index.html" ]; then
    print_error "Frontend build failed - no dist directory or index.html"
    exit 1
fi

print_success "Frontend built successfully"

# Deploy to web directory
sudo mkdir -p "$FRONTEND_DIR"
sudo rm -rf "${FRONTEND_DIR}"/*
sudo cp -r dist/* "$FRONTEND_DIR/"
sudo chown -R www-data:www-data "$FRONTEND_DIR"
sudo chmod -R 755 "$FRONTEND_DIR"

print_success "Frontend deployed to $FRONTEND_DIR"
cd ..

# Step 7: Configure Nginx
print_status "Configuring Nginx..."

# Create nginx config
sudo cp deployment/nginx/nexuscos.online.conf /etc/nginx/sites-available/
sudo ln -sf /etc/nginx/sites-available/nexuscos.online.conf /etc/nginx/sites-enabled/

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
if sudo nginx -t; then
    print_success "Nginx configuration valid"
else
    print_error "Nginx configuration invalid"
    exit 1
fi

# Step 8: SSL Certificate Setup
print_status "Setting up SSL certificates..."

# Check if certificates exist
if [ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    print_status "Obtaining SSL certificates..."
    
    # Temporarily start nginx for certificate verification
    sudo systemctl start nginx
    
    # Get certificate
    sudo certbot --nginx -d "$DOMAIN" -d "$WWW_DOMAIN" --non-interactive --agree-tos --email admin@nexuscos.online --redirect
    
    if [ $? -eq 0 ]; then
        print_success "SSL certificates obtained successfully"
    else
        print_warning "SSL certificate generation failed, continuing with HTTP"
        # Create a basic HTTP-only config
        sudo cp deployment/nginx/nexuscos.online.conf /etc/nginx/sites-available/nexuscos.online.conf.backup
        
        # Create simplified HTTP config
        cat > /tmp/nexuscos-http.conf << 'EOF'
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
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Node.js API endpoints
    location /api/ {
        proxy_pass http://localhost:3000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Python FastAPI endpoints
    location /py/ {
        proxy_pass http://localhost:3001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Python health check
    location /py/health {
        proxy_pass http://localhost:3001/health;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
        sudo cp /tmp/nexuscos-http.conf /etc/nginx/sites-available/nexuscos.online.conf
        sudo nginx -t && print_success "HTTP-only Nginx configuration created"
    fi
else
    print_success "SSL certificates already exist"
fi

# Step 9: Start Production Services with PM2
print_status "Starting production services..."

# Create PM2 ecosystem file
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'nexus-backend',
      script: 'npx',
      args: 'ts-node src/server.ts',
      cwd: './backend',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '500M',
      error_file: '/var/log/pm2/nexus-backend-error.log',
      out_file: '/var/log/pm2/nexus-backend-out.log',
      log_file: '/var/log/pm2/nexus-backend.log',
      time: true
    },
    {
      name: 'nexus-python',
      script: './backend/.venv/bin/uvicorn',
      args: 'app.main:app --host 0.0.0.0 --port 3001',
      cwd: './backend',
      env: {
        PYTHONPATH: './backend',
        PORT: 3001
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '500M',
      error_file: '/var/log/pm2/nexus-python-error.log',
      out_file: '/var/log/pm2/nexus-python-out.log',
      log_file: '/var/log/pm2/nexus-python.log',
      time: true
    }
  ]
};
EOF

# Create PM2 log directory
sudo mkdir -p /var/log/pm2
sudo chown -R $USER:$USER /var/log/pm2

# Start services with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup

print_success "Backend services started with PM2"

# Step 10: Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
print_success "Nginx started and enabled"

# Step 11: Health Checks and Validation
print_status "Performing health checks..."

# Wait for services to start
sleep 10

# Check PM2 services
pm2 status

# Check if backends are responding
NODE_HEALTH=""
PYTHON_HEALTH=""
NGINX_STATUS=""

# Test Node.js health
for i in {1..5}; do
    if curl -f -s http://localhost:$BACKEND_PORT/health >/dev/null 2>&1; then
        NODE_HEALTH="✅ OK"
        break
    fi
    sleep 2
done

# Test Python health  
for i in {1..5}; do
    if curl -f -s http://localhost:$PYTHON_PORT/health >/dev/null 2>&1; then
        PYTHON_HEALTH="✅ OK"
        break
    fi
    sleep 2
done

# Test Nginx
if sudo systemctl is-active --quiet nginx; then
    NGINX_STATUS="✅ OK"
else
    NGINX_STATUS="❌ Failed"
fi

# Step 12: Final Validation and Reporting
print_status "Generating deployment report..."

cat << EOF

🎉 NEXUS COS PRODUCTION DEPLOYMENT COMPLETE!

=== DEPLOYMENT SUMMARY ===
📅 Deployment Time: $(date)
🌐 Domain: https://$DOMAIN
🔒 SSL Status: $([ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ] && echo "✅ Enabled" || echo "⚠️  HTTP Only")

=== SERVICE STATUS ===
🔧 Node.js Backend (Port $BACKEND_PORT): ${NODE_HEALTH:-"❌ Failed"}
🐍 Python Backend (Port $PYTHON_PORT): ${PYTHON_HEALTH:-"❌ Failed"}
🌐 Nginx Web Server: $NGINX_STATUS
📁 Frontend Assets: ✅ Deployed to $FRONTEND_DIR

=== ACCESS POINTS ===
🌐 Website: http://$DOMAIN (or https:// if SSL enabled)
🔧 Node.js Health: http://$DOMAIN/health
🐍 Python Health: http://$DOMAIN/py/health
📊 PM2 Status: pm2 status

=== PROCESS MANAGEMENT ===
• View logs: pm2 logs
• Restart services: pm2 restart all
• Stop services: pm2 stop all
• Monitor: pm2 monit

=== SSL CERTIFICATE ===
• Auto-renewal: $(sudo crontab -l 2>/dev/null | grep certbot >/dev/null && echo "✅ Configured" || echo "⚠️  Manual setup needed")
• Certificate path: /etc/letsencrypt/live/$DOMAIN/

=== TROUBLESHOOTING ===
• Deployment log: $LOG_FILE
• Nginx logs: sudo journalctl -u nginx
• PM2 logs: pm2 logs
• System logs: sudo journalctl -f

EOF

# Final validation
if [ "$NODE_HEALTH" = "✅ OK" ] && [ "$PYTHON_HEALTH" = "✅ OK" ] && [ "$NGINX_STATUS" = "✅ OK" ]; then
    print_success "🎯 ALL SERVICES OPERATIONAL - DEPLOYMENT SUCCESSFUL!"
    log "DEPLOYMENT COMPLETED SUCCESSFULLY"
    exit 0
else
    print_warning "⚠️  Some services may need attention, but core deployment is complete"
    log "DEPLOYMENT COMPLETED WITH WARNINGS"
    exit 0
fi