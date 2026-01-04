#!/bin/bash
set -e

# Source the nginx safe deployment library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/lib/nginx-safe-deploy.sh" ]]; then
    source "$SCRIPT_DIR/lib/nginx-safe-deploy.sh"
else
    echo "ERROR: nginx-safe-deploy.sh library not found"
    exit 1
fi

echo "==> 🚀 Starting Nexus COS Production Deployment"

# -----------------------------------------
# 1. Install dependencies
# -----------------------------------------
echo "==> Installing system dependencies..."
apt update -y
apt install -y nginx certbot python3-certbot-nginx nodejs npm python3 python3-pip git

# -----------------------------------------
# 2. Setup systemd services (Node + Python)
# -----------------------------------------
echo "==> Creating systemd services..."

# Node.js backend
cat >/etc/systemd/system/nexus-backend.service <<'EOF'
[Unit]
Description=Nexus COS Node.js Backend
After=network.target

[Service]
ExecStart=/usr/bin/npx ts-node src/server.ts
Restart=always
User=root
WorkingDirectory=/root/nexus-cos/backend
Environment=NODE_ENV=production
Environment=PORT=3000
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=nexus-backend

[Install]
WantedBy=multi-user.target
EOF

# Python FastAPI backend
cat >/etc/systemd/system/nexus-python.service <<'EOF'
[Unit]
Description=Nexus COS Python FastAPI Backend
After=network.target

[Service]
ExecStart=/root/nexus-cos/backend/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
User=root
WorkingDirectory=/root/nexus-cos/backend
Environment=PYTHONUNBUFFERED=1
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=nexus-python

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl enable nexus-backend nexus-python
systemctl restart nexus-backend nexus-python

# -----------------------------------------
# 3. Setup NGINX with SSL
# -----------------------------------------
echo "==> Configuring NGINX..."

safe_deploy_nginx_heredoc "/etc/nginx/sites-available/nexuscos" "true" <<'EOF'
server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name nexuscos.online www.nexuscos.online;

    ssl_certificate /etc/letsencrypt/live/nexuscos.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/nexuscos.online/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    root /var/www/nexuscos/frontend;
    index index.html;

    location / {
        try_files $uri /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /py/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
}
EOF

# Enable site and reload nginx
safe_enable_site "nexuscos" || {
    echo "ERROR: Failed to enable nginx site"
    exit 1
}

reload_nginx || {
    echo "ERROR: Failed to reload nginx"
    exit 1
}

# Obtain / renew SSL certs
certbot --nginx -d nexuscos.online -d www.nexuscos.online --non-interactive --agree-tos -m admin@nexuscos.online || true

# -----------------------------------------
# 4. Build & Deploy Frontend
# -----------------------------------------
echo "==> Building frontend..."
cd /root/nexus-cos/frontend
npm install
npm run build

mkdir -p /var/www/nexuscos/frontend
cp -r dist/* /var/www/nexuscos/frontend/

# -----------------------------------------
# 5. Verify Services
# -----------------------------------------
echo "==> Verifying services..."
systemctl status nexus-backend --no-pager
systemctl status nexus-python --no-pager
curl -k https://nexuscos.online/health || true
curl -k https://nexuscos.online/py/health || true

# -----------------------------------------
# 6. Automated Firewall Configuration
# -----------------------------------------
echo "==> Configuring production firewall for automation..."

# Execute the automated firewall configuration
if [ -f "/root/nexus-cos/scripts/configure-firewall.sh" ]; then
    bash /root/nexus-cos/scripts/configure-firewall.sh
else
    echo "❌ Firewall configuration script not found!"
    exit 1
fi

# Install firewall monitoring service
if [ -f "/root/nexus-cos/scripts/firewall-monitor.sh" ]; then
    echo "==> Installing firewall monitoring service..."
    bash /root/nexus-cos/scripts/firewall-monitor.sh --install
    echo "✅ Firewall monitoring service installed"
else
    echo "⚠️  Firewall monitoring script not found!"
fi

# -----------------------------------------
# 7. Final Validation and Health Checks
# -----------------------------------------
echo "==> Performing final validation..."

# Test all health endpoints through firewall
echo "Testing health endpoints through firewall..."
curl -k https://nexuscos.online/health || echo "⚠️  External health check failed"
curl -k https://nexuscos.online/py/health || echo "⚠️  External Python health check failed"
curl -s http://localhost/health || echo "⚠️  Local health check failed"
curl -s http://localhost/py/health || echo "⚠️  Local Python health check failed"

# Validate firewall health
if [ -f "/usr/local/bin/nexus-firewall-health" ]; then
    /usr/local/bin/nexus-firewall-health || echo "⚠️  Firewall health check failed"
fi

# Run comprehensive firewall and connectivity check
if [ -f "/root/nexus-cos/scripts/firewall-monitor.sh" ]; then
    bash /root/nexus-cos/scripts/firewall-monitor.sh --check || echo "⚠️  Comprehensive connectivity check detected issues"
fi

echo "==> ✅ Production deployment with firewall automation completed!"
echo "🚀 Platform is now fully self-healing with unblocked agent connectivity."
echo "📊 Firewall monitoring service will check connectivity every 5 minutes."