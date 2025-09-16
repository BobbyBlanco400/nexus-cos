#!/bin/bash
# Nexus COS Production Diagnosis Script
# Diagnoses current state and errors on nexuscos.online

echo "🔍 Nexus COS Production Diagnosis Starting..."
echo "============================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_check() {
    echo -e "${BLUE}[CHECK]${NC} $1"
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. System Services Status
echo ""
log_check "Checking system services..."

# Nginx status
if systemctl is-active --quiet nginx; then
    log_ok "Nginx is running"
else
    log_error "Nginx is not running"
    echo "  └─ Status: $(systemctl show -p SubState --value nginx)"
fi

# Check nginx configuration
if nginx -t 2>/dev/null; then
    log_ok "Nginx configuration is valid"
else
    log_error "Nginx configuration has errors:"
    nginx -t
fi

# 2. Port Status
echo ""
log_check "Checking port availability..."

for port in 80 443 3000 3001; do
    if netstat -ln 2>/dev/null | grep ":$port " >/dev/null; then
        log_ok "Port $port is in use"
    else
        log_warn "Port $port is not in use"
    fi
done

# 3. Backend Process Status
echo ""
log_check "Checking backend processes..."

# Check Node.js processes
NODE_PROCS=$(pgrep -f "node.*server" | wc -l)
if [ "$NODE_PROCS" -gt 0 ]; then
    log_ok "Node.js processes found: $NODE_PROCS"
else
    log_error "No Node.js backend processes found"
fi

# Check Python processes
PYTHON_PROCS=$(pgrep -f "uvicorn.*main" | wc -l)
if [ "$PYTHON_PROCS" -gt 0 ]; then
    log_ok "Python/Uvicorn processes found: $PYTHON_PROCS"
else
    log_error "No Python backend processes found"
fi

# 4. PM2 Status
echo ""
log_check "Checking PM2 status..."
if command -v pm2 >/dev/null 2>&1; then
    pm2 list 2>/dev/null | head -20
else
    log_warn "PM2 not installed"
fi

# 5. Log Analysis
echo ""
log_check "Analyzing recent logs..."

# Nginx logs
if [ -f /var/log/nginx/error.log ]; then
    echo "Recent Nginx errors:"
    tail -20 /var/log/nginx/error.log | grep -E "(error|crit|alert|emerg)" | tail -5
else
    log_warn "Nginx error log not found"
fi

# System logs for services
echo ""
echo "Recent systemd service errors:"
journalctl --since "1 hour ago" -p err --no-pager | tail -10

# 6. Directory and File Permissions
echo ""
log_check "Checking file permissions and directories..."

# Frontend directory
if [ -d "/var/www/nexus-cos" ]; then
    FRONTEND_OWNER=$(stat -c '%U:%G' /var/www/nexus-cos)
    log_ok "Frontend directory exists (owner: $FRONTEND_OWNER)"
    
    if [ -f "/var/www/nexus-cos/index.html" ]; then
        log_ok "Frontend index.html exists"
    else
        log_error "Frontend index.html missing"
    fi
else
    log_error "Frontend directory /var/www/nexus-cos does not exist"
fi

# Backend directories
if [ -d "backend" ]; then
    log_ok "Backend directory exists"
    
    if [ -d "backend/node_modules" ]; then
        log_ok "Node.js dependencies installed"
    else
        log_error "Node.js dependencies missing"
    fi
    
    if [ -d "backend/.venv" ]; then
        log_ok "Python virtual environment exists"
    else
        log_error "Python virtual environment missing"
    fi
else
    log_error "Backend directory not found"
fi

# 7. SSL Certificate Status
echo ""
log_check "Checking SSL certificates..."

if [ -f "/etc/letsencrypt/live/nexuscos.online/fullchain.pem" ]; then
    CERT_EXPIRY=$(openssl x509 -enddate -noout -in /etc/letsencrypt/live/nexuscos.online/fullchain.pem | cut -d= -f2)
    log_ok "SSL certificate exists (expires: $CERT_EXPIRY)"
else
    log_error "SSL certificate not found"
fi

# 8. Health Endpoint Tests
echo ""
log_check "Testing health endpoints..."

# Test Node.js health
if curl -f -s --max-time 5 http://localhost:3000/health >/dev/null 2>&1; then
    log_ok "Node.js health endpoint responding"
else
    log_error "Node.js health endpoint not responding"
fi

# Test Python health
if curl -f -s --max-time 5 http://localhost:3001/health >/dev/null 2>&1; then
    log_ok "Python health endpoint responding"
else
    log_error "Python health endpoint not responding"
fi

# Test external access
if curl -f -s --max-time 10 http://nexuscos.online/health >/dev/null 2>&1; then
    log_ok "External health endpoint accessible"
else
    log_error "External health endpoint not accessible"
fi

# 9. Resource Usage
echo ""
log_check "Checking system resources..."

echo "Memory usage:"
free -h

echo ""
echo "Disk usage:"
df -h / /var

echo ""
echo "Load average:"
uptime

# 10. Network connectivity
echo ""
log_check "Checking network connectivity..."

# Check DNS resolution
if nslookup nexuscos.online >/dev/null 2>&1; then
    log_ok "DNS resolution working"
else
    log_error "DNS resolution failed"
fi

# Generate summary
echo ""
echo "============================================="
echo "🔍 DIAGNOSIS COMPLETE"
echo "============================================="

# Count issues
ERRORS=$(grep -E "\[ERROR\]" /tmp/diagnosis_output.log 2>/dev/null | wc -l || echo "0")
WARNINGS=$(grep -E "\[WARN\]" /tmp/diagnosis_output.log 2>/dev/null | wc -l || echo "0")

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}✅ No critical issues found${NC}"
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS warnings found, but no critical errors${NC}"
else
    echo -e "${RED}❌ $ERRORS errors found that need attention${NC}"
fi

echo ""
echo "💡 RECOMMENDED ACTIONS:"
echo "   1. Run production-deploy.sh for full recovery"
echo "   2. Check logs: journalctl -f"
echo "   3. Check Nginx: sudo systemctl status nginx"
echo "   4. Check PM2: pm2 status"