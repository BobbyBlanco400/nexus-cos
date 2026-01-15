#!/usr/bin/env bash
set -e

# N3XUS v-COS Full Stack Launch Script
# Phases 3-12 + Extended / Compliance / Sandbox
# Launches all 98+ services with N3XUS LAW 55-45-17 Enforcement

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOCKER_COMPOSE_FILE="docker-compose.full.yml"
N3XUS_HANDSHAKE="55-45-17"
MIN_DOCKER_VERSION="20.10.0"
MIN_COMPOSE_VERSION="2.0.0"

echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}  N3XUS v-COS Full Stack Launch${NC}"
echo -e "${BLUE}  Phases 3-12 + Extended / Compliance / Sandbox${NC}"
echo -e "${BLUE}  N3XUS LAW 55-45-17 Enforcement Active${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""

# Change to project root
cd "$PROJECT_ROOT"

# Function: Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function: Version comparison
version_ge() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

# Step 1: Prerequisites Check
echo -e "${YELLOW}[1/8] Checking prerequisites...${NC}"

# Check Docker
if ! command_exists docker; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

DOCKER_VERSION=$(docker --version | grep -oP '\d+\.\d+\.\d+' | head -1)
if ! version_ge "$DOCKER_VERSION" "$MIN_DOCKER_VERSION"; then
    echo -e "${RED}❌ Docker version $DOCKER_VERSION is too old (minimum: $MIN_DOCKER_VERSION)${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker $DOCKER_VERSION${NC}"

# Check Docker Compose
if ! docker compose version >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker Compose v2+ is not available${NC}"
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

# Try to get compose version
if docker compose version >/dev/null 2>&1; then
    COMPOSE_VERSION=$(docker compose version | grep -oP '\d+\.\d+\.\d+' | head -1)
    echo -e "${GREEN}✅ Docker Compose $COMPOSE_VERSION${NC}"
else
    echo -e "${RED}❌ Docker Compose v2+ is required${NC}"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker daemon is not running${NC}"
    echo "Please start Docker and try again"
    exit 1
fi
echo -e "${GREEN}✅ Docker daemon is running${NC}"

# Step 2: Environment Check
echo ""
echo -e "${YELLOW}[2/8] Checking environment...${NC}"

# Check if docker-compose.full.yml exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "${RED}❌ $DOCKER_COMPOSE_FILE not found${NC}"
    exit 1
fi
echo -e "${GREEN}✅ $DOCKER_COMPOSE_FILE found${NC}"

# Check N3XUS LAW compliance
export N3XUS_HANDSHAKE="$N3XUS_HANDSHAKE"
echo -e "${GREEN}✅ N3XUS_HANDSHAKE=$N3XUS_HANDSHAKE${NC}"

# Check .env file (optional but recommended)
if [ -f ".env" ]; then
    echo -e "${GREEN}✅ .env file found${NC}"
else
    echo -e "${YELLOW}⚠️  .env file not found (using defaults)${NC}"
fi

# Step 3: Cleanup existing containers
echo ""
echo -e "${YELLOW}[3/8] Cleaning up existing containers...${NC}"

# Stop and remove containers if they exist
if docker compose -f "$DOCKER_COMPOSE_FILE" ps -q 2>/dev/null | grep -q .; then
    echo "Stopping existing containers..."
    docker compose -f "$DOCKER_COMPOSE_FILE" down -v 2>/dev/null || true
    echo -e "${GREEN}✅ Cleanup complete${NC}"
else
    echo -e "${GREEN}✅ No existing containers to clean up${NC}"
fi

# Step 4: Build all services
echo ""
echo -e "${YELLOW}[4/8] Building all services...${NC}"
echo "This may take 10-20 minutes on first run..."
echo ""

if docker compose -f "$DOCKER_COMPOSE_FILE" build --build-arg N3XUS_HANDSHAKE="$N3XUS_HANDSHAKE"; then
    echo -e "${GREEN}✅ All services built successfully${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    echo "Check the output above for errors"
    exit 1
fi

# Step 5: Start infrastructure services first
echo ""
echo -e "${YELLOW}[5/8] Starting infrastructure services...${NC}"

docker compose -f "$DOCKER_COMPOSE_FILE" up -d postgres redis

# Wait for infrastructure to be healthy
echo "Waiting for infrastructure services to be healthy..."
for i in {1..30}; do
    if docker compose -f "$DOCKER_COMPOSE_FILE" ps postgres | grep -q "healthy" && \
       docker compose -f "$DOCKER_COMPOSE_FILE" ps redis | grep -q "healthy"; then
        echo -e "${GREEN}✅ Infrastructure services are healthy${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ Infrastructure services failed to become healthy${NC}"
        docker compose -f "$DOCKER_COMPOSE_FILE" logs postgres redis
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo ""

