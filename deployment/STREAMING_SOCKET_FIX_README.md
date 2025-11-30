# Nexus COS - Streaming Socket.IO Fix & Deployment Guide

> **Issue**: `/streaming/socket.io/` was returning `maintenance.html` error while `/socket.io/` worked correctly.
>
> **Root Cause**: The streaming namespace path lacked WebSocket upgrade support in proxy configurations.

---

## 📋 Table of Contents

1. [Problem Summary](#problem-summary)
2. [Pre-Deployment Cleanup](#pre-deployment-cleanup)
3. [Solution Overview](#solution-overview)
4. [Nginx Configuration](#nginx-configuration)
5. [Apache/Plesk Configuration](#apacheplesk-configuration)
6. [Deployment Commands](#deployment-commands)
7. [Verification Steps](#verification-steps)
8. [Troubleshooting](#troubleshooting)
9. [Service Port Reference](#service-port-reference)

---

## 🔍 Problem Summary

**Symptoms observed:**
```
=== https://nexuscos.online/ ===
200  ✅

=== https://nexuscos.online/api/health ===
404  ❌

=== https://nexuscos.online/socket.io/?EIO=4&transport=polling ===
{"sid":"...","upgrades":["websocket"],...}  ✅

=== https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling ===
Cannot GET /error_docs/maintenance.html  ❌
```

**Root Cause**: Missing proxy configuration for `/streaming/socket.io/` endpoint with proper WebSocket upgrade headers.

---

## 🧹 Pre-Deployment Cleanup

### Step 1: Remove Backup Files Causing Nginx Errors

The nginx error you encountered was caused by a backup file in sites-enabled:

```bash
# Check for problematic backup files
ls -la /etc/nginx/sites-enabled/*.bak* 2>/dev/null

# Remove the specific backup file causing the error
sudo rm /etc/nginx/sites-enabled/nexuscos.online.bak.2025-11-28_21:33:26

# Or move it to a safe location
sudo mkdir -p ~/nginx-backups
sudo mv /etc/nginx/sites-enabled/*.bak* ~/nginx-backups/ 2>/dev/null
```

### Step 2: Verify Nginx Configuration

```bash
# Test nginx configuration
sudo nginx -t

# Expected output:
# nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful
```

---

## 🛠 Solution Overview

Two configuration methods are provided:

| Method | Use Case |
|--------|----------|
| **Nginx** | Standard web server setup |
| **Apache/Plesk** | Plesk-managed hosting environments |

Both configurations add:
- `/socket.io/` → WebSocket proxy with upgrade support
- `/streaming/socket.io/` → WebSocket proxy (aliases to same backend)
- Proper headers for WebSocket connections
- Long timeout (86400s) for persistent connections

---

## 🔧 Nginx Configuration

### Location Block to Add

Add this to your nginx site configuration (e.g., `/etc/nginx/sites-available/nexuscos.online`):

```nginx
# Socket.IO for Streaming Service
location /streaming/socket.io/ {
    proxy_pass http://127.0.0.1:3001/socket.io/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_upgrade;
    proxy_buffering off;
    proxy_read_timeout 86400;
}

# Root Socket.IO endpoint
location /socket.io/ {
    proxy_pass http://127.0.0.1:3001/socket.io/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_upgrade;
    proxy_buffering off;
    proxy_read_timeout 86400;
}
```

### Apply Nginx Changes

```bash
# Test configuration
sudo nginx -t

# Reload nginx (if test passes)
sudo systemctl reload nginx

# Or restart if reload doesn't work
sudo systemctl restart nginx
```

---

## 🌐 Apache/Plesk Configuration

### Option A: Use the Automated Setup Script

```bash
# Navigate to repository (clone if needed)
cd /opt/nexus-cos
git pull origin copilot/fix-proxy-configuration-errors

# Run the setup script
sudo ./deployment/apache/setup-plesk-apache.sh nexuscos.online
```

### Option B: Download and Run Script Directly

```bash
# Download the script
curl -O https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/copilot/fix-proxy-configuration-errors/deployment/apache/setup-plesk-apache.sh

# Make executable and run
chmod +x setup-plesk-apache.sh
sudo ./setup-plesk-apache.sh nexuscos.online
```

### Option C: Manual Plesk Configuration

1. Go to **Plesk Panel** → **Domains** → **nexuscos.online**
2. Click **Apache & nginx Settings**
3. Enable **Additional Apache directives**
4. Paste the contents of `deployment/apache/nexuscos.online.conf` into **Additional directives for HTTPS**
5. Click **Apply**

### Required Apache Modules

Ensure these modules are enabled:

```bash
sudo a2enmod proxy proxy_http proxy_wstunnel rewrite headers
sudo systemctl restart apache2
```

---

## 🚀 Deployment Commands

### Quick Deployment Sequence

```bash
# 1. Navigate to repository
cd /opt/nexus-cos

# 2. Pull latest changes
git pull origin copilot/fix-proxy-configuration-errors

# 3. Clean up backup files
sudo rm /etc/nginx/sites-enabled/*.bak* 2>/dev/null

# 4. Test nginx configuration
sudo nginx -t

# 5. Reload nginx
sudo systemctl reload nginx

# 6. Verify services are running
pm2 status

# 7. Test endpoints
curl -s https://nexuscos.online/socket.io/?EIO=4&transport=polling
curl -s https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling
```

### Full Reset Commands (if needed)

```bash
# Stop all services
pm2 stop all

# Restart nginx
sudo systemctl restart nginx

# Start services
pm2 start all

# Check status
pm2 status
```

---

## ✅ Verification Steps

### Step 1: Check Service Status

```bash
# Check PM2 processes
pm2 status

# Check nginx status
sudo systemctl status nginx

# Check if ports are listening
sudo netstat -tlnp | grep -E ':(3001|3010|3014|3020|3030|4000|9001|9002|9003|9004)'
```

### Step 2: Test Endpoints

```bash
# Test main site
curl -sS -o /dev/null -w "%{http_code}\n" https://nexuscos.online/

# Test API health
curl -sS -o /dev/null -w "%{http_code}\n" https://nexuscos.online/api/health

# Test root Socket.IO (should return JSON with sid)
curl -s "https://nexuscos.online/socket.io/?EIO=4&transport=polling"

# Test streaming Socket.IO (should return JSON with sid, NOT maintenance.html)
curl -s "https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling"
```

### Expected Results

| Endpoint | Expected Response |
|----------|-------------------|
| `/` | HTTP 200 |
| `/api/health` | HTTP 200 or JSON response |
| `/socket.io/?EIO=4&transport=polling` | JSON: `{"sid":"...","upgrades":["websocket"],...}` |
| `/streaming/socket.io/?EIO=4&transport=polling` | JSON: `{"sid":"...","upgrades":["websocket"],...}` |

### Step 3: Test WebSocket Connection

```bash
# Install wscat if not available
npm install -g wscat

# Test WebSocket connection
wscat -c "wss://nexuscos.online/socket.io/?EIO=4&transport=websocket"
wscat -c "wss://nexuscos.online/streaming/socket.io/?EIO=4&transport=websocket"
```

---

## 🔧 Troubleshooting

### Issue: "events" directive error

**Error:**
```
"events" directive is not allowed here in /etc/nginx/sites-enabled/nexuscos.online.bak...
```

**Solution:**
```bash
sudo rm /etc/nginx/sites-enabled/*.bak*
sudo nginx -t && sudo systemctl reload nginx
```

### Issue: Script not found

**Error:**
```
-bash: ./deployment/apache/setup-plesk-apache.sh: No such file or directory
```

**Solution:**
```bash
# Clone or navigate to the repository first
cd /opt/nexus-cos
git pull origin copilot/fix-proxy-configuration-errors

# Then run the script
./deployment/apache/setup-plesk-apache.sh nexuscos.online
```

### Issue: 502 Bad Gateway

**Possible causes:**
1. Backend service not running
2. Wrong port in proxy configuration

**Solution:**
```bash
# Check if services are running
pm2 status

# Check what's listening on the expected ports
sudo netstat -tlnp | grep 3001

# Restart services if needed
pm2 restart all
```

### Issue: WebSocket connection fails

**Possible causes:**
1. Missing `Upgrade` headers in proxy config
2. Firewall blocking WebSocket connections

**Solution:**
```bash
# Check nginx error logs
sudo tail -f /var/log/nginx/error.log

# Check Apache error logs (if using Apache)
sudo tail -f /var/log/apache2/error.log
```

---

## 📊 Service Port Reference

| Service | Port | Health Endpoint |
|---------|------|-----------------|
| Main API | 3001 | `/health` |
| V-Suite | 3010 | `/v-suite/health` |
| Keys Service | 3014 | `/keys/health` |
| Creator Hub | 3020 | `/creator-hub/health` |
| PuaboVerse | 3030 | `/puaboverse/health` |
| Gateway | 4000 | `/health/gateway` |
| AI Dispatch | 9001 | `/puabo-nexus/dispatch/health` |
| Driver Backend | 9002 | `/puabo-nexus/driver/health` |
| Fleet Manager | 9003 | `/puabo-nexus/fleet/health` |
| Route Optimizer | 9004 | `/puabo-nexus/routes/health` |

---

## 📁 Files Changed in This Fix

| File | Description |
|------|-------------|
| `nginx.conf` | Added Socket.IO location blocks |
| `deployment/nginx/*.conf` | Updated all nginx configs |
| `nginx/conf.d/nexus-proxy.conf` | Added Socket.IO routes |
| `deployment/apache/nexuscos.online.conf` | New Apache config for Plesk |
| `deployment/apache/setup-plesk-apache.sh` | Automated setup script |

---

## 📞 Support

If you encounter issues after following this guide:

1. Check logs: `sudo tail -100 /var/log/nginx/error.log`
2. Verify services: `pm2 status`
3. Test endpoints: Use the curl commands in Verification Steps
4. Review this README for troubleshooting tips

---

*Last updated: November 30, 2025*
*Branch: `copilot/fix-proxy-configuration-errors`*
