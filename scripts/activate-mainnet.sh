#!/usr/bin/env bash
set -e

echo "🚀 Activating Mainnet..."

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

# Create secure temporary file
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Update genesis lock file - set both activated and state
jq '.activated = true | .state = "MAINNET_ACTIVE" | .mainnet_activated_at = now | .mainnet_activated_at |= todate' \
  config/genesis.lock.json > "$TEMP_FILE"

# Move the updated file back
mv "$TEMP_FILE" config/genesis.lock.json

echo "✅ MAINNET IS NOW LIVE"
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🔴 MAINNET ACTIVATED                                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "System Status:"
echo "  State: MAINNET_ACTIVE"
echo "  Activated: true"
echo "  Timestamp: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo ""
echo "⚠️  WARNING: This is an irreversible state transition."
echo "   The platform is now live and operational."
echo ""
