#!/bin/bash

# ==============================================================================
# Nexus COS - PF v2025.10.01 Health Check Script
# ==============================================================================
# Purpose: Automated health check for all PF v2025.10.01 services
# ==============================================================================

set -e

# Configuration
DOMAIN="${DOMAIN:-nexuscos.online}"
TIMEOUT=5

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
HEALTHY_COUNT=0
UNHEALTHY_COUNT=0
TOTAL_COUNT=0

# ==============================================================================
# Utility Functions
# ==============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║         NEXUS COS - PF v2025.10.01 HEALTH CHECK               ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Domain: ${DOMAIN}${NC}"
    echo -e "${BLUE}Timeout: ${TIMEOUT}s${NC}"
    echo ""
}

check_endpoint() {
    local name="$1"
    local url="$2"
    ((TOTAL_COUNT++))
    
    # Try HTTP first if HTTPS fails (for local testing)
    if curl -s -f -m "${TIMEOUT}" "${url}" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} ${name}"
        ((HEALTHY_COUNT++))
        return 0
    else
        echo -e "${RED}✗${NC} ${name} (${url})"
        ((UNHEALTHY_COUNT++))
        return 1
    fi
}

print_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# ==============================================================================
# Health Checks
# ==============================================================================

print_header

# Core Services
print_section "Core Platform Services"
check_endpoint "Core API Gateway" "https://${DOMAIN}/api/health"
check_endpoint "Gateway Health" "https://${DOMAIN}/health/gateway"

# PUABO NEXUS Services
print_section "PUABO NEXUS Services (Box Truck & Fleet)"
check_endpoint "AI Dispatch" "https://${DOMAIN}/puabo-nexus/dispatch/health"
check_endpoint "Driver App Backend" "https://${DOMAIN}/puabo-nexus/driver/health"
check_endpoint "Fleet Manager" "https://${DOMAIN}/puabo-nexus/fleet/health"
check_endpoint "Route Optimizer" "https://${DOMAIN}/puabo-nexus/routes/health"

# V-Suite Services
print_section "V-Suite Services"
check_endpoint "VScreen Hollywood" "https://${DOMAIN}/v-suite/screen/health"
check_endpoint "V-Prompter Pro" "https://${DOMAIN}/v-suite/prompter/health"

# Media & Entertainment
print_section "Media & Entertainment"
check_endpoint "Nexus Studio AI" "https://${DOMAIN}/nexus-studio/health"
check_endpoint "Club Saditty" "https://${DOMAIN}/club-saditty/health"
check_endpoint "PUABO DSP" "https://${DOMAIN}/puabo-dsp/health"
check_endpoint "PUABO BLAC" "https://${DOMAIN}/puabo-blac/health"

# Authentication & Payment
print_section "Authentication & Payment"
check_endpoint "Nexus ID OAuth" "https://${DOMAIN}/auth/health"
check_endpoint "Nexus Pay Gateway" "https://${DOMAIN}/payment/health"

# Summary
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                                ║${NC}"
echo -e "${CYAN}║                      HEALTH CHECK SUMMARY                      ║${NC}"
echo -e "${CYAN}║                                                                ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}Healthy Services:${NC}   ${HEALTHY_COUNT}"
echo -e "${RED}Unhealthy Services:${NC} ${UNHEALTHY_COUNT}"
echo -e "${BLUE}Total Services:${NC}     ${TOTAL_COUNT}"
echo ""

# Calculate percentage
if [ $TOTAL_COUNT -gt 0 ]; then
    HEALTH_PERCENTAGE=$((HEALTHY_COUNT * 100 / TOTAL_COUNT))
    echo -e "${CYAN}Health Percentage:${NC}  ${HEALTH_PERCENTAGE}%"
    echo ""
fi

# Exit code based on health
if [ $UNHEALTHY_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓ All services are healthy!${NC}"
    echo ""
    exit 0
else
    echo -e "${YELLOW}⚠ Some services are unhealthy${NC}"
    echo ""
    echo -e "${CYAN}Tips:${NC}"
    echo "  - Check if services are running: docker compose -f docker-compose.pf.yml ps"
    echo "  - View logs: docker compose -f docker-compose.pf.yml logs -f"
    echo "  - Restart unhealthy services: docker compose -f docker-compose.pf.yml restart <service>"
    echo ""
    exit 1
fi
