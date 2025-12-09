#!/bin/bash
# ==============================================================================
# Additional Tests for Problem Statement Requirements
# ==============================================================================
# Purpose: Verify all requirements from the problem statement are met
# ==============================================================================

set +e  # Don't exit on errors, we want to run all tests

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0

echo "======================================"
echo "Testing Problem Statement Requirements"
echo "======================================"
echo ""

# Test 1: Verify CSP value exactly matches requirement
echo -n "Test 1: CSP matches exact requirement... "
REQUIRED_CSP="default-src 'self' https://nexuscos.online; img-src 'self' data: blob: https://nexuscos.online; script-src 'self' 'unsafe-inline' https://nexuscos.online; style-src 'self' 'unsafe-inline' https://nexuscos.online; connect-src 'self' https://nexuscos.online https://nexuscos.online/streaming wss://nexuscos.online ws://nexuscos.online;"

if grep -q "$REQUIRED_CSP" scripts/pf-fix-nginx-headers-redirect.sh; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Expected CSP not found"
    ((FAILED++))
fi

# Test 2: Verify no backticks in CSP
echo -n "Test 2: CSP has no backticks... "
CSP_LINE=$(grep "Content-Security-Policy" scripts/pf-fix-nginx-headers-redirect.sh | grep "add_header")
if echo "$CSP_LINE" | grep -q '`'; then
    echo -e "${RED}FAIL${NC}"
    echo "Found backticks in CSP"
    ((FAILED++))
else
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
fi

# Test 3: Verify redirect uses $host (not hardcoded domain)
echo -n "Test 3: Redirect uses \$host variable... "
if grep -q 'https://\$host\$request_uri' scripts/pf-fix-nginx-headers-redirect.sh; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Redirect does not use \$host"
    ((FAILED++))
fi

# Test 4: Verify all required headers are present
echo -n "Test 4: All 5 required headers present... "
REQUIRED_HEADERS=(
    "Strict-Transport-Security"
    "X-Content-Type-Options"
    "X-Frame-Options"
    "Referrer-Policy"
    "Content-Security-Policy"
)

ALL_FOUND=true
for header in "${REQUIRED_HEADERS[@]}"; do
    if ! grep -q "add_header $header" scripts/pf-fix-nginx-headers-redirect.sh; then
        ALL_FOUND=false
        echo -e "${RED}FAIL${NC}"
        echo "Missing header: $header"
        ((FAILED++))
        break
    fi
done

if [ "$ALL_FOUND" = true ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
fi

# Test 5: Verify conf.d include is ensured
echo -n "Test 5: Script ensures conf.d inclusion... "
if grep -q "include.*conf.d.*\.conf" scripts/pf-fix-nginx-headers-redirect.sh; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 6: Verify backtick removal logic
echo -n "Test 6: Script removes backticks... "
if grep -q "sed -i 's/\`//g'" scripts/pf-fix-nginx-headers-redirect.sh; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 7: Verify VPS deploy script exists
echo -n "Test 7: vps-deploy.sh exists... "
if [ -f "scripts/vps-deploy.sh" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 8: Verify VPS deploy integrates hardening script
echo -n "Test 8: vps-deploy.sh integrates hardening... "
if grep -q "pf-fix-nginx-headers-redirect.sh" scripts/vps-deploy.sh; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 9: Verify VPS deploy script uploads hardening script
echo -n "Test 9: vps-deploy.sh uploads hardening script... "
if grep -q "scp.*pf-fix-nginx-headers-redirect.sh" scripts/vps-deploy.sh; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 10: Verify VPS deploy executes hardening with DOMAIN
echo -n "Test 10: vps-deploy.sh executes with DOMAIN... "
if grep -q "DOMAIN=.*pf-fix-nginx-headers-redirect.sh" scripts/vps-deploy.sh; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 11: Verify VPS deploy checks backend port
echo -n "Test 11: vps-deploy.sh checks port 3001... "
if grep -q "3001" scripts/vps-deploy.sh; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 12: Verify documentation exists
echo -n "Test 12: DEPLOYMENT_INSTRUCTIONS.md exists... "
if [ -f "DEPLOYMENT_INSTRUCTIONS.md" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 13: Verify documentation includes validation commands
echo -n "Test 13: Documentation includes validation... "
if grep -q "curl -fsSI https://nexuscos.online" DEPLOYMENT_INSTRUCTIONS.md; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 14: Verify scripts have correct permissions
echo -n "Test 14: Scripts are executable... "
if [ -x "scripts/pf-fix-nginx-headers-redirect.sh" ] && [ -x "scripts/vps-deploy.sh" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Summary
echo ""
echo "======================================"
echo "Test Results:"
echo "  Passed: ${PASSED}/14"
echo "  Failed: ${FAILED}/14"
echo "======================================"

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}All problem statement requirements met!${NC}"
    echo ""
    echo "✅ Acceptance Criteria:"
    echo "  ✓ Security headers configured (HSTS, CSP, X-Content-Type-Options, X-Frame-Options, Referrer-Policy)"
    echo "  ✓ CSP has no backticks or escape codes"
    echo "  ✓ HTTP→HTTPS redirect uses \$host variable"
    echo "  ✓ Backtick removal implemented"
    echo "  ✓ conf.d inclusion ensured"
    echo "  ✓ VPS deployment script created"
    echo "  ✓ Hardening integrated into deployment"
    echo "  ✓ Backend port ownership check included"
    echo "  ✓ Comprehensive documentation provided"
    echo ""
    exit 0
else
    echo -e "${RED}Some requirements not met.${NC}"
    exit 1
fi
