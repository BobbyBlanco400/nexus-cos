#!/usr/bin/env bash
# Bootstrap Phase 5-6: Federation Spine
# N3XUS LAW 55-45-17 Enforced
set -e

echo "=========================================="
echo "Phase 5-6 Bootstrap: Federation Spine"
echo "=========================================="
echo ""

echo "🔐 Verifying N3XUS LAW..."
if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then
  echo "❌ LAW VIOLATION"
  exit 1
fi

echo "✅ N3XUS LAW VERIFIED"
echo ""

echo "🚀 Building Federation Services..."
echo "  - federation-spine"
echo "  - identity-registry"
echo "  - federation-gateway"
echo "  - attestation-service"
echo ""

docker compose -f docker-compose.final.yml build \
  federation-spine \
  identity-registry \
  federation-gateway \
  attestation-service

echo ""
echo "🐳 Starting Federation Services..."
docker compose -f docker-compose.final.yml up -d \
  federation-spine \
  identity-registry \
  federation-gateway \
  attestation-service

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 15

echo ""
echo "✅ PHASE 5-6 COMPLETE"
echo ""
echo "Federation services running:"
docker ps --filter "name=federation" --filter "name=identity" --filter "name=attestation" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
