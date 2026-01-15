#!/usr/bin/env bash
set -e

# N3XUS Phase 7-8 Ignition: Casino Domain
# Services: casino-core, ledger-engine

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== N3XUS v-COS Phase 7-8 Ignition ==="
echo "Casino Domain: casino-core, ledger-engine"
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

# Start Phase 7-8 services
echo "Starting Phase 7-8 services..."
docker compose -f "$COMPOSE_FILE" up -d \
    casino-core \
    ledger-engine

# Wait for services
echo "Waiting for services to start..."
sleep 5

# Verify services
echo ""
echo "Verifying services..."
for port in 3020 3021; do
    if curl -f -s "http://localhost:$port/health" > /dev/null 2>&1; then
        echo "✅ Service on port $port"
    else
        echo "⏳ Service on port $port - still starting..."
    fi
done

echo ""
echo "✅ Phase 7-8 ignition complete"
echo "Services available on ports 3020-3021"
