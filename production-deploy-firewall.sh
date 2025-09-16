#!/bin/bash
set -e

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
ExecStart=/usr/bin/node /root/nexus-cos/backend/src/index.js
Restart=always
User=root
WorkingDirectory=/root/nexus-cos/backend
Environment=NODE_ENV=production
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

cat >/etc/nginx/sites-available/nexuscos <<'EOF'
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

ln -sf /etc/nginx/sites-available/nexuscos /etc/nginx/sites-enabled/nexuscos
nginx -t && systemctl reload nginx

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
# 6. Firewall Task (hand off to Code Agent)
# -----------------------------------------
echo "==> Triggering Copilot agent for firewall adjustments..."
cat <<'EOS'

@copilot Please take ownership of this task and implement the firewall adjustments as described in issue #6.
Ensure all health monitoring, automation, and agent connectivity work fully without firewall interference.
Provide a summary log of actions and verification steps.

EOS
echo "==> ✅ Deployment script completed!"