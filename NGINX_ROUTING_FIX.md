# Nginx Routing Fix for nexuscos.online - Deployment Guide

## Executive Summary

This document provides instructions for fixing the Nginx routing issue where **nexuscos.online** was serving the Nginx welcome page instead of the published site.

**Problem**: The domain returns the Nginx welcome page for all paths (/, /api, /stream).  
**Solution**: Deploy correct vhost configuration with proper routing, proxy headers, and WebSocket support.  
**Time to Deploy**: ~5 minutes  
**Rollback**: Automated backup created before deployment

---

## Quick Start

### For Standard Linux Servers (Vanilla Nginx)

```bash
cd /path/to/nexus-cos
sudo ./deployment/nginx/scripts/deploy-vanilla.sh
./deployment/nginx/scripts/validate-endpoints.sh
```

### For IONOS/Plesk Managed Servers

```bash
cd /path/to/nexus-cos
sudo ./deployment/nginx/scripts/deploy-plesk.sh
./deployment/nginx/scripts/validate-endpoints.sh
```

---

## What This Fix Does

### Configuration Changes

✅ **Enables proper vhost** for nexuscos.online (was missing or not enabled)  
✅ **Sets correct document root** to `/var/www/nexus-cos` (was pointing to default)  
✅ **Adds HTTP to HTTPS redirect** for security  
✅ **Configures API proxy** to backend on port 3000 with WebSocket support  
✅ **Configures streaming proxy** to service on port 3043 with WebSocket support  
✅ **Adds security headers** (HSTS, X-Frame-Options, etc.)  
✅ **Enables SPA routing** for /apex/, /beta/, /core/ with try_files fallback  
✅ **Adds health check endpoint** at /health  

### Routes Configured

| Path | Destination | Purpose |
|------|-------------|---------|
| `/` | `/var/www/nexus-cos/index.html` | Main landing page |
| `/apex/*` | `/var/www/nexus-cos/apex/` | Apex SPA application |
| `/beta/*` | `/var/www/nexus-cos/beta/` | Beta SPA application |
| `/core/*` | `/var/www/nexus-cos/core/` | Core assets |
| `/api/*` | `http://127.0.0.1:3000/` | Backend API (Node.js) |
| `/stream/*` | `http://127.0.0.1:3043/stream/` | Streaming service |
| `/hls/*` | `http://127.0.0.1:3043/hls/` | HLS streaming |
| `/health` | Nginx health check | Returns "ok" |

---

## Prerequisites

### Required Services

Before deploying, ensure these services are running:

```bash
# Backend API (port 3000)
curl -I http://127.0.0.1:3000/

# Streaming Service (port 3043)
curl -I http://127.0.0.1:3043/stream/
```

If services are not running:
```bash
# Using PM2 (example)
pm2 start backend
pm2 start streaming-service
```

### SSL Certificates

Ensure IONOS SSL certificates exist:
```bash
ls -la /etc/ssl/ionos/fullchain.pem
ls -la /etc/ssl/ionos/privkey.pem
```

If using Let's Encrypt instead, update the paths in the configuration files:
```nginx
ssl_certificate /etc/letsencrypt/live/nexuscos.online/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/nexuscos.online/privkey.pem;
```

---

## Detailed Deployment Steps

### Option 1: Vanilla Nginx (Recommended for Standard Servers)

1. **Clone or update the repository**
   ```bash
   cd /path/to/nexus-cos
   git pull origin main
   ```

2. **Review the configuration** (optional)
   ```bash
   cat deployment/nginx/sites-available/nexuscos.online
   ```

3. **Run the deployment script**
   ```bash
   sudo ./deployment/nginx/scripts/deploy-vanilla.sh
   ```

4. **Verify deployment**
   ```bash
   ./deployment/nginx/scripts/validate-endpoints.sh
   ```

### Option 2: Plesk Deployment (For IONOS/Plesk Servers)

1. **Clone or update the repository**
   ```bash
   cd /path/to/nexus-cos
   git pull origin main
   ```

2. **Verify Plesk domain exists**
   ```bash
   plesk bin domain --list | grep nexuscos.online
   ```

3. **Review the configuration** (optional)
   ```bash
   cat deployment/nginx/plesk/vhost_nginx.conf
   ```

4. **Run the deployment script**
   ```bash
   sudo ./deployment/nginx/scripts/deploy-plesk.sh
   ```

5. **Verify deployment**
   ```bash
   ./deployment/nginx/scripts/validate-endpoints.sh
   ```

---

## Validation

### Automated Validation

The validation script tests all configured endpoints:

```bash
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

### Manual Browser Testing

1. **Main site**: https://nexuscos.online/ (should show your landing page, not Nginx welcome)
2. **API**: https://nexuscos.online/api/ (should proxy to backend, may return 404)
3. **Streaming**: https://nexuscos.online/stream/ (should proxy to streaming service)
4. **Health**: https://nexuscos.online/health (should return "ok")

---

## Troubleshooting

### Issue: Still Seeing Nginx Welcome Page

**Diagnosis:**
```bash
# Check which config is active
sudo nginx -T | grep -A 5 "server_name nexuscos.online"

