#!/bin/bash

# ==============================================================================
# PUABO NEXUS - Nginx Route Updater
# ==============================================================================
# Purpose: Safely insert /puabo-nexus/* location routes into Nginx configuration
# Author: Code Agent + TRAE Solo
# Version: v2025.10.01
# ==============================================================================

set -euo pipefail

# Configuration
readonly DOMAIN="${DOMAIN:-nexuscos.online}"
readonly NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
readonly NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"
readonly NGINX_CONF="${NGINX_SITES_AVAILABLE}/nexuscos"
readonly BACKUP_DIR="/etc/nginx/backups"

# Colors
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
    echo -e "${CYAN}║   PUABO NEXUS - Nginx Route Updater                           ║${NC}"
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
    
    # Check if config file exists
    if [[ ! -f "${NGINX_CONF}" ]]; then
        print_warning "Nginx config file not found: ${NGINX_CONF}"
        print_info "Creating new configuration file..."
        touch "${NGINX_CONF}"
    fi
    print_success "Nginx config file exists"
}

backup_config() {
    print_step "Backing up current Nginx configuration..."
    
    # Create backup directory
    mkdir -p "${BACKUP_DIR}"
    
    # Create backup with timestamp
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${BACKUP_DIR}/nexuscos_${timestamp}.conf"
    
    if [[ -f "${NGINX_CONF}" ]] && [[ -s "${NGINX_CONF}" ]]; then
        cp "${NGINX_CONF}" "${backup_file}"
        print_success "Backup created: ${backup_file}"
    else
        print_warning "No existing configuration to backup"
    fi
}

check_routes_exist() {
    print_step "Checking if PUABO NEXUS routes already exist..."
    
    if grep -q "location /puabo-nexus/dispatch" "${NGINX_CONF}" 2>/dev/null; then
        print_warning "PUABO NEXUS routes already exist in configuration"
        print_info "Routes will be updated if necessary"
        return 0
    else
        print_info "PUABO NEXUS routes not found, will be added"
        return 1
    fi
}

insert_nexus_routes() {
    print_step "Inserting PUABO NEXUS routes..."
    
    # Define the PUABO NEXUS location blocks
    local nexus_routes='
    # ==============================================================================
    # PUABO NEXUS Fleet Services
    # ==============================================================================
    
    # AI Dispatch Service (127.0.0.1:9001)
    location /puabo-nexus/dispatch {
        proxy_pass http://127.0.0.1:9001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 90;
        proxy_buffering off;
    }
    
    location /puabo-nexus/dispatch/health {
        proxy_pass http://127.0.0.1:9001/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Driver Backend Service (127.0.0.1:9002)
    location /puabo-nexus/driver {
        proxy_pass http://127.0.0.1:9002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 90;
        proxy_buffering off;
    }
    
    location /puabo-nexus/driver/health {
        proxy_pass http://127.0.0.1:9002/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Fleet Manager Service (127.0.0.1:9003)
    location /puabo-nexus/fleet {
        proxy_pass http://127.0.0.1:9003;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 90;
        proxy_buffering off;
    }
    
    location /puabo-nexus/fleet/health {
        proxy_pass http://127.0.0.1:9003/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Route Optimizer Service (127.0.0.1:9004)
    location /puabo-nexus/routes {
        proxy_pass http://127.0.0.1:9004;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 90;
        proxy_buffering off;
    }
    
    location /puabo-nexus/routes/health {
        proxy_pass http://127.0.0.1:9004/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }'
    
    # Remove existing PUABO NEXUS routes if they exist
    if check_routes_exist; then
        print_step "Removing old PUABO NEXUS routes..."
        # Create temp file without PUABO NEXUS routes
        sed '/# PUABO NEXUS Fleet Services/,/location \/puabo-nexus\/routes\/health {[^}]*}/d' "${NGINX_CONF}" > "${NGINX_CONF}.tmp"
        mv "${NGINX_CONF}.tmp" "${NGINX_CONF}"
        print_success "Old routes removed"
    fi
    
    # Find the server block for the domain and insert routes
    if grep -q "server_name ${DOMAIN}" "${NGINX_CONF}"; then
        # Insert before the last closing brace of the server block
        # Using awk to insert in the correct location
        awk -v routes="${nexus_routes}" '
            /server_name '"${DOMAIN}"'/ { in_server=1 }
            in_server && /^[[:space:]]*}[[:space:]]*$/ && !found {
                print routes
                found=1
            }
            { print }
        ' "${NGINX_CONF}" > "${NGINX_CONF}.tmp"
        mv "${NGINX_CONF}.tmp" "${NGINX_CONF}"
        print_success "PUABO NEXUS routes inserted successfully"
    else
        print_warning "Could not find server block for ${DOMAIN}"
        print_info "Adding routes at the end of the file"
        echo "${nexus_routes}" >> "${NGINX_CONF}"
    fi
}

validate_config() {
    print_step "Validating Nginx configuration..."
    
    if nginx -t 2>&1 | grep -q "successful"; then
        print_success "Nginx configuration is valid"
        return 0
    else
        print_error "Nginx configuration validation failed"
        nginx -t 2>&1
        print_warning "Restoring from backup..."
        
        # Find most recent backup
        local latest_backup
        latest_backup=$(ls -t "${BACKUP_DIR}"/nexuscos_*.conf 2>/dev/null | head -1)
        
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
    
    if systemctl reload nginx 2>/dev/null || service nginx reload 2>/dev/null; then
        print_success "Nginx reloaded successfully"
    else
        print_error "Failed to reload Nginx"
        print_info "Try manually: sudo systemctl reload nginx"
        return 1
    fi
}

enable_site() {
    print_step "Ensuring site is enabled..."
    
    if [[ ! -L "${NGINX_SITES_ENABLED}/nexuscos" ]]; then
        ln -sf "${NGINX_CONF}" "${NGINX_SITES_ENABLED}/nexuscos"
        print_success "Site enabled"
    else
        print_info "Site already enabled"
    fi
}

print_summary() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   PUABO NEXUS Routes Updated Successfully                      ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Health Check Endpoints:${NC}"
    echo -e "  ${CYAN}•${NC} https://${DOMAIN}/puabo-nexus/dispatch/health"
    echo -e "  ${CYAN}•${NC} https://${DOMAIN}/puabo-nexus/driver/health"
    echo -e "  ${CYAN}•${NC} https://${DOMAIN}/puabo-nexus/fleet/health"
    echo -e "  ${CYAN}•${NC} https://${DOMAIN}/puabo-nexus/routes/health"
    echo ""
    echo -e "${YELLOW}Test with:${NC}"
    echo -e "  curl -I https://${DOMAIN}/puabo-nexus/dispatch/health"
    echo ""
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_header
    
    check_prerequisites
    backup_config
    insert_nexus_routes
    
    if validate_config; then
        enable_site
        
        if reload_nginx; then
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
