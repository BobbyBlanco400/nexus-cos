#!/usr/bin/env bash
# N3XUS v-COS Logo Deployment Verification Script
# Verifies that all logo files are properly deployed and match the canonical source

set -e

echo "🔍 N3XUS v-COS Logo Deployment Verification"
echo "============================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Canonical source
CANONICAL_LOGO="branding/official/N3XUS-vCOS.png"

# Check if canonical logo exists
if [ ! -f "$CANONICAL_LOGO" ]; then
    echo -e "${RED}❌ FATAL: Canonical logo not found at $CANONICAL_LOGO${NC}"
    echo "   This is a critical N3XUS LAW violation!"
    exit 1
fi

echo -e "${GREEN}✅ Canonical logo found: $CANONICAL_LOGO${NC}"

# Get canonical logo info
CANONICAL_SIZE=$(stat -f%z "$CANONICAL_LOGO" 2>/dev/null || stat -c%s "$CANONICAL_LOGO" 2>/dev/null || echo "unknown")
CANONICAL_MD5=$(md5sum "$CANONICAL_LOGO" 2>/dev/null | awk '{print $1}' || md5 -q "$CANONICAL_LOGO" 2>/dev/null || echo "unknown")

if [ "$CANONICAL_SIZE" = "unknown" ]; then
    echo "   Size: Unable to determine"
else
    # Try to format size nicely, fallback to raw bytes
    FORMATTED_SIZE=$(numfmt --to=iec-i --suffix=B "$CANONICAL_SIZE" 2>/dev/null || echo "${CANONICAL_SIZE} bytes")
    echo "   Size: $FORMATTED_SIZE"
fi

echo "   MD5: $CANONICAL_MD5"
echo ""

# Exit if we couldn't get MD5
if [ "$CANONICAL_MD5" = "unknown" ]; then
    echo -e "${RED}❌ FATAL: Could not calculate MD5 checksum${NC}"
    echo "   Please ensure md5sum or md5 command is available"
    exit 1
fi

# Define all deployment targets
declare -a TARGETS=(
    "branding/logo.png"
    "frontend/public/assets/branding/logo.png"
    "admin/public/assets/branding/logo.png"
    "creator-hub/public/assets/branding/logo.png"
)

# Verify each target
echo "📋 Verifying deployment targets..."
echo ""

VERIFIED=0
MISSING=0
MISMATCH=0

for TARGET in "${TARGETS[@]}"; do
    if [ ! -f "$TARGET" ]; then
        echo -e "${RED}❌ MISSING: $TARGET${NC}"
        MISSING=$((MISSING + 1))
    else
        TARGET_MD5=$(md5sum "$TARGET" 2>/dev/null | awk '{print $1}' || md5 -q "$TARGET" 2>/dev/null || echo "unknown")
        
        if [ "$TARGET_MD5" = "unknown" ]; then
            echo -e "${YELLOW}⚠️  CANNOT VERIFY: $TARGET${NC}"
            echo "   Could not calculate MD5 checksum"
            MISMATCH=$((MISMATCH + 1))
        elif [ "$TARGET_MD5" = "$CANONICAL_MD5" ]; then
            echo -e "${GREEN}✅ VERIFIED: $TARGET${NC}"
            VERIFIED=$((VERIFIED + 1))
        else
            echo -e "${YELLOW}⚠️  MISMATCH: $TARGET${NC}"
            echo "   Expected MD5: $CANONICAL_MD5"
            echo "   Actual MD5:   $TARGET_MD5"
            MISMATCH=$((MISMATCH + 1))
        fi
    fi
done

echo ""
echo "============================================"
echo "📊 Verification Summary:"
echo "   ✅ Verified:  $VERIFIED / ${#TARGETS[@]}"
echo "   ❌ Missing:   $MISSING"
echo "   ⚠️  Mismatch: $MISMATCH"
echo "============================================"
echo ""

# Overall status
if [ $MISSING -eq 0 ] && [ $MISMATCH -eq 0 ]; then
    echo -e "${GREEN}🎉 All logos verified successfully!${NC}"
    echo "   N3XUS LAW compliant - Holographic deployment active"
    echo ""
    
    # Run bootstrap check if available
    if [ -f "scripts/bootstrap.sh" ]; then
        echo "Running bootstrap verification..."
        echo ""
        # Capture output once and check for logo verification
        BOOTSTRAP_OUTPUT=$(bash scripts/bootstrap.sh 2>&1)
        if echo "$BOOTSTRAP_OUTPUT" | grep -q "Official logo verified"; then
            echo "$BOOTSTRAP_OUTPUT" | grep -A2 "Official logo" | head -3 || true
        else
            echo "⚠️  Bootstrap script did not verify logo as expected"
        fi
    fi
    
    exit 0
else
    echo -e "${RED}❌ Verification failed!${NC}"
    
    if [ $MISSING -gt 0 ]; then
        echo "   Some logo files are missing."
    fi
    
    if [ $MISMATCH -gt 0 ]; then
        echo "   Some logo files don't match the canonical source."
    fi
    
    echo ""
    echo "To fix this, run:"
    echo "   bash scripts/deploy-holographic-logo.sh"
    echo ""
    
    exit 1
fi