# Check sites-enabled symlink (vanilla Nginx)
ls -la /etc/nginx/sites-enabled/nexuscos.online

# Verify document root
sudo nginx -T | grep -A 2 "root "
```

**Solution:**
```bash
# Re-run deployment
sudo ./deployment/nginx/scripts/deploy-vanilla.sh  # or deploy-plesk.sh

# Force reload
sudo systemctl restart nginx
```

### Issue: 502 Bad Gateway on /api or /stream

**Diagnosis:**
```bash
# Check if services are running
curl -I http://127.0.0.1:3000/
curl -I http://127.0.0.1:3043/stream/

# Check service status
pm2 list
```

**Solution:**
```bash
# Start services
pm2 start backend
pm2 start streaming-service

# Verify ports are listening
sudo netstat -tlnp | grep -E ":(3000|3043)"
```

### Issue: SSL Certificate Errors

**Diagnosis:**
```bash
# Verify certificate files
ls -la /etc/ssl/ionos/fullchain.pem
ls -la /etc/ssl/ionos/privkey.pem

# Check certificate validity
openssl x509 -in /etc/ssl/ionos/fullchain.pem -noout -dates
```

**Solution:**
- If files don't exist, update certificate paths in configuration
- If expired, renew certificates
- If using Let's Encrypt, update paths to `/etc/letsencrypt/live/nexuscos.online/`

### Issue: Configuration Test Fails

**Diagnosis:**
```bash
sudo nginx -t
```

**Common errors and solutions:**
- **"unknown directive"**: Check for typos in configuration
- **"duplicate location"**: Check for conflicting location blocks
- **"cannot load certificate"**: Verify SSL certificate paths

---

## Rollback Procedure

Both deployment scripts create automatic timestamped backups.

### Find Backup

```bash
# Vanilla Nginx
ls -la /etc/nginx/sites-enabled/nexuscos.online.bak.*

# Plesk
ls -la /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf.bak.*
```

### Restore Backup (Vanilla)

```bash
# Replace TIMESTAMP with actual timestamp
sudo cp /etc/nginx/sites-enabled/nexuscos.online.bak.TIMESTAMP \
     /etc/nginx/sites-enabled/nexuscos.online

# Test and reload
sudo nginx -t && sudo systemctl reload nginx
```

### Restore Backup (Plesk)

```bash
# Replace TIMESTAMP with actual timestamp
sudo cp /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf.bak.TIMESTAMP \
     /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf

# Rebuild and reload
sudo plesk repair web -domain nexuscos.online -y
sudo nginx -t && sudo systemctl reload nginx
```

---

## Port Configuration Reference

If your services run on different ports, update these lines in the configuration:

### API Backend
```nginx
# Default: port 3000
location ^~ /api/ {
    proxy_pass http://127.0.0.1:3000/;
    # ... rest of config
}
```

### Streaming Service
```nginx
# Default: port 3043
location ^~ /stream/ {
    proxy_pass http://127.0.0.1:3043/stream/;
    # ... rest of config
}
```

### Python Backend (Optional)
```nginx
# Default: port 3001 (commented out)
# Uncomment if using Python backend
# location ^~ /py/ {
#     proxy_pass http://127.0.0.1:3001/;
#     # ... rest of config
# }
```

---

## Additional Resources

- **Full Documentation**: [deployment/nginx/README.md](deployment/nginx/README.md)
- **Quick Reference**: [deployment/nginx/QUICK_REFERENCE.md](deployment/nginx/QUICK_REFERENCE.md)
- **Configuration Files**: [deployment/nginx/](deployment/nginx/)

---

## Support Checklist

If you need help, gather this information:

- [ ] Output of `sudo nginx -t`
- [ ] Output of `sudo nginx -T | grep -A 10 "server_name nexuscos.online"`
- [ ] Last 50 lines of error log: `sudo tail -n 50 /var/log/nginx/error.log`
- [ ] Service status: `pm2 list` or `systemctl status <service-name>`
- [ ] Port listeners: `sudo netstat -tlnp | grep -E ":(3000|3043)"`
- [ ] Validation script output: `./deployment/nginx/scripts/validate-endpoints.sh`

---

## Summary

This deployment fixes the Nginx routing for nexuscos.online by:

1. Creating a proper vhost configuration
2. Enabling the vhost (disabling default)
3. Configuring correct document root
4. Adding proxy rules for API and streaming with WebSocket support
5. Implementing security headers and HSTS
6. Supporting SPA routing for frontend applications

The deployment is automated, includes automatic backups, and provides validation tools to ensure everything works correctly.

**Deployment time**: ~5 minutes  
**Downtime**: <10 seconds (Nginx reload)  
**Rollback time**: <1 minute
