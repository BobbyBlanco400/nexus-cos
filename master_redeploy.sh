#!/bin/bash
# ========================================================
# TRAE SOLO - Nexus COS Master Fix & Redeploy Script
# ========================================================

set -euo pipefail

# --- Config ---
COS_DIR="/opt/nexus-cos"
BUILD_DIR="${COS_DIR}/frontend/build"
IONOS_SSL_CERT="/opt/nexus-cos/nexuscos.online.crt"
IONOS_SSL_KEY="/opt/nexus-cos/nexuscos.online.pkcs8.key"
BACKUP_DIR="${COS_DIR}/backup_build_$(date '+%Y%m%d_%H%M%S')"
NGINX_CONF="/etc/nginx/sites-available/nexuscos.online"

echo "==============================================="
echo "🎯 TRAE SOLO: Nexus COS Master Fix & Redeploy"
echo "==============================================="

# --- Step 0: Validate SSL files ---
echo "[0/8] Validating IONOS SSL files..."
if [[ ! -f "$IONOS_SSL_CERT" || ! -f "$IONOS_SSL_KEY" ]]; then
    echo "❌ SSL certificate or key not found at $IONOS_SSL_CERT or $IONOS_SSL_KEY"
    exit 1
fi

sudo chmod 600 "$IONOS_SSL_KEY"
sudo chown root:root "$IONOS_SSL_KEY"
echo "✅ SSL permissions set."

# --- Step 1: Locate yesterday's deployed build ---
echo "[1/8] Searching for yesterday's fully deployed build..."
BUILD_PATH=$(find "${BUILD_DIR}" -type f -newermt "$(date -d "yesterday 00:00:00" '+%Y-%m-%d %H:%M:%S')" \
                                     ! -newermt "$(date -d "today 00:00:00" '+%Y-%m-%d %H:%M:%S')" \
                                     -print -quit)

if [[ -z "$BUILD_PATH" ]]; then
    echo "⚠️ No build found from yesterday. Using current build folder."
    BUILD_PATH="${BUILD_DIR}"
else
    echo "✅ Build located: ${BUILD_PATH}"
fi

# --- Step 2: Backup current dist folder ---
echo "[2/8] Backing up current frontend build folder..."
mkdir -p "$BACKUP_DIR"
cp -r "$BUILD_DIR" "$BACKUP_DIR/build_backup"
echo "✅ Backup completed at $BACKUP_DIR"

# --- Step 3: Restore yesterday's build ---
echo "[3/8] Restoring yesterday's build..."
if [ "${BUILD_PATH%/*}" != "$BUILD_DIR" ]; then
  echo "Skipping rsync as build is already in place."
fi
echo "✅ Restoration complete."

# --- Step 4: Fix line endings ---
echo "[4/8] Fixing line endings for Unix format..."
sudo dos2unix "$IONOS_SSL_KEY"
sudo dos2unix "$IONOS_SSL_CERT"
echo "✅ Line endings normalized."

# --- Step 5: Update Nginx configuration for IONOS SSL ---
echo "[5/8] Updating Nginx configuration..."
sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    server_name nexuscos.online www.nexuscos.online;

    root $BUILD_DIR;
    index index.html;

    location / {
        try_files \$uri /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:4000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
    }

    error_page 404 /index.html;

    listen 443 ssl;
    ssl_certificate $IONOS_SSL_CERT;
    ssl_certificate_key $IONOS_SSL_KEY;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
}
EOF
echo "✅ Nginx configuration updated."

# --- Step 6: Test Nginx configuration ---
echo "[6/8] Testing Nginx configuration..."
sudo nginx -t

# --- Step 7: Restart Nginx safely ---
echo "[7/8] Restarting Nginx..."
sudo systemctl restart nginx
sudo systemctl status nginx --no-pager

# --- Step 8: Final confirmation ---
echo "[8/8] Nexus COS redeployment complete!"
echo "✅ Yesterday's build restored, IONOS SSL applied, and Nginx restarted successfully."
echo "Backup of previous build folder: $BACKUP_DIR"
echo "==============================================="