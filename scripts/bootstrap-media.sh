#!/usr/bin/env bash
# Bootstrap Phase 8: Media Engine (PMMG)
# N3XUS LAW 55-45-17 Enforced
set -e

echo "=========================================="
echo "Phase 8 Bootstrap: Media Engine"
echo "=========================================="
echo ""

echo "🔐 Verifying N3XUS LAW..."
if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then
  echo "❌ LAW VIOLATION"
  exit 1
fi

echo "✅ N3XUS LAW VERIFIED"
echo ""

echo "🚀 Building Media Services..."
echo "  - pmmg-media-engine"
echo "  - royalty-engine"
echo ""

docker compose -f docker-compose.final.yml build \
  pmmg-media-engine \
  royalty-engine

echo ""
echo "🐳 Starting Media Services..."
docker compose -f docker-compose.final.yml up -d \
  pmmg-media-engine \
  royalty-engine

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

echo ""
echo "✅ PHASE 8 COMPLETE"
echo ""
echo "Media services running:"
docker ps --filter "name=pmmg" --filter "name=royalty" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
