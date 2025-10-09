#!/bin/bash
# Test script for API routing fix
# Tests all API endpoints to verify they're working

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="${1:-http://localhost:3001}"
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

echo "================================================"
echo "API Routing Fix - Test Suite"
echo "================================================"
echo "Testing against: $BASE_URL"
echo ""

# Test function
test_endpoint() {
    local name=$1
    local endpoint=$2
    local expected_status=${3:-200}
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testing $name... "
    
    response=$(curl -s -w "\n%{http_code}" "$BASE_URL$endpoint")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" -eq "$expected_status" ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $http_code)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        if [ -n "$body" ]; then
            echo "  Response: $(echo $body | head -c 100)..."
        fi
    else
        echo -e "${RED}✗ FAIL${NC} (Expected $expected_status, got $http_code)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        if [ -n "$body" ]; then
            echo "  Response: $body"
        fi
    fi
    echo ""
}

# Run tests
echo "Running tests..."
echo ""

test_endpoint "Health Check" "/health"
test_endpoint "API Info" "/api"
test_endpoint "System Status" "/api/system/status"
test_endpoint "Auth Route" "/api/auth"
test_endpoint "Users Route" "/api/users"
test_endpoint "Service Health (auth)" "/api/services/auth/health"
test_endpoint "Service Health (unknown)" "/api/services/unknown/health"
test_endpoint "Creator Hub Status" "/api/creator-hub/status"
test_endpoint "V-Suite Status" "/api/v-suite/status"
test_endpoint "PuaboVerse Status" "/api/puaboverse/status"

# Summary
echo "================================================"
echo "Test Summary"
echo "================================================"
echo "Total Tests:  $TOTAL_TESTS"
echo -e "Passed:       ${GREEN}$PASSED_TESTS${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "Failed:       ${RED}$FAILED_TESTS${NC}"
else
    echo -e "Failed:       ${GREEN}$FAILED_TESTS${NC}"
fi
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed!${NC}"
    exit 1
fi
