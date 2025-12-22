#!/bin/bash
# ==============================================================================
# Test Script for nexus_cos_health_check.sh
# ==============================================================================
# Purpose: Verify the health check script functions correctly
# ==============================================================================

set +e  # Don't exit on errors, we want to run all tests

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0
SCRIPT_PATH="./nexus_cos_health_check.sh"

echo "======================================"
echo "Testing nexus_cos_health_check.sh"
echo "======================================"
echo ""

# Test 1: Verify script exists
echo -n "Test 1: Script exists... "
if [ -f "$SCRIPT_PATH" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Script not found at $SCRIPT_PATH"
    ((FAILED++))
    exit 1
fi

# Test 2: Verify script is executable
echo -n "Test 2: Script is executable... "
if [ -x "$SCRIPT_PATH" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Script is not executable"
    ((FAILED++))
fi

# Test 3: Verify script has correct shebang
echo -n "Test 3: Script has bash shebang... "
if head -n 1 "$SCRIPT_PATH" | grep -q "#!/bin/bash"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Script does not have proper bash shebang"
    ((FAILED++))
fi

# Test 4: Verify syntax is correct
echo -n "Test 4: Script syntax is valid... "
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Script has syntax errors"
    ((FAILED++))
fi

# Test 5: Verify script has proper header
echo -n "Test 5: Script has proper header... "
if grep -q "NΞ3XUS·COS Health Check & Repair Script" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Script header is missing or incorrect"
    ((FAILED++))
fi

# Test 6: Verify LOG_DIR configuration exists
echo -n "Test 6: LOG_DIR configuration exists... "
if grep -q "LOG_DIR=" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "LOG_DIR configuration is missing"
    ((FAILED++))
fi

# Test 7: Verify MAX_WAIT_TIME configuration exists
echo -n "Test 7: MAX_WAIT_TIME configuration exists... "
if grep -q "MAX_WAIT_TIME=" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "MAX_WAIT_TIME configuration is missing"
    ((FAILED++))
fi

# Test 8: Verify wait_for_healthy function exists
echo -n "Test 8: wait_for_healthy function exists... "
if grep -q "wait_for_healthy()" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "wait_for_healthy function is missing"
    ((FAILED++))
fi

# Test 9: Verify get_container_health function exists
echo -n "Test 9: get_container_health function exists... "
if grep -q "get_container_health()" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "get_container_health function is missing"
    ((FAILED++))
fi

# Test 10: Verify get_container_state function exists
echo -n "Test 10: get_container_state function exists... "
if grep -q "get_container_state()" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "get_container_state function is missing"
    ((FAILED++))
fi

# Test 11: Verify script checks for "starting" state
echo -n "Test 11: Script handles 'starting' state... "
if grep -q "starting" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Script does not handle 'starting' state"
    ((FAILED++))
fi

# Test 12: Verify script saves container logs
echo -n "Test 12: Script saves container logs... "
if grep -q "docker logs" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Script does not save container logs"
    ((FAILED++))
fi

# Test 13: Verify script restarts containers
echo -n "Test 13: Script restarts containers... "
if grep -q "docker restart" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Script does not restart containers"
    ((FAILED++))
fi

# Test 14: Verify script waits after restart
echo -n "Test 14: Script waits after restart... "
if grep -q "wait_for_healthy" "$SCRIPT_PATH" && grep -q "MAX_WAIT_TIME" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Script does not properly wait after restart"
    ((FAILED++))
fi

# Test 15: Verify script checks healthcheck status
echo -n "Test 15: Script checks healthcheck status... "
if grep -q "Health.Status" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Script does not check Docker healthcheck status"
    ((FAILED++))
fi

# Test 16: Verify script distinguishes between "starting" and "unhealthy"
echo -n "Test 16: Script distinguishes transitional states... "
if grep -q "exited" "$SCRIPT_PATH" && grep -q "dead" "$SCRIPT_PATH" && grep -q "paused" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Script does not check for problematic states (exited, dead, paused)"
    ((FAILED++))
fi

# Test 17: Verify script handles containers without healthchecks
echo -n "Test 17: Script handles containers without healthchecks... "
if grep -q "none" "$SCRIPT_PATH" && grep -q "running" "$SCRIPT_PATH"; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    echo "Script does not handle containers without healthchecks"
    ((FAILED++))
fi

# Summary
echo ""
echo "======================================"
echo "Test Summary"
echo "======================================"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed.${NC}"
    exit 1
fi
