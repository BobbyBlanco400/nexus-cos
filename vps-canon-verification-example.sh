#!/bin/bash
# VPS Canon-Verification Workflow - Example Script
# This script demonstrates the atomic one-line deployment workflow

set -e  # Exit on any error

# Configuration - Update these paths for your environment
REPO_DIR="${REPO_DIR:-$(pwd)}"
LOGO_SOURCE="${LOGO_SOURCE:-$HOME/Downloads/Official logo.svg}"
CANON_LOGO_PATH="branding/official/N3XUS-vCOS.svg"
CANON_CONFIG="canon-verifier/config/canon_assets.json"

echo "=================================================="
echo "N3XUS COS VPS Canon-Verification & Launch Workflow"
echo "=================================================="
echo ""
echo "Repository: $REPO_DIR"
echo "Logo Source: $LOGO_SOURCE"
echo "Canonical Path: $CANON_LOGO_PATH"
echo ""

# Step 1: Navigate to repository
echo "Step 1: Navigate to repository..."
cd "$REPO_DIR" || exit 1
echo "✓ In directory: $(pwd)"
echo ""

# Step 2: Create canonical branding directory
echo "Step 2: Create canonical branding directory..."
mkdir -p branding/official
echo "✓ Directory created: branding/official/"
echo ""

# Step 3: Copy official logo
echo "Step 3: Copy official logo..."
if [ -f "$LOGO_SOURCE" ]; then
    cp "$LOGO_SOURCE" "$CANON_LOGO_PATH"
    echo "✓ Logo copied from: $LOGO_SOURCE"
else
    echo "⚠ Warning: Logo source not found at: $LOGO_SOURCE"
    echo "  Using existing logo at: $CANON_LOGO_PATH"
    if [ ! -f "$CANON_LOGO_PATH" ]; then
        echo "✗ Error: No logo available"
        exit 1
    fi
fi
echo ""

# Step 4: Verify logo exists
echo "Step 4: Verify logo exists..."
if [ ! -f "$CANON_LOGO_PATH" ]; then
    echo "✗ Canonization failed — logo missing"
    exit 1
fi

# Get file size (cross-platform)
if stat -f%z "$CANON_LOGO_PATH" 2>/dev/null; then
    LOGO_SIZE=$(stat -f%z "$CANON_LOGO_PATH" 2>/dev/null)
elif stat -c%s "$CANON_LOGO_PATH" 2>/dev/null; then
    LOGO_SIZE=$(stat -c%s "$CANON_LOGO_PATH" 2>/dev/null)
else
    echo "✗ Error: Unable to determine file size"
    exit 1
fi

echo "✓ Logo verified: $CANON_LOGO_PATH ($LOGO_SIZE bytes)"
echo ""

# Step 5: Update canon-verifier configuration
echo "Step 5: Update canon-verifier configuration..."
mkdir -p "$(dirname "$CANON_CONFIG")"

# Initialize config if it doesn't exist
if [ ! -f "$CANON_CONFIG" ]; then
    echo '{}' > "$CANON_CONFIG"
    echo "✓ Initialized config file: $CANON_CONFIG"
fi

# Update logo path using jq
if [ ! -d "$(dirname "$CANON_LOGO_PATH")" ]; then
    echo "✗ Error: Logo directory does not exist: $(dirname "$CANON_LOGO_PATH")"
    exit 1
fi

ABSOLUTE_LOGO_PATH="$(cd "$(dirname "$CANON_LOGO_PATH")" && pwd)/$(basename "$CANON_LOGO_PATH")"
if [ -z "$ABSOLUTE_LOGO_PATH" ]; then
    echo "✗ Error: Failed to determine absolute logo path"
    exit 1
fi

jq --arg logo "$ABSOLUTE_LOGO_PATH" '.OfficialLogo = $logo' "$CANON_CONFIG" > "$CANON_CONFIG.tmp"
mv "$CANON_CONFIG.tmp" "$CANON_CONFIG"
echo "✓ Configuration updated with logo path"
echo ""

# Step 6: Create timestamped logging folder
echo "Step 6: Create timestamped logging folder..."
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="canon-verifier/logs/run_$TIMESTAMP"
mkdir -p "$LOG_DIR"
export CANON_LOG_DIR="$LOG_DIR"
echo "✓ Log directory: $LOG_DIR"
echo ""

# Step 7: Run canon-verifier harness
echo "Step 7: Run full canon-verifier harness..."
echo "=================================================="
python3 canon-verifier/trae_go_nogo.py
VERIFIER_EXIT=$?
echo "=================================================="
echo ""

# Step 8: Check verification result
if [ $VERIFIER_EXIT -ne 0 ]; then
    echo "✗ NO-GO: Verification failed"
    echo "  Check logs at: $LOG_DIR"
    exit 1
fi

echo "✓ Verification PASSED"
echo ""

# Step 9: Launch services (optional - can be commented out for testing)
echo "Step 9: Launch services..."
echo ""

# Check if PM2 is available
if command -v pm2 &> /dev/null; then
    echo "  Launching PM2 services..."
    # Uncomment the line below to actually start services
    # pm2 start ecosystem.config.js --only n3xus-platform
    echo "  ⚠ PM2 launch skipped (uncomment in script to enable)"
else
    echo "  ⚠ PM2 not found - skipping PM2 launch"
fi
echo ""

# Check if docker-compose is available
if command -v docker-compose &> /dev/null; then
    echo "  Launching Docker services..."
    # Uncomment the line below to actually start services
    # docker-compose -f docker-compose.yml up -d
    echo "  ⚠ Docker launch skipped (uncomment in script to enable)"
else
    echo "  ⚠ docker-compose not found - skipping Docker launch"
fi
echo ""

# Step 10: Final confirmation
echo "=================================================="
echo "GO: Official logo canonized, verification passed"
echo "    N3XUS COS ready for launch"
echo "    Logs saved to: $LOG_DIR"
echo "=================================================="
echo ""
echo "Next steps:"
echo "  1. Review logs: cat $LOG_DIR/verification.log"
echo "  2. Check report: cat $LOG_DIR/verification_report.json"
echo "  3. Start services manually if needed"
echo ""
