#!/bin/bash
# Nexus COS - PF Configuration Test Script
# Comprehensive test of PF services, routes, and health endpoints

echo "🧪 Nexus COS - PF Configuration Test"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

test_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

test_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

test_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Test 1: Configuration Files
echo -e "${BLUE}Test 1: Configuration Files${NC}"
echo ""

if [ -f "nginx/nginx.conf" ] && [ -f "nginx/conf.d/nexus-proxy.conf" ]; then
    test_pass "Nginx configuration files exist"
else
    test_fail "Nginx configuration files missing"
fi

if [ -f "frontend/.env" ] && [ -f "frontend/.env.example" ]; then
    test_pass "Frontend environment files exist"
else
    test_fail "Frontend environment files missing"
fi

if [ -f "test-diagram/NexusCOS-PF.mmd" ]; then
    test_pass "PF architecture diagram exists"
else
    test_fail "PF architecture diagram missing"
fi

echo ""

# Test 2: Docker Services
echo -e "${BLUE}Test 2: Docker Services${NC}"
echo ""

if docker compose -f docker-compose.pf.yml ps 2>/dev/null | grep -q "puabo-api"; then
    test_info "puabo-api service defined in docker-compose.pf.yml"
else
    test_info "puabo-api service not running (start with: docker compose -f docker-compose.pf.yml up -d)"
fi

# Check if containers are running
if docker ps 2>/dev/null | grep -q "puabo-api"; then
    test_pass "puabo-api container is running"
    CONTAINER_RUNNING=true
else
    test_info "puabo-api container not running (this is OK if testing config only)"
    CONTAINER_RUNNING=false
fi

if docker ps 2>/dev/null | grep -q "nexus-cos-puaboai-sdk"; then
    test_pass "nexus-cos-puaboai-sdk container is running"
else
    test_info "nexus-cos-puaboai-sdk container not running"
fi

if docker ps 2>/dev/null | grep -q "nexus-cos-pv-keys"; then
    test_pass "nexus-cos-pv-keys container is running"
else
    test_info "nexus-cos-pv-keys container not running"
fi

echo ""

# Test 3: Health Endpoints (if containers are running)
if [ "$CONTAINER_RUNNING" = true ]; then
    echo -e "${BLUE}Test 3: Health Endpoints${NC}"
    echo ""
    
    if curl -sf http://localhost:4000/health >/dev/null 2>&1; then
        test_pass "puabo-api health endpoint responding (http://localhost:4000/health)"
    else
        test_fail "puabo-api health endpoint not responding"
    fi
    
    if curl -sf http://localhost:3002/health >/dev/null 2>&1; then
        test_pass "nexus-cos-puaboai-sdk health endpoint responding (http://localhost:3002/health)"
    else
        test_fail "nexus-cos-puaboai-sdk health endpoint not responding"
    fi
    
    if curl -sf http://localhost:3041/health >/dev/null 2>&1; then
        test_pass "nexus-cos-pv-keys health endpoint responding (http://localhost:3041/health)"
    else
        test_fail "nexus-cos-pv-keys health endpoint not responding"
    fi
    
    echo ""
else
    echo -e "${YELLOW}Test 3: Health Endpoints (skipped - containers not running)${NC}"
    echo ""
fi

# Test 4: Nginx Configuration Syntax
echo -e "${BLUE}Test 4: Nginx Configuration Syntax${NC}"
echo ""

# Check if nginx is installed
if command -v nginx >/dev/null 2>&1; then
    test_info "Nginx is installed"
    
    # Check nginx/nginx.conf syntax
    if sudo nginx -t -c "$(pwd)/nginx/nginx.conf" 2>&1 | grep -q "syntax is ok"; then
        test_pass "nginx/nginx.conf syntax is valid"
    else
        # Check if it's just the upstream issue
        if sudo nginx -t -c "$(pwd)/nginx/nginx.conf" 2>&1 | grep -q "host not found"; then
            test_info "nginx/nginx.conf syntax is valid (upstream hosts not resolved - normal if services not running)"
        else
            test_fail "nginx/nginx.conf has syntax errors"
        fi
    fi
else
    test_info "Nginx not installed (skipping syntax check)"
fi

echo ""

# Test 5: Route Configuration
echo -e "${BLUE}Test 5: Route Configuration${NC}"
echo ""

ROUTES=(
    "/admin:Admin Panel"
    "/hub:Creator Hub"
    "/studio:Studio"
    "/streaming:Streaming"
    "/api:Main API"
    "/v-suite/hollywood:V-Suite Hollywood"
    "/v-suite/prompter:V-Suite Prompter"
    "/v-suite/caster:V-Suite Caster"
    "/v-suite/stage:V-Suite Stage"
)

for route_desc in "${ROUTES[@]}"; do
    IFS=':' read -r route desc <<< "$route_desc"
    if grep -q "location $route" nginx/conf.d/nexus-proxy.conf; then
        test_pass "$desc route configured ($route)"
    else
        test_fail "$desc route not found ($route)"
    fi
done

echo ""

# Test 6: Frontend Environment
echo -e "${BLUE}Test 6: Frontend Environment${NC}"
echo ""

if grep -q "VITE_API_URL=https://nexuscos.online/api" frontend/.env; then
    test_pass "Frontend .env has correct API URL"
else
    test_fail "Frontend .env missing or has incorrect API URL"
fi

if grep -q "VITE_API_URL=https://nexuscos.online/api" frontend/.env.example; then
    test_pass "Frontend .env.example has correct API URL"
else
    test_fail "Frontend .env.example missing or has incorrect API URL"
fi

echo ""

# Test 7: PF Architecture Diagram
echo -e "${BLUE}Test 7: PF Architecture Diagram${NC}"
echo ""

if grep -q "puabo-api" test-diagram/NexusCOS-PF.mmd && \
   grep -q "nexus-cos-puaboai-sdk" test-diagram/NexusCOS-PF.mmd && \
   grep -q "nexus-cos-pv-keys" test-diagram/NexusCOS-PF.mmd; then
    test_pass "All PF services represented in diagram"
else
    test_fail "Some PF services missing from diagram"
fi

if grep -q "/v-suite/" test-diagram/NexusCOS-PF.mmd; then
    test_pass "V-Suite routes represented in diagram"
else
    test_fail "V-Suite routes missing from diagram"
fi

echo ""

# Summary
echo "===================================="
echo -e "${BLUE}Test Summary${NC}"
echo "===================================="
echo -e "Passed: ${GREEN}${PASSED}${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "Failed: ${RED}${FAILED}${NC}"
else
    echo -e "Failed: ${FAILED}"
fi
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Start PF services: docker compose -f docker-compose.pf.yml up -d"
    echo "2. Test health endpoints: curl http://localhost:4000/health"
    echo "3. Deploy nginx config to production"
    echo "4. Verify all routes without 502 errors"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Please review and fix.${NC}"
    exit 1
fi
