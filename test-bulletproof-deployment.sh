#!/bin/bash
# ==============================================================================
# Bulletproof Deployment Test Script
# ==============================================================================
# Purpose: Validate bulletproof deployment setup without actually deploying
# Usage: bash test-bulletproof-deployment.sh
# ==============================================================================

# Don't use set -e for test scripts - we want to continue on failures
set +e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PASSED=0
FAILED=0
WARNINGS=0

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                              ║${NC}"
    echo -e "${CYAN}║              🛡️  BULLETPROOF DEPLOYMENT TEST SUITE  🛡️                       ║${NC}"
    echo -e "${CYAN}║                                                                              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

test_pass() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
    ((PASSED++))
}

test_fail() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
    ((FAILED++))
}

test_warn() {
    echo -e "${YELLOW}[⚠ WARN]${NC} $1"
    ((WARNINGS++))
}

# Test 1: Script Files Exist
test_script_files() {
    print_section "TEST 1: Script Files Existence"
    
    local scripts=(
        "trae-solo-bulletproof-deploy.sh"
        "launch-bulletproof.sh"
        "BULLETPROOF_ONE_LINER.md"
        "TRAE_SOLO_BULLETPROOF_GUIDE.md"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            test_pass "File exists: $script"
        else
            test_fail "File missing: $script"
        fi
    done
}

# Test 2: Script Syntax
test_script_syntax() {
    print_section "TEST 2: Script Syntax Validation"
    
    local scripts=(
        "trae-solo-bulletproof-deploy.sh"
        "launch-bulletproof.sh"
    )
    
    for script in "${scripts[@]}"; do
        if bash -n "$script" 2>/dev/null; then
            test_pass "Syntax valid: $script"
        else
            test_fail "Syntax error: $script"
        fi
    done
}

# Test 3: Script Permissions
test_script_permissions() {
    print_section "TEST 3: Script Permissions"
    
    local scripts=(
        "trae-solo-bulletproof-deploy.sh"
        "launch-bulletproof.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -x "$script" ]]; then
            test_pass "Executable: $script"
        else
            test_fail "Not executable: $script"
        fi
    done
}

# Test 4: Integration Scripts Exist
test_integration_scripts() {
    print_section "TEST 4: Integration Scripts Existence"
    
    local scripts=(
        "validate-pf.sh"
        "validate-ip-domain-routing.sh"
        "nexus-cos-launch-validator.sh"
        "verify-29-services.sh"
        "deploy-trae-solo.sh"
        "master-fix-trae-solo.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            test_pass "Integration script exists: $script"
        else
            test_warn "Integration script not found: $script (optional)"
        fi
    done
}

# Test 5: Configuration Files
test_configuration_files() {
    print_section "TEST 5: Configuration Files"
    
    local configs=(
        "trae-solo.yaml"
        ".env.example"
        "package.json"
    )
    
    for config in "${configs[@]}"; do
        if [[ -f "$config" ]]; then
            test_pass "Config file exists: $config"
        else
            test_warn "Config file not found: $config (may be generated)"
        fi
    done
}

# Test 6: Directory Structure
test_directory_structure() {
    print_section "TEST 6: Directory Structure"
    
    local dirs=(
        "frontend"
        "backend"
        "admin"
        "creator-hub"
        "deployment"
        "scripts"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            test_pass "Directory exists: $dir"
        else
            test_warn "Directory not found: $dir (may be optional)"
        fi
    done
}

# Test 7: Documentation Files
test_documentation() {
    print_section "TEST 7: Documentation Files"
    
    local docs=(
        "README.md"
        "BULLETPROOF_ONE_LINER.md"
        "TRAE_SOLO_BULLETPROOF_GUIDE.md"
    )
    
    for doc in "${docs[@]}"; do
        if [[ -f "$doc" ]]; then
            test_pass "Documentation exists: $doc"
        else
            test_fail "Documentation missing: $doc"
        fi
    done
}

# Test 8: Script Variables
test_script_variables() {
    print_section "TEST 8: Script Variables Configuration"
    
    # Check if main script has required variables
    if grep -q "REPO_MAIN=" trae-solo-bulletproof-deploy.sh; then
        test_pass "REPO_MAIN variable defined"
    else
        test_fail "REPO_MAIN variable not found"
    fi
    
    if grep -q "SERVICE_NAME=" trae-solo-bulletproof-deploy.sh; then
        test_pass "SERVICE_NAME variable defined"
    else
        test_fail "SERVICE_NAME variable not found"
    fi
    
    if grep -q "DOMAIN=" trae-solo-bulletproof-deploy.sh; then
        test_pass "DOMAIN variable defined"
    else
        test_fail "DOMAIN variable not found"
    fi
}

# Test 9: Function Definitions
test_function_definitions() {
    print_section "TEST 9: Function Definitions"
    
    local functions=(
        "preflight_checks"
        "sync_application_files"
        "validate_configuration"
        "install_dependencies"
        "build_applications"
        "deploy_main_service"
        "deploy_microservices"
        "configure_nginx"
        "verify_services"
        "run_health_checks"
        "final_validation"
    )
    
    for func in "${functions[@]}"; do
        if grep -q "^${func}()" trae-solo-bulletproof-deploy.sh; then
            test_pass "Function defined: $func"
        else
            test_fail "Function missing: $func"
        fi
    done
}

# Test 10: README Integration
test_readme_integration() {
    print_section "TEST 10: README Integration"
    
    if grep -q "bulletproof" README.md; then
        test_pass "Bulletproof deployment referenced in README"
    else
        test_warn "Bulletproof deployment not referenced in README"
    fi
    
    if grep -q "launch-bulletproof.sh" README.md; then
        test_pass "Launch script referenced in README"
    else
        test_warn "Launch script not referenced in README"
    fi
}

# Test 11: Error Handling
test_error_handling() {
    print_section "TEST 11: Error Handling"
    
    if grep -q "set -euo pipefail" trae-solo-bulletproof-deploy.sh; then
        test_pass "Strict error handling enabled (set -euo pipefail)"
    elif grep -q "set -e" trae-solo-bulletproof-deploy.sh; then
        test_pass "Basic error handling enabled (set -e)"
    else
        test_fail "No error handling found"
    fi
    
    if grep -q "trap.*ERR" trae-solo-bulletproof-deploy.sh; then
        test_pass "Error trap configured"
    else
        test_warn "No error trap found"
    fi
}

# Test 12: Logging Configuration
test_logging() {
    print_section "TEST 12: Logging Configuration"
    
    if grep -q "LOG_DIR=" trae-solo-bulletproof-deploy.sh; then
        test_pass "Log directory configured"
    else
        test_warn "Log directory not configured"
    fi
    
    if grep -q "DEPLOYMENT_LOG=" trae-solo-bulletproof-deploy.sh; then
        test_pass "Deployment log configured"
    else
        test_warn "Deployment log not configured"
    fi
    
    if grep -q "ERROR_LOG=" trae-solo-bulletproof-deploy.sh; then
        test_pass "Error log configured"
    else
        test_warn "Error log not configured"
    fi
}

# Print Summary
print_summary() {
    print_section "TEST SUMMARY"
    
    local total=$((PASSED + FAILED + WARNINGS))
    
    echo -e "${GREEN}Passed:${NC}   $PASSED / $total"
    echo -e "${RED}Failed:${NC}   $FAILED / $total"
    echo -e "${YELLOW}Warnings:${NC} $WARNINGS / $total"
    echo ""
    
    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                                                                              ║${NC}"
        echo -e "${GREEN}║                    ✅  ALL TESTS PASSED!  ✅                                  ║${NC}"
        echo -e "${GREEN}║                                                                              ║${NC}"
        echo -e "${GREEN}║            Bulletproof deployment is ready to use!                           ║${NC}"
        echo -e "${GREEN}║                                                                              ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}Next steps:${NC}"
        echo -e "  1. Review any warnings above (if any)"
        echo -e "  2. Test deployment in a safe environment"
        echo -e "  3. Run: ${YELLOW}sudo bash trae-solo-bulletproof-deploy.sh${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║                                                                              ║${NC}"
        echo -e "${RED}║                    ✗  SOME TESTS FAILED  ✗                                   ║${NC}"
        echo -e "${RED}║                                                                              ║${NC}"
        echo -e "${RED}║            Please fix the issues before deploying                            ║${NC}"
        echo -e "${RED}║                                                                              ║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        return 1
    fi
}

# Main execution
main() {
    print_header
    
    test_script_files
    test_script_syntax
    test_script_permissions
    test_integration_scripts
    test_configuration_files
    test_directory_structure
    test_documentation
    test_script_variables
    test_function_definitions
    test_readme_integration
    test_error_handling
    test_logging
    
    print_summary
}

main "$@"
