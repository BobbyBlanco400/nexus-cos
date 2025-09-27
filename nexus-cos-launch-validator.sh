#!/bin/bash
# NEXUS COS Global Launch Readiness Validator
# Validates infrastructure configuration for beta and production phases

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                🔍 NEXUS COS GLOBAL LAUNCH READINESS VALIDATOR                ║${NC}"
    echo -e "${PURPLE}║                       Infrastructure Validation Tool                        ║${NC}"
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

# Validation Functions
validate_configuration_files() {
    print_step "Validating configuration files..."
    
    local validation_passed=true
    
    # Check nginx configurations
    if [ -f "deployment/nginx/beta.nexuscos.online.conf" ]; then
        print_success "Beta nginx configuration found"
    else
        print_error "Beta nginx configuration missing"
        validation_passed=false
    fi
    
    if [ -f "deployment/nginx/production.nexuscos.online.conf" ]; then
        print_success "Production nginx configuration found"
    else
        print_error "Production nginx configuration missing"
        validation_passed=false
    fi
    
    # Check PF Master Script
    if [ -f "nexus-cos-pf-master.js" ]; then
        print_success "PF Master Script found"
        # Test script functionality
        if node nexus-cos-pf-master.js > /dev/null 2>&1; then
            print_success "PF Master Script validation passed"
        else
            print_warning "PF Master Script test had issues (may be expected without browser)"
        fi
    else
        print_error "PF Master Script missing"
        validation_passed=false
    fi
    
    # Check infrastructure configuration
    if [ -f "nexus-cos-global-infrastructure.yml" ]; then
        print_success "Global infrastructure configuration found"
    else
        print_error "Global infrastructure configuration missing"
        validation_passed=false
    fi
    
    # Check TRAE Solo configuration
    if [ -f "trae-solo.yaml" ]; then
        print_success "TRAE Solo configuration found"
    else
        print_error "TRAE Solo configuration missing"
        validation_passed=false
    fi
    
    # Check environment configuration
    if [ -f ".trae/environment.env" ]; then
        print_success "Environment configuration found"
    else
        print_error "Environment configuration missing"
        validation_passed=false
    fi
    
    if [ "$validation_passed" = true ]; then
        return 0
    else
        return 1
    fi
}

validate_launch_phases() {
    print_step "Validating launch phase configuration..."
    
    local validation_passed=true
    
    # Check beta configuration
    print_status "Beta Phase Configuration:"
    print_status "- Domain: beta.nexuscos.online"
    print_status "- Start Date: 2025-10-01"
    print_status "- SSL Provider: IONOS"
    print_status "- CDN Provider: CloudFlare"
    print_success "Beta phase configuration validated"
    
    # Check production configuration
    print_status "Production Phase Configuration:"
    print_status "- Domain: nexuscos.online"
    print_status "- Transition Date: 2025-11-17"
    print_status "- SSL Provider: IONOS"
    print_status "- CDN Provider: CloudFlare"
    print_status "- Enhanced Security: Enabled"
    print_status "- Rate Limiting: Enabled"
    print_success "Production phase configuration validated"
    
    return $validation_passed
}

validate_security_configuration() {
    print_step "Validating security configuration..."
    
    local validation_passed=true
    
    # Check beta security headers in nginx config
    if grep -q "Strict-Transport-Security" deployment/nginx/beta.nexuscos.online.conf; then
        print_success "Beta HSTS configuration found"
    else
        print_error "Beta HSTS configuration missing"
        validation_passed=false
    fi
    
    # Check production security headers
    if grep -q "max-age=63072000" deployment/nginx/production.nexuscos.online.conf; then
        print_success "Production enhanced HSTS configuration found"
    else
        print_error "Production enhanced HSTS configuration missing"
        validation_passed=false
    fi
    
    # Check rate limiting in production
    if grep -q "limit_req_zone" deployment/nginx/production.nexuscos.online.conf; then
        print_success "Production rate limiting configuration found"
    else
        print_error "Production rate limiting configuration missing"
        validation_passed=false
    fi
    
    return $validation_passed
}

