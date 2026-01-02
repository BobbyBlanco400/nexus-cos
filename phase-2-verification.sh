#!/bin/bash
################################################################################
# N3XUS COS Phase-2 Verification Script
# Comprehensive health check and validation for Phase-2 sealed system
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0
TOTAL_CHECKS=0

# Output functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_check() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    echo -e "${YELLOW}[CHECK $TOTAL_CHECKS]${NC} $1"
}

print_pass() {
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
    echo -e "${GREEN}✓ PASS:${NC} $1"
}

print_fail() {
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
    echo -e "${RED}✗ FAIL:${NC} $1"
}

print_warn() {
    CHECKS_WARNING=$((CHECKS_WARNING + 1))
    echo -e "${YELLOW}⚠ WARN:${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ INFO:${NC} $1"
}

################################################################################
# Check Functions
################################################################################

check_git_status() {
    print_header "Git Repository Status"
    
    print_check "Checking git repository"
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        print_pass "In git repository"
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        print_info "Current branch: $CURRENT_BRANCH"
    else
        print_fail "Not in a git repository"
        return 1
    fi
}

check_documentation() {
    print_header "Phase-2 Documentation"
    
    REQUIRED_DOCS=(
        "PHASE_2_COMPLETION.md"
        "30_FOUNDERS_LOOP_TIMELINE.md"
        "V_DOMAINS_ARCHITECTURE.md"
        "GOVERNANCE_CHARTER_55_45_17.md"
        "PUABO_API_AI_HF_SUMMARY.md"
        "README.md"
    )
    
    for doc in "${REQUIRED_DOCS[@]}"; do
        print_check "Checking for $doc"
        if [ -f "$doc" ]; then
            print_pass "$doc exists"
        else
            print_fail "$doc is missing"
        fi
    done
}

check_puabo_service() {
    print_header "PUABO AI Hybrid Service"
    
    print_check "Checking PUABO service directory"
    if [ -d "services/puabo_api_ai_hf" ]; then
        print_pass "PUABO service directory exists"
    else
        print_fail "PUABO service directory not found"
        return 1
    fi
    
    print_check "Checking PUABO service files"
    PUABO_FILES=(
        "services/puabo_api_ai_hf/server.py"
        "services/puabo_api_ai_hf/requirements.txt"
        "services/puabo_api_ai_hf/config.json"
        "services/puabo_api_ai_hf/Dockerfile"
    )
    
    for file in "${PUABO_FILES[@]}"; do
        if [ -f "$file" ]; then
            print_pass "$(basename $file) exists"
        else
            print_fail "$(basename $file) is missing"
        fi
    done
    
    print_check "Checking if PUABO service port is configured (3401)"
    if grep -q "3401" services/puabo_api_ai_hf/server.py 2>/dev/null; then
        print_pass "Port 3401 configured in service"
    else
        print_warn "Port 3401 not found in server.py"
    fi
}

check_kei_ai_removed() {
    print_header "Kei AI Removal Verification"
    
    print_check "Verifying Kei AI service is removed"
    if [ -d "services/kei-ai" ]; then
        print_fail "Kei AI service directory still exists"
    else
        print_pass "Kei AI service directory removed"
    fi
    
    print_check "Checking for Kei AI references in code"
    if grep -r "kei.ai\|kei_ai" --include="*.js" --include="*.py" --include="*.json" . 2>/dev/null | grep -v "backup\|.git" | head -1; then
        print_warn "Found references to Kei AI in code (may be in backups/comments)"
    else
        print_pass "No Kei AI references found in active code"
    fi
}

check_nginx_config() {
    print_header "Nginx Configuration"
    
    print_check "Checking nginx.conf exists"
    if [ -f "nginx.conf" ]; then
        print_pass "nginx.conf exists"
    else
        print_fail "nginx.conf not found"
        return 1
    fi
    
    print_check "Verifying Handshake 55-45-17 in Nginx config"
    if grep -q "55-45-17" nginx.conf; then
        print_pass "Handshake 55-45-17 found in nginx.conf"
    else
        print_fail "Handshake 55-45-17 NOT found in nginx.conf"
    fi
    
    print_check "Checking SSL configuration"
    if grep -q "ssl_certificate" nginx.conf; then
        print_pass "SSL certificates configured"
    else
        print_warn "SSL certificates not configured in nginx.conf"
    fi
    
    print_check "Checking for common routing issues"
    if grep -q "return 301" nginx.conf; then
        print_info "Redirect rules found (verify no infinite loops)"
    fi
}

check_docker_compose() {
    print_header "Docker Compose Configuration"
    
    print_check "Checking for docker-compose files"
    COMPOSE_FILES=$(find . -maxdepth 1 -name "docker-compose*.yml" -type f)
    
    if [ -n "$COMPOSE_FILES" ]; then
        print_pass "Found docker-compose files:"
        echo "$COMPOSE_FILES" | while read file; do
            print_info "  - $file"
        done
    else
        print_warn "No docker-compose files found"
    fi
}

check_v_suite() {
    print_header "V-Suite Domains"
    
    print_check "Checking V-Suite documentation"
    if [ -f "V_DOMAINS_ARCHITECTURE.md" ]; then
        print_pass "V-Domains architecture documented"
        
        print_check "Verifying V-Domain references"
        V_DOMAINS=("V-Studio" "V-Media" "V-Brand" "V-Stream" "V-Legal")
        for domain in "${V_DOMAINS[@]}"; do
            if grep -q "$domain" V_DOMAINS_ARCHITECTURE.md; then
                print_pass "$domain documented"
            else
                print_warn "$domain not found in documentation"
            fi
        done
    else
        print_fail "V-Domains architecture documentation missing"
    fi
}

