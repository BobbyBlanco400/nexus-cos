#!/bin/bash
# Helper script to pull latest fixes and resolve conflicts
# This script handles the divergent branches issue

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "Pull Latest Deployment Fixes"
echo "=========================================="
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Save current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}[INFO]${NC} Current branch: $CURRENT_BRANCH"

# Stash any local changes
echo -e "${BLUE}[INFO]${NC} Stashing local changes..."
git stash push -m "Auto-stash before pulling fixes $(date '+%Y-%m-%d %H:%M:%S')" || true

# Configure pull strategy to merge
echo -e "${BLUE}[INFO]${NC} Configuring git pull strategy..."
git config pull.rebase false

# Fetch latest changes
echo -e "${BLUE}[INFO]${NC} Fetching latest changes..."
git fetch origin

# Pull with merge strategy
echo -e "${BLUE}[INFO]${NC} Pulling latest changes..."
if git pull origin copilot/fix-deployment-issues; then
    echo -e "${GREEN}[SUCCESS]${NC} Successfully pulled latest fixes!"
else
    echo -e "${RED}[ERROR]${NC} Failed to pull. Trying reset strategy..."
    
    # Reset to remote branch (this will overwrite local changes)
    echo -e "${YELLOW}[WARNING]${NC} Resetting to remote branch (local changes will be lost)..."
    git reset --hard origin/copilot/fix-deployment-issues
    
    echo -e "${GREEN}[SUCCESS]${NC} Reset to latest version!"
fi

# Check if there are stashed changes
if git stash list | grep -q "Auto-stash"; then
    echo ""
    echo -e "${YELLOW}[INFO]${NC} Your previous changes were stashed."
    echo -e "${YELLOW}[INFO]${NC} To restore them, run: git stash pop"
    echo -e "${YELLOW}[INFO]${NC} To discard them, run: git stash drop"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "Ready to run deployment fixes!"
echo "==========================================${NC}"
echo ""
echo "Run the following command to fix all issues:"
echo -e "${BLUE}./fix-deployment-issues.sh${NC}"
echo ""
