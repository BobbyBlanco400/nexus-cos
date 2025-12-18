#!/bin/bash
# Test script to validate Nexus COS Platform API endpoints

echo "=== Nexus COS Platform API Endpoint Validation ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base URL (can be overridden with environment variable)
BASE_URL="${BASE_URL:-http://localhost:4000}"

echo "Testing against: $BASE_URL"
echo ""

# Test counter
PASSED=0
FAILED=0

# Function to test an endpoint
test_endpoint() {
    local endpoint=$1
    local expected_status=${2:-200}
    local description=$3
    
    echo -n "Testing $description ($endpoint)... "
    
    # Use timeout and capture both stdout and stderr
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 --connect-timeout 5 "$BASE_URL$endpoint" 2>&1)
    
    # Check if curl succeeded
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ FAIL${NC} (Connection error or timeout)"
        ((FAILED++))
    elif [ "$response" = "$expected_status" ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $response)"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC} (Expected HTTP $expected_status, got HTTP $response)"
        ((FAILED++))
    fi
}

# Test all documented API endpoints
echo "--- Core Health Endpoints ---"
test_endpoint "/health" 200 "Main health check"
test_endpoint "/api/health" 200 "API health check"
test_endpoint "/api/status" 200 "API status"

echo ""
echo "--- System Endpoints ---"
test_endpoint "/api" 200 "API root"
test_endpoint "/api/system/status" 200 "System status"

echo ""
echo "--- IMCUS Endpoints ---"
test_endpoint "/api/v1/imcus/001/status" 200 "IMCUS 001 status"
test_endpoint "/api/v1/imcus/001/nodes" 200 "IMCUS 001 nodes"

echo ""
echo "--- Module Endpoints ---"
test_endpoint "/api/creator-hub/status" 200 "Creator Hub status"
test_endpoint "/api/v-suite/status" 200 "V-Suite status"
test_endpoint "/api/puaboverse/status" 200 "PuaboVerse status"

echo ""
echo "--- Auth Endpoints ---"
test_endpoint "/api/auth" 200 "Auth root"

echo ""
echo "--- Beta Domain Tests (if BETA_URL is set) ---"
if [ -n "${BETA_URL:-}" ]; then
    ORIGINAL_BASE_URL="$BASE_URL"
    BASE_URL="$BETA_URL"
    
    test_endpoint "/health" 200 "Beta health check"
    test_endpoint "/api/health" 200 "Beta API health"
    test_endpoint "/api/status" 200 "Beta API status"
    test_endpoint "/api" 200 "Beta API root"
    
    BASE_URL="$ORIGINAL_BASE_URL"
else
    echo "Skipped (set BETA_URL to test beta domain)"
fi

echo ""
echo "=== Test Summary ==="
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Please check the output above.${NC}"
    exit 1
fi
