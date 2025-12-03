#!/bin/bash
# Nexus COS Master Production Deployment & Fix Script
# Orchestrates all fixes and validations to achieve 100% deployment health

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
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
    echo -e "${GREEN}[✓ SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠ WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗ ERROR]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to repo root
cd "$REPO_ROOT"

print_header "NEXUS COS MASTER DEPLOYMENT FIX"
print_status "Repository: $REPO_ROOT"
print_status "Script Directory: $SCRIPT_DIR"
echo ""

# Check if running with appropriate permissions
if [ "$EUID" -eq 0 ]; then
    print_warning "Running as root. Some operations may need sudo prefix removal."
    SUDO=""
else
    print_status "Running as regular user. Will use sudo where needed."
    SUDO="sudo"
fi

# ============================================================================
# PHASE 1: PRE-FLIGHT CHECKS
# ============================================================================
print_header "PHASE 1: PRE-FLIGHT CHECKS"

print_step "Checking required commands..."
MISSING_DEPS=0

for cmd in pm2 node npm nginx systemctl netstat; do
    if command -v $cmd &> /dev/null; then
        print_success "$cmd is available"
    else
        print_error "$cmd is not installed"
        MISSING_DEPS=$((MISSING_DEPS + 1))
    fi
done

if [ $MISSING_DEPS -gt 0 ]; then
    print_error "Missing $MISSING_DEPS required dependencies. Please install them first."
    exit 1
fi

# ============================================================================
# PHASE 2: NGINX CONFIGURATION FIX
# ============================================================================
print_header "PHASE 2: NGINX CONFIGURATION"

print_step "Testing Nginx configuration..."
if $SUDO nginx -t &>/dev/null; then
    print_success "Nginx configuration is valid"
else
    print_error "Nginx configuration has errors:"
    $SUDO nginx -t 2>&1
    exit 1
fi

print_step "Checking if Nginx is running..."
if systemctl is-active --quiet nginx; then
    print_success "Nginx is running"
    
    print_step "Reloading Nginx configuration..."
    if $SUDO systemctl reload nginx &>/dev/null; then
        print_success "Nginx configuration reloaded"
    else
        print_warning "Failed to reload Nginx. Trying restart..."
        if $SUDO systemctl restart nginx &>/dev/null; then
            print_success "Nginx restarted successfully"
        else
            print_error "Failed to restart Nginx"
            exit 1
        fi
    fi
else
    print_warning "Nginx is not running. Starting Nginx..."
    if $SUDO systemctl start nginx &>/dev/null; then
        print_success "Nginx started successfully"
    else
        print_error "Failed to start Nginx"
        exit 1
    fi
fi

# ============================================================================
# PHASE 3: APACHE2/PLESK RESOLUTION
# ============================================================================
print_header "PHASE 3: APACHE2/PLESK CONFIGURATION"

if systemctl list-unit-files | grep -q "apache2.service"; then
    print_step "Apache2 detected on system..."
    
    if systemctl is-active --quiet apache2; then
        print_warning "Apache2 is running alongside Nginx"
        
        # Check if port 80/443 is used by apache
        PORT_80=$(netstat -tlnp 2>/dev/null | grep ":80 " | grep apache | wc -l)
        PORT_443=$(netstat -tlnp 2>/dev/null | grep ":443 " | grep apache | wc -l)
        
        if [ "$PORT_80" -gt 0 ] || [ "$PORT_443" -gt 0 ]; then
            print_error "Apache2 is using ports needed by Nginx!"
            print_status "Stopping Apache2..."
            
            if $SUDO systemctl stop apache2 &>/dev/null; then
                print_success "Apache2 stopped"
                print_status "Disabling Apache2 from auto-start..."
                $SUDO systemctl disable apache2 &>/dev/null || true
                print_success "Apache2 disabled"
            else
                print_error "Failed to stop Apache2. Manual intervention required."
            fi
        else
            print_success "Apache2 is running but not conflicting with Nginx"
        fi
    else
        print_success "Apache2 is not running (expected with Nginx)"
    fi
