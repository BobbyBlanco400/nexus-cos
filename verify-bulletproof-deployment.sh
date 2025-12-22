#!/bin/bash
# ==============================================================================
# Nexus COS Platform Stack - Bulletproof Deployment Verification
# ==============================================================================
# This script verifies that all components are correctly configured for
# containerized deployment without manual server login.
# ==============================================================================

set -uo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
PASS=0
FAIL=0
WARN=0

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║   NEXUS COS - BULLETPROOF DEPLOYMENT VERIFICATION              ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASS++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAIL++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARN++))
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# ==============================================================================
# Check 1: Nginx Configuration Files Exist
# ==============================================================================
check_nginx_files() {
    print_section "Checking Nginx Configuration Files"
    
    if [[ -f "nginx.conf" ]]; then
        check_pass "nginx.conf exists"
    else
        check_fail "nginx.conf missing"
    fi
    
    if [[ -f "nginx.conf.docker" ]]; then
        check_pass "nginx.conf.docker exists"
    else
        check_fail "nginx.conf.docker missing"
    fi
    
    if [[ -f "nginx/conf.d/nexus-proxy.conf" ]]; then
        check_pass "nginx/conf.d/nexus-proxy.conf exists"
    else
        check_fail "nginx/conf.d/nexus-proxy.conf missing"
    fi
}

# ==============================================================================
# Check 2: No Static Localhost References in Nginx
# ==============================================================================
check_no_static_localhost() {
    print_section "Checking for Static Localhost References"
    
    # Check nginx.conf
    if grep -q "127\.0\.0\.1:3047" nginx.conf; then
        check_fail "nginx.conf contains static localhost:3047 reference"
    else
        check_pass "nginx.conf has no static localhost:3047 references"
    fi
    
    # Check nginx/conf.d/nexus-proxy.conf
    if grep -q "127\.0\.0\.1:3047" nginx/conf.d/nexus-proxy.conf; then
        check_fail "nexus-proxy.conf contains static localhost:3047 reference"
    else
        check_pass "nexus-proxy.conf has no static localhost:3047 references"
    fi
}

# ==============================================================================
# Check 3: Verify Upstream Definitions
# ==============================================================================
check_upstreams() {
    print_section "Verifying Upstream Definitions"
    
    # Check pf_gateway upstream
    if grep -q "upstream pf_gateway" nginx.conf; then
        check_pass "pf_gateway upstream defined"
        
        if grep -A 1 "upstream pf_gateway" nginx.conf | grep -q "puabo-api:4000"; then
            check_pass "pf_gateway points to puabo-api:4000"
        else
            check_fail "pf_gateway does not point to puabo-api:4000"
        fi
    else
        check_fail "pf_gateway upstream not defined"
    fi
    
    # Check other upstreams
    if grep -q "upstream pf_puaboai_sdk" nginx.conf; then
        check_pass "pf_puaboai_sdk upstream defined"
    else
        check_warn "pf_puaboai_sdk upstream not defined"
    fi
    
    if grep -q "upstream pf_pv_keys" nginx.conf; then
        check_pass "pf_pv_keys upstream defined"
    else
        check_warn "pf_pv_keys upstream not defined"
    fi
    
    if grep -q "upstream vscreen_hollywood" nginx.conf; then
        check_pass "vscreen_hollywood upstream defined"
    else
        check_warn "vscreen_hollywood upstream not defined"
    fi
}

# ==============================================================================
# Check 4: Verify Critical Routes Use Upstreams
# ==============================================================================
check_routes() {
    print_section "Verifying Critical Routes"
    
    # Check /streaming route
    if grep -A 5 "location /streaming" nginx.conf | grep -q "proxy_pass http://pf_gateway/streaming"; then
        check_pass "/streaming route uses pf_gateway upstream"
    else
        check_fail "/streaming route does not use pf_gateway upstream"
    fi
    
    # Check /casino route
    if grep -A 5 "location /casino" nginx.conf | grep -q "proxy_pass http://pf_gateway/casino"; then
        check_pass "/casino route uses pf_gateway upstream"
    else
        check_fail "/casino route does not use pf_gateway upstream"
    fi
    
    # Check /api route
    if grep -A 5 "location /api" nginx.conf | grep -q "proxy_pass http://pf_gateway/api"; then
        check_pass "/api route uses pf_gateway upstream"
    else
        check_fail "/api route does not use pf_gateway upstream"
    fi
    
    # Check /admin route
    if grep -A 5 "location /admin" nginx.conf | grep -q "proxy_pass http://pf_gateway/admin"; then
        check_pass "/admin route uses pf_gateway upstream"
    else
        check_warn "/admin route does not use pf_gateway upstream"
    fi
}

