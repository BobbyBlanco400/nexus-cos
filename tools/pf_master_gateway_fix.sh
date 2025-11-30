#!/bin/bash
# ==============================================================================
# Nexus COS - Master PF Gateway Fix Script
# ==============================================================================
# Purpose: Configure gateway routing for V-Suite services
# Usage: DOMAIN=<domain> VSCREEN_PORT=<port> ... /opt/nexus-cos/tools/pf_master_gateway_fix.sh
# ==============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==============================================================================
# Utility Functions
# ==============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║          NEXUS COS - MASTER PF GATEWAY FIX                     ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# ==============================================================================
# Configuration Variables
# ==============================================================================

# Required environment variables with defaults
DOMAIN="${DOMAIN:-}"
VSCREEN_PORT="${VSCREEN_PORT:-3004}"
VSTAGE_PORT="${VSTAGE_PORT:-3033}"
VSUITE_PORT="${VSUITE_PORT:-3005}"
SOCKET_PORT="${SOCKET_PORT:-3043}"

# Paths
REPO_ROOT="/opt/nexus-cos"
NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"

# ==============================================================================
# Validation
# ==============================================================================

validate_config() {
    print_step "Validating configuration..."
    
    if [[ -z "$DOMAIN" ]]; then
        print_error "DOMAIN is required but not set"
        exit 2
    fi
    
    print_success "Domain: $DOMAIN"
    print_info "V-Screen Port: $VSCREEN_PORT"
    print_info "V-Stage Port: $VSTAGE_PORT"
    print_info "V-Suite Port: $VSUITE_PORT"
    print_info "Socket Port: $SOCKET_PORT"
}

# ==============================================================================
# Nginx Gateway Configuration
# ==============================================================================

configure_gateway() {
    print_step "Configuring gateway routes..."
    
    # Backup existing configuration
    if [[ -f "${NGINX_SITES_AVAILABLE}/nexus-gateway" ]]; then
        cp "${NGINX_SITES_AVAILABLE}/nexus-gateway" "${NGINX_SITES_AVAILABLE}/nexus-gateway.bak.$(date +%Y%m%d-%H%M%S)"
        print_success "Backed up existing gateway configuration"
    fi
    
    # Create gateway configuration
    cat > "${NGINX_SITES_AVAILABLE}/nexus-gateway" << EOF
# ==============================================================================
# Nexus COS Gateway Configuration
# Generated: $(date)
# Domain: ${DOMAIN}
# ==============================================================================

# V-Screen upstream
upstream vscreen_upstream {
    server 127.0.0.1:${VSCREEN_PORT};
    keepalive 32;
}

# V-Stage upstream
upstream vstage_upstream {
    server 127.0.0.1:${VSTAGE_PORT};
    keepalive 32;
}

# V-Suite upstream
upstream vsuite_upstream {
    server 127.0.0.1:${VSUITE_PORT};
    keepalive 32;
}

# Streaming Socket.IO upstream
upstream socket_upstream {
    server 127.0.0.1:${SOCKET_PORT};
    keepalive 32;
}

# Main server block
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};
    
    # Redirect HTTP to HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DOMAIN} www.${DOMAIN};
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Logging
    access_log /var/log/nginx/nexus-gateway.access.log;
    error_log /var/log/nginx/nexus-gateway.error.log;
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 '{"status":"ok","service":"nexus-gateway"}';
        add_header Content-Type application/json;
    }
    
    # V-Screen routes
    location /v-screen {
        proxy_pass http://vscreen_upstream;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
    
    location /v-suite/screen {
        proxy_pass http://vscreen_upstream;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
    
    # V-Stage routes
    location /v-stage {
        proxy_pass http://vstage_upstream;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
    
    location /v-suite/stage {
        proxy_pass http://vstage_upstream;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
    
    # V-Suite main routes
    location /v-suite {
        proxy_pass http://vsuite_upstream;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
    
    # Socket.IO streaming endpoint
    location /socket.io {
        proxy_pass http://socket_upstream;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
    
    # Streaming WebSocket endpoint
    location /stream {
        proxy_pass http://socket_upstream;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
}
EOF
    
    print_success "Gateway configuration created"
}

# ==============================================================================
# Enable Gateway
# ==============================================================================

enable_gateway() {
    print_step "Enabling gateway configuration..."
    
    # Create symlink if not exists
    if [[ ! -L "${NGINX_SITES_ENABLED}/nexus-gateway" ]]; then
        ln -sf "${NGINX_SITES_AVAILABLE}/nexus-gateway" "${NGINX_SITES_ENABLED}/nexus-gateway"
        print_success "Gateway configuration enabled"
    else
        print_info "Gateway configuration already enabled"
    fi
}

# ==============================================================================
# Validate and Reload Nginx
# ==============================================================================

reload_nginx() {
    print_step "Validating Nginx configuration..."
    
    # Capture nginx test output for debugging
    NGINX_TEST_OUTPUT=$(nginx -t 2>&1)
    NGINX_TEST_STATUS=$?
    
    if [ $NGINX_TEST_STATUS -eq 0 ]; then
        print_success "Nginx configuration is valid"
        echo "$NGINX_TEST_OUTPUT"
        
        print_step "Reloading Nginx..."
        if systemctl reload nginx 2>/dev/null || service nginx reload 2>/dev/null; then
            print_success "Nginx reloaded successfully"
        else
            print_error "Failed to reload Nginx"
            exit 1
        fi
    else
        print_error "Nginx configuration test failed"
        echo "$NGINX_TEST_OUTPUT"
        exit 1
    fi
}

# ==============================================================================
# Print Summary
# ==============================================================================

print_summary() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║               GATEWAY CONFIGURATION COMPLETE                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Gateway Routes:${NC}"
    echo -e "  • V-Screen:   https://${DOMAIN}/v-screen"
    echo -e "  • V-Stage:    https://${DOMAIN}/v-stage"
    echo -e "  • V-Suite:    https://${DOMAIN}/v-suite"
    echo -e "  • Socket.IO:  https://${DOMAIN}/socket.io"
    echo -e "  • Health:     https://${DOMAIN}/health"
    echo ""
    echo -e "${CYAN}Ports:${NC}"
    echo -e "  • V-Screen:   ${VSCREEN_PORT}"
    echo -e "  • V-Stage:    ${VSTAGE_PORT}"
    echo -e "  • V-Suite:    ${VSUITE_PORT}"
    echo -e "  • Socket:     ${SOCKET_PORT}"
    echo ""
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_header
    validate_config
    configure_gateway
    enable_gateway
    reload_nginx
    print_summary
    
    echo -e "${GREEN}✨ Master PF Gateway Fix Complete! ✨${NC}"
}

# Run main function
main "$@"
