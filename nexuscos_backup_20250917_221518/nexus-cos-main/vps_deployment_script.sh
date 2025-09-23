#!/bin/bash
# NEXUS COS VPS Deployment Script
# Complete deployment automation for Ubuntu/Debian VPS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root (use sudo)"
   exit 1
fi

print_header "NEXUS COS VPS DEPLOYMENT STARTING"

# Step 1: Update system and install basic dependencies
print_header "Installing System Dependencies"
print_status "Updating package lists..."
apt update

print_status "Installing essential packages..."
apt install -y curl wget gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release

# Step 2: Install Node.js 22.x
print_header "Installing Node.js 22.x"
print_status "Adding NodeSource repository..."
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

# Install pnpm globally
print_status "Installing pnpm package manager..."
npm install -g pnpm

print_success "Node.js $(node --version) and pnpm $(pnpm --version) installed"

# Step 3: Install Python 3.12
print_header "Installing Python 3.12"
print_status "Adding deadsnakes PPA for Python 3.12..."
add-apt-repository -y ppa:deadsnakes/ppa
apt update
apt install -y python3.12 python3.12-venv python3.12-dev python3-pip

# Set Python 3.12 as default python3
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

print_success "Python $(python3 --version) installed"

# Step 4: Install build tools
print_header "Installing Build Tools"
apt install -y build-essential gcc g++ make git

print_success "Build tools installed"

# Step 5: Install and configure nginx
print_header "Installing and Configuring Nginx"
apt install -y nginx
systemctl enable nginx
systemctl start nginx

print_success "Nginx installed and started"

# Step 6: Install certbot for SSL
print_header "Installing Certbot for SSL"
apt install -y certbot python3-certbot-nginx

print_success "Certbot installed"

# Step 7: Install PM2 for process management
print_header "Installing PM2 Process Manager"
npm install -g pm2
pm2 startup

print_success "PM2 installed"

# Step 8: Create application directory and user
print_header "Setting up Application Environment"
print_status "Creating nexus user and directories..."
useradd -m -s /bin/bash nexus || true
mkdir -p /var/www/nexus-cos
mkdir -p /opt/nexus-cos
chown -R nexus:nexus /opt/nexus-cos
chown -R www-data:www-data /var/www/nexus-cos

print_success "Application environment created"

# Step 9: Configure firewall
print_header "Configuring Firewall"
ufw --force enable
ufw allow ssh
ufw allow 'Nginx Full'
ufw allow 3000  # Node.js backend
ufw allow 3001  # Python backend

print_success "Firewall configured"

# Step 10: Create systemd services
print_header "Creating Systemd Services"

# Node.js backend service
cat > /etc/systemd/system/nexus-node-backend.service << 'EOF'
[Unit]
Description=Nexus COS Node.js Backend
After=network.target

[Service]
Type=simple
User=nexus
WorkingDirectory=/opt/nexus-cos/backend
Environment=NODE_ENV=production
Environment=PORT=3000
ExecStart=/usr/bin/npx ts-node src/server.ts
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Python backend service
cat > /etc/systemd/system/nexus-python-backend.service << 'EOF'
[Unit]
Description=Nexus COS Python Backend
After=network.target

[Service]
Type=simple
User=nexus
WorkingDirectory=/opt/nexus-cos/backend
Environment=PYTHONPATH=/opt/nexus-cos/backend
ExecStart=/opt/nexus-cos/backend/.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 3001
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

print_success "Systemd services created"

# Step 11: Create deployment script
print_header "Creating Deployment Helper Scripts"

cat > /opt/deploy-nexus.sh << 'EOF'
#!/bin/bash
# Nexus COS Deployment Helper

set -e

APP_DIR="/opt/nexus-cos"
WEB_DIR="/var/www/nexus-cos"

echo "🚀 Deploying Nexus COS..."

