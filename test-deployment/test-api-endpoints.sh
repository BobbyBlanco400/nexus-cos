#!/bin/bash

# === Nexus COS API Endpoint Testing Script ===
# This script performs comprehensive health checks and API endpoint testing
# for all Nexus COS backend services.

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

# Configuration
CONFIG_FILE="nexus-cos-services.yml"
TIMEOUT=5  # Seconds to wait for each request
RETRY_COUNT=3
RETRY_DELAY=2

# Function to log messages
log() {
    echo -e "${2:-$NC}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Function to make HTTP request with retry
make_request() {
    local url=$1
    local method=${2:-GET}
    local data=${3:-""}
    local success=false
    local response=""
    local status_code=""
    
    for ((i=1; i<=RETRY_COUNT; i++)); do
        if [ -n "$data" ]; then
            response=$(curl -s -X "$method" -H "Content-Type: application/json" -d "$data" -w "%{http_code}" "$url" -m "$TIMEOUT" 2>&1)
        else
            response=$(curl -s -X "$method" -w "%{http_code}" "$url" -m "$TIMEOUT" 2>&1)
        fi
        
        status_code=${response: -3}
        response_body=${response:0:${#response}-3}
        
        if [[ "$status_code" =~ ^2[0-9][0-9]$ ]]; then
            success=true
            break
        else
            log "Attempt $i failed for $url (Status: $status_code)" "$YELLOW"
            if [ $i -lt $RETRY_COUNT ]; then
                sleep "$RETRY_DELAY"
            fi
        fi
    done
    
    if [ "$success" = true ]; then
        echo "SUCCESS:$status_code:$response_body"
    else
        echo "FAILED:$status_code:$response_body"
    fi
}

# Function to test a specific endpoint
test_endpoint() {
    local service=$1
    local endpoint=$2
    local method=${3:-GET}
    local data=${4:-""}
    local expected_status=${5:-200}
    
    log "Testing $method $endpoint for $service..." "$YELLOW"
    
    local result
    result=$(make_request "$endpoint" "$method" "$data")
    local status=$(echo "$result" | cut -d':' -f1)
    local http_status=$(echo "$result" | cut -d':' -f2)
    local response=$(echo "$result" | cut -d':' -f3-)
    
    if [ "$status" = "SUCCESS" ] && [ "$http_status" -eq "$expected_status" ]; then
        log "✅ $service $method $endpoint - Success (HTTP $http_status)" "$GREEN"
        return 0
    else
        log "❌ $service $method $endpoint - Failed (HTTP $http_status)" "$RED"
        log "Response: $response" "$RED"
        return 1
    fi
}

# Function to parse YAML configuration
parse_yaml() {
    local yaml_file=$1
    python3 -c '
import yaml
import json
import sys

with open("'"$yaml_file"'", "r") as f:
    try:
        data = yaml.safe_load(f)
        print(json.dumps(data))
    except Exception as e:
        print(f"Error parsing YAML: {str(e)}", file=sys.stderr)
        sys.exit(1)
    '
}

# Function to test all service health endpoints
test_service_health() {
    log "Testing service health endpoints..." "$YELLOW"
    
    local config_json
    config_json=$(parse_yaml "$CONFIG_FILE")
    
    local failed_services=()
    
    # Test each service's health endpoint
    echo "$config_json" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
services = data.get("services", {})

for service_name, config in services.items():
    port = config.get("port")
    health_endpoint = config.get("health_endpoint", "/health")
    print(f"{service_name}|http://localhost:{port}{health_endpoint}")
' | while IFS='|' read -r service_name endpoint; do
        if ! test_endpoint "$service_name" "$endpoint"; then
            failed_services+=("$service_name")
        fi
    done
    
    # Report results
    if [ ${#failed_services[@]} -eq 0 ]; then
        log "All service health checks passed!" "$GREEN"
        return 0
    else
        log "The following services failed health checks: ${failed_services[*]}" "$RED"
        return 1
    fi
}

# Function to test common API endpoints
test_api_endpoints() {
    log "Testing common API endpoints..." "$YELLOW"
    
    local base_url="http://localhost"
    local failed_tests=0
    
    # Test nexus-backend endpoints
    test_endpoint "nexus-backend" "$base_url:3001/api/status" || ((failed_tests++))
    test_endpoint "nexus-backend" "$base_url:3001/api/version" || ((failed_tests++))
    
    # Test nexus-cos-api endpoints
    test_endpoint "nexus-cos-api" "$base_url:3002/api/health" || ((failed_tests++))
    test_endpoint "nexus-cos-api" "$base_url:3002/api/status" || ((failed_tests++))
    
    # Test boomroom-backend endpoints
    test_endpoint "boomroom-backend" "$base_url:3003/api/health" || ((failed_tests++))
    test_endpoint "boomroom-backend" "$base_url:3003/api/status" || ((failed_tests++))
    
    # Test creator-hub endpoints
    test_endpoint "creator-hub" "$base_url:3020/api/health" || ((failed_tests++))
    test_endpoint "creator-hub" "$base_url:3020/api/status" || ((failed_tests++))
    
    # Test puaboverse endpoints
    test_endpoint "puaboverse" "$base_url:3030/api/health" || ((failed_tests++))
    test_endpoint "puaboverse" "$base_url:3030/api/status" || ((failed_tests++))
    
    # Report results
    if [ $failed_tests -eq 0 ]; then
        log "All API endpoint tests passed!" "$GREEN"
        return 0
    else
        log "$failed_tests API endpoint tests failed" "$RED"
        return 1
    fi
}

# Function to test PM2 process status
test_pm2_status() {
    log "Checking PM2 process status..." "$YELLOW"
    
    local pm2_status
    pm2_status=$(pm2 list --no-color)
    
    if echo "$pm2_status" | grep -q "errored\|stopped\|exit"; then
        log "Some PM2 processes are not running correctly:" "$RED"
        echo "$pm2_status"
        return 1
    else
        log "All PM2 processes are running correctly" "$GREEN"
        return 0
    fi
}

# Main function
main() {
    log "Starting Nexus COS API endpoint tests..." "$YELLOW"
    
    # Check if configuration file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        log "Configuration file $CONFIG_FILE not found" "$RED"
        exit 1
    fi
    
    # Run all tests
    local failed=0
    
    test_pm2_status || ((failed++))
    test_service_health || ((failed++))
    test_api_endpoints || ((failed++))
    
    # Report final results
    if [ $failed -eq 0 ]; then
        log "🎉 All tests passed successfully!" "$GREEN"
        exit 0
    else
        log "❌ $failed test categories failed" "$RED"
        exit 1
    fi
}

# Execute main function
main