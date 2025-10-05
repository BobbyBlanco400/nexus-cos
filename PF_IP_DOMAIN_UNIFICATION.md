# Nexus COS - IP/Domain Routing Unification PF

## Overview

This Platform Fix (PF) resolves the critical issue where accessing Nexus COS via IP address (`http://74.208.155.161/`) shows different UI/branding than accessing via domain (`https://nexuscos.online/`).

## Problem Statement

### The Issue

When accessing the platform by raw IP address, users were experiencing:
- Different UI appearance compared to domain access
- Missing or incorrect branding assets
- Potential CSP (Content Security Policy) violations
- Cached static assets from incorrect paths
- Environment variable mismatches

### Root Cause

The problem stems from Nginx routing behavior:

1. **Default Server Block**: When accessing by IP, Nginx routes to the `default_server` block, which may serve different static files or proxy to different backends
2. **Host Header Mismatch**: IP requests don't match the `server_name` directive, causing Nginx to use fallback configuration
3. **Asset Path Differences**: Static assets cached with domain paths fail when loaded via IP
4. **Environment Variables**: `VITE_API_URL` and similar vars may be hardcoded to localhost in development

## Solution

This PF implements a comprehensive fix that ensures **identical content** is served regardless of access method (IP or domain).

### Key Changes

1. **Nginx Configuration**
   - Configure `default_server` directive on HTTPS block
   - Include IP address in `server_name` directive
   - Redirect HTTP IP requests to HTTPS domain
   - Ensure consistent routing for all paths

2. **Environment Variables**
   - Validate `VITE_API_URL=/api` (not localhost)
   - Ensure production environment parity

3. **Build Process**
   - Rebuild all frontend applications with correct env vars
   - Deploy to consistent paths
   - Set proper file permissions

4. **Branding Enforcement**
   - Consolidate legacy branding references
   - Ensure consistent assets across all apps
   - Validate branding integrity

## Usage

### Prerequisites

- Root or sudo access on the VPS
- Nginx installed and configured
- Node.js and npm installed
- SSL certificates in place (`/etc/letsencrypt/live/nexuscos.online/`)

### Installation

```bash
# 1. Clone or pull latest repository
cd /home/runner/work/nexus-cos/nexus-cos

# 2. Run the PF script
sudo bash pf-ip-domain-unification.sh
```

### What the Script Does

The script performs these steps automatically:

1. **Environment Verification**
   - Checks for `.env` file
   - Validates `VITE_API_URL` setting
   - Creates missing directories
   - Verifies build paths

2. **Frontend Build**
   - Builds main frontend application
   - Builds admin panel
   - Builds creator hub
   - Deploys module diagram
   - Sets proper permissions

3. **Nginx Configuration**
   - Creates unified configuration file
   - Sets up `default_server` directive
   - Configures IP and domain routing
   - Adds security headers
   - Sets up proper caching
   - Configures API proxying

4. **Routing Verification**
   - Tests Nginx configuration
   - Provides verification commands
   - Checks service status

5. **Branding Enforcement**
   - Runs branding consolidation
   - Validates assets
   - Ensures consistency

6. **Report Generation**
   - Creates comprehensive deployment report
   - Lists all configurations
   - Provides testing checklist

## Nginx Configuration Details

### HTTP to HTTPS Redirect

```nginx
# Redirect domain HTTP to HTTPS
server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    return 301 https://$server_name$request_uri;
}

# Redirect IP HTTP to domain HTTPS
server {
    listen 80 default_server;
    server_name _;
    return 301 https://nexuscos.online$request_uri;
}
```

### HTTPS with Default Server

```nginx
server {
    listen 443 ssl http2 default_server;
    server_name nexuscos.online www.nexuscos.online 74.208.155.161 _;
    
    # This captures both domain and IP requests
    # Serves identical content for all
}
```

### Key Features

- **default_server**: Captures all unmatched requests (including IP)
- **Multiple server_name**: Handles domain, www, IP, and fallback
- **Consistent Paths**: All locations use absolute paths
- **Proper Caching**: Static assets cached for 1 year, HTML not cached
- **CSP Headers**: Configured to allow React inline styles/scripts
- **API Proxying**: Routes API calls through Nginx to backend services

## Verification

After running the script, verify the fix works:

### 1. Test Domain Access

```bash
# Should return 200 OK
curl -I https://nexuscos.online/

# Should serve admin panel
curl -L https://nexuscos.online/admin/
```

### 2. Test IP Access

```bash
# Should redirect to domain
curl -I http://74.208.155.161/

# Test with Host header
curl -I -H "Host: nexuscos.online" http://74.208.155.161/
```

### 3. Test Index Files

