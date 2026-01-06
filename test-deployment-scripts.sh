#!/bin/bash
# ==============================================================================
# Test Script for Deployment Scripts Path Detection
# ==============================================================================
# Purpose: Verify that deployment scripts correctly detect their paths
# Usage: bash test-deployment-scripts.sh
# ==============================================================================

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PASSED=0
FAILED=0

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     NEXUS COS - DEPLOYMENT SCRIPTS TEST                        ║${NC}"
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

print_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Test 1: Check script syntax
test_script_syntax() {
    print_section "1. SCRIPT SYNTAX CHECK"
    
    print_test "pf-master-deployment.sh syntax"
    if bash -n pf-master-deployment.sh 2>/dev/null; then
        print_pass "pf-master-deployment.sh has valid syntax"
    else
        print_fail "pf-master-deployment.sh has syntax errors"
    fi
    
    print_test "pf-ip-domain-unification.sh syntax"
    if bash -n pf-ip-domain-unification.sh 2>/dev/null; then
        print_pass "pf-ip-domain-unification.sh has valid syntax"
    else
        print_fail "pf-ip-domain-unification.sh has syntax errors"
    fi
    
    print_test "validate-ip-domain-routing.sh syntax"
    if bash -n validate-ip-domain-routing.sh 2>/dev/null; then
        print_pass "validate-ip-domain-routing.sh has valid syntax"
    else
        print_fail "validate-ip-domain-routing.sh has syntax errors"
    fi
}

# Test 2: Check path detection in pf-master-deployment.sh
test_master_path_detection() {
    print_section "2. PF-MASTER-DEPLOYMENT PATH DETECTION"
    
    print_test "Dynamic SCRIPT_DIR usage"
    if grep -q 'SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE\[0\]}")" && pwd)"' pf-master-deployment.sh; then
        print_pass "SCRIPT_DIR uses dynamic detection"
    else
        print_fail "SCRIPT_DIR not using dynamic detection"
    fi
    
    print_test "REPO_ROOT uses SCRIPT_DIR default"
    if grep -q 'REPO_ROOT="\${REPO_ROOT:-\$SCRIPT_DIR}"' pf-master-deployment.sh; then
        print_pass "REPO_ROOT defaults to SCRIPT_DIR and supports override"
    else
        print_fail "REPO_ROOT not properly configured"
    fi
}

# Test 3: Check path detection in pf-ip-domain-unification.sh
test_unification_path_detection() {
    print_section "3. PF-IP-DOMAIN-UNIFICATION PATH DETECTION"
    
    print_test "DOMAIN supports override"
    if grep -q 'DOMAIN="\${DOMAIN:-n3xuscos.online}"' pf-ip-domain-unification.sh; then
        print_pass "DOMAIN supports environment variable override"
    else
        print_fail "DOMAIN override not configured"
    fi
    
    print_test "SERVER_IP supports override"
    if grep -q 'SERVER_IP="\${SERVER_IP:-74.208.155.161}"' pf-ip-domain-unification.sh; then
        print_pass "SERVER_IP supports environment variable override"
    else
        print_fail "SERVER_IP override not configured"
    fi
    
    print_test "Dynamic SCRIPT_DIR and REPO_ROOT"
    if grep -q 'SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE\[0\]}")" && pwd)"' pf-ip-domain-unification.sh; then
        print_pass "SCRIPT_DIR uses dynamic detection"
    else
        print_fail "SCRIPT_DIR not using dynamic detection"
    fi
    
    if grep -q 'REPO_ROOT="\${REPO_ROOT:-\$SCRIPT_DIR}"' pf-ip-domain-unification.sh; then
        print_pass "REPO_ROOT defaults to SCRIPT_DIR"
    else
        print_fail "REPO_ROOT not properly configured"
    fi
}

