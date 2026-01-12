#!/bin/bash

# N3XUS v-COS Logo Deployment Script
# Syncs the holographic logo to all branding locations

echo "🎨 N3XUS v-COS Holographic Logo Deployment"
echo "=========================================="

SOURCE_LOGO="assets/svg/logo.svg"
DESTINATIONS=(
    "branding/logo.svg"
    "admin/public/assets/branding/logo.svg"
    "creator-hub/public/assets/branding/logo.svg"
    "frontend/public/assets/branding/logo.svg"
)

# Check if source exists
if [ ! -f "$SOURCE_LOGO" ]; then
    echo "❌ Error: Source logo not found at $SOURCE_LOGO"
    exit 1
fi

echo "📦 Source logo: $SOURCE_LOGO"
echo ""

# Deploy to each destination
DEPLOYED=0
FAILED=0

for dest in "${DESTINATIONS[@]}"; do
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"
    
    # Copy logo
    if cp "$SOURCE_LOGO" "$dest"; then
        echo "✅ Deployed to: $dest"
        ((DEPLOYED++))
    else
        echo "❌ Failed to deploy to: $dest"
        ((FAILED++))
    fi
done

echo ""
echo "=========================================="
echo "📊 Deployment Summary:"
echo "   ✅ Successful: $DEPLOYED"
echo "   ❌ Failed: $FAILED"
echo "=========================================="

if [ $FAILED -eq 0 ]; then
    echo "🎉 All logos deployed successfully!"
    exit 0
else
    echo "⚠️  Some deployments failed. Please check the errors above."
    exit 1
fi
