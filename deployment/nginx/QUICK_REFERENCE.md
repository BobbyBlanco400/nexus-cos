# Nexus COS - Nginx Routing Fix Quick Reference

## TL;DR - One-Command Deployment

### For Vanilla Nginx (Standard Linux)
```bash
cd /path/to/nexus-cos && sudo ./deployment/nginx/scripts/deploy-vanilla.sh
```

### For Plesk (IONOS/Plesk Managed)
```bash
cd /path/to/nexus-cos && sudo ./deployment/nginx/scripts/deploy-plesk.sh
```

### Validate Endpoints
```bash
./deployment/nginx/scripts/validate-endpoints.sh
```

---

## Manual Deployment (Vanilla Nginx)

```bash
# Backup existing config
sudo cp -f /etc/nginx/sites-enabled/nexuscos.online /etc/nginx/sites-enabled/nexuscos.online.bak.$(date +%Y%m%d%H%M%S) 2>/dev/null || true

# Install vhost configuration
sudo cp deployment/nginx/sites-available/nexuscos.online /etc/nginx/sites-available/nexuscos.online

# Enable the site
sudo ln -sf /etc/nginx/sites-available/nexuscos.online /etc/nginx/sites-enabled/nexuscos.online

# Disable default site
sudo rm -f /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

---

## Manual Deployment (Plesk)

```bash
# Backup existing config
sudo cp -f /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf.bak.$(date +%Y%m%d%H%M%S) 2>/dev/null || true

# Install Plesk vhost configuration
sudo cp deployment/nginx/plesk/vhost_nginx.conf /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf

# Rebuild Plesk configuration
sudo plesk repair web -domain nexuscos.online -y || true

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

---

## Validation Commands

### Automated Validation
```bash
./deployment/nginx/scripts/validate-endpoints.sh
```

### Manual Validation with curl
```bash
BASE=https://nexuscos.online
for path in "/" "/apex/" "/beta/" "/api/" "/stream/" "/hls/" "/health"; do
  code=$(curl -sSI --max-time 8 -k "$BASE$path" | awk 'toupper($0) ~ /^HTTP/{print $2; exit}')
  echo "$path $code"
done
```

Expected results:
- `/` → 200 (main page)
- `/apex/` → 200 or 404 (if not published)
- `/beta/` → 200 or 404 (if not published)
- `/api/` → 200, 404, or 401 (depends on backend)
- `/stream/` → 200 or appropriate code
- `/hls/` → 200 or appropriate code
- `/health` → 200

---

## Why It Was Failing

The site was returning the Nginx welcome page because:

1. **No active vhost**: The nexuscos.online vhost was not enabled or didn't exist in `sites-enabled`
2. **Server name mismatch**: No vhost matched the domain, causing fallback to `default_server`
3. **Wrong document root**: Root was pointing to `/var/www/html` (default) instead of `/var/www/nexus-cos`
4. **Missing proxy config**: `/api`, `/stream`, and `/hls` lacked proper proxy headers and WebSocket support
5. **Plesk override missing**: On Plesk systems, domain-specific config requires `vhost_nginx.conf`, not `sites-available`

---

## Service Ports

| Service | Port | Endpoints |
|---------|------|-----------|
| Backend API | 3000 | `/api/*` |
| Python Backend (optional) | 3001 | `/py/*` |
| Streaming Service | 3043 | `/stream/*`, `/hls/*` |

---

## Troubleshooting

### Check Services Are Running
```bash
curl -I http://127.0.0.1:3000/  # Backend
curl -I http://127.0.0.1:3043/stream/  # Streaming
```

### View Nginx Logs
```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Test Nginx Config
```bash
sudo nginx -t
```

### Reload Nginx
```bash
sudo systemctl reload nginx
```

### Check Active Configuration
```bash
sudo nginx -T | grep -A 20 "server_name nexuscos.online"
```

---

## Rollback

### Find Backup
```bash
# Vanilla Nginx
ls -la /etc/nginx/sites-enabled/nexuscos.online.bak.*

# Plesk
ls -la /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf.bak.*
```

### Restore Backup (Vanilla)
```bash
sudo cp /etc/nginx/sites-enabled/nexuscos.online.bak.TIMESTAMP /etc/nginx/sites-enabled/nexuscos.online
sudo nginx -t && sudo systemctl reload nginx
```

### Restore Backup (Plesk)
```bash
sudo cp /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf.bak.TIMESTAMP \
     /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf
sudo plesk repair web -domain nexuscos.online -y
sudo nginx -t && sudo systemctl reload nginx
```

---

## Files in This Solution

```
deployment/nginx/
├── sites-available/
│   └── nexuscos.online          # Vanilla Nginx vhost
├── plesk/
│   └── vhost_nginx.conf         # Plesk additional directives
├── scripts/
│   ├── deploy-vanilla.sh        # Deploy script for vanilla Nginx
│   ├── deploy-plesk.sh          # Deploy script for Plesk
│   └── validate-endpoints.sh    # Endpoint validation
├── README.md                    # Full documentation
└── QUICK_REFERENCE.md           # This file
```

---

## Key Configuration Highlights

### HTTP to HTTPS Redirect
```nginx
server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    return 301 https://$server_name$request_uri;
}
```

### API Proxy with WebSocket
```nginx
location ^~ /api/ {
    proxy_pass http://127.0.0.1:3000/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    # ... additional headers
}
```

### Streaming with Extended Timeout
```nginx
location ^~ /stream/ {
    proxy_pass http://127.0.0.1:3043/stream/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 86400;
    # ... additional headers
}
```

### SPA Routing
```nginx
location ^~ /apex/ {
    alias /var/www/nexus-cos/apex/;
    try_files $uri $uri/ /apex/index.html;
}
```

---

## Need Help?

1. Check the full [README.md](./README.md) for detailed documentation
2. Review Nginx error logs: `sudo tail -f /var/log/nginx/error.log`
3. Verify services are running: `pm2 list`
4. Run validation script: `./deployment/nginx/scripts/validate-endpoints.sh`
