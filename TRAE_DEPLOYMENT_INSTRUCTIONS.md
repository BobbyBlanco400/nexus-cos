# TRAE Deployment Instructions - Nginx Routing Fix
## ONE-SHOT DEPLOYMENT - 100% GREEN REQUIRED

**Mission**: Fix nexuscos.online Nginx routing (currently shows welcome page instead of published site)  
**Deadline**: Complete before 12/31/2025 (Beta launch period)  
**Status**: All code ready, tested, and validated. Just needs deployment.

---

## ⚠️ CRITICAL REQUIREMENTS

1. ✅ **No deviations** - Follow steps exactly as written
2. ✅ **One-shot deployment** - All steps must succeed in sequence
3. ✅ **100% green validation** - All tests must pass
4. ✅ **No pausing** - Complete all steps in one session
5. ✅ **Strict adherence** - Do not modify or skip any steps

---

## 📋 PRE-FLIGHT CHECKLIST

Before starting deployment, verify these prerequisites:

```bash
# 1. Verify backend services are running
curl -I http://127.0.0.1:3000/
# Expected: HTTP response (200, 404, etc. - just needs to respond)

curl -I http://127.0.0.1:3043/stream/
# Expected: HTTP response (200, 404, etc. - just needs to respond)

# 2. Verify SSL certificates exist
ls -la /etc/ssl/ionos/fullchain.pem
ls -la /etc/ssl/ionos/privkey.pem
# Expected: Both files must exist

# 3. Verify you have sudo access
sudo nginx -v
# Expected: nginx version output

# 4. Check current site status
curl -I https://nexuscos.online/
# Expected: Currently shows Nginx welcome page (this is what we're fixing)
```

**If ANY pre-flight check fails, STOP and resolve the issue before proceeding.**

---

## 🚀 DEPLOYMENT STEPS - EXECUTE IN ORDER

### Step 1: Navigate to Repository

```bash
cd /path/to/nexus-cos
```

### Step 2: Choose Deployment Method

**Option A: Vanilla Nginx (Standard Linux Server)**
```bash
sudo ./deployment/nginx/scripts/deploy-vanilla.sh
```

**Option B: Plesk (IONOS/Managed Hosting)**
```bash
sudo ./deployment/nginx/scripts/deploy-plesk.sh
```

**Choose ONE option based on your server setup. If unsure, try:**
```bash
# Check if Plesk is installed
which plesk
# If command found: Use Option B (Plesk)
# If command not found: Use Option A (Vanilla)
```

### Step 3: Validate Deployment

```bash
./deployment/nginx/scripts/validate-endpoints.sh
```

**Expected Output:**
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

**If validation shows FAIL for any endpoint, check troubleshooting section below.**

### Step 4: Run Integration Tests (100% Green Required)

```bash
./deployment/nginx/scripts/test-config.sh
```

**Expected Output:**
```
Total tests: 34
Passed: 34
Warnings: 0
Failed: 0

✅ All tests passed!
```

**CRITICAL: If any test fails, deployment is NOT complete. See troubleshooting below.**

### Step 5: Verify in Browser

1. Open browser and navigate to: `https://nexuscos.online/`
2. **Expected**: Your published landing page (NOT Nginx welcome page)
3. Test API: `https://nexuscos.online/api/`
4. Test health: `https://nexuscos.online/health` (should return "ok")

---

## ✅ SUCCESS CRITERIA

Deployment is 100% complete when ALL of the following are true:

- [ ] Deploy script completed without errors
- [ ] Validation script shows all endpoints PASS
- [ ] Integration tests show 34/34 PASSED
- [ ] Browser shows published site (not Nginx welcome page)
- [ ] `/health` endpoint returns "ok"
- [ ] No errors in Nginx error log: `sudo tail -n 50 /var/log/nginx/error.log`

---

## 🔥 TROUBLESHOOTING

### Issue: Validation Shows FAIL for /api or /stream

**Cause**: Backend services not running  
**Fix**:
```bash
# Check if services are running
pm2 list
# or
systemctl status <service-name>

# Start services if needed
pm2 start backend
pm2 start streaming-service
```

Then re-run validation: `./deployment/nginx/scripts/validate-endpoints.sh`

### Issue: SSL Certificate Errors

