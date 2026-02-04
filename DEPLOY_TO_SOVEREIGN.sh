#!/bin/bash
# -----------------------------------------------------------------------------
# N3XUS v-COS | SOVEREIGN MESH DEPLOYMENT
# Target: https://n3xuscos.online
# Description: Deploys the full Casino Federation and v-Studios Mesh to Production.
# -----------------------------------------------------------------------------

echo "🚀 INITIATING N3XUS MESH DEPLOYMENT..."
echo "🌐 TARGET: n3xuscos.online"

# 1. STOP EXISTING SERVICES
echo ">>> [1/5] Stopping current services..."
pm2 stop all || true

# 2. UPDATE CODEBASE
echo ">>> [2/5] Syncing Sovereign Codebase..."
# git pull origin main  # Uncomment if using git
# Or assumes files are already transferred via SCP

# 3. CONFIGURE NGINX
echo ">>> [3/5] Updating Mesh Gateway (Nginx)..."
cp deployment/nginx/production.nexuscos.online.conf /etc/nginx/sites-available/n3xuscos.online.conf
ln -sf /etc/nginx/sites-available/n3xuscos.online.conf /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
echo "✅ Nginx Mesh Configured"

# 4. LAUNCH CASINO FEDERATION
echo ">>> [4/5] Activating Casino Federation Grid..."
# Install dependencies if needed
cd modules/casino-nexus
npm install --production
cd ../..

# Launch via PM2 for production persistence
pm2 start start_casino_federation.js --name "casino-federation"

# 5. LAUNCH V-STUDIOS CORE
echo ">>> [5/5] Activating v-Studios Core..."
pm2 start services/vscreen-hollywood/server.js --name "v-screen" --port 8088
pm2 start addons/phase11/franchise-forge/server.js --name "franchise-forge"
pm2 start addons/phase11/royalty-bridge/server.js --name "royalty-bridge"

# 6. SAVE STATE
pm2 save
echo "✅ PM2 State Saved"

echo "-------------------------------------------------------------------------"
echo "🏆 DEPLOYMENT COMPLETE"
echo "🌐 URL: https://n3xuscos.online/casino/"
echo "-------------------------------------------------------------------------"
