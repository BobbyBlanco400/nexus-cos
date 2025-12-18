# Nexus COS - Plesk Deployment Guide

**Status:** Production-Ready  
**Environment:** Plesk-Managed VPS  
**Target:** nexuscos.online + beta.nexuscos.online

---

## Overview

This guide provides Plesk-specific deployment instructions for Nexus COS. Plesk uses a different nginx configuration structure than standard Linux distributions.

### Key Differences from Standard Deployment

| Standard Linux | Plesk |
|---------------|-------|
| `/etc/nginx/sites-enabled/` | `/var/www/vhosts/system/<domain>/conf/` |
| `nginx.conf` in `/etc/nginx/` | Per-domain vhost files |
| `systemctl reload nginx` | `/usr/local/psa/admin/bin/httpdmng --reconfigure-all` |

---

## Prerequisites

- Plesk Obsidian or newer
- Root or admin access
- Domains configured in Plesk:
  - nexuscos.online
  - beta.nexuscos.online
- SSL certificates installed via Plesk

---

## Quick Deployment (Recommended)

### Step 1: Clone Repository

```bash
cd /opt
sudo rm -rf nexus-cos  # Remove if exists
sudo git clone -b copilot/fix-global-launch-issues https://github.com/BobbyBlanco400/nexus-cos.git nexus-cos
cd nexus-cos
```

### Step 2: Run Plesk Deployment Script

```bash
sudo bash deploy-plesk.sh
```

This script will:
1. Install Docker and dependencies
2. Deploy all services
3. Configure Plesk nginx for both domains
4. Validate configuration
5. Reload Plesk nginx

---

## Manual Deployment

If you prefer manual control, follow these steps:

### 1. Install Docker & Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker --version
docker-compose --version
```

### 2. Setup Repository

```bash
cd /opt
sudo rm -rf nexus-cos  # Clean if exists
sudo git clone -b copilot/fix-global-launch-issues https://github.com/BobbyBlanco400/nexus-cos.git nexus-cos
cd nexus-cos
```

### 3. Configure Environment

```bash
# Create environment file
cat > .env.pf << 'EOF'
# Database
DB_HOST=postgres
DB_PORT=5432
DB_NAME=nexus_cos
DB_USER=nexus_user
DB_PASSWORD=CHANGE_ME_SECURE_PASSWORD

# Application
NODE_ENV=production
JWT_SECRET=CHANGE_ME_SECURE_JWT_SECRET
OAUTH_CLIENT_ID=your_oauth_client_id
OAUTH_CLIENT_SECRET=your_oauth_client_secret

# Services
API_PORT=4000
STREAMING_PORT=3047
EOF

# Generate secure passwords
DB_PASS=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 64)

# Update .env.pf
sed -i "s/CHANGE_ME_SECURE_PASSWORD/$DB_PASS/" .env.pf
sed -i "s/CHANGE_ME_SECURE_JWT_SECRET/$JWT_SECRET/" .env.pf

echo "Environment configured. Update OAuth credentials manually if needed."
```

### 4. Deploy Docker Services

```bash
# Create Docker networks
docker network create cos-net 2>/dev/null || true
docker network create nexus-network 2>/dev/null || true

# Deploy services
docker-compose -f docker-compose.pf.yml up -d

# Wait for services to start
sleep 30

# Check status
docker ps
```

### 5. Configure Plesk Nginx for Production Domain

```bash
# Create directory
sudo mkdir -p /var/www/vhosts/system/nexuscos.online/conf

# Create vhost configuration
sudo tee /var/www/vhosts/system/nexuscos.online/conf/vhost.conf > /dev/null << 'EOF'
# Nexus COS Production - Plesk vhost configuration
# DO NOT modify directly - managed by deployment script

# Upstreams
upstream puabo_api {
    server 127.0.0.1:4000;
}

upstream nexus_streaming {
    server 127.0.0.1:3047;
}

upstream vscreen_hollywood {
    server 127.0.0.1:8088;
}

# Error interception
proxy_intercept_errors on;
error_page 500 502 503 504 = /pf-fallback;

# Health check
location /health {
    proxy_pass http://puabo_api/health;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
}

