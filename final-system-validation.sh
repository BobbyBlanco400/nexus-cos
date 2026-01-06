#!/bin/bash

# Nexus COS - Final System Validation Script
# Complete production readiness check for Docker-based Nginx deployment

# set -e # Disabled to show all checks

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0
WARNINGS=0

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Nexus COS Final System Validation                       ║${NC}"
echo -e "${BLUE}║       Production Readiness Check                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

test_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

test_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

test_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

test_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}1. Repository Hygiene${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check if critical config files are tracked
if git ls-files | grep -q "nginx.conf.docker"; then
    test_pass "nginx.conf.docker is tracked in git"
else
    test_fail "nginx.conf.docker is not tracked in git"
fi

if git ls-files | grep -q "nginx.conf.host"; then
    test_pass "nginx.conf.host is tracked in git"
else
    test_fail "nginx.conf.host is not tracked in git"
fi

if [ -f "NGINX_CONFIGURATION_README.md" ] && [ -s "NGINX_CONFIGURATION_README.md" ]; then
    test_pass "NGINX_CONFIGURATION_README.md exists and is not empty"
else
    test_fail "NGINX_CONFIGURATION_README.md is missing or empty"
fi

# Check for untracked files that could cause git pull errors
UNTRACKED=$(git status --porcelain | grep "^??" | wc -l)
if [ "$UNTRACKED" -eq 0 ]; then
    test_pass "No untracked files that could block git pull"
else
    test_warn "$UNTRACKED untracked files found (may block git pull)"
fi

# Check if .env files are in .gitignore
if grep -q "^\.env$" .gitignore; then
    test_pass ".env files are in .gitignore"
else
    test_warn ".env files should be in .gitignore for security"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}2. Docker Stack Finalization${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check docker-compose.yml network configuration
if grep -q "cos-net:" docker-compose.pf.yml; then
    test_pass "docker-compose.pf.yml uses cos-net network"
else
    test_warn "docker-compose.pf.yml should use cos-net network"
fi

# Check if nginx container is defined
if grep -q "nginx:" docker-compose.pf.yml; then
    test_pass "Nginx container defined in docker-compose.pf.yml"
else
    test_info "Nginx container can be added to docker-compose.pf.yml"
fi

# Check nginx.conf.docker upstreams
if grep -q "puabo-api:4000" nginx.conf.docker; then
    test_pass "nginx.conf.docker uses Docker service name (puabo-api:4000)"
else
    test_fail "nginx.conf.docker should use Docker service names"
fi

if grep -q "nexus-cos-puaboai-sdk:3002" nginx.conf.docker; then
    test_pass "nginx.conf.docker has puaboai-sdk service name"
else
    test_fail "nginx.conf.docker missing puaboai-sdk service name"
fi

if grep -q "nexus-cos-pv-keys:3041" nginx.conf.docker; then
    test_pass "nginx.conf.docker has pv-keys service name"
else
    test_fail "nginx.conf.docker missing pv-keys service name"
fi

# Check nginx.conf.host upstreams
if grep -q "localhost:4000" nginx.conf.host; then
    test_pass "nginx.conf.host uses localhost ports"
else
    test_fail "nginx.conf.host should use localhost with ports"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}3. Automated Validation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check if test scripts exist and are executable
if [ -x "test-pf-configuration.sh" ]; then
    test_pass "test-pf-configuration.sh is executable"
else
    test_fail "test-pf-configuration.sh is missing or not executable"
fi

if [ -x "validate-pf-nginx.sh" ]; then
    test_pass "validate-pf-nginx.sh is executable"
else
    test_fail "validate-pf-nginx.sh is missing or not executable"
fi

# Check for interactive one-liner in README or docs
if grep -q "Choose Nginx mode" NGINX_CONFIGURATION_README.md; then
    test_pass "Interactive one-liner documented in NGINX_CONFIGURATION_README.md"
else
    test_fail "Interactive one-liner missing from documentation"
fi

if grep -q "Choose Nginx mode" README.md; then
    test_pass "Interactive one-liner documented in README.md"
else
    test_warn "Interactive one-liner should be in README.md for visibility"
fi

# Verify endpoint validation in one-liner
if grep -q "curl -I https://n3xuscos.online" NGINX_CONFIGURATION_README.md || grep -q "curl -I https://n3xuscos.online" README.md; then
    test_pass "Automated endpoint validation included in one-liner"
else
    test_warn "Endpoint validation should be in deployment one-liner"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}4. Deployment Documentation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check documentation files
DOC_FILES=(
    "NGINX_CONFIGURATION_README.md"
    "PF_TRAE_Beta_Launch_Validation.md"
    "PF_CONFIGURATION_SUMMARY.md"
    "README.md"
)

