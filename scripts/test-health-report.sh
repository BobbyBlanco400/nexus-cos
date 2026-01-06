#!/bin/bash
# Test script for Nexus COS Health Report
# Validates nexus_health_report.sh functionality

echo "==> 🧪 Testing Nexus COS Health Report Script"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HEALTH_SCRIPT="$SCRIPT_DIR/nexus_health_report.sh"
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo "➡️  Testing: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo "✅ PASS: $test_name"
        ((TESTS_PASSED++))
    else
        echo "❌ FAIL: $test_name"
        ((TESTS_FAILED++))
    fi
    echo ""
}

# Function to check content
check_content() {
    local test_name="$1"
    local pattern="$2"
    
    echo "➡️  Testing: $test_name"
    
    if grep -q "$pattern" "$HEALTH_SCRIPT"; then
        echo "✅ PASS: $test_name"
        ((TESTS_PASSED++))
    else
        echo "❌ FAIL: $test_name (pattern not found: $pattern)"
        ((TESTS_FAILED++))
    fi
    echo ""
}

echo ""
echo "=== Script Existence and Permissions ==="
echo ""

run_test "Health report script exists" "test -f '$HEALTH_SCRIPT'"
run_test "Health report script is executable" "test -x '$HEALTH_SCRIPT'"

echo ""
echo "=== Syntax and Structure Validation ==="
echo ""

run_test "Script has valid bash syntax" "bash -n '$HEALTH_SCRIPT'"
check_content "Has shebang" "^#!/bin/bash"
check_content "Uses set -u for safety" "set -u"
check_content "Uses set -o pipefail" "set -o pipefail"

echo ""
echo "=== URL Configuration ==="
echo ""

check_content "MAIN_URL properly quoted" 'MAIN_URL="https://n3xuscos.online/health"'
check_content "BETA_URL properly quoted" 'BETA_URL="https://beta.n3xuscos.online/health"'

echo ""
echo "=== Environment Path Resolution ==="
echo ""

check_content "Has resolve_env_path function" "resolve_env_path()"
check_content "Checks ENV_PATH variable" "ENV_PATH"
check_content "Prefers /opt/nexus-cos/.env" '"/opt/nexus-cos/.env"'
check_content "Falls back to local .env" "repo_root"

echo ""
echo "=== Curl Configuration ==="
echo ""

check_content "Has CURL_TIMEOUT setting" "CURL_TIMEOUT="
check_content "Has CURL_MAX_TIME setting" "CURL_MAX_TIME="
check_content "Uses connect-timeout in curl" "connect-timeout"
check_content "Uses max-time in curl" "max-time"

echo ""
echo "=== Exit Codes ==="
echo ""

check_content "Defines EXIT_SUCCESS" "EXIT_SUCCESS=0"
check_content "Defines EXIT_HEALTH_FAILED" "EXIT_HEALTH_FAILED=1"
check_content "Defines EXIT_DB_FAILED" "EXIT_DB_FAILED=2"
check_content "Defines EXIT_BOTH_FAILED" "EXIT_BOTH_FAILED=3"

echo ""
echo "=== Health Check Functions ==="
echo ""

check_content "Has check_health_endpoint function" "check_health_endpoint()"
check_content "Has check_db_connectivity function" "check_db_connectivity()"
check_content "Has load_env function" "load_env()"

echo ""
echo "=== Database Configuration ==="
echo ""

check_content "Uses DB_HOST variable" "DB_HOST"
check_content "Uses DB_PORT variable" "DB_PORT"
check_content "Has default DB_HOST" "DB_HOST:-"
check_content "Has default DB_PORT" "DB_PORT:-"

echo ""
echo "=== Runtime Tests ==="
echo ""

# Test script execution with default settings
run_test "Script runs without errors" "bash '$HEALTH_SCRIPT' >/dev/null 2>&1 || test \$? -le 3"

# Test with custom ENV_PATH
run_test "Script accepts ENV_PATH" "ENV_PATH='/opt/nexus-cos/.env' bash '$HEALTH_SCRIPT' >/dev/null 2>&1 || test \$? -le 3"

# Test exit code is in expected range (0-3)
echo "➡️  Testing: Exit code validation"
bash "$HEALTH_SCRIPT" >/dev/null 2>&1
EXIT_CODE=$?
if [[ $EXIT_CODE -ge 0 ]] && [[ $EXIT_CODE -le 3 ]]; then
    echo "✅ PASS: Exit code validation (got: $EXIT_CODE, expected: 0-3)"
    ((TESTS_PASSED++))
else
    echo "❌ FAIL: Exit code validation (got: $EXIT_CODE, expected: 0-3)"
    ((TESTS_FAILED++))
fi
echo ""

echo ""
echo "=== Test Summary ==="
echo ""
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed"
    exit 1
fi
