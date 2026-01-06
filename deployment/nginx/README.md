# Nginx Configuration for n3xuscos.online

## Overview

This directory contains the complete Nginx configuration for **n3xuscos.online**, designed to fix routing issues where the domain was serving the Nginx welcome page instead of the published site.

## Problem Summary

### What Was Failing

The n3xuscos.online domain was returning the Nginx welcome page for all paths (/, /api, /stream, /hls) instead of serving the published site and proxying API/streaming requests. The root causes were:

1. **Default site winning**: The default Nginx site configuration in `sites-enabled` was being served instead of the n3xuscos.online vhost
2. **Server name mismatch**: No active vhost configuration matched `n3xuscos.online`, causing requests to fall through to `default_server`
3. **Incorrect document root**: The vhost root was pointing to Nginx's default directory instead of `/var/www/nexus-cos`
4. **Missing proxy configuration**: API and streaming routes lacked proper proxy headers and WebSocket upgrade support
5. **Plesk configuration override**: On IONOS/Plesk systems, per-domain configuration requires using `vhost_nginx.conf` instead of `sites-available`

## Solution

This solution provides two deployment approaches:

### 1. Vanilla Nginx (Standard Linux Installation)
- Configuration file: `sites-available/n3xuscos.online`
- Deployment script: `scripts/deploy-vanilla.sh`
- Location: `/etc/nginx/sites-available/n3xuscos.online`

### 2. Plesk Nginx (IONOS/Plesk Managed)
- Configuration file: `plesk/vhost_nginx.conf`
- Deployment script: `scripts/deploy-plesk.sh`
- Location: `/var/www/vhosts/system/n3xuscos.online/conf/vhost_nginx.conf`

## Directory Structure

```
deployment/nginx/
├── sites-available/
│   └── n3xuscos.online          # Vanilla Nginx vhost configuration
├── plesk/
│   └── vhost_nginx.conf         # Plesk additional directives
├── scripts/
│   ├── deploy-vanilla.sh        # Deployment script for vanilla Nginx
│   ├── deploy-plesk.sh          # Deployment script for Plesk
│   └── validate-endpoints.sh    # Endpoint validation script
└── README.md                    # This file
```

## Configuration Features

Both configurations include:

- ✅ **HTTP to HTTPS redirect** for n3xuscos.online and www subdomain
- ✅ **Default server redirect** to capture IP and unmatched domain requests
- ✅ **SSL/TLS** using IONOS certificates (`/etc/ssl/ionos/fullchain.pem` and `privkey.pem`)
- ✅ **Security headers**: HSTS, X-Frame-Options, X-Content-Type-Options, etc.
- ✅ **SPA routing**: `try_files` fallback to `index.html` for React/Vue/Angular apps
- ✅ **API proxy**: `/api/` → `http://127.0.0.1:3000/` with WebSocket support
- ✅ **Streaming proxy**: `/stream/` and `/hls/` → `http://127.0.0.1:3043/` with WebSocket and extended timeouts
- ✅ **Health endpoint**: `/health` returns 200 OK for monitoring
- ✅ **Static asset caching**: 1-year cache for JS/CSS/images
- ✅ **Security filters**: Block access to `.git`, `.env`, and other sensitive files

## Deployment Instructions

### Option 1: Vanilla Nginx Deployment

For standard Linux servers with Nginx (not managed by Plesk):

```bash
# 1. Navigate to the repository
cd /path/to/nexus-cos

# 2. Run the deployment script
sudo ./deployment/nginx/scripts/deploy-vanilla.sh
```

The script will:
- Backup existing configuration (if any)
- Copy vhost to `/etc/nginx/sites-available/n3xuscos.online`
- Create symlink in `/etc/nginx/sites-enabled/`
- Disable the default site
- Test Nginx configuration
- Reload Nginx

### Option 2: Plesk Deployment

For IONOS or other Plesk-managed servers:

```bash
# 1. Navigate to the repository
cd /path/to/nexus-cos

# 2. Run the deployment script
sudo ./deployment/nginx/scripts/deploy-plesk.sh
```

The script will:
- Backup existing configuration (if any)
- Copy vhost to `/var/www/vhosts/system/n3xuscos.online/conf/vhost_nginx.conf`
- Set proper permissions
- Rebuild Plesk web configuration
- Test Nginx configuration
- Reload Nginx

## Validation

After deployment, validate that all endpoints are responding correctly:

```bash
# Run the validation script
./deployment/nginx/scripts/validate-endpoints.sh
```

Expected output:
```
Testing / ... PASS (200) - Main landing page
Testing /apex/ ... PASS (200) - Apex SPA (if published)
Testing /beta/ ... PASS (200) - Beta SPA (if published)
Testing /api/ ... PASS (404) - Backend API (may return 404 if no root handler)
Testing /stream/ ... PASS (200) - Streaming service
Testing /hls/ ... PASS (200) - HLS streaming
Testing /health ... PASS (200) - Nginx health check

✅ All critical endpoints are responding!
```

