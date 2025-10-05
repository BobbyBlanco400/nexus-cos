# Quick Fix: IP vs Domain Routing Issue

## Problem
Accessing `http://74.208.155.161/` shows different UI than `https://nexuscos.online/`

## Root Cause
Nginx's `default_server` block serves different content for IP requests

## Quick Solution

### 1. Run the Fix Script

```bash
cd /home/runner/work/nexus-cos/nexus-cos
sudo bash pf-ip-domain-unification.sh
```

This single command:
- ✅ Validates environment variables
- ✅ Rebuilds all frontend applications
- ✅ Configures Nginx with `default_server` directive
- ✅ Sets up unified IP/domain routing
- ✅ Enforces consistent branding
- ✅ Generates verification report

### 2. Validate the Fix

```bash
./validate-ip-domain-routing.sh
```

### 3. Test in Browser

```bash
# Clear browser cache
Ctrl + Shift + Delete

# Test both URLs
http://74.208.155.161/      # Should redirect to domain
https://nexuscos.online/     # Should load correctly
```

## What Changed

### Before
```nginx
server {
    listen 443 ssl;
    server_name nexuscos.online www.nexuscos.online;
    # IP requests go to default server ❌
}
```

### After
```nginx
server {
    listen 443 ssl http2 default_server;
    server_name nexuscos.online www.nexuscos.online 74.208.155.161 _;
    # IP requests handled by same server ✅
}
```

## Key Configuration Changes

1. **Default Server Directive**
   - Added `default_server` to port 443
   - Captures all unmatched requests including IP

2. **Multiple Server Names**
   - `nexuscos.online` - Main domain
   - `www.nexuscos.online` - WWW variant
   - `74.208.155.161` - IP address
   - `_` - Fallback for any other name

3. **HTTP Redirect**
   - IP HTTP requests redirect to domain HTTPS
   - Ensures consistent access method

4. **Environment Variables**
   - `VITE_API_URL=/api` (not localhost)
   - Routes through Nginx proxy

## Verification Checklist

- [ ] IP HTTP redirects to domain HTTPS
- [ ] Domain HTTPS loads correctly
- [ ] Admin panel accessible at both URLs
- [ ] Creator hub accessible at both URLs
- [ ] API endpoints responding
- [ ] No CSP errors in browser console
- [ ] Branding consistent across all pages
- [ ] Static assets load with correct paths

## Quick Tests

```bash
# Test IP redirect
curl -I http://74.208.155.161/

# Test domain access
curl -I https://nexuscos.online/

# Test with Host header
curl -I -H "Host: nexuscos.online" http://74.208.155.161/

# Test admin panel
curl -L https://nexuscos.online/admin/

# Test API
curl https://nexuscos.online/health
```

## Troubleshooting

### Issue: Still seeing different UI

**Solution:**
```bash
# Clear browser cache completely
Ctrl + Shift + Delete (All time)

# Hard reload
Ctrl + Shift + R
```

### Issue: 502 Bad Gateway

**Solution:**
```bash
# Check backend services
systemctl status nexus-backend
systemctl status nexus-python

# Check Nginx logs
tail -f /var/log/nginx/nexus-cos.error.log
```

### Issue: CSP Violations

**Solution:**
Already fixed in unified config with:
```nginx
Content-Security-Policy: "... 'unsafe-inline' 'unsafe-eval' ..."
```

### Issue: Cached Assets

**Solution:**
Static assets now use:
```nginx
expires 1y;
add_header Cache-Control "public, immutable";
```

## Rollback

If issues occur:

```bash
# Restore backup
sudo cp /etc/nginx/sites-available/nexuscos.backup.[timestamp] \
        /etc/nginx/sites-available/nexuscos

# Reload
sudo nginx -t && sudo systemctl reload nginx
```

## Support Files

- **Main Script:** `pf-ip-domain-unification.sh`
- **Validation:** `validate-ip-domain-routing.sh`
- **Documentation:** `PF_IP_DOMAIN_UNIFICATION.md`
- **Nginx Config:** `deployment/nginx/nexuscos-unified.conf`

## Expected Behavior

### HTTP Requests
```
http://74.208.155.161/
    ↓ (301 Redirect)
https://nexuscos.online/
```

### HTTPS Requests
```
https://74.208.155.161/  →  Serves admin panel ✅
https://nexuscos.online/  →  Serves admin panel ✅
(Same content, same branding)
```

## Success Indicators

✅ Both URLs show identical UI
✅ Branding is consistent
✅ No redirect loops
✅ No 502/503 errors
✅ Static assets load correctly
✅ No CSP errors in console
✅ API calls work through Nginx proxy

## Time to Fix

- **Script Execution:** 2-5 minutes
- **Validation:** 1 minute
- **Browser Testing:** 2 minutes
- **Total:** ~10 minutes

## Next Steps After Fix

1. Monitor logs for any issues
2. Test all major features
3. Clear CDN cache if using one
4. Update DNS if needed
5. Document any custom changes

## Contact

For issues, check:
1. `/tmp/nexus-cos-pf-report.txt` - Deployment report
2. `/var/log/nginx/nexus-cos.error.log` - Nginx errors
3. `journalctl -u nexus-backend -f` - Backend logs
