#!/bin/bash
# ==============================================================================
# Nexus COS - PF v2025.10.01 PUABO NEXUS Fleet Configuration Test
# ==============================================================================
# Purpose: Test the PUABO NEXUS fleet compose file and deployment scripts
# ==============================================================================

echo "🧪 PF v2025.10.01 - PUABO NEXUS Fleet Configuration Test"
echo "========================================================="
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

# ==============================================================================
# Test 1: Required Files Exist
# ==============================================================================
echo -e "${BLUE}Test 1: Required Files${NC}"
echo ""

if [ -f "docker-compose.pf.nexus.yml" ]; then
    test_pass "docker-compose.pf.nexus.yml exists"
else
    test_fail "docker-compose.pf.nexus.yml is missing"
fi

if [ -f "scripts/deploy_hybrid_fullstack_pf.sh" ]; then
    test_pass "scripts/deploy_hybrid_fullstack_pf.sh exists"
else
    test_fail "scripts/deploy_hybrid_fullstack_pf.sh is missing"
fi

if [ -f "scripts/update-nginx-puabo-nexus-routes.sh" ]; then
    test_pass "scripts/update-nginx-puabo-nexus-routes.sh exists"
else
    test_fail "scripts/update-nginx-puabo-nexus-routes.sh is missing"
fi

if [ -x "scripts/deploy_hybrid_fullstack_pf.sh" ]; then
    test_pass "deploy_hybrid_fullstack_pf.sh is executable"
else
    test_fail "deploy_hybrid_fullstack_pf.sh is not executable"
fi

if [ -x "scripts/update-nginx-puabo-nexus-routes.sh" ]; then
    test_pass "update-nginx-puabo-nexus-routes.sh is executable"
else
    test_fail "update-nginx-puabo-nexus-routes.sh is not executable"
fi

echo ""

# ==============================================================================
# Test 2: Docker Compose Validation
# ==============================================================================
echo -e "${BLUE}Test 2: Docker Compose Validation${NC}"
echo ""

if command -v docker &> /dev/null; then
    test_info "Docker is installed"
    
    if docker compose -f docker-compose.pf.nexus.yml config > /dev/null 2>&1; then
        test_pass "docker-compose.pf.nexus.yml syntax is valid"
    else
        test_fail "docker-compose.pf.nexus.yml has syntax errors"
    fi
    
    # Check services are defined
    services=$(docker compose -f docker-compose.pf.nexus.yml config --services 2>/dev/null)
    if echo "$services" | grep -q "ai-dispatch"; then
        test_pass "ai-dispatch service is defined"
    else
        test_fail "ai-dispatch service is not defined"
    fi
    
    if echo "$services" | grep -q "driver-backend"; then
        test_pass "driver-backend service is defined"
    else
        test_fail "driver-backend service is not defined"
    fi
    
    if echo "$services" | grep -q "fleet-manager"; then
        test_pass "fleet-manager service is defined"
    else
        test_fail "fleet-manager service is not defined"
    fi
    
    if echo "$services" | grep -q "route-optimizer"; then
        test_pass "route-optimizer service is defined"
    else
        test_fail "route-optimizer service is not defined"
    fi
else
    test_fail "Docker is not installed - cannot validate compose file"
fi

echo ""

# ==============================================================================
# Test 3: Port Mappings
# ==============================================================================
echo -e "${BLUE}Test 3: Port Mappings${NC}"
echo ""

if grep -q "127.0.0.1:9001:8080" docker-compose.pf.nexus.yml; then
    test_pass "AI Dispatch port mapping (9001:8080) is configured"
else
    test_fail "AI Dispatch port mapping is missing or incorrect"
fi

if grep -q "127.0.0.1:9002:8080" docker-compose.pf.nexus.yml; then
    test_pass "Driver Backend port mapping (9002:8080) is configured"
else
    test_fail "Driver Backend port mapping is missing or incorrect"
fi

if grep -q "127.0.0.1:9003:8080" docker-compose.pf.nexus.yml; then
    test_pass "Fleet Manager port mapping (9003:8080) is configured"
else
    test_fail "Fleet Manager port mapping is missing or incorrect"
fi

if grep -q "127.0.0.1:9004:8080" docker-compose.pf.nexus.yml; then
    test_pass "Route Optimizer port mapping (9004:8080) is configured"
else
    test_fail "Route Optimizer port mapping is missing or incorrect"
fi

echo ""

# ==============================================================================
# Test 4: Deploy Script Configuration
# ==============================================================================
echo -e "${BLUE}Test 4: Deploy Script Configuration${NC}"
echo ""

if grep -q "COMPOSE_NEXUS_FILE" scripts/deploy_hybrid_fullstack_pf.sh; then
    test_pass "Deploy script references COMPOSE_NEXUS_FILE"
else
    test_fail "Deploy script does not reference COMPOSE_NEXUS_FILE"
fi

if grep -q "NGINX_ROUTE_UPDATER" scripts/deploy_hybrid_fullstack_pf.sh; then
    test_pass "Deploy script references NGINX_ROUTE_UPDATER"
