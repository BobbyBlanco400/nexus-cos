#!/bin/bash

# ==============================================================================
# Nexus COS - V-Suite Streaming Routes Validation Script
# ==============================================================================
# Purpose: Validate all V-Suite streaming routes after deployment
# Usage: ./validate-streaming-routes.sh [domain]
# ==============================================================================

set -e

# Configuration
DOMAIN="${1:-n3xuscos.online}"
TIMEOUT=10

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  V-SUITE STREAMING ROUTES VALIDATION${NC}"
    echo -e "${CYAN}  Domain: $DOMAIN${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

print_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Test endpoint
test_endpoint() {
    local url=$1
    local name=$2
    local expect_code=${3:-200}
    
    print_info "Testing $name..."
    
    # Use curl to test the endpoint
    response=$(curl -s -o /dev/null -w "%{http_code}" -m $TIMEOUT "$url" 2>/dev/null || echo "000")
    
    if [[ "$response" == "$expect_code" ]] || [[ "$response" == "301" ]] || [[ "$response" == "302" ]]; then
        print_success "$name is accessible (HTTP $response)"
        return 0
    elif [[ "$response" == "000" ]]; then
        print_error "$name failed to respond (timeout or connection error)"
        print_info "  URL: $url"
        return 1
    else
        print_warning "$name returned unexpected status (HTTP $response)"
        print_info "  URL: $url"
        return 1
    fi
}

# Main validation
main() {
    print_header
    
    local passed=0
    local failed=0
    
    # Section 1: Local Service Health Checks
    print_section "1. LOCAL SERVICE HEALTH CHECKS"
    
    print_info "Checking if services are running locally..."
    
    # V-Screen Hollywood (port 8088)
    if curl -s -f -m 5 "http://localhost:8088/health" > /dev/null 2>&1; then
        print_success "V-Screen Hollywood service is running (localhost:8088)"
        ((passed++))
    else
        print_warning "V-Screen Hollywood not accessible on localhost:8088"
        print_info "  Service may not be running or bound to different interface"
        ((failed++))
    fi
    
    # Gateway API (port 4000)
    if curl -s -f -m 5 "http://localhost:4000/health" > /dev/null 2>&1; then
        print_success "Gateway API is running (localhost:4000)"
        ((passed++))
    else
        print_warning "Gateway API not accessible on localhost:4000"
        ((failed++))
    fi
    
    # AI SDK (port 3002)
    if curl -s -f -m 5 "http://localhost:3002/health" > /dev/null 2>&1; then
        print_success "AI SDK is running (localhost:3002)"
        ((passed++))
    else
        print_warning "AI SDK not accessible on localhost:3002"
        ((failed++))
    fi
    
    # Section 2: Production Domain Routes
    print_section "2. PRODUCTION V-SUITE ROUTES"
    
    print_info "Testing production streaming routes on $DOMAIN..."
    
    # Core routes
    if test_endpoint "https://$DOMAIN/v-suite/screen" "V-Screen (/v-suite/screen)"; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_endpoint "https://$DOMAIN/v-screen" "V-Screen Direct (/v-screen)"; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_endpoint "https://$DOMAIN/v-suite/hollywood" "V-Hollywood (/v-suite/hollywood)"; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_endpoint "https://$DOMAIN/v-suite/prompter" "V-Prompter Pro (/v-suite/prompter)"; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_endpoint "https://$DOMAIN/v-suite/caster" "V-Caster (/v-suite/caster)"; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_endpoint "https://$DOMAIN/v-suite/stage" "V-Stage (/v-suite/stage)"; then
        ((passed++))
    else
        ((failed++))
    fi
    
    # Section 3: Core Platform Routes
    print_section "3. CORE PLATFORM ROUTES"
    
    if test_endpoint "https://$DOMAIN/" "Frontend Root"; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_endpoint "https://$DOMAIN/admin" "Admin Panel"; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_endpoint "https://$DOMAIN/api" "API Gateway"; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_endpoint "https://$DOMAIN/health" "Health Endpoint"; then
        ((passed++))
    else
        ((failed++))
    fi
    
    # Section 4: Health Check Details
    print_section "4. DETAILED HEALTH CHECKS"
    
    print_info "Fetching health check responses..."
    
    # V-Screen Hollywood health
    echo ""
    echo -e "${CYAN}V-Screen Hollywood Health:${NC}"
    curl -s -m 5 "http://localhost:8088/health" 2>/dev/null | jq . 2>/dev/null || \
        curl -s -m 5 "http://localhost:8088/health" 2>/dev/null || \
        echo "  Service not responding"
    
    # Gateway health
    echo ""
    echo -e "${CYAN}Gateway API Health:${NC}"
    curl -s -m 5 "http://localhost:4000/health" 2>/dev/null | jq . 2>/dev/null || \
        curl -s -m 5 "http://localhost:4000/health" 2>/dev/null || \
        echo "  Service not responding"
    
    # Section 5: Docker Service Status
    print_section "5. DOCKER SERVICE STATUS"
    
    if command -v docker &> /dev/null; then
        print_info "Checking Docker container status..."
        echo ""
        
        # Check if docker-compose.pf.yml exists
        if [[ -f "docker-compose.pf.yml" ]]; then
            docker compose -f docker-compose.pf.yml ps 2>/dev/null || \
                print_warning "Could not retrieve Docker service status"
        elif [[ -f "/opt/nexus-cos/docker-compose.pf.yml" ]]; then
            docker compose -f /opt/nexus-cos/docker-compose.pf.yml ps 2>/dev/null || \
                print_warning "Could not retrieve Docker service status"
        else
            print_warning "docker-compose.pf.yml not found"
        fi
    else
        print_warning "Docker not installed or not in PATH"
    fi
    
    # Summary
    print_section "VALIDATION SUMMARY"
    
    echo -e "${GREEN}Passed:${NC} $passed"
    echo -e "${RED}Failed:${NC} $failed"
    echo ""
    
    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}✨ All streaming routes are operational! ✨${NC}"
        echo ""
        return 0
    else
        echo -e "${YELLOW}⚠ Some routes failed validation${NC}"
        echo ""
        print_info "Troubleshooting steps:"
        print_info "  1. Check if services are running: docker compose ps"
        print_info "  2. Review service logs: docker compose logs [service-name]"
        print_info "  3. Verify Nginx configuration: sudo nginx -t"
        print_info "  4. Check firewall rules: sudo ufw status"
        print_info "  5. Review Nginx logs: tail -f /var/log/nginx/error.log"
        echo ""
        return 1
    fi
}

# Run main function
main "$@"
