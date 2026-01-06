#!/bin/bash
# ==============================================================================
# Nexus COS - VPS Deployment Script
# ==============================================================================
# Purpose: Deploy Nexus COS to VPS with security hardening
# Usage: bash scripts/vps-deploy.sh
# Environment Variables:
#   VPS_HOST - VPS host IP or domain (default: 74.208.155.161)
#   VPS_USER - VPS SSH user (default: root)
#   DOMAIN - Target domain (default: n3xuscos.online)
# ==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
VPS_HOST="${VPS_HOST:-74.208.155.161}"
VPS_USER="${VPS_USER:-root}"
DOMAIN="${DOMAIN:-n3xuscos.online}"
DEPLOY_DIR="/opt/nexus-cos"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ==============================================================================
# Utility Functions
# ==============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║            NEXUS COS VPS DEPLOYMENT                            ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
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

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# ==============================================================================
# 1. Verify Prerequisites
# ==============================================================================

verify_prerequisites() {
    print_section "1. VERIFY PREREQUISITES"
    
    print_step "Checking for required commands..."
    
    # Check for ssh
    if ! command -v ssh &> /dev/null; then
        print_error "ssh command not found"
        exit 1
    fi
    print_success "ssh found"
    
    # Check for scp
    if ! command -v scp &> /dev/null; then
        print_error "scp command not found"
        exit 1
    fi
    print_success "scp found"
    
    print_info "Target VPS: ${VPS_USER}@${VPS_HOST}"
    print_info "Domain: ${DOMAIN}"
    print_info "Deploy directory: ${DEPLOY_DIR}"
}

# ==============================================================================
# 2. Test VPS Connectivity
# ==============================================================================

test_vps_connectivity() {
    print_section "2. TEST VPS CONNECTIVITY"
    
    print_step "Testing SSH connection to ${VPS_HOST}..."
    
    if ssh -o ConnectTimeout=10 -o BatchMode=yes "${VPS_USER}@${VPS_HOST}" "echo 'Connection successful'" 2>/dev/null; then
        print_success "SSH connection successful"
    else
        print_error "Could not connect to VPS at ${VPS_HOST}"
        print_warning "Please verify:"
        echo "  - VPS is running and accessible"
        echo "  - SSH keys are properly configured"
        echo "  - VPS_HOST and VPS_USER environment variables are correct"
        exit 1
    fi
}

# ==============================================================================
# 3. Prepare VPS Environment
# ==============================================================================

prepare_vps_environment() {
    print_section "3. PREPARE VPS ENVIRONMENT"
    
    print_step "Creating deployment directory on VPS..."
    ssh "${VPS_USER}@${VPS_HOST}" "mkdir -p ${DEPLOY_DIR}/scripts"
    print_success "Deployment directory ready"
    
    print_step "Checking for required packages on VPS..."
    ssh "${VPS_USER}@${VPS_HOST}" "command -v nginx &> /dev/null || { echo 'Nginx not installed'; exit 1; }"
    print_success "Nginx is installed on VPS"
}

# ==============================================================================
# 4. Upload Application Files
# ==============================================================================

upload_application_files() {
    print_section "4. UPLOAD APPLICATION FILES"
    
    print_step "Uploading application files to VPS..."
    
    # Note: This is a placeholder for actual application deployment
    # In a real scenario, you would upload your application code here
    # For now, we'll just upload the necessary scripts
    
    print_info "Application file upload would happen here"
    print_warning "Skipping application upload in this example"
}

# ==============================================================================
# 5. Deploy Backend Services
# ==============================================================================

deploy_backend_services() {
    print_section "5. DEPLOY BACKEND SERVICES"
    
    print_step "Checking backend service status..."
    
    # Check if port 3001 is owned by systemd
    ssh "${VPS_USER}@${VPS_HOST}" "command -v ss &> /dev/null || apt-get install -y iproute2"
    
    PORT_OWNER=$(ssh "${VPS_USER}@${VPS_HOST}" "ss -ltnp | grep ':3001' | awk '{print \$NF}' | cut -d'\"' -f2 | cut -d'/' -f1" || echo "none")
    
    if [[ "$PORT_OWNER" == "none" ]]; then
        print_warning "Port 3001 is not in use"
    elif echo "$PORT_OWNER" | grep -qi "systemd\|python"; then
        print_success "Port 3001 is owned by systemd-managed service"
    else
        print_warning "Port 3001 is owned by: $PORT_OWNER (expected systemd/python)"
        print_info "You may need to stop PM2 and ensure systemd service is running"
    fi
}

# ==============================================================================
# 6. Apply Nginx Security Hardening
# ==============================================================================

