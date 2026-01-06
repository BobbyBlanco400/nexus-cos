#!/bin/bash
# test_ssl_config.sh
# SSL Configuration Validation Script for n3xuscos.online
#
# Usage: sudo ./test_ssl_config.sh
# Purpose: Validates SSL certificate installation, security configuration, 
#          Nginx setup, HTTPS access, permissions, and security headers

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
SSL_DIR="/etc/ssl/ionos"
WEB_ROOT="/var/www/n3xuscos.online/html"
SITE_CONF="/etc/nginx/sites-available/n3xuscos.online.conf"
DOMAIN="n3xuscos.online"
FULLCHAIN_PATH="$SSL_DIR/fullchain.pem"
PRIVKEY_PATH="$SSL_DIR/privkey.pem"
CHAIN_PATH="$SSL_DIR/chain.pem"

# Functions
print_header() {
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}    SSL Configuration Validation Script${NC}"
    echo -e "${BLUE}    Domain: $DOMAIN${NC}"
    echo -e "${BLUE}===============================================${NC}"
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

# Test Functions
test_certificate_presence() {
    print_section "Certificate Presence Check"
    
    if [ -f "$FULLCHAIN_PATH" ]; then
        print_success "SSL certificate found: $FULLCHAIN_PATH"
    else
        print_error "SSL certificate missing: $FULLCHAIN_PATH"
        return 1
    fi
    
    if [ -f "$PRIVKEY_PATH" ]; then
        print_success "Private key found: $PRIVKEY_PATH"
    else
        print_error "Private key missing: $PRIVKEY_PATH"
        return 1
    fi
    
    if [ -f "$CHAIN_PATH" ]; then
        print_success "Certificate chain found: $CHAIN_PATH"
    else
        print_warning "Certificate chain missing: $CHAIN_PATH (may affect SSL stapling)"
    fi
    
    return 0
}

test_certificate_validity() {
    print_section "Certificate Validity Check"
    
    if [ ! -f "$FULLCHAIN_PATH" ]; then
        print_error "Cannot validate certificate - file not found"
        return 1
    fi
    
    # Check if certificate is valid
    if openssl x509 -in "$FULLCHAIN_PATH" -noout -checkend 0 > /dev/null 2>&1; then
        print_success "Certificate is valid and not expired"
        
        # Show certificate details
        expiry_date=$(openssl x509 -in "$FULLCHAIN_PATH" -noout -enddate | cut -d= -f2)
        print_info "Certificate expires: $expiry_date"
        
        # Check if expires within 30 days
        if openssl x509 -in "$FULLCHAIN_PATH" -noout -checkend 2592000 > /dev/null 2>&1; then
            print_success "Certificate valid for more than 30 days"
        else
            print_warning "Certificate expires within 30 days"
        fi
    else
        print_error "Certificate is invalid or expired"
        return 1
    fi
    
    # Verify certificate chain
    if openssl verify -CAfile "$FULLCHAIN_PATH" "$FULLCHAIN_PATH" > /dev/null 2>&1; then
        print_success "Certificate chain verification passed"
    else
        print_warning "Certificate chain verification failed (may be self-signed)"
    fi
    
    return 0
}

test_file_permissions() {
    print_section "File Permissions Check"
    
    # Check certificate permissions (should be 644)
    if [ -f "$FULLCHAIN_PATH" ]; then
        cert_perms=$(stat -c "%a" "$FULLCHAIN_PATH")
        if [ "$cert_perms" = "644" ]; then
            print_success "Certificate permissions correct: $cert_perms"
        else
            print_warning "Certificate permissions: $cert_perms (expected: 644)"
        fi
    fi
    
    # Check private key permissions (should be 600)
    if [ -f "$PRIVKEY_PATH" ]; then
        key_perms=$(stat -c "%a" "$PRIVKEY_PATH")
        if [ "$key_perms" = "600" ]; then
            print_success "Private key permissions correct: $key_perms"
        else
            print_error "Private key permissions: $key_perms (expected: 600)"
        fi
    fi
    
    # Check chain certificate permissions (should be 644)
    if [ -f "$CHAIN_PATH" ]; then
        chain_perms=$(stat -c "%a" "$CHAIN_PATH")
        if [ "$chain_perms" = "644" ]; then
            print_success "Certificate chain permissions correct: $chain_perms"
        else
            print_warning "Certificate chain permissions: $chain_perms (expected: 644)"
        fi
    fi
    
    # Check web root ownership
    if [ -d "$WEB_ROOT" ]; then
        web_owner=$(stat -c "%U:%G" "$WEB_ROOT")
        if [ "$web_owner" = "www-data:www-data" ]; then
            print_success "Web root ownership correct: $web_owner"
        else
            print_warning "Web root ownership: $web_owner (expected: www-data:www-data)"
        fi
    else
        print_warning "Web root directory not found: $WEB_ROOT"
    fi
}

