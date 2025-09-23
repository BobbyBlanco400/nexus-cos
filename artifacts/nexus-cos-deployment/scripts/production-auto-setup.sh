#!/bin/bash
# 🚀 Nexus COS Auto-Setup Script
# Run as root on fresh Ubuntu 22.04 VPS
# Integrated with TRAE Solo deployment system

DOMAIN="nexuscos.online"
EMAIL="puaboverse@gmail.com"
PG_USER="nexus_admin"
PG_PASS="Momoney2025$$"
JWT_SECRET="whitefamilylegacy600$$"
APP_DIR="/var/www/nexus-cos"

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

# Error handling
set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Starting Nexus COS Production Auto-Setup"
log_info "Domain: $DOMAIN"
log_info "Email: $EMAIL"
log_info "App Directory: $APP_DIR"

echo "=== 1. Updating server & installing dependencies ==="
log_info "Updating system packages..."
apt update && apt upgrade -y

log_info "Installing required packages..."
apt install -y python3 python3-venv python3-pip git ufw nginx postgresql postgresql-contrib certbot python3-certbot-nginx curl wget unzip

# Install Node.js 20.x
log_info "Installing Node.js 20.x..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt install -y nodejs

# Install Docker
log_info "Installing Docker..."
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
systemctl start docker
systemctl enable docker

log_success "Dependencies installed successfully"

echo "=== 2. Configuring PostgreSQL ==="
log_info "Setting up PostgreSQL database..."
sudo -u postgres psql -c "CREATE USER $PG_USER WITH PASSWORD '$PG_PASS';" || true
sudo -u postgres psql -c "ALTER USER $PG_USER CREATEDB;" || true
sudo -u postgres psql -c "CREATE DATABASE nexus_cos OWNER $PG_USER;" || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE nexus_cos TO $PG_USER;" || true

log_success "PostgreSQL configured successfully"

echo "=== 3. Setting up firewall (UFW) ==="
log_info "Configuring firewall rules..."
ufw allow OpenSSH
ufw allow "Nginx Full"
ufw allow 3000/tcp  # Node.js backend
ufw allow 3001/tcp  # Python backend
ufw allow 5432/tcp  # PostgreSQL
ufw --force enable

log_success "Firewall configured successfully"

echo "=== 4. Cloning project into $APP_DIR ==="
log_info "Setting up project directory..."
mkdir -p $APP_DIR
cd $APP_DIR

if [ ! -d ".git" ]; then
    log_info "Cloning Nexus COS repository..."
    git clone https://github.com/BobbyBlanco400/nexus-cos.git $APP_DIR
else
    log_info "Updating existing repository..."
    git pull
fi

# Set proper permissions
chown -R www-data:www-data $APP_DIR
chmod -R 755 $APP_DIR

log_success "Project cloned successfully"

echo "=== 5. Backend setup ==="
log_info "Setting up Python backend..."
cd $APP_DIR/backend

# Create Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    log_warning "requirements.txt not found, installing basic dependencies"
    pip install fastapi uvicorn psycopg2-binary python-jose[cryptography] passlib[bcrypt] python-multipart
fi

deactivate

# Setup Node.js backend if exists
if [ -f "package.json" ]; then
    log_info "Setting up Node.js backend..."
    npm install
fi

log_success "Backend setup completed"

echo "=== 6. Frontend setup ==="
if [ -d "$APP_DIR/frontend" ]; then
    log_info "Setting up React frontend..."
    cd $APP_DIR/frontend
    
    if [ -f "package.json" ]; then
        npm install
        npm run build
        log_success "Frontend built successfully"
    else
        log_warning "Frontend package.json not found"
    fi
else
    log_warning "Frontend directory not found"
fi

echo "=== 7. Creating systemd services ==="
log_info "Creating systemd service for Python backend..."
cat > /etc/systemd/system/nexus-backend-python.service <<EOL
[Unit]
Description=Nexus COS Python Backend (FastAPI)
After=network.target postgresql.service

[Service]
User=www-data
Group=www-data
WorkingDirectory=$APP_DIR/backend
Environment="DATABASE_URL=postgresql://$PG_USER:$PG_PASS@localhost:5432/nexus_cos"
Environment="JWT_SECRET=$JWT_SECRET"
Environment="PYTHONPATH=$APP_DIR/backend"
ExecStart=$APP_DIR/backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 3001
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL

# Create Node.js backend service if package.json exists
if [ -f "$APP_DIR/backend/package.json" ]; then
    log_info "Creating systemd service for Node.js backend..."
    cat > /etc/systemd/system/nexus-backend-node.service <<EOL
[Unit]
Description=Nexus COS Node.js Backend
After=network.target postgresql.service

