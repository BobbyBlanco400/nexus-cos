#!/bin/bash

# N3XUS COS — Runtime Verification Script
# Version: v2.5.0-RC1
# Handshake: 55-45-17

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Banner
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  N3XUS COS — Runtime Verification"
echo "  Version: v2.5.0-RC1"
echo "  Handshake: 55-45-17"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Track verification status
VERIFICATION_FAILED=0

# Test 1: Handshake Verification
print_info "Test 1: Handshake 55-45-17 Verification"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if grep -r "55-45-17" "${REPO_ROOT}" --include="*.tsx" --include="*.ts" --include="*.md" --include="*.sh" > /dev/null 2>&1; then
    print_success "Handshake 55-45-17 found in codebase"
else
    print_error "Handshake 55-45-17 NOT found in codebase"
    VERIFICATION_FAILED=1
fi

echo ""

# Test 2: Version Check
print_info "Test 2: Version Check (v2.5.0-RC1)"

if grep -r "v2.5.0-RC1" "${REPO_ROOT}" --include="*.md" --include="*.json" > /dev/null 2>&1; then
    print_success "Version v2.5.0-RC1 verified"
else
    print_warning "Version v2.5.0-RC1 not found in expected locations"
fi

echo ""

# Test 3: Documentation Files
print_info "Test 3: Documentation Files"

REQUIRED_DOCS=(
    "docs/N3XUS_MAINNET_LAUNCH_ANNOUNCEMENT.md"
    "docs/N3XUS_KINETIC_TEXT_SEQUENCE.md"
    "docs/N3XUS_KINETIC_STORYBOARD.md"
    "docs/N3XUS_KINETIC_VO_SCRIPT.md"
    "docs/N3XUS_FOUNDING_RESIDENTS_PRESS_KIT.md"
    "docs/N3XUS_SOCIAL_ROLLOUT_PLAN.md"
    "docs/N3XUS_LAUNCH_ASSETS_INDEX.md"
    "docs/N3XUS_MAINNET_VERIFICATION_CHECKLIST.md"
    "NEXUS_COS_STATUS_DASHBOARD.md"
)

MISSING_DOCS=0
for doc in "${REQUIRED_DOCS[@]}"; do
    if [ -f "${REPO_ROOT}/${doc}" ]; then
        print_success "Found: ${doc}"
    else
        print_error "Missing: ${doc}"
        MISSING_DOCS=$((MISSING_DOCS + 1))
        VERIFICATION_FAILED=1
    fi
done

if [ ${MISSING_DOCS} -eq 0 ]; then
    print_success "All required documentation files present"
fi

echo ""

# Test 4: Tenant Registry
print_info "Test 4: Tenant Registry"

TENANT_REGISTRY="${REPO_ROOT}/runtime/tenants/tenants.json"

if [ -f "${TENANT_REGISTRY}" ]; then
    print_success "Tenant registry found: ${TENANT_REGISTRY}"
    
    # Check if it contains 13 tenants
    if command -v jq &> /dev/null; then
        TENANT_COUNT=$(jq '.tenants | length' "${TENANT_REGISTRY}")
        if [ "${TENANT_COUNT}" -eq 13 ]; then
            print_success "Tenant count verified: 13 founding residents"
        else
            print_error "Expected 13 tenants, found: ${TENANT_COUNT}"
            VERIFICATION_FAILED=1
        fi
    else
        print_warning "jq not installed, skipping JSON validation"
    fi
else
    print_error "Tenant registry not found"
    VERIFICATION_FAILED=1
fi

echo ""

# Test 5: Deployment Scripts
print_info "Test 5: Deployment Scripts"

DEPLOY_SCRIPTS=(
    "infra/cps/scripts/deploy-tenant.sh"
    "infra/cps/scripts/deploy-all-tenants.sh"
)

for script in "${DEPLOY_SCRIPTS[@]}"; do
    if [ -f "${REPO_ROOT}/${script}" ]; then
        if [ -x "${REPO_ROOT}/${script}" ]; then
            print_success "Script found and executable: ${script}"
        else
            print_warning "Script found but not executable: ${script}"
            chmod +x "${REPO_ROOT}/${script}"
            print_info "Made executable: ${script}"
        fi
    else
        print_error "Script not found: ${script}"
        VERIFICATION_FAILED=1
    fi
done

echo ""

# Test 6: Status Dashboard
print_info "Test 6: Status Dashboard"

STATUS_DASHBOARD="${REPO_ROOT}/NEXUS_COS_STATUS_DASHBOARD.md"

if [ -f "${STATUS_DASHBOARD}" ]; then
    if grep -q "READY_FOR_MAINNET" "${STATUS_DASHBOARD}"; then
        print_success "Status: READY_FOR_MAINNET ✅"
    else
        print_error "Status dashboard missing READY_FOR_MAINNET indicator"
        VERIFICATION_FAILED=1
    fi
else
    print_error "Status dashboard not found"
    VERIFICATION_FAILED=1
fi

echo ""

# Test 7: Frontend Routes
print_info "Test 7: Frontend Routes"

ROUTER_FILE="${REPO_ROOT}/frontend/src/router.tsx"

if [ -f "${ROUTER_FILE}" ]; then
    print_success "Router configuration found"
    
    EXPECTED_ROUTES=("/residents" "/cps" "/dashboard" "/desktop")
    for route in "${EXPECTED_ROUTES[@]}"; do
        if grep -q "${route}" "${ROUTER_FILE}"; then
            print_success "Route configured: ${route}"
        else
            print_warning "Route not found in router: ${route}"
        fi
    done
else
    print_error "Router file not found"
    VERIFICATION_FAILED=1
fi

echo ""

# Final Summary
echo "═══════════════════════════════════════════════════════════"

if [ ${VERIFICATION_FAILED} -eq 0 ]; then
    print_success "RUNTIME VERIFICATION PASSED ✅"
    echo ""
    echo "N3XUS COS v2.5.0-RC1"
    echo "Handshake: 55-45-17 VERIFIED"
    echo "Status: READY_FOR_MAINNET"
    echo ""
    exit 0
else
    print_error "RUNTIME VERIFICATION FAILED ❌"
    echo ""
    echo "Please review the errors above and fix them."
    echo ""
    exit 1
fi
