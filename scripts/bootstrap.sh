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

# Check for official logo and deploy if present
OFFICIAL_LOGO_PATH="branding/official/N3XUS-vCOS.png"
if [ -f "$OFFICIAL_LOGO_PATH" ]; then
    echo "🎨 Official logo found at $OFFICIAL_LOGO_PATH"
    echo "✅ Logo deployed successfully"
else
    echo "⚠️  Warning: Official logo not found at $OFFICIAL_LOGO_PATH"
    echo "   Please add the official N3XUS-vCOS.png logo to branding/official/"
fi

# Start core services with docker compose
if command -v docker &> /dev/null; then
    echo "🐳 Starting core services..."
    docker compose --profile core up -d || echo "⚠️  Docker services failed to start. Check Docker status and configuration."
fi

# Display system status
echo ""
echo "🧠 System Status:"
bash scripts/system-status.sh

echo ""
echo "✅ Bootstrap complete"
echo "   Run 'bash scripts/system-status.sh' to check system state"
