#!/bin/bash
# ============================================================================
# TRAE Final Deployment Readiness Check
# ============================================================================
# Purpose: Comprehensive validation before TRAE execution
# Validates: Configuration, package.json files, services, and system readiness
# Date: $(date +%Y-%m-%d)
# ============================================================================

# Don't exit on error - we want to collect all test results
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Test counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# Print functions
print_header() {
    echo ""
    echo -e "${CYAN}============================================================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}============================================================================${NC}"
}

print_section() {
    echo ""
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}────────────────────────────────────────────────────────────────────────${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((PASSED_CHECKS++))
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
    ((FAILED_CHECKS++))
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
    ((WARNINGS++))
}

check_item() {
    ((TOTAL_CHECKS++))
    local description="$1"
    local command="$2"
    
    if eval "$command" >/dev/null 2>&1; then
        print_success "$description"
        return 0
    else
        print_error "$description"
        return 1
    fi
}

# ============================================================================
# PHASE 1: System Prerequisites Check
# ============================================================================
check_system_prerequisites() {
    print_section "PHASE 1: System Prerequisites Validation"
    
    ((TOTAL_CHECKS++))
    if command -v node >/dev/null 2>&1; then
        NODE_VERSION=$(node --version)
        print_success "Node.js installed: $NODE_VERSION"
    else
        print_error "Node.js not found"
    fi
    
    ((TOTAL_CHECKS++))
    if command -v npm >/dev/null 2>&1; then
        NPM_VERSION=$(npm --version)
        print_success "NPM installed: $NPM_VERSION"
    else
        print_error "NPM not found"
    fi
    
    ((TOTAL_CHECKS++))
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_VERSION=$(python3 --version)
        print_success "Python3 installed: $PYTHON_VERSION"
    else
        print_error "Python3 not found"
    fi
    
    ((TOTAL_CHECKS++))
    if command -v docker >/dev/null 2>&1; then
        DOCKER_VERSION=$(docker --version)
        print_success "Docker installed: $DOCKER_VERSION"
    else
        print_warning "Docker not found (may be required for production deployment)"
    fi
}

# ============================================================================
# PHASE 2: TRAE Configuration Validation
# ============================================================================
check_trae_configuration() {
    print_section "PHASE 2: TRAE Configuration Validation"
    
    ((TOTAL_CHECKS++))
    if [ -f "trae-solo.yaml" ]; then
        print_success "TRAE Solo configuration file exists: trae-solo.yaml"
        
        # Validate YAML syntax
        ((TOTAL_CHECKS++))
        if python3 -c "import yaml; yaml.safe_load(open('trae-solo.yaml'))" 2>/dev/null; then
            print_success "TRAE Solo YAML configuration is valid"
        else
            print_error "TRAE Solo YAML configuration has syntax errors"
        fi
    else
        print_error "TRAE Solo configuration file missing: trae-solo.yaml"
    fi
    
    ((TOTAL_CHECKS++))
    if [ -d ".trae" ]; then
        print_success "TRAE directory exists: .trae/"
        
        ((TOTAL_CHECKS++))
        if [ -f ".trae/environment.env" ]; then
            print_success "TRAE environment configuration exists"
        else
            print_warning "TRAE environment.env not found"
        fi
        
        ((TOTAL_CHECKS++))
        if [ -f ".trae/services.yaml" ]; then
            print_success "TRAE services configuration exists"
        else
            print_warning "TRAE services.yaml not found"
        fi
    else
        print_warning "TRAE directory not found: .trae/"
    fi
    
    ((TOTAL_CHECKS++))
    if [ -x "deploy-trae-solo.sh" ]; then
        print_success "TRAE deployment script is executable"
    else
        print_error "TRAE deployment script missing or not executable"
    fi
}

