#!/bin/bash

# Complete Verification Suite
# Runs all tests to verify full system functionality

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║     NEXUS COS - COMPLETE VERIFICATION SUITE                  ║
║     Running all tests to verify 100% functionality           ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

REPO_ROOT="/home/runner/work/nexus-cos/nexus-cos"
SUITE_PASSED=0
SUITE_FAILED=0

run_test_suite() {
    local suite_name="$1"
    local test_script="$2"
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Running: $suite_name${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    
    if [ -f "$test_script" ]; then
        if bash "$test_script"; then
            echo -e "${GREEN}✓ $suite_name PASSED${NC}"
            ((SUITE_PASSED++))
        else
            echo -e "${RED}✗ $suite_name FAILED${NC}"
            ((SUITE_FAILED++))
        fi
    else
        echo -e "${YELLOW}⚠ Test script not found: $test_script${NC}"
        ((SUITE_FAILED++))
    fi
}

# Run all test suites
run_test_suite "Handshake & Revenue Tests" "$REPO_ROOT/tests/handshake/test-handshake.sh"
run_test_suite "IMVU Isolation Tests" "$REPO_ROOT/tests/isolation/test-isolation.sh"
run_test_suite "Exit Portability Tests" "$REPO_ROOT/tests/exit/test-exit.sh"
run_test_suite "Hostile Actor Tests" "$REPO_ROOT/tests/hostile-admin/test-hostile.sh"

# Run system health check
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Running: System Health Check${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"

if bash "$REPO_ROOT/tools/system-health.sh"; then
    echo -e "${GREEN}✓ System Health Check PASSED${NC}"
    ((SUITE_PASSED++))
else
    echo -e "${RED}✗ System Health Check FAILED${NC}"
    ((SUITE_FAILED++))
fi

# Final Summary
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}VERIFICATION SUITE SUMMARY${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
TOTAL=$((SUITE_PASSED + SUITE_FAILED))
echo -e "Total Test Suites: $TOTAL"
echo -e "${GREEN}Passed: $SUITE_PASSED${NC}"
echo -e "${RED}Failed: $SUITE_FAILED${NC}"
echo ""

if [ $SUITE_FAILED -eq 0 ]; then
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                       ║${NC}"
    echo -e "${GREEN}║  ✅ ALL TESTS PASSED - SYSTEM 100% OPERATIONAL       ║${NC}"
    echo -e "${GREEN}║                                                       ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}The Nexus COS platform is fully verified and ready for:${NC}"
    echo -e "  • Constitutional enforcement (55-45-17 + 80/20)"
    echo -e "  • NN-5G browser-native operations"
    echo -e "  • Complete IMVU lifecycle"
    echo -e "  • Mini-platform integration"
    echo -e "  • Sovereign infrastructure operations"
    echo ""
    exit 0
else
    echo -e "${RED}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                       ║${NC}"
    echo -e "${RED}║  ❌ VERIFICATION FAILED                               ║${NC}"
    echo -e "${RED}║                                                       ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}Please review failed tests and fix issues before deployment.${NC}"
    echo ""
    exit 1
fi
