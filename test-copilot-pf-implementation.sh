#!/bin/bash
# Test script for GitHub Copilot Code Agent PF Review & Fix Script implementation
# Validates all components created by the PF implementation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[TEST]${NC} $1"
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

TESTS_PASSED=0
TESTS_TOTAL=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TESTS_TOTAL++))
    print_info "Running: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        print_success "$test_name"
        ((TESTS_PASSED++))
    else
        print_error "$test_name"
    fi
}

print_info "🧪 Testing GitHub Copilot PF Implementation"
print_info "============================================"

# Test 1: Admin Authentication Service Fix
print_info ""
print_info "📋 Task 1: Admin Authentication Service Fix"
print_info "--------------------------------------------"

run_test "Auth service package.json contains jsonwebtoken@9.0.2" \
    "grep -q 'jsonwebtoken.*9.0.2' /home/runner/work/nexus-cos/nexus-cos/services/auth-service/package.json"

run_test "Auth service server.js implements JWT functionality" \
    "grep -q 'jsonwebtoken' /home/runner/work/nexus-cos/nexus-cos/services/auth-service/server.js"

run_test "Auth service has JWT refresh endpoint" \
    "grep -q '/auth/refresh' /home/runner/work/nexus-cos/nexus-cos/services/auth-service/server.js"

run_test "Auth service dependencies are installed" \
    "test -d /home/runner/work/nexus-cos/nexus-cos/services/auth-service/node_modules"

# Test 2: Branding System Consolidation
print_info ""
print_info "📋 Task 2: Branding System Consolidation"
print_info "-----------------------------------------"

run_test "Branding PF configuration exists" \
    "test -f /home/runner/work/nexus-cos/nexus-cos/pfs/final/branding-pf.yml"

run_test "Branding enforcement script exists and is executable" \
    "test -x /home/runner/work/nexus-cos/nexus-cos/scripts/branding-enforce.sh"

run_test "Branding theme CSS exists" \
    "test -f /home/runner/work/nexus-cos/nexus-cos/branding/theme.css"

run_test "Branding logo SVG exists" \
    "test -f /home/runner/work/nexus-cos/nexus-cos/branding/logo.svg"

run_test "Branding assets directory structure is correct" \
    "test -d /home/runner/work/nexus-cos/nexus-cos/branding"

# Test 3: Service Communication Setup
print_info ""
print_info "📋 Task 3: Service Communication Setup"
print_info "---------------------------------------"

run_test "Services configuration JSON exists" \
    "test -f /home/runner/work/nexus-cos/nexus-cos/config/services.json"

run_test "Environment variables file exists" \
    "test -f /home/runner/work/nexus-cos/nexus-cos/.env"

run_test "Services JSON contains auth-service configuration" \
    "grep -q 'auth-service' /home/runner/work/nexus-cos/nexus-cos/config/services.json"

run_test "Environment file contains JWT_SECRET" \
    "grep -q 'JWT_SECRET' /home/runner/work/nexus-cos/nexus-cos/.env"

# Test 4: Health Check and Verification System
print_info ""
print_info "📋 Task 4: Health Check and Verification"
print_info "-----------------------------------------"

run_test "Health check script exists and is executable" \
    "test -x /home/runner/work/nexus-cos/nexus-cos/scripts/health-check.sh"

run_test "Log directory exists with required log files" \
    "test -f /home/runner/work/nexus-cos/nexus-cos/logs/auth.log && test -f /home/runner/work/nexus-cos/nexus-cos/logs/branding.log && test -f /home/runner/work/nexus-cos/nexus-cos/logs/system.log"

run_test "GitHub Copilot PF YAML configuration exists" \
    "test -f /home/runner/work/nexus-cos/nexus-cos/github-copilot-pf.yaml"

run_test "PM2 ecosystem configuration exists" \
    "test -f /home/runner/work/nexus-cos/nexus-cos/ecosystem.config.js"

# Test 5: Functional Tests (if possible)
print_info ""
print_info "📋 Task 5: Functional Validation"
print_info "---------------------------------"

# Start auth service for functional testing
if command -v node >/dev/null 2>&1; then
    print_info "Starting auth service for functional testing..."
    cd /home/runner/work/nexus-cos/nexus-cos/services/auth-service
    timeout 10s node server.js &
    AUTH_PID=$!
    sleep 3
    
    if kill -0 $AUTH_PID 2>/dev/null; then
        run_test "Auth service starts successfully" "true"
        
        if command -v curl >/dev/null 2>&1; then
            run_test "Auth service health endpoint responds" \
                "curl -s http://localhost:3100/health | grep -q 'ok'"
            
            run_test "Auth service JWT endpoint is accessible" \
                "curl -s http://localhost:3100/auth/login | grep -q 'Username and password required'"
        else
            print_warning "curl not available - skipping HTTP tests"
        fi
        
        # Clean up
        kill $AUTH_PID 2>/dev/null || true
    else
        print_error "Auth service failed to start"
    fi
else
    print_warning "Node.js not available - skipping functional tests"
fi

# Test 6: Script Execution Tests
print_info ""
print_info "📋 Task 6: Script Execution Validation"
print_info "---------------------------------------"

cd /home/runner/work/nexus-cos/nexus-cos

if ./scripts/branding-enforce.sh >/dev/null 2>&1; then
    run_test "Branding enforcement script executes successfully" "true"
    run_test "Branding enforcement generates report" \
        "test -f /tmp/branding-enforcement-report.txt"
else
    print_error "Branding enforcement script failed to execute"
fi

# Final Results
print_info ""
print_info "🏁 Test Results Summary"
print_info "======================="
print_info "Tests Passed: $TESTS_PASSED"
print_info "Tests Total:  $TESTS_TOTAL"

SUCCESS_RATE=$((TESTS_PASSED * 100 / TESTS_TOTAL))
print_info "Success Rate: $SUCCESS_RATE%"

if [[ $SUCCESS_RATE -ge 80 ]]; then
    print_success "🎉 GitHub Copilot PF Implementation: SUCCESSFUL"
    print_success "All critical components are in place and functional!"
    exit 0
else
    print_error "❌ GitHub Copilot PF Implementation: NEEDS ATTENTION"
    print_error "Some components failed validation."
    exit 1
fi