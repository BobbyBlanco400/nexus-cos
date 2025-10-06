#!/bin/bash
# ==============================================================================
# Nexus COS - IP/Domain Routing Validation Script
# ==============================================================================
# Purpose: Validate that IP and domain requests are routed identically
# Usage: ./validate-ip-domain-routing.sh
# ==============================================================================

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Allow environment variable overrides for flexibility
DOMAIN="${DOMAIN:-nexuscos.online}"
SERVER_IP="${SERVER_IP:-74.208.155.161}"

# Dynamically determine repository root
# Priority: Environment variable > Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$SCRIPT_DIR}"

# Counters
PASSED=0
FAILED=0
WARNINGS=0

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     NEXUS COS - IP/DOMAIN ROUTING VALIDATION                   ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_test() {
    echo -e "${BLUE}Testing:${NC} $1"
}

print_pass() {
    echo -e "${GREEN}✓ PASS${NC} - $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}✗ FAIL${NC} - $1"
    ((FAILED++))
}

print_warn() {
    echo -e "${YELLOW}⚠ WARN${NC} - $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${CYAN}ℹ INFO${NC} - $1"
}

print_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Test 1: Check Nginx is running
test_nginx_running() {
    print_section "1. NGINX SERVICE CHECK"
    print_test "Nginx service status"
    
    if systemctl is-active --quiet nginx 2>/dev/null; then
        print_pass "Nginx is running"
    elif service nginx status 2>/dev/null | grep -q "running"; then
        print_pass "Nginx is running"
    else
        print_fail "Nginx is not running"
    fi
}

# Test 2: Check configuration syntax
test_nginx_config() {
    print_section "2. NGINX CONFIGURATION"
    print_test "Nginx configuration syntax"
    
    if nginx -t 2>&1 | grep -q "successful"; then
        print_pass "Nginx configuration is valid"
    else
        print_fail "Nginx configuration has errors"
        nginx -t 2>&1
    fi
    
    # Check if nexuscos config exists
    print_test "Nexus COS configuration file"
    if [[ -f "/etc/nginx/sites-available/nexuscos" ]]; then
        print_pass "Configuration file exists"
    else
        print_fail "Configuration file not found"
    fi
    
    # Check if enabled
    print_test "Site enabled status"
    if [[ -L "/etc/nginx/sites-enabled/nexuscos" ]]; then
        print_pass "Site is enabled"
    else
        print_fail "Site is not enabled"
    fi
}

# Test 3: Check default_server directive
test_default_server() {
    print_section "3. DEFAULT SERVER CONFIGURATION"
    print_test "default_server directive presence"
    
    if grep -q "default_server" /etc/nginx/sites-available/nexuscos 2>/dev/null; then
        print_pass "default_server directive found"
        
        # Show the line with default_server
        print_info "Found: $(grep "default_server" /etc/nginx/sites-available/nexuscos | head -1 | xargs)"
    else
        print_fail "default_server directive not found (IP requests may fail)"
    fi
    
    # Check if IP is in server_name
    print_test "IP address in server_name"
    if grep -q "$SERVER_IP" /etc/nginx/sites-available/nexuscos 2>/dev/null; then
        print_pass "IP address found in server_name"
    else
        print_warn "IP address not in server_name (may still work with default_server)"
    fi
}

