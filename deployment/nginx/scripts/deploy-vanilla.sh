#!/usr/bin/env bash
# ==============================================================================
# Nexus COS - Vanilla Nginx Deployment Script
# ==============================================================================
# This script deploys the n3xuscos.online vhost configuration for standard
# (non-Plesk) Nginx installations.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
VHOST_SOURCE="$REPO_ROOT/deployment/nginx/sites-available/n3xuscos.online"

echo "=============================================================================="
echo "Nexus COS - Vanilla Nginx Deployment"
echo "=============================================================================="
echo ""

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
    echo "⚠️  This script must be run with sudo or as root."
    echo "Usage: sudo $0"
    exit 1
fi

# Check if Nginx is installed
if ! command -v nginx &> /dev/null; then
    echo "❌ Nginx is not installed. Please install nginx first."
    exit 1
fi

# Backup existing configuration if it exists
echo "📦 Backing up existing configuration..."
BACKUP_FILE="/etc/nginx/sites-enabled/n3xuscos.online.bak.$(date +%Y%m%d%H%M%S)"
if [[ -f /etc/nginx/sites-enabled/n3xuscos.online ]]; then
    cp /etc/nginx/sites-enabled/n3xuscos.online "$BACKUP_FILE"
    echo "✅ Backup created: $BACKUP_FILE"
else
    echo "ℹ️  No existing configuration to backup"
fi

# Copy vhost configuration to sites-available
echo ""
echo "📄 Installing vhost configuration..."
cp -f "$VHOST_SOURCE" /etc/nginx/sites-available/n3xuscos.online
echo "✅ Copied to /etc/nginx/sites-available/n3xuscos.online"

# Create symlink in sites-enabled
echo ""
echo "🔗 Enabling site..."
ln -sf /etc/nginx/sites-available/n3xuscos.online /etc/nginx/sites-enabled/n3xuscos.online
echo "✅ Created symlink in sites-enabled"

# Disable default site if it exists
echo ""
echo "🚫 Disabling default site..."
if [[ -f /etc/nginx/sites-enabled/default ]]; then
    rm -f /etc/nginx/sites-enabled/default
    echo "✅ Default site disabled"
else
    echo "ℹ️  Default site not found (already disabled)"
fi

# Test nginx configuration
echo ""
echo "🔍 Testing Nginx configuration..."
if nginx -t; then
    echo "✅ Nginx configuration test passed"
else
    echo "❌ Nginx configuration test failed!"
    echo "⚠️  Rolling back..."
    if [[ -f "$BACKUP_FILE" ]]; then
        cp "$BACKUP_FILE" /etc/nginx/sites-enabled/n3xuscos.online
        echo "✅ Rollback complete"
    fi
    exit 1
fi

# Reload nginx
echo ""
echo "🔄 Reloading Nginx..."
if systemctl reload nginx; then
    echo "✅ Nginx reloaded successfully"
else
    echo "❌ Failed to reload Nginx"
    exit 1
fi

echo ""
echo "=============================================================================="
echo "✅ Deployment Complete!"
echo "=============================================================================="
echo ""
echo "📋 Next Steps:"
echo "   1. Verify site is accessible: https://n3xuscos.online/"
echo "   2. Test API endpoint: https://n3xuscos.online/api/"
echo "   3. Test streaming: https://n3xuscos.online/stream/"
echo "   4. Run validation script: $REPO_ROOT/deployment/nginx/scripts/validate-endpoints.sh"
echo ""
echo "💾 Backup location: $BACKUP_FILE"
echo ""
echo "🔄 To rollback, run:"
echo "   sudo cp $BACKUP_FILE /etc/nginx/sites-enabled/n3xuscos.online"
echo "   sudo nginx -t && sudo systemctl reload nginx"
echo ""
