#!/bin/bash
# deploy_nexus_cos.sh
# One-shot deployment for Nexus COS (backend, frontend, mobile)

set -e

echo "🚀 Starting Nexus COS deployment..."

# 1️⃣ Go to your Nexus COS repo
cd /var/www/nexus-cos || { echo "❌ Nexus COS folder not found"; exit 1; }

# 2️⃣ Save current commit for rollback
CURRENT_COMMIT=$(git rev-parse HEAD)
echo "💾 Current commit $CURRENT_COMMIT saved for rollback"

# 3️⃣ Update repo
echo "↻ Pulling latest changes..."
git fetch origin
git reset --hard origin/main

# 4️⃣ Set environment
export NODE_ENV=production
echo "⚙️ Environment set to production"

# 5️⃣ Install backend dependencies
echo "📦 Installing backend dependencies..."
cd apps/api || { echo "❌ Backend folder not found"; exit 1; }
npm ci --omit=dev

# 6️⃣ Install frontend dependencies and build
echo "📦 Installing frontend dependencies..."
cd ../web || { echo "❌ Frontend folder not found"; exit 1; }
npm ci --omit=dev
echo "📦 Building frontend..."
npm run build

# 7️⃣ Install mobile API dependencies
echo "📦 Installing mobile API dependencies..."
cd ../mobile || { echo "❌ Mobile folder not found"; exit 1; }
npm ci --omit=dev

# 8️⃣ Build Android/IOS APKs
echo "📦 Building mobile APKs..."
# Example placeholders; replace with your actual mobile build commands:
npm run build:android || echo "⚠️ Android build skipped or failed"
npm run build:ios || echo "⚠️ iOS build skipped or failed"

# 9️⃣ Restart all services via PM2
echo "♻️ Restarting all services via PM2..."
pm2 delete all || true
pm2 start /var/www/nexus-cos/apps/api/server.js --name "nexus-backend" --watch
pm2 start /var/www/nexus-cos/web/server.js --name "nexus-frontend" --watch
pm2 start /var/www/nexus-cos/mobile/server.js --name "nexus-mobile-api" --watch

# 1️⃣0️⃣ Save PM2 process list for auto-start
echo "💾 Saving PM2 process list..."
pm2 save

echo "✅ Nexus COS deployed successfully!"
