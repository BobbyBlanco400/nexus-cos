#!/bin/bash
# Nexus COS Production Deployment Fix Script
# This script applies all necessary fixes and validates the deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${MAGENTA}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Track issues
WARNINGS=0
ERRORS=0
FIXES_APPLIED=0

print_header "NEXUS COS PRODUCTION DEPLOYMENT FIX"

# Check if running with appropriate permissions
if [ "$EUID" -eq 0 ]; then
    print_warning "Running as root. This is acceptable for production deployment."
fi

print_header "PHASE 1: ENVIRONMENT VALIDATION"

# Check if PM2 is installed
print_step "Checking PM2 installation..."
if command -v pm2 &> /dev/null; then
    PM2_VERSION=$(pm2 -v)
    print_success "PM2 installed (version: $PM2_VERSION)"
else
    print_error "PM2 is not installed. Please install PM2 first: npm install -g pm2"
    ERRORS=$((ERRORS + 1))
fi

# Check if Nginx is installed
print_step "Checking Nginx installation..."
if command -v nginx &> /dev/null; then
    NGINX_VERSION=$(nginx -v 2>&1 | cut -d'/' -f2)
    print_success "Nginx installed (version: $NGINX_VERSION)"
else
    print_error "Nginx is not installed. Please install Nginx first."
    ERRORS=$((ERRORS + 1))
fi

# Check Node.js installation
print_step "Checking Node.js installation..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    print_success "Node.js installed (version: $NODE_VERSION)"
else
    print_error "Node.js is not installed. Please install Node.js first."
    ERRORS=$((ERRORS + 1))
fi

if [ $ERRORS -gt 0 ]; then
    print_error "Critical dependencies missing. Please install required software first."
    exit 1
fi

print_header "PHASE 2: NGINX CONFIGURATION CHECK"

print_step "Testing Nginx configuration..."
if sudo nginx -t &>/dev/null; then
    print_success "Nginx configuration is valid"
else
    print_error "Nginx configuration has errors:"
    sudo nginx -t 2>&1
    ERRORS=$((ERRORS + 1))
fi

print_step "Checking if Nginx is running..."
if systemctl is-active --quiet nginx; then
    print_success "Nginx is running"
else
    print_warning "Nginx is not running. Will attempt to start it."
    WARNINGS=$((WARNINGS + 1))
fi

print_header "PHASE 3: PM2 SERVICE STATUS CHECK"

print_step "Checking PM2 daemon..."
if pm2 ping &>/dev/null; then
    print_success "PM2 daemon is running"
else
    print_warning "PM2 daemon is not responding"
    WARNINGS=$((WARNINGS + 1))
fi

print_step "Analyzing PM2 services..."
echo ""

# Get PM2 list as JSON
PM2_LIST=$(pm2 jlist 2>/dev/null || echo "[]")

if [ "$PM2_LIST" = "[]" ]; then
    print_error "No PM2 services found. Services need to be deployed."
    ERRORS=$((ERRORS + 1))
else
    # Count services by status
    TOTAL_SERVICES=$(echo "$PM2_LIST" | jq '. | length' 2>/dev/null || echo "0")
    ONLINE_SERVICES=$(echo "$PM2_LIST" | jq '[.[] | select(.pm2_env.status == "online")] | length' 2>/dev/null || echo "0")
    STOPPED_SERVICES=$(echo "$PM2_LIST" | jq '[.[] | select(.pm2_env.status == "stopped")] | length' 2>/dev/null || echo "0")
    
    print_status "Total PM2 Services: $TOTAL_SERVICES"
    print_status "Online Services: $ONLINE_SERVICES"
    print_status "Stopped Services: $STOPPED_SERVICES"
    
    if [ "$STOPPED_SERVICES" -gt 0 ]; then
        print_warning "$STOPPED_SERVICES services are stopped"
        echo ""
        echo "Stopped services:"
        echo "$PM2_LIST" | jq -r '.[] | select(.pm2_env.status == "stopped") | "  - \(.name) (id: \(.pm_id))"' 2>/dev/null || echo "  (Unable to parse service list)"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

echo ""

print_header "PHASE 4: PORT AVAILABILITY CHECK"

print_step "Checking critical service ports..."
echo ""

# Define critical ports
declare -A PORTS=(
    [3001]="Backend API"
    [3010]="AI Service"
    [3014]="Key Service"
    [3020]="Creator Hub"
    [3030]="PuaboVerse"
    [4000]="Gateway"
    [3231]="AI Dispatch (PUABO NEXUS)"
    [3232]="Driver Backend (PUABO NEXUS)"
    [3233]="Fleet Manager (PUABO NEXUS)"
    [3234]="Route Optimizer (PUABO NEXUS)"
)

LISTENING_PORTS=0
NOT_LISTENING=()

