#!/usr/bin/env bash
set -e

# N3XUS Phase 11-12 Ignition: Governance
# Services: governance-core, constitution-engine

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== N3XUS v-COS Phase 11-12 Ignition ==="
echo "Governance: governance-core, constitution-engine"
echo ""

cd "$PROJECT_ROOT"

# Use full stack compose file
COMPOSE_FILE="docker-compose.full.yml"

# Export N3XUS handshake
export N3XUS_HANDSHAKE="55-45-17"

# Start infrastructure if not running
echo "Starting infrastructure services..."
docker compose -f "$COMPOSE_FILE" up -d postgres redis

# Wait for infrastructure
echo "Waiting for infrastructure to be healthy..."
sleep 10

# Start Phase 11-12 services
echo "Starting Phase 11-12 services..."
docker compose -f "$COMPOSE_FILE" up -d \
    governance-core \
    constitution-engine

# Wait for services
echo "Waiting for services to start..."
sleep 5

# Verify services
echo ""
echo "Verifying services..."
for port in 3050 3051; do
    if curl -f -s "http://localhost:$port/health" > /dev/null 2>&1; then
        echo "✅ Service on port $port"
    else
        echo "⏳ Service on port $port - still starting..."
    fi
done

echo ""
echo "✅ Phase 11-12 ignition complete"
echo "Services available on ports 3050-3051"
