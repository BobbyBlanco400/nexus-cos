#!/bin/bash
# Test script for pf-fix-nginx-headers-redirect.sh
# Validates script functionality without requiring root access

set +e  # Don't exit on errors, we want to run all tests

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_PATH="./scripts/pf-fix-nginx-headers-redirect.sh"
PASSED=0
FAILED=0

echo "Testing pf-fix-nginx-headers-redirect.sh"
echo "=========================================="
echo ""

# Test 1: Script file exists
echo -n "Test 1: Script file exists... "
if [[ -f "$SCRIPT_PATH" ]]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 2: Script is executable
echo -n "Test 2: Script is executable... "
if [[ -x "$SCRIPT_PATH" ]]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 3: Script has valid bash syntax
echo -n "Test 3: Script has valid bash syntax... "
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 4: Script contains security headers configuration
echo -n "Test 4: Contains all security headers... "
HEADERS_FOUND=0
while IFS= read -r header; do
    if grep -q "$header" "$SCRIPT_PATH"; then
        ((HEADERS_FOUND++))
    fi
done << EOF
Strict-Transport-Security
Content-Security-Policy
X-Content-Type-Options
X-Frame-Options
Referrer-Policy
EOF

if [[ $HEADERS_FOUND -eq 5 ]]; then
    echo -e "${GREEN}PASS${NC} (found all 5 headers)"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} (found only $HEADERS_FOUND of 5 headers)"
    ((FAILED++))
fi

# Test 5: Script contains conf.d inclusion logic
echo -n "Test 5: Contains conf.d inclusion logic... "
if grep -q "conf.d/.*\.conf" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 6: Script contains redirect fix logic
echo -n "Test 6: Contains redirect fix logic... "
if grep -q "return 301 https://" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 7: Script contains backtick removal logic
echo -n "Test 7: Contains backtick removal logic... "
if grep -q "sed -i 's/\`//g'" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 8: Script validates nginx config
echo -n "Test 8: Contains nginx validation... "
if grep -q "nginx -t" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 9: Script reloads nginx
echo -n "Test 9: Contains nginx reload... "
if grep -q "systemctl reload nginx\|service nginx reload" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 10: Script supports DOMAIN environment variable
echo -n "Test 10: Supports DOMAIN environment variable... "
if grep -q 'DOMAIN="${DOMAIN:-n3xuscos.online}"' "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 11: Script checks for root privileges
echo -n "Test 11: Checks for root privileges... "
if grep -q "EUID" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 12: Script creates backups before modifying files
echo -n "Test 12: Creates backups before modifications... "
if grep -q ".backup." "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 13: Script runs without root (should exit gracefully)
echo -n "Test 13: Exits gracefully when not run as root... "
OUTPUT=$(bash "$SCRIPT_PATH" 2>&1 || true)
if echo "$OUTPUT" | grep -q "must be run as root"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 14: Script contains verification logic
echo -n "Test 14: Contains result verification... "
if grep -q "verify_results" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Summary
echo ""
echo "=========================================="
echo "Test Results:"
echo "  Passed: ${PASSED}/14"
echo "  Failed: ${FAILED}/14"
echo "=========================================="

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
