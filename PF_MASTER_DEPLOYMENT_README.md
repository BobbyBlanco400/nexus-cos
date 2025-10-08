# Nexus COS - Master PF Deployment

## Overview

This is the comprehensive Platform Fix (PF) deployment suite for Nexus COS that addresses the critical IP vs domain routing issue and ensures consistent branding/OI across the entire platform.

## Problem Addressed

When accessing the platform via IP address (`http://74.208.155.161/`), users experienced different UI/branding compared to accessing via domain (`https://nexuscos.online/`). This was caused by:

1. **Nginx Default Server Routing** - IP requests hit a different server block
2. **Environment Variable Mismatches** - VITE_API_URL pointed to localhost
3. **Cached Static Assets** - Old assets served from incorrect paths
4. **CSP Blocking** - Content Security Policy blocked inline styles/scripts
5. **Missing default_server Directive** - IP requests not properly captured

## Solution Architecture

This PF implements a multi-layered fix:

### 1. Nginx Configuration
- **default_server directive** on both HTTP and HTTPS
- **Multiple server_name** entries (domain, www, IP, fallback)
- **HTTP to HTTPS redirect** for all requests
- **IP requests redirect** to domain for consistency

### 2. Environment Validation
- Checks for `.env` file
- Validates `VITE_API_URL=/api` (not localhost)
- Creates missing directories
- Sets proper permissions

### 3. Frontend Builds
- Rebuilds all frontend applications with correct env vars
- Admin panel (React)
- Creator hub (React)
- Main frontend (Vite)
- Module diagram

### 4. Branding Enforcement
- Consolidates legacy branding references
- Updates CSS variables
- Validates branding assets
- Ensures consistency across all apps

### 5. Security & Caching
- Proper CSP headers for React apps
- Static assets cached for 1 year (immutable)
- HTML files not cached (always fresh)
- Security headers configured

## Quick Start

### Option 1: Master Deployment (Recommended)

Run the comprehensive master script that executes all PF components:

```bash
# For VPS deployment (recommended path):
cd /opt/nexus-cos
sudo bash pf-master-deployment.sh

# Or from any location where the repository is cloned:
cd /path/to/nexus-cos
sudo bash pf-master-deployment.sh

# With custom domain:
cd /opt/nexus-cos
sudo DOMAIN=nexuscos.online bash pf-master-deployment.sh
```

This single command:
- Performs pre-flight checks
- Executes IP/domain unification
- Enforces branding consistency
- Validates deployment
- Generates comprehensive report

**Note:** The scripts now automatically detect their location and work from any directory where the repository is installed.

### Option 2: Individual Scripts

Execute individual components as needed:

```bash
# 1. IP/Domain routing fix
sudo bash pf-ip-domain-unification.sh

# With custom domain:
sudo DOMAIN=yourdomain.com bash pf-ip-domain-unification.sh

# 2. Branding enforcement
bash scripts/branding-enforce.sh

# 3. Validation
bash validate-ip-domain-routing.sh
```

## What Gets Deployed

### Directory Structure

```
/var/www/nexus-cos/
├── frontend/
│   └── dist/              # Main Vite app
├── admin/
│   └── build/             # Admin panel (React)
├── creator-hub/
│   └── build/             # Creator hub (React)
└── diagram/               # Module diagram

/etc/nginx/
├── sites-available/
│   └── nexuscos           # Main configuration
└── sites-enabled/
    └── nexuscos           # Symlink

/home/runner/work/nexus-cos/nexus-cos/
├── .env                   # Environment variables
└── branding/              # Branding assets
```

### Nginx Configuration Highlights

```nginx
# HTTP - Domain requests
server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    return 301 https://$server_name$request_uri;
}

# HTTP - Default for IP requests
server {
    listen 80 default_server;
    server_name _;
    return 301 https://nexuscos.online$request_uri;
}

# HTTPS - Unified server (handles all)
server {
    listen 443 ssl http2 default_server;
    server_name nexuscos.online www.nexuscos.online 74.208.155.161 _;
    # ... configuration
}
```

## Verification

After deployment, verify the fix:

### Automated Validation

```bash
bash validate-ip-domain-routing.sh
```

This checks:
- Nginx service status
- Configuration syntax
- default_server presence
- HTTP/HTTPS redirects
- Application routing
- API proxying
- Security headers
- File permissions

