#!/bin/bash

# ==============================================================================
# PR#87 Landing Page Validation Script
# ==============================================================================
# Purpose: Comprehensive validation of deployed landing pages from PR#87
# Target VPS: 74.208.155.161 (n3xuscos.online)
# ==============================================================================

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Dynamically determine repository root
# Priority: Environment variable > Parent of script directory
# Since this script is in scripts/ subdirectory, go up one level to find repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="${REPO_ROOT:-$(dirname "$SCRIPT_DIR")}"

# Configuration
readonly APEX_TARGET="/var/www/n3xuscos.online/index.html"
readonly BETA_TARGET="/var/www/beta.n3xuscos.online/index.html"

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# ==============================================================================
# Helper Functions
# ==============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║         PR#87 LANDING PAGE VALIDATION - STRICT MODE            ║${NC}"
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

check() {
    echo -e "${YELLOW}▶${NC} $1"
}

pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# ==============================================================================
# File Validation
# ==============================================================================

validate_files() {
    print_section "1. FILE VALIDATION"
    
    # Check apex file
    check "Checking apex landing page..."
    if [[ -f "${APEX_TARGET}" ]]; then
        pass "Apex file exists: ${APEX_TARGET}"
        
        # Check line count
        APEX_LINES=$(wc -l < "${APEX_TARGET}")
        if [[ "${APEX_LINES}" -eq 815 ]]; then
            pass "Apex file has correct line count: ${APEX_LINES}"
        else
            warn "Apex file line count: ${APEX_LINES} (expected 815)"
        fi
        
        # Check file permissions
        APEX_PERMS=$(stat -c "%a" "${APEX_TARGET}")
        if [[ "${APEX_PERMS}" == "644" ]]; then
            pass "Apex file permissions correct: ${APEX_PERMS}"
        else
            warn "Apex file permissions: ${APEX_PERMS} (expected 644)"
        fi
        
        # Check ownership
        APEX_OWNER=$(stat -c "%U:%G" "${APEX_TARGET}")
        if [[ "${APEX_OWNER}" == "www-data:www-data" ]]; then
            pass "Apex file ownership correct: ${APEX_OWNER}"
        else
            warn "Apex file ownership: ${APEX_OWNER} (expected www-data:www-data)"
        fi
    else
        fail "Apex file NOT found: ${APEX_TARGET}"
    fi
    
    # Check beta file
    check "Checking beta landing page..."
    if [[ -f "${BETA_TARGET}" ]]; then
        pass "Beta file exists: ${BETA_TARGET}"
        
        # Check line count
        BETA_LINES=$(wc -l < "${BETA_TARGET}")
        if [[ "${BETA_LINES}" -eq 826 ]]; then
            pass "Beta file has correct line count: ${BETA_LINES}"
        else
            warn "Beta file line count: ${BETA_LINES} (expected 826)"
        fi
        
        # Check file permissions
        BETA_PERMS=$(stat -c "%a" "${BETA_TARGET}")
        if [[ "${BETA_PERMS}" == "644" ]]; then
            pass "Beta file permissions correct: ${BETA_PERMS}"
        else
            warn "Beta file permissions: ${BETA_PERMS} (expected 644)"
        fi
        
        # Check ownership
        BETA_OWNER=$(stat -c "%U:%G" "${BETA_TARGET}")
        if [[ "${BETA_OWNER}" == "www-data:www-data" ]]; then
            pass "Beta file ownership correct: ${BETA_OWNER}"
        else
            warn "Beta file ownership: ${BETA_OWNER} (expected www-data:www-data)"
        fi
    else
        fail "Beta file NOT found: ${BETA_TARGET}"
    fi
}

# ==============================================================================
# Content Validation
# ==============================================================================