else
    test_fail "Deploy script does not reference NGINX_ROUTE_UPDATER"
fi

if grep -q "NETWORK_NAME" scripts/deploy_hybrid_fullstack_pf.sh; then
    test_pass "Deploy script references NETWORK_NAME"
else
    test_fail "Deploy script does not reference NETWORK_NAME"
fi

if grep -q "docker-compose.pf.nexus.yml" scripts/deploy_hybrid_fullstack_pf.sh; then
    test_pass "Deploy script mentions NEXUS compose file"
else
    test_fail "Deploy script does not mention NEXUS compose file"
fi

echo ""

# ==============================================================================
# Test 5: Nginx Route Configuration
# ==============================================================================
echo -e "${BLUE}Test 5: Nginx Route Configuration${NC}"
echo ""

if grep -q "/puabo-nexus/dispatch" scripts/update-nginx-puabo-nexus-routes.sh; then
    test_pass "Route updater includes /puabo-nexus/dispatch route"
else
    test_fail "Route updater missing /puabo-nexus/dispatch route"
fi

if grep -q "/puabo-nexus/driver" scripts/update-nginx-puabo-nexus-routes.sh; then
    test_pass "Route updater includes /puabo-nexus/driver route"
else
    test_fail "Route updater missing /puabo-nexus/driver route"
fi

if grep -q "/puabo-nexus/fleet" scripts/update-nginx-puabo-nexus-routes.sh; then
    test_pass "Route updater includes /puabo-nexus/fleet route"
else
    test_fail "Route updater missing /puabo-nexus/fleet route"
fi

if grep -q "/puabo-nexus/routes" scripts/update-nginx-puabo-nexus-routes.sh; then
    test_pass "Route updater includes /puabo-nexus/routes route"
else
    test_fail "Route updater missing /puabo-nexus/routes route"
fi

if grep -q "127.0.0.1:9001" scripts/update-nginx-puabo-nexus-routes.sh; then
    test_pass "Route updater proxies to 127.0.0.1:9001"
else
    test_fail "Route updater missing proxy to 127.0.0.1:9001"
fi

if grep -q "127.0.0.1:9002" scripts/update-nginx-puabo-nexus-routes.sh; then
    test_pass "Route updater proxies to 127.0.0.1:9002"
else
    test_fail "Route updater missing proxy to 127.0.0.1:9002"
fi

if grep -q "127.0.0.1:9003" scripts/update-nginx-puabo-nexus-routes.sh; then
    test_pass "Route updater proxies to 127.0.0.1:9003"
else
    test_fail "Route updater missing proxy to 127.0.0.1:9003"
fi

if grep -q "127.0.0.1:9004" scripts/update-nginx-puabo-nexus-routes.sh; then
    test_pass "Route updater proxies to 127.0.0.1:9004"
else
    test_fail "Route updater missing proxy to 127.0.0.1:9004"
fi

echo ""

# ==============================================================================
# Test 6: Script Syntax Validation
# ==============================================================================
echo -e "${BLUE}Test 6: Script Syntax Validation${NC}"
echo ""

if bash -n scripts/deploy_hybrid_fullstack_pf.sh 2>/dev/null; then
    test_pass "deploy_hybrid_fullstack_pf.sh has valid bash syntax"
else
    test_fail "deploy_hybrid_fullstack_pf.sh has syntax errors"
fi

if bash -n scripts/update-nginx-puabo-nexus-routes.sh 2>/dev/null; then
    test_pass "update-nginx-puabo-nexus-routes.sh has valid bash syntax"
else
    test_fail "update-nginx-puabo-nexus-routes.sh has syntax errors"
fi

echo ""

# ==============================================================================
# Test 7: Documentation Updates
# ==============================================================================
echo -e "${BLUE}Test 7: Documentation Updates${NC}"
echo ""

if grep -q "docker-compose.pf.nexus.yml" PF_INDEX.md; then
    test_pass "PF_INDEX.md documents docker-compose.pf.nexus.yml"
else
    test_fail "PF_INDEX.md does not mention docker-compose.pf.nexus.yml"
fi

if grep -q "update-nginx-puabo-nexus-routes.sh" PF_INDEX.md; then
    test_pass "PF_INDEX.md documents update-nginx-puabo-nexus-routes.sh"
else
    test_fail "PF_INDEX.md does not mention update-nginx-puabo-nexus-routes.sh"
fi

if grep -q "9001\|9002\|9003\|9004" PF_INDEX.md; then
    test_pass "PF_INDEX.md documents fleet service ports"
else
    test_fail "PF_INDEX.md does not mention fleet service ports"
fi

echo ""

# ==============================================================================
# Summary
# ==============================================================================
echo "========================================================="
echo -e "${BLUE}Test Summary${NC}"
echo "========================================================="
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "✅ PF v2025.10.01 PUABO NEXUS Fleet is properly configured"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    echo ""
    echo "⚠️  Please review the failed tests and fix any issues"
    exit 1
fi
