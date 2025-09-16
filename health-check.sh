#!/bin/bash

# Nexus COS Diagnostic and Health Check Script
# This script helps diagnose issues with the Nexus COS deployment

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "=================================================================="
echo "               Nexus COS Health Check & Diagnostics"
echo "=================================================================="
echo ""

# Check system services
log_info "Checking system services..."
echo ""

# Check Nginx
if systemctl is-active --quiet nginx; then
    log_success "✅ Nginx is running"
    echo "   Status: $(systemctl is-active nginx)"
    echo "   Enabled: $(systemctl is-enabled nginx)"
else
    log_error "❌ Nginx is not running"
    echo "   Status: $(systemctl is-active nginx)"
    echo "   Recent logs:"
    journalctl -u nginx --lines=5 --no-pager
fi

echo ""

# Check PM2 processes
log_info "Checking PM2 processes..."
if command -v pm2 >/dev/null 2>&1; then
    pm2 list
    echo ""
    log_info "PM2 process details:"
    pm2 jlist | jq -r '.[] | "Name: \(.name), Status: \(.pm2_env.status), PID: \(.pid), Memory: \(.pm2_env.memory)"' 2>/dev/null || pm2 jlist
else
    log_error "❌ PM2 is not installed"
fi

echo ""

# Check backend health endpoints
log_info "Testing backend health endpoints..."

