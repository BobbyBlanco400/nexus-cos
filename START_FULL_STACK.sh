#!/bin/bash
# =================================================================
# N3XUS v-COS | FULL STACK ACTIVATION (PHASES 1-12)
# =================================================================

echo "🚀 INITIATING FULL STACK LAUNCH SEQUENCE..."

# 1. Stop Conflicting Services
# 'casino-federation' script binds port 3000, which belongs to the Main App
echo "🛑 Resolving Port 3000 Conflict..."
pm2 stop casino-federation 2>/dev/null || true

# 2. Activate Core Ecosystem (Backend, V-Suite, Creator Hub, PuaboVerse)
echo "🌍 Starting Ecosystem Services (Phase 1-10)..."
pm2 start ecosystem.config.js --update-env

# 3. Activate Main Platform (Nexus App / Auth / API Gateway) on Port 3000
echo "⚡ Starting Main Nexus Platform (Port 3000)..."
pm2 start server.js --name nexus-app --update-env

# 4. Ensure Casino Federation Services (Phase 11) are Running
echo "🎰 Verifying Casino Federation Services..."
pm2 start casino-nexus-api --update-env 2>/dev/null || true
pm2 start nexcoin-ms --update-env 2>/dev/null || true
pm2 start nft-marketplace-ms --update-env 2>/dev/null || true
pm2 start skill-games-ms --update-env 2>/dev/null || true
pm2 start rewards-ms --update-env 2>/dev/null || true
pm2 start vr-world-ms --update-env 2>/dev/null || true

# 5. Save State
echo "💾 Saving Process State..."
pm2 save

echo "✅ FULL STACK ACTIVATION COMPLETE."
echo "📊 SYSTEM STATUS:"
pm2 status | grep -E "nexus-app|creator-hub|v-suite|puaboverse|vr-world"
