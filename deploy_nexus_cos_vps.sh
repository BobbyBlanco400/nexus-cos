#!/bin/bash

# Nexus COS VPS Deployment Script for IONOS VPS
# This script deploys the full Nexus COS application on a production VPS

set -e

echo "🚀 Starting Nexus COS VPS Deployment..."

# Configuration variables - UPDATE THESE FOR YOUR VPS
DOMAIN="your-domain.com"  # Update with your actual domain
SERVER_USER="root"        # Update with your VPS user
BACKEND_PORT="8000"
FRONTEND_PORT="3000"
DB_NAME="nexus_cos_db"
DB_USER="nexus_user"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root or with sudo
check_permissions() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo"
        exit 1
    fi
}

# Update system packages
update_system() {
    log_info "Updating system packages..."
    apt update && apt upgrade -y
    apt install -y curl wget git build-essential
}

# Install Node.js 22
install_nodejs() {
    log_info "Installing Node.js 22..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y nodejs
    
    # Verify installation
    node_version=$(node --version)
    npm_version=$(npm --version)
    log_info "Node.js version: $node_version"
    log_info "npm version: $npm_version"
}

# Install Python 3.12 and Poetry
install_python() {
    log_info "Installing Python 3.12 and Poetry..."
    apt install -y python3.12 python3.12-venv python3-pip python3.12-dev
    
    # Install Poetry
    curl -sSL https://install.python-poetry.org | python3 -
    export PATH="/root/.local/bin:$PATH"
    echo 'export PATH="/root/.local/bin:$PATH"' >> ~/.bashrc
    
    # Verify installation
    python_version=$(python3.12 --version)
    log_info "Python version: $python_version"
}

# Install and configure PostgreSQL
install_postgresql() {
    log_info "Installing PostgreSQL..."
    apt install -y postgresql postgresql-contrib
    
    # Start and enable PostgreSQL
    systemctl start postgresql
    systemctl enable postgresql
    
    # Create database and user
    log_info "Setting up database..."
    sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
    sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD 'secure_password_here';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
    
    log_info "PostgreSQL setup completed"
}

# Install and configure Nginx
install_nginx() {
    log_info "Installing Nginx..."
    apt install -y nginx
    
    # Create Nginx configuration
    cat > /etc/nginx/sites-available/nexus-cos << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;
    
    # SSL configuration (will be handled by Certbot)
    # ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # Frontend - serve React build files
    location / {
        root /var/www/nexus-cos/frontend/dist;
        index index.html;
        try_files \$uri \$uri/ /index.html;
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
    }
    
    # Backend API proxy
    location /api/ {
        proxy_pass http://127.0.0.1:$BACKEND_PORT/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # Static assets caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

    # Enable the site
    ln -sf /etc/nginx/sites-available/nexus-cos /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    # Test and reload Nginx
    nginx -t && systemctl reload nginx
    systemctl enable nginx
    
    log_info "Nginx configuration completed"
}

# Install SSL certificate with Certbot
install_ssl() {
    log_info "Installing SSL certificate with Let's Encrypt..."
    apt install -y certbot python3-certbot-nginx
    
    # Obtain SSL certificate
    certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN
    
    # Set up auto-renewal
    systemctl enable certbot.timer
    
    log_info "SSL certificate installed and auto-renewal configured"
}

# Create application directory and deploy code
deploy_application() {
    log_info "Deploying application code..."
    
    # Create application directory
    mkdir -p /var/www/nexus-cos
    cd /var/www/nexus-cos
    
    # If this is a fresh deployment, clone the repo
    if [ ! -d ".git" ]; then
        log_info "Cloning repository..."
        git clone https://github.com/BobbyBlanco400/nexus-cos.git .
    else
        log_info "Updating repository..."
        git pull origin main
    fi
    
    # Create environment file for backend
    cat > backend/.env << EOF
DATABASE_URL=postgresql://$DB_USER:secure_password_here@localhost/$DB_NAME
ENVIRONMENT=production
DEBUG=false
ALLOWED_HOSTS=$DOMAIN,www.$DOMAIN
SECRET_KEY=your_secret_key_here_change_this_in_production
EOF

    # Install and build frontend
    log_info "Installing frontend dependencies and building..."
    cd frontend
    npm ci --only=production
    npm run build
    cd ..
    
    # Install backend dependencies
    log_info "Installing backend dependencies..."
    cd backend
    python3.12 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install poetry
    poetry install --no-root --only=main
    
    # Run database migrations
    log_info "Running database migrations..."
    poetry run alembic upgrade head
    
    cd ..
    
    # Set proper permissions
    chown -R www-data:www-data /var/www/nexus-cos
    chmod -R 755 /var/www/nexus-cos
    
    log_info "Application deployment completed"
}

# Create systemd service for backend
create_backend_service() {
    log_info "Creating systemd service for backend..."
    
    cat > /etc/systemd/system/nexus-cos-backend.service << EOF
[Unit]
Description=Nexus COS Backend API
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/nexus-cos/backend
Environment=PATH=/var/www/nexus-cos/backend/venv/bin
ExecStart=/var/www/nexus-cos/backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port $BACKEND_PORT
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and start services
    systemctl daemon-reload
    systemctl enable nexus-cos-backend
    systemctl start nexus-cos-backend
    
    log_info "Backend service created and started"
}

# Setup firewall
configure_firewall() {
    log_info "Configuring firewall..."
    ufw --force enable
    ufw allow ssh
    ufw allow 'Nginx Full'
    ufw reload
    
    log_info "Firewall configured"
}

# Main deployment function
main() {
    log_info "Starting Nexus COS VPS deployment process..."
    
    check_permissions
    update_system
    install_nodejs
    install_python
    install_postgresql
    install_nginx
    deploy_application
    create_backend_service
    configure_firewall
    
    # Install SSL after everything is set up
    install_ssl
    
    log_info "✅ Nexus COS deployment completed successfully!"
    log_info "Your application should be available at: https://$DOMAIN"
    log_info ""
    log_info "Next steps:"
    log_info "1. Update the domain variable in this script with your actual domain"
    log_info "2. Update database password in backend/.env"
    log_info "3. Update SECRET_KEY in backend/.env"
    log_info "4. Update your DNS records to point to this server"
    log_info "5. Test the application at https://$DOMAIN"
    log_info ""
    log_info "Service status:"
    systemctl status nexus-cos-backend --no-pager -l
    systemctl status nginx --no-pager -l
    systemctl status postgresql --no-pager -l
}

# Run main function
main "$@"