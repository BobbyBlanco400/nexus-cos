# Nexus COS - IP/Domain Fix Deployment Checklist

## Pre-Deployment

### System Requirements
- [ ] VPS access (root or sudo privileges)
- [ ] Server IP: 74.208.155.161
- [ ] Domain: nexuscos.online
- [ ] SSH access configured
- [ ] Git repository accessible

### Prerequisites Verification
- [ ] Nginx installed and running
- [ ] Node.js installed (v14+)
- [ ] npm installed
- [ ] Git installed
- [ ] curl installed
- [ ] At least 5GB disk space available
- [ ] Ports 80 and 443 available

### Backup Current Configuration
- [ ] Backup current Nginx config
  ```bash
  sudo cp /etc/nginx/sites-available/nexuscos \
          /etc/nginx/sites-available/nexuscos.backup.$(date +%s)
  ```
- [ ] Backup current webroot
  ```bash
  sudo tar -czf /tmp/webroot-backup-$(date +%s).tar.gz /var/www/nexus-cos
  ```
- [ ] Note current backend service status
  ```bash
  systemctl status nexus-backend > /tmp/pre-deploy-status.txt
  systemctl status nexus-python >> /tmp/pre-deploy-status.txt
  ```

### Documentation Review
- [ ] Read `QUICK_FIX_IP_DOMAIN.md`
- [ ] Read `PF_MASTER_DEPLOYMENT_README.md`
- [ ] Review `deployment/nginx/nexuscos-unified.conf`

## Deployment Phase

### Step 1: Clone/Update Repository
```bash
cd /home/runner/work/nexus-cos/nexus-cos
git pull origin main
```
- [ ] Repository updated successfully
- [ ] All new scripts present
- [ ] Scripts have execute permissions

### Step 2: Execute Master Deployment
```bash
sudo bash pf-master-deployment.sh
```
- [ ] Pre-flight checks passed
- [ ] Confirmed deployment plan
- [ ] Environment validation completed
- [ ] Frontend builds successful
- [ ] Nginx configuration created
- [ ] Branding enforcement completed
- [ ] Validation checks completed
- [ ] Deployment report generated

### Step 3: Verify Nginx Configuration
```bash
sudo nginx -t
```
- [ ] Configuration test passed
- [ ] No syntax errors
- [ ] SSL certificates valid

### Step 4: Reload Nginx
```bash
sudo systemctl reload nginx
```
- [ ] Nginx reloaded successfully
- [ ] No errors in logs
- [ ] Service remains active

## Validation Phase

### Automated Validation
```bash
bash validate-ip-domain-routing.sh
```
- [ ] Nginx service running: ✓
- [ ] Nginx configuration valid: ✓
- [ ] default_server configured: ✓
- [ ] HTTP domain redirect: ✓
- [ ] HTTP IP redirect: ✓
- [ ] HTTPS domain access: ✓
- [ ] Admin panel routing: ✓
- [ ] Creator hub routing: ✓
- [ ] API endpoint routing: ✓
- [ ] Security headers: ✓
- [ ] File permissions: ✓
- [ ] Environment variables: ✓

### Manual Testing - Command Line

#### Test IP Redirect
```bash
curl -I http://74.208.155.161/
```
- [ ] Returns 301 redirect
- [ ] Location header points to https://nexuscos.online

#### Test Domain Access
```bash
curl -I https://nexuscos.online/
```
- [ ] Returns 200 OK or 301 to /admin/
- [ ] No errors

#### Test Admin Panel
```bash
curl -L https://nexuscos.online/admin/
```
- [ ] Returns 200 OK
- [ ] HTML content received
- [ ] No 404 or 502 errors

#### Test Creator Hub
```bash
curl -L https://nexuscos.online/creator-hub/
```
- [ ] Returns 200 OK
- [ ] HTML content received
- [ ] No 404 or 502 errors

#### Test Health Endpoint
```bash
curl https://nexuscos.online/health
```
- [ ] Returns "OK - Nexus COS Platform"
- [ ] Status 200

#### Test API Proxy
```bash
curl -I https://nexuscos.online/api/health
```
- [ ] Returns status code (200, 502, or 503)
- [ ] Proxy is configured

### Browser Testing

#### Preparation
- [ ] Clear browser cache (Ctrl+Shift+Delete)
- [ ] Select "All time"
- [ ] Clear all data types
- [ ] Close and reopen browser

#### Test IP Access
Open browser to: `http://74.208.155.161/`
- [ ] Redirects to https://nexuscos.online/
- [ ] Page loads correctly
- [ ] No redirect loop

#### Test Domain Access
Open browser to: `https://nexuscos.online/`
- [ ] Page loads correctly
- [ ] SSL certificate valid
- [ ] No browser warnings

#### Test Admin Panel
Navigate to: `https://nexuscos.online/admin/`
- [ ] Admin panel loads
- [ ] Branding appears correct
- [ ] Navigation works
- [ ] No console errors

#### Test Creator Hub
Navigate to: `https://nexuscos.online/creator-hub/`
- [ ] Creator hub loads
- [ ] Branding appears correct
- [ ] Navigation works
- [ ] No console errors