test_nginx_configuration() {
    print_section "Nginx Configuration Check"
    
    # Check if site configuration exists
    if [ -f "$SITE_CONF" ]; then
        print_success "Nginx site configuration found: $SITE_CONF"
    else
        print_error "Nginx site configuration missing: $SITE_CONF"
        return 1
    fi
    
    # Check if site is enabled
    if [ -L "/etc/nginx/sites-enabled/n3xuscos.online.conf" ]; then
        print_success "Site is enabled in Nginx"
    else
        print_error "Site is not enabled in Nginx"
    fi
    
    # Test Nginx configuration syntax
    if nginx -t > /dev/null 2>&1; then
        print_success "Nginx configuration syntax is valid"
    else
        print_error "Nginx configuration has syntax errors"
        nginx -t
        return 1
    fi
    
    # Check for SSL directives
    if grep -q "ssl_certificate.*$SSL_DIR/fullchain.pem" "$SITE_CONF"; then
        print_success "SSL certificate path configured correctly"
    else
        print_warning "SSL certificate path may not be configured correctly"
    fi
    
    if grep -q "ssl_certificate_key.*$SSL_DIR/privkey.pem" "$SITE_CONF"; then
        print_success "SSL private key path configured correctly"
    else
        print_warning "SSL private key path may not be configured correctly"
    fi
    
    # Check for modern TLS protocols
    if grep -q "ssl_protocols.*TLSv1.2.*TLSv1.3" "$SITE_CONF"; then
        print_success "Modern TLS protocols configured (TLS 1.2/1.3)"
    else
        print_warning "TLS protocol configuration may need updating"
    fi
    
    # Check for HTTP to HTTPS redirect
    if grep -q "return 301 https" "$SITE_CONF"; then
        print_success "HTTP to HTTPS redirect configured"
    else
        print_warning "HTTP to HTTPS redirect may not be configured"
    fi
}

test_security_headers() {
    print_section "Security Headers Check"
    
    # Check if Nginx is running
    if ! systemctl is-active nginx > /dev/null 2>&1; then
        print_warning "Nginx is not running - cannot test security headers"
        return 1
    fi
    
    # Test security headers via HTTP request (if possible)
    headers_temp="/tmp/ssl_headers_test.txt"
    
    # Try to get headers from localhost
    if curl -k -I -s "https://localhost" > "$headers_temp" 2>/dev/null || \
       curl -k -I -s "https://127.0.0.1" > "$headers_temp" 2>/dev/null; then
        
        # Check for HSTS header
        if grep -qi "strict-transport-security" "$headers_temp"; then
            print_success "HSTS header present"
        else
            print_warning "HSTS header missing"
        fi
        
        # Check for X-Frame-Options
        if grep -qi "x-frame-options" "$headers_temp"; then
            print_success "X-Frame-Options header present"
        else
            print_warning "X-Frame-Options header missing"
        fi
        
        # Check for X-Content-Type-Options
        if grep -qi "x-content-type-options" "$headers_temp"; then
            print_success "X-Content-Type-Options header present"
        else
            print_warning "X-Content-Type-Options header missing"
        fi
        
        # Check for X-XSS-Protection
        if grep -qi "x-xss-protection" "$headers_temp"; then
            print_success "X-XSS-Protection header present"
        else
            print_warning "X-XSS-Protection header missing"
        fi
        
        # Check for CSP
        if grep -qi "content-security-policy" "$headers_temp"; then
            print_success "Content-Security-Policy header present"
        else
            print_warning "Content-Security-Policy header missing"
        fi
        
    else
        print_warning "Cannot test security headers - HTTPS not accessible"
        
        # Check configuration file for headers instead
        if grep -q "add_header.*Strict-Transport-Security" "$SITE_CONF"; then
            print_info "HSTS header configured in Nginx config"
        else
            print_warning "HSTS header not found in Nginx config"
        fi
    fi
    
    rm -f "$headers_temp"
}

test_https_access() {
    print_section "HTTPS Access Test"
    
    # Check if Nginx is running
    if ! systemctl is-active nginx > /dev/null 2>&1; then
        print_error "Nginx is not running"
        return 1
    else
        print_success "Nginx service is running"
    fi
    
    # Test HTTPS access
    if curl -k -s --connect-timeout 5 "https://localhost" > /dev/null 2>&1; then
        print_success "HTTPS access working (localhost)"
    else
        print_warning "HTTPS access test failed (localhost)"
    fi
    
    # Test HTTP redirect
    redirect_test=$(curl -s -I --connect-timeout 5 "http://localhost" 2>/dev/null | grep -i "location.*https")
    if [ -n "$redirect_test" ]; then
        print_success "HTTP to HTTPS redirect working"
    else
        print_warning "HTTP to HTTPS redirect may not be working"
    fi
}

test_logging_configuration() {
    print_section "Logging Configuration Check"
    
    access_log="/var/log/nginx/${DOMAIN}_access.log"
    error_log="/var/log/nginx/${DOMAIN}_error.log"
    
    # Check if log files are configured
    if grep -q "$access_log" "$SITE_CONF" 2>/dev/null; then
        print_success "Access log configured: $access_log"
    else
        print_warning "Access log may not be configured"
    fi
    
    if grep -q "$error_log" "$SITE_CONF" 2>/dev/null; then
        print_success "Error log configured: $error_log"
    else
        print_warning "Error log may not be configured"
    fi
    
    # Check if log directory exists and is writable
    log_dir="/var/log/nginx"
    if [ -d "$log_dir" ] && [ -w "$log_dir" ]; then
        print_success "Log directory exists and is writable: $log_dir"
    else
        print_warning "Log directory may not be writable: $log_dir"
    fi
}

generate_summary() {
    print_section "Validation Summary"
    echo ""
    print_info "SSL Configuration Validation Complete"
    echo ""
    print_info "Next steps if issues found:"
    echo "  1. Run: sudo ./puabo_fix_nginx_ssl.sh"
    echo "  2. Check certificate files in: $SSL_DIR"
    echo "  3. Verify Nginx config: sudo nginx -t"
    echo "  4. Restart Nginx: sudo systemctl restart nginx"
    echo "  5. Check logs: sudo tail -f /var/log/nginx/error.log"
    echo ""
}

# Main execution
main() {
    print_header
    
    # Run all tests
    test_certificate_presence
    test_certificate_validity
    test_file_permissions
    test_nginx_configuration
    test_security_headers
    test_https_access
    test_logging_configuration
    
    generate_summary
}

# Execute main function
main "$@"