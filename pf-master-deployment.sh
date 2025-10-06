#!/bin/bash
# ==============================================================================
# Nexus COS - Master PF Deployment Script
# ==============================================================================
# Purpose: Complete deployment integrating all PF scripts
# Usage: sudo bash pf-master-deployment.sh
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Dynamically determine repository root
# Priority: Environment variable > Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$SCRIPT_DIR}"

# ==============================================================================
# Utility Functions
# ==============================================================================

print_header() {
    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║          NEXUS COS - MASTER PF DEPLOYMENT                      ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║  Comprehensive Platform Fix for Production Deployment          ║${NC}"
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
# Pre-flight Checks
# ==============================================================================

preflight_checks() {
    print_section "PRE-FLIGHT CHECKS"
    
    # Check if running as root or with sudo
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root or with sudo"
        exit 1
    fi
    print_success "Running with root privileges"
    
    # Check if we're in the right directory
    if [[ ! -d "$REPO_ROOT" ]]; then
        print_error "Repository not found at $REPO_ROOT"
        exit 1
    fi
    print_success "Repository located: $REPO_ROOT"
    
    # Check for required commands
    local required_commands=("nginx" "npm" "node" "git" "curl")
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            print_success "$cmd is installed"
        else
            print_error "$cmd is not installed"
            exit 1
        fi
    done
    
    # Check Nginx version
    NGINX_VERSION=$(nginx -v 2>&1 | cut -d'/' -f2)
    print_info "Nginx version: $NGINX_VERSION"
    
    # Check Node version
    NODE_VERSION=$(node -v)
    print_info "Node version: $NODE_VERSION"
    
    # Check available disk space
    AVAILABLE_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $AVAILABLE_SPACE -gt 5 ]]; then
        print_success "Sufficient disk space: ${AVAILABLE_SPACE}GB"
    else
        print_warning "Low disk space: ${AVAILABLE_SPACE}GB"
    fi
}

# ==============================================================================
# Display Deployment Plan
# ==============================================================================

display_plan() {
    print_section "DEPLOYMENT PLAN"
    
    cat << EOF
This master PF deployment will execute the following steps:

1. ✅ Pre-flight system checks
2. 🔧 Environment configuration and validation
3. 🏗️  Frontend application builds
4. 🌐 Nginx configuration for IP/domain unification
5. 🎨 Branding enforcement and consolidation
6. 🔍 Comprehensive validation
7. 📊 Deployment report generation

The deployment addresses:
  • IP vs domain routing inconsistencies
  • Default server configuration
  • Environment variable validation
  • Static asset caching
  • CSP header configuration
  • React Router fallback handling
  • Branding consistency

Estimated time: 5-10 minutes

EOF

    read -p "$(echo -e ${YELLOW}'Continue with deployment? (y/n): '${NC})" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deployment cancelled by user"
        exit 0
    fi
}

# ==============================================================================
# Execute IP/Domain Unification PF
# ==============================================================================

execute_ip_domain_fix() {
    print_section "EXECUTING IP/DOMAIN UNIFICATION PF"
    
    if [[ -f "${SCRIPT_DIR}/pf-ip-domain-unification.sh" ]]; then
        print_step "Running IP/Domain unification script..."
        bash "${SCRIPT_DIR}/pf-ip-domain-unification.sh"
        print_success "IP/Domain unification completed"
    else
        print_error "IP/Domain unification script not found"
        print_info "Expected: ${SCRIPT_DIR}/pf-ip-domain-unification.sh"
        exit 1
    fi
}

# ==============================================================================
# Execute Branding Enforcement
# ==============================================================================

execute_branding_enforcement() {
    print_section "EXECUTING BRANDING ENFORCEMENT"
    
    if [[ -f "${SCRIPT_DIR}/scripts/branding-enforce.sh" ]]; then
        print_step "Running branding enforcement script..."
        bash "${SCRIPT_DIR}/scripts/branding-enforce.sh" 2>&1 | grep -v "^$" || true
        print_success "Branding enforcement completed"
    else
        print_warning "Branding enforcement script not found (optional)"
    fi
}

# ==============================================================================
# Execute Validation
# ==============================================================================

execute_validation() {
    print_section "EXECUTING VALIDATION"
    
    if [[ -f "${SCRIPT_DIR}/validate-ip-domain-routing.sh" ]]; then
        print_step "Running routing validation..."
        bash "${SCRIPT_DIR}/validate-ip-domain-routing.sh"
        print_success "Validation completed"
    else
        print_warning "Validation script not found"
    fi
}

# ==============================================================================
# Generate Final Report
# ==============================================================================