### Manual Testing

```bash
# 1. Test IP redirect
curl -I http://74.208.155.161/
# Expected: 301 redirect to domain

# 2. Test domain access
curl -I https://nexuscos.online/
# Expected: 200 OK or 301 to /admin/

# 3. Test admin panel
curl -L https://nexuscos.online/admin/
# Expected: 200 OK with HTML

# 4. Test API proxy
curl https://nexuscos.online/health
# Expected: "OK - Nexus COS Platform"
```

### Browser Testing

1. **Clear browser cache completely** (Ctrl+Shift+Delete, "All time")
2. Visit `http://74.208.155.161/` - should redirect to domain
3. Visit `https://nexuscos.online/` - should load correctly
4. Check browser console - no CSP errors
5. Verify branding is consistent

## Scripts Reference

### Main Deployment Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `pf-master-deployment.sh` | Complete deployment with all PF components | `sudo bash pf-master-deployment.sh` |
| `pf-ip-domain-unification.sh` | IP/domain routing fix only | `sudo bash pf-ip-domain-unification.sh` |
| `validate-ip-domain-routing.sh` | Validation and testing | `bash validate-ip-domain-routing.sh` |

### Supporting Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `scripts/branding-enforce.sh` | Branding consolidation | `bash scripts/branding-enforce.sh` |

## Documentation

### Quick Reference
- **QUICK_FIX_IP_DOMAIN.md** - Fast reference guide with single-command fix
- **PF_IP_DOMAIN_UNIFICATION.md** - Complete technical documentation
- **PF_INDEX.md** - Master index of all PF resources

### Configuration Files
- **deployment/nginx/nexuscos-unified.conf** - Production-ready Nginx config
- **.env** - Environment variables (auto-created/validated)
- **pfs/final/branding-pf.yml** - Branding configuration

## Key Features

### 1. Consistent Routing
- ✅ IP and domain serve identical content
- ✅ No more "different UI" issue
- ✅ Proper default_server configuration
- ✅ Intelligent redirects

### 2. Environment Validation
- ✅ Validates VITE_API_URL
- ✅ Checks for localhost references
- ✅ Auto-creates missing configs
- ✅ Production-ready settings

### 3. Optimized Caching
- ✅ Static assets: 1 year, immutable
- ✅ HTML files: no-cache (always fresh)
- ✅ API responses: not cached
- ✅ Proper Cache-Control headers

### 4. Security Headers
- ✅ X-Frame-Options: SAMEORIGIN
- ✅ X-Content-Type-Options: nosniff
- ✅ X-XSS-Protection: enabled
- ✅ HSTS: max-age 31536000
- ✅ CSP: configured for React

### 5. React Router Support
- ✅ Proper fallback handling
- ✅ @location blocks for SPAs
- ✅ try_files configuration
- ✅ No 404s on client routes

## Troubleshooting

### Issue: Still seeing different UI

**Solution:**
```bash
# 1. Clear browser cache completely
Ctrl + Shift + Delete → All time → Clear data

# 2. Hard reload
Ctrl + Shift + R

# 3. Test in incognito
Ctrl + Shift + N
```

### Issue: 502 Bad Gateway

**Solution:**
```bash
# Check backend services
systemctl status nexus-backend
systemctl status nexus-python

# Restart if needed
systemctl restart nexus-backend
systemctl restart nexus-python

# Check logs
journalctl -u nexus-backend -f
```

### Issue: CSP Violations

**Solution:**
Already fixed in the unified config. If still occurring:
```bash
# Verify CSP header
curl -I https://nexuscos.online/ | grep -i content-security

# Should include: 'unsafe-inline' 'unsafe-eval'
```

### Issue: Assets not loading

**Solution:**
```bash
# Check file permissions
ls -la /var/www/nexuscos.online/

# Fix permissions
sudo chown -R www-data:www-data /var/www/nexuscos.online/
sudo chmod -R 755 /var/www/nexuscos.online/
```

### Issue: Nginx configuration error

**Solution:**
```bash
# Test configuration
nginx -t

# View detailed error
nginx -t 2>&1

# Restore backup if needed
sudo cp /etc/nginx/sites-available/nexuscos.backup.[timestamp] \
        /etc/nginx/sites-available/nexuscos
sudo nginx -t && sudo systemctl reload nginx
```