### Manual Validation

You can also test endpoints manually with `curl`:

```bash
# Test main site
curl -I https://n3xuscos.online/

# Test API endpoint
curl -I https://n3xuscos.online/api/

# Test streaming
curl -I https://n3xuscos.online/stream/

# Test HLS
curl -I https://n3xuscos.online/hls/

# Test health
curl https://n3xuscos.online/health
```

## Service Configuration

Ensure the following services are running:

### Backend API (Port 3000)
```bash
# Check if running
curl -I http://127.0.0.1:3000/

# Start if needed (example using PM2)
pm2 start backend
```

### Streaming Service (Port 3043)
```bash
# Check if running
curl -I http://127.0.0.1:3043/stream/

# Start if needed (example using PM2)
pm2 start streaming-service
```

### Optional: Python Backend (Port 3001)

If you're using the Python backend, uncomment the `/py/` location block in the configuration files.

```bash
# Check if running
curl -I http://127.0.0.1:3001/
```

## Rollback

Both deployment scripts create timestamped backups. To rollback:

### Vanilla Nginx Rollback
```bash
# Find the backup
ls -la /etc/nginx/sites-enabled/n3xuscos.online.bak.*

# Restore the backup
sudo cp /etc/nginx/sites-enabled/n3xuscos.online.bak.YYYYMMDDHHMMSS /etc/nginx/sites-enabled/n3xuscos.online

# Test and reload
sudo nginx -t && sudo systemctl reload nginx
```

### Plesk Rollback
```bash
# Find the backup
ls -la /var/www/vhosts/system/n3xuscos.online/conf/vhost_nginx.conf.bak.*

# Restore the backup
sudo cp /var/www/vhosts/system/n3xuscos.online/conf/vhost_nginx.conf.bak.YYYYMMDDHHMMSS \
     /var/www/vhosts/system/n3xuscos.online/conf/vhost_nginx.conf

# Rebuild Plesk configuration
sudo plesk repair web -domain n3xuscos.online -y

# Test and reload
sudo nginx -t && sudo systemctl reload nginx
```

## Troubleshooting

### Site Still Showing Welcome Page

1. **Check active configuration:**
   ```bash
   sudo nginx -T | grep "server_name n3xuscos.online"
   ```

2. **Verify symlink exists (vanilla Nginx):**
   ```bash
   ls -la /etc/nginx/sites-enabled/n3xuscos.online
   ```

3. **Check for default_server conflicts:**
   ```bash
   sudo nginx -T | grep "default_server"
   ```

### API/Stream Endpoints Return 502 Bad Gateway

1. **Check if backend services are running:**
   ```bash
   curl -I http://127.0.0.1:3000/
   curl -I http://127.0.0.1:3043/stream/
   ```

2. **Check service logs:**
   ```bash
   pm2 logs backend
   pm2 logs streaming-service
   ```

3. **Verify firewall rules:**
   ```bash
   sudo ufw status
   ```

### SSL Certificate Errors

1. **Verify certificate files exist:**
   ```bash
   ls -la /etc/ssl/ionos/fullchain.pem
   ls -la /etc/ssl/ionos/privkey.pem
   ```

2. **Check certificate expiration:**
   ```bash
   openssl x509 -in /etc/ssl/ionos/fullchain.pem -noout -dates
   ```

### Check Nginx Error Logs

```bash
# View recent errors
sudo tail -n 50 /var/log/nginx/error.log

# Follow error log in real-time
sudo tail -f /var/log/nginx/error.log
```

## Port Configuration

The default configuration uses these ports:

| Service | Port | Path | Purpose |
|---------|------|------|---------|
| Backend API | 3000 | `/api/` | Main Node.js backend |
| Python Backend | 3001 | `/py/` | Optional Python FastAPI backend |
| Streaming | 3043 | `/stream/`, `/hls/` | Streaming and HLS service |

To change these ports, edit the appropriate configuration file and update the `proxy_pass` directives.

## File Paths

### Vanilla Nginx
- Document root: `/var/www/nexus-cos`
- Apex SPA: `/var/www/nexus-cos/apex/`
- Beta SPA: `/var/www/nexus-cos/beta/`
- Core assets: `/var/www/nexus-cos/core/`

### Plesk
- Document root: `/var/www/vhosts/n3xuscos.online/httpdocs`
- Apex SPA: `/var/www/vhosts/n3xuscos.online/httpdocs/apex/`
- Beta SPA: `/var/www/vhosts/n3xuscos.online/httpdocs/beta/`
- Core assets: `/var/www/vhosts/n3xuscos.online/httpdocs/core/`

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Nginx error logs
3. Verify all services are running
4. Run the validation script for diagnostics

## License

Part of the Nexus COS project.