# ==============================================================================
# Check 5: Docker Compose Configuration
# ==============================================================================
check_docker_compose() {
    print_section "Checking Docker Compose Configuration"
    
    if [[ -f "docker-compose.pf.yml" ]]; then
        check_pass "docker-compose.pf.yml exists"
        
        # Check for puabo-api service
        if grep -q "puabo-api:" docker-compose.pf.yml; then
            check_pass "puabo-api service defined"
            
            # Check port 4000
            if grep -A 30 "puabo-api:" docker-compose.pf.yml | grep -E '^\s+ports:' -A 2 | grep -q "4000:4000"; then
                check_pass "puabo-api exposes port 4000"
            else
                check_fail "puabo-api does not expose port 4000"
            fi
        else
            check_fail "puabo-api service not defined"
        fi
        
        # Check for networks
        if grep -q "cos-net:" docker-compose.pf.yml; then
            check_pass "cos-net network defined"
        else
            check_fail "cos-net network not defined"
        fi
        
    else
        check_fail "docker-compose.pf.yml missing"
    fi
}

# ==============================================================================
# Check 6: Environment Configuration
# ==============================================================================
check_env_files() {
    print_section "Checking Environment Configuration"
    
    if [[ -f ".env.pf.example" ]]; then
        check_pass ".env.pf.example exists"
    else
        check_warn ".env.pf.example missing"
    fi
    
    if [[ -f ".env.pf" ]]; then
        check_pass ".env.pf exists"
        
        # Check for required variables
        if grep -q "DB_PASSWORD=" .env.pf && ! grep -q "DB_PASSWORD=$" .env.pf; then
            check_pass "DB_PASSWORD is set"
        else
            check_warn "DB_PASSWORD not set or empty"
        fi
        
        if grep -q "OAUTH_CLIENT_ID=" .env.pf && ! grep -q "OAUTH_CLIENT_ID=$" .env.pf; then
            check_pass "OAUTH_CLIENT_ID is set"
        else
            check_warn "OAUTH_CLIENT_ID not set or empty"
        fi
    else
        check_warn ".env.pf does not exist (will use defaults)"
    fi
}

# ==============================================================================
# Check 7: TRAE Documentation
# ==============================================================================
check_trae_docs() {
    print_section "Checking TRAE Documentation"
    
    if [[ -d ".trae" ]]; then
        check_pass ".trae directory exists"
        
        if [[ -f ".trae/DEPLOYMENT_INSTRUCTIONS.md" ]]; then
            check_pass ".trae/DEPLOYMENT_INSTRUCTIONS.md exists"
        else
            check_fail ".trae/DEPLOYMENT_INSTRUCTIONS.md missing"
        fi
        
        if [[ -f ".trae/environment.env" ]]; then
            check_pass ".trae/environment.env exists"
        else
            check_warn ".trae/environment.env missing"
        fi
    else
        check_fail ".trae directory missing"
    fi
}

# ==============================================================================
# Check 8: File Permissions
# ==============================================================================
check_permissions() {
    print_section "Checking File Permissions"
    
    # Check if nginx configs are readable
    if [[ -r "nginx.conf" ]]; then
        check_pass "nginx.conf is readable"
    else
        check_fail "nginx.conf is not readable"
    fi
    
    if [[ -r "nginx.conf.docker" ]]; then
        check_pass "nginx.conf.docker is readable"
    else
        check_fail "nginx.conf.docker is not readable"
    fi
}

# ==============================================================================
# Print Summary
# ==============================================================================
print_summary() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    VERIFICATION SUMMARY                        ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}Passed:${NC}   $PASS"
    echo -e "  ${RED}Failed:${NC}   $FAIL"
    echo -e "  ${YELLOW}Warnings:${NC} $WARN"
    echo ""
    
    if [[ $FAIL -eq 0 ]]; then
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ✓ ALL CRITICAL CHECKS PASSED - READY FOR DEPLOYMENT          ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}Next Steps:${NC}"
        echo -e "  1. Configure .env.pf with production credentials"
        echo -e "  2. Deploy with: ${YELLOW}docker compose -f docker-compose.pf.yml up -d${NC}"
        echo -e "  3. Verify services: ${YELLOW}docker compose -f docker-compose.pf.yml ps${NC}"
        echo -e "  4. Check health: ${YELLOW}curl http://localhost:4000/health${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  ✗ CRITICAL CHECKS FAILED - FIX ERRORS BEFORE DEPLOYMENT       ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Please fix the failed checks above before deploying.${NC}"
        echo ""
        return 1
    fi
}

# ==============================================================================
# Main Execution
# ==============================================================================
main() {
    print_header
    
    check_nginx_files
    check_no_static_localhost
    check_upstreams
    check_routes
    check_docker_compose
    check_env_files
    check_trae_docs
    check_permissions
    
    print_summary
}

# Run main function
main "$@"
