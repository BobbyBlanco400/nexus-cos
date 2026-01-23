#!/bin/bash
# N3XUS Server Health & Diagnostic Tool
# Run this on the server (72.62.86.217) as root

echo "==================================================="
echo "   N3XUS v-COS SERVER DIAGNOSTICS (Phase 1/2/2.5)"
echo "==================================================="
date
echo ""

# 1. Check System Resources
echo "--- 1. System Resources ---"
uptime
free -h
df -h / | awk 'NR==2 {print "Disk Usage: " $5}'
echo ""

# 2. Check Network Ports (Listening)
echo "--- 2. Network Ports (Listening) ---"
netstat -tulpn | grep -E ':(80|443|9000|22)' || echo "❌ No standard ports found listening!"
echo ""

# 3. Check Nginx Status
echo "--- 3. Nginx Status ---"
systemctl status nginx | grep "Active:" || echo "❌ Nginx service not active"
nginx -t 2>&1 | grep "syntax is" || echo "❌ Nginx configuration error"
echo ""

# 4. Check Firewall (UFW)
echo "--- 4. Firewall Status (UFW) ---"
if command -v ufw > /dev/null; then
    ufw status | grep -E '80|443|9000'
else
    echo "⚠️ UFW not installed"
fi
echo ""

# 5. Check Docker Containers
echo "--- 5. Critical Docker Containers ---"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E 'nginx|frontend|puabo|saditty'
echo ""

# 6. Connectivity Test (Localhost)
echo "--- 6. Internal Connectivity Test ---"
echo "Testing HTTP (80):"
curl -I -s -o /dev/null -w "%{http_code}" http://localhost:80 && echo " ✅ OK" || echo " ❌ FAILED"

echo "Testing HTTPS (443):"
curl -k -I -s -o /dev/null -w "%{http_code}" https://localhost:443 && echo " ✅ OK" || echo " ❌ FAILED"

echo "Testing Control Panel (9000):"
curl -I -s -o /dev/null -w "%{http_code}" http://localhost:9000 && echo " ✅ OK" || echo " ❌ FAILED"

echo ""
echo "==================================================="
echo "DIAGNOSTICS COMPLETE"
echo "==================================================="
