#!/usr/bin/env bash
set -e

# N3XUS Phase 3-4 Ignition: Core Runtime
# Services: v-supercore, puabo-api-ai-hf

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== N3XUS v-COS Phase 3 & 4 Ignition ==="
echo "Core Runtime: v-supercore, puabo-api-ai-hf"
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

# Start Phase 3-4 services
echo "Starting Phase 3-4 services..."
docker compose -f "$COMPOSE_FILE" up -d v-supercore puabo-api-ai-hf

# Wait for services
echo "Waiting for services to start..."
sleep 5

# Verify services
echo ""
echo "Verifying services..."
if curl -f -s http://localhost:3001/health > /dev/null 2>&1; then
    echo "✅ v-supercore (port 3001)"
else
    echo "⏳ v-supercore (port 3001) - still starting..."
fi

if curl -f -s http://localhost:3002/health > /dev/null 2>&1; then
    echo "✅ puabo-api-ai-hf (port 3002)"
else
    echo "⏳ puabo-api-ai-hf (port 3002) - still starting..."
fi

echo ""
echo "✅ Phase 3-4 ignition complete"
echo "Services available on ports 3001-3002"
