#!/bin/bash

# Nexus COS THIIO Handoff Package Builder
# This script generates the THIIO handoff ZIP bundle containing only the 23 core handoff files

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

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$PROJECT_ROOT/dist"
BUNDLE_NAME="Nexus-COS-THIIO-FullHandoff"
TEMP_DIR="$DIST_DIR/${BUNDLE_NAME}-temp"
ZIP_FILE="$DIST_DIR/$BUNDLE_NAME.zip"
MANIFEST_FILE="$DIST_DIR/${BUNDLE_NAME}-sample-manifest.json"

# List of 23 files to include in the handoff package
FILES_TO_INCLUDE=(
  "scripts/package-thiio-bundle.sh"
  "make_handoff_zip.ps1"
  ".github/workflows/bundle-thiio-handoff.yml"
  "docs/THIIO-HANDOFF/README.md"
  "docs/THIIO-HANDOFF/architecture/system-overview.md"
  "docs/THIIO-HANDOFF/architecture/service-map.md"
  "deployment-manifest.json"
  "docs/THIIO-HANDOFF/operations/runbook-daily-ops.md"
  "docs/THIIO-HANDOFF/operations/runbook-rollback.md"
  "docs/THIIO-HANDOFF/operations/runbook-monitoring.md"
  "docs/THIIO-HANDOFF/operations/runbook-performance.md"
  "docs/THIIO-HANDOFF/operations/runbook-failover.md"
  "docs/THIIO-HANDOFF/services/README.md"
  "docs/THIIO-HANDOFF/services/service-template.md"
  "docs/THIIO-HANDOFF/services/core-auth.md"
  "docs/THIIO-HANDOFF/modules/README.md"
  "docs/THIIO-HANDOFF/modules/module-template.md"
  "docs/THIIO-HANDOFF/frontend/vite-guide.md"
  "scripts/generate-k8s-configs.sh"
  "PROJECT-OVERVIEW.md"
  "THIIO-ONBOARDING.md"
  "CHANGELOG.md"
  "scripts/run-local"
)

# Create clean directories
echo -e "${YELLOW}Creating working directories...${NC}"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
mkdir -p "$DIST_DIR"

# Copy files preserving directory structure
echo -e "${YELLOW}Copying handoff files (23 files)...${NC}"
COPIED_COUNT=0
MISSING_COUNT=0

for file in "${FILES_TO_INCLUDE[@]}"; do
  SOURCE_FILE="$PROJECT_ROOT/$file"
  DEST_FILE="$TEMP_DIR/$file"
  
  if [ -f "$SOURCE_FILE" ]; then
    # Create destination directory
    mkdir -p "$(dirname "$DEST_FILE")"
    # Copy file
    cp "$SOURCE_FILE" "$DEST_FILE"
    echo -e "  ${GREEN}✓${NC} $file"
    COPIED_COUNT=$((COPIED_COUNT + 1))
  else
    echo -e "  ${RED}✗${NC} $file (not found)"
    MISSING_COUNT=$((MISSING_COUNT + 1))
  fi
done

echo ""
echo -e "${YELLOW}Files copied: ${GREEN}${COPIED_COUNT}${NC} / ${#FILES_TO_INCLUDE[@]}"
if [ $MISSING_COUNT -gt 0 ]; then
  echo -e "${YELLOW}Files missing: ${RED}${MISSING_COUNT}${NC}"
fi
echo ""

# Create the ZIP file
echo -e "${YELLOW}Creating ZIP archive...${NC}"
cd "$TEMP_DIR"
rm -f "$ZIP_FILE"
zip -r "$ZIP_FILE" . -q

# Calculate SHA256 and size
echo -e "${YELLOW}Computing ZIP metadata...${NC}"
SHA256=$(sha256sum "$ZIP_FILE" | awk '{print toupper($1)}')
# Try macOS stat first, fall back to Linux stat
if stat -f%z "$ZIP_FILE" 2>/dev/null >/dev/null; then
  SIZE_BYTES=$(stat -f%z "$ZIP_FILE")
else
  SIZE_BYTES=$(stat -c%s "$ZIP_FILE")
fi
FILE_SIZE_KB=$(echo "scale=2; $SIZE_BYTES / 1024" | bc)
GENERATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Generate manifest file
echo -e "${YELLOW}Generating manifest...${NC}"
cat > "$MANIFEST_FILE" <<EOF
{
  "path": "dist/$BUNDLE_NAME.zip",
  "sha256": "$SHA256",
  "size_bytes": $SIZE_BYTES,
  "generated_at": "$GENERATED_AT",
  "note": "ZIP reproduced from the 23 handoff files provided in this PR. This ZIP will differ from any earlier reported handoff ZIP that included large artifacts not present here."
}
EOF

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Bundle Created Successfully!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "Location: ${GREEN}$ZIP_FILE${NC}"
echo -e "Size: ${GREEN}${FILE_SIZE_KB} KB ($SIZE_BYTES bytes)${NC}"
echo -e "SHA256: ${GREEN}$SHA256${NC}"
echo -e "Manifest: ${GREEN}$MANIFEST_FILE${NC}"
echo -e "Files: ${GREEN}${COPIED_COUNT} / ${#FILES_TO_INCLUDE[@]}${NC}"
echo ""
echo -e "Contents:"
echo -e "  - Packaging scripts (2 files)"
echo -e "  - GitHub workflow (1 file)"
echo -e "  - Architecture docs (3 files)"
echo -e "  - Operations runbooks (5 files)"
echo -e "  - Services docs (3 files)"
echo -e "  - Modules docs (2 files)"
echo -e "  - Frontend guide (1 file)"
echo -e "  - Deployment scripts (2 files)"
echo -e "  - Root documentation (4 files)"
echo ""
echo -e "${GREEN}Ready for THIIO handoff!${NC}"
echo ""

# Cleanup temp directory
rm -rf "$TEMP_DIR"

exit 0
