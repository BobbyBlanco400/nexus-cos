# Nexus COS VPS Deployment Guide

## Overview

This guide covers the deployment of Nexus COS to a production VPS with full Nginx security hardening, including:

- Strict Transport Security (HSTS)
- Content Security Policy (CSP) without backticks
- X-Content-Type-Options, X-Frame-Options, Referrer-Policy headers
- HTTP→HTTPS redirect using `$host` variable
- Removal of conflicting Nginx configurations
- Systemd backend service ownership validation

## Quick Start

### Option 1: Automated Deployment

Run the complete VPS deployment script:

```bash
# Using default settings (VPS: 74.208.155.161, Domain: n3xuscos.online)
bash scripts/vps-deploy.sh

# With custom settings
VPS_HOST=your.vps.ip DOMAIN=yourdomain.com bash scripts/vps-deploy.sh
```

### Option 2: Manual Nginx Hardening Only

If you only need to apply Nginx security headers and redirect fixes:

```bash
# On the VPS directly
sudo bash scripts/pf-fix-nginx-headers-redirect.sh

# Or with custom domain
sudo DOMAIN=yourdomain.com bash scripts/pf-fix-nginx-headers-redirect.sh
```

### Option 3: Remote Nginx Hardening

Upload and run the hardening script on a remote VPS:

```bash
# Upload script
scp scripts/pf-fix-nginx-headers-redirect.sh root@74.208.155.161:/opt/nexus-cos/scripts/

# Execute remotely
ssh root@74.208.155.161 "sudo DOMAIN=n3xuscos.online bash /opt/nexus-cos/scripts/pf-fix-nginx-headers-redirect.sh"
```

## What Gets Configured

### Security Headers

The deployment adds the following security headers to `/etc/nginx/conf.d/zz-security-headers.conf`:

1. **Strict-Transport-Security**: `max-age=31536000; includeSubDomains; preload`
   - Forces HTTPS for 1 year
   
2. **Content-Security-Policy**: 
   ```
   default-src 'self' https://n3xuscos.online; 
   img-src 'self' data: blob: https://n3xuscos.online; 
   script-src 'self' 'unsafe-inline' https://n3xuscos.online; 
   style-src 'self' 'unsafe-inline' https://n3xuscos.online; 
   connect-src 'self' https://n3xuscos.online https://n3xuscos.online/streaming wss://n3xuscos.online ws://n3xuscos.online;
   ```
   - No backticks or escape codes
   
3. **X-Content-Type-Options**: `nosniff`
   - Prevents MIME type sniffing
   
4. **X-Frame-Options**: `SAMEORIGIN`
   - Prevents clickjacking
   
5. **Referrer-Policy**: `no-referrer-when-downgrade`
   - Controls referrer information

### HTTP→HTTPS Redirect

The deployment updates all Nginx vhosts listening on port 80 to use:

```nginx
return 301 https://$host$request_uri;
```

This ensures:
- Both apex and www domains redirect correctly
- No hardcoded domain names in the redirect
- Works for any subdomain

### Configuration Cleanup

The deployment script:
- Removes stray backticks from all Nginx `.conf` files
- Ensures `include /etc/nginx/conf.d/*.conf;` is present in `nginx.conf`
- Validates and reloads Nginx configuration

## Verification

### Verify HTTPS Headers

```bash
curl -fsSI https://n3xuscos.online/ | tr -d '\r' | egrep -i '^(Strict-Transport-Security|Content-Security-Policy|X-Content-Type-Options|X-Frame-Options|Referrer-Policy):'
```

Expected output:
```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
Content-Security-Policy: default-src 'self' https://n3xuscos.online; ...
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Referrer-Policy: no-referrer-when-downgrade
```

### Verify HTTP Redirect

```bash
curl -fsSI http://n3xuscos.online/ | tr -d '\r' | egrep -i '^(HTTP|Location):'
```

Expected output:
```
HTTP/1.1 301 Moved Permanently
Location: https://n3xuscos.online/
```

### Verify Backend Port Ownership

```bash
ssh root@74.208.155.161 'ss -ltnp | grep ":3001"'
```

Expected: Port 3001 should be owned by systemd-managed `python3` process, not PM2.

### Check for Nginx Warnings

```bash
ssh root@74.208.155.161 'sudo nginx -t'
```

Should show no warnings about:
- Conflicting server names
- Protocol options redefined
- Duplicate configurations

## Troubleshooting

### Conflicting Nginx Configurations

If you see "conflicting server name" warnings:

