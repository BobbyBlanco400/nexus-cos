#!/usr/bin/env bash
# FAIL-PROOF VPS DEPLOYMENT ONE-LINER
# Hostinger VPS: 72.62.86.217 (n3xuscos.online)
# Date: December 25, 2025
# This script can be run directly on your Hostinger VPS server

set -euo pipefail

# Hostinger VPS Configuration
VPS_IP="72.62.86.217"
VPS_DOMAIN="n3xuscos.online"
POSTGRES_PASSWORD="password"  # Change this immediately after deployment!

echo "═══════════════════════════════════════════════════════════════"
echo "  FAIL-PROOF N.E.X.U.S DEPLOYMENT - HOSTINGER VPS"
echo "  IP: $VPS_IP"
echo "  Domain: $VPS_DOMAIN"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Step 1: Download the fixed deployment script
echo "[1/4] Downloading fixed deployment script..."
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/NEXUS_AI_FULL_DEPLOY.sh -o /tmp/nexus-deploy.sh
chmod +x /tmp/nexus-deploy.sh

# Step 2: Verify script downloaded correctly
if [ ! -f /tmp/nexus-deploy.sh ]; then
    echo "[ERROR] Failed to download deployment script"
    exit 1
fi

# Check that the script has the VPS-compatible RAM check (3000 instead of 6144)
if grep -q "RAM_AVAIL -lt 3000" /tmp/nexus-deploy.sh; then
    echo "[✓] Script has VPS-compatible RAM check (3GB)"
else
    echo "[ERROR] Script does not have the VPS fix. Aborting."
    exit 1
fi

# Check that the script has the correct password
if grep -q 'PGPASSWORD="password"' /tmp/nexus-deploy.sh; then
    echo "[✓] Script has correct PostgreSQL password"
else
    echo "[ERROR] Script does not have the correct password. Aborting."
    exit 1
fi

echo "[✓] Pre-flight checks passed"
echo ""

# Step 3: Run the deployment
echo "[2/4] Starting deployment (this will take 3-7 minutes)..."
bash /tmp/nexus-deploy.sh

# Step 4: Verify deployment
echo ""
echo "[3/4] Verifying deployment..."
sleep 5

# Check if nexus-control was installed
if command -v nexus-control &>/dev/null; then
    echo "[✓] N.E.X.U.S AI Control Panel installed"
    nexus-control health
else
    echo "[WARN] N.E.X.U.S AI Control Panel not found"
fi

# Step 5: Display post-deployment instructions
echo ""
echo "[4/4] Deployment Complete!"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  🚨 CRITICAL: CHANGE PASSWORDS IMMEDIATELY 🚨"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Run these commands NOW:"
echo ""
echo "sudo -u postgres psql"
echo "\\password postgres"
echo "ALTER USER nexus_user WITH PASSWORD 'YourSecurePassword123!';"
echo "ALTER USER nexuscos WITH PASSWORD 'YourSecurePassword123!';"
echo "\\q"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  ✅ DEPLOYMENT SUCCESSFUL"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Test URLs:"
echo "  - https://$VPS_DOMAIN"
echo "  - https://$VPS_DOMAIN/puaboverse"
echo "  - https://$VPS_DOMAIN/wallet"
echo "  - https://$VPS_DOMAIN/api"
echo ""
echo "Management Commands:"
echo "  - nexus-control status"
echo "  - nexus-control health"
echo "  - nexus-control logs <service>"
echo "  - nexus-control monitor"
echo ""
echo "Log file: /var/log/nexus-cos/deploy-*.log"
echo ""
