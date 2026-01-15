#!/usr/bin/env bash
# Bootstrap Phase 11-12: Governance & DAO
# N3XUS LAW 55-45-17 Enforced
set -e

echo "=========================================="
echo "Phase 11-12 Bootstrap: Governance & DAO"
echo "=========================================="
echo ""

echo "🔐 Verifying N3XUS LAW..."
if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then
  echo "❌ LAW VIOLATION"
  exit 1
fi

echo "✅ N3XUS LAW VERIFIED"
echo ""

echo "🚀 Building Governance Services..."
echo "  - governance-core"
echo "  - constitution-engine"
echo ""

docker compose -f docker-compose.final.yml build \
  governance-core \
  constitution-engine

echo ""
echo "🐳 Starting Governance Services..."
docker compose -f docker-compose.final.yml up -d \
  governance-core \
  constitution-engine

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

echo ""
echo "✅ PHASE 11-12 COMPLETE"
echo ""
echo "Governance services running:"
docker ps --filter "name=governance" --filter "name=constitution" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