check_governance() {
    print_header "Governance & Compliance"
    
    print_check "Checking governance charter"
    if [ -f "GOVERNANCE_CHARTER_55_45_17.md" ]; then
        print_pass "Governance charter exists"
    else
        print_fail "Governance charter missing"
    fi
    
    print_check "Checking for governance verification script"
    if [ -f "trae-governance-verification.sh" ]; then
        print_pass "Governance verification script exists"
        if [ -x "trae-governance-verification.sh" ]; then
            print_pass "Governance script is executable"
        else
            print_warn "Governance script is not executable"
        fi
    else
        print_warn "Governance verification script not found"
    fi
}

check_services_directory() {
    print_header "Services Directory"
    
    print_check "Checking services directory"
    if [ -d "services" ]; then
        SERVICE_COUNT=$(find services -maxdepth 1 -type d | wc -l)
        SERVICE_COUNT=$((SERVICE_COUNT - 1)) # Exclude services/ itself
        print_pass "Services directory exists with $SERVICE_COUNT services"
        
        print_check "Listing core services"
        CORE_SERVICES=("backend-api" "puabo_api_ai_hf" "auth-service" "streaming-service-v2")
        for service in "${CORE_SERVICES[@]}"; do
            if [ -d "services/$service" ]; then
                print_pass "$service found"
            else
                print_info "$service not found (may use different name)"
            fi
        done
    else
        print_fail "Services directory not found"
    fi
}

check_package_json() {
    print_header "Package Configuration"
    
    print_check "Checking package.json"
    if [ -f "package.json" ]; then
        print_pass "package.json exists"
        
        print_check "Checking for trae configuration"
        if grep -q '"trae"' package.json; then
            print_pass "TRAE configuration found"
        else
            print_warn "TRAE configuration not found"
        fi
    else
        print_fail "package.json not found"
    fi
}

check_health_scripts() {
    print_header "Health Check Scripts"
    
    HEALTH_SCRIPTS=(
        "nexus_cos_health_check.sh"
        "verify_puabo_api_ai_hf.sh"
        "validate-deployment-ready.sh"
    )
    
    for script in "${HEALTH_SCRIPTS[@]}"; do
        print_check "Checking for $script"
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                print_pass "$script exists and is executable"
            else
                print_warn "$script exists but is not executable"
            fi
        else
            print_info "$script not found (optional)"
        fi
    done
}

check_phase_2_markers() {
    print_header "Phase-2 Seal Markers"
    
    print_check "Checking for Phase-2 completion documentation"
    if [ -f "PHASE_2_COMPLETION.md" ]; then
        print_pass "Phase-2 completion document exists"
        
        if grep -q "PHASE-2 SEALED" PHASE_2_COMPLETION.md; then
            print_pass "Phase-2 seal marker found"
        else
            print_warn "Phase-2 seal marker not found in document"
        fi
    else
        print_fail "Phase-2 completion document missing"
    fi
    
    print_check "Checking for 30-Founders Loop timeline"
    if [ -f "30_FOUNDERS_LOOP_TIMELINE.md" ]; then
        print_pass "30-Founders Loop timeline exists"
    else
        print_fail "30-Founders Loop timeline missing"
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║              N3XUS COS PHASE-2 VERIFICATION SCRIPT                ║
║                                                                   ║
║              Comprehensive System Health & Compliance             ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
    
    print_info "Starting comprehensive Phase-2 verification..."
    print_info "Date: $(date)"
    echo ""
    
    # Run all checks
    check_git_status
    check_documentation
    check_puabo_service
    check_kei_ai_removed
    check_nginx_config
    check_docker_compose
    check_v_suite
    check_governance
    check_services_directory
    check_package_json
    check_health_scripts
    check_phase_2_markers
    
    # Final summary
    print_header "Verification Summary"
    
    echo -e "${BLUE}Total Checks:${NC} $TOTAL_CHECKS"
    echo -e "${GREEN}Passed:${NC} $CHECKS_PASSED"
    echo -e "${YELLOW}Warnings:${NC} $CHECKS_WARNING"
    echo -e "${RED}Failed:${NC} $CHECKS_FAILED"
    echo ""
    
    # Calculate success rate
    if [ $TOTAL_CHECKS -gt 0 ]; then
        SUCCESS_RATE=$((CHECKS_PASSED * 100 / TOTAL_CHECKS))
        echo -e "${BLUE}Success Rate:${NC} ${SUCCESS_RATE}%"
    fi
    
    echo ""
    
    # Final status
    if [ $CHECKS_FAILED -eq 0 ]; then
        if [ $CHECKS_WARNING -eq 0 ]; then
            echo -e "${GREEN}✓✓✓ PHASE-2 VERIFICATION COMPLETE - ALL CHECKS PASSED ✓✓✓${NC}"
            echo -e "${GREEN}System is fully operational and Phase-2 sealed.${NC}"
            exit 0
        else
            echo -e "${YELLOW}⚠ PHASE-2 VERIFICATION COMPLETE - WITH WARNINGS ⚠${NC}"
            echo -e "${YELLOW}System is operational but has $CHECKS_WARNING warnings to review.${NC}"
            exit 0
        fi
    else
        echo -e "${RED}✗ PHASE-2 VERIFICATION FAILED ✗${NC}"
        echo -e "${RED}System has $CHECKS_FAILED failed checks. Please review and fix.${NC}"
        exit 1
    fi
}

# Run main function
main "$@"
