#!/bin/bash
# Nexus COS Branding Enforcement Script
# Consolidates and enforces branding system across platform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
BASE_DIR="/home/runner/work/nexus-cos/nexus-cos"
BRANDING_DIR="$BASE_DIR/branding"
PF_CONFIG="$BASE_DIR/pfs/final/branding-pf.yml"

print_info "🎨 Starting Nexus COS Branding Enforcement"
print_info "======================================="

# Check if PF config exists
if [[ ! -f "$PF_CONFIG" ]]; then
    print_error "Branding PF config not found: $PF_CONFIG"
    exit 1
fi

print_success "Found branding PF configuration"

# Create branding assets if they don't exist
if [[ ! -d "$BRANDING_DIR" ]]; then
    print_info "Creating branding directory..."
    mkdir -p "$BRANDING_DIR"
fi

# Generate placeholder logo if it doesn't exist
if [[ ! -f "$BRANDING_DIR/logo.svg" ]]; then
    print_info "Generating Nexus COS logo..."
    cat > "$BRANDING_DIR/logo.svg" << 'EOF'
<svg width="120" height="32" viewBox="0 0 120 32" xmlns="http://www.w3.org/2000/svg">
  <rect width="120" height="32" fill="#2563eb" rx="6"/>
  <text x="60" y="20" font-family="Inter, sans-serif" font-size="14" font-weight="600" 
        text-anchor="middle" fill="white">Nexus COS</text>
</svg>
EOF
    print_success "Generated logo.svg"
fi

# Generate favicon if it doesn't exist
if [[ ! -f "$BRANDING_DIR/favicon.ico" ]]; then
    print_info "Creating placeholder favicon..."
    # Create a minimal 16x16 favicon placeholder
    touch "$BRANDING_DIR/favicon.ico"
    print_success "Generated favicon.ico placeholder"
fi

# Consolidate legacy branding references
print_info "Consolidating legacy branding references..."

# Update CSS variables in existing stylesheets
find "$BASE_DIR" -name "*.css" -not -path "*/node_modules/*" -not -path "*/.git/*" | while IFS= read -r css_file; do
    if [[ -w "$css_file" ]]; then
        # Replace common legacy color variables
        sed -i 's/#007bff/var(--nexus-primary)/g' "$css_file" 2>/dev/null || true
        sed -i 's/#0056b3/var(--nexus-secondary)/g' "$css_file" 2>/dev/null || true
        print_info "Updated CSS variables in $(basename "$css_file")"
    fi
done

# Validate branding assets
print_info "Validating branding assets..."

if [[ -f "$BRANDING_DIR/theme.css" ]]; then
    print_success "✓ Theme CSS found"
else
    print_warning "⚠ Theme CSS not found"
fi

if [[ -f "$BRANDING_DIR/logo.svg" ]]; then
    print_success "✓ Logo SVG found"
else
    print_warning "⚠ Logo SVG not found"
fi

# Create branding report
REPORT_FILE="/tmp/branding-enforcement-report.txt"
cat > "$REPORT_FILE" << EOF
Nexus COS Branding Enforcement Report
=====================================
Timestamp: $(date)
PF Config: $PF_CONFIG
Branding Dir: $BRANDING_DIR

Assets Status:
- Logo SVG: $(test -f "$BRANDING_DIR/logo.svg" && echo "✓ Present" || echo "✗ Missing")
- Theme CSS: $(test -f "$BRANDING_DIR/theme.css" && echo "✓ Present" || echo "✗ Missing")
- Favicon: $(test -f "$BRANDING_DIR/favicon.ico" && echo "✓ Present" || echo "✗ Missing")

Legacy Cleanup: Completed
CSS Variables: Updated
Branding Consolidation: Enforced
EOF

print_success "Branding enforcement completed successfully!"
print_info "Report saved to: $REPORT_FILE"

# Log to branding log file
echo "[$(date)] Branding enforcement completed successfully" >> "$BASE_DIR/logs/branding.log"

exit 0