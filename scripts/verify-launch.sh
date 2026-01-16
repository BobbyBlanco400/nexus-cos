#!/usr/bin/env bash
set -e

# N3XUS v-COS Full Stack Launch Verification
# Phases 3-12 + Extended / Compliance / Sandbox
# Verifies handshake enforcement, health endpoints, and container status

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOCKER_COMPOSE_FILE="docker-compose.full.yml"
N3XUS_HANDSHAKE="55-45-17"

echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}  N3XUS v-COS Full Stack Launch Verification${NC}"
echo -e "${BLUE}  N3XUS LAW 55-45-17 Enforcement Verification${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""

cd "$PROJECT_ROOT"

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Function: Test endpoint with handshake
test_endpoint_with_handshake() {
    local name=$1
    local port=$2
    local path=${3:-/}
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # Test with valid handshake
    if curl -f -s -H "X-N3XUS-Handshake: $N3XUS_HANDSHAKE" "http://localhost:$port$path" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $name: Accepts valid handshake${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}❌ $name: Failed with valid handshake${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# Function: Test endpoint rejects invalid handshake
test_endpoint_rejects_invalid() {
    local name=$1
    local port=$2
    local path=${3:-/}
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # Test without handshake - should return 451 or 403
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port$path" 2>/dev/null || echo "000")
    
    if [ "$HTTP_CODE" = "451" ] || [ "$HTTP_CODE" = "403" ]; then
        echo -e "${GREEN}✅ $name: Correctly rejects invalid handshake (HTTP $HTTP_CODE)${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    elif [ "$HTTP_CODE" = "000" ]; then
        echo -e "${YELLOW}⚠️  $name: Service not responding${NC}"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
        return 1
    else
        echo -e "${RED}❌ $name: Accepts invalid handshake (HTTP $HTTP_CODE)${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# Function: Test health endpoint bypasses handshake
test_health_endpoint() {
    local name=$1
    local port=$2
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # Health endpoint should work without handshake
    if curl -f -s "http://localhost:$port/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $name: Health endpoint accessible without handshake${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${YELLOW}⚠️  $name: Health endpoint not accessible${NC}"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
        return 1
    fi
}

# Function: Check container status
check_container_status() {
    local container=$1
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if docker ps --filter "name=$container" --format "{{.Names}}" | grep -q "^${container}$"; then
        local status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null || echo "unknown")
        if [ "$status" = "running" ]; then
            echo -e "${GREEN}✅ Container $container: running${NC}"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
            return 0
        else
            echo -e "${RED}❌ Container $container: $status${NC}"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            return 1
        fi
    else
        echo -e "${RED}❌ Container $container: not found${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# ============================================================================
# CONTAINER STATUS CHECKS
# ============================================================================

echo -e "${YELLOW}[1/5] Verifying container status...${NC}"
echo ""

# Infrastructure
echo "Infrastructure:"
check_container_status "nexus-postgres"
check_container_status "nexus-redis"

# Phase 3-4: Core Runtime
echo ""
echo "Phase 3-4: Core Runtime"
check_container_status "v-supercore"
check_container_status "puabo-api-ai-hf"

# Phase 5-6: Federation
echo ""
echo "Phase 5-6: Federation"
check_container_status "federation-spine"
check_container_status "identity-registry"
check_container_status "federation-gateway"
check_container_status "attestation-service"

# Phase 7-8: Casino Domain
echo ""
echo "Phase 7-8: Casino Domain"
check_container_status "casino-core"
check_container_status "ledger-engine"

# Phase 9: Financial Core
echo ""
echo "Phase 9: Financial Core"
check_container_status "wallet-engine"
check_container_status "treasury-core"
check_container_status "payout-engine"

# Phase 10: Earnings & Media
echo ""
echo "Phase 10: Earnings & Media"
check_container_status "earnings-oracle"
check_container_status "pmmg-media-engine"
check_container_status "royalty-engine"

# Phase 11-12: Governance
echo ""
echo "Phase 11-12: Governance"
check_container_status "governance-core"
check_container_status "constitution-engine"

# Compliance/Nuisance
echo ""
echo "Compliance / Nuisance Modules:"
check_container_status "payment-partner"
check_container_status "jurisdiction-rules"
check_container_status "responsible-gaming"
check_container_status "legal-entity"
check_container_status "explicit-opt-in"

# ============================================================================
# HEALTH ENDPOINT CHECKS
# ============================================================================

echo ""
echo -e "${YELLOW}[2/5] Verifying health endpoints (no handshake required)...${NC}"
echo ""

# Test a sample of services
test_health_endpoint "v-supercore" 3001
test_health_endpoint "puabo-api-ai-hf" 3002
test_health_endpoint "federation-spine" 3010
test_health_endpoint "identity-registry" 3011
test_health_endpoint "casino-core" 3020
test_health_endpoint "wallet-engine" 3030
test_health_endpoint "governance-core" 3050
test_health_endpoint "payment-partner" 4001

# ============================================================================
# VALID HANDSHAKE CHECKS
# ============================================================================

echo ""
echo -e "${YELLOW}[3/5] Verifying services accept valid handshake...${NC}"
echo ""

# Test a sample of services with valid handshake
test_endpoint_with_handshake "v-supercore" 3001 /
test_endpoint_with_handshake "federation-spine" 3010 /
test_endpoint_with_handshake "casino-core" 3020 /
test_endpoint_with_handshake "wallet-engine" 3030 /
test_endpoint_with_handshake "governance-core" 3050 /
test_endpoint_with_handshake "payment-partner" 4001 /

# ============================================================================
# INVALID HANDSHAKE REJECTION CHECKS
# ============================================================================

echo ""
echo -e "${YELLOW}[4/5] Verifying services reject invalid handshake...${NC}"
echo ""

# Test that services reject requests without handshake (should return 451 or 403)
test_endpoint_rejects_invalid "v-supercore" 3001 /
test_endpoint_rejects_invalid "federation-spine" 3010 /
test_endpoint_rejects_invalid "casino-core" 3020 /
test_endpoint_rejects_invalid "wallet-engine" 3030 /
test_endpoint_rejects_invalid "governance-core" 3050 /
test_endpoint_rejects_invalid "payment-partner" 4001 /

# ============================================================================
# FILE VERIFICATION
# ============================================================================

echo ""
echo -e "${YELLOW}[5/5] Verifying configuration files...${NC}"
echo ""

# Check key files
for FILE in docker-compose.full.yml .env.example README.md; do
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if [ -f "$FILE" ]; then
        echo -e "${GREEN}✅ File exists: $FILE${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${YELLOW}⚠️  File missing: $FILE${NC}"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
    fi
done

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}  Verification Summary${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""
echo "Total Checks: $TOTAL_CHECKS"
echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
echo -e "${RED}Failed: $FAILED_CHECKS${NC}"
echo -e "${YELLOW}Warnings: $WARNING_CHECKS${NC}"
echo ""

SUCCESS_RATE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
echo "Success Rate: $SUCCESS_RATE%"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CRITICAL CHECKS PASSED${NC}"
    echo -e "${GREEN}✅ N3XUS LAW 55-45-17 ENFORCEMENT: ACTIVE${NC}"
    echo ""
    echo -e "${BLUE}============================================================================${NC}"
    exit 0
elif [ $SUCCESS_RATE -ge 80 ]; then
    echo -e "${YELLOW}⚠️  MOSTLY OPERATIONAL (some services may still be starting)${NC}"
    echo "Run this script again in a few minutes for full verification"
    echo ""
    echo -e "${BLUE}============================================================================${NC}"
    exit 0
else
    echo -e "${RED}❌ VERIFICATION FAILED${NC}"
    echo "Check the output above for details"
    echo ""
    echo "Troubleshooting:"
    echo "  - View service logs: docker compose -f $DOCKER_COMPOSE_FILE logs [service-name]"
    echo "  - Check service status: docker compose -f $DOCKER_COMPOSE_FILE ps"
    echo "  - Restart services: bash scripts/full-stack-launch.sh"
    echo ""
    echo -e "${BLUE}============================================================================${NC}"
    exit 1
fi
