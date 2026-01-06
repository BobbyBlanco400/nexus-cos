#!/bin/bash

# ==============================================================================
# Nexus COS Beta Launch Endpoint Validation Script
# ==============================================================================
# Purpose: Validate all health check endpoints per PF v2025.10.01
# Author: Code Agent + TRAE Solo
# Version: v1.0.0
# ==============================================================================

set -euo pipefail

# Configuration
readonly DOMAIN="${DOMAIN:-n3xuscos.online}"
readonly BETA_DOMAIN="${BETA_DOMAIN:-beta.n3xuscos.online}"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# ==============================================================================
# Utility Functions
# ==============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   Nexus COS Beta Launch - Endpoint Validation                 ║${NC}"
    echo -e "${CYAN}║   PF v2025.10.01 Compliance Check                             ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}▶${NC} Testing: $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS_PASSED++))
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((CHECKS_FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((CHECKS_WARNING++))
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# ==============================================================================
# Endpoint Testing Functions
# ==============================================================================

test_endpoint() {
    local url="$1"
    local expected_status="${2:-200}"
    local endpoint_name="$3"
    
    print_step "${endpoint_name}"
    
    # Use curl to test the endpoint
    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "${url}" 2>/dev/null || echo "000")
    
    if [[ "${status_code}" == "${expected_status}" ]]; then
        print_success "${endpoint_name} → ${status_code} (Expected: ${expected_status})"
        return 0
    elif [[ "${status_code}" == "000" ]]; then
        print_error "${endpoint_name} → Connection failed (service may be down)"
        return 1
    elif [[ "${status_code}" == "502" ]] || [[ "${status_code}" == "503" ]]; then
        print_warning "${endpoint_name} → ${status_code} (Backend service unavailable)"
        return 1
    elif [[ "${status_code}" == "404" ]]; then
        print_error "${endpoint_name} → ${status_code} (Route not configured in Nginx)"
        return 1
    else
        print_warning "${endpoint_name} → ${status_code} (Expected: ${expected_status})"
        return 1
    fi
}

# ==============================================================================
# Test Suites
# ==============================================================================

test_core_endpoints() {
    print_section "Core Platform Endpoints"
    
    test_endpoint "https://${DOMAIN}/api/health" "200" "Core API Health"
    test_endpoint "https://${DOMAIN}/health/gateway" "200" "Gateway Health (Canonical)"
    test_endpoint "https://${DOMAIN}/health" "200" "Legacy Health Endpoint"
}

test_puabo_nexus_fleet() {
    print_section "PUABO NEXUS Fleet Services (PF v2025.10.01)"
    
    test_endpoint "https://${DOMAIN}/puabo-nexus/dispatch/health" "200" "AI Dispatch Service"
    test_endpoint "https://${DOMAIN}/puabo-nexus/driver/health" "200" "Driver Backend Service"
    test_endpoint "https://${DOMAIN}/puabo-nexus/fleet/health" "200" "Fleet Manager Service"
    test_endpoint "https://${DOMAIN}/puabo-nexus/routes/health" "200" "Route Optimizer Service"
}

test_vsuite_services() {
    print_section "V-Suite Services"
    
    test_endpoint "https://${DOMAIN}/v-suite/prompter/health" "200" "V-Prompter Pro"
    test_endpoint "https://${DOMAIN}/v-suite/screen/health" "200" "VScreen Hollywood"
}

test_beta_domain() {
    print_section "Beta Domain Endpoints"
    
    test_endpoint "https://${BETA_DOMAIN}/" "200" "Beta Landing Page"
    test_endpoint "https://${BETA_DOMAIN}/api/health" "200" "Beta API Health"
    test_endpoint "https://${BETA_DOMAIN}/health/gateway" "200" "Beta Gateway Health"
    test_endpoint "https://${BETA_DOMAIN}/v-suite/prompter/health" "200" "Beta V-Prompter"
}

test_nginx_configuration() {
    print_section "Nginx Configuration Validation"
    
    print_step "Checking Nginx configuration syntax"
    
    if command -v nginx &>/dev/null; then
        if sudo nginx -t 2>&1 | grep -q "successful"; then
            print_success "Nginx configuration is valid"
        else
            print_error "Nginx configuration has errors"
            sudo nginx -t 2>&1 | tail -5
        fi
    else
        print_warning "Nginx not found in PATH (cannot validate config)"
    fi
    
    print_step "Checking for duplicate server_name warnings"
    local nginx_test_output
    nginx_test_output=$(sudo nginx -t 2>&1 || true)
    
    if echo "${nginx_test_output}" | grep -q "conflicting server name"; then
        print_warning "Found conflicting server_name directive"
        echo "${nginx_test_output}" | grep "conflicting" | head -5
    else
        print_success "No conflicting server_name directives"
    fi
}

# ==============================================================================
# Report Generation
# ==============================================================================

generate_report() {
    print_section "Validation Summary"
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S %Z')
    
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Test Results:${NC}"
    echo -e "  ${GREEN}✓ Passed:${NC}   ${CHECKS_PASSED}"
    echo -e "  ${RED}✗ Failed:${NC}   ${CHECKS_FAILED}"
    echo -e "  ${YELLOW}⚠ Warnings:${NC} ${CHECKS_WARNING}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    local total_checks=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNING))
    local pass_percentage=0
    
    if [[ ${total_checks} -gt 0 ]]; then
        pass_percentage=$((CHECKS_PASSED * 100 / total_checks))
    fi
    
    echo -e "${CYAN}Overall Health:${NC} ${pass_percentage}% (${CHECKS_PASSED}/${total_checks} checks passed)"
    echo ""
    
    # Determine readiness status
    if [[ ${CHECKS_FAILED} -eq 0 ]] && [[ ${CHECKS_WARNING} -le 2 ]]; then
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                                                                ║${NC}"
        echo -e "${GREEN}║              ✅  BETA LAUNCH READY  ✅                         ║${NC}"
        echo -e "${GREEN}║                                                                ║${NC}"
        echo -e "${GREEN}║     All critical endpoints are responding correctly            ║${NC}"
        echo -e "${GREEN}║                                                                ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
        return 0
    elif [[ ${CHECKS_FAILED} -le 3 ]]; then
        echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║                                                                ║${NC}"
        echo -e "${YELLOW}║              ⚠️  BETA LAUNCH WITH CAUTION  ⚠️                 ║${NC}"
        echo -e "${YELLOW}║                                                                ║${NC}"
        echo -e "${YELLOW}║     Some services are unavailable or misconfigured            ║${NC}"
        echo -e "${YELLOW}║     Review the failed checks above                             ║${NC}"
        echo -e "${YELLOW}║                                                                ║${NC}"
        echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
        return 1
    else
        echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║                                                                ║${NC}"
        echo -e "${RED}║              ❌  NOT READY FOR BETA LAUNCH  ❌                ║${NC}"
        echo -e "${RED}║                                                                ║${NC}"
        echo -e "${RED}║     Critical issues found - fix before proceeding              ║${NC}"
        echo -e "${RED}║                                                                ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
        return 1
    fi
}

print_next_steps() {
    echo ""
    print_section "Next Steps"
    
    if [[ ${CHECKS_FAILED} -gt 0 ]]; then
        echo -e "${YELLOW}To fix failed checks:${NC}"
        echo ""
        echo "1. For 404 errors (routes not configured):"
        echo "   - Verify Nginx configuration includes the routes"
        echo "   - Run: sudo cp deployment/nginx/*.conf /etc/nginx/sites-available/"
        echo "   - Run: sudo nginx -t && sudo systemctl reload nginx"
        echo ""
        echo "2. For 502/503 errors (backend unavailable):"
        echo "   - Start the backend services on the required ports"
        echo "   - Check: docker-compose ps or systemctl status <service>"
        echo "   - Review logs: docker-compose logs or journalctl -u <service>"
        echo ""
        echo "3. For connection errors:"
        echo "   - Check if SSL certificates are valid"
        echo "   - Verify DNS records point to correct IP"
        echo "   - Check firewall rules: sudo ufw status"
        echo ""
    fi
    
    echo -e "${CYAN}Recommended Actions:${NC}"
    echo "  • Monitor service logs for errors"
    echo "  • Set up uptime monitoring for critical endpoints"
    echo "  • Review PF v2025.10.01 documentation for service details"
    echo "  • Test with: curl -I https://${DOMAIN}/api/health"
    echo ""
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_header
    
    # Run test suites
    test_nginx_configuration
    test_core_endpoints
    test_puabo_nexus_fleet
    test_vsuite_services
    test_beta_domain
    
    # Generate report
    local exit_code=0
    generate_report || exit_code=$?
    
    # Print next steps if needed
    print_next_steps
    
    exit ${exit_code}
}

# Run main function
main "$@"
