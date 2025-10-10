#!/bin/bash
# Nexus COS Repository Aggregation Script
# Part of v2025 Final Unified Build
# 
# IMPORTANT: This script is designed to be executed in an environment with:
# - Git access to all source repositories
# - Write access to the target repository
# - Sufficient disk space for all repositories
#
# This script documents the aggregation process and can be executed
# when the appropriate environment and permissions are available.

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Nexus COS Repository Aggregation${NC}"
echo -e "${BLUE}v2025 Final Unified Build${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Configuration
WORKSPACE_DIR="${WORKSPACE_DIR:-/opt/nexus-cos}"
SOURCE_DIR="${WORKSPACE_DIR}/source"
FINAL_DIR="${WORKSPACE_DIR}/final"
BACKUP_DIR="${WORKSPACE_DIR}/backup"

# Source Repositories
declare -a BOBBY_REPOS=(
    "https://github.com/BobbyBlanco400/puabo-os.git"
    "https://github.com/BobbyBlanco400/PUABO-OS-V200.git"
    "https://github.com/BobbyBlanco400/Nexus-COS.git"
    "https://github.com/BobbyBlanco400/nexus-cos-beta.git"
)

declare -a PUABO20_REPOS=(
    "https://github.com/Puabo20/node-auth-api.git"
    "https://github.com/Puabo20/puabo-os-2025.git"
    "https://github.com/Puabo20/puabo-cos.git"
    "https://github.com/Puabo20/puabo-os.git"
)

# Repository to Module Mapping
declare -A REPO_TO_MODULE=(
    ["PUABO-OS-V200"]="modules/puabo-os-v200"
    ["Nexus-COS"]="modules/core-os"
    ["nexus-cos-beta"]="modules/puaboverse"
    ["node-auth-api"]="services/auth-service"
    ["puabo-os-2025"]="modules/puabo-nexus"
    ["puabo-cos"]="modules/puabo-studio"
)

echo -e "${YELLOW}⚠ PREREQUISITE CHECK${NC}"
echo ""

# Check if running in appropriate environment
if [ ! -w "$(pwd)" ]; then
    echo -e "${RED}✗ No write access to current directory${NC}"
    echo -e "${YELLOW}  This script requires write access to perform repository operations${NC}"
    exit 1
fi

# Check for git
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git is available${NC}"

# Check disk space (require at least 5GB)
available_space=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$available_space" -lt 5 ]; then
    echo -e "${RED}✗ Insufficient disk space (need 5GB, have ${available_space}GB)${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Sufficient disk space available${NC}"

echo ""
echo -e "${YELLOW}NOTE: This script will clone external repositories.${NC}"
echo -e "${YELLOW}Ensure you have appropriate access and credentials configured.${NC}"
echo ""
read -p "Continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${YELLOW}Aborted by user${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Step 1: Directory Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Create directory structure
mkdir -p "$SOURCE_DIR"
mkdir -p "$FINAL_DIR"
mkdir -p "$BACKUP_DIR"

echo -e "${GREEN}✓ Directories created:${NC}"
echo "  - Source: $SOURCE_DIR"
echo "  - Final: $FINAL_DIR"
echo "  - Backup: $BACKUP_DIR"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Step 2: Clone Source Repositories${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cd "$SOURCE_DIR"

# Function to clone or update repository
clone_or_update() {
    local repo_url=$1
    local repo_name=$(basename "$repo_url" .git)
    
    if [ -d "$repo_name" ]; then
        echo -e "${YELLOW}→ Updating $repo_name${NC}"
        cd "$repo_name"
        git fetch origin
        git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true
        cd ..
    else
        echo -e "${YELLOW}→ Cloning $repo_name${NC}"
        git clone "$repo_url" 2>&1 | grep -v "^Cloning" || true
    fi
    
    if [ -d "$repo_name" ]; then
        echo -e "${GREEN}✓ $repo_name ready${NC}"
    else
        echo -e "${RED}✗ Failed to clone $repo_name${NC}"
        return 1
    fi
}

echo "Cloning BobbyBlanco400 repositories..."
for repo in "${BOBBY_REPOS[@]}"; do
    clone_or_update "$repo" || echo -e "${RED}Failed: $repo${NC}"
done

echo ""
echo "Cloning Puabo20 repositories..."
for repo in "${PUABO20_REPOS[@]}"; do
    clone_or_update "$repo" || echo -e "${RED}Failed: $repo${NC}"
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Step 3: Repository Analysis${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Analyze each cloned repository
for repo_dir in */; do
    repo_name="${repo_dir%/}"
    echo -e "${YELLOW}Analyzing: $repo_name${NC}"
    
    if [ -d "$repo_dir" ]; then
        cd "$repo_dir"
        
        # Count files
        file_count=$(find . -type f ! -path "*/\.*" | wc -l)
        
        # Check for package.json
        if [ -f "package.json" ]; then
            echo "  ✓ Node.js project detected"
        fi
        
        # Check for docker files
        if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ]; then
            echo "  ✓ Docker configuration found"
        fi
        
        # Check for services/modules directories
        if [ -d "services" ] || [ -d "modules" ]; then
            echo "  ✓ Modular structure detected"
        fi
        
        echo "  Files: $file_count"
        
        cd ..
    fi
    echo ""
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Step 4: Create Unified Repository${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cd "$FINAL_DIR"

# Initialize if not already a git repository
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}→ Initializing Git repository${NC}"
    git init
    git branch -M main
    echo -e "${GREEN}✓ Repository initialized${NC}"
else
    echo -e "${GREEN}✓ Git repository already initialized${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Step 5: Merge Repository Content${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}NOTE: Content merging should be done carefully:${NC}"
echo "  1. Review each repository's unique components"
echo "  2. Map to appropriate modules/ or services/ directories"
echo "  3. Update dependencies and imports"
echo "  4. Resolve any conflicts"
echo "  5. Test each integrated component"
echo ""

# This is a manual process that requires careful review
echo -e "${YELLOW}Manual merge steps recommended:${NC}"
echo ""
echo "For each source repository:"
echo "  1. Identify unique components not in unified structure"
echo "  2. Copy to appropriate target directory"
echo "  3. Update package.json dependencies"
echo "  4. Update import statements"
echo "  5. Verify Dockerfiles"
echo "  6. Test service independently"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Step 6: Validation & Testing${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo "After merging content, run:"
echo "  1. docker compose build"
echo "  2. docker compose up -d"
echo "  3. bash pf-health-check.sh"
echo "  4. Verify all endpoints"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Step 7: Final Commit & Push${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo "Once validated, commit and push:"
echo "  git add ."
echo "  git commit -m '🧠 Nexus COS v2025 Final Unified Build'"
echo "  git remote add origin https://github.com/BobbyBlanco400/nexus-cos.git"
echo "  git push -u origin main"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Repository Aggregation Guide Complete${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Review source repositories in: $SOURCE_DIR"
echo "  2. Manually merge unique components"
echo "  3. Update unified repository in: $FINAL_DIR"
echo "  4. Validate with Docker Compose"
echo "  5. Commit and push to production"
echo ""
echo -e "${BLUE}For detailed guidance, see:${NC}"
echo "  NEXUS_COS_V2025_UNIFIED_BUILD_GUIDE.md"
echo ""
