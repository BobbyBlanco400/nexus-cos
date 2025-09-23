#!/bin/bash

set -e

# Define modules
MODULES=("studio" "metavision" "streamcore" "v-suite" "creator-hub" "puaboverse" "pay" "store" "admin-console" "developer-console" "boom-boom-room-live" "v-hollywood-studio-engine")

# Clean Old Builds & Artifacts
echo "Cleaning old builds..."
for MOD in "${MODULES[@]}"; do
  MOD_PATH="/opt/nexus-cos/services/$MOD"
  if [ -d "$MOD_PATH/public" ]; then
    rm -rf "$MOD_PATH/public/*"
    echo "- Cleared public folder for $MOD"
  else
    echo "- Skipped cleaning for $MOD (public folder missing)"
  fi
done

# Build All Frontends
echo "Building all frontends..."
for MOD in "${MODULES[@]}"; do
  MOD_PATH="/opt/nexus-cos/services/$MOD"
  if [ -d "$MOD_PATH" ] && [ -f "$MOD_PATH/package.json" ]; then
    cd $MOD_PATH
    npm install --legacy-peer-deps > /dev/null 2>&1
    npm run build > /dev/null 2>&1
    if [ -d "dist" ]; then
      mkdir -p public
      cp -r dist/* public/
    fi
    echo "- Built and deployed $MOD"
  else
    echo "- Skipped build for $MOD (directory or package.json missing)"
  fi
done

# Sync Global Branding
echo "Applying unified branding..."
BRANDING_DIR="/opt/nexus-cos/shared/assets"
for MOD in "${MODULES[@]}"; do
  MOD_PATH="/opt/nexus-cos/services/$MOD"
  if [ -d "$MOD_PATH" ]; then
    mkdir -p $MOD_PATH/public
    if [ -d "$BRANDING_DIR" ]; then
      cp -r $BRANDING_DIR/* $MOD_PATH/public/
      echo "- Branding synced for $MOD"
    else
      echo "- Skipped branding for $MOD (BRANDING_DIR missing)"
    fi
  else
    echo "- Skipped branding for $MOD (module directory missing)"
  fi
done

# Merge Navigation & UI Components
echo "Standardizing UI/UX..."
for MOD in "${MODULES[@]}"; do
  MOD_PATH="/opt/nexus-cos/services/$MOD"
  if [ -d "$MOD_PATH" ]; then
    mkdir -p $MOD_PATH/public
    # Example: enforce shared header/footer and sidebar
    if [ -f "/opt/nexus-cos/shared/components/header.html" ]; then
      cp /opt/nexus-cos/shared/components/header.html $MOD_PATH/public/
    fi
    if [ -f "/opt/nexus-cos/shared/components/footer.html" ]; then
      cp /opt/nexus-cos/shared/components/footer.html $MOD_PATH/public/
    fi
    echo "- UI components merged for $MOD"
  else
    echo "- Skipped UI merge for $MOD (module directory missing)"
  fi
done

# Restart Services
echo "Restarting all containers..."
if [ -f "/opt/nexus-cos/docker-compose.yml" ]; then
  docker compose -f /opt/nexus-cos/docker-compose.yml down
  docker compose -f /opt/nexus-cos/docker-compose.yml up -d
else
  echo "docker-compose.yml missing, skipping restart"
fi

# Full System Health Check
echo "Running full system checks..."
URLS=(
  "https://nexuscos.online/"
  "https://nexuscos.online/admin/"
  "https://nexuscos.online/creator-hub/"
  "https://nexuscos.online/studio/"
  "https://nexuscos.online/metavision/"
  "https://nexuscos.online/streamcore/"
  "https://nexuscos.online/v-suite/"
  "https://nexuscos.online/puaboverse/"
  "https://nexuscos.online/pay/"
  "https://nexuscos.online/store/"
  "https://nexuscos.online/boom-boom-room-live/"
  "https://nexuscos.online/v-hollywood-studio-engine/"
)
REPORT="/opt/nexus-cos/SYSTEM-READINESS-UNISON.md"
echo "# Nexus COS Full Systems & Branding Check" > $REPORT
echo "Generated: $(date)" >> $REPORT
echo "" >> $REPORT
for URL in "${URLS[@]}"; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)
  if [ "$STATUS" -eq 200 ]; then COLOR="GREEN"; elif [ "$STATUS" -eq 404 ]; then COLOR="ORANGE"; else COLOR="RED"; fi
  echo "- $URL → $STATUS $COLOR" >> $REPORT
done

# Summary
echo "Full build and branding unison complete. Check $REPORT"