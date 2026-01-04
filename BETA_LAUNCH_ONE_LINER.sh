#!/bin/bash
# ===============================
# Nexus COS Beta Launch - One-Liner Execution
# ===============================
# Quick deployment for TRAE Solo
# ===============================

set -e

echo "🚀 Nexus COS Beta Launch - Quick Deploy"
echo "========================================"
echo ""

# Step 1: Navigate to Nexus COS
cd /opt/nexus-cos || {
    echo "❌ ERROR: /opt/nexus-cos not found"
    echo "Clone the repository first:"
    echo "  sudo mkdir -p /opt"
    echo "  cd /opt"
    echo "  sudo git clone https://github.com/BobbyBlanco400/nexus-cos.git"
    exit 1
}

# Step 2: Pull latest changes
echo "📥 Pulling latest changes..."
git pull origin main

# Step 3: Make scripts executable
echo "🔧 Setting up scripts..."
chmod +x nexus-cos-vps-deployment.sh
chmod +x nexus-cos-vps-validation.sh

# Step 4: Run deployment
echo "🚀 Running deployment..."
./nexus-cos-vps-deployment.sh

# Step 5: Run validation
echo "✅ Running validation..."
./nexus-cos-vps-validation.sh

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                 🎉 BETA LAUNCH COMPLETE 🎉                     ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║                                                                ║"
echo "║  Nexus COS is now deployed and validated                      ║"
echo "║                                                                ║"
echo "║  🌐 Access Points:                                             ║"
echo "║     Apex: https://n3xuscos.online                             ║"
echo "║     Beta: https://beta.n3xuscos.online                        ║"
echo "║     API:  https://n3xuscos.online/api                         ║"
echo "║                                                                ║"
echo "║  📖 Full documentation:                                        ║"
echo "║     TRAE_SOLO_BETA_LAUNCH_HANDOFF.md                          ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

exit 0
