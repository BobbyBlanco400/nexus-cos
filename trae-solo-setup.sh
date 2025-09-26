#!/bin/bash

# 🤖 TRAE SOLO - Nexus COS Automated Setup Script
# For rapid deployment to workspace: c:\Users\wecon\Downloads\nexus-cos-main

set -e

echo "🤖 TRAE SOLO - Nexus COS Setup"
echo "=============================="
echo "Target: c:/Users/wecon/Downloads/nexus-cos-main"
echo ""

# Define paths (Windows-style for TRAE SOLO)
WORKSPACE="c:/Users/wecon/Downloads"
TARGET_DIR="$WORKSPACE/nexus-cos-main"
DOWNLOAD_URL="https://github.com/BobbyBlanco400/nexus-cos/archive/refs/heads/main.zip"

echo "🌐 Downloading Nexus COS from GitHub..."
cd "$WORKSPACE"

# Download the latest version
curl -L "$DOWNLOAD_URL" -o nexus-cos-main.zip

echo "📦 Extracting archive..."
unzip -q nexus-cos-main.zip

# Rename to expected directory structure
if [ -d "nexus-cos-main" ]; then
    rm -rf nexus-cos  # Remove old version if exists
    mv nexus-cos-main nexus-cos
else
    echo "❌ Extraction failed - directory not found"
    exit 1
fi

cd nexus-cos

echo "📋 Installing dependencies..."
npm install

echo "🔧 Setting up Git LFS (if needed)..."
if command -v git >/dev/null 2>&1; then
    git lfs install 2>/dev/null || echo "Git LFS not required"
fi

echo "🚀 Making deployment scripts executable..."
chmod +x *.sh

echo "✅ Setup Complete!"
echo ""
echo "📍 Project Location: $TARGET_DIR/nexus-cos"
echo "🚀 Ready for deployment!"
echo ""
echo "📋 Next Steps:"
echo "   1. cd nexus-cos"
echo "   2. ./master-fix-trae-solo.sh    # Full deployment"
echo "   3. ./quick-launch.sh           # Quick launch"
echo ""
echo "🌐 Expected URLs after deployment:"
echo "   • https://nexuscos.online"
echo "   • http://localhost:3000/health"
echo "   • http://localhost:3001/health"
echo ""
echo "🎯 Ready for TRAE SOLO orchestration!"