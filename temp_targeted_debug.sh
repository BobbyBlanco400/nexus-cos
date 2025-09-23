#!/bin/bash

# Step: Create Debug Directory
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DEBUG_DIR="/opt/nexus-cos/debug_logs_$TIMESTAMP"
mkdir -p $DEBUG_DIR
echo "🔹 Debug logs directory created: $DEBUG_DIR"

# Step: Audit Container Status & Restart Failing Containers
echo "===== CONTAINER STATUS =====" > $DEBUG_DIR/container_status.txt
docker ps --format "table {{.Names}}\t{{.Status}}" >> $DEBUG_DIR/container_status.txt

# Auto-restart containers that are not healthy
for CONTAINER in $(docker ps -q); do
  HEALTH=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER 2>/dev/null || echo "no-healthcheck")
  NAME=$(docker inspect --format='{{.Name}}' $CONTAINER | sed 's/^\/\|\/$//g')
  STATUS=$(docker inspect --format='{{.State.Status}}' $CONTAINER)
  if [ "$HEALTH" = "unhealthy" ] || [ "$STATUS" != "running" ]; then
    echo "⚠️ $NAME is $STATUS/$HEALTH, restarting..." | tee -a $DEBUG_DIR/container_status.txt
    docker restart $NAME &>> $DEBUG_DIR/container_status.txt
  fi
done
echo "✅ Container audit + auto-restart complete"

# Step: Verify & Rebuild Module Frontends
MODULES=("studio" "metavision" "streamcore" "v-suite" "creator-hub" "puaboverse" "pay" "store" "admin-console" "developer-console" "boom-boom-room-live" "v-hollywood-studio-engine")
echo "===== MODULE BUILD STATUS =====" > $DEBUG_DIR/module_build_status.txt

for MOD in "${MODULES[@]}"; do
  MOD_PATH="/opt/nexus-cos/$MOD"
  echo -e "\n-- $MOD --" >> $DEBUG_DIR/module_build_status.txt
  if [ -f "$MOD_PATH/public/index.html" ]; then
    echo "✅ Build exists" >> $DEBUG_DIR/module_build_status.txt
  else
    echo "❌ Build missing, attempting rebuild..." >> $DEBUG_DIR/module_build_status.txt
    if [ -f "$MOD_PATH/package.json" ]; then
      cd $MOD_PATH
      npm install --legacy-peer-deps &> $DEBUG_DIR/${MOD}_npm_install.log
      npm run build &> $DEBUG_DIR/${MOD}_npm_build.log
      mkdir -p public
      cp -r dist/* public/ 2>/dev/null
      if [ -f "$MOD_PATH/public/index.html" ]; then
        echo "✅ Rebuild successful" >> $DEBUG_DIR/module_build_status.txt
      else
        echo "❌ Rebuild failed, check ${MOD}_npm_build.log" >> $DEBUG_DIR/module_build_status.txt
      fi
    else
      echo "❌ No package.json, cannot rebuild" >> $DEBUG_DIR/module_build_status.txt
    fi
  fi
done

# Step: Nginx Routing Verification
NGINX_CONF="/etc/nginx/sites-enabled/nexus-cos.conf"
echo "===== NGINX CONFIG =====" > $DEBUG_DIR/nginx_routing.txt
if [ -f "$NGINX_CONF" ]; then
  echo "Nginx config found: $NGINX_CONF" >> $DEBUG_DIR/nginx_routing.txt
  grep -E "location|root" $NGINX_CONF >> $DEBUG_DIR/nginx_routing.txt
else
  echo "❌ Nginx config not found at $NGINX_CONF" >> $DEBUG_DIR/nginx_routing.txt
fi

# Step: Module Health Check & Markdown Summary
URLS=(
  "https://nexuscos.online"
  "https://nexuscos.online/studio"
  "https://nexuscos.online/metavision"
  "https://nexuscos.online/streamcore"
  "https://nexuscos.online/v-suite"
  "https://nexuscos.online/creator-hub"
  "https://nexuscos.online/admin-console"
  "https://nexuscos.online/developer-console"
  "https://nexuscos.online/puaboverse"
  "https://nexuscos.online/pay"
  "https://nexuscos.online/store"
  "https://nexuscos.online/boom-boom-room-live"
  "https://nexuscos.online/v-hollywood-studio-engine"
)

SUMMARY=$DEBUG_DIR/system_summary.md
echo "# Nexus COS Debug Summary" > $SUMMARY
echo "Generated: $(date)" >> $SUMMARY
echo "" >> $SUMMARY
echo "## Module HTTP Status" >> $SUMMARY

for URL in "${URLS[@]}"; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)
  if [ "$STATUS" -eq 200 ]; then
    COLOR="🟢"
  elif [ "$STATUS" -eq 404 ]; then
    COLOR="🟠"
  else
    COLOR="🔴"
  fi
  echo "- $URL → $STATUS $COLOR" >> $SUMMARY
done

echo "" >> $SUMMARY
echo "✅ Debug workflow complete. Review logs in $DEBUG_DIR"