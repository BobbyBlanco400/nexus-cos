#!/bin/bash

# Nexus COS Extended - SSL Certificate Setup Script
# Automated Let's Encrypt SSL certificate generation for nexuscos.online

set -euo pipefail

# Configuration
DOMAIN="nexuscos.online"
SUBDOMAINS="www.nexuscos.online,monitoring.nexuscos.online,api.nexuscos.online"
EMAIL="${SSL_EMAIL:-admin@nexuscos.online}"
WEBROOT="/var/www/certbot"
SSL_DIR="/etc/nginx/ssl"
NGINX_CONF_DIR="/etc/nginx/conf.d"

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
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    
    # Update package list
    apt-get update -qq
    
    # Install required packages
    apt-get install -y \
        certbot \
        python3-certbot-nginx \
        nginx \
        curl \
        openssl
    
    log_success "Dependencies installed successfully"
}

# Create necessary directories
create_directories() {
    log_info "Creating SSL directories..."
    
    mkdir -p "$SSL_DIR/$DOMAIN"
    mkdir -p "$WEBROOT"
    mkdir -p "$NGINX_CONF_DIR"
    
    # Set proper permissions
    chmod 755 "$SSL_DIR"
    chmod 755 "$WEBROOT"
    
    log_success "Directories created successfully"
}

# Generate DH parameters for enhanced security
generate_dhparam() {
    local dhparam_file="$SSL_DIR/dhparam.pem"
    
    if [[ ! -f "$dhparam_file" ]]; then
        log_info "Generating DH parameters (this may take a while)..."
        openssl dhparam -out "$dhparam_file" 2048
        chmod 600 "$dhparam_file"
        log_success "DH parameters generated successfully"
    else
        log_info "DH parameters already exist, skipping generation"
    fi
}

# Create temporary Nginx configuration for ACME challenge
create_temp_nginx_config() {
    log_info "Creating temporary Nginx configuration..."
    
    cat > "$NGINX_CONF_DIR/temp-ssl-setup.conf" << EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN $SUBDOMAINS;
    
    location /.well-known/acme-challenge/ {
        root $WEBROOT;
        try_files \$uri =404;
    }
    
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}
EOF
    
    # Test and reload Nginx
    nginx -t && systemctl reload nginx
    
    log_success "Temporary Nginx configuration created"
}

# Obtain SSL certificates
obtain_certificates() {
    log_info "Obtaining SSL certificates from Let's Encrypt..."
    
    # Build certbot command
    local certbot_cmd="certbot certonly"
    certbot_cmd+=" --webroot"
    certbot_cmd+=" --webroot-path=$WEBROOT"
    certbot_cmd+=" --email $EMAIL"
    certbot_cmd+=" --agree-tos"
    certbot_cmd+=" --no-eff-email"
    certbot_cmd+=" --domains $DOMAIN,$SUBDOMAINS"
    certbot_cmd+=" --non-interactive"
    
    # Run certbot
    if $certbot_cmd; then
        log_success "SSL certificates obtained successfully"
    else
        log_error "Failed to obtain SSL certificates"
        exit 1
    fi
}

# Copy certificates to Nginx SSL directory
copy_certificates() {
    log_info "Copying certificates to Nginx SSL directory..."
    
    local cert_dir="/etc/letsencrypt/live/$DOMAIN"
    local target_dir="$SSL_DIR/$DOMAIN"
    
    if [[ -d "$cert_dir" ]]; then
        cp "$cert_dir/fullchain.pem" "$target_dir/"
        cp "$cert_dir/privkey.pem" "$target_dir/"
        cp "$cert_dir/chain.pem" "$target_dir/"
        cp "$cert_dir/cert.pem" "$target_dir/"
        
        # Set proper permissions
        chmod 644 "$target_dir/fullchain.pem"
        chmod 644 "$target_dir/chain.pem"
        chmod 644 "$target_dir/cert.pem"
        chmod 600 "$target_dir/privkey.pem"
        
        log_success "Certificates copied successfully"
    else
        log_error "Certificate directory not found: $cert_dir"
        exit 1
    fi
}

# Install production Nginx configuration
install_nginx_config() {
    log_info "Installing production Nginx configuration..."
    
    # Remove temporary configuration
    rm -f "$NGINX_CONF_DIR/temp-ssl-setup.conf"
    
    # Copy production configuration
    if [[ -f "/opt/nexus-cos/nginx/nexuscos-online.conf" ]]; then
        cp "/opt/nexus-cos/nginx/nexuscos-online.conf" "$NGINX_CONF_DIR/"
        log_success "Production Nginx configuration installed"
    else
        log_warning "Production Nginx configuration not found, using default"
    fi
    
    # Test and reload Nginx
    if nginx -t; then
        systemctl reload nginx
        log_success "Nginx configuration reloaded successfully"
    else
        log_error "Nginx configuration test failed"
        exit 1
    fi
}

