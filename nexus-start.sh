#!/bin/bash
###############################################################################
# Nexus COS Quick Start Script
# Version: 1.0.0
# Purpose: Simple one-command startup for Nexus COS production environment
#
# This script is a simplified wrapper around the full deployment script
# Use this for daily operations after initial deployment
#
# Usage:
#   ./nexus-start.sh
#
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}   Nexus COS - Quick Start${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if full deployment script exists
if [ ! -f "./nexus-cos-production-deploy.sh" ]; then
  echo "Error: nexus-cos-production-deploy.sh not found!"
  echo "Please run the full deployment script first."
  exit 1
fi

# Run the full deployment with --no-pull and --skip-verify for quick startup
echo -e "${GREEN}Starting Nexus COS...${NC}"
echo ""

./nexus-cos-production-deploy.sh --no-pull --skip-verify

echo ""
echo -e "${GREEN}${BOLD}✓ Nexus COS Started!${NC}"
echo ""
echo "Quick commands:"
echo -e "  ${CYAN}pm2 list${NC}     - View services"
echo -e "  ${CYAN}pm2 logs${NC}     - View logs"
echo -e "  ${CYAN}pm2 monit${NC}    - Monitor in real-time"
echo ""

exit 0
