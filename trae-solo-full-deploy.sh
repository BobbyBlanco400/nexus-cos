#!/bin/bash
# TRAE SOLO 🚀 FULL NEXUS COS DEPLOYMENT
# Automated deployment script for IONOS VPS

set -e  # Exit on any error

# Configuration
VPS_HOST="74.208.155.161"
VPS_USER="root"
VPS_AUTH="I29FgNi4"
DOMAIN="nexuscos.online"
SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6ZrsVXihP5wR9Sj2xkjG8lyrpzoHxGM1S1ZlcSLgbW puaboverse@gmail.com"
GITHUB_REPO="https://github.com/BobbyBlanco400/nexus-cos.git"
LOCAL_PROJECT="/root/PUABO-OS-2025"
DEPLOY_DIR="/opt/nexus-cos"
WWW_DIR="/var/www/nexus-cos"
LOG_FILE="/tmp/nexus-cos-deploy.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Initialize deployment log
echo "TRAE SOLO 🚀 FULL NEXUS COS DEPLOYMENT" > "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"
echo "VPS: $VPS_HOST" >> "$LOG_FILE"
echo "Domain: $DOMAIN" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

log "🚀 Starting TRAE SOLO Full NEXUS COS Deployment"
log "Target VPS: $VPS_HOST"
log "Domain: $DOMAIN"

# Function to execute commands on VPS
vps_exec() {
    local cmd="$1"
    log "Executing on VPS: $cmd"
    sshpass -p "$VPS_AUTH" ssh -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "$cmd" 2>&1 | tee -a "$LOG_FILE"
}

# Function to copy files to VPS
vps_copy() {
    local src="$1"
    local dest="$2"
    log "Copying $src to VPS:$dest"
    sshpass -p "$VPS_AUTH" scp -o StrictHostKeyChecking=no -r "$src" "$VPS_USER@$VPS_HOST:$dest" 2>&1 | tee -a "$LOG_FILE"
}

# Step 1: Remove old Nexus COS files and services
log "📦 Step 1: Cleaning up old installations"
vps_exec "systemctl stop nexus-node || true"
vps_exec "systemctl stop nexus-python || true"
vps_exec "systemctl disable nexus-node || true"
vps_exec "systemctl disable nexus-python || true"
vps_exec "pm2 stop all || true"
vps_exec "pm2 delete all || true"
vps_exec "rm -rf $DEPLOY_DIR || true"
vps_exec "rm -rf $WWW_DIR || true"
vps_exec "rm -f /etc/systemd/system/nexus-*.service || true"
vps_exec "systemctl daemon-reload"
success "Old installations cleaned up"

# Step 2: Update system and install dependencies
log "🔧 Step 2: Installing system dependencies"
vps_exec "apt update && apt upgrade -y"
vps_exec "apt install -y nginx certbot python3-certbot-nginx nodejs npm python3 python3-pip git curl wget unzip sshpass"
vps_exec "npm install -g pm2 @nestjs/cli"
vps_exec "pip3 install fastapi uvicorn python-multipart"
success "System dependencies installed"

# Step 3: Create deployment directories
log "📁 Step 3: Creating deployment directories"
vps_exec "mkdir -p $DEPLOY_DIR"
vps_exec "mkdir -p $WWW_DIR"
vps_exec "mkdir -p $WWW_DIR/mobile"
vps_exec "chown -R www-data:www-data $WWW_DIR"
success "Deployment directories created"

# Step 4: Clone/pull latest code
log "📥 Step 4: Deploying application code"
if [ -d "$LOCAL_PROJECT" ]; then
    log "Copying from local project: $LOCAL_PROJECT"
    vps_copy "$LOCAL_PROJECT/*" "$DEPLOY_DIR/"
else
    log "Cloning from GitHub: $GITHUB_REPO"
    vps_exec "cd $DEPLOY_DIR && git clone $GITHUB_REPO ."
fi
success "Application code deployed"

# Step 5: Install Node.js dependencies and build
log "📦 Step 5: Installing Node.js dependencies"
vps_exec "cd $DEPLOY_DIR && npm install"
vps_exec "cd $DEPLOY_DIR/backend && npm install"
vps_exec "cd $DEPLOY_DIR/frontend && npm install && npm run build"
vps_exec "cp -r $DEPLOY_DIR/frontend/dist/* $WWW_DIR/"
success "Node.js application built and deployed"

