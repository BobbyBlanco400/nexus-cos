# Nexus COS Deployment - Fixing Remaining Issues

## Current Status: 91% → Target: 100%

Your deployment is at **91% success rate** with 3 issues to fix:

1. ❌ Backend API (Port 8000) - Not responding
2. ❌ V-Screen Hollywood (Port 3004) - Not responding
3. ❌ Database (PostgreSQL) - Not accessible

---

## Quick Fix - Run This First

```bash
# Navigate to your deployment directory
cd /var/www/nexuscos.online/nexus-cos-app/nexus-cos

# Pull the latest fixes
git pull origin copilot/verify-production-readiness

# Run the automated fix script
./fix-deployment-issues.sh
```

This script will automatically:
- Start the PostgreSQL database
- Start the Backend API on port 8000
- Start V-Screen Hollywood on port 3004
- Re-run the production audit

---

## Manual Fix Guide (If Automated Script Doesn't Work)

### Fix 1: PostgreSQL Database

**Check if PostgreSQL is running:**
```bash
docker ps | grep postgres
```

**If not running, start it:**
```bash
# Create Docker network
docker network create cos-net 2>/dev/null || true

# Start PostgreSQL
docker run -d \
  --name nexus-postgres \
  --network cos-net \
  -e POSTGRES_DB=nexus_cos \
  -e POSTGRES_USER=nexus_admin \
  -e POSTGRES_PASSWORD=YOUR_SECURE_PASSWORD \
  -p 5432:5432 \
  -v nexus-postgres-data:/var/lib/postgresql/data \
  --restart unless-stopped \
  postgres:15

# Wait for it to start
sleep 10

# Verify
docker exec nexus-postgres psql -U nexus_admin -d nexus_cos -c "SELECT 1"
```

**If already running but not accessible:**
```bash
# Check logs
docker logs nexus-postgres --tail 50

# Restart if needed
docker restart nexus-postgres
sleep 10
```

---

### Fix 2: Backend API (Port 8000)

**Check if backend is running:**
```bash
netstat -tulpn | grep 8000
pm2 list | grep backend
```

**If not running, start it:**
```bash
cd /var/www/nexuscos.online/nexus-cos-app/nexus-cos

# Option A: If you have a backend directory
if [ -d "backend" ]; then
    cd backend
    npm install --production
    pm2 start server.js --name nexus-backend -- --port 8000
    cd ..
fi

# Option B: If server.js is in root
if [ -f "server.js" ]; then
    pm2 start server.js --name nexus-backend -- --port 8000
fi

# Save PM2 processes
pm2 save

# Verify
sleep 3
curl http://localhost:8000/health/
```

**If running but not responding:**
```bash
# Check logs
pm2 logs nexus-backend --lines 50

# Restart
pm2 restart nexus-backend

# Check again
curl http://localhost:8000/health/
```

**Common issues:**
- **Missing .env file:** Ensure `.env` exists with proper configuration
- **Wrong port:** Check if another service is using port 8000
- **Missing dependencies:** Run `npm install` in backend directory
- **Database connection:** Ensure DB_PASSWORD in `.env` matches PostgreSQL password

---

### Fix 3: V-Screen Hollywood (Port 3004)

**Check if V-Screen is running:**
```bash
netstat -tulpn | grep 3004
pm2 list | grep vscreen
```

**If not running, start it:**
```bash
cd /var/www/nexuscos.online/nexus-cos-app/nexus-cos

# Option A: If in services directory
if [ -d "services/vscreen-hollywood" ]; then
    cd services/vscreen-hollywood
    npm install --production
    pm2 start server.js --name vscreen-hollywood -- --port 3004
    cd ../..
fi

# Option B: If in modules/v-suite
if [ -d "modules/v-suite" ]; then
    cd modules/v-suite
    npm install --production
    pm2 start server.js --name vscreen-hollywood -- --port 3004
    cd ../..
fi

# Save PM2 processes
pm2 save

# Verify
sleep 3
curl http://localhost:3004/health
```

**If running but not responding:**
```bash
# Check logs
pm2 logs vscreen-hollywood --lines 50

# Restart
pm2 restart vscreen-hollywood

# Check again
curl http://localhost:3004/health
```

---

## Verification Steps

After applying fixes, verify each service:

