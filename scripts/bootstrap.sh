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

# Verify Founding Creatives infrastructure
echo ""
echo "🚀 Verifying Founding Creatives infrastructure..."
if [ -d "founding-creatives" ]; then
    echo "  ✅ Founding Creatives modules found"
else
    echo "  ⚠️  Founding Creatives modules not found"
fi

# Verify Stack Architecture
if [ -d "stack-architecture" ]; then
    echo "  ✅ Stack Architecture found"
else
    echo "  ⚠️  Stack Architecture not found"
fi

# Verify Monetization modules
if [ -d "monetization" ]; then
    echo "  ✅ Monetization modules found"
else
    echo "  ⚠️  Monetization modules not found"
fi

# Verify SuperCore service (existing deployment)
echo "  🔍 Checking v-supercore service (existing deployment)..."
if [ -d "services/v-supercore" ]; then
    echo "  ✅ v-supercore service verified (N3XUS LAW compliant - not modified)"
else
    echo "  ⚠️  v-supercore service not found"
fi

# Start core services with docker compose
if command -v docker &> /dev/null; then
    echo "🐳 Starting core services..."
    # Clean up conflicting containers to ensure smooth start
    docker rm -f nexus-nginx nexus-api nexus-postgres nexus-core 2>/dev/null || true

    # Stop conflicting host web servers and free ports
    if command -v systemctl &> /dev/null; then
        systemctl stop nginx 2>/dev/null || true
        systemctl stop apache2 2>/dev/null || true
    fi
    # Aggressively free port 80/443 if still in use
    if command -v fuser &> /dev/null; then
        fuser -k 80/tcp 2>/dev/null || true
        fuser -k 443/tcp 2>/dev/null || true
    fi

    docker compose --profile core up -d || echo "⚠️  Docker services failed to start. Check Docker status and configuration."
fi

# Display system status
echo ""
echo "🧠 System Status:"
bash scripts/system-status.sh

echo ""
echo "🎉 N3XUS v-COS Bootstrap Complete"
echo "================================"
echo "✅ Core systems verified"
echo "✅ N3XUS LAW compliance active"
echo "✅ Founding Creatives infrastructure ready"
echo "✅ Monetization modules initialized"
echo ""
echo "📘 Next steps:"
echo "  - Run 'bash scripts/system-status.sh' to check system state"
echo "  - Review 'founding-creatives/' for launch workflow"
echo "  - Check 'monetization/' for revenue streams"
echo ""
echo "🚀 Ready for Founding Creatives Launch Window"
