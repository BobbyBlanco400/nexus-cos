#!/bin/bash
# ==============================================================================
# PF Update Script: Front-Facing Module + Puaboverse + Tenant Platforms
# ==============================================================================
# Purpose: Update Nginx routing for the Nexus COS Stack
# This script updates Nginx routing for front-facing platform, internal
# metaverse/creator hub (Puaboverse), and tenant platforms (e.g., Club Saditty)
# Author: Nexus COS Team
# Version: v2025.10.01
# ==============================================================================

set -euo pipefail

# ==============================================================================
# Configuration - Define container IPs
# ==============================================================================
FRONTEND_IP="${FRONTEND_IP:-172.20.0.14:3080}"       # Front-facing Netflix-style module
PUABOVERSE_IP="${PUABOVERSE_IP:-172.20.0.13:3060}"     # Internal Metaverse/Creator Hub
CLUB_SADITTY_IP="${CLUB_SADITTY_IP:-172.20.0.15:3070}"   # Tenant Platform example
# Add more tenant platforms as needed

DOMAIN="${DOMAIN:-n3xuscos.online}"                    # Domain name
NGINX_CONF="${NGINX_CONF:-/etc/nginx/sites-available/nexus-cos.conf}"
BACKUP_DIR="/etc/nginx/backups"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# ==============================================================================
# Utility Functions
# ==============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   PF Update Script - Nexus COS Stack Nginx Routing            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# ==============================================================================
# Main Functions
# ==============================================================================

check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
    print_success "Running as root"
    
    # Check if nginx is installed
    if ! command -v nginx &> /dev/null; then
        print_error "Nginx is not installed"
        exit 1
    fi
    print_success "Nginx is installed"
}

backup_config() {
    print_step "Backing up current Nginx configuration..."
    
    # Create backup directory
    mkdir -p "${BACKUP_DIR}"
    
    # Create backup with timestamp if file exists
    if [[ -f "${NGINX_CONF}" ]] && [[ -s "${NGINX_CONF}" ]]; then
        local timestamp
        timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_file="${BACKUP_DIR}/nexus-cos_${timestamp}.conf"
        cp "${NGINX_CONF}" "${backup_file}"
        print_success "Backup created: ${backup_file}"
    else
        print_warning "No existing configuration to backup"
    fi
}

update_nginx_config() {
    print_step "Updating Nginx configuration for Nexus COS stack..."
    
    # Create the new configuration in a temporary file first
    local temp_conf
    temp_conf=$(mktemp)
    
    cat > "${temp_conf}" <<EOL
upstream puabo-frontend {
    server ${FRONTEND_IP};
}

upstream puaboverse {
    server ${PUABOVERSE_IP};
}

upstream club-saditty {
    server ${CLUB_SADITTY_IP};
}

server {
    listen 80;
    server_name ${DOMAIN};

    # Front-facing platform
    location / {
        proxy_pass http://puabo-frontend/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Internal Metaverse/Creator Hub
    location /puaboverse/ {
        proxy_pass http://puaboverse/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Puaboverse health check
    location /puaboverse/health {
        proxy_pass http://puaboverse/health;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Tenant Platforms
    location /club-saditty/ {
        proxy_pass http://club-saditty/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Add additional tenant platforms here as needed
}
EOL

    # Atomically move the temp file to the final location
    mv "${temp_conf}" "${NGINX_CONF}"
    chmod 644 "${NGINX_CONF}"
    
    print_success "Nginx configuration updated"
}

validate_config() {
    print_step "Testing Nginx configuration..."
    
    if nginx -t >/dev/null 2>&1; then
        print_success "Nginx configuration is valid"
        return 0
    else
        print_error "Nginx configuration validation failed"
        nginx -t 2>&1
        print_warning "Restoring from backup..."
        
        # Find most recent backup
        local latest_backup
        latest_backup=$(ls -t "${BACKUP_DIR}"/nexus-cos_*.conf 2>/dev/null | head -1)
        
        if [[ -n "${latest_backup}" ]]; then
            cp "${latest_backup}" "${NGINX_CONF}"
            print_success "Configuration restored from backup"
        else
            print_error "No backup available to restore"
        fi
        
        return 1
    fi
}

reload_nginx() {
    print_step "Reloading Nginx..."
    
    if nginx -s reload >/dev/null 2>&1; then
        print_success "Nginx reloaded successfully"
        return 0
    else
        print_warning "nginx -s reload failed, trying systemctl/service..."
        if systemctl reload nginx >/dev/null 2>&1 || service nginx reload >/dev/null 2>&1; then
            print_success "Nginx reloaded successfully"
            return 0
        else
            print_error "Failed to reload Nginx"
            print_info "Try manually: sudo systemctl reload nginx"
            return 1
        fi
    fi
}

verify_routes() {
    print_step "Verifying routes..."
    
    echo ""
    print_info "Testing front-facing platform..."
    if curl -I https://${DOMAIN}/ 2>&1 | head -1; then
        print_success "Front-facing platform endpoint responded"
    else
        print_warning "Front-facing platform endpoint check failed (this is expected if SSL is not configured)"
    fi
    
    echo ""
    print_info "Testing Puaboverse health check..."
    if curl -I https://${DOMAIN}/puaboverse/health 2>&1 | head -1; then
        print_success "Puaboverse health check endpoint responded"
    else
        print_warning "Puaboverse health check endpoint failed (this is expected if SSL is not configured)"
    fi
    
    echo ""
    print_info "Testing Club Saditty platform..."
    if curl -I https://${DOMAIN}/club-saditty/ 2>&1 | head -1; then
        print_success "Club Saditty endpoint responded"
    else
        print_warning "Club Saditty endpoint check failed (this is expected if SSL is not configured)"
    fi
    echo ""
}

print_summary() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   Nginx Routing Update Complete                               ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Configuration Summary:${NC}"
    echo -e "  ${CYAN}•${NC} Front-facing Platform: https://${DOMAIN}/"
    echo -e "  ${CYAN}•${NC} Puaboverse Hub: https://${DOMAIN}/puaboverse/"
    echo -e "  ${CYAN}•${NC} Puaboverse Health: https://${DOMAIN}/puaboverse/health"
    echo -e "  ${CYAN}•${NC} Club Saditty: https://${DOMAIN}/club-saditty/"
    echo ""
    echo -e "${YELLOW}Container IPs:${NC}"
    echo -e "  ${CYAN}•${NC} Frontend: ${FRONTEND_IP}"
    echo -e "  ${CYAN}•${NC} Puaboverse: ${PUABOVERSE_IP}"
    echo -e "  ${CYAN}•${NC} Club Saditty: ${CLUB_SADITTY_IP}"
    echo ""
    echo -e "${BLUE}Configuration file: ${NGINX_CONF}${NC}"
    echo ""
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_header
    
    check_prerequisites
    backup_config
    update_nginx_config
    
    if validate_config; then
        if reload_nginx; then
            verify_routes
            print_summary
            exit 0
        else
            print_error "Nginx reload failed"
            exit 1
        fi
    else
        print_error "Configuration validation failed, changes not applied"
        exit 1
    fi
}

# Run main function
main "$@"
