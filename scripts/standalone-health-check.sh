#!/bin/bash
# N3XUS Server Health & Diagnostic Tool - STANDALONE VERSION
# Copy and paste this ENTIRE content into your terminal on the server

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
if command -v netstat > /dev/null; then
    netstat -tulpn | grep -E ':(80|443|9000|22)' || echo "❌ No standard ports found listening!"
else
    ss -tulpn | grep -E ':(80|443|9000|22)' || echo "❌ No standard ports found listening!"
fi
echo ""

# 3. Check Nginx Status
echo "--- 3. Nginx Status ---"
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx service is ACTIVE"
else
    echo "❌ Nginx service is INACTIVE/FAILED"
fi

if nginx -t 2>&1 | grep -q "successful"; then
    echo "✅ Nginx configuration syntax is OK"
else
    echo "❌ Nginx configuration error detected:"
    nginx -t 2>&1 | head -n 5
fi
echo ""

# 4. Check Firewall (UFW)
echo "--- 4. Firewall Status (UFW) ---"
if command -v ufw > /dev/null; then
    if sudo ufw status | grep -q "Status: active"; then
        echo "✅ UFW is ACTIVE"
        sudo ufw status | grep -E '80|443|9000'
    else
        echo "⚠️ UFW is INACTIVE"
    fi
else
    echo "⚠️ UFW not installed"
fi
echo ""

# 5. Check Docker Containers
echo "--- 5. Critical Docker Containers ---"
if command -v docker > /dev/null; then
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E 'nginx|frontend|puabo|saditty|nexus' || echo "⚠️ No core Nexus containers running"
else
    echo "❌ Docker not installed or not in PATH"
fi
echo ""

# 6. Connectivity Test (Localhost)
echo "--- 6. Internal Connectivity Test ---"
check_url() {
    local url=$1
    local name=$2
    if curl -I -s -o /dev/null -w "%{http_code}" "$url" | grep -qE "200|301|302|404"; then
        echo " ✅ $name: OK"
    else
        echo " ❌ $name: FAILED (Connection Refused or Timeout)"
    fi
}

check_url "http://localhost:80" "HTTP (80)"
check_url "https://localhost:443" "HTTPS (443)"
check_url "http://localhost:9000" "Control Panel (9000)"

echo ""
echo "==================================================="
echo "DIAGNOSTICS COMPLETE"
echo "==================================================="
