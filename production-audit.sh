#!/bin/bash
# Nexus COS Production Audit Script
# Validates all critical components for production deployment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
PASSED=0
FAILED=0
WARNINGS=0

print_header() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    🔍 NEXUS COS PRODUCTION AUDIT                             ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}▶ $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "  ${GREEN}✅ $1${NC}"
    ((PASSED++))
}

print_error() {
    echo -e "  ${RED}❌ $1${NC}"
    ((FAILED++))
}

print_warning() {
    echo -e "  ${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

print_info() {
    echo -e "  ${BLUE}ℹ️  $1${NC}"
}

# Start audit
print_header
echo -e "${BLUE}Starting production audit at $(date)${NC}"
echo ""

# 1. Check Docker Services
print_section "1. Docker Services"

if command -v docker &> /dev/null; then
    print_success "Docker is installed"
    
    # Check PostgreSQL container
    if docker ps | grep -q "nexus-postgres"; then
        print_success "PostgreSQL container is running"
        
        # Check if PostgreSQL is ready
        if docker exec nexus-postgres pg_isready -U nexuscos &> /dev/null; then
            print_success "PostgreSQL is accepting connections"
        else
            print_error "PostgreSQL is not ready"
        fi
    else
        if docker ps -a | grep -q "nexus-postgres"; then
            print_warning "PostgreSQL container exists but is not running"
        else
            print_error "PostgreSQL container not found"
        fi
    fi
else
    print_warning "Docker not installed (may not be required)"
fi

# 2. Check PM2 Services
print_section "2. PM2 Services Status"

if command -v pm2 &> /dev/null; then
    print_success "PM2 is installed"
    
    # Define critical services
    CRITICAL_SERVICES=("backend-api" "puabomusicchain" "ai-service" "key-service")
    
    for service in "${CRITICAL_SERVICES[@]}"; do
        if pm2 describe "$service" &> /dev/null; then
            if pm2 describe "$service" | grep -q "online"; then
                print_success "$service is ONLINE"
            else
                status=$(pm2 describe "$service" | grep "status" | head -1 | awk '{print $4}')
                print_error "$service is $status"
            fi
        else
            print_warning "$service is not in PM2"
        fi
    done
    
    # Check for errored services
    ERRORED=$(pm2 jlist 2>/dev/null | grep -o '"status":"errored"' | wc -l)
    if [ "$ERRORED" -eq 0 ]; then
        print_success "No services in errored state"
    else
        print_error "$ERRORED service(s) in errored state"
    fi
else
    print_error "PM2 is not installed"
fi

# 3. Check Service Ports
print_section "3. Service Port Availability"

check_port() {
    local port=$1
    local service=$2
    
    if nc -z localhost "$port" 2>/dev/null || lsof -i :"$port" &>/dev/null; then
        print_success "$service is listening on port $port"
    else
        print_error "$service is NOT listening on port $port"
    fi
}

check_port 3001 "Backend API"
check_port 3013 "PuaboMusicChain"
check_port 5432 "PostgreSQL"
check_port 8088 "V-Screen Hollywood"

# 4. Check Service Health Endpoints
print_section "4. Service Health Endpoints"

check_health() {
    local url=$1
    local service=$2
    
    if response=$(curl -s --max-time 5 "$url" 2>/dev/null); then
        if echo "$response" | grep -q "ok\|healthy\|running"; then
            print_success "$service health check passed"
        else
            print_warning "$service responded but format unexpected"
        fi
    else
        print_error "$service health check failed"
    fi
}

check_health "http://localhost:3001/health" "Backend API"
check_health "http://localhost:3013/health" "PuaboMusicChain"
check_health "http://localhost:8088/health" "V-Screen Hollywood"

# 5. Check Configuration Files
print_section "5. Configuration Files"

check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        print_success "$description exists"
    else
        print_error "$description is missing"
    fi
}

