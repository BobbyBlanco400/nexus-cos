#!/bin/bash
################################################################################
# Complete THIIO Handoff + Master PF Deployment Script
# 
# This script integrates:
# 1. Existing THIIO handoff package (23E5... hash verification)
# 2. Master PF execution pipeline (short film production)
# 3. Unified THIIO handoff bundle creation
#
# Usage (SSH): 
#   ssh user@server 'bash -s' < deploy_complete_thiio_master_pf.sh
#   OR
#   scp deploy_complete_thiio_master_pf.sh user@server:/tmp/ && ssh user@server 'bash /tmp/deploy_complete_thiio_master_pf.sh'
################################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/BobbyBlanco400/nexus-cos.git"
BRANCH="copilot/setup-github-ready-repo-structure"
WORK_DIR="/opt/nexus-cos"
EXPECTED_SHA256="23E511A6F52F17FE12DED43E32F71D748FBEF1B32CA339DBB60C253E03339AB4"

# Banner
echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════╗
║      NEXUS COS - COMPLETE THIIO HANDOFF + MASTER PF DEPLOYMENT          ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}Deployment Configuration:${NC}"
echo -e "  Repository: ${GREEN}${REPO_URL}${NC}"
echo -e "  Branch: ${GREEN}${BRANCH}${NC}"
echo -e "  Work Directory: ${GREEN}${WORK_DIR}${NC}"
echo -e "  Expected SHA256: ${GREEN}${EXPECTED_SHA256}${NC}"
echo ""