**Cause**: Certificate files don't exist or are in different location  
**Fix**:
```bash
# Check if using Let's Encrypt instead
ls -la /etc/letsencrypt/live/nexuscos.online/

# If Let's Encrypt certs exist, update config paths:
# Edit: deployment/nginx/sites-available/nexuscos.online
# Change:
#   ssl_certificate /etc/ssl/ionos/fullchain.pem;
# To:
#   ssl_certificate /etc/letsencrypt/live/nexuscos.online/fullchain.pem;
```

Then re-run deployment script.

### Issue: nginx -t Shows Configuration Error

**Cause**: Syntax error in configuration  
**Fix**:
```bash
# View detailed error
sudo nginx -t

# Check what's wrong and fix the error
# Then re-run deployment script
```

### Issue: Still Shows Nginx Welcome Page After Deployment

**Cause**: Wrong vhost is active  
**Fix**:
```bash
# Verify our config is loaded
sudo nginx -T | grep -A 5 "server_name nexuscos.online"

# If nothing shown, vhost is not loaded
# Check symlink exists (vanilla Nginx)
ls -la /etc/nginx/sites-enabled/nexuscos.online

# If missing, re-run deployment script
```

### Issue: Integration Tests Fail

**Cause**: Configuration files corrupted or missing  
**Fix**:
```bash
# Re-clone or pull latest from repository
git pull origin <branch-name>

# Re-run deployment from Step 1
```

---

## 🔄 ROLLBACK (If Needed)

If deployment fails and you need to rollback:

```bash
# Find the backup
ls -la /etc/nginx/sites-enabled/nexuscos.online.bak.*

# Restore (replace TIMESTAMP with actual timestamp from ls output)
sudo cp /etc/nginx/sites-enabled/nexuscos.online.bak.TIMESTAMP \
     /etc/nginx/sites-enabled/nexuscos.online

# Test and reload
sudo nginx -t && sudo systemctl reload nginx
```

**For Plesk**:
```bash
# Find backup
ls -la /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf.bak.*

# Restore
sudo cp /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf.bak.TIMESTAMP \
     /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf

# Rebuild and reload
sudo plesk repair web -domain nexuscos.online -y
sudo nginx -t && sudo systemctl reload nginx
```

---

## 📊 DEPLOYMENT METRICS

- **Total Time**: ~5 minutes
- **Downtime**: <10 seconds (just Nginx reload)
- **Rollback Time**: <1 minute
- **Risk Level**: Low (automatic backups created)

---

## 📞 ESCALATION

If deployment fails after following troubleshooting:

1. Check Nginx error log: `sudo tail -n 100 /var/log/nginx/error.log`
2. Verify all services running: `pm2 list` or `systemctl status nginx`
3. Check ports listening: `sudo netstat -tlnp | grep -E ":(3000|3043)"`
4. Review detailed documentation:
   - `NGINX_ROUTING_FIX.md` - Full deployment guide
   - `deployment/nginx/README.md` - Technical reference
   - `deployment/nginx/TROUBLESHOOTING.md` - Extended troubleshooting

---

## 🎯 FINAL CHECKLIST

Before marking as complete:

- [ ] Deployment script completed successfully
- [ ] Validation script shows 100% PASS
- [ ] Integration tests: 34/34 PASSED (100% green)
- [ ] Browser shows published site at nexuscos.online
- [ ] API endpoints responding
- [ ] Streaming endpoints responding
- [ ] No errors in Nginx logs
- [ ] Site accessible from external network (not just localhost)
- [ ] HTTPS enforced (HTTP redirects to HTTPS)
- [ ] Health check returns "ok"

**When ALL boxes are checked, deployment is 100% COMPLETE.**

---

## 📝 COMPLETION REPORT

After successful deployment, report back with:

```
DEPLOYMENT COMPLETE ✅

Deployment Method: [Vanilla/Plesk]
Deployment Time: [X minutes]
Validation Result: [X/X PASS]
Integration Tests: [34/34 PASSED]
Site Status: [nexuscos.online serving published site]
Issues Encountered: [None / List any]

All success criteria met. Ready for beta launch continuation.
```

---

**REMEMBER**: 
- No deviations from this guide
- All steps must succeed
- 100% green validation required
- One-shot deployment
- Strict adherence mandatory

**This is the ONLY task preventing 100% completion. Execute with precision.**

---

**Last Updated**: December 15, 2025  
**Status**: READY FOR DEPLOYMENT  
**Tested**: 34/34 integration tests passing  
**Risk**: LOW (automatic backup and rollback)
