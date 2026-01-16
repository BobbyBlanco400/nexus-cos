#!/usr/bin/env bash
set -e

# N3XUS Phase 9 Ignition: Financial Core
# Services: wallet-engine, treasury-core, payout-engine

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== N3XUS v-COS Phase 9 Ignition ==="
echo "Financial Core: wallet-engine, treasury-core, payout-engine"
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

# Start Phase 9 services
echo "Starting Phase 9 services..."
docker compose -f "$COMPOSE_FILE" up -d \
    wallet-engine \
    treasury-core \
    payout-engine

# Wait for services
echo "Waiting for services to start..."
sleep 5

# Verify services
echo ""
echo "Verifying services..."
for port in 3030 3031 3032; do
    if curl -f -s "http://localhost:$port/health" > /dev/null 2>&1; then
        echo "✅ Service on port $port"
    else
        echo "⏳ Service on port $port - still starting..."
    fi
done

echo ""
echo "✅ Phase 9 ignition complete"
echo "Services available on ports 3030-3032"
