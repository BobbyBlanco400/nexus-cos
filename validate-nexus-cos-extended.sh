#!/bin/bash

# Nexus COS Extended - Service Validation Script
# Validates all service endpoints as specified in the deployment requirements

set -e

# Configuration
DOMAIN="nexuscos.online"
BASE_URL="http://localhost"  # Change to https://$DOMAIN for production
TIMEOUT=30

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✓ $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠ WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ✗ ERROR: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] ℹ INFO: $1${NC}"
}

# Function to check HTTP endpoint
check_endpoint() {
    local endpoint="$1"
    local expected_status="${2:-200}"
    local description="$3"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    info "Checking $description: $endpoint"
    
    local response
    local status_code
    
    response=$(curl -s -w "%{http_code}" --connect-timeout $TIMEOUT --max-time $TIMEOUT "$endpoint" 2>/dev/null || echo "000")
    status_code="${response: -3}"
    
    if [[ "$status_code" == "$expected_status" ]]; then
        log "$description - OK (Status: $status_code)"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        error "$description - FAILED (Status: $status_code, Expected: $expected_status)"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# Function to check WebSocket endpoint
check_websocket() {
    local endpoint="$1"
    local description="$2"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    info "Checking WebSocket $description: $endpoint"
    
    # Simple WebSocket check using curl
    if curl -s --connect-timeout $TIMEOUT --max-time $TIMEOUT \
        -H "Connection: Upgrade" \
        -H "Upgrade: websocket" \
        -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
        -H "Sec-WebSocket-Version: 13" \
        "$endpoint" >/dev/null 2>&1; then
        log "$description - WebSocket OK"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        error "$description - WebSocket FAILED"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# Function to check Docker service
check_docker_service() {
    local service_name="$1"
    local description="$2"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    info "Checking Docker service: $service_name"
    
    if docker-compose -f docker-compose.trae-solo-extended.yml ps "$service_name" | grep -q "Up"; then
        log "$description - Docker service running"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        error "$description - Docker service not running"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# Main validation function
main() {
    echo "=================================================="
    echo "🚀 Nexus COS Extended - Service Validation"
    echo "=================================================="
    echo ""
    
    info "Starting validation of all service endpoints..."
    echo ""
    
    # Check Docker services first
    echo "📦 Docker Services Health Check"
    echo "--------------------------------"
    check_docker_service "postgres" "PostgreSQL Database"
    check_docker_service "redis" "Redis Cache"
    check_docker_service "nginx" "Nginx Reverse Proxy"
    check_docker_service "ott-frontend" "OTT Frontend"
    check_docker_service "puaboverse" "PUABOverse"
    check_docker_service "creator-hub" "Creator Hub"
    check_docker_service "v-hollywood-studio" "V-Hollywood Studio"
    check_docker_service "v-screen" "V-Screen"
    check_docker_service "v-stage" "V-Stage"
    check_docker_service "v-caster-pro" "V-Caster Pro"
    check_docker_service "v-prompter-pro" "V-Prompter Pro"
    check_docker_service "boom-boom-room-live" "Boom Boom Room Live"
    check_docker_service "nexus-cos-studio-ai" "Nexus COS Studio AI"
    check_docker_service "kei-ai-orchestrator" "Kei AI Orchestrator"
    echo ""
    
    # Final checks as specified in requirements
    echo "🎯 Final Endpoint Validation"
    echo "----------------------------"
    
    # 1. Validate OTT Frontend routes → /
    check_endpoint "$BASE_URL/" "200" "OTT Frontend Landing Page"
    check_endpoint "$BASE_URL/health" "200" "OTT Frontend Health Check"
    
    # 2. Validate V-Hollywood Studio Engine API → /v-suite/hollywood
    check_endpoint "$BASE_URL/v-suite/hollywood/health" "200" "V-Hollywood Studio Engine API"
    check_endpoint "$BASE_URL/v-suite/hollywood/api/projects" "200" "V-Hollywood Studio Projects API"
    
    # 3. Validate Boom Boom Room Live → /live/boomroom
    check_endpoint "$BASE_URL/live/boomroom/health" "200" "Boom Boom Room Live"
    check_websocket "$BASE_URL/live/boomroom/socket.io/" "Boom Boom Room WebSocket"
    
    # 4. Validate Creator-Hub workspace → /hub
    check_endpoint "$BASE_URL/hub/health" "200" "Creator Hub Workspace"
    check_endpoint "$BASE_URL/hub/api/projects" "200" "Creator Hub Projects API"
    
    # 5. Validate Studio AI → /studio
    check_endpoint "$BASE_URL/studio/health" "200" "Nexus COS Studio AI"
    check_endpoint "$BASE_URL/studio/api/workspaces" "200" "Studio AI Workspaces API"
    
    # Additional V-Suite validations
    echo ""
    echo "🎬 V-Suite Extended Validation"
    echo "------------------------------"
    check_endpoint "$BASE_URL/v-suite/screen/health" "200" "V-Screen Virtual Backdrops"
    check_endpoint "$BASE_URL/v-suite/stage/health" "200" "V-Stage Virtual Stage Builder"
    check_endpoint "$BASE_URL/v-suite/caster/health" "200" "V-Caster Pro OTT Broadcast"
    check_endpoint "$BASE_URL/v-suite/prompter/health" "200" "V-Prompter Pro AI Teleprompter"
    
    # PUABOverse validation
    echo ""
    echo "🌐 PUABOverse Validation"
    echo "-----------------------"
    check_endpoint "$BASE_URL/puaboverse/health" "200" "PUABOverse User Identity"
    check_endpoint "$BASE_URL/puaboverse/api/profiles" "200" "PUABOverse Multiworld Profiles"
    check_endpoint "$BASE_URL/puaboverse/api/economy" "200" "PUABOverse Virtual Economy"
    
    # Kei AI Integration validation
    echo ""
    echo "🤖 Kei AI Integration Validation"
    echo "--------------------------------"
    check_endpoint "$BASE_URL/api/kei-ai/health" "200" "Kei AI Orchestrator"
    check_endpoint "$BASE_URL/api/kei-ai/status" "200" "Kei AI Status API"
    
    # Infrastructure validation
    echo ""
    echo "🏗️ Infrastructure Validation"
    echo "----------------------------"
    check_endpoint "$BASE_URL/nginx-status" "404" "Nginx Reverse Proxy (404 expected)"
    
    # Generate validation report
    echo ""
    echo "=================================================="
    echo "📊 VALIDATION REPORT"
    echo "=================================================="
    echo "Total Checks: $TOTAL_CHECKS"
    echo "Passed: $PASSED_CHECKS"
    echo "Failed: $FAILED_CHECKS"
    
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        log "🎉 ALL VALIDATIONS PASSED! Nexus COS Extended is ready for production."
        echo ""
        echo "✅ Service Status Summary:"
        echo "   • OTT Frontend: ✓ Running on /"
        echo "   • V-Hollywood Studio: ✓ Running on /v-suite/hollywood"
        echo "   • Boom Boom Room Live: ✓ Running on /live/boomroom"
        echo "   • Creator Hub: ✓ Running on /hub"
        echo "   • Studio AI: ✓ Running on /studio"
        echo "   • V-Suite (All 5 engines): ✓ Unified and operational"
        echo "   • PUABOverse: ✓ User identity and virtual economy active"
        echo "   • Kei AI Pipeline: ✓ Orchestration layer functional"
        echo ""
        echo "🚀 Nexus COS Extended deployment is SUCCESSFUL!"
        exit 0
    else
        error "❌ $FAILED_CHECKS validation(s) failed. Please check the services and try again."
        echo ""
        echo "🔧 Troubleshooting Tips:"
        echo "   1. Check Docker service logs: docker-compose logs [service-name]"
        echo "   2. Verify environment variables are set correctly"
        echo "   3. Ensure all required ports are available"
        echo "   4. Check Nginx configuration for routing issues"
        echo "   5. Verify Kei AI key is valid and accessible"
        exit 1
    fi
}

# Check if Docker Compose file exists
if [[ ! -f "docker-compose.trae-solo-extended.yml" ]]; then
    error "Docker Compose file not found. Please run this script from the project root directory."
    exit 1
fi

# Run main validation
main "$@"