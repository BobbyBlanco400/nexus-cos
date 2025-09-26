#!/bin/bash

# 🚀 Nexus COS Snapshot Creator
# Creates a complete deployment-ready snapshot for TRAE Solo

set -e

echo "🔥 Creating Nexus COS Final Snapshot..."
echo "========================================"

# Define the snapshot name
SNAPSHOT_NAME="nexus-cos-final-snapshot"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
SNAPSHOT_DIR="/tmp/${SNAPSHOT_NAME}"
SNAPSHOT_ZIP="${SNAPSHOT_NAME}.zip"

# Clean up any existing snapshot
rm -rf "$SNAPSHOT_DIR" "$SNAPSHOT_ZIP"

echo "📂 Creating snapshot directory: $SNAPSHOT_DIR"
mkdir -p "$SNAPSHOT_DIR"

echo "📋 Copying essential project files..."

# Copy core configuration files
cp -v package.json "$SNAPSHOT_DIR/"
cp -v package-lock.json "$SNAPSHOT_DIR/" 2>/dev/null || echo "No package-lock.json found"
cp -v trae-solo.yaml "$SNAPSHOT_DIR/"
cp -v docker-compose.yml "$SNAPSHOT_DIR/"
cp -v docker-compose.prod.yml "$SNAPSHOT_DIR/"
cp -v vite.config.js "$SNAPSHOT_DIR/"
cp -v .gitignore "$SNAPSHOT_DIR/"

# Copy documentation
cp -v README.md "$SNAPSHOT_DIR/"
cp -v DEPLOYMENT_COMPLETE.md "$SNAPSHOT_DIR/"
cp -v NEXUS_COS_EXTENDED_COMPLETE.md "$SNAPSHOT_DIR/"
cp -v MIGRATION_SUMMARY.md "$SNAPSHOT_DIR/"
cp -v TRAE_SOLO_DEPLOYMENT_GUIDE.md "$SNAPSHOT_DIR/"

# Copy deployment scripts
echo "🚀 Copying deployment scripts..."
cp -v master-fix-trae-solo.sh "$SNAPSHOT_DIR/"
cp -v quick-launch.sh "$SNAPSHOT_DIR/"
cp -v deploy_nexus_cos.sh "$SNAPSHOT_DIR/"
cp -v health-check.sh "$SNAPSHOT_DIR/"
cp -v nexus_cos_copilot_build.sh "$SNAPSHOT_DIR/"

# Copy essential directories (excluding node_modules, .venv, etc.)
echo "📁 Copying essential directories..."

# Frontend
echo "Copying frontend..."
mkdir -p "$SNAPSHOT_DIR/frontend"
rsync -av --exclude='node_modules' --exclude='dist' --exclude='.vite' \
    frontend/ "$SNAPSHOT_DIR/frontend/"

# Backend
echo "Copying backend..."
mkdir -p "$SNAPSHOT_DIR/backend"
rsync -av --exclude='node_modules' --exclude='.venv' --exclude='__pycache__' \
    backend/ "$SNAPSHOT_DIR/backend/"

# Creator Hub
echo "Copying creator-hub..."
mkdir -p "$SNAPSHOT_DIR/creator-hub"
rsync -av --exclude='node_modules' --exclude='dist' \
    creator-hub/ "$SNAPSHOT_DIR/creator-hub/"

# Admin
echo "Copying admin..."
mkdir -p "$SNAPSHOT_DIR/admin"
rsync -av --exclude='node_modules' --exclude='dist' \
    admin/ "$SNAPSHOT_DIR/admin/"

# Mobile
echo "Copying mobile..."
mkdir -p "$SNAPSHOT_DIR/mobile"
rsync -av --exclude='node_modules' --exclude='builds' \
    mobile/ "$SNAPSHOT_DIR/mobile/"

# Extended modules
echo "Copying extended modules..."
mkdir -p "$SNAPSHOT_DIR/extended"
rsync -av --exclude='node_modules' --exclude='dist' \
    extended/ "$SNAPSHOT_DIR/extended/"

# Deployment and infrastructure
echo "Copying deployment configuration..."
cp -rv deployment "$SNAPSHOT_DIR/" 2>/dev/null || echo "No deployment directory found"
cp -rv .trae "$SNAPSHOT_DIR/" 2>/dev/null || echo "No .trae directory found"
cp -rv .github "$SNAPSHOT_DIR/" 2>/dev/null || echo "No .github directory found"

# Scripts
echo "Copying scripts..."
cp -rv scripts "$SNAPSHOT_DIR/" 2>/dev/null || echo "No scripts directory found"

# Additional configuration files
cp -v server.js "$SNAPSHOT_DIR/" 2>/dev/null || echo "No server.js found"
cp -v App.js "$SNAPSHOT_DIR/" 2>/dev/null || echo "No App.js found"

echo "📦 Creating ZIP archive..."
cd /tmp
zip -q -r "$SNAPSHOT_ZIP" "$SNAPSHOT_NAME"

# Move to project root
mv "$SNAPSHOT_ZIP" /home/runner/work/nexus-cos/nexus-cos/

echo "✅ Snapshot created successfully!"
echo "📍 Location: /home/runner/work/nexus-cos/nexus-cos/$SNAPSHOT_ZIP"
echo "📊 Size: $(du -sh /home/runner/work/nexus-cos/nexus-cos/$SNAPSHOT_ZIP | cut -f1)"
echo ""
echo "🔗 This snapshot can be uploaded to:"
echo "   • GitHub Releases"
echo "   • Google Drive"
echo "   • Dropbox"
echo "   • OneDrive"
echo ""
echo "📋 Contents:"
ls -la "$SNAPSHOT_DIR" | head -20

# Clean up temp directory
rm -rf "$SNAPSHOT_DIR"

echo "🎉 Nexus COS Final Snapshot Ready!"