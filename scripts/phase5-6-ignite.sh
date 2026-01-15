#!/usr/bin/env bash
set -e

# N3XUS Phase 5-6 Ignition: Federation
# Services: federation-spine, identity-registry, federation-gateway, attestation-service

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== N3XUS v-COS Phase 5-6 Ignition ==="
echo "Federation: federation-spine, identity-registry, federation-gateway, attestation-service"
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

# Start Phase 5-6 services
echo "Starting Phase 5-6 services..."
docker compose -f "$COMPOSE_FILE" up -d \
    federation-spine \
    identity-registry \
    federation-gateway \
    attestation-service

# Wait for services
echo "Waiting for services to start..."
sleep 5

# Verify services
echo ""
echo "Verifying services..."
for port in 3010 3011 3012 3013; do
    if curl -f -s "http://localhost:$port/health" > /dev/null 2>&1; then
        echo "✅ Service on port $port"
    else
        echo "⏳ Service on port $port - still starting..."
    fi
done

echo ""
echo "✅ Phase 5-6 ignition complete"
echo "Services available on ports 3010-3013"
