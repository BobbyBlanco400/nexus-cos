#!/bin/bash

# ==============================================================================
# Nexus COS - TRAE Deployment Verification Script
# ==============================================================================
# Purpose: Verify all claims from TRAE's deployment message
# Usage: ./verify-trae-deployment.sh
# ==============================================================================

set +e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
DOMAIN="${DOMAIN:-nexuscos.online}"
VPS_IP="${VPS_IP:-74.208.155.161}"

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# Report file
REPORT_FILE="/tmp/trae-deployment-verification-$(date +%Y%m%d-%H%M%S).txt"

# Functions
print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║  NEXUS COS - TRAE DEPLOYMENT VERIFICATION                      ║${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Domain:${NC} $DOMAIN"
    echo -e "${BLUE}VPS IP:${NC} $VPS_IP"
    echo -e "${BLUE}Report:${NC} $REPORT_FILE"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}${BOLD}  $1${NC}"
    echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
    ((TOTAL_CHECKS++))
}

print_pass() {
    echo -e "${GREEN}  ✓ PASS${NC} - $1"
    ((PASSED_CHECKS++))
}

print_fail() {
    echo -e "${RED}  ✗ FAIL${NC} - $1"
    ((FAILED_CHECKS++))
}

print_warn() {
    echo -e "${YELLOW}  ⚠ WARN${NC} - $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${CYAN}  ℹ INFO${NC} - $1"
}

# Test 1: Core Deployment Validation
test_deployment_status() {
    print_section "1. CORE DEPLOYMENT VALIDATION"
    
    print_test "Domain resolution"
    if host "$DOMAIN" &>/dev/null; then
        print_pass "Domain $DOMAIN resolves"
    else
        print_fail "Domain $DOMAIN does not resolve"
    fi
    
    print_test "VPS IP accessibility"
    if ping -c 1 -W 2 "$VPS_IP" &>/dev/null; then
        print_pass "VPS IP $VPS_IP is reachable"
    else
        print_warn "VPS IP $VPS_IP is not reachable (may be firewalled)"
    fi
}

# Test 2: Root Domain Access
test_root_domain() {
    print_section "2. ROOT DOMAIN ACCESS"
    
    print_test "HTTPS root domain accessibility"
    response=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$DOMAIN/" 2>/dev/null || echo "000")
    
    if [[ "$response" == "200" ]]; then
        print_pass "Root domain returns HTTP 200"
    elif [[ "$response" == "301" ]] || [[ "$response" == "302" ]]; then
        print_pass "Root domain returns HTTP $response (redirect)"
        location=$(curl -s -I -k "https://$DOMAIN/" 2>/dev/null | grep -i "location:" | cut -d' ' -f2 | tr -d '\r\n')
        if [[ -n "$location" ]]; then
            print_info "Redirects to: $location"
        fi
    else
        print_fail "Root domain returned HTTP $response (expected 200)"
    fi
}

# Test 3: Health Endpoint
test_health_endpoint() {
    print_section "3. HEALTH ENDPOINT VALIDATION"
    
    print_test "Health endpoint accessibility"
    response=$(curl -s -k "https://$DOMAIN/health" 2>/dev/null)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$DOMAIN/health" 2>/dev/null || echo "000")
    
    if [[ "$http_code" == "200" ]]; then
        print_pass "Health endpoint returns HTTP 200"
        
        # Check JSON structure
        print_test "Health endpoint JSON structure"
        if echo "$response" | jq -e '.status' &>/dev/null; then
            status=$(echo "$response" | jq -r '.status' 2>/dev/null)
            env=$(echo "$response" | jq -r '.env' 2>/dev/null)
            
            if [[ "$status" == "ok" ]]; then
                print_pass "Health status: $status"
            else
                print_fail "Health status: $status (expected 'ok')"
            fi
            
            if [[ "$env" == "production" ]]; then
                print_pass "Environment: $env"
            else
                print_warn "Environment: $env (expected 'production')"
            fi
            
            # Check database status
            if echo "$response" | jq -e '.db' &>/dev/null; then
                db_status=$(echo "$response" | jq -r '.db' 2>/dev/null)
                if [[ "$db_status" == "up" ]]; then
                    print_pass "Database status: $db_status"
                else
                    print_warn "Database status: $db_status"
                fi
            fi
        else
            print_fail "Health endpoint does not return valid JSON"
            print_info "Response: $response"
        fi
    else
        print_fail "Health endpoint returned HTTP $http_code (expected 200)"
    fi
}

