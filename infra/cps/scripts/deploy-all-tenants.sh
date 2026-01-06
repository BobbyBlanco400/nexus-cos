#!/bin/bash

# N3XUS COS — Mass Tenant Deployment Script
# Version: v2.5.0-RC1
# Handshake: 55-45-17
# Deploys all 13 Founding Residents

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}[DEPLOY]${NC} $1"
}

# Banner
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  N3XUS COS — Mass Deployment Script"
echo "  Founding Residents Cohort v1.0.0"
echo "  Version: v2.5.0-RC1"
echo "  Handshake: 55-45-17"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_SCRIPT="${SCRIPT_DIR}/deploy-tenant.sh"

# Check if deploy-tenant.sh exists
if [ ! -f "${DEPLOY_SCRIPT}" ]; then
    print_error "deploy-tenant.sh not found at: ${DEPLOY_SCRIPT}"
    exit 1
fi

# Make deploy-tenant.sh executable
chmod +x "${DEPLOY_SCRIPT}"

# Array of all 13 Founding Residents
# Format: "Tenant Name|tenant-slug|domain"
declare -a TENANTS=(
    "Club Saditty|club-saditty|clubsaditty.n3xuscos.online"
    "Faith Through Fitness|faith-through-fitness|faithfitness.n3xuscos.online"
    "Ashanti's Munch & Mingle|ashantis-munch-and-mingle|ashantifoods.n3xuscos.online"
    "Ro Ro's Gamers Lounge|ro-ros-gamers-lounge|rorogaming.n3xuscos.online"
    "IDH-Live!|idh-live|idhlive.n3xuscos.online"
    "Clocking T. Wit Ya Gurl P|clocking-t|clockingt.n3xuscos.online"
    "Tyshawn's V-Dance Studio|tyshawn-dance-studio|tyshawndance.n3xuscos.online"
    "Fayeloni-Kreations|fayeloni-kreations|fayeloni.n3xuscos.online"
    "Sassie Lashes|sassie-lashes|sassielashes.n3xuscos.online"
    "Nee Nee & Kids|neenee-and-kids|neeneekids.n3xuscos.online"
    "Headwina's Comedy Club|headwinas-comedy-club|headwinacomedy.n3xuscos.online"
    "Rise Sacramento 916|rise-sacramento-916|risesac916.n3xuscos.online"
    "Sheda Shay's Butter Bar|sheda-shays-butter-bar|shedasbutterbar.n3xuscos.online"
)

# Count total tenants
TOTAL_TENANTS=${#TENANTS[@]}

print_info "Deploying ${TOTAL_TENANTS} Founding Resident platforms..."
echo ""

# Track success/failure
SUCCESS_COUNT=0
FAILED_COUNT=0
declare -a FAILED_TENANTS

# Deploy each tenant
for i in "${!TENANTS[@]}"; do
    TENANT_NUM=$((i + 1))
    TENANT_DATA="${TENANTS[$i]}"
    
    # Parse tenant data
    IFS='|' read -r TENANT_NAME TENANT_SLUG TENANT_DOMAIN <<< "$TENANT_DATA"
    
    print_header "[$TENANT_NUM/$TOTAL_TENANTS] Deploying: ${TENANT_NAME}"
    echo ""
    
    # Run deployment
    if "${DEPLOY_SCRIPT}" "${TENANT_NAME}" "${TENANT_SLUG}" "${TENANT_DOMAIN}"; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        print_success "✅ ${TENANT_NAME} deployed successfully"
    else
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_TENANTS+=("${TENANT_NAME}")
        print_error "❌ ${TENANT_NAME} deployment failed"
    fi
    
    echo ""
    echo "───────────────────────────────────────────────────────────"
    echo ""
    
    # Small delay between deployments
    sleep 1
done

# Deployment summary
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  MASS DEPLOYMENT COMPLETE"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Total Tenants: ${TOTAL_TENANTS}"
echo "Successful: ${SUCCESS_COUNT} ✅"
echo "Failed: ${FAILED_COUNT} ❌"
echo ""

if [ ${FAILED_COUNT} -gt 0 ]; then
    print_error "Failed deployments:"
    for tenant in "${FAILED_TENANTS[@]}"; do
        echo "  - ${tenant}"
    done
    echo ""
fi

if [ ${SUCCESS_COUNT} -eq ${TOTAL_TENANTS} ]; then
    print_success "ALL 13 FOUNDING RESIDENTS DEPLOYED SUCCESSFULLY! 🚀"
    echo ""
    echo "N3XUS COS v2.5.0-RC1 — MAINNET ACTIVATED"
    echo "Handshake: 55-45-17 ✅"
    echo ""
    exit 0
else
    print_error "Some deployments failed. Please review the errors above."
    exit 1
fi
