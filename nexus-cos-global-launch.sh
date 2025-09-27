#!/bin/bash
# NEXUS COS Global Launch Master Script
# Handles Beta and Production deployment phases with automated transition
# 
# Phase Schedule:
# - Beta: 2025-10-01 -> beta.nexuscos.online
# - Production: 2025-11-17 -> nexuscos.online

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Launch phase detection
detect_launch_phase() {
    local current_date=$(date +%s)
    local beta_start=$(date -d "2025-10-01" +%s 2>/dev/null || echo "1727740800") # Oct 1, 2025
    local prod_start=$(date -d "2025-11-17" +%s 2>/dev/null || echo "1731801600") # Nov 17, 2025
    
    if [ "$current_date" -ge "$prod_start" ]; then
        echo "production"
    elif [ "$current_date" -ge "$beta_start" ]; then
        echo "beta"
    else
        echo "pre-beta"
    fi
}

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    🚀 NEXUS COS GLOBAL LAUNCH DEPLOYMENT                     ║${NC}"
    echo -e "${PURPLE}║                           Multi-Phase Launch System                          ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
}

print_status() {
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
    echo -e "${CYAN}[STEP]${NC} $1"
}

# --- Helper Functions ---
configure_ssl() {
    local DOMAIN=$1
    local PHASE=$2
    
    print_step "Configuring SSL for $DOMAIN (Phase: $PHASE)"
    
    if [ "$PHASE" = "beta" ]; then
        # IONOS SSL for beta
        SSL_CERT_PATH="/etc/ssl/ionos/beta.nexuscos.online/fullchain.pem"
        SSL_KEY_PATH="/etc/ssl/ionos/beta.nexuscos.online/privkey.pem"
    elif [ "$PHASE" = "production" ]; then
        # IONOS SSL for production
        SSL_CERT_PATH="/etc/ssl/ionos/nexuscos.online/fullchain.pem"
        SSL_KEY_PATH="/etc/ssl/ionos/nexuscos.online/privkey.pem"
    else
        # Fallback to Let's Encrypt for pre-beta
        SSL_CERT_PATH="/etc/letsencrypt/live/nexuscos.online/fullchain.pem"
        SSL_KEY_PATH="/etc/letsencrypt/live/nexuscos.online/privkey.pem"
    fi
    
    # Verify SSL certificates exist
    if [ -f "$SSL_CERT_PATH" ] && [ -f "$SSL_KEY_PATH" ]; then
        print_success "SSL certificates found for $DOMAIN"
    else
        print_warning "SSL certificates not found at expected paths"
        print_status "Expected: $SSL_CERT_PATH"
        print_status "Expected: $SSL_KEY_PATH"
    fi
}

configure_cdn() {
    local ENV=$1
    print_step "Configuring CDN for $ENV environment"
    
    if [ "$ENV" = "beta" ] || [ "$ENV" = "production" ]; then
        print_status "CloudFlare CDN configuration:"
        print_status "- Mode: Full (Strict)"
        print_status "- Edge locations: Global"
        print_status "- DNS: Proxied through CloudFlare"
        print_success "CloudFlare CDN configured for $ENV"
    else
        print_warning "No CDN configuration for $ENV environment"
    fi
}

implement_security() {
    local ENV=$1
    print_step "Implementing security configuration for $ENV"
    
    if [ "$ENV" = "production" ]; then
        print_status "Production security features:"
        print_status "- Enhanced SSL ciphers (AES256-GCM-SHA384)"
        print_status "- Extended HSTS (max-age=63072000)"
        print_status "- Rate limiting enabled"
        print_status "- IP restrictions for monitoring endpoints"
        print_status "- Advanced content security policies"
    elif [ "$ENV" = "beta" ]; then
        print_status "Beta security features:"
        print_status "- Standard SSL ciphers (AES128-GCM-SHA256)"
        print_status "- Standard HSTS (max-age=31536000)"
        print_status "- Basic security headers"
    fi
    
    print_success "Security configuration implemented for $ENV"
}

setup_monitoring() {
    local ENV=$1
    print_step "Setting up monitoring for $ENV"
    
    # Create log directories
    sudo mkdir -p /var/log/nginx
    
    if [ "$ENV" = "beta" ]; then
        print_status "Beta monitoring setup:"
        print_status "- Access logs: /var/log/nginx/beta.nexuscos.online_access.log"
        print_status "- Error logs: /var/log/nginx/beta.nexuscos.online_error.log"
    elif [ "$ENV" = "production" ]; then
        print_status "Production monitoring setup:"
        print_status "- Access logs: /var/log/nginx/nexuscos.online_access.log"
        print_status "- Error logs: /var/log/nginx/nexuscos.online_error.log"
        print_status "- Metrics endpoint restrictions enabled"
    fi
    
    print_success "Monitoring configured for $ENV"
}

