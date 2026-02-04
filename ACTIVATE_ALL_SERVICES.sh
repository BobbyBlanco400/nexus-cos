#!/bin/bash
# =================================================================
# N3XUS v-COS | ACTIVATE ALL SERVICES (PHASE 1-12)
# =================================================================

echo "🚀 INITIATING GLOBAL SERVICE ACTIVATION..."

# 1. Activate Main Ecosystem (Phase 1-10)
# This handles Backend, AI, Streaming, Creator Hub, V-Suite
echo "🌍 Starting Core Ecosystem..."
pm2 start ecosystem.config.js --update-env

# 2. Activate Casino Federation (Phase 11)
# These are independent microservices
echo "🎰 Starting Casino Federation Services..."
pm2 start modules/casino-nexus/services/casino-nexus-api/index.js --name casino-nexus-api --update-env 2>/dev/null || true
pm2 start modules/casino-nexus/services/nexcoin-ms/index.js --name nexcoin-ms --update-env 2>/dev/null || true
pm2 start modules/casino-nexus/services/nft-marketplace-ms/index.js --name nft-marketplace-ms --update-env 2>/dev/null || true
pm2 start modules/casino-nexus/services/rewards-ms/index.js --name rewards-ms --update-env 2>/dev/null || true
pm2 start modules/casino-nexus/services/skill-games-ms/index.js --name skill-games-ms --update-env 2>/dev/null || true
pm2 start modules/casino-nexus/services/vr-world-ms/index.js --name vr-world-ms --update-env 2>/dev/null || true

# 3. Cleanup & Save
echo "🧹 Cleaning up ghosts and saving state..."
pm2 save

echo "✅ ALL SERVICES COMMANDED TO START."
echo "📊 SYSTEM STATUS:"
pm2 status
