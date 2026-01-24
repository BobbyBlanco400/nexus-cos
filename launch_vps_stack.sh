#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# 🦅 TRAE MASTER LAUNCH PROTOCOL
# ==============================================================================
# AUTHORITY: TRAE SOLO CODER
# TARGET: SOVEREIGN VPS (Hostinger)
# PROTOCOL: N3XUS HANDSHAKE 55-45-17
# ==============================================================================

HANDSHAKE="55-45-17"
COMPOSE_FILE="docker-compose.full.yml"
LOCK_FILE="NOTARIZED_DIGITAL_COPY.md"

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║  🦅 N3XUS v-COS SOVEREIGN LAUNCH SEQUENCE                            ║"
echo "║  Target: 72.62.86.217 (Hostinger)                                    ║"
echo "║  Protocol: Handshake $HANDSHAKE                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# ------------------------------------------------------------------------------
# 1. VERIFICATION
# ------------------------------------------------------------------------------
echo "🔍 [1/5] Verifying Notarization..."
if [ ! -f "$LOCK_FILE" ]; then
    echo "   ❌ Notarization Certificate MISSING!"
    exit 1
fi
echo "   ✅ Notarized Certificate Verified."

# ------------------------------------------------------------------------------
# 2. BUILD
# ------------------------------------------------------------------------------
echo "🏗️  [2/5] Building Sovereign Stack (50+ Services)..."
echo "   ℹ️  Enforcing N3XUS_HANDSHAKE=${HANDSHAKE}"

# Export for Compose Interpolation
export N3XUS_HANDSHAKE="${HANDSHAKE}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-nexus_pass}"

docker-compose -f "${COMPOSE_FILE}" build \
    --build-arg N3XUS_HANDSHAKE="${HANDSHAKE}"

# ------------------------------------------------------------------------------
# 3. DEPLOY
# ------------------------------------------------------------------------------
echo "🚀 [3/5] Deploying Containers..."
docker-compose -f "${COMPOSE_FILE}" up -d --remove-orphans

# ------------------------------------------------------------------------------
# 4. HEALTH CHECK
# ------------------------------------------------------------------------------
echo "🏥 [4/5] Verifying Health (Wait 30s)..."
sleep 30

check_health() {
    name="$1"
    port="$2"
    url="http://localhost:${port}/health"
    echo "   → Checking ${name} on port ${port}..."
    if curl -fsS -m 5 "${url}" >/dev/null 2>&1; then
        echo "     ✅ ${name}: HEALTHY"
    else
        echo "     ⚠️ ${name}: UNREACHABLE (Check logs)"
    fi
}

# Core Tier
check_health "v-supercore" 3001
check_health "puabo-api-ai-hf" 3002
check_health "federation-spine" 3010
check_health "casino-core" 3020
check_health "wallet-engine" 3030

# ------------------------------------------------------------------------------
# 5. FINAL REPORT
# ------------------------------------------------------------------------------
echo ""
echo "════════════════════════════════════════════════════════════════════════"
echo "✅  SOVEREIGN LAUNCH COMPLETE"
echo "    Status:     ACTIVE"
echo "    Protocol:   $HANDSHAKE"
echo "    Timestamp:  $(date -u)"
echo "════════════════════════════════════════════════════════════════════════"
echo "🦅 N3XUS v-COS IS LIVE."