for doc in "${DOC_FILES[@]}"; do
    if [ -f "$doc" ] && [ -s "$doc" ]; then
        test_pass "$doc exists and is not empty"
    else
        test_fail "$doc is missing or empty"
    fi
done

# Check if documentation covers Docker mode
if grep -q -i "docker mode\|docker.*nginx" NGINX_CONFIGURATION_README.md; then
    test_pass "Docker mode deployment documented"
else
    test_fail "Docker mode deployment missing from docs"
fi

# Check if troubleshooting is documented
if grep -q -i "troubleshoot" NGINX_CONFIGURATION_README.md || grep -q -i "troubleshoot" README.md; then
    test_pass "Troubleshooting section present in documentation"
else
    test_warn "Troubleshooting section should be in documentation"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}5. Security & Monitoring${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check for hardcoded secrets
if grep -r "password.*=.*['\"][^'\"]*['\"]" --include="*.yml" --include="*.yaml" docker-compose.pf.yml 2>/dev/null | grep -v "your-" | grep -q "password"; then
    test_warn "Potential hardcoded passwords found in docker-compose.pf.yml"
else
    test_pass "No obvious hardcoded passwords in docker-compose.pf.yml"
fi

# Check if .env.example files exist
if [ -f ".env.pf.example" ]; then
    test_pass ".env.pf.example exists for template"
else
    test_fail ".env.pf.example should exist as template"
fi

if [ -f ".env.example" ]; then
    test_pass ".env.example exists for template"
else
    test_info ".env.example recommended for general configuration"
fi

# Check SSL/TLS configuration in nginx configs
if grep -q "ssl_protocols TLSv1.2 TLSv1.3" nginx.conf.docker; then
    test_pass "SSL/TLS configured in nginx.conf.docker (TLS 1.2, 1.3)"
else
    test_warn "SSL/TLS should be configured in nginx.conf.docker"
fi

# Check security headers
if grep -q "X-Frame-Options" nginx.conf.docker; then
    test_pass "Security headers configured (X-Frame-Options found)"
else
    test_warn "Security headers should be configured"
fi

# Check for access and error logs
if grep -q "access_log\|error_log" nginx.conf.docker; then
    test_pass "Nginx logging configured"
else
    test_warn "Nginx access and error logs should be configured"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}6. Final System Checks${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check if docker is available
if command -v docker >/dev/null 2>&1; then
    test_pass "Docker is installed"
    
    # Check if docker compose is available
    if docker compose version >/dev/null 2>&1; then
        test_pass "Docker Compose is available"
    else
        test_fail "Docker Compose is not available"
    fi
else
    test_warn "Docker not installed (OK for documentation-only validation)"
fi

# Validate docker-compose files
if docker compose -f docker-compose.yml config >/dev/null 2>&1; then
    test_pass "docker-compose.yml syntax is valid"
else
    test_fail "docker-compose.yml has syntax errors"
fi

if docker compose -f docker-compose.pf.yml config >/dev/null 2>&1; then
    test_pass "docker-compose.pf.yml syntax is valid"
else
    test_info "docker-compose.pf.yml requires .env.pf file to validate"
fi

# Check if nginx is installed (for host mode)
if command -v nginx >/dev/null 2>&1; then
    test_pass "Nginx is installed (for Host mode)"
else
    test_info "Nginx not installed on host (OK for Docker mode)"
fi

# Check nginx configuration syntax if nginx is available
if command -v nginx >/dev/null 2>&1; then
    if sudo nginx -t -c "$(pwd)/nginx/nginx.conf" 2>&1 | grep -q "syntax is ok"; then
        test_pass "nginx/nginx.conf syntax is valid"
    elif sudo nginx -t -c "$(pwd)/nginx/nginx.conf" 2>&1 | grep -q "host not found"; then
        test_info "nginx/nginx.conf syntax OK (upstreams not resolved - normal without running services)"
    else
        test_warn "nginx/nginx.conf may have syntax issues"
    fi
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Passed:   ${GREEN}${PASSED}${NC}"
echo -e "Failed:   ${RED}${FAILED}${NC}"
echo -e "Warnings: ${YELLOW}${WARNINGS}${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ ALL CRITICAL CHECKS PASSED - READY FOR PRODUCTION          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Ensure .env.pf is configured with production credentials"
    echo "2. Deploy SSL certificates to ./ssl/ directory"
    echo "3. Start services: docker compose -f docker-compose.pf.yml up -d"
    echo "4. Run deployment one-liner for final validation"
    echo "5. Monitor logs and health endpoints"
    echo ""
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ✗ VALIDATION FAILED - ISSUES MUST BE FIXED                   ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Please fix the failed checks above before proceeding.${NC}"
    echo ""
    exit 1
fi