# Test 4: HTTP domain redirect
test_http_domain_redirect() {
    print_section "4. HTTP DOMAIN REDIRECT"
    print_test "HTTP to HTTPS redirect for domain"
    
    RESPONSE=$(curl -I -s -o /dev/null -w "%{http_code}" http://${DOMAIN}/ 2>/dev/null || echo "000")
    
    if [[ "$RESPONSE" == "301" ]] || [[ "$RESPONSE" == "302" ]]; then
        print_pass "Domain HTTP redirects correctly (${RESPONSE})"
    else
        print_warn "Domain HTTP may not redirect (got ${RESPONSE})"
    fi
}

# Test 5: HTTP IP redirect
test_http_ip_redirect() {
    print_section "5. HTTP IP REDIRECT"
    print_test "HTTP IP redirect to domain"
    
    RESPONSE=$(curl -I -s -o /dev/null -w "%{http_code}" http://${SERVER_IP}/ 2>/dev/null || echo "000")
    
    if [[ "$RESPONSE" == "301" ]] || [[ "$RESPONSE" == "302" ]]; then
        print_pass "IP HTTP redirects correctly (${RESPONSE})"
    else
        print_warn "IP HTTP may not redirect (got ${RESPONSE})"
    fi
}

# Test 6: HTTPS domain access
test_https_domain() {
    print_section "6. HTTPS DOMAIN ACCESS"
    print_test "HTTPS domain accessibility"
    
    RESPONSE=$(curl -I -s -o /dev/null -w "%{http_code}" https://${DOMAIN}/ -k 2>/dev/null || echo "000")
    
    if [[ "$RESPONSE" == "200" ]] || [[ "$RESPONSE" == "301" ]] || [[ "$RESPONSE" == "302" ]]; then
        print_pass "HTTPS domain accessible (${RESPONSE})"
    else
        print_fail "HTTPS domain not accessible (got ${RESPONSE})"
    fi
}

# Test 7: Admin panel routing
test_admin_routing() {
    print_section "7. ADMIN PANEL ROUTING"
    print_test "Admin panel accessibility"
    
    RESPONSE=$(curl -I -s -o /dev/null -w "%{http_code}" https://${DOMAIN}/admin/ -k 2>/dev/null || echo "000")
    
    if [[ "$RESPONSE" == "200" ]]; then
        print_pass "Admin panel accessible (${RESPONSE})"
    else
        print_warn "Admin panel may not be accessible (got ${RESPONSE})"
    fi
    
    # Check if admin build exists
    print_test "Admin build directory"
    if [[ -d "/var/www/nexus-cos/admin/build" ]]; then
        print_pass "Admin build directory exists"
        
        if [[ -f "/var/www/nexus-cos/admin/build/index.html" ]]; then
            print_pass "Admin index.html exists"
        else
            print_fail "Admin index.html not found"
        fi
    else
        print_fail "Admin build directory not found"
    fi
}

# Test 8: Creator hub routing
test_creator_routing() {
    print_section "8. CREATOR HUB ROUTING"
    print_test "Creator hub accessibility"
    
    RESPONSE=$(curl -I -s -o /dev/null -w "%{http_code}" https://${DOMAIN}/creator-hub/ -k 2>/dev/null || echo "000")
    
    if [[ "$RESPONSE" == "200" ]]; then
        print_pass "Creator hub accessible (${RESPONSE})"
    else
        print_warn "Creator hub may not be accessible (got ${RESPONSE})"
    fi
    
    # Check if creator hub build exists
    print_test "Creator hub build directory"
    if [[ -d "/var/www/nexus-cos/creator-hub/build" ]]; then
        print_pass "Creator hub build directory exists"
    else
        print_warn "Creator hub build directory not found"
    fi
}

# Test 9: API endpoint routing
test_api_routing() {
    print_section "9. API ENDPOINT ROUTING"
    print_test "Health endpoint"
    
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" https://${DOMAIN}/health -k 2>/dev/null || echo "000")
    
    if [[ "$RESPONSE" == "200" ]]; then
        print_pass "Health endpoint responding (${RESPONSE})"
    else
        print_warn "Health endpoint not responding (got ${RESPONSE})"
    fi
    
    print_test "API endpoint proxy"
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" https://${DOMAIN}/api/health -k 2>/dev/null || echo "000")
    
    if [[ "$RESPONSE" == "200" ]]; then
        print_pass "API endpoint responding (${RESPONSE})"
    elif [[ "$RESPONSE" == "502" ]] || [[ "$RESPONSE" == "503" ]]; then
        print_warn "API endpoint proxy configured but backend not running (${RESPONSE})"
    else
        print_warn "API endpoint may not be configured (got ${RESPONSE})"
    fi
}

# Test 10: Security headers
test_security_headers() {
    print_section "10. SECURITY HEADERS"
    print_test "Security headers presence"
    
    HEADERS=$(curl -I -s https://${DOMAIN}/ -k 2>/dev/null)
    
    if echo "$HEADERS" | grep -qi "X-Frame-Options"; then
        print_pass "X-Frame-Options header present"
    else
        print_warn "X-Frame-Options header missing"
    fi
    
    if echo "$HEADERS" | grep -qi "X-Content-Type-Options"; then
        print_pass "X-Content-Type-Options header present"
    else
        print_warn "X-Content-Type-Options header missing"
    fi
    
    if echo "$HEADERS" | grep -qi "Strict-Transport-Security"; then
        print_pass "HSTS header present"
    else
        print_warn "HSTS header missing (expected if SSL not fully configured)"
    fi
    
    if echo "$HEADERS" | grep -qi "Content-Security-Policy"; then
        print_pass "CSP header present"
    else
        print_warn "CSP header missing"
    fi
}

# Test 11: File permissions
test_file_permissions() {
    print_section "11. FILE PERMISSIONS"
    print_test "Webroot permissions"
    
    if [[ -d "/var/www/nexus-cos" ]]; then
        PERMS=$(stat -c "%a" /var/www/nexus-cos 2>/dev/null || stat -f "%A" /var/www/nexus-cos 2>/dev/null || echo "000")
        
        if [[ "$PERMS" == "755" ]] || [[ "$PERMS" == "775" ]]; then
            print_pass "Webroot has correct permissions (${PERMS})"
        else
            print_warn "Webroot permissions may be incorrect (${PERMS})"
        fi
    else
        print_fail "Webroot directory not found"
    fi
}

# Test 12: Environment variables
test_environment_vars() {
    print_section "12. ENVIRONMENT VARIABLES"
    print_test "Environment configuration"
    
    if [[ -f "${REPO_ROOT}/.env" ]]; then
        print_pass ".env file exists"
        
        if grep -q "VITE_API_URL" "${REPO_ROOT}/.env"; then
            VITE_API_URL=$(grep "VITE_API_URL" "${REPO_ROOT}/.env" | cut -d'=' -f2)
            
            if echo "$VITE_API_URL" | grep -qi "localhost"; then
                print_fail "VITE_API_URL points to localhost (production issue!)"
            else
                print_pass "VITE_API_URL correctly configured: ${VITE_API_URL}"
            fi
        else
            print_warn "VITE_API_URL not found in .env"
        fi
    else
        print_warn ".env file not found"
    fi
}

# Generate summary
print_summary() {
    print_section "VALIDATION SUMMARY"
    
    TOTAL=$((PASSED + FAILED + WARNINGS))
    
    echo -e "Total Tests: ${TOTAL}"
    echo -e "${GREEN}Passed: ${PASSED}${NC}"
    echo -e "${RED}Failed: ${FAILED}${NC}"
    echo -e "${YELLOW}Warnings: ${WARNINGS}${NC}"
    echo ""
    
    if [[ $FAILED -eq 0 ]]; then
        if [[ $WARNINGS -eq 0 ]]; then
            echo -e "${GREEN}✓ ALL CHECKS PASSED${NC}"
            echo -e "IP/Domain routing is correctly unified!"
        else
            echo -e "${YELLOW}⚠ CHECKS PASSED WITH WARNINGS${NC}"
            echo -e "Review warnings above and address if needed"
        fi
    else
        echo -e "${RED}✗ SOME CHECKS FAILED${NC}"
        echo -e "Review failed checks and run pf-ip-domain-unification.sh"
    fi
    
    echo ""
    echo -e "Detailed report: /tmp/nexus-cos-validation-report.txt"
}

# Main execution
main() {
    print_header
    
    test_nginx_running
    test_nginx_config
    test_default_server
    test_http_domain_redirect
    test_http_ip_redirect
    test_https_domain
    test_admin_routing
    test_creator_routing
    test_api_routing
    test_security_headers
    test_file_permissions
    test_environment_vars
    
    print_summary
    
    # Save report
    {
        echo "Nexus COS - IP/Domain Routing Validation Report"
        echo "================================================"
        echo "Timestamp: $(date)"
        echo ""
        echo "Results:"
        echo "  Total Tests: $((PASSED + FAILED + WARNINGS))"
        echo "  Passed: $PASSED"
        echo "  Failed: $FAILED"
        echo "  Warnings: $WARNINGS"
        echo ""
        echo "Domain: $DOMAIN"
        echo "Server IP: $SERVER_IP"
    } > /tmp/nexus-cos-validation-report.txt
}

# Run
main "$@"
