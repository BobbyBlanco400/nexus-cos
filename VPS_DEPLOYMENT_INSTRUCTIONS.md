# Nexus COS - VPS Deployment Instructions

## Overview

This guide provides step-by-step instructions for deploying Nexus COS on your VPS using the fixed deployment scripts. The scripts have been updated to work correctly on your VPS without hardcoded paths.

## What Was Fixed

The deployment scripts previously had hardcoded paths to `/home/runner/work/nexus-cos/nexus-cos` (GitHub Actions runner directory), which prevented them from working on your VPS. 

### Changes Made:
- ✅ **Dynamic Path Detection**: Scripts now automatically detect their location
- ✅ **VPS Compatible**: Works from `/var/www/nexus-cos` or any directory
- ✅ **Environment Variables**: Support for `DOMAIN`, `SERVER_IP`, and `REPO_ROOT` overrides
- ✅ **No Hardcoded Paths**: All GitHub Actions paths removed

## Prerequisites

1. VPS server with:
   - Ubuntu/Debian Linux
   - Nginx installed
   - Node.js and npm installed
   - Root/sudo access

2. Repository copied to VPS at `/var/www/nexus-cos` (recommended)

## Deployment Steps

### Step 1: Upload Repository to VPS

```bash
# On your local machine, create a zip of the repository
cd /path/to/nexus-cos
zip -r nexus-cos.zip . -x "*.git*" "node_modules/*" "*/node_modules/*"

# Upload to VPS (replace with your VPS details)
scp nexus-cos.zip user@your-vps-ip:/tmp/

# On VPS, extract to /var/www/nexus-cos
ssh user@your-vps-ip
sudo mkdir -p /var/www/nexus-cos
sudo unzip /tmp/nexus-cos.zip -d /var/www/nexus-cos
```

### Step 2: Verify Scripts are Executable

```bash
cd /var/www/nexus-cos
ls -l pf-master-deployment.sh

# Make scripts executable if needed
sudo chmod +x pf-master-deployment.sh
sudo chmod +x pf-ip-domain-unification.sh
sudo chmod +x validate-ip-domain-routing.sh
```

### Step 3: Run Master Deployment

**IMPORTANT**: Copy the command exactly as shown. Do NOT include any leading hyphens (-) or bullets.

```bash
cd /var/www/nexus-cos
sudo DOMAIN=nexuscos.online bash pf-master-deployment.sh
```

**What this does**:
1. Performs pre-flight system checks
2. Executes IP/domain unification
3. Rebuilds frontend applications
4. Configures Nginx
5. Enforces branding consistency
6. Validates deployment
7. Generates comprehensive report

### Step 4: Validate Deployment

After deployment completes, run the validation script:

```bash
sudo bash /var/www/nexus-cos/validate-ip-domain-routing.sh
```

**Expected Results**:
- All or most tests should pass
- Nginx should be running
- Configuration should be valid
- HTTP should redirect to HTTPS
- Domain should be accessible

### Step 5: Test in Browser

1. **Clear your browser cache** (Important!)
   - Chrome/Edge: Ctrl+Shift+Delete
   - Firefox: Ctrl+Shift+Delete
   - Safari: Cmd+Option+E

2. **Test both access methods**:
   ```
   http://74.208.155.161/
   https://nexuscos.online/
   ```

3. **Verify**:
   - Both should show the same UI/branding
   - HTTP should redirect to HTTPS
   - All pages load correctly
   - No console errors

### Step 6: Spot-Check with curl

```bash
# Check HTTP redirect from IP
curl -I http://74.208.155.161/

# Check HTTPS domain
curl -I https://nexuscos.online/

# Check admin panel
curl -I https://nexuscos.online/admin

# Check API health
curl -I https://nexuscos.online/api/health
```

## Troubleshooting

### If pf-master-deployment.sh is not found

```bash
cd /var/www/nexus-cos
ls -l pf-master-deployment.sh

# If not found, check if you're in the right directory
pwd

# Verify files exist
ls -la | grep pf-
```

### If you get "-: command not found"

This error occurs when you copy commands with leading hyphens or bullets. 

**Solution**: Type the command manually or copy only the command without any leading characters:

```bash
# ❌ WRONG (has leading hyphen)
- cd /var/www/nexus-cos

# ✅ CORRECT
cd /var/www/nexus-cos
```

### If Nginx fails to reload

```bash
# Test nginx configuration
sudo nginx -t

# Check error logs
sudo tail -n 200 /var/log/nginx/error.log

# Restart nginx
sudo systemctl restart nginx

# Check status
sudo systemctl status nginx
```

### If deployment fails

1. Check the error message carefully
2. Review the deployment report: `/tmp/nexus-cos-master-pf-report.txt`
3. Check nginx error logs: `/var/log/nginx/error.log`
4. Verify all required services are running
5. Try running individual scripts:

```bash
# Run just the IP/domain fix
sudo bash pf-ip-domain-unification.sh

# Run validation
bash validate-ip-domain-routing.sh
```

## Alternative Deployment Path

If you need to deploy to a different location:

```bash
# Deploy from custom location
cd /custom/path/to/nexus-cos
sudo DOMAIN=nexuscos.online bash pf-master-deployment.sh

# The script will automatically detect its location
```

## Environment Variables

You can customize the deployment using environment variables:

```bash
# Custom domain
sudo DOMAIN=yourdomain.com bash pf-master-deployment.sh

# Custom server IP
sudo DOMAIN=yourdomain.com SERVER_IP=1.2.3.4 bash pf-ip-domain-unification.sh

# Custom repository root (if needed)
sudo REPO_ROOT=/custom/path bash pf-master-deployment.sh
```

## Nginx Configuration

The deployment creates/updates:
- `/etc/nginx/sites-available/nexuscos` - Main config
- `/etc/nginx/sites-enabled/nexuscos` - Enabled symlink

To manually check/edit:

```bash
# View configuration
sudo cat /etc/nginx/sites-available/nexuscos

# Test configuration
sudo nginx -t

# Reload if changes made
sudo systemctl reload nginx
```

## Post-Deployment Checklist

- [ ] Run master deployment script
- [ ] Validation script passes all checks
- [ ] Browser testing successful (cache cleared)
- [ ] Both IP and domain show same UI
- [ ] HTTP redirects to HTTPS
- [ ] All features work correctly
- [ ] No errors in nginx logs
- [ ] Backend services running
- [ ] SSL certificates valid (if applicable)

## Support

If you encounter issues:

1. Check `/tmp/nexus-cos-master-pf-report.txt` for deployment report
2. Check `/tmp/nexus-cos-validation-report.txt` for validation results
3. Review nginx logs: `/var/log/nginx/error.log`
4. Review the troubleshooting section above

## Summary

The scripts are now fully compatible with VPS deployment. Simply:

1. Upload repository to `/var/www/nexus-cos`
2. Run: `cd /var/www/nexus-cos`
3. Run: `sudo DOMAIN=nexuscos.online bash pf-master-deployment.sh`
4. Validate: `bash validate-ip-domain-routing.sh`
5. Test in browser with cleared cache

Your Nexus COS platform will then be fully deployed with unified UI/branding across all access methods!