[Service]
User=www-data
Group=www-data
WorkingDirectory=$APP_DIR/backend
Environment="DATABASE_URL=postgresql://$PG_USER:$PG_PASS@localhost:5432/nexus_cos"
Environment="JWT_SECRET=$JWT_SECRET"
Environment="NODE_ENV=production"
Environment="PORT=3000"
ExecStart=/usr/bin/node app.js
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL
    
    systemctl daemon-reload
    systemctl enable nexus-backend-node
    systemctl start nexus-backend-node
    log_success "Node.js backend service created and started"
fi

systemctl daemon-reload
systemctl enable nexus-backend-python
systemctl start nexus-backend-python

log_success "Backend services created and started"

echo "=== 8. Nginx configuration ==="
log_info "Configuring Nginx reverse proxy..."
cat > /etc/nginx/sites-available/nexuscos <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;

    # API routes
    location /api/node/ {
        proxy_pass http://127.0.0.1:3000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    location /api/python/ {
        proxy_pass http://127.0.0.1:3001/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\\n";
        add_header Content-Type text/plain;
    }

    # Static files
    location / {
        root $APP_DIR/frontend/dist;
        index index.html;
        try_files \$uri \$uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)\$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # Fallback for frontend build directory
    location /build/ {
        root $APP_DIR/frontend;
        try_files \$uri \$uri/ =404;
    }
}
EOL

# Remove default site and enable nexuscos
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/nexuscos /etc/nginx/sites-enabled/

# Test nginx configuration
nginx -t && systemctl restart nginx

log_success "Nginx configured successfully"

echo "=== 9. SSL with Let's Encrypt ==="
log_info "Setting up SSL certificate..."
certbot --nginx -d $DOMAIN -m $EMAIL --agree-tos --non-interactive --redirect || {
    log_warning "SSL setup failed, but continuing. You can run 'certbot --nginx -d $DOMAIN' manually later."
}

echo "=== 10. Final health checks ==="
log_info "Performing system health checks..."

# Check services
services=("postgresql" "nginx" "nexus-backend-python")
if systemctl is-active --quiet nexus-backend-node; then
    services+=("nexus-backend-node")
fi

for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        log_success "$service is running"
    else
        log_error "$service is not running"
        systemctl status "$service" --no-pager
    fi
done

# Check ports
log_info "Checking open ports..."
netstat -tlnp | grep -E ':(80|443|3000|3001|5432)\s'

# Create deployment summary
cat > $APP_DIR/PRODUCTION_DEPLOYMENT_SUMMARY.md <<EOL
# Nexus COS Production Deployment Summary

**Deployment Date:** $(date)
**Domain:** $DOMAIN
**Server:** $(hostname -f)
**OS:** $(lsb_release -d | cut -f2)

## Services Status
$(systemctl is-active postgresql && echo "✅ PostgreSQL: Running" || echo "❌ PostgreSQL: Failed")
$(systemctl is-active nginx && echo "✅ Nginx: Running" || echo "❌ Nginx: Failed")
$(systemctl is-active nexus-backend-python && echo "✅ Python Backend: Running" || echo "❌ Python Backend: Failed")
$(systemctl is-active nexus-backend-node 2>/dev/null && echo "✅ Node.js Backend: Running" || echo "⚠️ Node.js Backend: Not configured")

## Access Points
- **Frontend:** https://$DOMAIN
- **Python API:** https://$DOMAIN/api/python/
- **Node.js API:** https://$DOMAIN/api/node/ (if configured)
- **Health Check:** https://$DOMAIN/health

## Database
- **Host:** localhost:5432
- **Database:** nexus_cos
- **User:** $PG_USER

## SSL Certificate
$(certbot certificates 2>/dev/null | grep -q "$DOMAIN" && echo "✅ SSL Certificate: Active" || echo "⚠️ SSL Certificate: Not configured")

## Next Steps
1. Verify all services are running: \`systemctl status nexus-backend-python\`
2. Check application logs: \`journalctl -u nexus-backend-python -f\`
3. Test API endpoints: \`curl https://$DOMAIN/health\`
4. Configure monitoring and backups
5. Setup CI/CD pipeline

## Support
- Logs: \`journalctl -u nexus-backend-python\`
- Nginx logs: \`tail -f /var/log/nginx/error.log\`
- Database logs: \`tail -f /var/log/postgresql/postgresql-*.log\`
EOL

log_success "Production deployment summary created: $APP_DIR/PRODUCTION_DEPLOYMENT_SUMMARY.md"

echo "=== ✅ Setup Complete! ==="
log_success "Nexus COS should be live at https://$DOMAIN"
log_info "Check the deployment summary at: $APP_DIR/PRODUCTION_DEPLOYMENT_SUMMARY.md"
log_info "Monitor services with: systemctl status nexus-backend-python"
log_info "View logs with: journalctl -u nexus-backend-python -f"

echo ""
echo "🎉 Nexus COS Production Deployment Complete!"
echo "🌐 Frontend: https://$DOMAIN"
echo "🔗 API: https://$DOMAIN/api/python/"
echo "💚 Health: https://$DOMAIN/health"
echo ""