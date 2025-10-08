#!/bin/bash
# ==============================================================================
# One-Line Landing Page Deployment for Nexus COS
# ==============================================================================
# Quick deployment script that can be run with a single command
# Usage: sudo bash DEPLOY_LANDING_PAGES_NOW.sh
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  Nexus COS Landing Page - Quick Deployment            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Detect script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$SCRIPT_DIR}"

echo -e "${YELLOW}►${NC} Repository: ${REPO_ROOT}"
echo ""

# Check if we're root or have sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}✗ This script must be run as root or with sudo${NC}"
    exit 1
fi

# Step 1: Create directories
echo -e "${YELLOW}►${NC} Creating deployment directories..."
mkdir -p /var/www/nexuscos.online
mkdir -p /var/www/beta.nexuscos.online
echo -e "${GREEN}✓${NC} Directories created"

# Step 2: Deploy landing pages
echo -e "${YELLOW}►${NC} Deploying landing pages..."
cp "${REPO_ROOT}/apex/index.html" /var/www/nexuscos.online/index.html
cp "${REPO_ROOT}/web/beta/index.html" /var/www/beta.nexuscos.online/index.html
echo -e "${GREEN}✓${NC} Landing pages deployed"

# Step 3: Set permissions
echo -e "${YELLOW}►${NC} Setting permissions..."
chown -R www-data:www-data /var/www/nexuscos.online /var/www/beta.nexuscos.online
chmod 644 /var/www/nexuscos.online/index.html /var/www/beta.nexuscos.online/index.html
echo -e "${GREEN}✓${NC} Permissions set"

# Step 4: Deploy nginx configuration
echo -e "${YELLOW}►${NC} Deploying nginx configuration..."
cp "${REPO_ROOT}/deployment/nginx/nexuscos-unified.conf" /etc/nginx/sites-available/nexuscos

# Enable site if not already enabled
if [ ! -L /etc/nginx/sites-enabled/nexuscos ]; then
    ln -s /etc/nginx/sites-available/nexuscos /etc/nginx/sites-enabled/
    echo -e "${GREEN}✓${NC} Nginx site enabled"
else
    echo -e "${GREEN}✓${NC} Nginx site already enabled"
fi

# Step 5: Test nginx configuration
echo -e "${YELLOW}►${NC} Testing nginx configuration..."
if nginx -t &>/dev/null; then
    echo -e "${GREEN}✓${NC} Nginx configuration is valid"
else
    echo -e "${RED}✗ Nginx configuration test failed!${NC}"
    nginx -t
    exit 1
fi

# Step 6: Reload nginx
echo -e "${YELLOW}►${NC} Reloading nginx..."
systemctl reload nginx
echo -e "${GREEN}✓${NC} Nginx reloaded"

# Verification
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅  Deployment Completed Successfully!               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Access your landing pages:${NC}"
echo -e "  🔗 Apex:  https://nexuscos.online"
echo -e "  🔗 Beta:  https://beta.nexuscos.online"
echo ""
echo -e "${CYAN}Admin panel still accessible at:${NC}"
echo -e "  🔗 Admin: https://nexuscos.online/admin/"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Clear browser cache (Ctrl+Shift+Delete)"
echo "  2. Visit the URLs above"
echo "  3. Verify landing pages load correctly"
echo ""