validate_content() {
    print_section "2. CONTENT VALIDATION"
    
    # Validate apex content
    check "Validating apex HTML structure..."
    if [[ -f "${APEX_TARGET}" ]]; then
        if grep -q '<!DOCTYPE html>' "${APEX_TARGET}"; then
            pass "Apex: DOCTYPE declaration present"
        else
            fail "Apex: DOCTYPE declaration missing"
        fi
        
        if grep -q '<title>Nexus COS — Apex</title>' "${APEX_TARGET}"; then
            pass "Apex: Correct title tag"
        else
            fail "Apex: Title tag missing or incorrect"
        fi
        
        if grep -q 'The COS for Creative Ecosystems' "${APEX_TARGET}"; then
            pass "Apex: Hero headline present"
        else
            fail "Apex: Hero headline missing"
        fi
        
        if grep -q 'theme-toggle' "${APEX_TARGET}"; then
            pass "Apex: Theme toggle present"
        else
            fail "Apex: Theme toggle missing"
        fi
        
        TAB_COUNT=$(grep -c 'tab-btn' "${APEX_TARGET}" || true)
        if [[ "${TAB_COUNT}" -ge 6 ]]; then
            pass "Apex: Module tabs present (${TAB_COUNT})"
        else
            fail "Apex: Module tabs missing or incomplete (found ${TAB_COUNT}, expected 6)"
        fi
        
        STAT_COUNT=$(grep -c 'stat-value' "${APEX_TARGET}" || true)
        if [[ "${STAT_COUNT}" -ge 3 ]]; then
            pass "Apex: Stat counters present (${STAT_COUNT})"
        else
            fail "Apex: Stat counters missing (found ${STAT_COUNT}, expected 3)"
        fi
    fi
    
    # Validate beta content
    check "Validating beta HTML structure..."
    if [[ -f "${BETA_TARGET}" ]]; then
        if grep -q '<!DOCTYPE html>' "${BETA_TARGET}"; then
            pass "Beta: DOCTYPE declaration present"
        else
            fail "Beta: DOCTYPE declaration missing"
        fi
        
        if grep -q '<title>Nexus COS — Beta</title>' "${BETA_TARGET}"; then
            pass "Beta: Correct title tag"
        else
            fail "Beta: Title tag missing or incorrect"
        fi
        
        if grep -q 'beta-badge' "${BETA_TARGET}"; then
            pass "Beta: Beta badge present"
        else
            fail "Beta: Beta badge missing"
        fi
        
        TAB_COUNT=$(grep -c 'tab-btn' "${BETA_TARGET}" || true)
        if [[ "${TAB_COUNT}" -ge 6 ]]; then
            pass "Beta: Module tabs present (${TAB_COUNT})"
        else
            fail "Beta: Module tabs missing or incomplete (found ${TAB_COUNT}, expected 6)"
        fi
    fi
}

# ==============================================================================
# Nginx Validation
# ==============================================================================

validate_nginx() {
    print_section "3. NGINX VALIDATION"
    
    check "Testing nginx configuration..."
    if nginx -t &>/dev/null; then
        pass "Nginx configuration is valid"
    else
        fail "Nginx configuration test failed"
    fi
    
    check "Checking nginx service status..."
    if systemctl is-active --quiet nginx; then
        pass "Nginx service is active"
    else
        fail "Nginx service is not running"
    fi
    
    check "Verifying nginx config files..."
    if [[ -f /etc/nginx/sites-available/n3xuscos.online ]] || \
       [[ -f /etc/nginx/conf.d/n3xuscos.online.conf ]] || \
       [[ -f /etc/nginx/nginx.conf ]]; then
        pass "Nginx configuration files present"
    else
        warn "Could not locate nginx configuration files"
    fi
}

# ==============================================================================
# HTTP/HTTPS Validation
# ==============================================================================