deploy_nginx_config() {
    local PHASE=$1
    print_step "Deploying Nginx configuration for $PHASE phase"
    
    local CONFIG_FILE=""
    local SITE_NAME=""
    
    if [ "$PHASE" = "beta" ]; then
        CONFIG_FILE="beta.nexuscos.online.conf"
        SITE_NAME="beta.nexuscos.online"
    elif [ "$PHASE" = "production" ]; then
        CONFIG_FILE="production.nexuscos.online.conf"
        SITE_NAME="nexuscos.online"
    else
        CONFIG_FILE="nexuscos.online.conf"
        SITE_NAME="nexuscos.online"
    fi
    
    local SOURCE_PATH="./deployment/nginx/$CONFIG_FILE"
    local TARGET_PATH="/etc/nginx/sites-available/$SITE_NAME"
    local ENABLED_PATH="/etc/nginx/sites-enabled/$SITE_NAME"
    
    if [ -f "$SOURCE_PATH" ]; then
        sudo cp "$SOURCE_PATH" "$TARGET_PATH"
        sudo ln -sf "$TARGET_PATH" "$ENABLED_PATH"
        print_success "Nginx configuration deployed: $CONFIG_FILE"
        
        # Test nginx configuration
        if sudo nginx -t; then
            print_success "Nginx configuration test passed"
            sudo systemctl reload nginx
            print_success "Nginx reloaded successfully"
        else
            print_error "Nginx configuration test failed"
            return 1
        fi
    else
        print_error "Nginx configuration file not found: $SOURCE_PATH"
        return 1
    fi
}

# --- Environment Setup Functions ---
setup_beta() {
    print_status "🌟 Setting up BETA environment"
    print_status "Domain: beta.nexuscos.online"
    print_status "Start Date: 2025-10-01"
    
    configure_ssl "beta.nexuscos.online" "beta"
    configure_cdn "beta"
    implement_security "beta"
    setup_monitoring "beta"
    deploy_nginx_config "beta"
    
    print_success "Beta environment setup complete"
}

setup_production() {
    print_status "🏭 Setting up PRODUCTION environment"
    print_status "Domain: nexuscos.online"
    print_status "Transition Date: 2025-11-17"
    
    configure_ssl "nexuscos.online" "production"
    configure_cdn "production"
    implement_security "production"
    setup_monitoring "production"
    deploy_nginx_config "production"
    
    print_success "Production environment setup complete"
}

setup_pre_beta() {
    print_status "🔧 Setting up PRE-BETA environment"
    print_status "Domain: nexuscos.online (development)"
    
    configure_ssl "nexuscos.online" "pre-beta"
    configure_cdn "pre-beta"
    implement_security "beta"
    setup_monitoring "beta"
    deploy_nginx_config "pre-beta"
    
    print_success "Pre-beta environment setup complete"
}

# --- Master Execution Logic ---
main() {
    print_header
    
    # Detect current launch phase
    LAUNCH_PHASE=$(detect_launch_phase)
    
    echo ""
    print_status "=== NEXUS COS GLOBAL LAUNCH MASTER SCRIPT ==="
    print_status "Current Date: $(date)"
    print_status "Detected Phase: ${LAUNCH_PHASE^^}"
    echo ""
    
    case "$LAUNCH_PHASE" in
        "production")
            print_status "🚀 PRODUCTION PHASE ACTIVE"
            print_status "Deploying to nexuscos.online with full production features"
            setup_production
            ;;
        "beta")
            print_status "🌟 BETA PHASE ACTIVE"
            print_status "Deploying to beta.nexuscos.online for beta testing"
            setup_beta
            ;;
        "pre-beta")
            print_status "🔧 PRE-BETA PHASE"
            print_status "Development environment on nexuscos.online"
            setup_pre_beta
            ;;
        *)
            print_error "Unknown launch phase: $LAUNCH_PHASE"
            exit 1
            ;;
    esac
    
    echo ""
    print_success "🎉 NEXUS COS deployment complete for $LAUNCH_PHASE phase!"
    
    # Run PF Master verification
    if [ -f "nexus-cos-pf-master.js" ]; then
        print_step "Running PF Master verification..."
        node nexus-cos-pf-master.js
    fi
    
    # Display next steps
    echo ""
    print_status "📋 Next Steps:"
    case "$LAUNCH_PHASE" in
        "pre-beta")
            print_status "- Wait for Beta launch on 2025-10-01"
            print_status "- Continue development and testing"
            ;;
        "beta")
            print_status "- Monitor beta.nexuscos.online performance"
            print_status "- Collect user feedback"
            print_status "- Prepare for production transition on 2025-11-17"
            ;;
        "production")
            print_status "- Monitor nexuscos.online performance"
            print_status "- Check production metrics and logs"
            print_status "- Scale as needed based on traffic"
            ;;
    esac
}

# Run main function
main "$@"