# Test 4: Check path detection in validate-ip-domain-routing.sh
test_validation_path_detection() {
    print_section "4. VALIDATE-IP-DOMAIN-ROUTING PATH DETECTION"
    
    print_test "DOMAIN supports override"
    if grep -q 'DOMAIN="\${DOMAIN:-n3xuscos.online}"' validate-ip-domain-routing.sh; then
        print_pass "DOMAIN supports environment variable override"
    else
        print_fail "DOMAIN override not configured"
    fi
    
    print_test "SERVER_IP supports override"
    if grep -q 'SERVER_IP="\${SERVER_IP:-74.208.155.161}"' validate-ip-domain-routing.sh; then
        print_pass "SERVER_IP supports environment variable override"
    else
        print_fail "SERVER_IP override not configured"
    fi
    
    print_test "Dynamic SCRIPT_DIR and REPO_ROOT"
    if grep -q 'SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE\[0\]}")" && pwd)"' validate-ip-domain-routing.sh; then
        print_pass "SCRIPT_DIR uses dynamic detection"
    else
        print_fail "SCRIPT_DIR not using dynamic detection"
    fi
    
    if grep -q 'REPO_ROOT="\${REPO_ROOT:-\$SCRIPT_DIR}"' validate-ip-domain-routing.sh; then
        print_pass "REPO_ROOT defaults to SCRIPT_DIR"
    else
        print_fail "REPO_ROOT not properly configured"
    fi
    
    print_test "REPO_ROOT variable used instead of hardcoded path"
    if grep -q '\${REPO_ROOT}/.env' validate-ip-domain-routing.sh; then
        print_pass "Uses REPO_ROOT variable for .env path"
    else
        print_fail "Not using REPO_ROOT variable for .env path"
    fi
}

# Test 5: Check no hardcoded paths remain
test_no_hardcoded_paths() {
    print_section "5. HARDCODED PATH CHECK"
    
    print_test "pf-master-deployment.sh"
    if grep -q 'REPO_ROOT="/home/runner/work/nexus-cos/nexus-cos"' pf-master-deployment.sh 2>/dev/null; then
        print_fail "Found hardcoded REPO_ROOT path in pf-master-deployment.sh"
    else
        print_pass "No hardcoded REPO_ROOT paths found"
    fi
    
    print_test "pf-ip-domain-unification.sh"
    if grep -q 'REPO_ROOT="/home/runner/work/nexus-cos/nexus-cos"' pf-ip-domain-unification.sh 2>/dev/null; then
        print_fail "Found hardcoded REPO_ROOT path in pf-ip-domain-unification.sh"
    else
        print_pass "No hardcoded REPO_ROOT paths found"
    fi
    
    print_test "validate-ip-domain-routing.sh"
    if grep -q '"/home/runner/work/nexus-cos/nexus-cos/.env"' validate-ip-domain-routing.sh 2>/dev/null; then
        print_fail "Found hardcoded paths in validate-ip-domain-routing.sh"
    else
        print_pass "No hardcoded paths found"
    fi
}

# Print summary
print_summary() {
    print_section "TEST SUMMARY"
    
    TOTAL=$((PASSED + FAILED))
    
    echo -e "${CYAN}Tests Run:${NC} $TOTAL"
    echo -e "${GREEN}Passed:${NC} $PASSED"
    echo -e "${RED}Failed:${NC} $FAILED"
    echo ""
    
    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
        echo ""
        echo -e "${CYAN}The deployment scripts are ready for VPS deployment!${NC}"
        echo ""
        echo -e "Next steps:"
        echo -e "  1. Copy repository to /var/www/nexus-cos on VPS"
        echo -e "  2. Run: ${YELLOW}cd /var/www/nexus-cos${NC}"
        echo -e "  3. Run: ${YELLOW}sudo DOMAIN=n3xuscos.online bash pf-master-deployment.sh${NC}"
        return 0
    else
        echo -e "${RED}✗ SOME TESTS FAILED${NC}"
        echo ""
        echo -e "Please review the failures above before deployment."
        return 1
    fi
}

# Main execution
main() {
    print_header
    test_script_syntax
    test_master_path_detection
    test_unification_path_detection
    test_validation_path_detection
    test_no_hardcoded_paths
    print_summary
}

main "$@"
