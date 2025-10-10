#!/bin/bash
# Nexus COS Unified Deployment Test
# v2025 Final Unified Build
# Tests docker-compose.unified.yml configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Nexus COS Unified Deployment Test${NC}"
echo -e "${BLUE}v2025 Final Unified Build${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cd "$REPO_ROOT"

# Test 1: Validate docker-compose file syntax
echo -e "${YELLOW}Test 1: Validating docker-compose.unified.yml syntax${NC}"
if docker compose -f docker-compose.unified.yml config > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Docker Compose configuration is valid"
else
    echo -e "${RED}✗${NC} Docker Compose configuration has syntax errors"
    docker compose -f docker-compose.unified.yml config
    exit 1
fi
echo ""

# Test 2: Count services
echo -e "${YELLOW}Test 2: Counting services in unified configuration${NC}"
service_count=$(docker compose -f docker-compose.unified.yml config --services | wc -l)
echo "  Total services: $service_count"

if [ "$service_count" -ge 33 ]; then
    echo -e "${GREEN}✓${NC} Service count meets requirement (33+ services)"
else
    echo -e "${YELLOW}⚠${NC} Service count: $service_count (target: 33+)"
fi
echo ""

# Test 3: Verify network configuration
echo -e "${YELLOW}Test 3: Verifying network configuration${NC}"
if docker compose -f docker-compose.unified.yml config | grep -q "cos-net:"; then
    echo -e "${GREEN}✓${NC} cos-net network configured"
else
    echo -e "${RED}✗${NC} cos-net network not found"
fi
echo ""

# Test 4: Check for required infrastructure services
echo -e "${YELLOW}Test 4: Checking infrastructure services${NC}"
required_infra=(
    "nexus-cos-postgres"
    "nexus-cos-redis"
    "puabo-api"
    "nginx"
)

for service in "${required_infra[@]}"; do
    if docker compose -f docker-compose.unified.yml config --services | grep -q "^${service}$"; then
        echo -e "${GREEN}✓${NC} $service configured"
    else
        echo -e "${RED}✗${NC} $service missing"
    fi
done
echo ""

# Test 5: Verify V-Suite services
echo -e "${YELLOW}Test 5: Verifying V-Suite services${NC}"
vsuite_services=(
    "streamcore"
    "vscreen-hollywood"
    "v-caster-pro"
    "v-prompter-pro"
    "v-screen-pro"
)

for service in "${vsuite_services[@]}"; do
    if docker compose -f docker-compose.unified.yml config --services | grep -q "^${service}$"; then
        echo -e "${GREEN}✓${NC} $service configured"
    else
        echo -e "${RED}✗${NC} $service missing"
    fi
done
echo ""

# Test 6: Verify PUABO NEXUS Fleet services
echo -e "${YELLOW}Test 6: Verifying PUABO NEXUS Fleet services${NC}"
nexus_services=(
    "puabo-nexus-ai-dispatch"
    "puabo-nexus-driver-app"
    "puabo-nexus-fleet-manager"
    "puabo-nexus-route-optimizer"
)

for service in "${nexus_services[@]}"; do
    if docker compose -f docker-compose.unified.yml config --services | grep -q "^${service}$"; then
        echo -e "${GREEN}✓${NC} $service configured"
    else
        echo -e "${RED}✗${NC} $service missing"
    fi
done
echo ""

# Test 7: Verify PUABO DSP services
echo -e "${YELLOW}Test 7: Verifying PUABO DSP services${NC}"
dsp_services=(
    "puabo-dsp-metadata"
    "puabo-dsp-streaming"
    "puabo-dsp-upload"
)

for service in "${dsp_services[@]}"; do
    if docker compose -f docker-compose.unified.yml config --services | grep -q "^${service}$"; then
        echo -e "${GREEN}✓${NC} $service configured"
    else
        echo -e "${RED}✗${NC} $service missing"
    fi
done
echo ""

# Test 8: Verify PUABO BLAC services
echo -e "${YELLOW}Test 8: Verifying PUABO BLAC services${NC}"
blac_services=(
    "puabo-blac-loan"
    "puabo-blac-risk"
)