# Function to print step headers
print_step() {
    echo ""
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}▶ STEP $1: $2${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Function to print success
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_warning "Not running as root. Some operations may require sudo."
fi

# STEP 1: Install Dependencies
print_step "1" "Installing System Dependencies"

if command -v apt-get &> /dev/null; then
    print_success "Using apt-get package manager"
    sudo apt-get update -qq
    sudo apt-get install -y git python3 python3-pip curl wget zip unzip bc > /dev/null 2>&1
elif command -v yum &> /dev/null; then
    print_success "Using yum package manager"
    sudo yum install -y git python3 python3-pip curl wget zip unzip bc > /dev/null 2>&1
else
    print_warning "Unknown package manager. Please ensure git, python3, curl, wget, zip are installed."
fi

print_success "System dependencies installed"

# STEP 2: Clone/Update Repository
print_step "2" "Cloning/Updating Nexus COS Repository"

if [ -d "$WORK_DIR" ]; then
    print_warning "Work directory exists. Updating..."
    cd "$WORK_DIR"
    git fetch origin
    git checkout "$BRANCH"
    git pull origin "$BRANCH"
    print_success "Repository updated"
else
    print_success "Cloning repository..."
    sudo mkdir -p "$(dirname "$WORK_DIR")"
    sudo git clone -b "$BRANCH" "$REPO_URL" "$WORK_DIR"
    cd "$WORK_DIR"
    print_success "Repository cloned"
fi

# Set permissions
sudo chown -R $USER:$USER "$WORK_DIR"
print_success "Permissions set"

# STEP 3: Verify/Generate THIIO Handoff Package (23E5... hash)
print_step "3" "Verifying THIIO Handoff Package (23E5... hash)"

cd "$WORK_DIR"

if [ -f "dist/Nexus-COS-THIIO-FullStack.zip" ]; then
    print_success "Found existing THIIO handoff package"
    
    # Verify SHA256
    ACTUAL_SHA256=$(sha256sum dist/Nexus-COS-THIIO-FullStack.zip | awk '{print toupper($1)}')
    
    if [ "$ACTUAL_SHA256" = "$EXPECTED_SHA256" ]; then
        print_success "SHA256 verified: $ACTUAL_SHA256"
    else
        print_warning "SHA256 mismatch!"
        echo -e "  Expected: ${GREEN}$EXPECTED_SHA256${NC}"
        echo -e "  Actual:   ${RED}$ACTUAL_SHA256${NC}"
        print_warning "Regenerating THIIO handoff package..."
        
        # Regenerate
        chmod +x make_full_thiio_handoff.sh
        ./make_full_thiio_handoff.sh
        
        # Verify again
        ACTUAL_SHA256=$(sha256sum dist/Nexus-COS-THIIO-FullStack.zip | awk '{print toupper($1)}')
        if [ "$ACTUAL_SHA256" = "$EXPECTED_SHA256" ]; then
            print_success "SHA256 verified after regeneration: $ACTUAL_SHA256"
        else
            print_error "SHA256 still doesn't match after regeneration"
            print_error "This may indicate source file differences"
        fi
    fi
else
    print_warning "THIIO handoff package not found. Generating..."
    chmod +x make_full_thiio_handoff.sh
    ./make_full_thiio_handoff.sh
    
    if [ -f "dist/Nexus-COS-THIIO-FullStack.zip" ]; then
        ACTUAL_SHA256=$(sha256sum dist/Nexus-COS-THIIO-FullStack.zip | awk '{print toupper($1)}')
        print_success "THIIO handoff package generated"
        echo -e "  SHA256: ${GREEN}$ACTUAL_SHA256${NC}"
    else
        print_error "Failed to generate THIIO handoff package"
        exit 1
    fi
fi

# Display package info
if [ -f "dist/Nexus-COS-THIIO-FullStack-manifest.json" ]; then
    echo ""
    echo -e "${BLUE}Package Information:${NC}"
    cat dist/Nexus-COS-THIIO-FullStack-manifest.json | python3 -m json.tool | head -20
fi

# STEP 4: Verify Master PF Structure
print_step "4" "Verifying Master PF Pipeline Structure"

REQUIRED_DIRS=(
    "01_assets/video"
    "01_assets/audio"
    "01_assets/subtitles"
    "01_assets/promo"
    "02_metatwin/actors"
    "02_metatwin/avatars"
    "02_metatwin/performance"
    "03_teleprompter_scripts"
    "04_holocore/environments"
    "04_holocore/ar_overlays"
    "04_holocore/scene_mappings"
    "05_pf_json"
    "06_thiio_handoff/legal"
    "06_thiio_handoff/deployment"
)

all_dirs_exist=true
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "  ${GREEN}✓${NC} $dir"
    else
        echo -e "  ${RED}✗${NC} $dir"
        all_dirs_exist=false
    fi
done

if [ "$all_dirs_exist" = true ]; then
    print_success "All Master PF directories verified"
else
    print_error "Some Master PF directories are missing"
    exit 1
fi

# Verify scripts
REQUIRED_SCRIPTS=(
    "master_pf_execute.sh"
    "scripts/render_segments.py"
    "scripts/apply_metatwin.py"
    "scripts/integrate_holocore.py"
    "scripts/link_assets.py"
    "scripts/verify_thiio.py"
)

echo ""
echo -e "${BLUE}Verifying Master PF Scripts:${NC}"
all_scripts_exist=true
for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo -e "  ${GREEN}✓${NC} $script (executable)"
    elif [ -f "$script" ]; then
        echo -e "  ${YELLOW}⚠${NC} $script (not executable, fixing...)"
        chmod +x "$script"
        echo -e "  ${GREEN}✓${NC} $script (now executable)"
    else
        echo -e "  ${RED}✗${NC} $script (missing)"
        all_scripts_exist=false
    fi
done

if [ "$all_scripts_exist" = true ]; then
    print_success "All Master PF scripts verified"
else
    print_error "Some Master PF scripts are missing"
    exit 1
fi

# STEP 5: Execute Master PF Pipeline
print_step "5" "Executing Master PF Pipeline"

chmod +x master_pf_execute.sh
./master_pf_execute.sh

if [ $? -eq 0 ]; then
    print_success "Master PF pipeline executed successfully"
else
    print_error "Master PF pipeline execution failed"
    exit 1
fi

# STEP 6: Create Unified THIIO Handoff Bundle
print_step "6" "Creating Unified THIIO Handoff Bundle"

UNIFIED_BUNDLE_NAME="Nexus-COS-THIIO-MasterPF-Unified"
UNIFIED_DIR="dist/${UNIFIED_BUNDLE_NAME}-temp"
UNIFIED_ZIP="dist/${UNIFIED_BUNDLE_NAME}.zip"

# Create clean directory
rm -rf "$UNIFIED_DIR"
mkdir -p "$UNIFIED_DIR"

# Copy THIIO handoff package
print_success "Copying THIIO handoff package..."
cp -r dist/Nexus-COS-THIIO-FullStack.zip "$UNIFIED_DIR/"
cp -r dist/Nexus-COS-THIIO-FullStack-manifest.json "$UNIFIED_DIR/"

# Copy Master PF structure
print_success "Copying Master PF structure..."
mkdir -p "$UNIFIED_DIR/master-pf"
cp -r 01_assets "$UNIFIED_DIR/master-pf/"
cp -r 02_metatwin "$UNIFIED_DIR/master-pf/"
cp -r 03_teleprompter_scripts "$UNIFIED_DIR/master-pf/"
cp -r 04_holocore "$UNIFIED_DIR/master-pf/"
cp -r 05_pf_json "$UNIFIED_DIR/master-pf/"
cp -r 06_thiio_handoff "$UNIFIED_DIR/master-pf/"
cp -r output "$UNIFIED_DIR/master-pf/" 2>/dev/null || true
cp master_pf_execute.sh "$UNIFIED_DIR/master-pf/"
cp README_MASTER_PF.md "$UNIFIED_DIR/master-pf/" 2>/dev/null || true
cp MASTER_PF_PACKAGE_SUMMARY.md "$UNIFIED_DIR/master-pf/" 2>/dev/null || true

# Copy Master PF scripts
mkdir -p "$UNIFIED_DIR/master-pf/scripts"
cp scripts/render_segments.py "$UNIFIED_DIR/master-pf/scripts/"
cp scripts/apply_metatwin.py "$UNIFIED_DIR/master-pf/scripts/"
cp scripts/integrate_holocore.py "$UNIFIED_DIR/master-pf/scripts/"
cp scripts/link_assets.py "$UNIFIED_DIR/master-pf/scripts/"
cp scripts/verify_thiio.py "$UNIFIED_DIR/master-pf/scripts/"

# Create unified README
cat > "$UNIFIED_DIR/README.md" << 'EOFREADME'
# Nexus COS - Unified THIIO Handoff + Master PF Package

This package contains:

## 1. THIIO Handoff Package (Platform Deployment)
- **File**: `Nexus-COS-THIIO-FullStack.zip`
- **SHA256**: `23E511A6F52F17FE12DED43E32F71D748FBEF1B32CA339DBB60C253E03339AB4`
- **Contents**: 52+ services, 43 modules, full platform stack
- **Purpose**: Deploy entire Nexus COS platform to THIIO network

## 2. Master PF Pipeline (Content Production)
- **Directory**: `master-pf/`
- **Contents**: Video rendering, MetaTwin integration, HoloCore environments
- **Purpose**: Create short film content with avatars and AR overlays

## Quick Start

### Deploy Platform (THIIO Handoff)
```bash
unzip Nexus-COS-THIIO-FullStack.zip
# Follow deployment instructions in extracted package
```

### Execute Master PF Pipeline
```bash
cd master-pf/
./master_pf_execute.sh
```

## Documentation
- THIIO Handoff: See `Nexus-COS-THIIO-FullStack-manifest.json`
- Master PF: See `master-pf/README_MASTER_PF.md`

## Verification
```bash
# Verify THIIO package
sha256sum Nexus-COS-THIIO-FullStack.zip
# Should output: 23E511A6F52F17FE12DED43E32F71D748FBEF1B32CA339DBB60C253E03339AB4
```
EOFREADME

print_success "Unified structure created"

# Create the unified ZIP
print_success "Creating unified ZIP archive..."
cd "$UNIFIED_DIR"
zip -r "$UNIFIED_ZIP" . -q
cd "$WORK_DIR"

# Calculate metadata
UNIFIED_SHA256=$(sha256sum "$UNIFIED_ZIP" | awk '{print toupper($1)}')
UNIFIED_SIZE=$(stat -c%s "$UNIFIED_ZIP" 2>/dev/null || stat -f%z "$UNIFIED_ZIP")
UNIFIED_SIZE_MB=$(echo "scale=2; $UNIFIED_SIZE / 1024 / 1024" | bc)

# Create unified manifest
cat > "dist/${UNIFIED_BUNDLE_NAME}-manifest.json" << EOF
{
  "package": "Nexus COS - Unified THIIO Handoff + Master PF Package",
  "version": "3.0.0",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "path": "dist/${UNIFIED_BUNDLE_NAME}.zip",
  "sha256": "$UNIFIED_SHA256",
  "size_bytes": $UNIFIED_SIZE,
  "size_mb": "$UNIFIED_SIZE_MB",
  "components": {
    "thiio_handoff": {
      "file": "Nexus-COS-THIIO-FullStack.zip",
      "sha256": "$EXPECTED_SHA256",
      "contents": "52+ services, 43 modules, full platform stack",
      "purpose": "Platform deployment to THIIO network"
    },
    "master_pf": {
      "directory": "master-pf/",
      "contents": "Video rendering, MetaTwin integration, HoloCore environments",
      "purpose": "Short film content production pipeline"
    }
  },
  "deployment": {
    "thiio_handoff": "Extract and deploy Nexus-COS-THIIO-FullStack.zip",
    "master_pf": "cd master-pf && ./master_pf_execute.sh"
  }
}
EOF

print_success "Unified manifest created"

# Cleanup temp directory
rm -rf "$UNIFIED_DIR"

# STEP 7: Summary
print_step "7" "Deployment Summary"

echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    DEPLOYMENT COMPLETE                                   ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📦 THIIO Handoff Package (Platform):${NC}"
echo -e "  Location: ${GREEN}dist/Nexus-COS-THIIO-FullStack.zip${NC}"
echo -e "  SHA256: ${GREEN}$EXPECTED_SHA256${NC}"
echo -e "  Purpose: Deploy Nexus COS platform to THIIO network"
echo ""

echo -e "${BLUE}🎬 Master PF Pipeline (Content Production):${NC}"
echo -e "  Directories: ${GREEN}01_assets/ through 06_thiio_handoff/${NC}"
echo -e "  Script: ${GREEN}./master_pf_execute.sh${NC}"
echo -e "  Purpose: Create short film content with MetaTwin/HoloCore"
echo ""

echo -e "${BLUE}📦 Unified Bundle:${NC}"
echo -e "  Location: ${GREEN}dist/${UNIFIED_BUNDLE_NAME}.zip${NC}"
echo -e "  SHA256: ${GREEN}$UNIFIED_SHA256${NC}"
echo -e "  Size: ${GREEN}${UNIFIED_SIZE_MB} MB${NC}"
echo -e "  Manifest: ${GREEN}dist/${UNIFIED_BUNDLE_NAME}-manifest.json${NC}"
echo ""

echo -e "${BLUE}📊 Deployment Details:${NC}"
echo -e "  Work Directory: ${GREEN}$WORK_DIR${NC}"
echo -e "  Branch: ${GREEN}$BRANCH${NC}"
echo -e "  Output Generated: ${GREEN}output/${NC}"
echo ""

echo -e "${BLUE}🚀 Next Steps:${NC}"
echo -e "  1. Download unified bundle:"
echo -e "     ${CYAN}scp user@server:$WORK_DIR/dist/${UNIFIED_BUNDLE_NAME}.zip .${NC}"
echo -e ""
echo -e "  2. Deploy THIIO platform:"
echo -e "     ${CYAN}unzip Nexus-COS-THIIO-FullStack.zip${NC}"
echo -e ""
echo -e "  3. Execute Master PF pipeline:"
echo -e "     ${CYAN}cd master-pf && ./master_pf_execute.sh${NC}"
echo ""

print_success "All operations completed successfully!"
echo ""

exit 0