# Stop services
sudo systemctl stop nexus-node-backend || true
sudo systemctl stop nexus-python-backend || true

# Update code (if git repo exists)
if [ -d "$APP_DIR/.git" ]; then
    cd $APP_DIR
    sudo -u nexus git pull
else
    echo "⚠️  No git repository found. Please clone your code to $APP_DIR"
fi

# Install dependencies and build
cd $APP_DIR

# Backend dependencies
echo "📦 Installing backend dependencies..."
cd backend
sudo -u nexus npm install

# Setup Python environment
if [ ! -d ".venv" ]; then
    sudo -u nexus python3 -m venv .venv
fi
sudo -u nexus .venv/bin/pip install -r requirements.txt
cd ..

# Frontend build
echo "🏗️  Building frontend..."
cd frontend
sudo -u nexus npm install
sudo -u nexus npm run build

# Deploy frontend
sudo cp -r dist/* $WEB_DIR/
sudo chown -R www-data:www-data $WEB_DIR
cd ..

# Mobile build (if needed)
if [ -d "mobile" ]; then
    echo "📱 Building mobile apps..."
    cd mobile
    sudo -u nexus ./build-mobile.sh || echo "Mobile build failed or not available"
    cd ..
fi

# Start services
sudo systemctl start nexus-node-backend
sudo systemctl start nexus-python-backend
sudo systemctl enable nexus-node-backend
sudo systemctl enable nexus-python-backend

# Reload nginx
sudo systemctl reload nginx

echo "✅ Deployment complete!"
echo "🌐 Check status: sudo systemctl status nexus-node-backend nexus-python-backend"
EOF

chmod +x /opt/deploy-nexus.sh

print_success "Deployment helper script created at /opt/deploy-nexus.sh"

# Step 12: Create SSL setup script
cat > /opt/setup-ssl.sh << 'EOF'
#!/bin/bash
# SSL Setup for Nexus COS

DOMAIN="nexuscos.online"
EMAIL="admin@nexuscos.online"  # Change this to your email

echo "🔒 Setting up SSL for $DOMAIN..."

# Get SSL certificate
certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email $EMAIL

# Setup auto-renewal
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -

echo "✅ SSL setup complete!"
EOF

chmod +x /opt/setup-ssl.sh

print_success "SSL setup script created at /opt/setup-ssl.sh"

# Final status report
print_header "DEPLOYMENT COMPLETE"
print_success "🎉 VPS setup completed successfully!"
echo ""
echo "📋 Next Steps:"
echo "  1. Clone your code to /opt/nexus-cos:"
echo "     sudo -u nexus git clone <your-repo-url> /opt/nexus-cos"
echo ""
echo "  2. Deploy the application:"
echo "     /opt/deploy-nexus.sh"
echo ""
echo "  3. Setup SSL (after DNS is configured):"
echo "     /opt/setup-ssl.sh"
echo ""
echo "  4. Configure nginx:"
echo "     sudo cp /opt/nexus-cos/deployment/nginx/nexuscos.online.conf /etc/nginx/sites-available/"
echo "     sudo ln -sf /etc/nginx/sites-available/nexuscos.online.conf /etc/nginx/sites-enabled/"
echo "     sudo nginx -t && sudo systemctl reload nginx"
echo ""
echo "🔗 Service Management:"
echo "  • Check status: sudo systemctl status nexus-node-backend nexus-python-backend"
echo "  • View logs: sudo journalctl -u nexus-node-backend -f"
echo "  • Restart: sudo systemctl restart nexus-node-backend nexus-python-backend"
echo ""
echo "🌐 Access URLs (after deployment):"
echo "  • Frontend: https://nexuscos.online"
echo "  • Node API: https://nexuscos.online/api/"
echo "  • Python API: https://nexuscos.online/py/"
echo "  • Health checks: https://nexuscos.online/health"
echo ""
print_success "🚀 Your VPS is ready for Nexus COS deployment!"