#### Test Console
Open browser console (F12)
- [ ] No CSP violations
- [ ] No 404 errors for assets
- [ ] No CORS errors
- [ ] JavaScript loads correctly
- [ ] CSS loads correctly

#### Test Branding Consistency
- [ ] Logo displays correctly
- [ ] Colors match branding (primary: #2563eb)
- [ ] Fonts load correctly
- [ ] Icons display correctly
- [ ] Same appearance on IP and domain access

## Post-Deployment Verification

### Review Reports
- [ ] Check `/tmp/nexus-cos-master-pf-report.txt`
- [ ] Check `/tmp/nexus-cos-pf-report.txt`
- [ ] Check `/tmp/nexus-cos-validation-report.txt`
- [ ] All reports show success

### Monitor Logs (10 minutes)
```bash
sudo tail -f /var/log/nginx/nexus-cos.error.log
```
- [ ] No errors appearing
- [ ] No 404s for static assets
- [ ] No proxy errors
- [ ] No SSL errors

### Check Access Logs
```bash
sudo tail -100 /var/log/nginx/nexus-cos.access.log
```
- [ ] Requests being served
- [ ] Status codes mostly 200
- [ ] No excessive 404s or 502s

### Verify Backend Services
```bash
systemctl status nexus-backend
systemctl status nexus-python
```
- [ ] nexus-backend is active (running)
- [ ] nexus-python is active (running)
- [ ] No recent restarts
- [ ] No errors in status

## Functional Testing

### Admin Panel Features
- [ ] Login page loads
- [ ] Dashboard displays
- [ ] User management accessible
- [ ] Settings accessible
- [ ] All navigation links work

### Creator Hub Features
- [ ] Dashboard loads
- [ ] Project management works
- [ ] Asset library accessible
- [ ] Analytics display
- [ ] All navigation links work

### API Testing
- [ ] Health endpoint responds
- [ ] Authentication endpoints accessible
- [ ] Data endpoints return data
- [ ] WebSocket connections work (if applicable)

## Performance Verification

### Load Times
- [ ] Homepage loads in < 3 seconds
- [ ] Admin panel loads in < 3 seconds
- [ ] Creator hub loads in < 3 seconds
- [ ] API responses in < 500ms

### Static Assets
- [ ] CSS files load quickly (cached)
- [ ] JS files load quickly (cached)
- [ ] Images load quickly (cached)
- [ ] Fonts load without FOUT

## Security Verification

### SSL/TLS
```bash
openssl s_client -connect nexuscos.online:443 < /dev/null
```
- [ ] Certificate valid
- [ ] Not expired
- [ ] Correct domain name
- [ ] Strong cipher used

### Security Headers
```bash
curl -I https://nexuscos.online/ | grep -i "x-\|strict\|content-security"
```
- [ ] X-Frame-Options present
- [ ] X-Content-Type-Options present
- [ ] X-XSS-Protection present
- [ ] Strict-Transport-Security present
- [ ] Content-Security-Policy present

### File Permissions
```bash
ls -la /var/www/nexus-cos/
```
- [ ] Correct ownership (www-data or appropriate user)
- [ ] Correct permissions (755 for directories, 644 for files)
- [ ] No world-writable files

## Documentation

### Update Internal Docs
- [ ] Document deployment date/time
- [ ] Document who performed deployment
- [ ] Document any issues encountered
- [ ] Document any deviations from plan

### Team Notification
- [ ] Notify development team
- [ ] Notify operations team
- [ ] Notify stakeholders
- [ ] Provide access to reports

## Monitoring Setup

### First 24 Hours
- [ ] Monitor error logs hourly
- [ ] Monitor access logs for anomalies
- [ ] Monitor backend service status
- [ ] Monitor server resources (CPU, RAM, disk)

### Set Alerts (if not already configured)
- [ ] Nginx service down alert
- [ ] High error rate alert
- [ ] High response time alert
- [ ] SSL certificate expiry alert

## Rollback Plan (If Needed)

### If Critical Issues Occur
```bash
# 1. Restore Nginx config
sudo cp /etc/nginx/sites-available/nexuscos.backup.[timestamp] \
        /etc/nginx/sites-available/nexuscos

# 2. Test configuration
sudo nginx -t

# 3. Reload Nginx
sudo systemctl reload nginx

# 4. Verify rollback
curl -I https://nexuscos.online/
```
- [ ] Backup config ready
- [ ] Rollback procedure tested
- [ ] Team knows rollback process

## Sign-Off

### Deployment Team
- [ ] DevOps Lead: _________________ Date: _______
- [ ] Developer: _________________ Date: _______
- [ ] QA Tester: _________________ Date: _______

### Verification
- [ ] All checklist items completed
- [ ] No critical issues
- [ ] All stakeholders notified
- [ ] Documentation updated

### Final Approval
- [ ] Project Lead: _________________ Date: _______

## Notes

### Issues Encountered
```
[Document any issues that occurred during deployment]




```

### Resolutions
```
[Document how issues were resolved]




```

### Recommendations
```
[Document any recommendations for future deployments]




```

---

**Deployment Checklist Version:** 1.0.0  
**Last Updated:** 2024-10-05  
**Status:** Ready for Use
