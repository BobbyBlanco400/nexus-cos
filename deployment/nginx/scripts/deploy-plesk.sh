#!/usr/bin/env bash
# ==============================================================================
# Nexus COS - Plesk Nginx Deployment Script
# ==============================================================================
# This script deploys the nexuscos.online vhost configuration for Plesk-managed
# Nginx installations.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
VHOST_SOURCE="$REPO_ROOT/deployment/nginx/plesk/vhost_nginx.conf"
PLESK_VHOST="/var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf"

echo "=============================================================================="
echo "Nexus COS - Plesk Nginx Deployment"
echo "=============================================================================="
echo ""

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
    echo "⚠️  This script must be run with sudo or as root."
    echo "Usage: sudo $0"
    exit 1
fi

# Check if Plesk is installed
if ! command -v plesk &> /dev/null; then
    echo "❌ Plesk is not installed. Use the vanilla deployment script instead."
    echo "Run: sudo $REPO_ROOT/deployment/nginx/scripts/deploy-vanilla.sh"
    exit 1
fi

# Check if Nginx is installed
if ! command -v nginx &> /dev/null; then
    echo "❌ Nginx is not installed."
    exit 1
fi

# Check if Plesk vhost directory exists
PLESK_VHOST_DIR="$(dirname "$PLESK_VHOST")"
if [[ ! -d "$PLESK_VHOST_DIR" ]]; then
    echo "❌ Plesk vhost directory not found: $PLESK_VHOST_DIR"
    echo "ℹ️  Make sure the domain nexuscos.online is configured in Plesk"
    exit 1
fi

# Backup existing configuration if it exists
echo "📦 Backing up existing configuration..."
BACKUP_FILE="${PLESK_VHOST}.bak.$(date +%Y%m%d%H%M%S)"
if [[ -f "$PLESK_VHOST" ]]; then
    cp "$PLESK_VHOST" "$BACKUP_FILE"
    echo "✅ Backup created: $BACKUP_FILE"
else
    echo "ℹ️  No existing configuration to backup"
fi

# Copy vhost configuration
echo ""
echo "📄 Installing Plesk vhost configuration..."
cp -f "$VHOST_SOURCE" "$PLESK_VHOST"
echo "✅ Copied to $PLESK_VHOST"

# Set proper permissions
echo ""
echo "🔒 Setting permissions..."
chown root:root "$PLESK_VHOST"
chmod 644 "$PLESK_VHOST"
echo "✅ Permissions set"

# Rebuild Plesk configuration
echo ""
echo "🔧 Rebuilding Plesk web configuration..."
if plesk repair web -domain nexuscos.online -y; then
    echo "✅ Plesk web configuration rebuilt"
else
    echo "⚠️  Plesk repair command returned non-zero, but may have succeeded"
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
        cp "$BACKUP_FILE" "$PLESK_VHOST"
        plesk repair web -domain nexuscos.online -y || true
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
echo "   1. Verify site is accessible: https://nexuscos.online/"
echo "   2. Test API endpoint: https://nexuscos.online/api/"
echo "   3. Test streaming: https://nexuscos.online/stream/"
echo "   4. Run validation script: $REPO_ROOT/deployment/nginx/scripts/validate-endpoints.sh"
echo ""
echo "💾 Backup location: $BACKUP_FILE"
echo ""
echo "🔄 To rollback, run:"
echo "   sudo cp $BACKUP_FILE $PLESK_VHOST"
echo "   sudo plesk repair web -domain nexuscos.online -y"
echo "   sudo nginx -t && sudo systemctl reload nginx"
echo ""
