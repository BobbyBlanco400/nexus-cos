#!/bin/bash
###############################################################################
# Setup Legal Docs for Nexus COS
# Purpose: Install legal documents scaffold to deployment location
# Usage: ./setup_legal_docs.sh [destination]
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default destination
DEFAULT_DEST="/opt/nexus-cos/legal"
DEST="${1:-$DEFAULT_DEST}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Nexus COS Legal Documents Setup Script             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    print_error "Source directory not found: $SOURCE_DIR"
    exit 1
fi

echo "Source directory: $SOURCE_DIR"
echo "Destination directory: $DEST"
echo ""

# Create destination directory if it doesn't exist
echo "Creating destination directory..."
if mkdir -p "$DEST"; then
    print_status "Destination directory created/verified"
else
    print_error "Failed to create destination directory"
    exit 1
fi

# Copy legal docs
echo ""
echo "Copying legal documents..."

# Copy holding company docs
if [ -d "$SOURCE_DIR/holding_company" ]; then
    mkdir -p "$DEST/holding_company"
    cp -r "$SOURCE_DIR/holding_company"/* "$DEST/holding_company/" 2>/dev/null || true
    print_status "Copied holding company documents"
else
    print_warning "Holding company directory not found"
fi

# Copy nexus_cos_core docs
if [ -d "$SOURCE_DIR/nexus_cos_core" ]; then
    mkdir -p "$DEST/nexus_cos_core"
    cp -r "$SOURCE_DIR/nexus_cos_core"/* "$DEST/nexus_cos_core/" 2>/dev/null || true
    print_status "Copied Nexus COS core documents"
else
    print_warning "Nexus COS core directory not found"
fi

# Copy modules_legal docs
if [ -d "$SOURCE_DIR/modules_legal" ]; then
    mkdir -p "$DEST/modules_legal"
    cp -r "$SOURCE_DIR/modules_legal"/* "$DEST/modules_legal/" 2>/dev/null || true
    print_status "Copied module legal documents"
else
    print_warning "Modules legal directory not found"
fi

# Copy compliance docs
if [ -d "$SOURCE_DIR/compliance" ]; then
    mkdir -p "$DEST/compliance"
    cp -r "$SOURCE_DIR/compliance"/* "$DEST/compliance/" 2>/dev/null || true
    print_status "Copied compliance documents"
else
    print_warning "Compliance directory not found"
fi

# Copy scripts
if [ -d "$SOURCE_DIR/scripts" ]; then
    mkdir -p "$DEST/scripts"
    cp -r "$SOURCE_DIR/scripts"/* "$DEST/scripts/" 2>/dev/null || true
    chmod +x "$DEST/scripts"/*.sh 2>/dev/null || true
    print_status "Copied scripts and set execute permissions"
else
    print_warning "Scripts directory not found"
fi

# Copy README
if [ -f "$SOURCE_DIR/README.md" ]; then
    cp "$SOURCE_DIR/README.md" "$DEST/"
    print_status "Copied README"
else
    print_warning "README.md not found"
fi

# Set appropriate permissions
echo ""
echo "Setting permissions..."

# Check if running as root or if we can use sudo
if [ "$EUID" -eq 0 ]; then
    # Running as root
    if id "nexususer" &>/dev/null; then
        chown -R nexususer:nexusgroup "$DEST" 2>/dev/null || chown -R nexususer:nexususer "$DEST" 2>/dev/null || true
        print_status "Set ownership to nexususer"
    else
        print_warning "nexususer not found, skipping ownership change"
    fi
    chmod -R 750 "$DEST"
    print_status "Set directory permissions to 750"
    chmod -R 640 "$DEST"/**/*.md 2>/dev/null || true
    print_status "Set file permissions to 640"
else
    # Not running as root
    chmod -R u+rw,g+r,o-rwx "$DEST" 2>/dev/null || true
    print_status "Set permissions (limited, not running as root)"
fi

# Count documents
echo ""
echo "Counting installed documents..."
MD_COUNT=$(find "$DEST" -name "*.md" -type f | wc -l)
DOCX_COUNT=$(find "$DEST" -name "*.docx" -type f | wc -l)
SCRIPT_COUNT=$(find "$DEST/scripts" -name "*.sh" -type f 2>/dev/null | wc -l)

print_status "Markdown documents: $MD_COUNT"
print_status "DOCX placeholders: $DOCX_COUNT"
print_status "Scripts: $SCRIPT_COUNT"

# Summary
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Legal Docs Setup Complete!                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Location: $DEST"
echo ""
echo "Next Steps:"
echo "  1. Review and customize documents with your entity details"
echo "  2. Run validation: $DEST/scripts/validate_legal_docs.sh"
echo "  3. Convert .md files to .docx for legal review"
echo "  4. Have legal counsel review all documents"
echo "  5. Publish finalized documents on your website/apps"
echo ""
echo "Structure installed:"
echo "  ├── holding_company/     (Corporate documents)"
echo "  ├── nexus_cos_core/      (Platform legal terms)"
echo "  ├── modules_legal/       (Module-specific terms)"
echo "  ├── compliance/          (Compliance policies)"
echo "  ├── scripts/             (Utility scripts)"
echo "  └── README.md            (Documentation)"
echo ""

exit 0
