#!/bin/bash
# ==============================================================================
# Nexus COS — VPS Endpoint Restoration Verification Script
# ==============================================================================
# Purpose: Verify that all restoration objectives are met
# ==============================================================================

# Note: Not using 'set -e' to allow all tests to run even if some fail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

DOMAIN="${DOMAIN:-nexuscos.online}"
PASSED=0
FAILED=0

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  NEXUS COS - VPS ENDPOINT RESTORATION VERIFICATION${NC}"
    echo -e "${CYAN}  Domain: $DOMAIN${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}─────────────────────────────────────────────────────────────────${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}─────────────────────────────────────────────────────────────────${NC}"
}

print_test() {
    echo -e "${CYAN}Testing: $1${NC}"
}

print_pass() {
    echo -e "${GREEN}✓ PASS: $1${NC}"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}✗ FAIL: $1${NC}"
    ((FAILED++))
}

print_warn() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}"
}

# Display header
print_header

# Test 1: Check deployment manifest exists and has correct legal_status
print_section "Test 1: Deployment Manifest Validation"
print_test "Checking deployment-manifest (1).json exists"

if [ -f "deployment-manifest (1).json" ]; then
    print_pass "Deployment manifest file exists"
    
    # Check for legal_status
    if grep -q '"legal_status": "CERTIFIED_PRODUCTION_DEPLOYMENT"' "deployment-manifest (1).json"; then
        print_pass "legal_status is CERTIFIED_PRODUCTION_DEPLOYMENT"
    else
        print_fail "legal_status is not CERTIFIED_PRODUCTION_DEPLOYMENT"
    fi
    
    # Check JSON validity
    if python3 -m json.tool "deployment-manifest (1).json" > /dev/null 2>&1; then
        print_pass "JSON syntax is valid"
    else
        print_fail "JSON syntax is invalid"
    fi
else
    print_fail "Deployment manifest file not found"
fi

# Test 2: Check restoration scripts exist
print_section "Test 2: Script Files Validation"

scripts=("restore-vps-endpoints.ps1" "restore-vps-endpoints.sh" "ssl-auto-pair.sh" "base-path-200-blocks.sh")
for script in "${scripts[@]}"; do
    print_test "Checking $script exists"
    if [ -f "$script" ]; then
        print_pass "$script exists"
        
        # Check if bash scripts are executable
        if [[ "$script" == *.sh ]]; then
            if [ -x "$script" ]; then
                print_pass "$script is executable"
            else
                print_fail "$script is not executable"
            fi
            
            # Validate bash syntax
            if bash -n "$script" 2>/dev/null; then
                print_pass "$script has valid bash syntax"
            else
                print_fail "$script has invalid bash syntax"
            fi
        fi
    else
        print_fail "$script not found"
    fi
done

# Test 3: Check documentation exists
print_section "Test 3: Documentation Validation"

docs=("VPS_ENDPOINT_RESTORATION_GUIDE.md" "VPS_RESTORATION_QUICK_REFERENCE.md")
for doc in "${docs[@]}"; do
    print_test "Checking $doc exists"
    if [ -f "$doc" ]; then
        print_pass "$doc exists"
        
        # Check file is not empty
        if [ -s "$doc" ]; then
            print_pass "$doc is not empty"
        else
            print_fail "$doc is empty"
        fi
    else
        print_fail "$doc not found"
    fi
done

# Test 4: Verify script content matches requirements
print_section "Test 4: Script Content Validation"

# Check restore-vps-endpoints.sh contains required elements
print_test "Checking restore-vps-endpoints.sh for required functionality"

required_elements=(
    "location = /api/"
    "location = /streaming/"
    "location = /"
    "return 301 /streaming/"
    "proxy_set_header"
    "plesk sbin httpdmng"
    "nginx -t"
    "systemctl restart nginx"
    "curl.*socket.io.*EIO=4"
)

all_found=true
for element in "${required_elements[@]}"; do
    if grep -q "$element" restore-vps-endpoints.sh; then
        echo -e "  ${GREEN}✓${NC} Found: $element"
    else
        echo -e "  ${RED}✗${NC} Missing: $element"
        all_found=false
    fi
done

if $all_found; then
    print_pass "All required elements found in restore-vps-endpoints.sh"
else
    print_fail "Some required elements missing from restore-vps-endpoints.sh"
fi

# Test 5: Verify SSL auto-pair script
print_section "Test 5: SSL Auto-Pair Script Validation"

print_test "Checking ssl-auto-pair.sh for SSL functionality"

