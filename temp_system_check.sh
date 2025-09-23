#!/bin/bash

echo "🔍 Checking running containers..."
docker ps --format "table {{.Names}}\t{{.Status}}" > /opt/nexus-cos/SYSTEM_STATUS.txt
echo "✅ Container list saved to SYSTEM_STATUS.txt"

echo "🔍 Verifying module builds..."
MODULES=("studio" "metavision" "streamcore" "v-suite" "creator-hub" "puaboverse" "pay" "store" "admin-console" "developer-console" "boom-boom-room-live" "v-hollywood-studio-engine")
for MOD in "${MODULES[@]}"; do
  if [ ! -f "/opt/nexus-cos/$MOD/public/index.html" ]; then
    echo "⚠️ $MOD has no frontend build. Rebuilding..."
    cd /opt/nexus-cos/$MOD
    if [ -f "package.json" ]; then
      npm install --legacy-peer-deps
      npm run build
      mkdir -p public
      cp -r dist/* public/
      echo "✅ $MOD rebuilt and deployed"
    else
      echo "❌ $MOD has no package.json, skipping"
    fi
  else
    echo "✅ $MOD frontend already present"
  fi
done

echo "🎨 Syncing global branding..."
for MOD in "${MODULES[@]}"; do
  if [ -d "/opt/nexus-cos/$MOD/public" ]; then
    cp -r /opt/nexus-cos/shared/assets/* /opt/nexus-cos/$MOD/public/
    echo "✅ Branding synced for $MOD"
  fi
done

echo "🔄 Restarting services..."
docker compose -f /opt/nexus-cos/docker-compose.yml down
docker compose -f /opt/nexus-cos/docker-compose.yml up -d
echo "✅ Containers restarted"

echo "🩺 Running health checks..."
URLS=(
  "https://nexuscos.online"
  "https://nexuscos.online/studio"
  "https://nexuscos.online/metavision"
  "https://nexuscos.online/streamcore"
  "https://nexuscos.online/v-suite"
  "https://nexuscos.online/creator-hub"
  "https://nexuscos.online/puaboverse"
  "https://nexuscos.online/pay"
  "https://nexuscos.online/store"
  "https://nexuscos.online/admin-console"
  "https://nexuscos.online/developer-console"
  "https://nexuscos.online/boom-boom-room-live"
  "https://nexuscos.online/v-hollywood-studio-engine"
)
REPORT=/opt/nexus-cos/SYSTEM-READINESS-REPORT.md
echo "# Nexus COS System Readiness Report" > $REPORT
echo "Generated: $(date)" >> $REPORT
echo "" >> $REPORT
for URL in "${URLS[@]}"; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" $URL)
  echo "- $URL → $CODE" >> $REPORT
done
echo "" >> $REPORT
echo "✅ Branding + module rebuild completed" >> $REPORT
echo "📄 Report saved at $REPORT"