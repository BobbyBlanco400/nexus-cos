#!/usr/bin/env bash
# Bootstrap Phase 9: Wallets & Treasury
# N3XUS LAW 55-45-17 Enforced
set -e

echo "=========================================="
echo "Phase 9 Bootstrap: Wallets & Treasury"
echo "=========================================="
echo ""

echo "🔐 Verifying N3XUS LAW..."
if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then
  echo "❌ LAW VIOLATION"
  exit 1
fi

echo "✅ N3XUS LAW VERIFIED"
echo ""

echo "🚀 Building Wallet & Treasury Services..."
echo "  - wallet-engine"
echo "  - treasury-core"
echo "  - ledger-engine"
echo ""

docker compose -f docker-compose.final.yml build \
  wallet-engine \
  treasury-core \
  ledger-engine

echo ""
echo "🐳 Starting Wallet & Treasury Services..."
docker compose -f docker-compose.final.yml up -d \
  wallet-engine \
  treasury-core \
  ledger-engine

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 15

echo ""
echo "✅ PHASE 9 COMPLETE"
echo ""
echo "Wallet & Treasury services running:"
docker ps --filter "name=wallet" --filter "name=treasury" --filter "name=ledger" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
