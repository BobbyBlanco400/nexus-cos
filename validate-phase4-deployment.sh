#!/bin/bash
################################################################################
# NEXUS COS - PHASE 4 DEPLOYMENT VALIDATION TEST
# Purpose: Validate deployment script without requiring sudo
################################################################################

set -uo pipefail

echo "======================================================================"
echo "Phase 4 Deployment Script Validation"
echo "======================================================================"
echo ""

# Colors
readonly C_GREEN='\033[0;32m'
readonly C_RED='\033[0;31m'
readonly C_YELLOW='\033[1;33m'
readonly C_NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

test_pass() {
    echo -e "${C_GREEN}✓${C_NC} $1"
    ((TESTS_PASSED++))
}

test_fail() {
    echo -e "${C_RED}✗${C_NC} $1"
    ((TESTS_FAILED++))
}

echo "1. Checking deployment script..."
if [ -f "./deploy-phase-4-full-launch.sh" ]; then
    test_pass "Deployment script exists"
else
    test_fail "Deployment script not found"
fi

echo ""
echo "2. Checking script permissions..."
if [ -x "./deploy-phase-4-full-launch.sh" ]; then
    test_pass "Deployment script is executable"
else
    test_fail "Deployment script is not executable"
fi

echo ""
echo "3. Checking script syntax..."
if bash -n ./deploy-phase-4-full-launch.sh 2>&1; then
    test_pass "Script syntax is valid"
else
    test_fail "Script syntax has errors"
fi

echo ""
echo "4. Checking documentation..."
if [ -f "./PHASE_4_DEPLOYMENT_GUIDE.md" ]; then
    test_pass "Deployment guide exists"
else
    test_fail "Deployment guide not found"
fi

if [ -f "./PHASE_4_QUICK_REFERENCE.md" ]; then
    test_pass "Quick reference exists"
else
    test_fail "Quick reference not found"
fi

echo ""
echo "5. Checking Phase 3 configuration..."
if [ -f "./pfs/marketplace-phase3.yaml" ]; then
    test_pass "Phase 3 marketplace config exists"
else
    test_fail "Phase 3 marketplace config not found"
fi

echo ""
echo "6. Checking Phase 4 configuration..."
if [ -f "./pfs/global-launch.yaml" ]; then
    test_pass "Phase 4 global launch config exists"
else
    test_fail "Phase 4 global launch config not found"
fi

if [ -f "./pfs/founder-public-transition.yaml" ]; then
    test_pass "Founder-public transition config exists"
else
    test_fail "Founder-public transition config not found"
fi

echo ""
echo "7. Checking script structure..."

# Check for key functions
if grep -q "run_all_prechecks" ./deploy-phase-4-full-launch.sh; then
    test_pass "Precheck function found"
else
    test_fail "Precheck function not found"
fi

if grep -q "generate_rollback_script" ./deploy-phase-4-full-launch.sh; then
    test_pass "Rollback generation function found"
else
    test_fail "Rollback generation function not found"
fi

if grep -q "activate_phase3_marketplace" ./deploy-phase-4-full-launch.sh; then
    test_pass "Phase 3 activation function found"
else
    test_fail "Phase 3 activation function not found"
fi

if grep -q "activate_phase4_public_launch" ./deploy-phase-4-full-launch.sh; then
    test_pass "Phase 4 activation function found"
else
    test_fail "Phase 4 activation function not found"
fi

echo ""
echo "8. Checking audit capabilities..."

if grep -q "log_audit" ./deploy-phase-4-full-launch.sh; then
    test_pass "Audit logging function found"
else
    test_fail "Audit logging function not found"
fi

if grep -q "AUDIT_LOG" ./deploy-phase-4-full-launch.sh; then
    test_pass "Audit log variable defined"
else
    test_fail "Audit log variable not defined"
fi

echo ""
echo "9. Checking precheck functions..."

# Count precheck functions
PRECHECK_COUNT=$(grep -c "^precheck_" ./deploy-phase-4-full-launch.sh || echo "0")
if [ "$PRECHECK_COUNT" -ge 12 ]; then
    test_pass "Found $PRECHECK_COUNT precheck functions (expected ≥12)"
else
    test_fail "Found only $PRECHECK_COUNT precheck functions (expected ≥12)"
fi

echo ""
echo "10. Checking safety features..."

if grep -q "LOCK_FILE" ./deploy-phase-4-full-launch.sh; then
    test_pass "Deployment lock mechanism found"
else
    test_fail "Deployment lock mechanism not found"
fi

if grep -q "trap release_lock EXIT INT TERM" ./deploy-phase-4-full-launch.sh; then
    test_pass "Lock cleanup trap found"
else
    test_fail "Lock cleanup trap not found"
fi

echo ""
echo "======================================================================"
echo "Validation Summary"
echo "======================================================================"
echo ""
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${C_GREEN}✓ All validation tests passed!${C_NC}"
    echo ""
    echo "Phase 4 deployment script is ready for use."
    echo "Requires sudo/root privileges for actual deployment."
    exit 0
else
    echo -e "${C_RED}✗ Some validation tests failed${C_NC}"
    echo ""
    echo "Please review the failures above before deployment."
    exit 1
fi
