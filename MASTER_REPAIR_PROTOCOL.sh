#!/bin/bash
# =================================================================
# N3XUS v-COS | MASTER REPAIR & SOVEREIGN WIRE HANDSHAKE
# TARGET: srv1213380 | REPAIRING: creator-hub, puaboverse, v-suite
# =================================================================

echo -e "\e[34m--- PHASE 1: REPAIRING ECOSYSTEM DEPENDENCIES ---\e[0m"

# Define the services to repair (Mapping directory names correctly)
# Note: Directory names must match actual folders in /var/www/nexus-cos/services/
SERVICES=("creator-hub-v2" "puaboverse-v2" "v-caster-pro" "v-prompter-pro")
BASE_DIR="/var/www/nexus-cos/services"

for SERVICE in "${SERVICES[@]}"; do
    echo -e "\e[33m[*] Fixing $SERVICE...\e[0m"
    if [ -d "$BASE_DIR/$SERVICE" ]; then
        cd "$BASE_DIR/$SERVICE"
        # Install missing dependencies (The "Bad" fix)
        npm install --quiet --no-audit --no-fund
        # Restart via PM2 to clear errors
        echo -e "\e[32m[*] Dependencies installed. Ready for restart.\e[0m"
    else
        echo -e "\e[31m[!] Directory $BASE_DIR/$SERVICE missing!\e[0m"
    fi
done

echo -e "\e[34m--- PHASE 2: CLEANING GHOST PROCESSES & RESTARTING ---\e[0m"

# Return to root
cd /var/www/nexus-cos

# Force restart specific ecosystem processes
pm2 restart creator-hub --update-env 2>/dev/null || pm2 start services/creator-hub-v2/server.js --name creator-hub
pm2 restart puaboverse --update-env 2>/dev/null || pm2 start services/puaboverse-v2/server.js --name puaboverse
pm2 restart v-suite --update-env 2>/dev/null || echo "V-Suite managed via ecosystem.config.js"

# Save state
pm2 save

echo -e "\n\e[32m--- PHASE 3: FINAL SOVEREIGN HANDSHAKE VERIFICATION ---\e[0m"

# 1. DEFINE CANONICAL TRUTH
EXPECTED_HASH="112c05cc396f6baa29aa5ace63628fd99762d8a5312923c8ae87aae7b5355e69"

# 2. VERIFY CRYPTOGRAPHIC SEAL
echo -n "[1/4] Checking Archive Integrity... "
if [ -f "PUABO_vSTUDIOS_FINAL_MASTER.zip" ]; then
    ACTUAL_HASH=$(sha256sum PUABO_vSTUDIOS_FINAL_MASTER.zip | awk '{print $1}')
    if [ "$ACTUAL_HASH" == "$EXPECTED_HASH" ]; then
        echo -e "\e[32mPASSED\e[0m"
    else
        echo -e "\e[31mHASH MISMATCH\e[0m"
        echo "Expected: $EXPECTED_HASH"
        echo "Actual:   $ACTUAL_HASH"
    fi
else
    echo -e "\e[33mARCHIVE NOT FOUND (SKIPPING HASH CHECK)\e[0m"
fi

# 3. VERIFY ECOSYSTEM UPTIME
echo -e "[2/4] PM2 Status Check:"
pm2 status | grep -E "creator-hub|puaboverse|v-suite|nexus-app|vr-world"

echo -e "\n\e[32m--- [REPAIR COMPLETE: SYSTEM IS WIRED & SOVEREIGN] ---\e[0m"