for service in "${blac_services[@]}"; do
    if docker compose -f docker-compose.unified.yml config --services | grep -q "^${service}$"; then
        echo -e "${GREEN}✓${NC} $service configured"
    else
        echo -e "${RED}✗${NC} $service missing"
    fi
done
echo ""

# Test 9: Verify PUABO NUKI Clothing services
echo -e "${YELLOW}Test 9: Verifying PUABO NUKI Clothing services${NC}"
nuki_services=(
    "puabo-nuki-inventory"
    "puabo-nuki-orders"
    "puabo-nuki-catalog"
    "puabo-nuki-shipping"
)

for service in "${nuki_services[@]}"; do
    if docker compose -f docker-compose.unified.yml config --services | grep -q "^${service}$"; then
        echo -e "${GREEN}✓${NC} $service configured"
    else
        echo -e "${RED}✗${NC} $service missing"
    fi
done
echo ""

# Test 10: Check port mappings
echo -e "${YELLOW}Test 10: Verifying port mappings${NC}"
echo "  Checking for port conflicts..."

# Extract all exposed ports
ports=$(docker compose -f docker-compose.unified.yml config | grep -E "^\s+-\s+\"[0-9]+:[0-9]+\"" | awk -F'"' '{print $2}' | cut -d':' -f1 | sort | uniq -d)

if [ -z "$ports" ]; then
    echo -e "${GREEN}✓${NC} No port conflicts detected"
else
    echo -e "${YELLOW}⚠${NC} Potential port conflicts found:"
    echo "$ports"
fi
echo ""

# Test 11: Verify health checks
echo -e "${YELLOW}Test 11: Verifying health check configurations${NC}"
healthcheck_count=$(docker compose -f docker-compose.unified.yml config | grep -c "healthcheck:" || true)
echo "  Services with health checks: $healthcheck_count"

if [ "$healthcheck_count" -ge 3 ]; then
    echo -e "${GREEN}✓${NC} Health checks configured for critical services"
else
    echo -e "${YELLOW}⚠${NC} Consider adding more health checks"
fi
echo ""

# Test 12: Verify volume configuration
echo -e "${YELLOW}Test 12: Verifying volume configuration${NC}"
volume_count=$(docker compose -f docker-compose.unified.yml config --volumes | wc -l)
echo "  Named volumes: $volume_count"

if [ "$volume_count" -ge 2 ]; then
    echo -e "${GREEN}✓${NC} Volumes configured for data persistence"
else
    echo -e "${YELLOW}⚠${NC} Limited volume configuration"
fi
echo ""

# Test 13: Verify service dependencies
echo -e "${YELLOW}Test 13: Checking service dependencies${NC}"
if docker compose -f docker-compose.unified.yml config | grep -q "depends_on:"; then
    echo -e "${GREEN}✓${NC} Service dependencies configured"
else
    echo -e "${YELLOW}⚠${NC} No service dependencies found"
fi
echo ""

# Test 14: Check environment variable references
echo -e "${YELLOW}Test 14: Checking environment variable usage${NC}"
if docker compose -f docker-compose.unified.yml config | grep -q "DB_HOST"; then
    echo -e "${GREEN}✓${NC} Database connection variables configured"
else
    echo -e "${YELLOW}⚠${NC} Database variables may not be configured"
fi

if docker compose -f docker-compose.unified.yml config | grep -q "REDIS_HOST"; then
    echo -e "${GREEN}✓${NC} Redis connection variables configured"
else
    echo -e "${YELLOW}⚠${NC} Redis variables may not be configured"
fi
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Service Count: $service_count"
echo "Health Checks: $healthcheck_count"
echo "Volumes: $volume_count"
echo ""

# List all services
echo -e "${BLUE}Configured Services:${NC}"
docker compose -f docker-compose.unified.yml config --services | sort | nl
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Unified Deployment Test Complete${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Ensure .env.pf is configured with production values"
echo "  2. Run: docker compose -f docker-compose.unified.yml build"
echo "  3. Run: docker compose -f docker-compose.unified.yml up -d"
echo "  4. Monitor: docker compose -f docker-compose.unified.yml ps"
echo "  5. Validate: bash pf-health-check.sh"
echo ""
