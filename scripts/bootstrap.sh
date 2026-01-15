#!/usr/bin/env bash
set -e

echo "🔁 Bootstrapping N3XUS COS..."

# Set environment variables
export NEXUS_HANDSHAKE="55-45-17"
export GENESIS_LOCK_ENABLED="true"

# Check if docker compose is available
if ! command -v docker &> /dev/null; then
    echo "⚠️  Warning: Docker is not installed or not running"
    echo "   Please install Docker to run the full system"
fi

# Check if config files exist
if [ ! -f "config/genesis.lock.json" ]; then
    echo "❌ Error: Genesis lock file not found"
    exit 1
fi

echo "✅ Genesis lock file found"

# N3XUS LAW: Hard-verify canonical PNG logo presence
OFFICIAL_LOGO_PATH="branding/official/N3XUS-vCOS.png"
if [ ! -f "$OFFICIAL_LOGO_PATH" ]; then
    echo "❌ FATAL: N3XUS LAW VIOLATION - Canonical logo not found"
    echo "   Required: $OFFICIAL_LOGO_PATH"
    echo "   Non-compliant environments cannot start"
    exit 1
fi

echo "🎨 Official logo verified at $OFFICIAL_LOGO_PATH"
echo "✅ N3XUS LAW compliant - Logo enforcement active"

# Start core services with docker compose
if command -v docker &> /dev/null; then
    echo "🐳 Starting core services..."
    # Clean up conflicting containers to ensure smooth start
    docker rm -f nexus-nginx nexus-api nexus-postgres nexus-core 2>/dev/null || true
    docker compose --profile core up -d || echo "⚠️  Docker services failed to start. Check Docker status and configuration."
fi

# Display system status
echo ""
echo "🧠 System Status:"
bash scripts/system-status.sh

echo ""
echo "✅ Bootstrap complete"
echo "   Run 'bash scripts/system-status.sh' to check system state"
