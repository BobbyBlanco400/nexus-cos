#!/usr/bin/env bash
# N3XUS v-COS Holographic Logo Deployment
# Propagates canonical PNG logo to all application surfaces

set -e

echo "🎨 N3XUS v-COS Holographic Logo Deployment"
echo "============================================"
echo ""

# Define canonical source
CANONICAL_LOGO="branding/official/N3XUS-vCOS.png"

# Verify canonical logo exists
if [ ! -f "$CANONICAL_LOGO" ]; then
    echo "❌ FATAL: Canonical logo not found at $CANONICAL_LOGO"
    echo "   Cannot proceed with deployment"
    exit 1
fi

echo "✅ Canonical logo verified: $CANONICAL_LOGO"
echo ""

# Define deployment targets
declare -a TARGETS=(
    "branding/logo.png"
    "admin/public/assets/branding/logo.png"
    "creator-hub/public/assets/branding/logo.png"
    "frontend/public/assets/branding/logo.png"
)

# Deploy to all targets
echo "📦 Deploying logo to all surfaces..."
echo ""

DEPLOYED=0
SKIPPED=0
FAILED=0

for TARGET in "${TARGETS[@]}"; do
    # Create directory if it doesn't exist
    TARGET_DIR=$(dirname "$TARGET")
    if [ ! -d "$TARGET_DIR" ]; then
        echo "   📁 Creating directory: $TARGET_DIR"
        mkdir -p "$TARGET_DIR"
    fi
    
    # Copy logo to target
    if cp "$CANONICAL_LOGO" "$TARGET"; then
        echo "   ✅ Deployed: $TARGET"
        DEPLOYED=$((DEPLOYED + 1))
    else
        echo "   ❌ Failed: $TARGET"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "============================================"
echo "📊 Deployment Summary:"
echo "   ✅ Deployed: $DEPLOYED"
echo "   ⏭️  Skipped: $SKIPPED"
echo "   ❌ Failed: $FAILED"
echo ""

if [ $FAILED -gt 0 ]; then
    echo "⚠️  Some deployments failed. Please check errors above."
    exit 1
fi

echo "🎉 Holographic logo deployment complete!"
echo "   All application surfaces now use canonical branding."
echo ""
echo "ℹ️  To update branding in the future:"
echo "   1. Replace: $CANONICAL_LOGO"
echo "   2. Run: bash scripts/deploy-holographic-logo.sh"
echo "   3. All surfaces will automatically update"
