#!/bin/bash
# Nexus COS PF v1.2 Health Check Script
# Comprehensive health monitoring for services and modules with dependency validation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE="nexus-cos-services-v1.2.yml"
HEALTH_RESULTS=()
DEPENDENCY_RESULTS=()

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    Nexus COS PF v1.2 Health Check                           ║${NC}"
    echo -e "${PURPLE}║                     With Dependency Validation                               ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}▼ $1${NC}"
    echo "═══════════════════════════════════════════════════════════════════"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Check individual service health
check_service_health() {
    local service_name=$1
    local port=$2
    local endpoint=${3:-"/health"}
    
    local url="http://localhost:${port}${endpoint}"
    
    if curl -sf "$url" >/dev/null 2>&1; then
        local response=$(curl -s "$url")
        print_success "$service_name (Port $port) - HEALTHY"
        HEALTH_RESULTS+=("✅ $service_name:$port - HEALTHY")
        
        # Check if response is valid JSON with status
        if echo "$response" | jq -e '.status' >/dev/null 2>&1; then
            local status=$(echo "$response" | jq -r '.status')
            if [[ "$status" == "ok" ]]; then
                return 0
            fi
        fi
    else
        print_error "$service_name (Port $port) - UNHEALTHY"
        HEALTH_RESULTS+=("❌ $service_name:$port - UNHEALTHY")
        return 1
    fi
}

# Check port availability
check_port() {
    local port=$1
    local service_name=$2
    
    if netstat -ln | grep -q ":$port "; then
        print_success "Port $port ($service_name) - LISTENING"
        return 0
    else
        print_error "Port $port ($service_name) - NOT LISTENING"
        return 1
    fi
}

# Check service dependencies
check_service_dependencies() {
    local service_name=$1
    local service_type=$2
    
    # Get dependencies from config
    local deps=$(yq eval ".${service_type}[] | select(.name == \"$service_name\") | .dependencies[]?" "$CONFIG_FILE" 2>/dev/null || echo "")
    
    if [[ -z "$deps" ]]; then
        print_info "$service_name - No dependencies"
        return 0
    fi
    
    local all_deps_healthy=true
    
    while IFS= read -r dep; do
        if [[ -n "$dep" ]]; then
            # Find the port for this dependency
            local dep_port=$(yq eval ".core_services[]?, .business_modules[]? | select(.name == \"$dep\") | .port" "$CONFIG_FILE" 2>/dev/null)
            
            if [[ -n "$dep_port" ]]; then
                if check_service_health "$dep" "$dep_port" >/dev/null 2>&1; then
                    print_success "$service_name → $dep (Port $dep_port) - DEPENDENCY OK"
                else
                    print_error "$service_name → $dep (Port $dep_port) - DEPENDENCY FAILED"
                    all_deps_healthy=false
                fi
            else
                print_warning "$service_name → $dep - DEPENDENCY PORT NOT FOUND"
                all_deps_healthy=false
            fi
        fi
    done <<< "$deps"
    
    if $all_deps_healthy; then
        DEPENDENCY_RESULTS+=("✅ $service_name - ALL DEPENDENCIES OK")
    else
        DEPENDENCY_RESULTS+=("❌ $service_name - DEPENDENCY ISSUES")
    fi
}

# Check core services
check_core_services() {
    print_section "1. Core Platform Services"
    
    local services=(
        "auth-service:3100"
        "billing-service:3110"
        "user-profile-service:3120"
        "media-encoding-service:3130"
        "streaming-service:3140"
        "recommendation-engine:3150"
        "chat-service:3160"
        "notification-service:3170"
        "analytics-service:3180"
    )
    
    for service_port in "${services[@]}"; do
        IFS=':' read -r service port <<< "$service_port"
        check_service_health "$service" "$port"
        check_port "$port" "$service"
        echo ""
    done
}

# Check business modules
check_business_modules() {
    print_section "2. Business & Domain Modules"
    
    local modules=(
        "core-os:3200"
        "puabo-dsp:3210"
        "puabo-blac:3220"
        "v-suite:3230"
        "media-community:3250"
        "business-tools:3280"
        "integrations:3290"
    )
    
    for module_port in "${modules[@]}"; do
        IFS=':' read -r module port <<< "$module_port"
        check_service_health "$module" "$port"
        check_port "$port" "$module"
        echo ""
    done
}

# Check microservices
check_microservices() {
    print_section "3. Microservices Health"
    
    # Auth service microservices
    check_service_health "session-mgr" "3101"
    check_service_health "token-mgr" "3102"
    
    # Billing service microservices
    check_service_health "invoice-gen" "3111"
    check_service_health "ledger-mgr" "3112"
    check_service_health "payout-engine" "3113"
    
    echo ""
}

# Check dependency chain
check_dependency_chain() {
    print_section "4. Service Dependency Validation"
    
    # Check core services dependencies
    local core_services=("auth-service" "billing-service" "user-profile-service" "media-encoding-service" "streaming-service" "recommendation-engine" "chat-service" "notification-service" "analytics-service")
    
    for service in "${core_services[@]}"; do
        check_service_dependencies "$service" "core_services"
    done
    
    echo ""
    
    # Check business modules dependencies
    local modules=("core-os" "puabo-dsp" "puabo-blac" "v-suite" "media-community" "business-tools" "integrations")
    
    for module in "${modules[@]}"; do
        check_service_dependencies "$module" "business_modules"
    done
}