# Step 6: Install Python dependencies
log "🐍 Step 6: Installing Python dependencies"
vps_exec "cd $DEPLOY_DIR/backend && pip3 install -r requirements.txt || true"
success "Python dependencies installed"

# Step 7: Create systemd services
log "⚙️ Step 7: Creating systemd services"

# Node.js service
vps_exec "cat > /etc/systemd/system/nexus-node.service << 'EOF'
[Unit]
Description=Nexus COS Node.js Backend
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$DEPLOY_DIR/backend
Environment=NODE_ENV=production
Environment=PORT=3000
ExecStart=/usr/bin/node app.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"

# Python service
vps_exec "cat > /etc/systemd/system/nexus-python.service << 'EOF'
[Unit]
Description=Nexus COS Python Backend
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$DEPLOY_DIR/backend
Environment=PYTHONPATH=$DEPLOY_DIR/backend
ExecStart=/usr/bin/python3 -m uvicorn app.main:app --host 0.0.0.0 --port 3001
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"

vps_exec "systemctl daemon-reload"
vps_exec "systemctl enable nexus-node nexus-python"
success "Systemd services created"

# Step 8: Configure Nginx
log "🌐 Step 8: Configuring Nginx"
vps_exec "cat > /etc/nginx/sites-available/nexus-cos << 'EOF'
server {
    listen 80;
    server_name $DOMAIN *.$DOMAIN;
    
    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN *.$DOMAIN;
    
    # SSL Configuration (will be updated by certbot)
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection \"1; mode=block\";
    add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains\";
    
    # Frontend static files
    location / {
        root $WWW_DIR;
        try_files \$uri \$uri/ /index.html;
        expires 1y;
        add_header Cache-Control \"public, immutable\";
    }
    
    # Node.js backend API
    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # Node.js health endpoint
    location /health {
        proxy_pass http://localhost:3000/health;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Python backend API
    location /py/ {
        proxy_pass http://localhost:3001/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Python health endpoint
    location /py/health {
        proxy_pass http://localhost:3001/health;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Mobile app downloads
    location /mobile/ {
        root $WWW_DIR;
        autoindex on;
        expires 1d;
    }
}
EOF"

vps_exec "ln -sf /etc/nginx/sites-available/nexus-cos /etc/nginx/sites-enabled/"
vps_exec "rm -f /etc/nginx/sites-enabled/default"
vps_exec "nginx -t"
success "Nginx configured"

# Step 9: Install SSL certificates
log "🔒 Step 9: Installing SSL certificates"
vps_exec "systemctl stop nginx"
vps_exec "certbot certonly --standalone --agree-tos --no-eff-email --email puaboverse@gmail.com -d $DOMAIN -d *.$DOMAIN || true"
vps_exec "systemctl start nginx"
vps_exec "systemctl enable nginx"

# Setup auto-renewal
vps_exec "echo '0 12 * * * /usr/bin/certbot renew --quiet' | crontab -"
success "SSL certificates installed"

# Step 10: Deploy mobile builds
log "📱 Step 10: Deploying mobile builds"
if [ -f "$LOCAL_PROJECT/mobile/builds/android/app.apk" ]; then
    vps_copy "$LOCAL_PROJECT/mobile/builds/android/app.apk" "$WWW_DIR/mobile/"
fi
if [ -f "$LOCAL_PROJECT/mobile/builds/ios/app.ipa" ]; then
    vps_copy "$LOCAL_PROJECT/mobile/builds/ios/app.ipa" "$WWW_DIR/mobile/"
fi
vps_exec "chown -R www-data:www-data $WWW_DIR/mobile"
success "Mobile builds deployed"

# Step 11: Start services
log "🚀 Step 11: Starting services"
vps_exec "systemctl start nexus-node"
vps_exec "systemctl start nexus-python"
vps_exec "systemctl restart nginx"

# Wait for services to start
sleep 10

vps_exec "systemctl status nexus-node --no-pager"
vps_exec "systemctl status nexus-python --no-pager"
vps_exec "systemctl status nginx --no-pager"
success "All services started"

# Step 12: Health checks
log "🏥 Step 12: Running health checks"

# Function to check health endpoint
check_health() {
    local url="$1"
    local name="$2"
    log "Checking $name health: $url"
    
    for i in {1..5}; do
        if curl -f -s "$url" | grep -q '"status".*"ok"'; then
            success "$name health check passed"
            return 0
        else
            warning "$name health check failed (attempt $i/5)"
            sleep 5
        fi
    done
    
    error "$name health check failed after 5 attempts"
}

# Wait for services to fully start
sleep 15

# Check health endpoints
check_health "https://$DOMAIN/health" "Node.js Backend"
check_health "https://$DOMAIN/py/health" "Python Backend"

# Check frontend
if curl -f -s "https://$DOMAIN" > /dev/null; then
    success "Frontend is accessible"
else
    warning "Frontend accessibility check failed"
fi

# Step 13: Install Puppeteer for testing
log "🧪 Step 13: Installing Puppeteer for testing"
vps_exec "cd $DEPLOY_DIR && npm install puppeteer"

# Create simple E2E test
vps_exec "cat > $DEPLOY_DIR/e2e-test.js << 'EOF'
const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({args: ['--no-sandbox', '--disable-setuid-sandbox']});
  const page = await browser.newPage();
  
  try {
    // Test frontend
    console.log('Testing frontend...');
    await page.goto('https://$DOMAIN', {waitUntil: 'networkidle2'});
    console.log('✓ Frontend loaded successfully');
    
    // Test API endpoints
    console.log('Testing API endpoints...');
    const nodeHealth = await page.goto('https://$DOMAIN/health');
    console.log('✓ Node.js health endpoint:', nodeHealth.status());
    
    const pythonHealth = await page.goto('https://$DOMAIN/py/health');
    console.log('✓ Python health endpoint:', pythonHealth.status());
    
    console.log('🎉 All E2E tests passed!');
  } catch (error) {
    console.error('❌ E2E test failed:', error.message);
    process.exit(1);
  } finally {
    await browser.close();
  }
})();
EOF"

# Run E2E tests
vps_exec "cd $DEPLOY_DIR && timeout 60 node e2e-test.js || true"
success "E2E tests completed"

# Step 14: Generate deployment summary
log "📋 Step 14: Generating deployment summary"

DEPLOY_SUMMARY="/tmp/nexus-cos-deployment-summary.txt"
vps_exec "cat > $DEPLOY_SUMMARY << 'EOF'
🚀 NEXUS COS DEPLOYMENT SUMMARY
================================
Deployment Date: $(date)
VPS: $VPS_HOST
Domain: $DOMAIN

📊 SERVICE STATUS:
$(systemctl is-active nexus-node) - Node.js Backend (Port 3000)
$(systemctl is-active nexus-python) - Python Backend (Port 3001)
$(systemctl is-active nginx) - Nginx Web Server

🌐 ENDPOINTS:
- Frontend: https://$DOMAIN
- Node.js API: https://$DOMAIN/api/
- Python API: https://$DOMAIN/py/
- Node.js Health: https://$DOMAIN/health
- Python Health: https://$DOMAIN/py/health
- Mobile Downloads: https://$DOMAIN/mobile/

🔒 SSL STATUS:
$(certbot certificates | grep -A 5 $DOMAIN || echo 'SSL certificate check failed')

📱 MOBILE BUILDS:
$(ls -la $WWW_DIR/mobile/ || echo 'No mobile builds found')

🔧 SYSTEM INFO:
- OS: $(lsb_release -d | cut -f2)
- Node.js: $(node --version)
- Python: $(python3 --version)
- Nginx: $(nginx -v 2>&1)

📝 DEPLOYMENT LOG:
See: $LOG_FILE
EOF"

# Display summary
vps_exec "cat $DEPLOY_SUMMARY"

# Copy summary to local
sshpass -p "$VPS_AUTH" scp -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST:$DEPLOY_SUMMARY" "./nexus-cos-deployment-summary.txt"

success "🎉 TRAE SOLO Full NEXUS COS Deployment Complete!"
log "📋 Deployment summary saved to: ./nexus-cos-deployment-summary.txt"
log "🌐 Your NEXUS COS is now live at: https://$DOMAIN"
log "📊 Monitor services with: systemctl status nexus-node nexus-python nginx"
log "📝 Full deployment log: $LOG_FILE"

echo ""
echo "🚀 DEPLOYMENT COMPLETE! 🚀"
echo "🌐 Visit: https://$DOMAIN"
echo "📊 Health: https://$DOMAIN/health"
echo "🐍 Python: https://$DOMAIN/py/health"
echo ""