```bash
# Remove duplicate/conflicting configurations
ssh root@74.208.155.161 "sudo rm -f /etc/nginx/conf.d/pf_gateway_n3xuscos.online.conf /etc/nginx/conf.d/pf_gateway_www.n3xuscos.online.conf"

# Test and reload
ssh root@74.208.155.161 "sudo nginx -t && sudo systemctl reload nginx"
```

### Port 3001 Owned by PM2

If PM2 is holding port 3001 instead of systemd:

```bash
# Stop PM2 processes
ssh root@74.208.155.161 "pm2 delete all || true"

# Start systemd service
ssh root@74.208.155.161 "systemctl enable --now nexus-python-api.service || systemctl restart nexus-python-api.service"

# Verify
ssh root@74.208.155.161 "ss -ltnp | grep ':3001'"
```

### Backticks Still Present

If backticks are still showing in responses:

```bash
# Remove backticks from security headers file
ssh root@74.208.155.161 "sudo sed -i 's/\`//g' /etc/nginx/conf.d/zz-security-headers.conf"

# Test and reload
ssh root@74.208.155.161 "sudo nginx -t && sudo systemctl reload nginx"
```

### Headers Not Showing on /health Endpoint

This is expected behavior. Nginx will return 404 for non-existent paths, but headers should still be present:

```bash
curl -fsSI https://n3xuscos.online/health | tr -d '\r' | egrep -i '^(Strict-Transport-Security|Content-Security-Policy|X-Content-Type-Options|X-Frame-Options|Referrer-Policy):' || true
```

## Environment Variables

### VPS Deployment Script (`scripts/vps-deploy.sh`)

- **VPS_HOST**: VPS IP address or hostname (default: `74.208.155.161`)
- **VPS_USER**: SSH user for VPS access (default: `root`)
- **DOMAIN**: Target domain name (default: `n3xuscos.online`)

### Nginx Hardening Script (`scripts/pf-fix-nginx-headers-redirect.sh`)

- **DOMAIN**: Target domain name (default: `n3xuscos.online`)

## Manual Deployment Steps

If you prefer to deploy manually:

1. **Connect to VPS**:
   ```bash
   ssh root@74.208.155.161
   ```

2. **Create deployment directory**:
   ```bash
   mkdir -p /opt/nexus-cos/scripts
   ```

3. **Upload hardening script**:
   ```bash
   # From local machine
   scp scripts/pf-fix-nginx-headers-redirect.sh root@74.208.155.161:/opt/nexus-cos/scripts/
   ```

4. **Run hardening script**:
   ```bash
   # On VPS
   sudo DOMAIN=n3xuscos.online bash /opt/nexus-cos/scripts/pf-fix-nginx-headers-redirect.sh
   ```

5. **Verify deployment**:
   ```bash
   curl -fsSI https://n3xuscos.online/ | tr -d '\r' | egrep -i '^(Strict-Transport-Security|Content-Security-Policy|X-Content-Type-Options|X-Frame-Options|Referrer-Policy):'
   ```

## Acceptance Criteria

✅ All acceptance criteria from the problem statement:

1. **Security Headers Present**: Strict-Transport-Security, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, and CSP show on HTTPS responses
2. **No Backticks**: CSP and all headers are free of backticks or escape codes
3. **HTTP Redirect Works**: HTTP requests return `Location: https://n3xuscos.online/...`
4. **No Nginx Warnings**: No conflicting server names or protocol redefinition warnings
5. **Systemd Owns Port 3001**: Port 3001 owned by systemd-managed python3, not PM2
6. **Automatic Hardening**: Re-running `scripts/vps-deploy.sh` applies headers and redirect hardening automatically

## Files Modified/Created

- `scripts/pf-fix-nginx-headers-redirect.sh` - Updated CSP and redirect patterns
- `scripts/vps-deploy.sh` - New deployment orchestration script
- `DEPLOYMENT_INSTRUCTIONS.md` - This documentation file

## Next Steps

After deployment:

1. Test site access: `https://n3xuscos.online/`
2. Verify all security headers are present
3. Confirm HTTP→HTTPS redirect works for apex and www
4. Check backend service health
5. Monitor Nginx logs for any issues

## Support

For issues or questions:
- Check Nginx logs: `ssh root@74.208.155.161 "sudo tail -f /var/log/nginx/error.log"`
- Verify configuration: `ssh root@74.208.155.161 "sudo nginx -t"`
- Review systemd services: `ssh root@74.208.155.161 "systemctl status nexus-python-api.service"`
