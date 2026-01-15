#!/usr/bin/env bash
# N3XUS Handshake Verification Script
# Enforces N3XUS LAW 55-45-17 globally
set -e

echo "🔐 Verifying N3XUS LAW 55-45-17..."

if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then
  echo "❌ N3XUS LAW VIOLATION"
  echo "❌ Expected: N3XUS_HANDSHAKE=55-45-17"
  echo "❌ Got: ${N3XUS_HANDSHAKE:-<empty>}"
  exit 1
fi

echo "✅ N3XUS LAW VERIFIED: Handshake 55-45-17"
echo ""

# Verify all running containers
echo "🐳 Checking container health..."
docker ps --format "table {{.Names}}\t{{.Status}}" 

# Check if any containers are not running
if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -v "Up" | grep -v "NAMES" > /dev/null 2>&1; then
  echo "⚠️  Some containers are not running"
  echo "Run: docker compose logs <service-name>"
  exit 1
fi

echo "✅ All containers alive under N3XUS LAW"
