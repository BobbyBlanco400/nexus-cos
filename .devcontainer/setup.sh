#!/usr/bin/env bash
# 🔴 N3XUS COS Codespaces Setup Script
# Automated environment configuration for browser-based development

set -euo pipefail

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  🔴 N3XUS COS Codespaces Environment Setup                  ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Set Genesis Lock environment
echo -e "${GREEN}[1/8]${NC} Setting Genesis Lock environment..."
export NEXUS_HANDSHAKE="55-45-17"
export GENESIS_LOCK_ENABLED="true"
export NODE_ENV="development"
export CODESPACES_ENV="true"

cat >> ~/.bashrc << 'EOF'
# N3XUS COS Environment
export NEXUS_HANDSHAKE="55-45-17"
export GENESIS_LOCK_ENABLED="true"
export PATH="$PATH:/workspaces/nexus-cos/scripts:/workspaces/nexus-cos/nexus-ai/verify"

# Red highlighting for critical commands
alias handshake='echo -e "\033[1;31m🔴 Running Handshake Enforcer...\033[0m" && ./nexus-handshake-enforcer.sh'
alias healthcheck='echo -e "\033[1;31m🔴 Running Health Check...\033[0m" && ./nexus_cos_health_check.sh'
alias genesis='echo -e "\033[1;31m🔴 Checking Genesis Lock...\033[0m" && test -f core/genesis-lock/lock.enabled && echo "✅ Active" || echo "❌ Inactive"'
EOF

source ~/.bashrc || true

# Install Node.js dependencies
echo -e "${GREEN}[2/8]${NC} Installing Node.js dependencies..."
if [ -f package.json ]; then
  npm install --silent || {
    echo -e "${YELLOW}⚠️  Some npm packages failed to install, continuing...${NC}"
  }
else
  echo -e "${YELLOW}⚠️  No package.json found, skipping npm install${NC}"
fi

# Install Python dependencies
echo -e "${GREEN}[3/8]${NC} Installing Python dependencies..."
if [ -f requirements.txt ]; then
  pip3 install -r requirements.txt --quiet || {
    echo -e "${YELLOW}⚠️  Some Python packages failed to install, continuing...${NC}"
  }
else
  echo -e "${YELLOW}⚠️  No requirements.txt found, skipping pip install${NC}"
fi

# Make scripts executable
echo -e "${GREEN}[4/8]${NC} Making scripts executable..."
find . -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
chmod +x nexus-handshake-enforcer.sh 2>/dev/null || true
chmod +x nexus_cos_health_check.sh 2>/dev/null || true
chmod +x trae-governance-verification.sh 2>/dev/null || true

# Create Genesis Lock files if missing
echo -e "${GREEN}[5/8]${NC} Initializing Genesis Lock..."
mkdir -p core/genesis-lock
if [ ! -f core/genesis-lock/lock.enabled ]; then
  touch core/genesis-lock/lock.enabled
  echo -e "${GREEN}✅ Genesis Lock enabled${NC}"
else
  echo -e "${GREEN}✅ Genesis Lock already enabled${NC}"
fi

# Copy environment template if .env doesn't exist
echo -e "${GREEN}[6/8]${NC} Configuring environment..."
if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env
  echo -e "${GREEN}✅ Created .env from template${NC}"
  
  # Update .env with Genesis Lock settings
  cat >> .env << 'EOF'

# Genesis Lock & Handshake (Codespaces)
NEXUS_HANDSHAKE=55-45-17
GENESIS_LOCK_ENABLED=true
CODESPACES_ENV=true
EOF
else
  echo -e "${GREEN}✅ Environment file exists${NC}"
fi

# Verify Docker is available
echo -e "${GREEN}[7/8]${NC} Verifying Docker..."
if command -v docker &> /dev/null; then
  echo -e "${GREEN}✅ Docker available${NC}"
  docker --version
else
  echo -e "${RED}❌ Docker not available${NC}"
fi

# Display welcome message
echo -e "${GREEN}[8/8]${NC} Setup complete!"
echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  ✅ N3XUS COS Codespaces Ready                              ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${RED}🔴 QUICK START COMMANDS:${NC}"
echo ""
echo -e "  ${RED}1.${NC} Run Handshake Enforcer:"
echo -e "     ${YELLOW}./nexus-handshake-enforcer.sh${NC}"
echo ""
echo -e "  ${RED}2.${NC} Start Development Environment (Phase 1+2):"
echo -e "     ${YELLOW}docker compose --profile phase1 --profile phase2 up -d${NC}"
echo ""
echo -e "  ${RED}3.${NC} Run Health Check:"
echo -e "     ${YELLOW}./nexus_cos_health_check.sh${NC}"
echo ""
echo -e "  ${RED}4.${NC} Verify System:"
echo -e "     ${YELLOW}./trae-governance-verification.sh${NC}"
echo ""
echo -e "  ${RED}5.${NC} Access AI Control Panel:"
echo -e "     ${YELLOW}http://localhost:9000${NC}"
echo ""
echo -e "${RED}🔴 GENESIS LOCK: ${GREEN}ENABLED${NC}"
echo -e "${RED}🔴 HANDSHAKE: ${GREEN}55-45-17${NC}"
echo ""
echo -e "${YELLOW}📘 See N3XUS_vCOS_MasterPR_FullStack_Launch.md for complete documentation${NC}"
echo ""

exit 0
