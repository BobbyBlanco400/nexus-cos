#!/bin/bash
# ==============================================================================
# TRAE Solo Bulletproof Quick Launch
# ==============================================================================
# Simple one-liner wrapper for bulletproofed deployment
# Usage: curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                                                              ║${NC}"
echo -e "${PURPLE}║     🛡️  TRAE SOLO BULLETPROOF QUICK LAUNCH  🛡️               ║${NC}"
echo -e "${PURPLE}║                                                              ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${BLUE}[INFO]${NC} This script needs root privileges. Please run with sudo."
    exit 1
fi

# Default configuration
REPO_PATH="${REPO_PATH:-/opt/nexus-cos}"
SCRIPT_URL="https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/trae-solo-bulletproof-deploy.sh"

echo -e "${BLUE}[INFO]${NC} Repository path: $REPO_PATH"
echo ""

# Check if repository exists
if [[ ! -d "$REPO_PATH" ]]; then
    echo -e "${CYAN}[SETUP]${NC} Repository not found. Cloning from GitHub..."
    mkdir -p "$(dirname "$REPO_PATH")"
    cd "$(dirname "$REPO_PATH")"
    
    if command -v git &> /dev/null; then
        git clone https://github.com/BobbyBlanco400/nexus-cos.git "$(basename "$REPO_PATH")"
        echo -e "${GREEN}[SUCCESS]${NC} Repository cloned successfully"
    else
        echo -e "${BLUE}[INFO]${NC} Git not found. Downloading as ZIP..."
        curl -L "https://github.com/BobbyBlanco400/nexus-cos/archive/refs/heads/main.zip" -o nexus-cos.zip
        unzip -q nexus-cos.zip
        mv nexus-cos-main "$(basename "$REPO_PATH")"
        rm nexus-cos.zip
        echo -e "${GREEN}[SUCCESS]${NC} Repository downloaded successfully"
    fi
fi

# Navigate to repository
cd "$REPO_PATH"

# Check if bulletproof script exists
if [[ ! -f "trae-solo-bulletproof-deploy.sh" ]]; then
    echo -e "${CYAN}[DOWNLOAD]${NC} Downloading bulletproof deployment script..."
    curl -fsSL "$SCRIPT_URL" -o trae-solo-bulletproof-deploy.sh
    chmod +x trae-solo-bulletproof-deploy.sh
    echo -e "${GREEN}[SUCCESS]${NC} Script downloaded"
fi

# Make sure script is executable
chmod +x trae-solo-bulletproof-deploy.sh

# Run the bulletproof deployment
echo ""
echo -e "${GREEN}[LAUNCH]${NC} Starting bulletproofed deployment..."
echo ""

bash "$REPO_PATH/trae-solo-bulletproof-deploy.sh"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║            ✅  BULLETPROOF LAUNCH COMPLETE!  ✅               ║${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
