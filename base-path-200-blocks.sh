#!/bin/bash
# ==============================================================================
# Nexus COS — Base Path 200 Blocks Script
# ==============================================================================
# Purpose: Insert exact-match base-path 200 blocks that do not affect subroutes
# Target: PF Gateway configuration for nexuscos.online
# ==============================================================================

set -e

DOMAIN="${DOMAIN:-nexuscos.online}"
PF="/etc/nginx/conf.d/pf_gateway_${DOMAIN}.conf"

echo "═══════════════════════════════════════════════════════════════"
echo "  BASE PATH 200 BLOCKS INSERTION"
echo "  Domain: $DOMAIN"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check if PF gateway config exists
if [ ! -f "$PF" ]; then
    echo "Error: PF gateway config not found at $PF"
    echo "Please ensure the gateway configuration file exists."
    exit 1
fi

echo "Step 1: Backing up current configuration..."
cp -f "$PF" "$PF.backup-$(date +%F-%H%M%S)"
echo "✓ Created backup of current configuration"

echo ""
echo "Step 2: Checking for existing base path blocks..."

# Check if blocks already exist
if grep -q "location = /api/" "$PF"; then
    echo "⚠ Base path blocks already exist in configuration"
    echo "Skipping insertion to avoid duplicates"
    exit 0
fi

echo "✓ No existing base path blocks found"

echo ""
echo "Step 3: Inserting base path 200 blocks..."

# Use awk to insert the blocks before the first matching location directives
awk 'BEGIN{a=0;s=0}
  /^[[:space:]]*location[[:space:]]+\/api\// && a==0 {
    print "    location = /api/ {"
    print "        return 200 \"ok\";"
    print "        add_header Content-Type text/plain;"
    print "    }"
    print ""
    a=1
  }
  /^[[:space:]]*location[[:space:]]+\/streaming\// && s==0 {
    print "    location = /streaming/ {"
    print "        return 200 \"ok\";"
    print "        add_header Content-Type text/plain;"
    print "    }"
    print ""
    s=1
  }
  {print}
' "$PF" > "$PF.tmp"

# Replace the original with the new version
mv "$PF.tmp" "$PF"
echo "✓ Base path blocks inserted successfully"

echo ""
echo "Step 4: Testing nginx configuration..."
if nginx -t; then
    echo "✓ Nginx configuration is valid"
else
    echo "Error: Nginx configuration test failed"
    echo "Restoring backup..."
    cp -f "$PF.backup-$(date +%F-%H%M%S)" "$PF"
    exit 1
fi

echo ""
echo "Step 5: Restarting nginx..."
if systemctl restart nginx 2>/dev/null || service nginx restart 2>/dev/null; then
    echo "✓ Nginx restarted successfully"
else
    echo "Error: Failed to restart nginx"
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  BASE PATH 200 BLOCKS INSERTION COMPLETE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "The following exact-match blocks were added to:"
echo "  $PF"
echo ""
echo "  - location = /api/ (returns 200)"
echo "  - location = /streaming/ (returns 200)"
echo ""
echo "These blocks will handle base path requests without affecting subroutes."
echo "For example:"
echo "  - /api/ returns 200 'ok'"
echo "  - /api/users still proxies to backend"
echo "  - /streaming/ returns 200 'ok'"
echo "  - /streaming/socket.io/ still works for Socket.IO"
echo ""