check_file ".env" ".env configuration"
check_file "ecosystem.config.js" "PM2 ecosystem config"
check_file "package.json" "Root package.json"
check_file "services/backend-api/server.js" "Backend API server"
check_file "services/puabomusicchain/server.js" "PuaboMusicChain server"

# 6. Check Node Modules
print_section "6. Dependencies"

if [ -d "node_modules" ]; then
    print_success "Root node_modules exists"
else
    print_warning "Root node_modules missing"
fi

if [ -d "services/backend-api/node_modules" ]; then
    print_success "Backend API node_modules exists"
else
    print_error "Backend API node_modules missing"
fi

if [ -d "services/puabomusicchain/node_modules" ]; then
    print_success "PuaboMusicChain node_modules exists"
else
    print_error "PuaboMusicChain node_modules missing"
fi

# 7. Check System Resources
print_section "7. System Resources"

# Check disk space
DISK_USAGE=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    print_success "Disk usage: ${DISK_USAGE}%"
else
    print_warning "Disk usage high: ${DISK_USAGE}%"
fi

# Check memory
if command -v free &> /dev/null; then
    MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    if [ "$MEMORY_USAGE" -lt 80 ]; then
        print_success "Memory usage: ${MEMORY_USAGE}%"
    else
        print_warning "Memory usage high: ${MEMORY_USAGE}%"
    fi
fi

# 8. Check Nginx (if installed)
print_section "8. Web Server Configuration"

if command -v nginx &> /dev/null; then
    print_success "Nginx is installed"
    
    if nginx -t &> /dev/null; then
        print_success "Nginx configuration is valid"
    else
        print_error "Nginx configuration has errors"
    fi
    
    if systemctl is-active --quiet nginx 2>/dev/null; then
        print_success "Nginx is running"
    else
        print_warning "Nginx is not running"
    fi
else
    print_info "Nginx not installed (optional)"
fi

# 9. Check SSL Certificates (if applicable)
print_section "9. SSL Configuration"

if [ -f "/etc/letsencrypt/live/nexuscos.online/fullchain.pem" ]; then
    print_success "SSL certificate exists"
    
    # Check certificate expiry
    CERT_EXPIRY=$(openssl x509 -enddate -noout -in /etc/letsencrypt/live/nexuscos.online/fullchain.pem 2>/dev/null | cut -d= -f2)
    if [ -n "$CERT_EXPIRY" ]; then
        print_info "Certificate expires: $CERT_EXPIRY"
    fi
else
    print_info "SSL certificate not found (may not be configured yet)"
fi

# 10. Check Environment Variables
print_section "10. Environment Configuration"

if [ -f ".env" ]; then
    # Check for required variables
    REQUIRED_VARS=("DB_HOST" "DB_NAME" "DB_USER" "DB_PASSWORD" "NODE_ENV")
    
    for var in "${REQUIRED_VARS[@]}"; do
        if grep -q "^${var}=" .env; then
            print_success "$var is configured"
        else
            print_error "$var is missing from .env"
        fi
    done
fi

# Final Summary
print_section "AUDIT SUMMARY"

TOTAL=$((PASSED + FAILED + WARNINGS))
SUCCESS_RATE=$((PASSED * 100 / TOTAL))

echo ""
echo -e "${BLUE}Total Checks:${NC} $TOTAL"
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo ""
echo -e "${BLUE}Success Rate:${NC} ${SUCCESS_RATE}%"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ PRODUCTION READY - All critical checks passed!           ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    exit 0
elif [ "$FAILED" -le 3 ]; then
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠️  MOSTLY READY - Some issues need attention              ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Review the failed checks above and run:${NC}"
    echo -e "${BLUE}./fix-deployment-issues.sh${NC}"
    exit 1
else
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ NOT READY - Critical issues detected                     ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}Please fix the issues above before deploying to production.${NC}"
    echo -e "${YELLOW}Run the fix script:${NC} ${BLUE}./fix-deployment-issues.sh${NC}"
    exit 1
fi
