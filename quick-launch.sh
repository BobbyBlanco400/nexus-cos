#!/bin/bash
# TRAE Solo Quick Launch Script
# Simple wrapper for easy deployment

set -e

echo "🚀 TRAE Solo - Nexus COS Quick Launch"
echo "====================================="

# Configuration check
if [ -z "$DEPLOY_PATH" ]; then
    export DEPLOY_PATH="/opt/nexus-cos"
fi

# Ensure we have the repository
if [ ! -d "$DEPLOY_PATH" ]; then
    echo "📥 Cloning Nexus COS repository..."
    mkdir -p /opt
    cd /opt
    git clone https://github.com/BobbyBlanco400/nexus-cos.git nexus-cos
fi

# Navigate to deployment directory
cd "$DEPLOY_PATH"

# Run the master fix script
echo "🔄 Running Master Fix Script..."
if [ -f "master-fix-trae-solo.sh" ]; then
    ./master-fix-trae-solo.sh
else
    echo "❌ Master fix script not found. Please ensure the repository is properly cloned."
    exit 1
fi

echo "✅ TRAE Solo deployment completed!"