### 1. Check All PM2 Processes
```bash
pm2 list
```
**Expected:** All services show "online" status

### 2. Check All Ports
```bash
netstat -tulpn | grep -E '8000|3004|3005|3006|5432'
```
**Expected:** See listeners on all ports

### 3. Check Docker Containers
```bash
docker ps
```
**Expected:** See nexus-postgres running

### 4. Test Each Endpoint
```bash
# Backend
curl http://localhost:8000/health/

# V-Screen Hollywood
curl http://localhost:3004/health

# V-Suite Orchestrator
curl http://localhost:3005/health

# Monitoring (optional)
curl http://localhost:3006/health

# Database
docker exec nexus-postgres psql -U nexus_admin -d nexus_cos -c "SELECT 1"
```

### 5. Run Production Audit Again
```bash
cd /var/www/nexuscos.online/nexus-cos-app/nexus-cos
./nexus-cos-complete-audit.sh
```
**Expected:** "PRODUCTION READINESS: CONFIRMED" with 100% success rate

---

## Troubleshooting Common Issues

### Issue: Port Already in Use

```bash
# Find what's using the port
lsof -i :8000  # or :3004, :5432, etc.

# Kill the process
kill -9 <PID>

# Or use different port in .env
```

### Issue: Missing Environment Variables

```bash
# Check .env file exists
cat .env

# Required variables:
# DB_PASSWORD=your_secure_password
# DB_HOST=localhost
# DB_PORT=5432
# DB_NAME=nexus_cos
# DB_USER=nexus_admin
# PORT=8000
# NODE_ENV=production
```

### Issue: PM2 Processes Not Starting

```bash
# View detailed logs
pm2 logs --lines 100

# Delete and recreate process
pm2 delete nexus-backend
pm2 start server.js --name nexus-backend -- --port 8000

# Save configuration
pm2 save
```

### Issue: Database Connection Fails

```bash
# Check PostgreSQL logs
docker logs nexus-postgres --tail 100

# Recreate database
docker stop nexus-postgres
docker rm nexus-postgres
# Then run the docker run command again from Fix 1

# Verify connection string in .env matches
```

### Issue: Services Start But Don't Respond

This usually means the service is running but encountering errors:

```bash
# Check PM2 logs for errors
pm2 logs nexus-backend --err --lines 50

# Common fixes:
# 1. Install missing dependencies
npm install

# 2. Check .env configuration
cat .env

# 3. Restart with fresh logs
pm2 restart all
pm2 flush  # Clear old logs
pm2 logs
```

---

## Final Verification Checklist

Before marking deployment as 100% complete:

- [ ] PostgreSQL container running: `docker ps | grep postgres`
- [ ] Backend API responds: `curl http://localhost:8000/health/`
- [ ] V-Screen responds: `curl http://localhost:3004/health`
- [ ] V-Suite responds: `curl http://localhost:3005/health`
- [ ] All PM2 processes online: `pm2 list`
- [ ] HTTPS works: `curl -I https://nexuscos.online`
- [ ] Production audit shows "CONFIRMED": `./nexus-cos-complete-audit.sh`
- [ ] No errors in PM2 logs: `pm2 logs --lines 50`
- [ ] No errors in Docker logs: `docker logs nexus-postgres --tail 50`

---

## Getting Help

If issues persist after trying all fixes:

1. **Check all logs:**
   ```bash
   pm2 logs --lines 200
   docker logs nexus-postgres --tail 100
   tail -100 /var/log/nginx/error.log
   ```

2. **Verify file structure:**
   ```bash
   ls -la /var/www/nexuscos.online/nexus-cos-app/nexus-cos
   ```

3. **Check system resources:**
   ```bash
   free -h
   df -h
   ```

4. **Restart everything:**
   ```bash
   pm2 restart all
   docker restart nexus-postgres
   systemctl restart nginx
   ```

---

## Success! 🎉

Once the audit shows **"PRODUCTION READINESS: CONFIRMED"** with **100% success rate**, you're ready to launch!

```
=========================================
PRODUCTION READINESS: CONFIRMED
=========================================

✓ All critical systems operational
Success Rate: 100% (44 passed, 0 failed, 0 warnings)
=========================================
```

**Your Nexus COS platform is now fully deployed and ready for the November 17, 2025 @ 12:00 PM PST launch!** 🚀
