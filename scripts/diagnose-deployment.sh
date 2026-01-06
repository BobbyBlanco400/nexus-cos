#!/bin/bash

# ==============================================================================
# NEXUS COS DEPLOYMENT DIAGNOSTIC SCRIPT
# ==============================================================================
# Purpose: Collect diagnostic information when deployment fails
# Usage: ./scripts/diagnose-deployment.sh
# ==============================================================================

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                                ║${NC}"
echo -e "${CYAN}║         NEXUS COS DEPLOYMENT DIAGNOSTICS                       ║${NC}"
echo -e "${CYAN}║                                                                ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  1. SYSTEM INFORMATION${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Hostname:"
hostname
echo ""

echo "OS Information:"
cat /etc/os-release | grep -E "PRETTY_NAME|VERSION"
echo ""

echo "Kernel:"
uname -r
echo ""

echo "Uptime:"
uptime
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  2. DISK SPACE${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

df -h | grep -E "Filesystem|/$|/opt"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  3. MEMORY${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

free -h
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  4. GIT STATUS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

if [[ -d ".git" ]]; then
    echo "Current Branch:"
    git branch | grep '\*'
    echo ""
    
    echo "Last Commit:"
    git log -1 --oneline
    echo ""
    
    echo "Git Status:"
    git status -s
    echo ""
else
    echo "Not a git repository"
    echo ""
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  5. NGINX STATUS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Nginx Service Status:"
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${RED}✗ Not Running${NC}"
fi
echo ""

echo "Nginx Configuration Test:"
if nginx -t 2>&1 | grep -q "successful"; then
    echo -e "${GREEN}✓ Configuration Valid${NC}"
else
    echo -e "${RED}✗ Configuration Invalid${NC}"
    nginx -t 2>&1
fi
echo ""

echo "Nginx Version:"
nginx -v 2>&1
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  6. LISTENING PORTS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Key Ports:"
netstat -tlnp 2>/dev/null | grep -E ":(80|443|3001|3004|4000)" || echo "No services listening on key ports"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  7. BACKEND HEALTH CHECKS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Port 3004 Health:"
if curl -sf http://localhost:3004/api/health >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Backend on 3004 is healthy${NC}"
    curl -s http://localhost:3004/api/health | head -n 5
else
    echo -e "${RED}✗ Backend on 3004 not responding${NC}"
fi
echo ""

echo "Port 3001 Health:"
if curl -sf http://localhost:3001/health >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Backend on 3001 is healthy${NC}"
    curl -s http://localhost:3001/health | head -n 5
else
    echo -e "${RED}✗ Backend on 3001 not responding${NC}"
fi
echo ""

echo "Port 4000 Health:"
if curl -sf http://localhost:4000/health >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Backend on 4000 is healthy${NC}"
else
    echo -e "${YELLOW}⚠ Backend on 4000 not responding (expected if not deployed)${NC}"
fi
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  8. DOMAIN CHECKS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Apex Domain (https://n3xuscos.online/):"
STATUS=$(curl -skI https://n3xuscos.online/ 2>/dev/null | head -n 1 || echo "FAILED")
if echo "$STATUS" | grep -q "200"; then
    echo -e "${GREEN}✓ 200 OK${NC}"
else
    echo -e "${RED}✗ $STATUS${NC}"
fi
echo ""

echo "Beta Domain (https://beta.n3xuscos.online/):"
STATUS=$(curl -skI https://beta.n3xuscos.online/ 2>/dev/null | head -n 1 || echo "FAILED")
if echo "$STATUS" | grep -q "200"; then
    echo -e "${GREEN}✓ 200 OK${NC}"
else
    echo -e "${RED}✗ $STATUS${NC}"
fi
echo ""

echo "API Root (https://n3xuscos.online/api/):"
STATUS=$(curl -skI https://n3xuscos.online/api/ 2>/dev/null | head -n 1 || echo "FAILED")
if echo "$STATUS" | grep -q "200"; then
    echo -e "${GREEN}✓ 200 OK${NC}"
else
    echo -e "${RED}✗ $STATUS${NC}"
fi
echo ""

echo "API Health (https://n3xuscos.online/api/health):"
STATUS=$(curl -skI https://n3xuscos.online/api/health 2>/dev/null | head -n 1 || echo "FAILED")
if echo "$STATUS" | grep -q "200"; then
    echo -e "${GREEN}✓ 200 OK${NC}"
else
    echo -e "${RED}✗ $STATUS${NC}"
fi
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  9. NGINX CONFIGURATION FILES${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo "API Proxy Config:"
if [[ -f "/etc/nginx/conf.d/nexuscos_api_proxy.conf" ]]; then
    echo -e "${GREEN}✓ File exists${NC}"
    echo "Content:"
    cat /etc/nginx/conf.d/nexuscos_api_proxy.conf
else
    echo -e "${RED}✗ File not found${NC}"
fi
echo ""

echo "Sites Enabled:"
ls -la /etc/nginx/sites-enabled/ 2>/dev/null || echo "Directory not found"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  10. RECENT NGINX ERROR LOG${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

if [[ -f "/var/log/nginx/error.log" ]]; then
    echo "Last 20 lines of error log:"
    tail -n 20 /var/log/nginx/error.log
else
    echo "Error log not found"
fi
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  11. DEPLOYMENT FILES${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Deployment Script:"
if [[ -f "DEPLOY_PHASE_2.5.sh" ]]; then
    echo -e "${GREEN}✓ DEPLOY_PHASE_2.5.sh exists${NC}"
    ls -lah DEPLOY_PHASE_2.5.sh
else
    echo -e "${RED}✗ DEPLOY_PHASE_2.5.sh not found${NC}"
fi
echo ""

echo "Validation Script:"
if [[ -f "scripts/validate-phase-2.5-deployment.sh" ]]; then
    echo -e "${GREEN}✓ validate-phase-2.5-deployment.sh exists${NC}"
else
    echo -e "${RED}✗ validate-phase-2.5-deployment.sh not found${NC}"
fi
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  12. SUMMARY${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Count issues
ISSUES=0

# Check Nginx
if ! systemctl is-active --quiet nginx; then
    echo -e "${RED}✗ Nginx is not running${NC}"
    ((ISSUES++))
fi

# Check Nginx config
if ! nginx -t 2>&1 | grep -q "successful"; then
    echo -e "${RED}✗ Nginx configuration is invalid${NC}"
    ((ISSUES++))
fi

# Check backends
if ! curl -sf http://localhost:3004/api/health >/dev/null 2>&1 && \
   ! curl -sf http://localhost:3001/health >/dev/null 2>&1; then
    echo -e "${RED}✗ No backend is responding${NC}"
    ((ISSUES++))
fi

# Check apex domain
if ! curl -skI https://n3xuscos.online/ 2>/dev/null | grep -q "200"; then
    echo -e "${RED}✗ Apex domain not returning 200${NC}"
    ((ISSUES++))
fi

# Check beta domain
if ! curl -skI https://beta.n3xuscos.online/ 2>/dev/null | grep -q "200"; then
    echo -e "${RED}✗ Beta domain not returning 200${NC}"
    ((ISSUES++))
fi

# Check API
if ! curl -skI https://n3xuscos.online/api/ 2>/dev/null | grep -q "200"; then
    echo -e "${RED}✗ API endpoint not returning 200${NC}"
    ((ISSUES++))
fi

if [[ $ISSUES -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                ║${NC}"
    echo -e "${GREEN}║              ✅  ALL SYSTEMS OPERATIONAL  ✅                   ║${NC}"
    echo -e "${GREEN}║                                                                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
else
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                                ║${NC}"
    echo -e "${RED}║           ⚠  $ISSUES ISSUES DETECTED  ⚠                           ║${NC}"
    echo -e "${RED}║                                                                ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Please report the above diagnostics for assistance."
fi
echo ""

exit 0
