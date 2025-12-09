# Nginx Configuration Fix - README

## Overview

This fix addresses critical Nginx configuration issues in the Nexus COS Platform:

1. **Duplicate server_name entries** on port 80 causing nginx warnings
2. **Backticks in headers** (CSP and Location headers)
3. **Inconsistent redirect patterns** using `$server_name` instead of `$host`
4. **Duplicate CSP headers** in individual vhosts instead of centralized configuration
5. **Duplicate gateway configurations** causing conflicts

## Files Modified

### Main Script
- `scripts/pf-fix-nginx-headers-redirect.sh` - Enhanced hardening script with:
  - Processes all vhosts in `/etc/nginx` and `/var/www/vhosts/system`
  - Normalizes redirect patterns to `https://$host$request_uri`
  - Removes duplicate CSP headers from vhosts
  - Strips backticks using perl (`\x60` removal)
  - Removes duplicate gateway and redirect configs
  - Handles Plesk vhost configurations

### Deployment Nginx Configurations Fixed
All deployment nginx configs now use `return 301 https://$host$request_uri;`:
- `deployment/nginx/nexuscos.online-ssl.conf`
- `deployment/nginx/beta.nexuscos.online-enhanced.conf`
- `deployment/nginx/nexuscos-unified.conf`
- `deployment/nginx/beta.nexuscos.online.conf`
- `deployment/nginx/nexuscos.online.conf`
- `deployment/nginx/nexuscos.online-enhanced.conf`
- `deployment/nginx/production.nexuscos.online.conf`

### New Script
- `scripts/vps-nginx-fix-one-liner.sh` - Standalone VPS deployment script

## What Was Fixed

### 1. Redirect Pattern Normalization
**Before:**
```nginx
return 301 https://$server_name$request_uri;
```

**After:**
```nginx
return 301 https://$host$request_uri;
```

**Why:** `$host` preserves the exact hostname from the request (www or apex), while `$server_name` uses the first server_name in the list, which can cause issues with www vs apex redirects.

### 2. Centralized Security Headers
Security headers are now defined once in `/etc/nginx/conf.d/zz-security-headers.conf`:
- Strict-Transport-Security
- Content-Security-Policy
- X-Content-Type-Options
- X-Frame-Options
- Referrer-Policy
- X-XSS-Protection

Individual vhosts no longer duplicate these headers.

### 3. Backtick Removal
All backticks (`` ` ``) are stripped from nginx configs using:
```bash
perl -0777 -pe 's/\x60//g' -i <file>
```

### 4. Duplicate Config Removal
The script removes:
- `zz-redirect.conf` when Plesk vhost exists
- `pf_gateway_${DOMAIN}.conf`
- `pf_gateway_www.${DOMAIN}.conf`

## Usage

### Option 1: Run the Enhanced Hardening Script
```bash
sudo bash scripts/pf-fix-nginx-headers-redirect.sh
```

Or with a custom domain:
```bash
sudo DOMAIN=yourdomain.com bash scripts/pf-fix-nginx-headers-redirect.sh
```

### Option 2: Use the VPS One-Liner
Display the one-liner command:
```bash
bash scripts/vps-nginx-fix-one-liner.sh
```

Execute it directly:
```bash
sudo bash scripts/vps-nginx-fix-one-liner.sh --execute
```

### Option 3: Copy/Paste One-Liner to VPS
The one-liner is also available in the `vps-nginx-fix-one-liner.sh` script output. Simply run:
```bash
bash scripts/vps-nginx-fix-one-liner.sh
```

Then copy the displayed command and run it on your VPS.

## Verification

After running the fix, verify the results:

### Check HTTPS Headers
```bash
curl -I https://nexuscos.online/ | grep -E "Strict-Transport-Security|Content-Security-Policy|X-Content-Type-Options|X-Frame-Options|Referrer-Policy"
```

**Expected output (without backticks):**
```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
Content-Security-Policy: default-src 'self' https://nexuscos.online; img-src 'self' data: blob: https://nexuscos.online; script-src 'self' 'unsafe-inline' https://nexuscos.online; style-src 'self' 'unsafe-inline' https://nexuscos.online; connect-src 'self' https://nexuscos.online https://nexuscos.online/streaming wss://nexuscos.online ws://nexuscos.online;
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Referrer-Policy: no-referrer-when-downgrade
```

### Check HTTP Redirect
```bash
curl -I http://nexuscos.online/
```

**Expected output (without backticks):**
```
HTTP/1.1 301 Moved Permanently
Location: https://nexuscos.online/
```

### Check for Nginx Warnings
```bash
sudo nginx -t
```

**Expected:** No duplicate server_name warnings

## Technical Details

### Redirect Pattern Fix
The script processes vhosts in multiple locations:
- `/etc/nginx/` (standard nginx configs)
- `/var/www/vhosts/system/` (Plesk vhosts)

It normalizes these patterns:
1. `return 301 https://$server_name$request_uri;` → `return 301 https://$host$request_uri;`
2. `return 301 https://domain.com$request_uri;` → `return 301 https://$host$request_uri;`
3. `return 301 https://;` → `return 301 https://$host$request_uri;`

### CSP Header Removal
All `add_header Content-Security-Policy` lines are removed from individual vhosts:
```bash
sed -i "/add_header[[:space:]]\+Content-Security-Policy/d" "$VF"
```

### Backtick Stripping
Using perl for reliable binary character removal:
```bash
find "$ROOT" -type f -name "*.conf" -print0 | xargs -0 perl -0777 -pe "s/\x60//g" -i
```

Fallback to sed if perl is not available:
```bash
find "$ROOT" -type f -name "*.conf" -exec sed -i "s/\`//g" {} \;
```

### Plesk Detection
The script detects Plesk vhosts:
```bash
if ls /var/www/vhosts/system/"$DOMAIN"/conf/vhost_nginx.conf >/dev/null 2>&1 || \
   ls /var/www/vhosts/system/"$DOMAIN"/conf/nginx.conf >/dev/null 2>&1; then
  # Plesk handles redirects, remove our custom redirect file
  rm -f /etc/nginx/conf.d/zz-redirect.conf
fi
```

## Troubleshooting

### Issue: Headers still show backticks
**Solution:** Check for additional vhost includes:
```bash
grep -r '`' /etc/nginx/ /var/www/vhosts/
```

### Issue: Duplicate server_name warnings persist
**Solution:** Find all files with the domain:
```bash
grep -r "server_name.*nexuscos.online" /etc/nginx/ /var/www/vhosts/
```

Remove or consolidate duplicate entries.

### Issue: Redirect uses wrong domain
**Solution:** Verify `$host` variable in redirect:
```bash
grep "return 301" /etc/nginx/sites-enabled/* /etc/nginx/conf.d/*
```

Should show: `return 301 https://$host$request_uri;`

## References

- Problem Statement: Lines 174, 216-228, 248-254 in `scripts/pf-fix-nginx-headers-redirect.sh`
- Nginx documentation: http://nginx.org/en/docs/http/ngx_http_core_module.html#var_host
- Content-Security-Policy: https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP

## Support

If you encounter issues after running this fix:
1. Check nginx error logs: `sudo tail -f /var/log/nginx/error.log`
2. Validate nginx config: `sudo nginx -t`
3. Review changes in backup files (created with timestamp)
4. Run the verification commands above

## Changelog

### 2025-12-09
- Enhanced `pf-fix-nginx-headers-redirect.sh` to process all vhosts
- Added duplicate config removal
- Added backtick stripping with perl
- Fixed redirect patterns in deployment configs
- Created VPS one-liner deployment script
- Added comprehensive verification with backtick detection
