#!/bin/bash
# Nexus COS Automated PM2/Nginx Deployment Script
# Reads nexus-cos-services.yml and deploys all backend services with PM2 and Nginx

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

print_header() {
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}    Nexus COS PM2/Nginx Automated Deployment${NC}"
    echo -e "${BLUE}===============================================${NC}"
}

# Configuration
CONFIG_FILE="nexus-cos-services.yml"
NGINX_SITE_NAME="nexus-cos"
NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"
NGINX_CONFIG_FILE="${NGINX_SITES_AVAILABLE}/${NGINX_SITE_NAME}"

# Check if running as root (needed for nginx operations)
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_warning "This script requires sudo privileges for nginx configuration"
        print_info "Re-running with sudo..."
        exec sudo "$0" "$@"
    fi
}

# Install dependencies
install_dependencies() {
    print_info "Installing required dependencies..."
    
    # Install PM2 globally if not present
    if ! command -v pm2 &> /dev/null; then
        print_info "Installing PM2 process manager..."
        npm install -g pm2
    else
        print_success "PM2 already installed"
    fi
    
    # Install yq for YAML parsing if not present
    if ! command -v yq &> /dev/null; then
        print_info "Installing yq YAML parser..."
        if command -v snap &> /dev/null; then
            snap install yq
        else
            wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
            chmod +x /usr/local/bin/yq
        fi
    else
        print_success "yq already installed"
    fi
    
    # Ensure nginx is installed
    if ! command -v nginx &> /dev/null; then
        print_info "Installing nginx..."
        apt update
        apt install -y nginx
    else
        print_success "nginx already installed"
    fi
}

# Check if port is available
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 1  # Port is in use
    else
        return 0  # Port is available
    fi
}

# Stop existing PM2 processes
stop_existing_processes() {
    print_info "Stopping existing PM2 processes..."
    
    # Get list of PM2 processes and stop any existing nexus-related ones
    if pm2 list | grep -q "nexus\|boomroom\|creator\|puabo"; then
        pm2 stop all
        pm2 delete all
        print_success "Stopped and deleted existing PM2 processes"
    else
        print_info "No existing PM2 processes found"
    fi
}

