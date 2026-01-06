#!/bin/bash
# comprehensive_ssl_validation.sh
# Comprehensive SSL Configuration Validation for n3xuscos.online
# Tests all configuration files, SSL settings, and service endpoints

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================================================${NC}"
    echo -e "${BLUE}    NEXUS COS SSL Configuration Validation${NC}"
    echo -e "${BLUE}    Domain: n3xuscos.online${NC}"
    echo -e "${BLUE}================================================================${NC}"
    echo ""
}

print_section() {
    echo -e "${BLUE}--- $1 ---${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Validate SSL Certificate Paths
validate_ssl_paths() {
    print_section "SSL Certificate Path Validation"
    
    # Check main nginx.conf
    if grep -q "/etc/ssl/ionos/fullchain.pem" nginx.conf; then
        print_success "Main nginx.conf uses IONOS SSL certificate path"
    else
        print_error "Main nginx.conf missing IONOS SSL certificate path"
    fi
    
    if grep -q "/etc/ssl/ionos/privkey.pem" nginx.conf; then
        print_success "Main nginx.conf uses IONOS private key path"
    else
        print_error "Main nginx.conf missing IONOS private key path"
    fi
    
    if grep -q "/etc/ssl/ionos/chain.pem" nginx.conf; then
        print_success "Main nginx.conf uses IONOS chain certificate path"
    else
        print_warning "Main nginx.conf missing IONOS chain certificate path"
    fi
    
    # Check deployment configurations
    for config in deployment/nginx/*.conf; do
        if [ -f "$config" ]; then
            config_name=$(basename "$config")
            if grep -q "/etc/ssl/ionos" "$config"; then
                print_success "$config_name uses IONOS SSL paths"
            else
                print_warning "$config_name may not use IONOS SSL paths"
            fi
        fi
    done
}

# Validate TLS Configuration
validate_tls_config() {
    print_section "TLS Protocol and Cipher Validation"
    
    # Check for TLS 1.2 and 1.3
    configs=(nginx.conf deployment/nginx/*.conf)
    for config in "${configs[@]}"; do
        if [ -f "$config" ]; then
            config_name=$(basename "$config")
            if grep -q "ssl_protocols.*TLSv1.2.*TLSv1.3" "$config"; then
                print_success "$config_name has correct TLS protocols (1.2/1.3)"
            elif grep -q "ssl_protocols" "$config"; then
                print_warning "$config_name has TLS protocols but may need updating"
            fi
            
            # Check for required cipher suites
            if grep -q "ECDHE-ECDSA-AES128-GCM-SHA256.*ECDHE-RSA-AES128-GCM-SHA256" "$config"; then
                print_success "$config_name has recommended cipher suites"
            elif grep -q "ssl_ciphers" "$config"; then
                print_warning "$config_name has cipher configuration but may need updating"
            fi
            
            # Check SSL preference setting
            if grep -q "ssl_prefer_server_ciphers off" "$config"; then
                print_success "$config_name has correct cipher preference setting"
            elif grep -q "ssl_prefer_server_ciphers on" "$config"; then
                print_warning "$config_name uses server cipher preference (should be 'off')"
            fi
        fi
    done
}

# Validate Security Headers
validate_security_headers() {
    print_section "Security Headers Validation"
    
    required_headers=(
        "X-Frame-Options.*SAMEORIGIN"
        "X-XSS-Protection.*mode=block"
        "X-Content-Type-Options.*nosniff"
        "Referrer-Policy.*no-referrer-when-downgrade"
        "Content-Security-Policy.*default-src.*self"
        "Strict-Transport-Security.*max-age=31536000.*includeSubDomains"
    )
    
    for config in nginx.conf deployment/nginx/*.conf; do
        if [ -f "$config" ]; then
            config_name=$(basename "$config")
            header_count=0
            
            for header in "${required_headers[@]}"; do
                if grep -q "$header" "$config"; then
                    ((header_count++))
                fi
            done
            
            if [ $header_count -eq ${#required_headers[@]} ]; then
                print_success "$config_name has all required security headers"
            elif [ $header_count -gt 0 ]; then
                print_warning "$config_name has $header_count/${#required_headers[@]} security headers"
            else
                print_error "$config_name missing security headers"
            fi
        fi
    done
}

# Validate Service Endpoints
validate_service_endpoints() {
    print_section "Service Endpoint Validation"
    
    # Required endpoints and their ports
    declare -A endpoints=(
        ["/api/"]=3001
        ["/ai/"]=3010
        ["/keys/"]=3014
        ["/health"]=3001
    )
    
    for config in nginx.conf deployment/nginx/*.conf; do
        if [ -f "$config" ]; then
            config_name=$(basename "$config")
            endpoint_count=0
            
            for endpoint in "${!endpoints[@]}"; do
                expected_port=${endpoints[$endpoint]}
                if grep -q "location $endpoint" "$config" && grep -A 5 "location $endpoint" "$config" | grep -q "localhost:$expected_port"; then
                    print_success "$config_name: $endpoint -> port $expected_port ✓"
                    ((endpoint_count++))
                elif grep -q "location $endpoint" "$config"; then
                    print_warning "$config_name: $endpoint configured but port may be incorrect"
                fi
            done
            
            if [ $endpoint_count -eq ${#endpoints[@]} ]; then
                print_success "$config_name has all required service endpoints"
            else
                print_warning "$config_name has $endpoint_count/${#endpoints[@]} service endpoints configured correctly"
            fi
        fi
    done
}

# Validate HTTP to HTTPS Redirection
validate_https_redirect() {
    print_section "HTTPS Redirection Validation"
    
    for config in nginx.conf deployment/nginx/*.conf; do
        if [ -f "$config" ]; then
            config_name=$(basename "$config")
            if grep -q "listen 80" "$config" && grep -q "return 301 https" "$config"; then
                print_success "$config_name has HTTP to HTTPS redirect"
            elif grep -q "listen 80" "$config"; then
                print_warning "$config_name has HTTP listener but redirect unclear"
            fi
        fi
    done
}

# Validate Domain Configuration
validate_domain_config() {
    print_section "Domain Configuration Validation"
    
    required_domains=("n3xuscos.online" "www.n3xuscos.online" "monitoring.n3xuscos.online")
    
    for config in nginx.conf deployment/nginx/*.conf; do
        if [ -f "$config" ]; then
            config_name=$(basename "$config")
            domain_count=0
            
            for domain in "${required_domains[@]}"; do
                if grep -q "server_name.*$domain" "$config"; then
                    ((domain_count++))
                fi
            done
            
            if [ $domain_count -eq ${#required_domains[@]} ]; then
                print_success "$config_name configures all required domains"
            elif [ $domain_count -gt 0 ]; then
                print_info "$config_name configures $domain_count/${#required_domains[@]} domains"
            fi
        fi
    done
}

# Validate Logging Configuration
validate_logging_config() {
    print_section "Logging Configuration Validation"
    
    for config in nginx.conf deployment/nginx/*.conf; do
        if [ -f "$config" ]; then
            config_name=$(basename "$config")
            if grep -q "access_log.*n3xuscos.online" "$config" && grep -q "error_log.*n3xuscos.online" "$config"; then
                print_success "$config_name has domain-specific logging"
            elif grep -q "access_log" "$config" || grep -q "error_log" "$config"; then
                print_warning "$config_name has logging but may need domain-specific paths"
            fi
        fi
    done
}

# Validate SSL Scripts
validate_ssl_scripts() {
    print_section "SSL Scripts Validation"
    
    # Check puabo_fix_nginx_ssl.sh
    if [ -f "puabo_fix_nginx_ssl.sh" ]; then
        if grep -q "/etc/ssl/ionos" puabo_fix_nginx_ssl.sh; then
            print_success "SSL setup script uses IONOS paths"
        else
            print_error "SSL setup script missing IONOS paths"
        fi
        
        if grep -q "chmod 600.*privkey.pem" puabo_fix_nginx_ssl.sh && grep -q "chmod 644.*fullchain.pem" puabo_fix_nginx_ssl.sh; then
            print_success "SSL setup script sets correct permissions"
        else
            print_warning "SSL setup script may not set correct file permissions"
        fi
    else
        print_error "SSL setup script not found: puabo_fix_nginx_ssl.sh"
    fi
    
    # Check test_ssl_config.sh
    if [ -f "test_ssl_config.sh" ]; then
        if grep -q "/etc/ssl/ionos" test_ssl_config.sh; then
            print_success "SSL test script uses IONOS paths"
        else
            print_error "SSL test script missing IONOS paths"
        fi
    else
        print_error "SSL test script not found: test_ssl_config.sh"
    fi
}

# Generate Summary Report
generate_summary() {
    print_section "Validation Summary"
    echo ""
    print_info "SSL Configuration Validation Complete"
    echo ""
    print_info "Key Components Verified:"
    echo "  • SSL certificate paths (/etc/ssl/ionos/)"
    echo "  • TLS protocols (1.2/1.3) and cipher suites"
    echo "  • Security headers (HSTS, XSS protection, etc.)"
    echo "  • Service endpoints (API:3001, AI:3010, Keys:3014)"
    echo "  • HTTP to HTTPS redirection"
    echo "  • Domain configuration (main, www, monitoring)"
    echo "  • Logging configuration"
    echo "  • SSL automation scripts"
    echo ""
    print_info "Files validated:"
    echo "  • nginx.conf"
    echo "  • deployment/nginx/*.conf"
    echo "  • puabo_fix_nginx_ssl.sh"
    echo "  • test_ssl_config.sh"
    echo ""
    print_info "For production deployment:"
    echo "  1. Ensure SSL certificates are in /etc/ssl/ionos/"
    echo "  2. Set file permissions: privkey.pem (600), fullchain.pem (644), chain.pem (644)"
    echo "  3. Test configuration: nginx -t"
    echo "  4. Run validation: ./test_ssl_config.sh"
    echo ""
}

# Main execution
main() {
    print_header
    
    # Change to the repository directory
    cd "$(dirname "$0")"
    
    # Run all validation tests
    validate_ssl_paths
    validate_tls_config
    validate_security_headers
    validate_service_endpoints
    validate_https_redirect
    validate_domain_config
    validate_logging_config
    validate_ssl_scripts
    
    generate_summary
}

# Execute main function
main "$@"