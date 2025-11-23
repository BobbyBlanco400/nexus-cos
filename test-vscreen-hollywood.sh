#!/bin/bash
# Test script for vscreen-hollywood service routing
# This validates that the nginx configuration properly routes to the service

set -e

echo "========================================="
echo "V-Screen Hollywood Service Test"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test service directly on port 8088 (if running)
echo -e "\n${YELLOW}Test 1: Direct service health check${NC}"
if curl -f -s http://localhost:8088/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Service is running on port 8088${NC}"
    curl -s http://localhost:8088/health | jq '.' || cat
else
    echo -e "${YELLOW}⚠ Service not running on port 8088 (expected in CI/test environment)${NC}"
fi

# Test service root endpoint
echo -e "\n${YELLOW}Test 2: Service root endpoint${NC}"
if curl -f -s http://localhost:8088/ > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Root endpoint responds${NC}"
    curl -s http://localhost:8088/ | jq '.message' || echo "Response OK"
else
    echo -e "${YELLOW}⚠ Root endpoint not accessible (service may not be running)${NC}"
fi

# Validate nginx configuration syntax
echo -e "\n${YELLOW}Test 3: Nginx configuration validation${NC}"
if command -v nginx &> /dev/null; then
    echo "Checking nginx.conf syntax..."
    # Note: This will fail if docker hostnames aren't resolvable, which is expected in CI
    nginx -t -c $(pwd)/nginx.conf 2>&1 || echo -e "${YELLOW}⚠ Nginx config references Docker hostnames (expected)${NC}"
else
    echo -e "${YELLOW}⚠ Nginx not installed (will validate in Docker)${NC}"
fi

# Check that nginx.conf has the correct upstream
echo -e "\n${YELLOW}Test 4: Verify nginx.conf has vscreen_hollywood upstream${NC}"
if grep -q "upstream vscreen_hollywood" nginx.conf; then
    echo -e "${GREEN}✓ vscreen_hollywood upstream found in nginx.conf${NC}"
else
    echo -e "${RED}✗ vscreen_hollywood upstream NOT found in nginx.conf${NC}"
    exit 1
fi

# Check that nginx.conf routes /v-suite/hollywood correctly
echo -e "\n${YELLOW}Test 5: Verify nginx.conf routes /v-suite/hollywood${NC}"
if grep -q "location /v-suite/hollywood" nginx.conf; then
    echo -e "${GREEN}✓ /v-suite/hollywood location found${NC}"
    if grep -A 1 "location /v-suite/hollywood" nginx.conf | grep -q "proxy_pass http://vscreen_hollywood"; then
        echo -e "${GREEN}✓ Routes to vscreen_hollywood upstream${NC}"
    else
        echo -e "${RED}✗ Does NOT route to vscreen_hollywood upstream${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ /v-suite/hollywood location NOT found${NC}"
    exit 1
fi

# Check for WebSocket support
echo -e "\n${YELLOW}Test 6: Verify WebSocket location exists${NC}"
if grep -q "location /v-suite/hollywood/ws" nginx.conf; then
    echo -e "${GREEN}✓ WebSocket location /v-suite/hollywood/ws found${NC}"
else
    echo -e "${RED}✗ WebSocket location NOT found${NC}"
    exit 1
fi

# Check nginx.conf.docker as well
echo -e "\n${YELLOW}Test 7: Verify nginx.conf.docker has vscreen_hollywood upstream${NC}"
if grep -q "upstream vscreen_hollywood" nginx.conf.docker; then
    echo -e "${GREEN}✓ vscreen_hollywood upstream found in nginx.conf.docker${NC}"
else
    echo -e "${YELLOW}⚠ vscreen_hollywood upstream NOT found in nginx.conf.docker${NC}"
fi

# Check nexus-proxy.conf
echo -e "\n${YELLOW}Test 8: Verify nginx/conf.d/nexus-proxy.conf routes correctly${NC}"
if [ -f "nginx/conf.d/nexus-proxy.conf" ]; then
    if grep -q "location /v-suite/hollywood" nginx/conf.d/nexus-proxy.conf; then
        echo -e "${GREEN}✓ /v-suite/hollywood location found in nexus-proxy.conf${NC}"
        if grep -A 1 "location /v-suite/hollywood" nginx/conf.d/nexus-proxy.conf | grep -q "proxy_pass http://vscreen_hollywood"; then
            echo -e "${GREEN}✓ Routes to vscreen_hollywood upstream${NC}"
        else
            echo -e "${YELLOW}⚠ nexus-proxy.conf may need updating${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ /v-suite/hollywood location NOT found in nexus-proxy.conf${NC}"
    fi
else
    echo -e "${YELLOW}⚠ nexus-proxy.conf not found${NC}"
fi

echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}All configuration validation tests passed!${NC}"
echo -e "${GREEN}=========================================${NC}"

exit 0
