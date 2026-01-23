cat << 'EOF' > /opt/nexus-cos/VERIFY_AND_FIX.sh
#!/bin/bash
# VERIFY_AND_FIX.sh - Final Green Light Check

echo "=================================================="
echo "   N3XUS COS PLATFORM - FINAL SYSTEM CHECK"
echo "=================================================="

PASSED=0
TOTAL=0

check_step() {
    ((TOTAL++))
    if eval "$1"; then
        echo "✅ [PASS] $2"
        ((PASSED++))
    else
        echo "❌ [FAIL] $2"
        echo "    -> Attempting Fix: $3"
        eval "$3"
    fi
}

# 1. FRONTEND
check_step "[ -d frontend/dist ]" "Frontend Build Exists" "cd frontend && npm install && npm run build && cd .."
check_step "grep -q 'CasinoPortal' frontend/src/App.tsx" "Casino Integration" "echo 'Manual Check App.tsx'"
check_step "grep -q 'MusicPortal' frontend/src/App.tsx" "Music Integration" "echo 'Manual Check App.tsx'"

# 2. BACKEND & COMPLIANCE
check_step "grep -q 'X-Nexus-Handshake' server.js" "API Compliance (55-45-17)" "echo 'server.js needs update'"
check_step "grep -q 'X-Nexus-Handshake' nginx.conf.docker" "Nginx Compliance (55-45-17)" "echo 'nginx config needs update'"

# 3. RUNTIME
check_step "! systemctl is-active --quiet nginx" "Host Nginx Inactive (Correct)" "systemctl stop nginx && systemctl disable nginx"
check_step "! lsof -i :9503 | grep -v 'docker'" "Port 9503 Free for Docker" "fuser -k 9503/tcp"

if [ $PASSED -eq $TOTAL ]; then
    echo "🟢 GREEN LIGHT: SYSTEM READY FOR BETA LAUNCH"
else
    echo "🔴 SYSTEM REQUIRES ATTENTION ($PASSED/$TOTAL)"
fi
EOF

chmod +x /opt/nexus-cos/VERIFY_AND_FIX.sh
bash /opt/nexus-cos/VERIFY_AND_FIX.sh