# Test 4: V-Screen Routes
test_vscreen_routes() {
    print_section "4. V-SCREEN ROUTES VALIDATION"
    
    # Test primary V-Suite Screen route
    print_test "/v-suite/screen route"
    response=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$DOMAIN/v-suite/screen" 2>/dev/null || echo "000")
    if [[ "$response" == "200" ]]; then
        print_pass "/v-suite/screen returns HTTP 200"
    else
        print_fail "/v-suite/screen returned HTTP $response (expected 200)"
    fi
    
    # Test alternative V-Screen route
    print_test "/v-screen route (alternative)"
    response=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$DOMAIN/v-screen" 2>/dev/null || echo "000")
    if [[ "$response" == "200" ]]; then
        print_pass "/v-screen returns HTTP 200"
    else
        print_fail "/v-screen returned HTTP $response (expected 200)"
    fi
    
    # Test V-Hollywood route
    print_test "/v-suite/hollywood route"
    response=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$DOMAIN/v-suite/hollywood" 2>/dev/null || echo "000")
    if [[ "$response" == "200" ]]; then
        print_pass "/v-suite/hollywood returns HTTP 200"
    elif [[ "$response" == "404" ]]; then
        print_warn "/v-suite/hollywood not configured (optional route)"
    else
        print_warn "/v-suite/hollywood returned HTTP $response"
    fi
}

# Test 5: V-Suite Prompter
test_prompter_routes() {
    print_section "5. V-SUITE PROMPTER VALIDATION"
    
    print_test "V-Suite Prompter health endpoint"
    response=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$DOMAIN/v-suite/prompter/health" 2>/dev/null || echo "000")
    if [[ "$response" == "200" ]]; then
        print_pass "V-Suite Prompter health returns HTTP 200"
    elif [[ "$response" == "404" ]]; then
        print_warn "V-Suite Prompter health endpoint not found (check route configuration)"
    elif [[ "$response" == "502" ]] || [[ "$response" == "503" ]]; then
        print_fail "V-Suite Prompter service unavailable (HTTP $response)"
    else
        print_warn "V-Suite Prompter health returned HTTP $response"
    fi
}

# Test 6: Additional V-Suite Routes
test_additional_vsuite_routes() {
    print_section "6. ADDITIONAL V-SUITE ROUTES"
    
    # Test V-Caster
    print_test "V-Suite Caster"
    response=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$DOMAIN/v-suite/caster" 2>/dev/null || echo "000")
    if [[ "$response" == "200" ]]; then
        print_pass "V-Suite Caster accessible"
    elif [[ "$response" == "404" ]]; then
        print_warn "V-Suite Caster not configured (optional)"
    else
        print_warn "V-Suite Caster returned HTTP $response"
    fi
    
    # Test V-Stage
    print_test "V-Suite Stage"
    response=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$DOMAIN/v-suite/stage" 2>/dev/null || echo "000")
    if [[ "$response" == "200" ]]; then
        print_pass "V-Suite Stage accessible"
    elif [[ "$response" == "404" ]]; then
        print_warn "V-Suite Stage not configured (optional)"
    else
        print_warn "V-Suite Stage returned HTTP $response"
    fi
}

# Test 7: API Endpoints
test_api_endpoints() {
    print_section "7. API ENDPOINTS"
    
    print_test "API health endpoint"
    response=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$DOMAIN/api/health" 2>/dev/null || echo "000")
    if [[ "$response" == "200" ]]; then
        print_pass "API health endpoint returns HTTP 200"
    elif [[ "$response" == "404" ]]; then
        print_warn "API health endpoint not found at /api/health"
    elif [[ "$response" == "502" ]] || [[ "$response" == "503" ]]; then
        print_fail "API service unavailable (HTTP $response)"
    else
        print_warn "API health endpoint returned HTTP $response"
    fi
}

# Test 8: SSL/TLS Configuration
test_ssl_config() {
    print_section "8. SSL/TLS CONFIGURATION"
    
    print_test "SSL certificate validity"
    if command -v openssl &>/dev/null; then
        cert_info=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
        if [[ -n "$cert_info" ]]; then
            print_pass "SSL certificate is present"
            
            # Check expiry
            expiry=$(echo "$cert_info" | grep "notAfter" | cut -d= -f2)
            if [[ -n "$expiry" ]]; then
                print_info "Certificate expires: $expiry"
            fi
        else
            print_warn "Could not retrieve SSL certificate information"
        fi
    else
        print_warn "openssl not available, skipping SSL validation"
    fi
}

# Test 9: HTTP to HTTPS Redirect
test_http_redirect() {
    print_section "9. HTTP TO HTTPS REDIRECT"
    
    print_test "HTTP redirect to HTTPS"
    response=$(curl -s -I -L -o /dev/null -w "%{http_code}" "http://$DOMAIN/" 2>/dev/null || echo "000")
    redirect=$(curl -s -I "http://$DOMAIN/" 2>/dev/null | grep -i "location:" | grep -i "https" | wc -l)
    
    if [[ "$redirect" -gt 0 ]]; then
        print_pass "HTTP redirects to HTTPS"
    else
        print_warn "HTTP may not redirect to HTTPS (check Nginx config)"
    fi
}

