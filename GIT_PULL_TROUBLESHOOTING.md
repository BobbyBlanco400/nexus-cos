# Git Pull Conflict Fix - Quick Guide

## Problem
When running `git pull origin copilot/fix-deployment-issues`, you get:
```
fatal: Need to specify how to reconcile divergent branches.
```

## Solution (Choose One)

### Option 1: Quick Fix (Recommended)
Run this helper script to automatically resolve the conflict:
```bash
./pull-latest-fixes.sh
```

This will:
- Stash your local changes
- Pull the latest fixes
- Configure git to use merge strategy

### Option 2: Manual Fix - Force Pull
If you don't need your local changes:
```bash
git fetch origin
git reset --hard origin/copilot/fix-deployment-issues
```

**Warning:** This will discard ALL local changes!

### Option 3: Manual Fix - Merge
If you want to keep local changes:
```bash
git config pull.rebase false
git pull origin copilot/fix-deployment-issues
```

If merge conflicts occur, resolve them manually.

---

## After Pulling Successfully

Run the deployment fix:
```bash
./fix-deployment-issues.sh
```

---

## Common Issues After Running Fix Script

### Issue 1: vstage Still Errored
**Symptoms:** `vstage` shows "errored" status with high restart count

**Fix:**
```bash
cd /var/www/nexuscos.online/nexus-cos-app/nexus-cos/modules/v-suite/v-stage
npm install
pm2 delete vstage
pm2 start index.js --name vstage
pm2 save
```

**Check:**
```bash
pm2 logs vstage --lines 50
curl http://localhost:3012/health
```

### Issue 2: nexus-api-health High Restarts
**Symptoms:** Service online but 100+ restarts

**Cause:** Usually database connection issues

**Fix:**
```bash
# Check database is running
docker ps | grep postgres

# Restart the service
pm2 delete nexus-api-health
PORT=3000 pm2 start /var/www/nexuscos.online/nexus-cos-app/nexus-cos/server.js --name nexus-api-health
pm2 save
```

**Check:**
```bash
pm2 logs nexus-api-health --lines 50
curl http://localhost:3000/health
```

### Issue 3: nexus-api 100% CPU
**Symptoms:** Service using 100% CPU, very high restart count

**Cause:** Crash loop - service keeps restarting

**Fix:**
```bash
# Stop the crashing service
pm2 delete nexus-api

# Check what's actually running on that port
lsof -i :3001

# View logs to see error
pm2 logs nexus-api --lines 100

# If it's backend-api that should be running:
pm2 start ecosystem.config.js --only backend-api
pm2 save
```

### Issue 4: Running Old Script Version
**Symptoms:** Script mentions ports 8000, 3004 instead of 3000, 3001, 3012, 3013

**Fix:**
```bash
# You're running an old version. Pull the latest:
./pull-latest-fixes.sh
# Then run:
./fix-deployment-issues.sh
```

---

## Verification Commands

After running fixes, verify everything:

```bash
# Check all services
pm2 list

# Should see these services ONLINE:
# - nexus-api-health (port 3000)
# - backend-api (port 3001)
# - vstage (port 3012)
# - puabomusicchain (port 3013)
# - vscreen-hollywood (port 8088)

# Test health endpoints
curl http://localhost:3000/health  # nexus-api-health
curl http://localhost:3001/health  # backend-api
curl http://localhost:3012/health  # vstage
curl http://localhost:3013/health  # puabomusicchain
curl http://localhost:8088/health  # vscreen-hollywood

# Check for errors
pm2 logs --lines 50

# Run full audit
./production-audit.sh
```

---

## Expected Final State

```
┌────┬────────────────────┬──────────┬──────┬───────────┬──────────┬──────────┐
│ id │ name               │ mode     │ ↺    │ status    │ cpu      │ memory   │
├────┼────────────────────┼──────────┼──────┼───────────┼──────────┼──────────┤
│ 0  │ nexus-api-health   │ fork     │ 0-5  │ online    │ 0-5%     │ 60-80mb  │
│ 1  │ backend-api        │ cluster  │ 0-5  │ online    │ 0-5%     │ 70-90mb  │
│ 2  │ vstage             │ fork     │ 0-5  │ online    │ 0-5%     │ 50-70mb  │
│ 3  │ puabomusicchain    │ cluster  │ 0-5  │ online    │ 0-5%     │ 60-80mb  │
│ 4  │ vscreen-hollywood  │ fork     │ 0-5  │ online    │ 0-5%     │ 50-70mb  │
└────┴────────────────────┴──────────┴──────┴───────────┴──────────┴──────────┘
```

**Key indicators:**
- ✅ Status: "online" (not "errored" or "launching")
- ✅ Restarts (↺): 0-5 (not 15, 30, 100+)
- ✅ CPU: 0-5% (not 100%)
- ✅ Memory: Showing actual usage (not "0b")

---

## Still Having Issues?

1. **Check logs for errors:**
   ```bash
   pm2 logs --lines 100
   ```

2. **Delete all and restart fresh:**
   ```bash
   pm2 delete all
   ./fix-deployment-issues.sh
   ```

3. **Check database:**
   ```bash
   docker ps | grep postgres
   docker logs nexus-postgres
   ```

4. **Run production audit:**
   ```bash
   ./production-audit.sh
   ```

---

## Contact Information

If issues persist after following this guide:
1. Collect diagnostic info: `pm2 list`, `pm2 logs`, `docker ps`
2. Note which specific services are failing
3. Include error messages from logs