# ============================================================================
# PHASE 3: Package.json Validation (Universal Health Check)
# ============================================================================
check_package_json_files() {
    print_section "PHASE 3: Universal Package.json Validation"
    
    print_status "Scanning all package.json files in the repository..."
    
    local package_files=$(find . -name "package.json" -not -path "*/node_modules/*" 2>/dev/null)
    local total_packages=0
    local valid_packages=0
    local invalid_packages=0
    
    while IFS= read -r package_file; do
        if [ -n "$package_file" ]; then
            ((total_packages++))
            ((TOTAL_CHECKS++))
            
            # Validate JSON syntax
            if python3 -c "import json; json.load(open('$package_file'))" 2>/dev/null; then
                print_success "Valid: $package_file"
                ((valid_packages++))
            else
                print_error "Invalid JSON: $package_file"
                ((invalid_packages++))
            fi
        fi
    done <<< "$package_files"
    
    echo ""
    print_status "Package.json Summary:"
    echo "  Total files scanned: $total_packages"
    echo "  Valid: $valid_packages"
    echo "  Invalid: $invalid_packages"
}

# ============================================================================
# PHASE 4: Services Validation
# ============================================================================
check_services() {
    print_section "PHASE 4: Services Configuration Validation"
    
    # Check services directory
    ((TOTAL_CHECKS++))
    if [ -d "services" ]; then
        print_success "Services directory exists"
        
        local service_count=$(ls -1 services 2>/dev/null | wc -l)
        print_status "Found $service_count services in services directory"
        
        # Check key services
        local key_services=(
            "auth-service"
            "backend-api"
            "puaboai-sdk"
            "key-service"
        )
        
        for service in "${key_services[@]}"; do
            ((TOTAL_CHECKS++))
            if [ -d "services/$service" ]; then
                print_success "Key service exists: $service"
                
                # Check if service has package.json
                if [ -f "services/$service/package.json" ]; then
                    print_success "  └─ package.json exists for $service"
                fi
            else
                print_warning "Key service not found: $service"
            fi
        done
    else
        print_error "Services directory not found"
    fi
}

# ============================================================================
# PHASE 5: Build and Deployment Artifacts
# ============================================================================
check_build_artifacts() {
    print_section "PHASE 5: Build and Deployment Artifacts"
    
    # Check for deployment scripts
    local deployment_scripts=(
        "deploy-trae-solo.sh"
        "launch-readiness-check.sh"
        "health-check.sh"
    )
    
    for script in "${deployment_scripts[@]}"; do
        ((TOTAL_CHECKS++))
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                print_success "Deployment script ready: $script"
            else
                print_warning "Deployment script not executable: $script"
            fi
        else
            print_warning "Deployment script not found: $script"
        fi
    done
    
    # Check for environment files
    ((TOTAL_CHECKS++))
    if [ -f ".env.example" ] || [ -f ".env.pf.example" ]; then
        print_success "Environment template files exist"
    else
        print_warning "No environment template files found"
    fi
}

# ============================================================================
# PHASE 6: TRAE Execution Readiness
# ============================================================================
check_trae_readiness() {
    print_section "PHASE 6: TRAE Execution Readiness Assessment"
    
    print_status "Checking TRAE Solo package.json integration..."
    
    ((TOTAL_CHECKS++))
    if grep -q "trae:deploy" package.json 2>/dev/null; then
        print_success "TRAE deployment script configured in package.json"
    else
        print_warning "TRAE deployment script not found in package.json"
    fi
    
    ((TOTAL_CHECKS++))
    if grep -q "trae:start" package.json 2>/dev/null; then
        print_success "TRAE start script configured in package.json"
    else
        print_warning "TRAE start script not found in package.json"
    fi
    
    ((TOTAL_CHECKS++))
    if grep -q "trae:health" package.json 2>/dev/null; then
        print_success "TRAE health check script configured in package.json"
    else
        print_warning "TRAE health check script not found in package.json"
    fi
    
    print_status "Verifying TRAE Solo metadata..."
    ((TOTAL_CHECKS++))
    if grep -q '"trae"' package.json 2>/dev/null; then
        print_success "TRAE metadata section exists in package.json"
    else
        print_warning "TRAE metadata not found in package.json"
    fi
}

