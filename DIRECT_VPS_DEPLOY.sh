#!/bin/bash
# ==============================================================================
# NEXUS COS - DIRECT VPS DEPLOYMENT (No Copy-Paste Issues)
# ==============================================================================
# This script downloads and executes the TRAE Solo PF directly from GitHub
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/copilot/fix-nginx-duplicate-entries/DIRECT_VPS_DEPLOY.sh)
# ==============================================================================

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║         NEXUS COS - DIRECT VPS NGINX FIX DEPLOYMENT           ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check root
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root or with sudo"
    echo "Usage: sudo bash <(curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/copilot/fix-nginx-duplicate-entries/DIRECT_VPS_DEPLOY.sh)"
    exit 1
fi

# Check nginx installed
if ! command -v nginx &> /dev/null; then
    echo "ERROR: Nginx is not installed"
    exit 1
fi

echo "✓ Root access confirmed"
echo "✓ Nginx detected"
echo ""
echo "Downloading TRAE Solo PF script..."

# Download the main script
SCRIPT_URL="https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/copilot/fix-nginx-duplicate-entries/TRAE_SOLO_NGINX_FIX_PF.sh"
TEMP_SCRIPT="/tmp/trae_nginx_fix_$(date +%s).sh"

if curl -fsSL "$SCRIPT_URL" -o "$TEMP_SCRIPT"; then
    echo "✓ Script downloaded successfully"
    echo ""
    echo "Executing TRAE Solo PF..."
    echo ""
    
    # Make executable and run
    chmod +x "$TEMP_SCRIPT"
    bash "$TEMP_SCRIPT"
    
    # Cleanup
    rm -f "$TEMP_SCRIPT"
else
    echo "ERROR: Failed to download script from GitHub"
    echo "Please check your internet connection and try again"
    exit 1
fi
