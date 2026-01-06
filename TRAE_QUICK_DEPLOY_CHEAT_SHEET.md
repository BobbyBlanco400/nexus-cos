# TRAE Quick Deployment Cheat Sheet - Nginx Fix
## Print this page and follow step-by-step

---

## PRE-FLIGHT (30 seconds)
```bash
# Check services running
curl -I http://127.0.0.1:3000/          # Backend API - must respond
curl -I http://127.0.0.1:3043/stream/   # Streaming - must respond

# Check SSL exists
ls -la /etc/ssl/ionos/*.pem             # Must show 2 files

# Verify sudo access
sudo nginx -v                            # Must show version
```
✅ All checks pass? Continue. ❌ Any fail? Fix first.

---

## DEPLOYMENT (3 minutes)

### Step 1: Navigate
```bash
cd /path/to/nexus-cos
```

### Step 2: Deploy (Choose ONE)

**Vanilla Nginx** (most common):
```bash
sudo ./deployment/nginx/scripts/deploy-vanilla.sh
```

**OR Plesk** (if using Plesk):
```bash
sudo ./deployment/nginx/scripts/deploy-plesk.sh
```

Expected: Script completes with "✅ Deployment Complete!"

---

## VALIDATION (2 minutes)

### Step 3: Validate Endpoints
```bash
./deployment/nginx/scripts/validate-endpoints.sh
```

Expected output:
```
Testing / ... PASS (200)
Testing /api/ ... PASS (404)
Testing /stream/ ... PASS (200)
Testing /hls/ ... PASS (200)
Testing /health ... PASS (200)

✅ All critical endpoints are responding!
```

### Step 4: Integration Tests
```bash
./deployment/nginx/scripts/test-config.sh
```

Expected output:
```
Total tests: 34
Passed: 34
Warnings: 0
Failed: 0

✅ All tests passed!
```

### Step 5: Browser Check
1. Open: `https://n3xuscos.online/`
2. See: Your published site (NOT "Welcome to nginx!")
3. Test: `https://n3xuscos.online/health` → shows "ok"

---

## SUCCESS CHECKLIST

- [ ] Deploy script: ✅ Complete
- [ ] Validate script: All PASS
- [ ] Integration tests: 34/34 PASSED
- [ ] Browser: Published site visible
- [ ] Health check: Returns "ok"

**All checked? DONE! 🎉**

---

## QUICK TROUBLESHOOTING

**Services not responding?**
```bash
pm2 list                    # Check services
pm2 start backend           # Start if needed
pm2 start streaming-service
```

**Still see welcome page?**
```bash
sudo nginx -T | grep "server_name n3xuscos.online"  # Must show config
sudo systemctl restart nginx                         # Force restart
```

**SSL errors?**
```bash
ls -la /etc/letsencrypt/live/n3xuscos.online/  # Using Let's Encrypt?
# If yes, update paths in config from /etc/ssl/ionos/ to /etc/letsencrypt/
```

---

## ROLLBACK (if needed)

```bash
# Find backup
ls -la /etc/nginx/sites-enabled/n3xuscos.online.bak.*

# Restore (use actual timestamp)
sudo cp /etc/nginx/sites-enabled/n3xuscos.online.bak.YYYYMMDDHHMMSS \
     /etc/nginx/sites-enabled/n3xuscos.online

# Reload
sudo nginx -t && sudo systemctl reload nginx
```

---

## REPORT COMPLETION

After 100% success, report:
```
✅ DEPLOYMENT COMPLETE

Method: [Vanilla/Plesk]
Time: [X] minutes
Validation: All PASS
Tests: 34/34 PASSED
Status: n3xuscos.online serving published site
Issues: None

Platform now 100% complete for beta launch.
```

---

**Time estimate: 5 minutes total**  
**Risk: Low (automatic backups)**  
**Deadline: Before 12/31/2025**

**NO DEVIATIONS. FOLLOW EXACTLY. 100% GREEN REQUIRED.**
