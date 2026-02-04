#!/bin/bash
# =================================================================
# N3XUS v-COS | CASINO FEDERATION SERVICE ACTIVATION
# =================================================================

echo "🚀 ACTIVATING CASINO FEDERATION MICROSERVICES..."

# Start Core Casino Services
pm2 start casino-nexus-api --update-env
pm2 start nexcoin-ms --update-env
pm2 start nft-marketplace-ms --update-env
pm2 start skill-games-ms --update-env
pm2 start rewards-ms --update-env
pm2 start vr-world-ms --update-env

echo "✅ SERVICES STARTED."
echo "📊 VERIFYING STATUS..."
pm2 status | grep -E "casino|nexcoin|nft|skill|rewards|vr-world"

echo "🏆 FEDERATION ONLINE."