ssl_elements=(
    "openssl x509 -noout -modulus"
    "openssl rsa -noout -modulus"
    "ssl_certificate"
    "ssl_certificate_key"
    "/opt/psa/var/certificates/"
)

ssl_found=true
for element in "${ssl_elements[@]}"; do
    if grep -q "$element" ssl-auto-pair.sh; then
        echo -e "  ${GREEN}✓${NC} Found: $element"
    else
        echo -e "  ${RED}✗${NC} Missing: $element"
        ssl_found=false
    fi
done

if $ssl_found; then
    print_pass "All required SSL elements found in ssl-auto-pair.sh"
else
    print_fail "Some required SSL elements missing from ssl-auto-pair.sh"
fi

# Test 6: Verify base path blocks script
print_section "Test 6: Base Path Blocks Script Validation"

print_test "Checking base-path-200-blocks.sh for location blocks"

bp_elements=(
    "location = /api/"
    "location = /streaming/"
    "return 200"
    "add_header Content-Type text/plain"
)

bp_found=true
for element in "${bp_elements[@]}"; do
    if grep -q "$element" base-path-200-blocks.sh; then
        echo -e "  ${GREEN}✓${NC} Found: $element"
    else
        echo -e "  ${RED}✗${NC} Missing: $element"
        bp_found=false
    fi
done

if $bp_found; then
    print_pass "All required base path elements found in base-path-200-blocks.sh"
else
    print_fail "Some required base path elements missing from base-path-200-blocks.sh"
fi

# Test 7: Check deployment manifest endpoints
print_section "Test 7: Deployment Manifest Endpoints Validation"

print_test "Checking deployment manifest for required endpoints"

manifest_endpoints=(
    "https://nexuscos.online/"
    "https://nexuscos.online/api/"
    "https://nexuscos.online/streaming/"
    "socket.io/?EIO=4&transport=polling"
)

manifest_found=true
for endpoint in "${manifest_endpoints[@]}"; do
    if grep -q "$endpoint" "deployment-manifest (1).json"; then
        echo -e "  ${GREEN}✓${NC} Found endpoint: $endpoint"
    else
        echo -e "  ${RED}✗${NC} Missing endpoint: $endpoint"
        manifest_found=false
    fi
done

if $manifest_found; then
    print_pass "All required endpoints found in deployment manifest"
else
    print_fail "Some required endpoints missing from deployment manifest"
fi

# Test 8: Verify idempotent design
print_section "Test 8: Idempotent Design Validation"

print_test "Checking for backup mechanisms"
if grep -qi "backup\|\.bak" restore-vps-endpoints.sh && grep -qi "backup\|\.bak" ssl-auto-pair.sh && grep -qi "backup\|\.bak" base-path-200-blocks.sh; then
    print_pass "Backup mechanisms found in all scripts"
else
    print_fail "Backup mechanisms not found in all scripts"
fi

print_test "Checking for conditional logic (if exists checks)"
if grep -q "if \[ -f" restore-vps-endpoints.sh && grep -q "grep -q" restore-vps-endpoints.sh; then
    print_pass "Conditional checks found in scripts"
else
    print_fail "Conditional checks not found in scripts"
fi

# Test 9: Verify error handling
print_section "Test 9: Error Handling Validation"

print_test "Checking for error handling (set -e, || continue, 2>/dev/null)"
error_handling_found=true

if grep -q "set -e" restore-vps-endpoints.sh ssl-auto-pair.sh base-path-200-blocks.sh; then
    echo -e "  ${GREEN}✓${NC} Found 'set -e' for error handling"
else
    echo -e "  ${RED}✗${NC} Missing 'set -e' for error handling"
    error_handling_found=false
fi

if grep -q "2>/dev/null\||| true\||| echo" restore-vps-endpoints.sh; then
    echo -e "  ${GREEN}✓${NC} Found non-fatal error handling"
else
    echo -e "  ${RED}✗${NC} Missing non-fatal error handling"
    error_handling_found=false
fi

if $error_handling_found; then
    print_pass "Error handling mechanisms found"
else
    print_fail "Error handling mechanisms incomplete"
fi

# Summary
print_section "Verification Summary"

total=$((PASSED + FAILED))
pass_rate=$((PASSED * 100 / total))

echo ""
echo -e "${CYAN}Total Tests:${NC} $total"
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo -e "${CYAN}Pass Rate:${NC} $pass_rate%"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ ALL VERIFICATION TESTS PASSED${NC}"
    echo -e "${GREEN}  VPS Endpoint Restoration is ready for deployment!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}  ✗ SOME VERIFICATION TESTS FAILED${NC}"
    echo -e "${RED}  Please review and fix the issues above.${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    exit 1
fi
