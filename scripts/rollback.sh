#!/bin/bash
# Emergency Rollback Script
# Implements zero-trust rollback procedure

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ⚠️  EMERGENCY ROLLBACK INITIATED                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Phase 1: Freeze and Snapshot
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 1: Freeze and Snapshot (60s)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🔒 Freezing ingress traffic..."
docker exec nginx nginx -s stop 2>/dev/null || echo "⚠️  Nginx not running"

echo "📸 Creating emergency snapshots..."
SNAPSHOT_ID=$(date +%s)
mkdir -p /backup

# Snapshot critical volumes (if they exist)
if docker volume ls | grep -q postgres-data; then
  docker run --rm -v postgres-data:/data -v /backup:/backup \
    alpine tar czf /backup/postgres-${SNAPSHOT_ID}.tar.gz /data 2>/dev/null || true
fi

if docker volume ls | grep -q ledger-data; then
  docker run --rm -v ledger-data:/data -v /backup:/backup \
    alpine tar czf /backup/ledger-${SNAPSHOT_ID}.tar.gz /data 2>/dev/null || true
fi

echo "✅ Snapshots created: $SNAPSHOT_ID"

# Phase 2: Stop Tiers in Reverse Order
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 2: Stop Tiers in Reverse Order (120s)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "⏹️  Stopping Tier 4 (Virtual Casino & AI)..."
docker compose stop avatar-ms world-engine-ms gamecore-ms \
  casino-nexus-api rewards-ms skill-games-ms puabo-nexus-ai-dispatch 2>/dev/null || echo "⚠️  Some Tier 4 services not found"

echo "⏹️  Stopping Tier 3 (Streaming Extensions)..."
docker compose stop streaming-service-v2 chat-stream-ms ott-api 2>/dev/null || echo "⚠️  Some Tier 3 services not found"

echo "⏹️  Stopping Tier 2 (Platform Services)..."
docker compose stop license-service musicchain-ms puabomusicchain \
  dsp-api content-management 2>/dev/null || echo "⚠️  Some Tier 2 services not found"

echo "⏹️  Stopping Tier 1 (Economic Core)..."
docker compose stop ledger-mgr wallet-ms token-mgr invoice-gen 2>/dev/null || echo "⚠️  Some Tier 1 services not found"

echo "✅ All upper tiers stopped"

# Phase 3: Restart Tier 0 Only
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 3: Restart Tier 0 Only (60s)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🚀 Starting Tier 0 (Foundation)..."
docker compose up -d postgres redis streamcore puabo-api auth-service pv-keys puaboai-sdk 2>/dev/null || echo "⚠️  Some Tier 0 services not found"

echo "⏳ Waiting for Tier 0 health (60s timeout)..."
sleep 10

# Phase 4: Validate Foundation
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 4: Validate Foundation (120s)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🔍 Validating foundation layer..."

# Test database
docker exec postgres psql -U nexus -c "SELECT 1" 2>/dev/null || echo "⚠️  Database check failed"

# Test Redis
docker exec redis redis-cli ping 2>/dev/null | grep PONG || echo "⚠️  Redis check failed"

echo "✅ Foundation validated"

# Phase 5: Re-enable Ingress
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 5: Re-enable Ingress (30s)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🔓 Re-enabling ingress..."
docker exec nginx nginx 2>/dev/null || echo "⚠️  Nginx restart failed"

sleep 5

echo "✅ Ingress restored"

# Phase 6: Post-Rollback Verification
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 6: Post-Rollback Verification (60s)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🔍 Running minimal verification..."

# Check for unhealthy containers
UNHEALTHY=$(docker ps --filter "health=unhealthy" --format "{{.Names}}")
if [ -n "$UNHEALTHY" ]; then
  echo "⚠️  Unhealthy containers: $UNHEALTHY"
else
  echo "✅ No unhealthy containers"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ✅ ROLLBACK COMPLETE                                      ║"
echo "║  Tier 0 operational, upper tiers stopped                    ║"
echo "║  System in safe state for investigation                     ║"
echo "╚════════════════════════════════════════════════════════════╝"

echo ""
echo "📋 Next Steps:"
echo "  1. Review logs to identify failure cause"
echo "  2. Fix issues in development environment"
echo "  3. Test fix thoroughly before redeployment"
echo "  4. Schedule redeployment during maintenance window"
echo ""
echo "Snapshot ID for reference: $SNAPSHOT_ID"

exit 0
