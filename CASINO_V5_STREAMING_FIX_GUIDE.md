# Casino V5 & Streaming Module - Deployment Fix Guide

## Overview

This guide addresses the critical issues with Casino V5 graphics (wireframe/missing textures) and Streaming module deployment in the Nexus COS platform.

## Problem Summary

### 1. Casino V5 Graphics Issue (CRITICAL)
- **Problem**: Casino loads V5 engine but cannot find 3D assets (textures, sounds, models)
- **Cause**: Assets are in wrong folder location
- **Impact**: Casino displays wireframes instead of textured models

### 2. Streaming Module Issue (MEDIUM)
- **Problem**: Streaming interface not loading at `/streaming`
- **Cause**: Missing index.html in streaming directory
- **Impact**: 404 error when accessing streaming URL

### 3. Service Cache Issue (HIGH)
- **Problem**: Nginx and backend API not serving updated content
- **Cause**: Services need restart to recognize new files
- **Impact**: Changes not reflected even after file updates

## Automated Solution

### Quick Fix (Recommended)

Run the automated deployment script:

```bash
cd /var/www/nexus-cos
sudo ./fix-casino-v5-streaming-deployment.sh
```

This script automatically:
1. ✅ Copies Casino V5 assets to correct location
2. ✅ Sets up Streaming module frontend
3. ✅ Restarts Nginx web server
4. ✅ Restarts puabo-api backend service
5. ✅ Verifies deployment success

### Manual Fix (Alternative)

If you prefer manual execution, follow these steps:

#### Step 1: Fix Casino V5 Graphics

```bash
# Create casino public directory structure
mkdir -p /var/www/nexus-cos/modules/casino-nexus/frontend/public

# Copy assets to casino directory
cp -r /var/www/nexus-cos/modules/casino-nexus/frontend/public/assets \
     /var/www/nexus-cos/modules/casino-nexus/frontend/public/

# Set proper permissions
chown -R www-data:www-data /var/www/nexus-cos/modules/casino-nexus/frontend/public
chmod -R 755 /var/www/nexus-cos/modules/casino-nexus/frontend/public
```

#### Step 2: Setup Streaming Module

```bash
# Create streaming directory structure
mkdir -p /var/www/nexus-cos/modules/puabo-ott-tv-streaming/frontend/public

# Copy streaming frontend
cp /var/www/nexus-cos/modules/puabo-ott-tv-streaming/frontend/index.html \
   /var/www/nexus-cos/modules/puabo-ott-tv-streaming/frontend/public/

# Set proper permissions
chown -R www-data:www-data /var/www/nexus-cos/modules/puabo-ott-tv-streaming/frontend/public
chmod -R 755 /var/www/nexus-cos/modules/puabo-ott-tv-streaming/frontend/public
```

#### Step 3: Restart Services

```bash
# Restart Nginx
systemctl restart nginx

# Restart Backend API
cd /var/www/nexus-cos
docker-compose restart puabo-api
```

## Directory Structure

After deployment, the structure should be:

```
/var/www/nexus-cos/
├── modules/
│   ├── casino-nexus/
│   │   ├── frontend/
│   │   │   ├── index.html
│   │   │   └── public/
│   │   │       ├── index.html
│   │   │       └── assets/
│   │   │           ├── textures/
│   │   │           │   └── manifest.json
│   │   │           ├── models/
│   │   │           │   └── manifest.json
│   │   │           ├── sounds/
│   │   │           │   └── manifest.json
│   │   │           └── shaders/
│   │   └── services/
│   └── puabo-ott-tv-streaming/
│       ├── frontend/
│       │   ├── index.html
│       │   └── public/
│       │       └── index.html
│       └── services/
```

## Verification

After running the fix, verify:

### 1. Casino V5 Graphics
```bash
# Check if assets directory exists
ls -la /var/www/nexus-cos/modules/casino-nexus/frontend/public/assets

# Check if index.html exists
ls -la /var/www/nexus-cos/modules/casino-nexus/frontend/public/index.html

# Test in browser
curl -I https://n3xuscos.online/casino
```

### 2. Streaming Module
```bash
# Check if streaming index exists
ls -la /var/www/nexus-cos/modules/puabo-ott-tv-streaming/frontend/public/index.html

# Test in browser
curl -I https://n3xuscos.online/streaming
```

### 3. Services Status
```bash
# Check Nginx
systemctl status nginx

# Check Docker containers
docker ps | grep puabo-api

# Check Nginx logs
tail -f /var/log/nginx/error.log
```

## Testing

### Browser Testing

1. **Clear Browser Cache**
   - Chrome/Edge: `Ctrl+Shift+Delete` → Clear cached images and files
   - Firefox: `Ctrl+Shift+Delete` → Cookies and Site Data

2. **Test Casino V5**
   - Navigate to: `https://n3xuscos.online/casino`
   - Verify: No wireframes, all textures loaded
   - Check: 3D models display correctly
   - Confirm: Sounds play when interacting

3. **Test Streaming**
   - Navigate to: `https://n3xuscos.online/streaming`
   - Verify: Netflix-style interface loads
   - Check: All sections display properly
   - Confirm: Navigation works

## Nginx Configuration

