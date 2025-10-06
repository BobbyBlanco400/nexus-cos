#!/bin/bash
###############################################################################
# Nexus COS - One-Command Setup & Deployment
# Version: 1.0.0
# Purpose: Complete setup and deployment in one command
#
# This script will:
#   1. Validate the environment
#   2. Install PM2 if needed (optional)
#   3. Deploy Nexus COS
#   4. Verify everything is working
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/setup-nexus-cos.sh | bash
#   
#   Or if you already have the repo:
#   ./setup-nexus-cos.sh
#
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_banner() {
  echo ""
  echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║${NC}  ${CYAN}${BOLD}Nexus COS - Production Setup & Deployment${NC}          ${BLUE}║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_step() {
  echo -e "\n${MAGENTA}➜${NC} ${BOLD}$1${NC}"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_info() {
  echo -e "${CYAN}ℹ${NC} $1"
}

print_banner

# Step 1: Check if we're in the right directory
print_step "Step 1: Checking environment..."

if [ ! -f "ecosystem.config.js" ]; then
  print_error "ecosystem.config.js not found!"
  echo ""
  echo "This script must be run from the Nexus COS directory."
  echo ""
  echo "If you haven't cloned the repository yet:"
  echo "  git clone https://github.com/BobbyBlanco400/nexus-cos.git"
  echo "  cd nexus-cos"
  echo "  ./setup-nexus-cos.sh"
  echo ""
  exit 1
fi

print_success "In Nexus COS directory"

# Step 2: Check Node.js
if ! command -v node &> /dev/null; then
  print_error "Node.js not installed!"
  echo ""
  echo "Please install Node.js (v14 or higher):"
  echo "  https://nodejs.org/"
  echo ""
  exit 1
fi

NODE_VERSION=$(node --version)
print_success "Node.js installed: $NODE_VERSION"

# Step 3: Check/Install PM2
print_step "Step 2: Checking PM2..."

if ! command -v pm2 &> /dev/null; then
  print_info "PM2 not installed"
  echo ""
  read -p "Install PM2 globally? (y/n) " -n 1 -r
  echo ""
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Installing PM2..."
    npm install -g pm2
    print_success "PM2 installed"
  else
    print_error "PM2 is required. Please install it manually:"
    echo "  npm install -g pm2"
    exit 1
  fi
else
  PM2_VERSION=$(pm2 --version)
  print_success "PM2 installed: v$PM2_VERSION"
fi

# Step 4: Validate deployment system
print_step "Step 3: Validating deployment system..."

if [ -f "validate-deployment-readiness.sh" ]; then
  chmod +x validate-deployment-readiness.sh
  
  if ./validate-deployment-readiness.sh > /tmp/validation.log 2>&1; then
    print_success "Validation passed"
  else
    VALIDATION_STATUS=$?
    if [ $VALIDATION_STATUS -eq 0 ]; then
      print_success "Validation passed with warnings"
    else
      print_error "Validation failed"
      echo ""
      echo "Review validation output:"
      cat /tmp/validation.log
      echo ""
      exit 1
    fi
  fi
else
  print_info "Validation script not found, skipping..."
fi

# Step 5: Make scripts executable
print_step "Step 4: Setting up scripts..."

chmod +x nexus-cos-production-deploy.sh 2>/dev/null || true
chmod +x nexus-start.sh 2>/dev/null || true
chmod +x validate-deployment-readiness.sh 2>/dev/null || true

print_success "Scripts are executable"

# Step 6: Deploy
print_step "Step 5: Deploying Nexus COS..."

echo ""
echo -e "${YELLOW}About to deploy Nexus COS with 33 services...${NC}"
echo ""
read -p "Continue with deployment? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  print_info "Deployment cancelled"
  echo ""
  echo "You can deploy later with:"
  echo "  ./nexus-cos-production-deploy.sh"
  echo ""
  exit 0
fi

# Run deployment
if ./nexus-cos-production-deploy.sh; then
  echo ""
  print_step "🎉 Setup Complete!"
  echo ""
  echo -e "${GREEN}${BOLD}Nexus COS is now running!${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Check status: ${CYAN}pm2 list${NC}"
  echo "  2. View logs: ${CYAN}pm2 logs${NC}"
  echo "  3. Check health: ${CYAN}curl -s https://nexuscos.online/health | jq${NC}"
  echo ""
  echo "Documentation:"
  echo "  - Quick start: ${CYAN}START_HERE.md${NC}"
  echo "  - Full guide: ${CYAN}PRODUCTION_DEPLOYMENT_GUIDE.md${NC}"
  echo ""
  echo "Daily operations:"
  echo "  - Start services: ${CYAN}./nexus-start.sh${NC}"
  echo "  - Restart: ${CYAN}pm2 restart all${NC}"
  echo "  - Monitor: ${CYAN}pm2 monit${NC}"
  echo ""
else
  print_error "Deployment failed"
  echo ""
  echo "Check the error messages above and try again."
  echo ""
  echo "For help, see:"
  echo "  - PRODUCTION_DEPLOYMENT_GUIDE.md"
  echo "  - Run: pm2 logs"
  echo ""
  exit 1
fi

exit 0