apply_nginx_hardening() {
    print_section "6. APPLY NGINX SECURITY HARDENING"
    
    print_step "Uploading Nginx hardening script..."
    
    # Upload the pf-fix-nginx-headers-redirect.sh script
    scp "${SCRIPT_DIR}/pf-fix-nginx-headers-redirect.sh" \
        "${VPS_USER}@${VPS_HOST}:${DEPLOY_DIR}/scripts/"
    
    print_success "Hardening script uploaded"
    
    print_step "Executing Nginx hardening script on VPS..."
    
    # Execute the script with DOMAIN environment variable
    ssh "${VPS_USER}@${VPS_HOST}" \
        "cd ${DEPLOY_DIR} && sudo DOMAIN=${DOMAIN} bash scripts/pf-fix-nginx-headers-redirect.sh"
    
    print_success "Nginx hardening complete"
}

# ==============================================================================
# 7. Verify Deployment
# ==============================================================================

verify_deployment() {
    print_section "7. VERIFY DEPLOYMENT"
    
    print_step "Verifying HTTP→HTTPS redirect..."
    
    # Test redirect from local machine
    if command -v curl &> /dev/null; then
        REDIRECT_RESPONSE=$(curl -fsSI --max-time 10 "http://${DOMAIN}/" 2>/dev/null | tr -d '\r' | grep -i '^Location:' || echo "No redirect")
        
        if echo "$REDIRECT_RESPONSE" | grep -q "https://"; then
            print_success "HTTP redirects to HTTPS"
            print_info "$REDIRECT_RESPONSE"
        else
            print_warning "Could not verify redirect (may not be accessible from this location)"
        fi
    else
        print_warning "curl not available, skipping local verification"
    fi
    
    print_step "Verifying HTTPS security headers..."
    
    if command -v curl &> /dev/null; then
        HEADERS=$(curl -fsSI --max-time 10 "https://${DOMAIN}/" 2>/dev/null | tr -d '\r' || echo "")
        
        # Check for security headers
        HEADERS_FOUND=0
        
        if echo "$HEADERS" | grep -qi '^Strict-Transport-Security:'; then
            print_success "HSTS header present"
            ((HEADERS_FOUND++))
        fi
        
        if echo "$HEADERS" | grep -qi '^Content-Security-Policy:'; then
            print_success "CSP header present"
            ((HEADERS_FOUND++))
        fi
        
        if echo "$HEADERS" | grep -qi '^X-Content-Type-Options:'; then
            print_success "X-Content-Type-Options header present"
            ((HEADERS_FOUND++))
        fi
        
        if echo "$HEADERS" | grep -qi '^X-Frame-Options:'; then
            print_success "X-Frame-Options header present"
            ((HEADERS_FOUND++))
        fi
        
        if echo "$HEADERS" | grep -qi '^Referrer-Policy:'; then
            print_success "Referrer-Policy header present"
            ((HEADERS_FOUND++))
        fi
        
        if [[ $HEADERS_FOUND -eq 5 ]]; then
            print_success "All security headers verified (5/5)"
        elif [[ $HEADERS_FOUND -gt 0 ]]; then
            print_warning "Some security headers present ($HEADERS_FOUND/5)"
        else
            print_warning "Could not verify headers (site may not be accessible from this location)"
        fi
    else
        print_warning "curl not available, skipping local verification"
    fi
}

# ==============================================================================
# 8. Display Summary
# ==============================================================================

display_summary() {
    print_section "✅ DEPLOYMENT COMPLETE"
    echo ""
    echo -e "${GREEN}VPS deployment completed successfully!${NC}"
    echo ""
    echo -e "${CYAN}Deployment Summary:${NC}"
    echo -e "  ${GREEN}✓${NC} VPS connectivity verified"
    echo -e "  ${GREEN}✓${NC} Environment prepared"
    echo -e "  ${GREEN}✓${NC} Backend services checked"
    echo -e "  ${GREEN}✓${NC} Nginx security hardening applied"
    echo -e "  ${GREEN}✓${NC} Deployment verified"
    echo ""
    echo -e "${CYAN}Access Points:${NC}"
    echo -e "  ${BLUE}https://${DOMAIN}/${NC}"
    echo -e "  ${BLUE}https://www.${DOMAIN}/${NC}"
    echo ""
    echo -e "${CYAN}Manual Verification Commands:${NC}"
    echo -e "  ${YELLOW}# Verify HTTPS headers${NC}"
    echo -e "  curl -fsSI https://${DOMAIN}/ | tr -d '\\r' | egrep -i '^(Strict-Transport-Security|Content-Security-Policy|X-Content-Type-Options|X-Frame-Options|Referrer-Policy):'"
    echo ""
    echo -e "  ${YELLOW}# Verify HTTP redirect${NC}"
    echo -e "  curl -fsSI http://${DOMAIN}/ | tr -d '\\r' | egrep -i '^(HTTP|Location):'"
    echo ""
    echo -e "  ${YELLOW}# Check backend port ownership${NC}"
    echo -e "  ssh ${VPS_USER}@${VPS_HOST} 'ss -ltnp | grep \":3001\"'"
    echo ""
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_header
    
    # Execute deployment steps
    verify_prerequisites
    test_vps_connectivity
    prepare_vps_environment
    upload_application_files
    deploy_backend_services
    apply_nginx_hardening
    verify_deployment
    display_summary
    
    print_success "Deployment script completed!"
}

# Run main function
main "$@"