## Rollback Procedure

If issues occur and you need to rollback:

```bash
# 1. Restore previous Nginx config
sudo cp /etc/nginx/sites-available/nexuscos.backup.[timestamp] \
        /etc/nginx/sites-available/nexuscos

# 2. Test configuration
sudo nginx -t

# 3. Reload Nginx
sudo systemctl reload nginx

# 4. Verify rollback
curl -I https://nexuscos.online/
```

Backups are automatically created with timestamps during deployment.

## Monitoring

### Logs to Monitor

```bash
# Nginx access log
tail -f /var/log/nginx/nexus-cos.access.log

# Nginx error log
tail -f /var/log/nginx/nexus-cos.error.log

# Backend service logs
journalctl -u nexus-backend -f
journalctl -u nexus-python -f
```

### Health Checks

```bash
# Platform health
curl https://nexuscos.online/health

# API health
curl https://nexuscos.online/api/health

# Python API health
curl https://nexuscos.online/py/health
```

## Success Criteria

After deployment, verify these indicators:

- [ ] ✅ Both IP and domain show identical UI
- [ ] ✅ No redirect loops
- [ ] ✅ Admin panel loads at /admin/
- [ ] ✅ Creator hub loads at /creator-hub/
- [ ] ✅ API endpoints respond correctly
- [ ] ✅ No CSP errors in browser console
- [ ] ✅ Static assets load with correct paths
- [ ] ✅ Branding is consistent across all pages
- [ ] ✅ No 502/503 errors
- [ ] ✅ SSL certificate valid

## Time Estimates

- **Master deployment**: 5-10 minutes
- **IP/Domain fix only**: 3-5 minutes
- **Validation**: 1-2 minutes
- **Browser testing**: 2-3 minutes
- **Total**: ~15 minutes

## Integration with Existing Systems

This PF integrates seamlessly with:

- ✅ All existing PF scripts (deploy-pf.sh, etc.)
- ✅ Docker Compose configurations
- ✅ PM2 process management
- ✅ SSL/TLS certificates
- ✅ Backend services (Node.js, Python)
- ✅ Database connections
- ✅ Redis caching

## Support

### Documentation
- PF_IP_DOMAIN_UNIFICATION.md - Full technical docs
- QUICK_FIX_IP_DOMAIN.md - Quick reference
- PF_INDEX.md - Master index

### Reports
- /tmp/nexus-cos-pf-report.txt - Individual script report
- /tmp/nexus-cos-master-pf-report.txt - Master deployment report
- /tmp/nexus-cos-validation-report.txt - Validation results

### Logs
- /var/log/nginx/nexus-cos.access.log
- /var/log/nginx/nexus-cos.error.log
- journalctl -u nexus-backend
- journalctl -u nexus-python

## Best Practices

1. **Always run validation after deployment**
2. **Clear browser cache before testing**
3. **Monitor logs for the first 24 hours**
4. **Test all major features after deployment**
5. **Keep backups of working configurations**
6. **Document any custom changes**
7. **Update DNS if using CDN**

## Production Checklist

Before considering deployment complete:

- [ ] Run master deployment script
- [ ] Validation script passes all checks
- [ ] Browser testing successful (cache cleared)
- [ ] All features work correctly
- [ ] Logs show no errors
- [ ] Backend services running
- [ ] SSL certificates valid
- [ ] Monitoring set up
- [ ] Backups verified
- [ ] Team notified

## Next Steps

1. **Deploy to production** using master script
2. **Validate deployment** with automated checks
3. **Test in browser** with cache cleared
4. **Monitor logs** for 24 hours
5. **Document any issues** encountered
6. **Update team** on deployment status

## Conclusion

This Master PF Deployment provides a comprehensive solution to the IP vs domain routing issue while ensuring consistent branding and optimal performance across the entire Nexus COS platform.

The deployment is:
- ✅ **Automated** - Single command execution
- ✅ **Validated** - Comprehensive testing built-in
- ✅ **Documented** - Complete guides and references
- ✅ **Production-ready** - Tested and verified
- ✅ **Reversible** - Automatic backups and rollback procedure

---

**Version:** 1.0.0  
**Last Updated:** 2024-10-05  
**Maintained By:** Nexus COS Team  
**Status:** ✅ PRODUCTION READY