# ============================================================================
# PHASE 7: Git Repository Status
# ============================================================================
check_git_status() {
    print_section "PHASE 7: Git Repository Status"
    
    ((TOTAL_CHECKS++))
    if [ -d ".git" ]; then
        print_success "Git repository initialized"
        
        local current_branch=$(git branch --show-current)
        print_status "Current branch: $current_branch"
        
        local git_status=$(git status --porcelain)
        if [ -z "$git_status" ]; then
            print_success "Working tree is clean"
        else
            print_warning "Working tree has uncommitted changes"
        fi
    else
        print_error "Not a git repository"
    fi
}

# ============================================================================
# FINAL REPORT GENERATION
# ============================================================================
generate_final_report() {
    print_header "TRAE DEPLOYMENT READINESS REPORT"
    
    echo ""
    echo -e "${CYAN}Test Summary:${NC}"
    echo "────────────────────────────────────────"
    echo "  Total Checks: $TOTAL_CHECKS"
    echo -e "  ${GREEN}Passed: $PASSED_CHECKS${NC}"
    echo -e "  ${RED}Failed: $FAILED_CHECKS${NC}"
    echo -e "  ${YELLOW}Warnings: $WARNINGS${NC}"
    echo ""
    
    local pass_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    echo "  Pass Rate: ${pass_rate}%"
    echo ""
    
    # Determine deployment readiness
    if [ $FAILED_CHECKS -eq 0 ]; then
        echo -e "${GREEN}════════════════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}✓ SYSTEM IS READY FOR TRAE DEPLOYMENT${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${GREEN}All critical checks passed!${NC}"
        echo ""
        echo "Next Steps:"
        echo "  1. Review any warnings above (non-blocking)"
        echo "  2. Execute TRAE deployment: ./deploy-trae-solo.sh"
        echo "  3. Monitor deployment progress and health checks"
        echo ""
        
        if [ $WARNINGS -gt 0 ]; then
            echo -e "${YELLOW}Note: $WARNINGS warnings detected but system is deployable${NC}"
            echo ""
        fi
        
        return 0
    elif [ $FAILED_CHECKS -le 3 ]; then
        echo -e "${YELLOW}════════════════════════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}⚠ SYSTEM READY WITH MINOR ISSUES${NC}"
        echo -e "${YELLOW}════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${YELLOW}$FAILED_CHECKS minor issues detected${NC}"
        echo ""
        echo "Recommended Actions:"
        echo "  1. Review failed checks above"
        echo "  2. Fix non-critical issues if time permits"
        echo "  3. System can proceed with deployment if issues are non-blocking"
        echo ""
        
        return 1
    else
        echo -e "${RED}════════════════════════════════════════════════════════════════════════${NC}"
        echo -e "${RED}✗ SYSTEM NOT READY FOR DEPLOYMENT${NC}"
        echo -e "${RED}════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${RED}$FAILED_CHECKS critical issues must be resolved${NC}"
        echo ""
        echo "Required Actions:"
        echo "  1. Fix all failed checks listed above"
        echo "  2. Re-run this validation script"
        echo "  3. Do not proceed with deployment until all checks pass"
        echo ""
        
        return 2
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================
main() {
    print_header "TRAE FINAL DEPLOYMENT READINESS CHECK"
    echo ""
    echo "Date: $(date)"
    echo "Repository: /home/runner/work/nexus-cos/nexus-cos"
    echo ""
    
    # Execute all validation phases
    check_system_prerequisites
    check_trae_configuration
    check_package_json_files
    check_services
    check_build_artifacts
    check_trae_readiness
    check_git_status
    
    # Generate final report
    generate_final_report
    
    local exit_code=$?
    
    echo ""
    echo "Validation completed at: $(date)"
    echo ""
    
    exit $exit_code
}

# Run main function
main "$@"
