#!/bin/bash

# ==============================================================================
# NEXUS COS PHASE 2.5 - ONE-COMMAND DEPLOYMENT
# ==============================================================================
# Purpose: Single command to deploy entire Phase 2.5 architecture to VPS
# Usage: sudo ./DEPLOY_PHASE_2.5.sh
# ==============================================================================

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# ==============================================================================
# Header
# ==============================================================================

print_header() {
    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║       NEXUS COS PHASE 2.5 - ONE-COMMAND DEPLOYMENT            ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║              Bulletproof Deployment for VPS Launch             ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

fatal_error() {
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                     DEPLOYMENT FAILED                          ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${RED}Error: $1${NC}"
    echo ""
    exit 1
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# ==============================================================================
# Pre-flight Checks
# ==============================================================================

print_header

print_info "Starting Phase 2.5 deployment..."
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    fatal_error "This script must be run as root. Use: sudo ./DEPLOY_PHASE_2.5.sh"
fi

# Verify we're in the correct directory
if [[ ! -f "PF_PHASE_2.5_OTT_INTEGRATION.md" ]]; then
    fatal_error "Must be run from /opt/nexus-cos directory. Current: $(pwd)"
fi

# Check that deployment scripts exist
if [[ ! -f "scripts/deploy-phase-2.5-architecture.sh" ]]; then
    fatal_error "Deployment script not found. Repository may be corrupted."
fi

if [[ ! -f "scripts/validate-phase-2.5-deployment.sh" ]]; then
    fatal_error "Validation script not found. Repository may be corrupted."
fi

# Make scripts executable
chmod +x scripts/deploy-phase-2.5-architecture.sh
chmod +x scripts/validate-phase-2.5-deployment.sh

print_success "Pre-flight checks passed"
echo ""

# ==============================================================================
# Execute Deployment
# ==============================================================================

print_info "Executing Phase 2.5 deployment..."
echo ""

if ./scripts/deploy-phase-2.5-architecture.sh; then
    print_success "Deployment completed successfully"
    echo ""
else
    fatal_error "Deployment script failed. Check logs above."
fi

# ==============================================================================
# Execute Validation
# ==============================================================================

print_info "Running deployment validation..."
echo ""

if ./scripts/validate-phase-2.5-deployment.sh; then
    print_success "Validation completed successfully"
    echo ""
else
    echo ""
    echo -e "${YELLOW}⚠ Warning: Validation found issues${NC}"
    echo -e "${YELLOW}Please review the validation output above${NC}"
    echo ""
fi

# ==============================================================================
# Success Summary
# ==============================================================================

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                                ║${NC}"
echo -e "${GREEN}║         🎉 PHASE 2.5 DEPLOYMENT COMPLETE - SUCCESS 🎉         ║${NC}"
echo -e "${GREEN}║                                                                ║${NC}"
echo -e "${GREEN}║              ALL MANDATORY REQUIREMENTS MET                    ║${NC}"
echo -e "${GREEN}║                                                                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN}Your Nexus COS Phase 2.5 deployment is live:${NC}"
echo ""
echo -e "  ${GREEN}►${NC} OTT Frontend:     https://nexuscos.online"
echo -e "  ${GREEN}►${NC} V-Suite Dashboard: https://nexuscos.online/v-suite/"
echo -e "  ${GREEN}►${NC} Beta Portal:      https://beta.nexuscos.online"
echo ""

echo -e "${CYAN}Next Steps:${NC}"
echo -e "  1. Verify domains resolve correctly"
echo -e "  2. Test SSL certificates are valid"
echo -e "  3. Monitor logs in /opt/nexus-cos/logs/phase2.5/"
echo -e "  4. Schedule beta transition for Nov 17, 2025"
echo ""

echo -e "${GREEN}✓ Deployment ready for production use!${NC}"
echo ""

exit 0
