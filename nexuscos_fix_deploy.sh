#!/bin/bash
# Nexus COS Production Deployment and Fix Script
# This script is idempotent and safe to run multiple times
# It fixes server.js 404 errors and deploys with PM2 and Nginx

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PM2_PROCESS_NAME="nexus-cos"
NODE_APP_PATH="$(pwd)/server.js"
NODE_PORT="3000"
NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"
NGINX_CONFIG_NAME="nexuscos"
NGINX_CONFIG_FILE="$NGINX_SITES_AVAILABLE/$NGINX_CONFIG_NAME.conf"
DOMAIN="n3xuscos.online"

# Helper functions
print_info() {
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

print_step() {
    echo -e "\n${BLUE}==== $1 ====${NC}"
}

# Check if running as root for nginx operations
check_privileges() {
    if [[ $EUID -ne 0 ]]; then
        print_warning "This script requires sudo privileges for nginx configuration"
        print_info "Please run with sudo or ensure you have the necessary permissions"
    fi
}

# Step 1: Stop and delete existing PM2 process
cleanup_pm2() {
    print_step "Cleaning up existing PM2 processes"
    
    # Check if PM2 is installed
    if ! command -v pm2 &> /dev/null; then
        print_info "PM2 not found, installing globally..."
        npm install -g pm2
    fi
    
    # Stop and delete any existing nexus-cos process
    if pm2 list | grep -q "$PM2_PROCESS_NAME"; then
        print_info "Stopping existing PM2 process: $PM2_PROCESS_NAME"
        pm2 stop "$PM2_PROCESS_NAME" || true
        pm2 delete "$PM2_PROCESS_NAME" || true
        print_success "Existing PM2 process cleaned up"
    else
        print_info "No existing PM2 process found for $PM2_PROCESS_NAME"
    fi
}

# Step 2: Start PM2 process and save
start_pm2() {
    print_step "Starting PM2 process"
    
    # Verify server.js exists
    if [[ ! -f "$NODE_APP_PATH" ]]; then
        print_error "server.js not found at $NODE_APP_PATH"
        exit 1
    fi
    
    # Start the application with PM2
    print_info "Starting $PM2_PROCESS_NAME with PM2..."
    pm2 start "$NODE_APP_PATH" --name "$PM2_PROCESS_NAME" --node-args="--max-old-space-size=1024"
    
    # Save PM2 process list
    print_info "Saving PM2 process list..."
    pm2 save
    
    # Set up PM2 startup script (if not already done)
    pm2 startup || true
    
    print_success "PM2 process started and saved"
}

# Step 3: Clean up legacy Nginx configurations
cleanup_nginx_configs() {
    print_step "Cleaning up legacy/duplicate Nginx configurations"
    
    # Remove any legacy configs in conf.d
    if [[ -d "/etc/nginx/conf.d" ]]; then
        print_info "Removing legacy configs from /etc/nginx/conf.d/"
        rm -f /etc/nginx/conf.d/nexuscos* /etc/nginx/conf.d/nexus-cos* || true
    fi
    
    # Remove any existing configs in sites-enabled (we'll recreate the link)
    if [[ -d "$NGINX_SITES_ENABLED" ]]; then
        print_info "Removing existing configs from $NGINX_SITES_ENABLED/"
        rm -f "$NGINX_SITES_ENABLED/nexuscos"* "$NGINX_SITES_ENABLED/nexus-cos"* || true
    fi
    
    # Remove any existing config file in sites-available
    if [[ -f "$NGINX_CONFIG_FILE" ]]; then
        print_info "Removing existing config file: $NGINX_CONFIG_FILE"
        rm -f "$NGINX_CONFIG_FILE"
    fi
    
    print_success "Legacy Nginx configurations cleaned up"
}

# Step 4: Create proper Nginx server block
create_nginx_config() {
    print_step "Creating Nginx server block configuration"
    
    # Ensure directories exist
    mkdir -p "$NGINX_SITES_AVAILABLE" "$NGINX_SITES_ENABLED"
    
    print_info "Creating Nginx configuration at $NGINX_CONFIG_FILE"
    
    # Create the nginx configuration
    cat > "$NGINX_CONFIG_FILE" << EOF
# Nexus COS Production Configuration
# HTTP server block - redirects to HTTPS
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Redirect all HTTP traffic to HTTPS
    return 301 https://\$server_name\$request_uri;
}

# HTTPS server block
server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;
    
    # SSL Configuration (managed by certbot)
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Proxy all requests to Node.js application
    location / {
        proxy_pass http://127.0.0.1:$NODE_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Health check endpoint
    location /health {
        proxy_pass http://127.0.0.1:$NODE_PORT/health;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Block access to sensitive files
    location ~ /\. {
        deny all;
    }
    
    location ~ /(README|CHANGELOG|LICENSE|COPYING|\.env) {
        deny all;
    }
    
    # Logging
    error_log /var/log/nginx/$DOMAIN.error.log;
    access_log /var/log/nginx/$DOMAIN.access.log;
}
EOF
    
    print_success "Nginx configuration created"
}

# Step 5: Enable Nginx site
enable_nginx_site() {
    print_step "Enabling Nginx site"
    
    # Create symbolic link to enable the site
    print_info "Creating symbolic link to enable site..."
    ln -sf "$NGINX_CONFIG_FILE" "$NGINX_SITES_ENABLED/$NGINX_CONFIG_NAME.conf"
    
    print_success "Nginx site enabled"
}

# Step 6: Test and restart Nginx
test_and_restart_nginx() {
    print_step "Testing Nginx configuration and restarting"
    
    # Test nginx configuration
    print_info "Testing Nginx configuration..."
    if nginx -t; then
        print_success "Nginx configuration test passed"
        
        # Restart nginx
        print_info "Restarting Nginx..."
        systemctl restart nginx
        
        # Check if nginx is running
        if systemctl is-active --quiet nginx; then
            print_success "Nginx restarted successfully"
        else
            print_error "Nginx failed to start"
            systemctl status nginx
            exit 1
        fi
    else
        print_error "Nginx configuration test failed"
        exit 1
    fi
}

# Main deployment function
main() {
    print_info "🚀 Starting Nexus COS deployment and fix process..."
    print_info "Process ID: $$"
    print_info "Working directory: $(pwd)"
    print_info "Timestamp: $(date)"
    
    # Check privileges
    check_privileges
    
    # Execute deployment steps
    cleanup_pm2
    start_pm2
    cleanup_nginx_configs
    create_nginx_config
    enable_nginx_site
    test_and_restart_nginx
    
    print_step "Deployment Summary"
    print_success "🎉 Nexus COS deployment completed successfully!"
    echo ""
    echo "📋 Deployment Details:"
    echo "  🔹 PM2 Process: $PM2_PROCESS_NAME"
    echo "  🔹 Node.js Port: $NODE_PORT"
    echo "  🔹 Nginx Config: $NGINX_CONFIG_FILE"
    echo "  🔹 Domain: $DOMAIN"
    echo ""
    echo "🔍 Process Status:"
    pm2 list | grep "$PM2_PROCESS_NAME" || echo "  ⚠️  PM2 process not found"
    echo ""
    systemctl is-active nginx >/dev/null && echo "  ✅ Nginx: Active" || echo "  ❌ Nginx: Inactive"
    echo ""
    echo "🧪 Testing Instructions:"
    echo ""
    echo "  📍 Local Testing:"
    echo "    curl http://127.0.0.1:$NODE_PORT"
    echo "    curl http://127.0.0.1:$NODE_PORT/api/auth/"
    echo ""
    echo "  🌐 Public Testing:"
    echo "    curl https://$DOMAIN"
    echo "    curl https://$DOMAIN/api/auth/"
    echo "    Open browser: https://$DOMAIN"
    echo ""
    echo "🔧 Useful Commands:"
    echo "  pm2 list                    # View PM2 processes"
    echo "  pm2 logs $PM2_PROCESS_NAME  # View application logs"
    echo "  pm2 restart $PM2_PROCESS_NAME # Restart application"
    echo "  systemctl status nginx      # Check nginx status"
    echo "  tail -f /var/log/nginx/$DOMAIN.error.log # View nginx errors"
}

# Run main function with all arguments
main "$@"