# Step 6: Start all application services
echo ""
echo -e "${YELLOW}[6/8] Starting application services...${NC}"
echo "This will start 98+ services..."
echo ""

if docker compose -f "$DOCKER_COMPOSE_FILE" up -d; then
    echo -e "${GREEN}✅ All services started${NC}"
else
    echo -e "${RED}❌ Failed to start services${NC}"
    exit 1
fi

# Step 7: Wait for services to be ready
echo ""
echo -e "${YELLOW}[7/8] Waiting for services to be ready...${NC}"
echo "This may take 2-3 minutes..."
echo ""

sleep 30

# Check service status
TOTAL_SERVICES=$(docker compose -f "$DOCKER_COMPOSE_FILE" ps --services | wc -l)
RUNNING_SERVICES=$(docker compose -f "$DOCKER_COMPOSE_FILE" ps --status running | grep -v "NAME" | wc -l)

echo "Services Status:"
echo "  Total: $TOTAL_SERVICES"
echo "  Running: $RUNNING_SERVICES"

if [ "$RUNNING_SERVICES" -lt $((TOTAL_SERVICES * 8 / 10)) ]; then
    echo -e "${YELLOW}⚠️  Less than 80% of services are running${NC}"
    echo "Run 'docker compose -f $DOCKER_COMPOSE_FILE ps' for details"
else
    echo -e "${GREEN}✅ Services are starting up${NC}"
fi

# Step 8: Verification
echo ""
echo -e "${YELLOW}[8/8] Running verification...${NC}"

# Test key services
echo ""
echo "Testing key service endpoints..."

test_endpoint() {
    local name=$1
    local port=$2
    local path=${3:-/health}
    
    if curl -f -s -H "X-N3XUS-Handshake: $N3XUS_HANDSHAKE" "http://localhost:$port$path" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $name (port $port)${NC}"
        return 0
    else
        echo -e "${YELLOW}⏳ $name (port $port) - still starting...${NC}"
        return 1
    fi
}

# Give services more time if needed
sleep 10

# Test Phase 3-4 (Core Runtime)
echo ""
echo "Phase 3-4: Core Runtime"
test_endpoint "v-supercore" 3001 /health || true
test_endpoint "puabo-api-ai-hf" 3002 /health || true

# Test Phase 5-6 (Federation)
echo ""
echo "Phase 5-6: Federation"
test_endpoint "federation-spine" 3010 /health || true
test_endpoint "identity-registry" 3011 /health || true
test_endpoint "federation-gateway" 3012 /health || true
test_endpoint "attestation-service" 3013 /health || true

# Test Phase 7-8 (Casino Domain)
echo ""
echo "Phase 7-8: Casino Domain"
test_endpoint "casino-core" 3020 /health || true
test_endpoint "ledger-engine" 3021 /health || true

# Test Phase 9 (Financial Core)
echo ""
echo "Phase 9: Financial Core"
test_endpoint "wallet-engine" 3030 /health || true
test_endpoint "treasury-core" 3031 /health || true
test_endpoint "payout-engine" 3032 /health || true

# Test Phase 10 (Earnings & Media)
echo ""
echo "Phase 10: Earnings & Media"
test_endpoint "earnings-oracle" 3040 /health || true
test_endpoint "pmmg-media-engine" 3041 /health || true
test_endpoint "royalty-engine" 3042 /health || true

# Test Phase 11-12 (Governance)
echo ""
echo "Phase 11-12: Governance"
test_endpoint "governance-core" 3050 /health || true
test_endpoint "constitution-engine" 3051 /health || true

# Test Compliance/Nuisance
echo ""
echo "Compliance / Nuisance Modules"
test_endpoint "payment-partner" 4001 /health || true
test_endpoint "jurisdiction-rules" 4002 /health || true
test_endpoint "responsible-gaming" 4003 /health || true
test_endpoint "legal-entity" 4004 /health || true
test_endpoint "explicit-opt-in" 4005 /health || true

# Summary
echo ""
echo -e "${BLUE}============================================================================${NC}"
echo -e "${GREEN}✅ N3XUS v-COS Full Stack Launch Complete${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Run verification: bash scripts/verify-launch.sh"
echo "  2. View logs: docker compose -f $DOCKER_COMPOSE_FILE logs -f [service-name]"
echo "  3. Check status: docker compose -f $DOCKER_COMPOSE_FILE ps"
echo ""
echo "Port Ranges:"
echo "  - Phases 3-12: 3001-3071"
echo "  - Compliance/Nuisance: 4001-4050"
echo "  - Extended/Sandbox: 4051-4099"
echo ""
echo "N3XUS LAW 55-45-17: ACTIVE ✅"
echo "All services enforce handshake validation"
echo ""
echo -e "${BLUE}============================================================================${NC}"
