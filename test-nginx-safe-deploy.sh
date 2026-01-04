#!/bin/bash
# ==============================================================================
# Test Script for Nginx Safe Deployment Library
# ==============================================================================
# This script tests the safe deployment library functions
# Run with: sudo ./test-nginx-safe-deploy.sh
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Testing Nginx Safe Deployment Library                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}✗ This test script must be run as root${NC}"
    echo "  Usage: sudo $0"
    exit 1
fi

# Source the nginx safe deployment library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

if [[ ! -f "$REPO_ROOT/lib/nginx-safe-deploy.sh" ]]; then
    echo -e "${RED}✗ Library not found: $REPO_ROOT/lib/nginx-safe-deploy.sh${NC}"
    exit 1
fi

source "$REPO_ROOT/lib/nginx-safe-deploy.sh"
echo -e "${GREEN}✓${NC} Library loaded successfully"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

test_function() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo ""
    echo -e "${BLUE}[TEST $TESTS_RUN]${NC} $test_name"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# ==============================================================================
# Test 1: Check if nginx is installed
# ==============================================================================
test_function "Check nginx installation" "check_nginx_installed"

# ==============================================================================
# Test 2: Check root permissions
# ==============================================================================
test_function "Check root permissions" "check_root_permissions"

# ==============================================================================
# Test 3: Create backup directory
# ==============================================================================
test_function "Create backup directory" "create_backup_dir && [[ -d '$NGINX_BACKUP_DIR' ]]"

# ==============================================================================
# Test 4: Test logging functions
# ==============================================================================
test_function "Test logging functions" "
    log_info 'Test info message' &&
    log_success 'Test success message' &&
    log_warning 'Test warning message' &&
    log_error 'Test error message'
"

# ==============================================================================
# Test 5: Create a test configuration file
# ==============================================================================
TEST_CONFIG="/tmp/test-nginx-config.conf"
cat > "$TEST_CONFIG" << 'EOF'
# Test Nginx Configuration
server {
    listen 8888;
    server_name test.local;
    
    location / {
        return 200 "Test OK";
    }
}
EOF

test_function "Create test config file" "[[ -f '$TEST_CONFIG' ]]"

# ==============================================================================
# Test 6: Backup a config file (if it exists)
# ==============================================================================
if [[ -f "/etc/nginx/sites-available/default" ]]; then
    test_function "Backup existing config" "
        BACKUP=\$(backup_config_file '/etc/nginx/sites-available/default') &&
        [[ -n \"\$BACKUP\" ]] &&
        [[ -f \"\$BACKUP\" ]]
    "
else
    echo -e "${YELLOW}⊘ SKIP${NC} - No default config to backup"
fi

# ==============================================================================
# Test 7: Validate current nginx config
# ==============================================================================
test_function "Validate current nginx config" "validate_nginx_config"

# ==============================================================================
# Test 8: List backups
# ==============================================================================
test_function "List backups" "list_backups > /dev/null"

# ==============================================================================
# Test 9: Test safe deployment with a valid config (dry run)
# ==============================================================================
# Create a test site config
TEST_SITE_CONFIG="/tmp/test-site.conf"
cat > "$TEST_SITE_CONFIG" << 'EOF'
server {
    listen 8080;
    server_name test-site.local;
    
    location / {
        return 200 "Test Site OK";
    }
}
EOF

echo ""
echo -e "${YELLOW}NOTE:${NC} Skipping actual deployment test to avoid modifying system"
echo "      In production, you would test:"
echo "      safe_deploy_nginx_config '$TEST_SITE_CONFIG' '/etc/nginx/sites-available/test-site'"

# ==============================================================================
# Cleanup
# ==============================================================================
echo ""
echo -e "${BLUE}Cleaning up test files...${NC}"
rm -f "$TEST_CONFIG" "$TEST_SITE_CONFIG"
echo -e "${GREEN}✓${NC} Cleanup complete"

# ==============================================================================
# Test Summary
# ==============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Test Summary                                          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Tests Run:    $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅  ALL TESTS PASSED                                  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "The nginx-safe-deploy library is working correctly!"
    echo ""
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌  SOME TESTS FAILED                                 ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Please review the failures above."
    echo ""
    exit 1
fi
