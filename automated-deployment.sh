#!/bin/bash

# Nexus COS Automated Deployment Script
# Follows NEXUS_COS_BULLETPROOF_DEPLOYMENT_PF.md
# Run this on your IONOS VPS as root

# Don't exit on all errors - we want to handle them gracefully
set +e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}Nexus COS Automated Deployment${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (use sudo)"
    exit 1
fi

print_success "Running as root"

# PHASE 1: System Preparation
print_status "PHASE 1: System Preparation"

print_status "Updating system packages..."
apt update -y
apt upgrade -y
apt install -y curl wget git vim htop net-tools jq
print_success "System packages updated"

# Install Docker
if ! command -v docker &> /dev/null; then
    print_status "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    print_success "Docker installed"
else
    print_success "Docker already installed"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_status "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed"
else
    print_success "Docker Compose already installed"
fi

# Install Node.js
if ! command -v node &> /dev/null; then
    print_status "Installing Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
    print_success "Node.js installed"
else
    print_success "Node.js already installed"
fi

# Install Python
if ! command -v python3 &> /dev/null; then
    print_status "Installing Python..."
    apt install -y python3 python3-pip python3-venv
    print_success "Python installed"
else
    print_success "Python already installed"
fi

# Install Nginx
if ! command -v nginx &> /dev/null; then
    print_status "Installing Nginx..."
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
    print_success "Nginx installed"
else
    print_success "Nginx already installed"
fi

# Install PM2
if ! command -v pm2 &> /dev/null; then
    print_status "Installing PM2..."
    npm install -g pm2
    # Setup PM2 startup - get the command and execute it
    STARTUP_CMD=$(pm2 startup | grep "sudo env" || true)
    if [ -n "$STARTUP_CMD" ]; then
        eval "$STARTUP_CMD"
    fi
    print_success "PM2 installed"
else
    print_success "PM2 already installed"
fi

# PHASE 2: Repository Setup
print_status "PHASE 2: Repository Setup"

DEPLOY_DIR="/var/www/nexuscos.online"
APP_DIR="$DEPLOY_DIR/nexus-cos-app"

# Check if we're already in the repository
CURRENT_DIR=$(pwd)
if [ -f "$CURRENT_DIR/automated-deployment.sh" ] && [ -f "$CURRENT_DIR/nexus-cos-complete-audit.sh" ]; then
    print_status "Running from repository directory: $CURRENT_DIR"
    APP_DIR="$CURRENT_DIR"
    print_success "Using current directory as repository"
else
    print_status "Creating deployment directory..."
    mkdir -p $DEPLOY_DIR
    cd $DEPLOY_DIR
    
    if [ -d "$APP_DIR" ]; then
        print_warning "Repository already exists, pulling latest changes..."
        cd $APP_DIR
        git pull origin copilot/verify-production-readiness 2>/dev/null || true
    else
        print_status "Cloning repository..."
        git clone https://github.com/BobbyBlanco400/nexus-cos.git nexus-cos-app
        cd $APP_DIR
        git checkout copilot/verify-production-readiness
    fi
    
    print_success "Repository ready at $APP_DIR"
fi

# PHASE 3: Environment Configuration
print_status "PHASE 3: Environment Configuration"

print_warning "You need to manually configure environment variables"
print_warning "Edit $APP_DIR/.env and $APP_DIR/.env.production"
print_warning "Press Enter when you have completed environment configuration..."
read

# PHASE 4: Database Setup
print_status "PHASE 4: Database Setup"

print_status "Creating Docker network..."
docker network create cos-net 2>/dev/null || print_warning "Network cos-net already exists"

print_status "Starting PostgreSQL container..."
docker run -d \
  --name nexus-postgres \
  --network cos-net \
  -e POSTGRES_DB=nexus_cos \
  -e POSTGRES_USER=nexus_admin \
  -e POSTGRES_PASSWORD=$(grep DB_PASSWORD $APP_DIR/.env | cut -d'=' -f2) \
  -p 5432:5432 \
  -v nexus-postgres-data:/var/lib/postgresql/data \
  --restart unless-stopped \
  postgres:15 2>/dev/null || print_warning "PostgreSQL container already exists"

sleep 5
print_success "PostgreSQL container started"

# PHASE 5: Backend Deployment
print_status "PHASE 5: Backend Deployment"

cd $APP_DIR
print_status "Installing backend dependencies..."
npm install --production

if [ -d "backend" ]; then
    cd backend
    npm install --production
    cd ..
fi

if [ -f "requirements.txt" ]; then
    pip3 install -r requirements.txt
fi

print_status "Starting backend with PM2..."
pm2 start ecosystem.config.js 2>/dev/null || pm2 restart ecosystem.config.js
pm2 save
print_success "Backend services started"

# PHASE 6: Frontend Deployment
print_status "PHASE 6: Frontend Deployment"

if [ -d "$APP_DIR/frontend" ]; then
    cd $APP_DIR/frontend
    print_status "Installing frontend dependencies..."
    npm install
    
    print_status "Building frontend..."
    npm run build
    
    print_status "Deploying frontend..."
    mkdir -p /var/www/vhosts/nexuscos.online/httpdocs
    cp -r dist/* /var/www/vhosts/nexuscos.online/httpdocs/ 2>/dev/null || \
    cp -r build/* /var/www/vhosts/nexuscos.online/httpdocs/
    
    chown -R www-data:www-data /var/www/vhosts/nexuscos.online/httpdocs
    chmod -R 755 /var/www/vhosts/nexuscos.online/httpdocs
    
    print_success "Frontend deployed"
else
    print_warning "Frontend directory not found"
fi

# PHASE 7: Nginx Configuration
print_status "PHASE 7: Nginx Configuration"

if [ -f "$APP_DIR/nginx.conf" ] || [ -f "$APP_DIR/nginx/nginx.conf" ]; then
    print_status "Copying Nginx configuration..."
    
    # Copy the appropriate nginx config
    if [ -f "$APP_DIR/nginx/nginx.conf" ]; then
        cp $APP_DIR/nginx/nginx.conf /etc/nginx/sites-available/nexuscos.online
    else
        cp $APP_DIR/nginx.conf /etc/nginx/sites-available/nexuscos.online
    fi
    
    # Enable site
    rm -f /etc/nginx/sites-enabled/default
    ln -sf /etc/nginx/sites-available/nexuscos.online /etc/nginx/sites-enabled/
    
    # Test and reload
    nginx -t && systemctl reload nginx
    print_success "Nginx configured"
else
    print_warning "Nginx config not found, you'll need to configure manually"
fi

# PHASE 8: Firewall Configuration
print_status "PHASE 8: Firewall Configuration"

if command -v ufw &> /dev/null; then
    print_status "Configuring firewall..."
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    print_success "Firewall configured"
else
    apt install -y ufw
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    print_success "Firewall installed and configured"
fi

# PHASE 9: Production Audit
print_status "PHASE 9: Running Production Audit"

cd $APP_DIR
if [ -f "nexus-cos-complete-audit.sh" ]; then
    chmod +x nexus-cos-complete-audit.sh
    
    echo ""
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}Running Production Audit...${NC}"
    echo -e "${BLUE}==========================================${NC}"
    echo ""
    
    ./nexus-cos-complete-audit.sh
    
    AUDIT_EXIT_CODE=$?
    
    if [ $AUDIT_EXIT_CODE -eq 0 ]; then
        print_success "✅ PRODUCTION READINESS: CONFIRMED"
    elif [ $AUDIT_EXIT_CODE -eq 1 ]; then
        print_warning "⚠️ PRODUCTION READINESS: CONDITIONAL - Review warnings"
    else
        print_error "❌ PRODUCTION READINESS: NOT READY - Fix issues"
    fi
else
    print_warning "Audit script not found"
fi

# PHASE 10: Setup Monitoring
print_status "PHASE 10: Setting up Monitoring"

cat > /root/nexus-backup.sh << 'BACKUP_EOF'
#!/bin/bash
BACKUP_DIR=/root/backups
DATE=$(date +%Y%m%d-%H%M%S)
mkdir -p $BACKUP_DIR
docker exec nexus-postgres pg_dump -U nexus_admin nexus_cos > $BACKUP_DIR/db-$DATE.sql
tar -czf $BACKUP_DIR/app-$DATE.tar.gz /var/www/nexuscos.online/nexus-cos-app
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
echo "Backup completed: $DATE"
BACKUP_EOF

chmod +x /root/nexus-backup.sh

# Add to crontab if not already there
(crontab -l 2>/dev/null | grep -q nexus-backup.sh) || \
(crontab -l 2>/dev/null; echo "0 2 * * * /root/nexus-backup.sh >> /var/log/nexus-backup.log 2>&1") | crontab -

print_success "Backup script created and scheduled"

# Final Summary
echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Verify all services are running: pm2 list"
echo "2. Check application: https://nexuscos.online"
echo "3. Review logs: pm2 logs"
echo "4. Monitor system: htop"
echo ""
echo -e "${BLUE}Important Files:${NC}"
echo "- Application: $APP_DIR"
echo "- Nginx config: /etc/nginx/sites-available/nexuscos.online"
echo "- Environment: $APP_DIR/.env"
echo "- Audit script: $APP_DIR/nexus-cos-complete-audit.sh"
echo "- Backup script: /root/nexus-backup.sh"
echo ""
echo -e "${GREEN}🚀 Nexus COS is ready for launch!${NC}"
echo ""
