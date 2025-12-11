#!/bin/bash

# Nexus COS THIIO Handoff Package Builder
# This script generates the complete THIIO handoff ZIP bundle

set -e

echo "========================================="
echo "THIIO Handoff Package Generator"
echo "========================================="
echo ""

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT_ROOT="/home/runner/work/nexus-cos/nexus-cos"
DIST_DIR="$PROJECT_ROOT/dist"
BUNDLE_NAME="Nexus-COS-THIIO-FullHandoff"
BUNDLE_DIR="$DIST_DIR/$BUNDLE_NAME"
ZIP_FILE="$DIST_DIR/$BUNDLE_NAME.zip"

# Create clean bundle directory
echo -e "${YELLOW}Creating bundle directory...${NC}"
rm -rf "$BUNDLE_DIR"
mkdir -p "$BUNDLE_DIR"

# Copy documentation
echo -e "${YELLOW}Copying THIIO handoff documentation...${NC}"
cp -r "$PROJECT_ROOT/docs/THIIO-HANDOFF" "$BUNDLE_DIR/docs/"

# Copy repository structure
echo -e "${YELLOW}Copying monorepo structure...${NC}"
cp -r "$PROJECT_ROOT/repos/nexus-cos-main" "$BUNDLE_DIR/repos/"

# Copy services
echo -e "${YELLOW}Copying services...${NC}"
mkdir -p "$BUNDLE_DIR/services"
cp -r "$PROJECT_ROOT/services"/* "$BUNDLE_DIR/services/" 2>/dev/null || true

# Copy modules
echo -e "${YELLOW}Copying modules...${NC}"
mkdir -p "$BUNDLE_DIR/modules"
cp -r "$PROJECT_ROOT/modules"/* "$BUNDLE_DIR/modules/" 2>/dev/null || true

# Copy scripts
echo -e "${YELLOW}Copying deployment scripts...${NC}"
mkdir -p "$BUNDLE_DIR/scripts"
cp "$PROJECT_ROOT"/scripts/*.sh "$BUNDLE_DIR/scripts/" 2>/dev/null || true

# Copy GitHub workflows
echo -e "${YELLOW}Copying GitHub workflows...${NC}"
mkdir -p "$BUNDLE_DIR/.github/workflows"
cp "$PROJECT_ROOT"/.github/workflows/*.yml "$BUNDLE_DIR/.github/workflows/" 2>/dev/null || true

# Copy configuration files
echo -e "${YELLOW}Copying configuration files...${NC}"
[ -f "$PROJECT_ROOT/package.json" ] && cp "$PROJECT_ROOT/package.json" "$BUNDLE_DIR/"
[ -f "$PROJECT_ROOT/docker-compose.yml" ] && cp "$PROJECT_ROOT/docker-compose.yml" "$BUNDLE_DIR/"
[ -f "$PROJECT_ROOT/.gitignore" ] && cp "$PROJECT_ROOT/.gitignore" "$BUNDLE_DIR/"
[ -f "$PROJECT_ROOT/.dockerignore" ] && cp "$PROJECT_ROOT/.dockerignore" "$BUNDLE_DIR/"
[ -f "$PROJECT_ROOT/.nvmrc" ] && cp "$PROJECT_ROOT/.nvmrc" "$BUNDLE_DIR/"

# Copy root documentation
echo -e "${YELLOW}Copying root documentation...${NC}"
[ -f "$PROJECT_ROOT/README.md" ] && cp "$PROJECT_ROOT/README.md" "$BUNDLE_DIR/"
[ -f "$PROJECT_ROOT/PROJECT-OVERVIEW.md" ] && cp "$PROJECT_ROOT/PROJECT-OVERVIEW.md" "$BUNDLE_DIR/"
[ -f "$PROJECT_ROOT/THIIO-ONBOARDING.md" ] && cp "$PROJECT_ROOT/THIIO-ONBOARDING.md" "$BUNDLE_DIR/"
[ -f "$PROJECT_ROOT/CHANGELOG.md" ] && cp "$PROJECT_ROOT/CHANGELOG.md" "$BUNDLE_DIR/"

# Generate manifest file
echo -e "${YELLOW}Generating bundle manifest...${NC}"
cat > "$BUNDLE_DIR/MANIFEST.md" << 'EOF'
# Nexus COS THIIO Handoff Bundle

## Package Contents

This ZIP file contains the complete Nexus COS platform handoff to THIIO.

### Directory Structure

```
Nexus-COS-THIIO-FullHandoff/
├── docs/
│   └── THIIO-HANDOFF/
│       ├── architecture/        # Architecture documentation
│       ├── deployment/          # Deployment manifests and configs
│       ├── operations/          # Operational runbooks
│       ├── modules/             # Module descriptions (16 files)
│       └── services/            # Service descriptions (43 files)
├── repos/
│   └── nexus-cos-main/          # Full monorepo structure
├── services/                    # All 43 service implementations
├── modules/                     # All 16 module implementations
├── scripts/                     # Deployment and utility scripts
├── .github/
│   └── workflows/               # CI/CD workflows
├── README.md                    # Main README
├── PROJECT-OVERVIEW.md          # Project overview
├── THIIO-ONBOARDING.md          # Onboarding guide
├── CHANGELOG.md                 # Version history
├── package.json                 # Dependencies
└── MANIFEST.md                  # This file
```

## Quick Start

1. Extract this ZIP file
2. Read `THIIO-ONBOARDING.md` first
3. Review `docs/THIIO-HANDOFF/architecture/architecture-overview.md`
4. Follow deployment guide in `docs/THIIO-HANDOFF/deployment/`
5. Use scripts in `scripts/` for automation

## Services (43)

Complete list of all services with descriptions in `docs/THIIO-HANDOFF/services/`

## Modules (16)

Complete list of all modules with descriptions in `docs/THIIO-HANDOFF/modules/`

## Support

For questions or issues during handoff:
- Review operational runbooks in `docs/THIIO-HANDOFF/operations/`
- Check deployment manifest in `docs/THIIO-HANDOFF/deployment/`
- Refer to service/module documentation as needed

## Version Information

- Package Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
- Platform Version: 2.0.0
- Total Services: 43
- Total Modules: 16

EOF

# Create the ZIP file
echo -e "${YELLOW}Creating ZIP archive...${NC}"
cd "$DIST_DIR"
rm -f "$ZIP_FILE"
zip -r "$ZIP_FILE" "$BUNDLE_NAME" -q

# Calculate file size
FILE_SIZE=$(du -h "$ZIP_FILE" | cut -f1)

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Bundle Created Successfully!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "Location: ${GREEN}$ZIP_FILE${NC}"
echo -e "Size: ${GREEN}$FILE_SIZE${NC}"
echo ""
echo -e "Contents:"
echo -e "  - Architecture documentation"
echo -e "  - Deployment manifests"
echo -e "  - Operations runbooks"
echo -e "  - 43 service descriptions"
echo -e "  - 16 module descriptions"
echo -e "  - Full monorepo structure"
echo -e "  - CI/CD workflows"
echo -e "  - Deployment scripts"
echo ""
echo -e "${GREEN}Ready for THIIO handoff!${NC}"
echo ""

# Cleanup
rm -rf "$BUNDLE_DIR"

exit 0
