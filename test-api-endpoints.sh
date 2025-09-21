#!/bin/bash
# Nexus COS API Health Check and Test Script
# Tests all API endpoints to verify JSON responses and service health

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}       Nexus COS API Health Check Script${NC}"
    echo -e "${BLUE}===============================================${NC}"
}

# Configuration
CONFIG_FILE="nexus-cos-services.yml"
TEST_RESULTS=()

# Test a single service endpoint
test_service_endpoint() {
    local service_name=$1
    local port=$2
    local endpoint=${3:-"/health"}
    local expected_pattern=${4:-'"status".*"ok"'}
    
    print_info "Testing $service_name at http://localhost:$port$endpoint"
    
    # Test direct service endpoint
    local response=$(curl -s -w "HTTP_STATUS:%{http_code}" "http://localhost:$port$endpoint" 2>/dev/null || echo "CURL_ERROR")
    
    if [[ "$response" == "CURL_ERROR" ]]; then
        print_error "$service_name - Connection failed (service may not be running)"
        TEST_RESULTS+=("❌ $service_name (port $port) - CONNECTION FAILED")
        return 1
    fi
    
    local http_code=$(echo "$response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
    local body=$(echo "$response" | sed 's/HTTP_STATUS:[0-9]*$//')
    
    if [[ "$http_code" == "200" ]]; then
        if echo "$body" | grep -q "$expected_pattern"; then
            print_success "$service_name - HEALTHY (JSON response valid)"
            TEST_RESULTS+=("✅ $service_name (port $port) - HEALTHY")
            
            # Also test via nginx proxy if available
            test_nginx_proxy "$service_name" "$endpoint" "$expected_pattern"
            return 0
        else
            print_warning "$service_name - RESPONDING but unexpected JSON format"
            print_info "Response: $body"
            TEST_RESULTS+=("⚠️  $service_name (port $port) - UNEXPECTED RESPONSE")
            return 1
        fi
    else
        print_error "$service_name - HTTP $http_code error"
        print_info "Response: $body"
        TEST_RESULTS+=("❌ $service_name (port $port) - HTTP $http_code")
        return 1
    fi
}

# Test nginx proxy routing
test_nginx_proxy() {
    local service_name=$1
    local endpoint=$2
    local expected_pattern=$3
    
    # Test via nginx proxy if nginx is running
    if systemctl is-active --quiet nginx 2>/dev/null; then
        local proxy_response=$(curl -s -w "HTTP_STATUS:%{http_code}" "http://localhost/api/$service_name$endpoint" 2>/dev/null || echo "PROXY_ERROR")
        
        if [[ "$proxy_response" != "PROXY_ERROR" ]]; then
            local proxy_http_code=$(echo "$proxy_response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
            local proxy_body=$(echo "$proxy_response" | sed 's/HTTP_STATUS:[0-9]*$//')
            
            if [[ "$proxy_http_code" == "200" ]] && echo "$proxy_body" | grep -q "$expected_pattern"; then
                print_success "  └─ Nginx proxy for $service_name - WORKING"
            else
                print_warning "  └─ Nginx proxy for $service_name - NOT WORKING (HTTP $proxy_http_code)"
            fi
        fi
    fi
}

# Test PM2 process status
test_pm2_status() {
    print_info "Checking PM2 process status..."
    
    if command -v pm2 &> /dev/null; then
        local pm2_output=$(pm2 jlist 2>/dev/null || echo "[]")
        local process_count=$(echo "$pm2_output" | jq length 2>/dev/null || echo "0")
        
        if [[ "$process_count" -gt 0 ]]; then
            print_success "PM2 is managing $process_count processes"
            
            # Show detailed PM2 status
            echo ""
            print_info "PM2 Process Details:"
            pm2 list --no-color | head -20
        else
            print_warning "No PM2 processes found"
        fi
    else
        print_warning "PM2 not installed or not in PATH"
    fi
}

# Test nginx configuration
test_nginx_config() {
    print_info "Checking Nginx configuration..."
    
    if command -v nginx &> /dev/null; then
        if nginx -t 2>/dev/null; then
            print_success "Nginx configuration is valid"
            
            if systemctl is-active --quiet nginx; then
                print_success "Nginx service is running"
            else
                print_warning "Nginx service is not running"
            fi
        else
            print_error "Nginx configuration has errors"
        fi
    else
        print_warning "Nginx not installed"
    fi
}

# Run comprehensive API tests
run_comprehensive_tests() {
    print_info "Running comprehensive API tests..."
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Configuration file $CONFIG_FILE not found!"
        exit 1
    fi
    
    # Check if yq is available
    if ! command -v yq &> /dev/null; then
        print_error "yq is required for parsing YAML configuration"
        exit 1
    fi
    
    local service_count=$(yq eval '.services | length' "$CONFIG_FILE")
    
    echo ""
    print_info "Testing $service_count services from configuration..."
    echo ""
    
    for ((i=0; i<service_count; i++)); do
        local name=$(yq eval ".services[$i].name" "$CONFIG_FILE")
        local port=$(yq eval ".services[$i].port" "$CONFIG_FILE")
        
        test_service_endpoint "$name" "$port" "/health" '"status".*"ok"'
        echo ""
    done
}

# Display test summary
display_summary() {
    echo ""
    print_info "🔍 Test Summary Report:"
    echo "=========================="
    
    for result in "${TEST_RESULTS[@]}"; do
        echo "  $result"
    done
    
    echo ""
    
    # Count results
    local total_tests=${#TEST_RESULTS[@]}
    local healthy_count=$(printf '%s\n' "${TEST_RESULTS[@]}" | grep -c "✅" || echo "0")
    local warning_count=$(printf '%s\n' "${TEST_RESULTS[@]}" | grep -c "⚠️" || echo "0")
    local error_count=$(printf '%s\n' "${TEST_RESULTS[@]}" | grep -c "❌" || echo "0")
    
    echo "📊 Results: $healthy_count healthy, $warning_count warnings, $error_count errors (total: $total_tests)"
    
    if [[ "$error_count" -eq 0 && "$warning_count" -eq 0 ]]; then
        print_success "🎉 All services are healthy and responding correctly!"
        return 0
    elif [[ "$error_count" -eq 0 ]]; then
        print_warning "⚠️  Some services have warnings but are operational"
        return 1
    else
        print_error "❌ Some services have critical errors"
        return 2
    fi
}

# Main execution
main() {
    print_header
    echo ""
    
    test_pm2_status
    echo ""
    
    test_nginx_config
    echo ""
    
    run_comprehensive_tests
    
    display_summary
    
    echo ""
    print_info "💡 Additional test commands:"
    echo "  curl http://localhost:3001/health          # Test nexus-backend directly"
    echo "  curl http://localhost/api/nexus-backend/health  # Test via nginx proxy"
    echo "  pm2 logs --lines 50                        # View recent PM2 logs"
    echo "  systemctl status nginx                     # Check nginx status"
}

# Handle command line arguments
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Nexus COS API Health Check Script"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --help, -h     Show this help message"
    echo "  --quick, -q    Run quick health checks only"
    echo "  --verbose, -v  Show detailed output"
    echo ""
    echo "This script tests all API endpoints defined in nexus-cos-services.yml"
    echo "and verifies they return proper JSON responses."
    exit 0
fi

# Run main function
main "$@"