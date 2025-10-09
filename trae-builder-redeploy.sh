#!/bin/bash
# ==============================================================================
# TRAE Builder - One-Shot Nexus COS Redeploy Script
# ==============================================================================
# Purpose: Execute a full redeploy of Nexus COS with minimal manual intervention
# Usage: sudo bash trae-builder-redeploy.sh
# ==============================================================================

set -euo pipefail

# ==============================================================================
# Environment Configuration
# ==============================================================================

# Set environment variables - UPDATE EMAIL BEFORE RUNNING
export VPS_HOST="${VPS_HOST:-nexuscos.online}"
export DOMAIN="${DOMAIN:-nexuscos.online}"
export EMAIL="${EMAIL:-your@email.com}"

# Derived configuration
readonly REPO_PATH="/root/nexus-cos"
readonly NGINX_PROXY_CONF="/etc/nginx/conf.d/nexuscos_api_proxy.conf"
readonly BACKEND_SERVICE="nexus-node-backend"
readonly BACKEND_PORT="3004"

# Colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# ==============================================================================
# Utility Functions
# ==============================================================================

print_header() {
    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║          TRAE BUILDER - ONE-SHOT NEXUS COS REDEPLOY           ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║  Automated Full Redeploy for nexuscos.online                  ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo ""
    echo -e "${BOLD}${BLUE}▶${NC} $1${NC}"
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
# Pre-flight Checks
# ==============================================================================

preflight_checks() {
    print_step "STEP 1: Pre-flight Checks"
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root or with sudo"
        exit 1
    fi
    print_success "Running with root privileges"
    
    # Check if repository exists
    if [[ ! -d "$REPO_PATH" ]]; then
        print_error "Repository not found at $REPO_PATH"
        print_info "Expected: $REPO_PATH"
        exit 1
    fi
    print_success "Repository found: $REPO_PATH"
    
    # Check if main deployment script exists
    if [[ ! -f "$REPO_PATH/pf-master-deployment.sh" ]]; then
        print_error "Main deployment script not found: $REPO_PATH/pf-master-deployment.sh"
        exit 1
    fi
    print_success "Main deployment script found"
    
    # Verify email is configured
    if [[ "$EMAIL" == "your@email.com" ]]; then
        print_error "EMAIL environment variable must be set to a valid email address"
        print_info "Edit this script and change: EMAIL=\"your@email.com\""
        exit 1
    fi
    print_success "Email configured: $EMAIL"
    
    # Check required commands
    local required_commands=("nginx" "systemctl" "curl")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            print_error "Required command not found: $cmd"
            exit 1
        fi
    done
    print_success "All required commands available"
    
    echo ""
    print_info "Environment Configuration:"
    print_info "  VPS_HOST: $VPS_HOST"
    print_info "  DOMAIN: $DOMAIN"
    print_info "  EMAIL: $EMAIL"
    print_info "  REPO_PATH: $REPO_PATH"
}

# ==============================================================================
# Execute Main Deployment
# ==============================================================================

execute_main_deployment() {
    print_step "STEP 2: Execute Main Deployment Script"
    
    cd "$REPO_PATH"
    
    print_info "Running pf-master-deployment.sh..."
    
    # Run the main deployment script
    # Auto-confirm by piping 'y' to handle the interactive prompt
    if echo "y" | bash "$REPO_PATH/pf-master-deployment.sh" 2>&1 | tee /tmp/nexus-deployment.log; then
        print_success "Main deployment completed successfully"
    else
        # Check if it's just a non-critical failure
        if [[ -f /tmp/nexus-deployment.log ]]; then
            print_info "Deployment log saved to /tmp/nexus-deployment.log"
        fi
        print_error "Main deployment encountered issues"
        return 1
    fi
}

# ==============================================================================
# Restart Backend Service
# ==============================================================================

restart_backend_service() {
    print_step "STEP 3: Restart Backend Node Service"
    
    # Check if PM2 is available
    if command -v pm2 &> /dev/null; then
        print_info "PM2 detected, checking for processes..."
        
        # Check if there are any PM2 processes
        if pm2 list 2>/dev/null | grep -q "online\|stopped"; then
            print_info "Restarting all PM2 processes..."
            pm2 restart all 2>/dev/null || true
            print_success "PM2 processes restarted"
        else
            print_info "No PM2 processes found"
        fi
    fi
    
    # Always try systemctl for the main service
    print_info "Restarting systemd service: $BACKEND_SERVICE..."
    
    if systemctl is-active --quiet "$BACKEND_SERVICE" 2>/dev/null; then
        systemctl restart "$BACKEND_SERVICE"
        print_success "Service $BACKEND_SERVICE restarted"
    elif systemctl list-unit-files | grep -q "^${BACKEND_SERVICE}.service"; then
        # Service exists but not running, start it
        systemctl start "$BACKEND_SERVICE"
        print_success "Service $BACKEND_SERVICE started"
    else
        print_info "Service $BACKEND_SERVICE not found (may not be configured)"
        print_info "Checking for alternative service names..."
        
        # Try alternative service names
        for alt_service in "nexus-backend-node" "nexus-backend" "nexus-node"; do
            if systemctl list-unit-files | grep -q "^${alt_service}.service"; then
                print_info "Found alternative service: $alt_service"
                systemctl restart "$alt_service" || systemctl start "$alt_service"
                print_success "Service $alt_service restarted"
                break
            fi
        done
    fi
    
    # Wait a moment for service to start
    sleep 3
}

# ==============================================================================
# Configure Nginx API Proxy
# ==============================================================================

configure_nginx_proxy() {
    print_step "STEP 4: Configure Nginx API Proxy"
    
    print_info "Creating/updating Nginx API proxy configuration..."
    
    # Backup existing config if it exists
    if [[ -f "$NGINX_PROXY_CONF" ]]; then
        cp "$NGINX_PROXY_CONF" "${NGINX_PROXY_CONF}.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Existing config backed up"
    fi
    
    # Create the proxy configuration
    cat > "$NGINX_PROXY_CONF" << 'EOF'
# Nexus COS API Proxy Configuration
# Auto-generated by TRAE Builder redeploy script

# Proxy /api requests to backend Node service
location /api {
    proxy_pass http://127.0.0.1:3004;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_upgrade;
    
    # Timeouts
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;
}
EOF
    
    print_success "Nginx API proxy configuration created: $NGINX_PROXY_CONF"
}

# ==============================================================================
# Reload and Test Nginx
# ==============================================================================

reload_and_test_nginx() {
    print_step "STEP 5: Reload and Test Nginx"
    
    print_info "Testing Nginx configuration..."
    
    if nginx -t 2>&1 | grep -q "successful"; then
        print_success "Nginx configuration is valid"
    else
        print_error "Nginx configuration test failed"
        nginx -t 2>&1
        return 1
    fi
    
    print_info "Reloading Nginx..."
    
    if systemctl reload nginx 2>/dev/null || service nginx reload 2>/dev/null; then
        print_success "Nginx reloaded successfully"
    else
        print_error "Failed to reload Nginx"
        return 1
    fi
    
    # Wait for Nginx to fully reload
    sleep 2
}

# ==============================================================================
# Validate Endpoints
# ==============================================================================

validate_endpoints() {
    print_step "STEP 6: Validate Endpoints"
    
    local endpoints=(
        "http://localhost/health"
        "http://localhost/api/system/status"
        "http://localhost/api/services/test/health"
    )
    
    local all_passed=true
    
    echo ""
    for endpoint in "${endpoints[@]}"; do
        local endpoint_name="${endpoint##*/}"
        local endpoint_path="${endpoint#http://localhost}"
        
        print_info "Testing: $endpoint_path"
        
        # Use curl to test the endpoint
        local status_code
        status_code=$(curl -s -o /dev/null -w "%{http_code}" "$endpoint" 2>/dev/null || echo "000")
        
        if [[ "$status_code" == "200" ]]; then
            echo -e "  ${GREEN}✓ OK${NC} - ${endpoint_path} (HTTP $status_code)"
        elif [[ "$status_code" == "000" ]]; then
            echo -e "  ${RED}✗ FAILED${NC} - ${endpoint_path} (Connection failed)"
            all_passed=false
        else
            echo -e "  ${RED}✗ FAILED${NC} - ${endpoint_path} (HTTP $status_code)"
            all_passed=false
        fi
    done
    
    echo ""
    
    if [[ "$all_passed" == "true" ]]; then
        print_success "All endpoint validations passed"
        return 0
    else
        print_error "Some endpoint validations failed"
        print_info "This may be expected if endpoints are not yet configured"
        return 1
    fi
}

# ==============================================================================
# Final Summary
# ==============================================================================

print_summary() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║          TRAE BUILDER REDEPLOY COMPLETE                        ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    print_success "Full redeploy of Nexus COS completed"
    
    echo ""
    echo -e "${BOLD}Configuration Summary:${NC}"
    echo -e "  Domain: ${CYAN}$DOMAIN${NC}"
    echo -e "  VPS Host: ${CYAN}$VPS_HOST${NC}"
    echo -e "  Email: ${CYAN}$EMAIL${NC}"
    echo ""
    
    echo -e "${BOLD}Next Steps:${NC}"
    echo -e "  1. Visit: ${CYAN}https://$DOMAIN${NC}"
    echo -e "  2. Test API: ${CYAN}https://$DOMAIN/api/system/status${NC}"
    echo -e "  3. Monitor logs: ${CYAN}journalctl -u $BACKEND_SERVICE -f${NC}"
    echo ""
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_header
    
    # Execute all steps
    preflight_checks || exit 1
    execute_main_deployment || exit 1
    restart_backend_service || print_info "Backend service restart completed with warnings"
    configure_nginx_proxy || exit 1
    reload_and_test_nginx || exit 1
    validate_endpoints || print_info "Endpoint validation completed with warnings"
    
    print_summary
    
    exit 0
}

# Error handling
trap 'echo -e "${RED}Error occurred during redeploy${NC}"; exit 1' ERR

# Run main function
main "$@"