for port in "${!PORTS[@]}"; do
    if nc -z localhost "$port" 2>/dev/null; then
        print_success "Port $port (${PORTS[$port]}) - LISTENING"
        LISTENING_PORTS=$((LISTENING_PORTS + 1))
    else
        print_warning "Port $port (${PORTS[$port]}) - NOT LISTENING"
        NOT_LISTENING+=("$port:${PORTS[$port]}")
        WARNINGS=$((WARNINGS + 1))
    fi
done

echo ""
print_status "Listening Ports: $LISTENING_PORTS/${#PORTS[@]}"

if [ ${#NOT_LISTENING[@]} -gt 0 ]; then
    print_warning "The following ports are not listening:"
    for item in "${NOT_LISTENING[@]}"; do
        echo "  - $item"
    done
fi

print_header "PHASE 5: APPLY FIXES"

# Fix 1: Restart stopped PM2 services
if [ "$STOPPED_SERVICES" -gt 0 ]; then
    print_step "Restarting stopped PM2 services..."
    if pm2 restart all &>/dev/null; then
        print_success "PM2 services restarted"
        FIXES_APPLIED=$((FIXES_APPLIED + 1))
        sleep 3  # Give services time to start
    else
        print_error "Failed to restart PM2 services"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Fix 2: Reload Nginx if configuration was updated
if [ -f "/etc/nginx/sites-available/nexuscos.online.conf" ]; then
    print_step "Reloading Nginx configuration..."
    if sudo systemctl reload nginx &>/dev/null; then
        print_success "Nginx configuration reloaded"
        FIXES_APPLIED=$((FIXES_APPLIED + 1))
    else
        print_warning "Failed to reload Nginx (may need manual intervention)"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# Fix 3: Ensure PM2 saves state
print_step "Saving PM2 process list..."
if pm2 save &>/dev/null; then
    print_success "PM2 process list saved"
    FIXES_APPLIED=$((FIXES_APPLIED + 1))
else
    print_warning "Failed to save PM2 process list"
    WARNINGS=$((WARNINGS + 1))
fi

print_header "PHASE 6: POST-FIX VALIDATION"

# Re-check PM2 services
print_step "Re-checking PM2 service status..."
PM2_LIST_AFTER=$(pm2 jlist 2>/dev/null || echo "[]")
if [ "$PM2_LIST_AFTER" != "[]" ]; then
    ONLINE_AFTER=$(echo "$PM2_LIST_AFTER" | jq '[.[] | select(.pm2_env.status == "online")] | length' 2>/dev/null || echo "0")
    STOPPED_AFTER=$(echo "$PM2_LIST_AFTER" | jq '[.[] | select(.pm2_env.status == "stopped")] | length' 2>/dev/null || echo "0")
    
    print_status "Services online: $ONLINE_AFTER"
    print_status "Services stopped: $STOPPED_AFTER"
    
    if [ "$STOPPED_AFTER" -eq 0 ]; then
        print_success "All PM2 services are now online!"
    else
        print_warning "$STOPPED_AFTER services are still stopped. Check logs: pm2 logs"
    fi
fi

# Re-check ports
print_step "Re-checking critical ports..."
LISTENING_AFTER=0
for port in "${!PORTS[@]}"; do
    if nc -z localhost "$port" 2>/dev/null; then
        LISTENING_AFTER=$((LISTENING_AFTER + 1))
    fi
done
print_status "Ports listening: $LISTENING_AFTER/${#PORTS[@]}"

print_header "DEPLOYMENT FIX SUMMARY"

echo ""
print_status "Fixes Applied: $FIXES_APPLIED"
print_status "Warnings: $WARNINGS"
print_status "Errors: $ERRORS"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    print_success "✓ All checks passed! Deployment is healthy."
    echo ""
    print_status "Next steps:"
    echo "  1. Test production URLs: https://nexuscos.online"
    echo "  2. Run endpoint tests: ./deployment/test-production-endpoints.sh"
    echo "  3. Monitor logs: pm2 logs"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    print_warning "⚠ Deployment completed with warnings. Review the output above."
    echo ""
    print_status "Recommended actions:"
    echo "  1. Check PM2 logs: pm2 logs --lines 100"
    echo "  2. Verify services: pm2 status"
    echo "  3. Check nginx: sudo systemctl status nginx"
    exit 0
else
    print_error "✗ Deployment has critical errors. Manual intervention required."
    echo ""
    print_status "Troubleshooting steps:"
    echo "  1. Review errors above"
    echo "  2. Check PM2 logs: pm2 logs --lines 100"
    echo "  3. Check nginx logs: sudo tail -f /var/log/nginx/error.log"
    echo "  4. See deployment/DEPLOYMENT_FIX_GUIDE.md for detailed help"
    exit 2
fi
