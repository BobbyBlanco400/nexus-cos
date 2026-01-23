#!/bin/bash
# N3XUS v-COS Settle Period Monitor
# Run 3x daily: 08:00, 14:00, 20:00
# Usage: bash monitor-vps-settle.sh

VPS_IP="72.62.86.217"
HANDSHAKE="55-45-17"

echo "=================================================="
echo " N3XUS v-COS Settle Period Monitor"
echo " Date: $(date)"
echo " VPS: $VPS_IP"
echo "=================================================="

echo ""
echo "[1/3] Checking Container Health (Goal: 13/13 running)..."
ssh root@$VPS_IP "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep -v 'CONTAINER ID'"
RUNNING_COUNT=$(ssh root@$VPS_IP "docker ps -q | wc -l")
echo "Total Containers: $RUNNING_COUNT"

echo ""
echo "[2/3] Checking System Resources (Goal: Mem ~30%)..."
ssh root@$VPS_IP "free -h | grep Mem | awk '{print \"Memory Usage: \" \$3 \" / \" \$2}'"
ssh root@$VPS_IP "uptime"

echo ""
echo "[3/3] Verifying N3XUS LAW Enforcement..."
# Check Blocked (No Handshake)
HTTP_BLOCK=$(ssh root@$VPS_IP "curl -s -o /dev/null -w '%{http_code}' http://localhost:3001/")
if [ "$HTTP_BLOCK" == "451" ] || [ "$HTTP_BLOCK" == "403" ] || [ "$HTTP_BLOCK" == "401" ]; then
    echo "✅ No Handshake: Blocked (HTTP $HTTP_BLOCK)"
else
    echo "⚠️  No Handshake: UNEXPECTED (HTTP $HTTP_BLOCK)"
fi

# Check Allowed (With Handshake)
HTTP_ALLOW=$(ssh root@$VPS_IP "curl -s -o /dev/null -w '%{http_code}' -H 'X-N3XUS-Handshake: $HANDSHAKE' http://localhost:3001/")
if [ "$HTTP_ALLOW" == "200" ]; then
    echo "✅ With Handshake: Allowed (HTTP 200)"
else
    echo "⚠️  With Handshake: UNEXPECTED (HTTP $HTTP_ALLOW)"
fi

echo ""
echo "=================================================="
echo "Monitor Complete."
