#!/bin/bash
# ============================================
# TRAE SOLO - Nexus COS Ultimate Redeploy
# One-Command Master Script
# ============================================

set -euo pipefail

# -------------------------
# Variables
# -------------------------
COS_DIR="/root/nexus-cos"
IONOS_CERT="${COS_DIR}/nexuscos.online.crt"
IONOS_KEY="${COS_DIR}/nexuscos.online.key"
NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"
NGINX_SITE_CONF="${NGINX_SITES_AVAILABLE}/nexuscos.online"
BACKUP_DIR="${COS_DIR}/backup_$(date +%Y%m%d_%H%M%S)"

# -------------------------
# Step 0: Pre-check IONOS SSL
# -------------------------
echo "[0/9] Checking IONOS SSL files..."
if [[ ! -f "${IONOS_CERT}" || ! -f "${IONOS_KEY}" ]]; then
    echo "❌ ERROR: IONOS SSL files not found in ${COS_DIR}"
    exit 1
fi

# -------------------------
# Step 1: Backup existing configs
# -------------------------
echo "[1/9] Backing up existing Nginx and COS configs..."
mkdir -p "${BACKUP_DIR}"
sudo cp -r "${NGINX_SITES_AVAILABLE}" "${BACKUP_DIR}/nginx_sites_available"
sudo cp -r "${NGINX_SITES_ENABLED}" "${BACKUP_DIR}/nginx_sites_enabled"
cp -r "${COS_DIR}" "${BACKUP_DIR}/nexus_cos_files"

# -------------------------
# Step 2: Clean old Certbot/Let's Encrypt
# -------------------------
echo "[2/9] Removing Certbot/Let's Encrypt remnants..."
sudo rm -f "${NGINX_SITES_ENABLED}/nexuscos.online" || true
sudo rm -f "${NGINX_SITES_AVAILABLE}/nexuscos.online" || true
sudo rm -rf /etc/letsencrypt/live/nexuscos.online || true
sudo rm -rf /etc/letsencrypt/archive/nexuscos.online || true
sudo rm -rf /etc/letsencrypt/renewal/nexuscos.online.conf || true

# -------------------------
# Step 3: Fix SSL permissions
# -------------------------
echo "[3/9] Fixing IONOS SSL permissions..."
sudo chmod 600 "${IONOS_KEY}"
sudo chown root:root "${IONOS_KEY}"
sudo chmod 644 "${IONOS_CERT}"
sudo chown root:root "${IONOS_CERT}"

# -------------------------
# Step 4: Convert SSL to Unix format (cleanup)
# -------------------------
echo "[4/9] Converting SSL key to Unix format..."
sudo tr -d '\r' < "${IONOS_KEY}" > "${IONOS_KEY}.clean"
sudo mv "${IONOS_KEY}.clean" "${IONOS_KEY}"

# -------------------------
# Step 5: Recreate Nginx site config
# -------------------------
echo "[5/9] Recreating Nginx configuration..."
sudo tee "${NGINX_SITE_CONF}" > /dev/null <<EOF
server {
    listen 443 ssl;
    server_name nexuscos.online www.nexuscos.online;

    root ${COS_DIR}/frontend/dist;
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

    ssl_certificate ${IONOS_CERT};
    ssl_certificate_key ${IONOS_KEY};
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
}
EOF

# -------------------------
# Step 6: Enable Nginx site
# -------------------------
echo "[6/9] Enabling Nginx site..."
sudo ln -sf "${NGINX_SITE_CONF}" "${NGINX_SITES_ENABLED}/nexuscos.online"

# -------------------------
# Step 7: Test Nginx
# -------------------------
echo "[7/9] Testing Nginx configuration..."
sudo nginx -t

# -------------------------
# Step 8: Restart Nginx
# -------------------------
echo "[8/9] Restarting Nginx..."
sudo systemctl restart nginx
sudo systemctl status nginx --no-pager

# -------------------------
# Step 9: Confirm COS frontend
# -------------------------
echo "[9/9] Confirming Nexus COS branding frontend is live..."
if curl -s -o /dev/null -w "%{http_code}" https://nexuscos.online  | grep -q "200"; then
    echo "✅ Nexus COS frontend is live and stable!"
else
    echo "⚠️ Warning: Nexus COS frontend may not be fully reachable. Check Nginx logs."
fi

echo "=============================================="
echo "🎯 Master Redeploy Complete. All branding restored."
echo "Backup of previous configs available at: ${BACKUP_DIR}"
echo "=============================================="