The platform should have nginx configured to serve these routes:

```nginx
# Casino V5 route
location /casino {
    alias /var/www/nexus-cos/modules/casino-nexus/frontend/public;
    index index.html;
    try_files $uri $uri/ /index.html;
}

# Streaming route
location /streaming {
    alias /var/www/nexus-cos/modules/puabo-ott-tv-streaming/frontend/public;
    index index.html;
    try_files $uri $uri/ /index.html;
}
```

## Troubleshooting

### Issue: Casino still shows wireframes

**Solution:**
1. Clear browser cache completely
2. Check browser console for 404 errors on asset files
3. Verify assets directory permissions: `ls -la /var/www/nexus-cos/modules/casino-nexus/frontend/public/assets`
4. Check nginx error logs: `tail -f /var/log/nginx/error.log`

### Issue: Streaming returns 404

**Solution:**
1. Verify index.html exists: `ls -la /var/www/nexus-cos/modules/puabo-ott-tv-streaming/frontend/public/index.html`
2. Check nginx configuration includes streaming location block
3. Restart nginx: `sudo systemctl restart nginx`
4. Check file permissions: `chmod 755 /var/www/nexus-cos/modules/puabo-ott-tv-streaming/frontend/public/index.html`

### Issue: Changes not reflected after deployment

**Solution:**
1. Restart nginx: `sudo systemctl restart nginx`
2. Clear browser cache
3. Try incognito/private browsing mode
4. Check if files were actually copied: `ls -la [target-directory]`

### Issue: Permission denied errors

**Solution:**
```bash
# Fix ownership
sudo chown -R www-data:www-data /var/www/nexus-cos/modules/casino-nexus/frontend/public
sudo chown -R www-data:www-data /var/www/nexus-cos/modules/puabo-ott-tv-streaming/frontend/public

# Fix permissions
sudo chmod -R 755 /var/www/nexus-cos/modules/casino-nexus/frontend/public
sudo chmod -R 755 /var/www/nexus-cos/modules/puabo-ott-tv-streaming/frontend/public
```

## Docker Configuration

Update docker-compose.yml to mount these directories:

```yaml
services:
  nginx:
    volumes:
      - ./modules/casino-nexus/frontend/public:/var/www/casino:ro
      - ./modules/puabo-ott-tv-streaming/frontend/public:/var/www/streaming:ro
```

## Asset Management

### Adding New Casino V5 Assets

1. Place assets in: `/var/www/nexus-cos/modules/casino-nexus/frontend/public/assets/`
2. Organize by type: textures/, models/, sounds/, shaders/
3. Update manifest.json files
4. Restart nginx to clear cache

### Asset Formats

- **Textures**: PNG, JPG, WebP (2048x2048 recommended)
- **Models**: GLTF/GLB (Draco compressed)
- **Sounds**: MP3, OGG (192kbps)
- **Shaders**: GLSL

## Performance Optimization

### Enable Nginx Caching

Add to nginx configuration:

```nginx
location /casino/assets {
    alias /var/www/nexus-cos/modules/casino-nexus/frontend/public/assets;
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

### Enable Gzip Compression

```nginx
gzip on;
gzip_types text/html text/css application/javascript application/json image/svg+xml;
gzip_min_length 1000;
```

## Maintenance

### Regular Checks

```bash
# Weekly: Check disk usage
df -h /var/www/nexus-cos

# Weekly: Check service status
systemctl status nginx
docker ps

# Monthly: Review logs for errors
tail -100 /var/log/nginx/error.log
```

### Backup Procedure

```bash
# Backup before updates
tar -czf casino-assets-backup-$(date +%Y%m%d).tar.gz \
  /var/www/nexus-cos/modules/casino-nexus/frontend/public/assets

tar -czf streaming-backup-$(date +%Y%m%d).tar.gz \
  /var/www/nexus-cos/modules/puabo-ott-tv-streaming/frontend/public
```

## Support

If issues persist after following this guide:

1. Check deployment logs: `journalctl -u nginx -n 100`
2. Check docker logs: `docker logs puabo-api --tail 100`
3. Verify nginx configuration: `nginx -t`
4. Check SELinux if enabled: `getenforce`

## Deployment Checklist

- [ ] Run deployment script or manual steps
- [ ] Verify Casino V5 assets copied
- [ ] Verify Streaming index.html created
- [ ] Nginx restarted successfully
- [ ] puabo-api restarted successfully
- [ ] Casino V5 accessible at /casino
- [ ] Streaming accessible at /streaming
- [ ] No wireframes in Casino (textures loading)
- [ ] Browser cache cleared
- [ ] Tested in multiple browsers
- [ ] File permissions correct (755)
- [ ] Nginx error log clean
- [ ] Docker containers running

## Rollback Procedure

If deployment causes issues:

```bash
# Stop services
systemctl stop nginx
docker-compose stop puabo-api

# Restore from backup
tar -xzf casino-assets-backup-[date].tar.gz -C /
tar -xzf streaming-backup-[date].tar.gz -C /

# Restart services
systemctl start nginx
docker-compose start puabo-api
```

---

**Document Version:** 1.0.0  
**Last Updated:** 2025-12-21  
**Author:** Nexus COS Platform Team