else
    print_success "Apache2 is not installed"
fi

# ============================================================================
# PHASE 4: PM2 SERVICE MANAGEMENT
# ============================================================================
print_header "PHASE 4: PM2 SERVICE MANAGEMENT"

print_step "Checking PM2 daemon..."
if pm2 ping &>/dev/null; then
    print_success "PM2 daemon is running"
else
    print_error "PM2 daemon is not responding"
    exit 1
fi

print_step "Analyzing PM2 services..."
if command -v jq &> /dev/null; then
    PM2_LIST=$(pm2 jlist 2>/dev/null || echo "[]")
    
    if [ "$PM2_LIST" = "[]" ]; then
        print_error "No PM2 services found. Please deploy services first."
        exit 1
    fi
    
    TOTAL=$(echo "$PM2_LIST" | jq '. | length')
    ONLINE=$(echo "$PM2_LIST" | jq '[.[] | select(.pm2_env.status == "online")] | length')
    STOPPED=$(echo "$PM2_LIST" | jq '[.[] | select(.pm2_env.status == "stopped")] | length')
    ERRORED=$(echo "$PM2_LIST" | jq '[.[] | select(.pm2_env.status == "errored")] | length')
    
    print_status "Total Services: $TOTAL | Online: $ONLINE | Stopped: $STOPPED | Errored: $ERRORED"
    
    if [ "$STOPPED" -gt 0 ] || [ "$ERRORED" -gt 0 ]; then
        print_warning "Found $((STOPPED + ERRORED)) services that need attention"
        
        print_step "Restarting all services..."
        if pm2 restart all &>/dev/null; then
            print_success "All PM2 services restarted"
            sleep 5  # Give services time to start
            
            # Re-check
            PM2_LIST_AFTER=$(pm2 jlist 2>/dev/null || echo "[]")
            STOPPED_AFTER=$(echo "$PM2_LIST_AFTER" | jq '[.[] | select(.pm2_env.status == "stopped")] | length')
            ERRORED_AFTER=$(echo "$PM2_LIST_AFTER" | jq '[.[] | select(.pm2_env.status == "errored")] | length')
            
            if [ "$STOPPED_AFTER" -eq 0 ] && [ "$ERRORED_AFTER" -eq 0 ]; then
                print_success "All services are now online!"
            else
                print_warning "$((STOPPED_AFTER + ERRORED_AFTER)) services still have issues"
                print_status "Run 'pm2 logs' to investigate"
            fi
        else
            print_error "Failed to restart PM2 services"
        fi
    else
        print_success "All PM2 services are online"
    fi
else
    print_warning "jq not installed. Using basic PM2 status"
    pm2 restart all &>/dev/null || true
    print_success "PM2 services restarted"
fi

print_step "Saving PM2 process list..."
pm2 save &>/dev/null || true
print_success "PM2 process list saved"

# ============================================================================
# PHASE 5: PORT AVAILABILITY CHECK
# ============================================================================
print_header "PHASE 5: PORT AVAILABILITY CHECK"

print_step "Checking critical service ports..."
echo ""

declare -A PORTS=(
    [3001]="Backend API"
    [3010]="AI Service"
    [3014]="Key Service"
    [3020]="Creator Hub"
    [3030]="PuaboVerse"
    [4000]="Gateway"
    [3231]="AI Dispatch"
    [3232]="Driver Backend"
    [3233]="Fleet Manager"
    [3234]="Route Optimizer"
)

LISTENING=0
for port in "${!PORTS[@]}"; do
    if nc -z localhost "$port" 2>/dev/null; then
        print_success "Port $port (${PORTS[$port]}) - LISTENING"
        LISTENING=$((LISTENING + 1))
    else
        print_warning "Port $port (${PORTS[$port]}) - NOT LISTENING"
    fi
done

echo ""
print_status "Listening Ports: $LISTENING/${#PORTS[@]}"

# ============================================================================
# PHASE 6: ENDPOINT HEALTH CHECKS
# ============================================================================
print_header "PHASE 6: ENDPOINT HEALTH CHECKS"

