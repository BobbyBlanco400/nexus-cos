#!/usr/bin/env bash
# Bootstrap Phase 10: Creator Payouts
# N3XUS LAW 55-45-17 Enforced
set -e

echo "=========================================="
echo "Phase 10 Bootstrap: Creator Payouts"
echo "=========================================="
echo ""

echo "🔐 Verifying N3XUS LAW..."
if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then
  echo "❌ LAW VIOLATION"
  exit 1
fi

echo "✅ N3XUS LAW VERIFIED"
echo ""

echo "🚀 Building Payout Services..."
echo "  - payout-engine"
echo "  - earnings-oracle"
echo ""

docker compose -f docker-compose.final.yml build \
  payout-engine \
  earnings-oracle

echo ""
echo "🐳 Starting Payout Services..."
docker compose -f docker-compose.final.yml up -d \
  payout-engine \
  earnings-oracle

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

echo ""
echo "✅ PHASE 10 COMPLETE"
echo ""
echo "Payout services running:"
docker ps --filter "name=payout" --filter "name=earnings" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