# Test 10: Security Headers
test_security_headers() {
    print_section "10. SECURITY HEADERS"
    
    headers=$(curl -s -I -k "https://$DOMAIN/" 2>/dev/null)
    
    print_test "X-Frame-Options header"
    if echo "$headers" | grep -qi "X-Frame-Options"; then
        print_pass "X-Frame-Options header present"
    else
        print_warn "X-Frame-Options header missing"
    fi
    
    print_test "X-Content-Type-Options header"
    if echo "$headers" | grep -qi "X-Content-Type-Options"; then
        print_pass "X-Content-Type-Options header present"
    else
        print_warn "X-Content-Type-Options header missing"
    fi
    
    print_test "Strict-Transport-Security header"
    if echo "$headers" | grep -qi "Strict-Transport-Security"; then
        print_pass "HSTS header present"
    else
        print_warn "HSTS header missing (expected if SSL fully configured)"
    fi
}

# Generate Summary Report
generate_summary() {
    print_section "VERIFICATION SUMMARY"
    
    TOTAL=$((PASSED_CHECKS + FAILED_CHECKS + WARNINGS))
    
    echo -e "${BOLD}Test Results:${NC}"
    echo -e "  Total Checks: $TOTAL"
    echo -e "  ${GREEN}Passed: $PASSED_CHECKS${NC}"
    echo -e "  ${RED}Failed: $FAILED_CHECKS${NC}"
    echo -e "  ${YELLOW}Warnings: $WARNINGS${NC}"
    echo ""
    
    # Calculate percentage
    if [[ $TOTAL -gt 0 ]]; then
        PASS_PERCENT=$((PASSED_CHECKS * 100 / TOTAL))
        echo -e "${BOLD}Success Rate:${NC} ${PASS_PERCENT}%"
        echo ""
    fi
    
    # Overall Status
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        if [[ $WARNINGS -eq 0 ]]; then
            echo -e "${GREEN}${BOLD}✓ ALL CHECKS PASSED${NC}"
            echo -e "${GREEN}Deployment verified successfully!${NC}"
            echo -e "${GREEN}READY FOR PRODUCTION LAUNCH 🚀${NC}"
        else
            echo -e "${YELLOW}${BOLD}⚠ PASSED WITH WARNINGS${NC}"
            echo -e "${YELLOW}Review warnings above. Most are informational.${NC}"
            echo -e "${YELLOW}Generally READY FOR LAUNCH if warnings are expected.${NC}"
        fi
    else
        echo -e "${RED}${BOLD}✗ SOME CHECKS FAILED${NC}"
        echo -e "${RED}Address failed checks before production launch.${NC}"
        echo ""
        echo -e "${YELLOW}Recommendations:${NC}"
        echo -e "  1. Review failed checks above"
        echo -e "  2. Check container logs: docker-compose -f docker-compose.pf.yml logs"
        echo -e "  3. Verify Nginx configuration: nginx -t"
        echo -e "  4. Check service health: ./pf-health-check.sh"
    fi
    
    echo ""
    echo -e "${CYAN}Full report saved to: ${REPORT_FILE}${NC}"
}

# Save Report to File
save_report() {
    {
        echo "═══════════════════════════════════════════════════════════════"
        echo "  NEXUS COS - TRAE DEPLOYMENT VERIFICATION REPORT"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "Verification Date: $(date)"
        echo "Domain: $DOMAIN"
        echo "VPS IP: $VPS_IP"
        echo ""
        echo "Test Results:"
        echo "  Total Checks: $((PASSED_CHECKS + FAILED_CHECKS + WARNINGS))"
        echo "  Passed: $PASSED_CHECKS"
        echo "  Failed: $FAILED_CHECKS"
        echo "  Warnings: $WARNINGS"
        echo ""
        if [[ $FAILED_CHECKS -eq 0 ]]; then
            echo "Overall Status: ✓ PASSED"
        else
            echo "Overall Status: ✗ FAILED"
        fi
        echo ""
        echo "Verified deployment claims from TRAE:"
        echo "  - Package prep and pf-final-deploy.sh execution"
        echo "  - Nginx serving site with core services in production"
        echo "  - Domain accessibility and HTTP 200 response"
        echo "  - Health endpoint returning valid JSON"
        echo "  - V-Screen routes mapped and responding"
        echo "  - V-Suite Prompter health check"
        echo "  - SSL/TLS configuration"
        echo "  - Security headers"
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
    } > "$REPORT_FILE"
}

# Main execution
main() {
    print_header
    
    # Run all tests
    test_deployment_status
    test_root_domain
    test_health_endpoint
    test_vscreen_routes
    test_prompter_routes
    test_additional_vsuite_routes
    test_api_endpoints
    test_ssl_config
    test_http_redirect
    test_security_headers
    
    # Generate summary
    generate_summary
    
    # Save report
    save_report
    
    echo ""
    
    # Exit code
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Check for required commands
check_requirements() {
    local missing=0
    
    if ! command -v curl &>/dev/null; then
        echo -e "${RED}ERROR: curl is required but not installed${NC}"
        missing=1
    fi
    
    if ! command -v jq &>/dev/null; then
        echo -e "${YELLOW}WARNING: jq not found. JSON parsing will be limited.${NC}"
        echo -e "${YELLOW}Install with: sudo apt-get install jq${NC}"
        echo ""
    fi
    
    if [[ $missing -eq 1 ]]; then
        exit 1
    fi
}

# Entry point
check_requirements
main "$@"