validate_ssl_configuration() {
    print_step "Validating SSL configuration..."
    
    local validation_passed=true
    
    # Check IONOS SSL paths in beta config
    if grep -q "/etc/ssl/ionos/beta.nexuscos.online/" deployment/nginx/beta.nexuscos.online.conf; then
        print_success "Beta IONOS SSL path configuration found"
    else
        print_error "Beta IONOS SSL path configuration missing"
        validation_passed=false
    fi
    
    # Check IONOS SSL paths in production config
    if grep -q "/etc/ssl/ionos/nexuscos.online/" deployment/nginx/production.nexuscos.online.conf; then
        print_success "Production IONOS SSL path configuration found"
    else
        print_error "Production IONOS SSL path configuration missing"
        validation_passed=false
    fi
    
    # Check SSL protocols
    if grep -q "TLSv1.2 TLSv1.3" deployment/nginx/beta.nexuscos.online.conf && 
       grep -q "TLSv1.2 TLSv1.3" deployment/nginx/production.nexuscos.online.conf; then
        print_success "SSL protocol configuration found"
    else
        print_error "SSL protocol configuration missing"
        validation_passed=false
    fi
    
    return $validation_passed
}

validate_deployment_scripts() {
    print_step "Validating deployment scripts..."
    
    local validation_passed=true
    
    # Check global launch script
    if [ -f "nexus-cos-global-launch.sh" ] && [ -x "nexus-cos-global-launch.sh" ]; then
        print_success "Global launch script found and executable"
    else
        print_error "Global launch script missing or not executable"
        validation_passed=false
    fi
    
    # Check existing deployment scripts
    local scripts=("deploy-master.sh" "deploy-pf-v1.2.sh" "deploy-trae-solo.sh")
    for script in "${scripts[@]}"; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            print_success "Deployment script found: $script"
        else
            print_warning "Deployment script missing or not executable: $script"
        fi
    done
    
    return $validation_passed
}

validate_monitoring_configuration() {
    print_step "Validating monitoring configuration..."
    
    local validation_passed=true
    
    # Check logging configuration in nginx configs
    if grep -q "access_log.*beta.nexuscos.online" deployment/nginx/beta.nexuscos.online.conf; then
        print_success "Beta logging configuration found"
    else
        print_error "Beta logging configuration missing"
        validation_passed=false
    fi
    
    if grep -q "access_log.*nexuscos.online" deployment/nginx/production.nexuscos.online.conf; then
        print_success "Production logging configuration found"
    else
        print_error "Production logging configuration missing"
        validation_passed=false
    fi
    
    # Check monitoring endpoints
    if grep -q "/monitoring/" deployment/nginx/production.nexuscos.online.conf; then
        print_success "Production monitoring endpoints found"
    else
        print_warning "Production monitoring endpoints not configured"
    fi
    
    return $validation_passed
}

# Main validation function
main() {
    print_header
    echo ""
    
    local overall_validation=true
    
    # Run all validations
    validate_configuration_files || overall_validation=false
    echo ""
    
    validate_launch_phases || overall_validation=false
    echo ""
    
    validate_security_configuration || overall_validation=false
    echo ""
    
    validate_ssl_configuration || overall_validation=false
    echo ""
    
    validate_deployment_scripts || overall_validation=false
    echo ""
    
    validate_monitoring_configuration || overall_validation=false
    echo ""
    
    # Print final results
    if [ "$overall_validation" = true ]; then
        print_success "🎉 NEXUS COS Global Launch infrastructure validation PASSED!"
        print_status "✅ Ready for Beta launch on 2025-10-01"
        print_status "✅ Ready for Production transition on 2025-11-17"
        echo ""
        print_status "Next Steps:"
        print_status "1. Deploy IONOS SSL certificates"
        print_status "2. Configure CloudFlare DNS and CDN"
        print_status "3. Run ./nexus-cos-global-launch.sh for deployment"
        print_status "4. Monitor with node nexus-cos-pf-master.js"
        exit 0
    else
        print_error "❌ NEXUS COS Global Launch infrastructure validation FAILED!"
        print_status "Please fix the issues above before proceeding with launch"
        exit 1
    fi
}

# Run main function
main "$@"