# Check PM2 processes
check_pm2_processes() {
    print_section "5. PM2 Process Status"
    
    if command -v pm2 &> /dev/null; then
        local pm2_status=$(pm2 jlist 2>/dev/null || echo "[]")
        
        if [[ "$pm2_status" == "[]" ]]; then
            print_warning "No PM2 processes running"
        else
            print_info "PM2 Process Summary:"
            pm2 list --no-color | grep -E "(name|online|stopped|errored)" || print_warning "No PM2 processes found"
        fi
    else
        print_warning "PM2 not installed or not available"
    fi
    
    echo ""
}

# Check system resources
check_system_resources() {
    print_section "6. System Resources"
    
    # Memory usage
    local mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    if (( $(echo "$mem_usage > 80" | bc -l) )); then
        print_warning "Memory usage: ${mem_usage}% (HIGH)"
    else
        print_success "Memory usage: ${mem_usage}% (OK)"
    fi
    
    # CPU load
    local cpu_load=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)
    print_info "CPU load average: $cpu_load"
    
    # Disk usage
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [[ $disk_usage -gt 80 ]]; then
        print_warning "Disk usage: ${disk_usage}% (HIGH)"
    else
        print_success "Disk usage: ${disk_usage}% (OK)"
    fi
    
    echo ""
}

# Check nginx configuration
check_nginx() {
    print_section "7. Nginx Load Balancer"
    
    if command -v nginx &> /dev/null; then
        if nginx -t &>/dev/null; then
            print_success "Nginx configuration - VALID"
        else
            print_error "Nginx configuration - INVALID"
        fi
        
        if systemctl is-active nginx &>/dev/null; then
            print_success "Nginx service - RUNNING"
        else
            print_error "Nginx service - NOT RUNNING"
        fi
    else
        print_warning "Nginx not installed"
    fi
    
    echo ""
}

# Check API routing
check_api_routing() {
    print_section "8. API Route Validation"
    
    local routes=(
        "/api/auth:3100"
        "/api/billing:3110"
        "/api/profile:3120"
        "/api/encoding:3130"
        "/api/streaming:3140"
        "/api/recommend:3150"
        "/api/chat:3160"
        "/api/notify:3170"
        "/api/analytics:3180"
        "/api/core-os:3200"
        "/api/dsp:3210"
        "/api/blac:3220"
        "/api/v-suite:3230"
        "/api/community:3250"
        "/api/business:3280"
        "/api/integrations:3290"
    )
    
    for route_port in "${routes[@]}"; do
        IFS=':' read -r route port <<< "$route_port"
        local service_name=$(echo "$route" | sed 's|/api/||')
        
        # Test direct port access
        if curl -sf "http://localhost:${port}/health" >/dev/null 2>&1; then
            print_success "Direct access: $service_name (localhost:$port) - OK"
        else
            print_error "Direct access: $service_name (localhost:$port) - FAILED"
        fi
    done
    
    echo ""
}

# Generate health report
generate_health_report() {
    print_section "9. Health Check Summary"
    
    echo -e "${CYAN}Service Health Results:${NC}"
    for result in "${HEALTH_RESULTS[@]}"; do
        echo "  $result"
    done
    
    echo ""
    echo -e "${CYAN}Dependency Check Results:${NC}"
    for result in "${DEPENDENCY_RESULTS[@]}"; do
        echo "  $result"
    done
    
    echo ""
    
    # Count results
    local total_health=${#HEALTH_RESULTS[@]}
    local healthy_count=$(printf '%s\n' "${HEALTH_RESULTS[@]}" | grep -c "✅" || echo "0")
    local unhealthy_count=$(printf '%s\n' "${HEALTH_RESULTS[@]}" | grep -c "❌" || echo "0")
    
    local total_deps=${#DEPENDENCY_RESULTS[@]}
    local deps_ok=$(printf '%s\n' "${DEPENDENCY_RESULTS[@]}" | grep -c "✅" || echo "0")
    local deps_failed=$(printf '%s\n' "${DEPENDENCY_RESULTS[@]}" | grep -c "❌" || echo "0")
    
    echo -e "${CYAN}Overall Health Status:${NC}"
    echo "  📊 Services: $healthy_count healthy, $unhealthy_count unhealthy (Total: $total_health)"
    echo "  🔗 Dependencies: $deps_ok OK, $deps_failed failed (Total: $total_deps)"
    
    if [[ $unhealthy_count -eq 0 && $deps_failed -eq 0 ]]; then
        echo ""
        print_success "🎉 Nexus COS PF v1.2 is fully operational!"
    else
        echo ""
        print_warning "⚠️  Some issues detected. Check the details above."
    fi
}

# Main execution
main() {
    print_header
    
    # Check if config file exists
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Configuration file $CONFIG_FILE not found!"
        exit 1
    fi
    
    # Install jq if not available (for JSON parsing)
    if ! command -v jq &> /dev/null; then
        print_info "Installing jq for JSON parsing..."
        apt-get update && apt-get install -y jq >/dev/null 2>&1 || true
    fi
    
    check_core_services
    check_business_modules
    check_microservices
    check_dependency_chain
    check_pm2_processes
    check_system_resources
    check_nginx
    check_api_routing
    generate_health_report
    
    echo ""
    print_info "Health check complete! 🏥"
}

# Execute main function
main "$@"