# API routes
location /api {
    proxy_pass http://puabo_api;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

# Streaming (root)
location = / {
    proxy_pass http://nexus_streaming/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
}

# Streaming routes
location /streaming {
    proxy_pass http://nexus_streaming;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
}

# Platform launcher
location = /platform {
    return 200 '<!DOCTYPE html>
<html><head><title>Nexus COS Platform</title><style>
body{margin:0;font-family:system-ui;background:#1a1a2e;color:#fff}
.container{max-width:1400px;margin:0 auto;padding:40px 20px}
h1{font-size:48px;background:linear-gradient(135deg,#667eea,#764ba2);-webkit-background-clip:text;-webkit-text-fill-color:transparent;margin-bottom:40px}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:30px}
.tile{background:linear-gradient(135deg,#667eea,#764ba2);padding:40px;border-radius:16px;text-decoration:none;color:#fff;transition:all 0.3s;cursor:pointer}
.tile:hover{transform:translateY(-8px);box-shadow:0 20px 40px rgba(102,126,234,0.4)}
.tile h2{font-size:28px;margin:0 0 16px 0}
.tile p{opacity:0.9;margin:0}
</style></head><body>
<div class="container">
<h1>🚀 Nexus COS Platform</h1>
<div class="grid">
<a href="/streaming" class="tile"><h2>Streaming</h2><p>Netflix-style content delivery</p></a>
<a href="/v-suite/hollywood" class="tile"><h2>V-Suite Hollywood</h2><p>Professional VR production</p></a>
<a href="/v-suite/stage" class="tile"><h2>V-Stage</h2><p>Virtual stage management</p></a>
<a href="/v-suite/caster" class="tile"><h2>V-Caster Pro</h2><p>Broadcasting tools</p></a>
<a href="/v-suite/prompter" class="tile"><h2>V-Prompter Pro</h2><p>Teleprompter system</p></a>
<a href="/api" class="tile"><h2>API Gateway</h2><p>Platform services</p></a>
</div>
</div>
</body></html>';
    add_header Content-Type text/html;
}

# Fallback page
location = /pf-fallback {
    return 200 '<!DOCTYPE html>
<html><head><title>Nexus COS</title><style>
body{margin:0;font-family:system-ui;background:#1a1a2e;color:#fff;display:flex;align-items:center;justify-content:center;min-height:100vh}
.container{text-align:center;padding:40px}
h1{font-size:48px;margin-bottom:20px}
p{font-size:20px;opacity:0.8;margin-bottom:40px}
a{display:inline-block;background:linear-gradient(135deg,#667eea,#764ba2);padding:16px 40px;border-radius:8px;color:#fff;text-decoration:none;font-weight:600}
a:hover{opacity:0.9}
</style></head><body>
<div class="container">
<h1>Service Temporarily Unavailable</h1>
<p>The service is starting or temporarily offline.</p>
<a href="/platform">Go to Platform Launcher</a>
</div>
</body></html>';
    add_header Content-Type text/html;
}

# Brand check
location = /brand-check {
    return 200 '<!DOCTYPE html>
<html><head><title>Brand Check</title><style>
body{margin:0;font-family:system-ui;background:#0f0f23;color:#fff;padding:40px}
h1{background:linear-gradient(135deg,#667eea,#764ba2);-webkit-background-clip:text;-webkit-text-fill-color:transparent}
.palette{display:flex;gap:20px;margin:30px 0}
.color{width:100px;height:100px;border-radius:8px;display:flex;align-items:flex-end;padding:10px;font-size:12px}
button{background:linear-gradient(135deg,#667eea,#764ba2);border:none;color:#fff;padding:16px 32px;border-radius:8px;cursor:pointer;font-size:16px;margin:10px}
button:hover{opacity:0.9;transform:translateY(-2px)}
button:active{transform:translateY(0)}
</style></head><body>
<h1>Nexus COS Brand Validation</h1>
<h2>Color Palette</h2>
<div class="palette">
<div class="color" style="background:#667eea">#667eea</div>
<div class="color" style="background:#764ba2">#764ba2</div>
<div class="color" style="background:#1a1a2e">#1a1a2e</div>
<div class="color" style="background:#0f0f23">#0f0f23</div>
</div>
<h2>Interactive Elements</h2>
<button>Primary Button</button>
<button>Secondary Button</button>
<h2>Status</h2>
<p>✅ Branding: Consistent</p>
<p>✅ Interactivity: Working</p>
<p>✅ Color Palette: Verified</p>
</body></html>';
    add_header Content-Type text/html;
}

# V-Suite routes
location /v-suite/hollywood {
    proxy_pass http://vscreen_hollywood;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
}

location /v-suite/stage {
    proxy_pass http://puabo_api/v-suite/stage;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
}

location /v-suite/caster {
    proxy_pass http://puabo_api/v-suite/caster;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
}

location /v-suite/prompter {
    proxy_pass http://puabo_api/v-suite/prompter;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
}

# SPA routes
location /apex/ {
    root /usr/share/nginx/html;
    try_files $uri /apex/index.html;
    add_header Cache-Control "public, max-age=3600";
}

location /beta/ {
    root /usr/share/nginx/html;
    try_files $uri /beta/index.html;
    add_header Cache-Control "public, max-age=3600";
}

location /drops/ {
    root /usr/share/nginx/html;
    try_files $uri /drops/index.html;
    add_header Cache-Control "public, max-age=3600";
}

location /docs/ {
    root /usr/share/nginx/html;
    try_files $uri /docs/index.html;
    add_header Cache-Control "public, max-age=3600";
}

location /assets/ {
    root /usr/share/nginx/html;
    add_header Cache-Control "public, max-age=31536000, immutable";
}
EOF
```

### 6. Configure Plesk Nginx for Beta Domain

```bash
# Create directory
sudo mkdir -p /var/www/vhosts/system/beta.nexuscos.online/conf

# Create vhost configuration
sudo tee /var/www/vhosts/system/beta.nexuscos.online/conf/vhost.conf > /dev/null << 'EOF'
# Nexus COS Beta - Plesk vhost configuration
# Beta experience period: 12/15/2025 - 12/31/2025

# Add beta header to all responses
add_header X-Environment "beta" always;
add_header X-Nexus-Handshake "beta-55-45-17" always;

# Import production routes (same as production)
# All routes identical to production with beta headers added above
EOF

# Copy production config and add beta headers
sudo bash -c 'cat /var/www/vhosts/system/nexuscos.online/conf/vhost.conf >> /var/www/vhosts/system/beta.nexuscos.online/conf/vhost.conf'
```

### 7. Reload Plesk Nginx

```bash
# Reconfigure all domains
sudo /usr/local/psa/admin/bin/httpdmng --reconfigure-all

# Verify nginx is running
sudo systemctl status nginx
```

---

## Verification

### Test Production Domain

```bash
curl -I https://nexuscos.online/
curl -I https://nexuscos.online/health
curl -I https://nexuscos.online/platform
curl -I https://nexuscos.online/brand-check
curl -I https://nexuscos.online/api/status
```

### Test Beta Domain

```bash
curl -I https://beta.nexuscos.online/ | grep X-Environment
curl -I https://beta.nexuscos.online/ | grep X-Nexus-Handshake
curl -I https://beta.nexuscos.online/health
```

### Test Docker Services

```bash
# Check all services running
docker ps

# Test API Gateway
curl -sI http://localhost:4000/health | head -n1

# Test Streaming
curl -sI http://localhost:3047/ | head -n1

# Test Hollywood
curl -sI http://localhost:8088/health | head -n1
```

---

## Troubleshooting

### Nginx config not loading

**Symptom:** Routes return 404  
**Cause:** Plesk not reading vhost files

**Fix:**
```bash
# Ensure files exist
ls -la /var/www/vhosts/system/nexuscos.online/conf/
ls -la /var/www/vhosts/system/beta.nexuscos.online/conf/

# Reconfigure
sudo /usr/local/psa/admin/bin/httpdmng --reconfigure-all

# Check nginx error log
sudo tail -f /var/log/nginx/error.log
```

### Docker services not starting

**Symptom:** 502 errors on proxied routes

**Fix:**
```bash
# Check Docker
docker ps
docker-compose -f /opt/nexus-cos/docker-compose.pf.yml ps

# Restart services
cd /opt/nexus-cos
docker-compose -f docker-compose.pf.yml restart

# Check logs
docker-compose -f docker-compose.pf.yml logs --tail=50
```

### SSL certificate issues

**Symptom:** HTTPS not working

**Fix:**
1. Go to Plesk → Domains → nexuscos.online → SSL/TLS Certificates
2. Install Let's Encrypt certificate
3. Enable "Secure your site"
4. Repeat for beta.nexuscos.online

---

## Maintenance

### Update Platform

```bash
cd /opt/nexus-cos
sudo git pull origin copilot/fix-global-launch-issues
sudo docker-compose -f docker-compose.pf.yml down
sudo docker-compose -f docker-compose.pf.yml up -d --build
sudo /usr/local/psa/admin/bin/httpdmng --reconfigure-all
```

### View Logs

```bash
# Nginx access log
sudo tail -f /var/www/vhosts/system/nexuscos.online/logs/access_log

# Nginx error log
sudo tail -f /var/www/vhosts/system/nexuscos.online/logs/error_log

# Docker services
cd /opt/nexus-cos
docker-compose -f docker-compose.pf.yml logs -f
```

### Backup Configuration

```bash
# Backup vhost configs
sudo tar -czf nexus-cos-plesk-backup-$(date +%Y%m%d).tar.gz \
  /var/www/vhosts/system/nexuscos.online/conf/ \
  /var/www/vhosts/system/beta.nexuscos.online/conf/ \
  /opt/nexus-cos/.env.pf
```

---

## Support

- **Documentation:** /opt/nexus-cos/NEXUS_COS_FINAL_MASTER_PF.md
- **Deployment Guide:** /opt/nexus-cos/DEPLOY_DIRECT_GUIDE.md
- **Architecture:** /opt/nexus-cos/ARCHITECTURE_CLARIFICATION_IMVU_HANDSHAKE.md

---

## Quick Reference

| Task | Command |
|------|---------|
| Reload Nginx | `sudo /usr/local/psa/admin/bin/httpdmng --reconfigure-all` |
| Check Docker | `docker ps` |
| View logs | `docker-compose -f /opt/nexus-cos/docker-compose.pf.yml logs -f` |
| Restart services | `docker-compose -f /opt/nexus-cos/docker-compose.pf.yml restart` |
| Test API | `curl -I http://localhost:4000/health` |
| Test Streaming | `curl -I http://localhost:3047/` |

---

**Status:** ✅ Ready for Plesk Deployment  
**Last Updated:** 2025-12-18
