#!/usr/bin/env bash
set -e

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "❌ Error: jq is not installed. Please install jq first."
    exit 1
fi

# Verify genesis lock file exists
if [ ! -f "config/genesis.lock.json" ]; then
    echo "❌ Error: config/genesis.lock.json not found"
    exit 1
fi

# Read state from genesis lock file
STATE=$(jq -r '.state' config/genesis.lock.json)
ACTIVATED=$(jq -r '.activated' config/genesis.lock.json)
PHASE_1=$(jq -r '.phases.phase_1' config/genesis.lock.json)
PHASE_2=$(jq -r '.phases.phase_2' config/genesis.lock.json)
PHASE_2_5=$(jq -r '.phases.phase_2_5' config/genesis.lock.json)

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  N3XUS COS System Status                                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "🧠 SYSTEM STATE: $STATE"
echo "🔥 MAINNET ACTIVE: $ACTIVATED"
echo ""
echo "Phase Status:"
echo "  Phase 1: $PHASE_1"
echo "  Phase 2: $PHASE_2"
echo "  Phase 2.5: $PHASE_2_5"
echo ""

# Interpretation
if [ "$STATE" = "GENESIS_LOCKED" ] && [ "$ACTIVATED" = "false" ]; then
    echo "📊 Interpretation: Launched, not ignited"
    echo "   The system is sealed and ready for activation."
    echo "   Run 'bash scripts/activate-mainnet.sh' to go live."
elif [ "$STATE" = "MAINNET_ACTIVE" ] && [ "$ACTIVATED" = "true" ]; then
    echo "📊 Interpretation: Live to the world"
    echo "   The platform is operational and serving users."
    echo "   🔴 MAINNET IS ACTIVE"
else
    echo "📊 Interpretation: Unknown state"
    echo "   Please verify genesis lock file integrity."
fi

echo ""