# Setup automatic certificate renewal
setup_auto_renewal() {
    log_info "Setting up automatic certificate renewal..."
    
    # Create renewal script
    cat > "/usr/local/bin/renew-nexuscos-ssl.sh" << 'EOF'
#!/bin/bash

# Nexus COS SSL Certificate Renewal Script
set -euo pipefail

DOMAIN="nexuscos.online"
SSL_DIR="/etc/nginx/ssl"
LOG_FILE="/var/log/nexuscos-ssl-renewal.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log "Starting SSL certificate renewal process"

# Renew certificates
if certbot renew --quiet --no-self-upgrade; then
    log "Certificate renewal successful"
    
    # Copy renewed certificates
    if [[ -d "/etc/letsencrypt/live/$DOMAIN" ]]; then
        cp "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" "$SSL_DIR/$DOMAIN/"
        cp "/etc/letsencrypt/live/$DOMAIN/privkey.pem" "$SSL_DIR/$DOMAIN/"
        cp "/etc/letsencrypt/live/$DOMAIN/chain.pem" "$SSL_DIR/$DOMAIN/"
        cp "/etc/letsencrypt/live/$DOMAIN/cert.pem" "$SSL_DIR/$DOMAIN/"
        
        # Set proper permissions
        chmod 644 "$SSL_DIR/$DOMAIN/fullchain.pem"
        chmod 644 "$SSL_DIR/$DOMAIN/chain.pem"
        chmod 644 "$SSL_DIR/$DOMAIN/cert.pem"
        chmod 600 "$SSL_DIR/$DOMAIN/privkey.pem"
        
        log "Certificates copied successfully"
        
        # Reload Nginx
        if nginx -t && systemctl reload nginx; then
            log "Nginx reloaded successfully"
        else
            log "ERROR: Failed to reload Nginx"
            exit 1
        fi
    else
        log "ERROR: Certificate directory not found"
        exit 1
    fi
else
    log "ERROR: Certificate renewal failed"
    exit 1
fi

log "SSL certificate renewal process completed"
EOF
    
    # Make renewal script executable
    chmod +x "/usr/local/bin/renew-nexuscos-ssl.sh"
    
    # Add cron job for automatic renewal (twice daily)
    cat > "/etc/cron.d/nexuscos-ssl-renewal" << EOF
# Nexus COS SSL Certificate Auto-Renewal
# Runs twice daily at random times to avoid load spikes
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Renew certificates twice daily
0 2,14 * * * root /usr/local/bin/renew-nexuscos-ssl.sh >/dev/null 2>&1
EOF
    
    log_success "Automatic certificate renewal configured"
}

# Verify SSL installation
verify_ssl() {
    log_info "Verifying SSL installation..."
    
    # Check certificate validity
    local cert_file="$SSL_DIR/$DOMAIN/fullchain.pem"
    
    if [[ -f "$cert_file" ]]; then
        local expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate | cut -d= -f2)
        log_info "Certificate expires: $expiry_date"
        
        # Check if certificate is valid for the domain
        if openssl x509 -in "$cert_file" -noout -text | grep -q "$DOMAIN"; then
            log_success "SSL certificate is valid for $DOMAIN"
        else
            log_warning "SSL certificate may not be valid for $DOMAIN"
        fi
    else
        log_error "Certificate file not found: $cert_file"
        exit 1
    fi
    
    # Test HTTPS connection
    if curl -s -I "https://$DOMAIN" | grep -q "HTTP/"; then
        log_success "HTTPS connection test successful"
    else
        log_warning "HTTPS connection test failed - this may be normal if DNS is not yet configured"
    fi
}

# Create SSL security configuration
create_ssl_security_config() {
    log_info "Creating SSL security configuration..."
    
    cat > "$NGINX_CONF_DIR/ssl-security.conf" << EOF
# SSL Security Configuration for Nexus COS
# Modern SSL/TLS configuration for maximum security

# SSL protocols and ciphers
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;

# SSL session settings
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
ssl_session_tickets off;

# OCSP stapling
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;

# DH parameters
ssl_dhparam $SSL_DIR/dhparam.pem;

# Security headers
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
EOF
    
    log_success "SSL security configuration created"
}

# Main execution
main() {
    log_info "Starting Nexus COS SSL setup for $DOMAIN"
    
    check_root
    install_dependencies
    create_directories
    generate_dhparam
    create_temp_nginx_config
    obtain_certificates
    copy_certificates
    create_ssl_security_config
    install_nginx_config
    setup_auto_renewal
    verify_ssl
    
    log_success "SSL setup completed successfully!"
    log_info "Your Nexus COS Extended platform is now secured with SSL/TLS"
    log_info "Certificates will be automatically renewed twice daily"
    log_info ""
    log_info "Next steps:"
    log_info "1. Ensure DNS records point to this server"
    log_info "2. Test HTTPS access: https://$DOMAIN"
    log_info "3. Monitor renewal logs: /var/log/nexuscos-ssl-renewal.log"
}

# Run main function
main "$@"