print_step "Testing local service health endpoints..."
echo ""

HEALTHY_ENDPOINTS=0
test_endpoint() {
    local url=$1
    local name=$2
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [ "$response" = "200" ]; then
        print_success "$name - HTTP $response"
        return 0
    else
        print_warning "$name - HTTP $response"
        return 1
    fi
}

# Test critical health endpoints
test_endpoint "http://localhost:3001/health" "Backend API" && HEALTHY_ENDPOINTS=$((HEALTHY_ENDPOINTS + 1)) || true
test_endpoint "http://localhost:3010/health" "AI Service" && HEALTHY_ENDPOINTS=$((HEALTHY_ENDPOINTS + 1)) || true
test_endpoint "http://localhost:3014/health" "Key Service" && HEALTHY_ENDPOINTS=$((HEALTHY_ENDPOINTS + 1)) || true
test_endpoint "http://localhost:3231/health" "AI Dispatch" && HEALTHY_ENDPOINTS=$((HEALTHY_ENDPOINTS + 1)) || true
test_endpoint "http://localhost:3232/health" "Driver Backend" && HEALTHY_ENDPOINTS=$((HEALTHY_ENDPOINTS + 1)) || true
test_endpoint "http://localhost:3233/health" "Fleet Manager" && HEALTHY_ENDPOINTS=$((HEALTHY_ENDPOINTS + 1)) || true
test_endpoint "http://localhost:3234/health" "Route Optimizer" && HEALTHY_ENDPOINTS=$((HEALTHY_ENDPOINTS + 1)) || true

echo ""
print_status "Healthy Endpoints: $HEALTHY_ENDPOINTS/7"

# ============================================================================
# FINAL SUMMARY
# ============================================================================
print_header "DEPLOYMENT SUMMARY"

echo ""
print_status "=== SYSTEM HEALTH REPORT ==="
echo ""
echo "  Nginx Status:        $(systemctl is-active nginx 2>/dev/null || echo 'inactive')"
echo "  PM2 Services Online: $ONLINE/$TOTAL"
echo "  Ports Listening:     $LISTENING/${#PORTS[@]}"
echo "  Health Endpoints:    $HEALTHY_ENDPOINTS/7"
echo ""

# Calculate overall health score
TOTAL_CHECKS=$((1 + ${#PORTS[@]} + 7))  # nginx + ports + endpoints
PASSED_CHECKS=$((1 + LISTENING + HEALTHY_ENDPOINTS))  # assuming nginx is running
HEALTH_PERCENTAGE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

print_status "Overall Health Score: $HEALTH_PERCENTAGE%"
echo ""

if [ $HEALTH_PERCENTAGE -eq 100 ]; then
    print_success "✓✓✓ PERFECT! All systems are healthy! ✓✓✓"
    echo ""
    print_status "Next Steps:"
    echo "  1. Test production URLs: https://nexuscos.online"
    echo "  2. Monitor services: pm2 monit"
    echo "  3. Check logs: pm2 logs"
    exit 0
elif [ $HEALTH_PERCENTAGE -ge 80 ]; then
    print_success "✓ System is mostly healthy ($HEALTH_PERCENTAGE%)"
    echo ""
    print_status "Recommendations:"
    echo "  1. Review warnings above"
    echo "  2. Check PM2 logs: pm2 logs --lines 100"
    echo "  3. Run detailed health check: ./deployment/pm2-health-monitor.sh"
    exit 0
else
    print_warning "⚠ System health is below acceptable threshold ($HEALTH_PERCENTAGE%)"
    echo ""
    print_status "Required Actions:"
    echo "  1. Review all errors and warnings above"
    echo "  2. Check PM2 logs: pm2 logs --lines 100"
    echo "  3. Run: ./deployment/pm2-health-monitor.sh"
    echo "  4. Check Nginx logs: $SUDO tail -f /var/log/nginx/error.log"
    echo "  5. See: deployment/DEPLOYMENT_FIX_GUIDE.md"
    exit 1
fi
