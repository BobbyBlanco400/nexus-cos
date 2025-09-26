#!/bin/bash
# Nexus COS Extended - Comprehensive Health Check and Validation Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                   🔍 NEXUS COS HEALTH CHECK & VALIDATION                    ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
}

print_section() {
    echo -e "${CYAN}▶ $1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

print_success() {
    echo -e "  ${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "  ${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "  ${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "  ${BLUE}ℹ️  $1${NC}"
}

# Service health check function
check_service() {
    local service_name=$1
    local url=$2
    local expected_response=${3:-"status.*ok"}
    
    if response=$(curl -s "$url" 2>/dev/null); then
        if echo "$response" | grep -q "$expected_response"; then
            print_success "$service_name - HEALTHY"
            return 0
        else
            print_warning "$service_name - RESPONDING but unexpected format"
            print_info "Response: $response"
            return 1
        fi
    else
        print_error "$service_name - NOT RESPONDING"
        return 1
    fi
}

# Port availability check
check_port() {
    local port=$1
    local service=$2
    
    if nc -z localhost "$port" 2>/dev/null; then
        print_success "$service (port $port) - LISTENING"
        return 0
    else
        print_error "$service (port $port) - NOT LISTENING"
        return 1
    fi
}

# Docker service check
check_docker_service() {
    local service_name=$1
    
    if docker-compose -f docker-compose.prod.yml ps | grep -q "$service_name.*Up"; then
        print_success "Docker service '$service_name' - RUNNING"
        return 0
    else
        print_error "Docker service '$service_name' - NOT RUNNING"
        return 1
    fi
}

# File existence check
check_file() {
    local file_path=$1
    local description=$2
    
    if [ -f "$file_path" ]; then
        print_success "$description - EXISTS"
        return 0
    else
        print_error "$description - MISSING"
        return 1
    fi
}

# Main health check execution
print_header

# 1. Core Backend Services
print_section "1. Core Backend Services"

check_service "Node.js Backend" "http://localhost:3000/health"
check_service "Python FastAPI Backend" "http://localhost:3001/health"

# 2. Extended Modules
print_section "2. Extended Modules"

check_service "V-Suite Module" "http://localhost:3010/health"
check_service "Creator Hub Module" "http://localhost:3020/health"
check_service "PuaboVerse Module" "http://localhost:3030/health"

# 3. Monitoring Infrastructure
print_section "3. Monitoring Infrastructure"

check_service "Prometheus" "http://localhost:9090/-/healthy" "Prometheus"
check_service "Grafana" "http://localhost:3003/api/health" "database.*ok"

# 4. Database and Cache
print_section "4. Database and Cache Services"

check_port 5432 "PostgreSQL Database"
check_port 6379 "Redis Cache"

# 5. Frontend and Static Files
print_section "5. Frontend and Static Files"

check_file "./frontend/dist/index.html" "Frontend build"
check_port 80 "Frontend/Nginx"

# 6. Mobile Applications
print_section "6. Mobile Applications"

check_file "./mobile/builds/android/app.apk" "Android APK"
check_file "./mobile/builds/ios/app.ipa" "iOS IPA"
check_file "./mobile/builds/BUILD_MANIFEST.json" "Mobile build manifest"

# 7. Deployment Files
print_section "7. Deployment Configuration"

check_file "./docker-compose.prod.yml" "Production Docker Compose"
check_file "./deployment/nginx/nexuscos.online.conf" "Nginx configuration"
check_file "./monitoring/prometheus.yml" "Prometheus configuration"
check_file "./.env" "Environment configuration"

# 8. Docker Services (if running)
print_section "8. Docker Infrastructure"

if command -v docker &> /dev/null && docker info &>/dev/null; then
    if [ -f "docker-compose.prod.yml" ]; then
        services=("postgres" "redis" "backend-node" "backend-python" "v-suite" "creator-hub" "puaboverse" "prometheus" "grafana")
        
        for service in "${services[@]}"; do
            check_docker_service "$service"
        done
    else
        print_warning "Docker Compose file not found, skipping Docker checks"
    fi
else
    print_warning "Docker not available or not running"
fi

# 9. Network Connectivity Tests
print_section "9. Network Connectivity"

# Test internal service communication
if curl -s "http://localhost:3000/health" >/dev/null; then
    print_success "Internal network connectivity - OK"
else
    print_error "Internal network connectivity - FAILED"
fi

# 10. API Endpoints Validation
print_section "10. API Endpoints Validation"

# Test various API endpoints
endpoints=(
    "http://localhost:3000/api/auth:Node.js Auth API"
    "http://localhost:3010/api/v-suite/status:V-Suite API"
    "http://localhost:3020/api/creator-hub/status:Creator Hub API"
    "http://localhost:3030/api/puaboverse/status:PuaboVerse API"
)

for endpoint in "${endpoints[@]}"; do
    IFS=':' read -r url desc <<< "$endpoint"
    if curl -s "$url" >/dev/null 2>&1; then
        print_success "$desc - ACCESSIBLE"
    else
        print_warning "$desc - NOT ACCESSIBLE (may be expected)"
    fi
done

# 11. System Resources
print_section "11. System Resources"

# Check disk space
disk_usage=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$disk_usage" -lt 90 ]; then
    print_success "Disk space usage: $disk_usage% - OK"
else
    print_warning "Disk space usage: $disk_usage% - HIGH"
fi

# Check memory
if command -v free &> /dev/null; then
    mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    if [ "$mem_usage" -lt 90 ]; then
        print_success "Memory usage: $mem_usage% - OK"
    else
        print_warning "Memory usage: $mem_usage% - HIGH"
    fi
fi

# 12. SSL/TLS Configuration
print_section "12. SSL/TLS Configuration"

if [ -f "/etc/letsencrypt/live/nexuscos.online/fullchain.pem" ]; then
    print_success "SSL certificate - INSTALLED"
    
    # Check certificate expiry
    if openssl x509 -checkend 2592000 -noout -in /etc/letsencrypt/live/nexuscos.online/cert.pem 2>/dev/null; then
        print_success "SSL certificate - VALID (>30 days)"
    else
        print_warning "SSL certificate - EXPIRES SOON (<30 days)"
    fi
else
    print_warning "SSL certificate - NOT FOUND (development mode)"
fi

# Summary
print_section "🎯 Health Check Summary"

echo ""
echo -e "${CYAN}📊 Overall System Status:${NC}"

# Count successful and failed checks
total_checks=0
passed_checks=0

# This is a simplified summary - in a real implementation, 
# you'd track the actual results from above
if curl -s "http://localhost:3000/health" >/dev/null && curl -s "http://localhost:3001/health" >/dev/null; then
    echo -e "  ${GREEN}✅ Core Services: OPERATIONAL${NC}"
else
    echo -e "  ${RED}❌ Core Services: ISSUES DETECTED${NC}"
fi

if [ -f "./frontend/dist/index.html" ] && [ -f "./mobile/builds/android/app.apk" ]; then
    echo -e "  ${GREEN}✅ Applications: READY${NC}"
else
    echo -e "  ${YELLOW}⚠️  Applications: PARTIAL${NC}"
fi

if [ -f "docker-compose.prod.yml" ] && [ -f "./deployment/nginx/nexuscos.online.conf" ]; then
    echo -e "  ${GREEN}✅ Deployment: CONFIGURED${NC}"
else
    echo -e "  ${YELLOW}⚠️  Deployment: INCOMPLETE${NC}"
fi

echo ""
echo -e "${PURPLE}🚀 Nexus COS Extended Health Check Complete!${NC}"
echo ""

# Create status report
cat > HEALTH_REPORT.txt << EOF
Nexus COS Extended Health Check Report
=====================================
Generated: $(date)

Core Services:
- Node.js Backend: $(curl -s "http://localhost:3000/health" >/dev/null && echo "HEALTHY" || echo "UNHEALTHY")
- Python Backend: $(curl -s "http://localhost:3001/health" >/dev/null && echo "HEALTHY" || echo "UNHEALTHY")

Extended Modules:
- V-Suite: $(curl -s "http://localhost:3010/health" >/dev/null && echo "HEALTHY" || echo "UNHEALTHY")
- Creator Hub: $(curl -s "http://localhost:3020/health" >/dev/null && echo "HEALTHY" || echo "UNHEALTHY")  
- PuaboVerse: $(curl -s "http://localhost:3030/health" >/dev/null && echo "HEALTHY" || echo "UNHEALTHY")

Applications:
- Frontend Build: $([ -f "./frontend/dist/index.html" ] && echo "AVAILABLE" || echo "MISSING")
- Android APK: $([ -f "./mobile/builds/android/app.apk" ] && echo "AVAILABLE" || echo "MISSING")
- iOS IPA: $([ -f "./mobile/builds/ios/app.ipa" ] && echo "AVAILABLE" || echo "MISSING")

Infrastructure:
- Docker Compose: $([ -f "docker-compose.prod.yml" ] && echo "CONFIGURED" || echo "MISSING")
- Nginx Config: $([ -f "./deployment/nginx/nexuscos.online.conf" ] && echo "CONFIGURED" || echo "MISSING")
- Monitoring: $([ -f "./monitoring/prometheus.yml" ] && echo "CONFIGURED" || echo "MISSING")
EOF

print_info "Health report saved to: HEALTH_REPORT.txt"