# Test Node.js backend
NODE_HEALTH=$(curl -s --max-time 5 http://localhost:3000/health 2>/dev/null || echo "connection_failed")
if [[ "$NODE_HEALTH" == *"ok"* ]]; then
    log_success "✅ Node.js backend health check passed"
    echo "   Response: $NODE_HEALTH"
else
    log_error "❌ Node.js backend health check failed"
    echo "   Response: $NODE_HEALTH"
    echo "   Testing direct connection:"
    nc -zv localhost 3000 2>&1 || echo "   Port 3000 not responding"
fi

# Test Python backend
PYTHON_HEALTH=$(curl -s --max-time 5 http://localhost:3001/health 2>/dev/null || echo "connection_failed")
if [[ "$PYTHON_HEALTH" == *"ok"* ]]; then
    log_success "✅ Python backend health check passed"
    echo "   Response: $PYTHON_HEALTH"
else
    log_error "❌ Python backend health check failed"
    echo "   Response: $PYTHON_HEALTH"
    echo "   Testing direct connection:"
    nc -zv localhost 3001 2>&1 || echo "   Port 3001 not responding"
fi

echo ""

# Check frontend deployment
log_info "Checking frontend deployment..."
FRONTEND_DIR="/var/www/nexus-cos"
if [ -d "$FRONTEND_DIR" ] && [ -f "$FRONTEND_DIR/index.html" ]; then
    log_success "✅ Frontend files deployed"
    echo "   Directory: $FRONTEND_DIR"
    echo "   Files: $(ls -la $FRONTEND_DIR | wc -l) items"
    echo "   Index file size: $(stat -c%s $FRONTEND_DIR/index.html 2>/dev/null || echo "not found") bytes"
else
    log_error "❌ Frontend files missing"
    echo "   Directory exists: $([ -d "$FRONTEND_DIR" ] && echo "Yes" || echo "No")"
    echo "   Index.html exists: $([ -f "$FRONTEND_DIR/index.html" ] && echo "Yes" || echo "No")"
fi

echo ""

# Check Nginx configuration
log_info "Checking Nginx configuration..."
if nginx -t 2>/dev/null; then
    log_success "✅ Nginx configuration is valid"
else
    log_error "❌ Nginx configuration has errors:"
    nginx -t
fi

# Check if sites are enabled
if [ -f "/etc/nginx/sites-enabled/nexuscos.online.conf" ]; then
    log_success "✅ Nexus COS site is enabled"
else
    log_warning "⚠️  Nexus COS site configuration not found in sites-enabled"
fi

echo ""

# Check SSL certificates
log_info "Checking SSL certificates..."
if command -v certbot >/dev/null 2>&1; then
    CERT_INFO=$(certbot certificates 2>/dev/null)
    if [[ "$CERT_INFO" == *"nexuscos.online"* ]]; then
        log_success "✅ SSL certificate found for nexuscos.online"
        echo "$CERT_INFO" | grep -A 5 "nexuscos.online"
    else
        log_warning "⚠️  No SSL certificate found for nexuscos.online"
        echo "   Available certificates:"
        echo "$CERT_INFO"
    fi
else
    log_warning "⚠️  Certbot not installed"
fi

echo ""

# Test external access
log_info "Testing external website access..."
DOMAIN="nexuscos.online"

# Test HTTP
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 http://localhost/ 2>/dev/null || echo "000")
if [[ "$HTTP_STATUS" =~ ^[2-3][0-9][0-9]$ ]]; then
    log_success "✅ HTTP access working (Status: $HTTP_STATUS)"
else
    log_error "❌ HTTP access failed (Status: $HTTP_STATUS)"
fi

# Test if domain resolves
if nslookup "$DOMAIN" >/dev/null 2>&1; then
    log_success "✅ Domain $DOMAIN resolves"
    echo "   IP: $(nslookup $DOMAIN | grep -A 1 "Name:" | tail -1 | awk '{print $2}' || echo "unknown")"
else
    log_warning "⚠️  Domain $DOMAIN does not resolve"
fi

echo ""

# Check disk space
log_info "Checking disk space..."
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    log_success "✅ Disk space OK ($DISK_USAGE% used)"
else
    log_warning "⚠️  Disk space low ($DISK_USAGE% used)"
fi

echo ""

# Check memory usage
log_info "Checking memory usage..."
MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
if [ "$MEMORY_USAGE" -lt 80 ]; then
    log_success "✅ Memory usage OK ($MEMORY_USAGE% used)"
else
    log_warning "⚠️  Memory usage high ($MEMORY_USAGE% used)"
fi

echo ""

# Recent logs
log_info "Recent system logs..."
echo "=== Nginx Error Logs (last 5 lines) ==="
tail -5 /var/log/nginx/error.log 2>/dev/null || echo "No nginx error logs found"

echo ""
echo "=== PM2 Logs (last 10 lines) ==="
pm2 logs --lines 10 --nostream 2>/dev/null || echo "No PM2 logs available"

echo ""

# Recommendations
log_info "Troubleshooting recommendations:"
echo ""

if ! systemctl is-active --quiet nginx; then
    echo "🔧 Nginx is not running:"
    echo "   sudo systemctl start nginx"
    echo "   sudo systemctl enable nginx"
    echo ""
fi

if [[ "$NODE_HEALTH" != *"ok"* ]]; then
    echo "🔧 Node.js backend issues:"
    echo "   pm2 restart nexus-node-backend"
    echo "   pm2 logs nexus-node-backend"
    echo "   Check if dependencies are installed: cd /opt/nexus-cos/backend && npm install"
    echo ""
fi

if [[ "$PYTHON_HEALTH" != *"ok"* ]]; then
    echo "🔧 Python backend issues:"
    echo "   pm2 restart nexus-python-backend"
    echo "   pm2 logs nexus-python-backend"
    echo "   Check virtual environment: cd /opt/nexus-cos/backend && source .venv/bin/activate && pip install fastapi uvicorn"
    echo ""
fi

if [ ! -f "/var/www/nexus-cos/index.html" ]; then
    echo "🔧 Frontend not deployed:"
    echo "   cd /opt/nexus-cos/frontend && npm run build"
    echo "   sudo cp -r dist/* /var/www/nexus-cos/"
    echo "   sudo chown -R www-data:www-data /var/www/nexus-cos"
    echo ""
fi

if ! nginx -t 2>/dev/null; then
    echo "🔧 Nginx configuration errors:"
    echo "   sudo nginx -t  # Check specific errors"
    echo "   sudo cp /opt/nexus-cos/deployment/nginx/nexuscos.online.conf /etc/nginx/sites-available/"
    echo "   sudo ln -sf /etc/nginx/sites-available/nexuscos.online.conf /etc/nginx/sites-enabled/"
    echo ""
fi

echo "=================================================================="
log_info "Health check complete. Run this script periodically to monitor system health."
echo "=================================================================="