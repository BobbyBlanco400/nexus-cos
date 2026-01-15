#!/usr/bin/env bash
# Launch Nuisance Services
# N3XUS LAW 55-45-17 Enforced
set -e

echo "=========================================="
echo "Nuisance Services Launch"
echo "=========================================="
echo ""

echo "🔐 Verifying N3XUS LAW..."
if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then
  echo "❌ LAW VIOLATION"
  exit 1
fi

echo "✅ N3XUS LAW VERIFIED"
echo ""

echo "🔹 Launching Nuisance Docker stack..."
docker compose -f docker-compose.codespaces.yml up -d --build \
  payment-partner \
  jurisdiction-rules \
  responsible-gaming \
  legal-entity \
  explicit-opt-in

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

echo ""
echo "✅ Nuisance services launched"
echo ""
echo "Services running:"
docker ps --filter "name=payment-partner" \
  --filter "name=jurisdiction-rules" \
  --filter "name=responsible-gaming" \
  --filter "name=legal-entity" \
  --filter "name=explicit-opt-in" \
  --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