```bash
# Verify correct HTML is served
curl -sSL -H "Host: nexuscos.online" http://127.0.0.1/admin/index.html | head -n 30
```

### 4. Test API Endpoints

```bash
# Should proxy to backend
curl -I https://nexuscos.online/api/health

# Platform health check
curl https://nexuscos.online/health
```

### 5. Browser Testing

1. Clear browser cache (Ctrl+Shift+F5)
2. Visit `http://74.208.155.161/` - should redirect to domain
3. Visit `https://nexuscos.online/` - should load correctly
4. Check browser console for CSP errors (should be none)
5. Verify branding looks consistent

## Common Issues Resolved

### Issue 1: Different UI on IP Access
**Fixed**: Default server now serves same content as domain

### Issue 2: CSP Blocking Assets
**Fixed**: CSP headers updated to allow React inline styles/scripts

### Issue 3: Stale Cached Assets
**Fixed**: Cache-Control headers properly configured with immutable flag

### Issue 4: Environment Variable Mismatches
**Fixed**: Script validates and corrects `VITE_API_URL`

### Issue 5: React Router Not Working
**Fixed**: Proper fallback locations for SPA routing

### Issue 6: 502 Bad Gateway Errors
**Fixed**: Increased proxy timeouts and proper upstream configuration

## File Structure

After deployment, the file structure is:

```
/var/www/nexus-cos/
├── frontend/
│   └── dist/           # Main frontend app
├── admin/
│   └── build/          # Admin panel
├── creator-hub/
│   └── build/          # Creator hub
└── diagram/            # Module diagram

/etc/nginx/
├── sites-available/
│   └── nexuscos        # Main configuration
└── sites-enabled/
    └── nexuscos        # Symlink to available

/var/log/nginx/
├── nexus-cos.access.log
└── nexus-cos.error.log
```

## Environment Variables

Ensure these are set in `.env`:

```bash
# Production API URL - routes through Nginx
VITE_API_URL=/api

# Do NOT use localhost in production
# ❌ VITE_API_URL=http://localhost:3000
# ✅ VITE_API_URL=/api
```

## Integration with Other PF Scripts

This PF integrates with and uses functionality from:

- `scripts/branding-enforce.sh` - Branding consolidation
- `deployment/nginx/nexuscos_pf.js` - Platform validation
- `comprehensive-frontend-fix.sh` - Frontend deployment patterns
- `master-fix-trae-solo.sh` - Service configuration
- `production-deploy-firewall.sh` - Base deployment

## Monitoring

After deployment, monitor these logs:

```bash
# Nginx access log
tail -f /var/log/nginx/nexus-cos.access.log

# Nginx error log
tail -f /var/log/nginx/nexus-cos.error.log

# Backend service logs
journalctl -u nexus-backend -f
journalctl -u nexus-python -f
```

## Rollback

If issues occur, rollback using the backup:

```bash
# Restore previous Nginx config
sudo cp /etc/nginx/sites-available/nexuscos.backup.[timestamp] \
        /etc/nginx/sites-available/nexuscos

# Test and reload
sudo nginx -t && sudo systemctl reload nginx
```

## Support

For issues or questions:

1. Check `/tmp/nexus-cos-pf-report.txt` for detailed status
2. Review Nginx logs for errors
3. Verify backend services are running
4. Clear browser cache completely
5. Test with curl to isolate client vs server issues

## Checklist

- [ ] Script executed successfully
- [ ] Nginx configuration valid
- [ ] Domain access works (https://nexuscos.online/)
- [ ] IP redirects to domain (http://74.208.155.161/)
- [ ] Admin panel loads correctly
- [ ] Creator hub loads correctly
- [ ] API endpoints respond
- [ ] No CSP errors in browser console
- [ ] Branding consistent across all pages
- [ ] Static assets load with correct paths
- [ ] Browser cache cleared and retested

## Technical Details

### Security Headers

```nginx
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: [configured for React]
```

### Cache Strategy

- **Static Assets** (JS, CSS, images): 1 year, immutable
- **HTML Files**: No cache (always fresh)
- **Diagram**: Dynamic, no cache
- **API Responses**: Not cached (bypass)

### Proxy Configuration

```nginx
# Node.js Backend
/api/ → http://127.0.0.1:3000/

# Python Backend
/py/ → http://127.0.0.1:8000/

Timeouts: 60s connect/send/read
```

## Conclusion

This PF ensures that Nexus COS presents a consistent, properly-branded interface regardless of whether users access via IP address or domain name. All routing goes through the same server block, serving identical static assets and proxying to the same backend services.

The fix is production-ready and addresses all common issues related to IP vs domain routing discrepancies.
