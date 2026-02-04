#!/bin/bash
# =================================================================
# N3XUS v-COS | ECOSYSTEM REPAIR SCRIPT
# =================================================================

echo "🔧 INITIATING ECOSYSTEM REPAIR..."

# 1. Install Dependencies for Critical Modules
echo "📦 Installing Dependencies..."

# Creator Hub V2
echo "   ➜ Creator Hub V2"
cd /var/www/nexus-cos/services/creator-hub-v2
npm install --no-audit --silent

# PuaboVerse V2
echo "   ➜ PuaboVerse V2"
cd /var/www/nexus-cos/services/puaboverse-v2
npm install --no-audit --silent

# V-Suite Services
echo "   ➜ V-Suite Pro Services"
cd /var/www/nexus-cos/services/v-caster-pro
npm install --no-audit --silent
cd /var/www/nexus-cos/services/v-prompter-pro
npm install --no-audit --silent

# 2. Return to Root
cd /var/www/nexus-cos

# 3. Force Restart Ecosystem
echo "🔄 Restarting Ecosystem Services..."
pm2 restart creator-hub --update-env
pm2 restart puaboverse --update-env

# 4. Clean up Legacy Processes (Optional)
echo "🧹 Cleaning up ghosts..."
pm2 delete nexus-creator-hub 2>/dev/null || true
pm2 delete nexus-puaboverse 2>/dev/null || true
pm2 delete nexus-v-suite 2>/dev/null || true
pm2 save

echo "✅ REPAIR COMPLETE."
echo "📊 NEW STATUS:"
pm2 status | grep -E "nexus-app|creator-hub|puaboverse|vr-world"
