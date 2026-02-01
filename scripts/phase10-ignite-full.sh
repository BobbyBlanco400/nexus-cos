#!/usr/bin/env bash
set -e

# N3XUS Phase 10 Ignition: Earnings & Media + V-Suite
# Services: earnings-oracle, pmmg-media-engine, royalty-engine
#           v-caster-pro, v-screen-pro, vscreen-hollywood

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== N3XUS v-COS Phase 10 Full Ignition ==="
echo "Services: Earnings/Media + V-Suite Pro"
echo ""

cd "$PROJECT_ROOT"
COMPOSE_FILE="docker-compose.full.yml"
export N3XUS_HANDSHAKE="55-45-17"

echo "Starting infrastructure services..."
docker-compose -f "$COMPOSE_FILE" up -d postgres redis

echo "Starting Phase 10 services..."
# We don't force build here to save time if images exist, but ensure they are up
docker-compose -f "$COMPOSE_FILE" up -d \
    earnings-oracle \
    pmmg-media-engine \
    royalty-engine \
    v-caster-pro \
    v-screen-pro \
    vscreen-hollywood

echo "Waiting for services to start..."
sleep 15

echo "Verifying services..."
for port in 3040 3041 3042 4070 4072 4073; do
    if curl -f -s -m 2 "http://localhost:$port/health" > /dev/null 2>&1; then
        echo "✅ Service on port $port is ONLINE"
    else
        echo "⏳ Service on port $port is starting or failed check"
    fi
done

echo ""
echo "✅ Phase 10 Full Ignition command sent."
