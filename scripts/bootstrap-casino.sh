#!/usr/bin/env bash
# Bootstrap Phase 7: Casino Engine
# N3XUS LAW 55-45-17 Enforced
set -e

echo "=========================================="
echo "Phase 7 Bootstrap: Casino Engine"
echo "=========================================="
echo ""

echo "🔐 Verifying N3XUS LAW..."
if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then
  echo "❌ LAW VIOLATION"
  exit 1
fi

echo "✅ N3XUS LAW VERIFIED"
echo ""

echo "🚀 Building Casino Services..."
echo "  - casino-core"
echo ""

docker compose -f docker-compose.final.yml build casino-core

echo ""
echo "🐳 Starting Casino Services..."
docker compose -f docker-compose.final.yml up -d casino-core

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

echo ""
echo "✅ PHASE 7 COMPLETE"
echo ""
echo "Casino services running:"
docker ps --filter "name=casino" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