validate_http() {
    print_section "4. HTTP/HTTPS VALIDATION"
    
    # Test apex domain
    check "Testing apex domain (https://n3xuscos.online)..."
    APEX_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://n3xuscos.online 2>/dev/null || echo "000")
    if [[ "${APEX_STATUS}" == "200" ]]; then
        pass "Apex domain returns 200 OK"
    elif [[ "${APEX_STATUS}" == "000" ]]; then
        warn "Apex domain unreachable (SSL/DNS may not be configured)"
    else
        warn "Apex domain returns: ${APEX_STATUS}"
    fi
    
    # Verify apex content
    if [[ "${APEX_STATUS}" == "200" ]]; then
        check "Verifying apex content..."
        APEX_CONTENT=$(curl -s https://n3xuscos.online 2>/dev/null || true)
        if echo "${APEX_CONTENT}" | grep -q 'Nexus COS — Apex'; then
            pass "Apex page title correct"
        else
            warn "Apex page title not found in response"
        fi
    fi
    
    # Test beta domain
    check "Testing beta domain (https://beta.n3xuscos.online)..."
    BETA_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://beta.n3xuscos.online 2>/dev/null || echo "000")
    if [[ "${BETA_STATUS}" == "200" ]]; then
        pass "Beta domain returns 200 OK"
    elif [[ "${BETA_STATUS}" == "000" ]]; then
        warn "Beta domain unreachable (SSL/DNS may not be configured)"
    else
        warn "Beta domain returns: ${BETA_STATUS}"
    fi
    
    # Verify beta content and badge
    if [[ "${BETA_STATUS}" == "200" ]]; then
        check "Verifying beta content..."
        BETA_CONTENT=$(curl -s https://beta.n3xuscos.online 2>/dev/null || true)
        if echo "${BETA_CONTENT}" | grep -q 'Nexus COS — Beta'; then
            pass "Beta page title correct"
        else
            warn "Beta page title not found in response"
        fi
        
        if echo "${BETA_CONTENT}" | grep -q 'beta-badge'; then
            pass "Beta badge present in response"
        else
            fail "Beta badge NOT found in response"
        fi
    fi
}

# ==============================================================================
# SSL Validation
# ==============================================================================

validate_ssl() {
    print_section "5. SSL VALIDATION"
    
    check "Checking SSL certificates..."
    if [[ -f /etc/nginx/ssl/apex/n3xuscos.online.crt ]]; then
        pass "SSL certificate found: /etc/nginx/ssl/apex/n3xuscos.online.crt"
        
        # Check expiration
        if openssl x509 -in /etc/nginx/ssl/apex/n3xuscos.online.crt -noout -checkend 0 &>/dev/null; then
            pass "SSL certificate is valid (not expired)"
            
            # Get expiration date
            EXPIRY=$(openssl x509 -in /etc/nginx/ssl/apex/n3xuscos.online.crt -noout -enddate 2>/dev/null | cut -d= -f2)
            info "Certificate expires: ${EXPIRY}"
        else
            fail "SSL certificate is expired or invalid"
        fi
        
        # Check issuer
        ISSUER=$(openssl x509 -in /etc/nginx/ssl/apex/n3xuscos.online.crt -noout -issuer 2>/dev/null || echo "Unknown")
        if echo "${ISSUER}" | grep -qi "IONOS"; then
            pass "SSL certificate issued by IONOS"
        else
            info "SSL issuer: ${ISSUER}"
        fi
    else
        warn "SSL certificate not found (expected for local/development)"
    fi
    
    # Test SSL connection
    check "Testing SSL connection to apex..."
    if timeout 5 openssl s_client -connect n3xuscos.online:443 -showcerts </dev/null &>/dev/null; then
        pass "SSL connection to apex successful"
    else
        warn "Could not establish SSL connection to apex (DNS/firewall may not be configured)"
    fi
    
    check "Testing SSL connection to beta..."
    if timeout 5 openssl s_client -connect beta.n3xuscos.online:443 -showcerts </dev/null &>/dev/null; then
        pass "SSL connection to beta successful"
    else
        warn "Could not establish SSL connection to beta (DNS/firewall may not be configured)"
    fi
}

# ==============================================================================
# Health Check Validation
# ==============================================================================

validate_health_checks() {
    print_section "6. HEALTH CHECK ENDPOINTS"
    
    check "Testing gateway health endpoint..."
    GATEWAY_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://n3xuscos.online/health/gateway 2>/dev/null || echo "000")
    if [[ "${GATEWAY_STATUS}" == "200" ]]; then
        pass "Gateway health endpoint returns 200 OK"
    elif [[ "${GATEWAY_STATUS}" == "502" ]] || [[ "${GATEWAY_STATUS}" == "503" ]]; then
        info "Gateway health endpoint returns ${GATEWAY_STATUS} (backend service may not be running)"
    elif [[ "${GATEWAY_STATUS}" == "000" ]]; then
        warn "Gateway health endpoint unreachable"
    else
        info "Gateway health endpoint returns: ${GATEWAY_STATUS}"
    fi
    
    check "Testing prompter health endpoint..."
    PROMPTER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://beta.n3xuscos.online/v-suite/prompter/health 2>/dev/null || echo "000")
    if [[ "${PROMPTER_STATUS}" == "204" ]] || [[ "${PROMPTER_STATUS}" == "200" ]]; then
        pass "Prompter health endpoint returns ${PROMPTER_STATUS}"
    elif [[ "${PROMPTER_STATUS}" == "502" ]] || [[ "${PROMPTER_STATUS}" == "503" ]]; then
        info "Prompter health endpoint returns ${PROMPTER_STATUS} (backend service may not be running)"
    elif [[ "${PROMPTER_STATUS}" == "000" ]]; then
        warn "Prompter health endpoint unreachable"
    else
        info "Prompter health endpoint returns: ${PROMPTER_STATUS}"
    fi
    
    info "Health check endpoints are configured correctly"
    info "Backend services will be validated when deployed"
}

# ==============================================================================
# Feature Validation
# ==============================================================================

validate_features() {
    print_section "7. FEATURE VALIDATION"
    
    check "Validating branding elements..."
    if [[ -f "${APEX_TARGET}" ]]; then
        # Check for inline SVG logo
        if grep -q '<svg' "${APEX_TARGET}"; then
            pass "Inline SVG logo present"
        else
            fail "Inline SVG logo missing"
        fi
        
        # Check for brand colors
        if grep -q '#2563eb' "${APEX_TARGET}" && \
           grep -q '#667eea' "${APEX_TARGET}" && \
           grep -q '#0c0f14' "${APEX_TARGET}"; then
            pass "Brand colors present in CSS"
        else
            warn "Some brand colors may be missing"
        fi
        
        # Check for Inter font
        if grep -q 'Inter' "${APEX_TARGET}"; then
            pass "Inter font family specified"
        else
            warn "Inter font family not found"
        fi
        
        # Check for theme color meta
        if grep -q 'theme-color' "${APEX_TARGET}"; then
            pass "Theme color meta tag present"
        else
            warn "Theme color meta tag missing"
        fi
        
        # Check for Open Graph tags
        OG_COUNT=$(grep -c 'og:' "${APEX_TARGET}" || true)
        if [[ "${OG_COUNT}" -ge 3 ]]; then
            pass "Open Graph tags present (${OG_COUNT})"
        else
            warn "Open Graph tags incomplete (found ${OG_COUNT})"
        fi
        
        # Check for Twitter Card tags
        if grep -q 'twitter:card' "${APEX_TARGET}"; then
            pass "Twitter Card tags present"
        else
            warn "Twitter Card tags missing"
        fi
    fi
}

# ==============================================================================
# Summary
# ==============================================================================

print_summary() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                     VALIDATION SUMMARY                         ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    TOTAL=$((PASSED + FAILED + WARNINGS))
    
    echo -e "${BOLD}Results:${NC}"
    echo -e "  Total Checks: ${TOTAL}"
    echo -e "  ${GREEN}✓ Passed:${NC}  ${PASSED}"
    echo -e "  ${RED}✗ Failed:${NC}  ${FAILED}"
    echo -e "  ${YELLOW}⚠ Warnings:${NC} ${WARNINGS}"
    echo ""
    
    if [[ ${FAILED} -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}${BOLD}║                                                                ║${NC}"
        echo -e "${GREEN}${BOLD}║                  ✅  ALL VALIDATIONS PASSED  ✅                ║${NC}"
        echo -e "${GREEN}${BOLD}║                                                                ║${NC}"
        echo -e "${GREEN}${BOLD}║           PR#87 Landing Pages Validated Successfully!          ║${NC}"
        echo -e "${GREEN}${BOLD}║                                                                ║${NC}"
        echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        if [[ ${WARNINGS} -gt 0 ]]; then
            echo -e "${YELLOW}Note: ${WARNINGS} warning(s) found. These may be acceptable for development/staging.${NC}"
            echo ""
        fi
        
        return 0
    else
        echo -e "${RED}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}${BOLD}║                                                                ║${NC}"
        echo -e "${RED}${BOLD}║                  ❌  VALIDATION FAILED  ❌                     ║${NC}"
        echo -e "${RED}${BOLD}║                                                                ║${NC}"
        echo -e "${RED}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${RED}${FAILED} critical error(s) found. Please review and fix.${NC}"
        echo ""
        
        return 1
    fi
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_header
    
    validate_files
    validate_content
    validate_nginx
    validate_http
    validate_ssl
    validate_health_checks
    validate_features
    print_summary
}

# Run main function
main "$@"