# Start services from YAML configuration
start_services() {
    print_info "Starting services from configuration..."
    
    # Parse YAML and start each service
    local service_count=$(yq eval '.services | length' "$CONFIG_FILE")
    
    for ((i=0; i<service_count; i++)); do
        local name=$(yq eval ".services[$i].name" "$CONFIG_FILE")
        local script=$(yq eval ".services[$i].script" "$CONFIG_FILE")
        local interpreter=$(yq eval ".services[$i].interpreter" "$CONFIG_FILE")
        local port=$(yq eval ".services[$i].port" "$CONFIG_FILE")
        local pm2_name=$(yq eval ".services[$i].pm2_name" "$CONFIG_FILE")
        local cwd=$(yq eval ".services[$i].cwd" "$CONFIG_FILE")
        local interpreter_args=$(yq eval ".services[$i].interpreter_args // \"\"" "$CONFIG_FILE")
        
        print_info "Starting service: $name on port $port"
        
        # Check if port is available
        if ! check_port "$port"; then
            print_error "Port $port is already in use! Stopping conflicting process..."
            # Kill process using the port
            fuser -k ${port}/tcp || true
            sleep 2
        fi
        
        # Install dependencies for the service
        service_dir=$(dirname "$cwd/$script")
        if [[ -f "$service_dir/package.json" ]]; then
            print_info "Installing dependencies for $name..."
            cd "$service_dir"
            npm install --silent
            cd - >/dev/null
        fi
        
        # Create PM2 ecosystem file for this service
        local ecosystem_file="/tmp/pm2-${pm2_name}.json"
        cat > "$ecosystem_file" << EOF
{
  "apps": [{
    "name": "$pm2_name",
    "script": "$script",
    "cwd": "$cwd",
    "interpreter": "$interpreter",
    "env": {
      "NODE_ENV": "production",
      "PORT": "$port",
      "PYTHONUNBUFFERED": "1"
    },
    "instances": 1,
    "autorestart": true,
    "watch": false,
    "max_memory_restart": "500M"
EOF

        # Add interpreter args for Python services
        if [[ "$interpreter_args" != "null" && "$interpreter_args" != "" ]]; then
            echo ",    \"args\": \"$interpreter_args\"" >> "$ecosystem_file"
        fi

        echo "  }]" >> "$ecosystem_file"
        echo "}" >> "$ecosystem_file"
        
        # Start the service with PM2
        if pm2 start "$ecosystem_file"; then
            print_success "Started $name successfully"
        else
            print_error "Failed to start $name"
            exit 1
        fi
        
        # Wait a moment for service to initialize
        sleep 2
        
        # Verify service is running
        if pm2 list | grep -q "$pm2_name.*online"; then
            print_success "$name is running on port $port"
        else
            print_error "$name failed to start properly"
        fi
    done
}

# Generate dynamic Nginx configuration
generate_nginx_config() {
    print_info "Generating dynamic Nginx configuration..."
    
    local server_name=$(yq eval '.nginx.server_name' "$CONFIG_FILE")
    local frontend_root=$(yq eval '.nginx.frontend_root' "$CONFIG_FILE")
    local frontend_index=$(yq eval '.nginx.frontend_index' "$CONFIG_FILE")
    local ssl_enabled=$(yq eval '.nginx.ssl_enabled' "$CONFIG_FILE")
    
    # Start nginx configuration
    cat > "$NGINX_CONFIG_FILE" << EOF
# Nexus COS Automated Nginx Configuration
# Generated by nexus-cos-setup.sh

server {
    listen 80;
    server_name $server_name www.$server_name;
EOF

    # Add SSL redirect if enabled
    if [[ "$ssl_enabled" == "true" ]]; then
        cat >> "$NGINX_CONFIG_FILE" << EOF
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $server_name www.$server_name;
    
    # SSL Configuration (to be managed by certbot)
    ssl_certificate /etc/letsencrypt/live/$server_name/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$server_name/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
EOF
    fi

    # Add frontend configuration
    cat >> "$NGINX_CONFIG_FILE" << EOF
    
    # Frontend static files
    location / {
        root $frontend_root;
        index $frontend_index;
        try_files \$uri \$uri/ /$frontend_index;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
EOF

    # Add API routes for each service
    local service_count=$(yq eval '.services | length' "$CONFIG_FILE")
    
    for ((i=0; i<service_count; i++)); do
        local name=$(yq eval ".services[$i].name" "$CONFIG_FILE")
        local port=$(yq eval ".services[$i].port" "$CONFIG_FILE")
        
        cat >> "$NGINX_CONFIG_FILE" << EOF
    
    # $name API endpoints
    location /api/$name/ {
        proxy_pass http://localhost:$port/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
EOF
    done

    # Close the server block
    cat >> "$NGINX_CONFIG_FILE" << EOF
    
    # Block access to sensitive files
    location ~ /\. {
        deny all;
    }
    
    location ~ /(README|CHANGELOG|LICENSE|COPYING) {
        deny all;
    }
}
EOF

    print_success "Nginx configuration generated at $NGINX_CONFIG_FILE"
}

# Enable nginx site and reload
configure_nginx() {
    print_info "Configuring Nginx..."
    
    # Remove default site if it exists
    if [[ -f "${NGINX_SITES_ENABLED}/default" ]]; then
        rm -f "${NGINX_SITES_ENABLED}/default"
    fi
    
    # Enable the new site
    ln -sf "$NGINX_CONFIG_FILE" "${NGINX_SITES_ENABLED}/${NGINX_SITE_NAME}"
    
    # Test nginx configuration
    if nginx -t; then
        print_success "Nginx configuration is valid"
        systemctl reload nginx
        print_success "Nginx reloaded successfully"
    else
        print_error "Nginx configuration is invalid!"
        exit 1
    fi
}

# Setup PM2 startup
setup_pm2_startup() {
    print_info "Setting up PM2 startup and persistence..."
    
    # Setup PM2 to start on boot
    pm2 startup systemd -u $(logname) --hp $(eval echo ~$(logname))
    
    # Save current PM2 process list
    pm2 save
    
    print_success "PM2 startup configuration saved"
}

# Test all services
test_services() {
    print_info "Testing service health endpoints..."
    
    sleep 5  # Wait for services to fully initialize
    
    local service_count=$(yq eval '.services | length' "$CONFIG_FILE")
    local all_healthy=true
    
    for ((i=0; i<service_count; i++)); do
        local name=$(yq eval ".services[$i].name" "$CONFIG_FILE")
        local port=$(yq eval ".services[$i].port" "$CONFIG_FILE")
        
        print_info "Testing $name health endpoint..."
        
        if curl -f -s "http://localhost:$port/health" >/dev/null; then
            print_success "$name health check passed"
        else
            print_error "$name health check failed"
            all_healthy=false
        fi
    done
    
    if [[ "$all_healthy" == "true" ]]; then
        print_success "All services are healthy!"
    else
        print_warning "Some services failed health checks"
    fi
}

# Main execution
main() {
    print_header
    
    # Check if config file exists
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Configuration file $CONFIG_FILE not found!"
        exit 1
    fi
    
    check_root
    install_dependencies
    stop_existing_processes
    start_services
    generate_nginx_config
    configure_nginx
    setup_pm2_startup
    test_services
    
    print_success "🎉 Nexus COS deployment completed successfully!"
    echo ""
    echo "📋 Deployment Summary:"
    echo "  🔹 Services managed by PM2: $(pm2 list | grep -c 'online' || echo '0')"
    echo "  🔹 Nginx configuration: $NGINX_CONFIG_FILE"
    echo "  🔹 Frontend served from: $(yq eval '.nginx.frontend_root' "$CONFIG_FILE")"
    echo ""
    echo "🔍 Useful commands:"
    echo "  pm2 list                 # View all processes"
    echo "  pm2 logs                 # View all logs"
    echo "  pm2 restart all          # Restart all services"
    echo "  systemctl status nginx   # Check nginx status"
}

# Run main function
main "$@"