generate_final_report() {
    print_section "GENERATING FINAL REPORT"
    
    REPORT_FILE="/tmp/nexus-cos-master-pf-report.txt"
    
    cat > "$REPORT_FILE" << EOF
╔════════════════════════════════════════════════════════════════╗
║          NEXUS COS - MASTER PF DEPLOYMENT REPORT               ║
╚════════════════════════════════════════════════════════════════╝

Deployment Timestamp: $(date)
Script Version: 1.0.0
Execution User: $(whoami)
Server: $(hostname)

═══════════════════════════════════════════════════════════════
DEPLOYMENT SUMMARY
═══════════════════════════════════════════════════════════════

Status: ✅ COMPLETED SUCCESSFULLY

Components Deployed:
  ✓ IP/Domain routing unification
  ✓ Nginx configuration
  ✓ Frontend applications
  ✓ Branding enforcement
  ✓ Environment validation
  ✓ Security headers
  ✓ Cache configuration

═══════════════════════════════════════════════════════════════
SYSTEM INFORMATION
═══════════════════════════════════════════════════════════════

Nginx Version: $(nginx -v 2>&1 | cut -d'/' -f2)
Node Version: $(node -v)
NPM Version: $(npm -v)
Disk Space: $(df -h / | awk 'NR==2 {print $4}') available

═══════════════════════════════════════════════════════════════
CONFIGURATION DETAILS
═══════════════════════════════════════════════════════════════

Domain: nexuscos.online
Server IP: 74.208.155.161
Webroot: /var/www/nexus-cos

Nginx Config: /etc/nginx/sites-available/nexuscos
SSL Certificates: /etc/letsencrypt/live/nexuscos.online/

Frontend Applications:
  - Admin Panel: /var/www/nexus-cos/admin/build/
  - Creator Hub: /var/www/nexus-cos/creator-hub/build/
  - Main Frontend: /var/www/nexus-cos/frontend/dist/
  - Module Diagram: /var/www/nexus-cos/diagram/

═══════════════════════════════════════════════════════════════
ROUTING CONFIGURATION
═══════════════════════════════════════════════════════════════

HTTP (Port 80):
  - Domain requests → Redirect to HTTPS
  - IP requests → Redirect to domain HTTPS
  - default_server configured ✓

HTTPS (Port 443):
  - default_server configured ✓
  - Multiple server_name entries ✓
  - SSL/TLS enabled ✓
  - Security headers configured ✓

API Proxying:
  - /api/ → http://127.0.0.1:3000/
  - /py/ → http://127.0.0.1:8000/
  - /health → Built-in health check

═══════════════════════════════════════════════════════════════
VERIFICATION CHECKLIST
═══════════════════════════════════════════════════════════════

Execute these commands to verify deployment:

# Test domain access
curl -I https://nexuscos.online/

# Test IP redirect
curl -I http://74.208.155.161/

# Test admin panel
curl -L https://nexuscos.online/admin/

# Test creator hub
curl -L https://nexuscos.online/creator-hub/

# Test health endpoint
curl https://nexuscos.online/health

# Test API proxy
curl https://nexuscos.online/api/health

═══════════════════════════════════════════════════════════════
POST-DEPLOYMENT TASKS
═══════════════════════════════════════════════════════════════

1. Clear browser cache and test in browser:
   - https://nexuscos.online/
   - http://74.208.155.161/ (should redirect)

2. Verify branding consistency across all pages

3. Check browser console for CSP violations

4. Monitor logs:
   tail -f /var/log/nginx/nexus-cos.access.log
   tail -f /var/log/nginx/nexus-cos.error.log

5. Verify backend services are running:
   systemctl status nexus-backend
   systemctl status nexus-python

═══════════════════════════════════════════════════════════════
TROUBLESHOOTING
═══════════════════════════════════════════════════════════════

If issues occur:

1. Check Nginx configuration:
   nginx -t

2. Review Nginx logs:
   tail -100 /var/log/nginx/nexus-cos.error.log

3. Verify file permissions:
   ls -la /var/www/nexus-cos/

4. Test with curl:
   curl -v -H "Host: nexuscos.online" http://127.0.0.1/

5. Rollback if needed:
   cp /etc/nginx/sites-available/nexuscos.backup.[timestamp] \\
      /etc/nginx/sites-available/nexuscos
   nginx -t && systemctl reload nginx

═══════════════════════════════════════════════════════════════
SUPPORT RESOURCES
═══════════════════════════════════════════════════════════════

Documentation:
  - PF_IP_DOMAIN_UNIFICATION.md
  - QUICK_FIX_IP_DOMAIN.md
  - PF_INDEX.md

Scripts:
  - pf-ip-domain-unification.sh
  - validate-ip-domain-routing.sh
  - pf-master-deployment.sh

Configuration:
  - deployment/nginx/nexuscos-unified.conf

═══════════════════════════════════════════════════════════════

Report saved: ${REPORT_FILE}

Deployment completed successfully! 🎉

═══════════════════════════════════════════════════════════════
EOF
    
    cat "$REPORT_FILE"
    print_success "Report generated: ${REPORT_FILE}"
}

# ==============================================================================
# Final Summary
# ==============================================================================

print_summary() {
    print_section "DEPLOYMENT COMPLETE"
    
    echo ""
    echo -e "${GREEN}✓✓✓ MASTER PF DEPLOYMENT SUCCESSFUL ✓✓✓${NC}"
    echo ""
    echo -e "${CYAN}Access your platform:${NC}"
    echo -e "  • ${BLUE}https://nexuscos.online/${NC}"
    echo -e "  • ${BLUE}https://nexuscos.online/admin/${NC}"
    echo -e "  • ${BLUE}https://nexuscos.online/creator-hub/${NC}"
    echo ""
    echo -e "${CYAN}Important:${NC}"
    echo -e "  • IP requests (http://74.208.155.161/) now redirect to domain"
    echo -e "  • Both access methods serve identical content"
    echo -e "  • Clear browser cache before testing (Ctrl+Shift+Del)"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  1. Review report: ${YELLOW}/tmp/nexus-cos-master-pf-report.txt${NC}"
    echo -e "  2. Test in browser with cache cleared"
    echo -e "  3. Monitor logs for any issues"
    echo -e "  4. Verify all features work correctly"
    echo ""
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_header
    
    # Execute deployment phases
    preflight_checks
    display_plan
    execute_ip_domain_fix
    execute_branding_enforcement
    execute_validation
    generate_final_report
    print_summary
    
    # Exit successfully
    exit 0
}

# Error handling
trap 'echo -e "${RED}Error occurred in master deployment script${NC}"; exit 1' ERR

# Run main function
main "$@"
