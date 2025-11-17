# Nexus COS Deployment Fix - Quick Start Guide

This guide will help you fix all deployment issues and get Nexus COS running on your VPS server.

## 🚀 Quick Start (One Command)

```bash
./fix-deployment-issues.sh
```

That's it! The script will automatically:
- ✅ Fix PostgreSQL container conflicts
- ✅ Install all dependencies (root + services)
- ✅ Clean up errored PM2 processes
- ✅ Start all services correctly
- ✅ Validate everything is working

## 📋 What Was Fixed

Based on your error output, the following issues were addressed:

### 1. PostgreSQL Container Conflict ✅
**Error:** `The container name "/nexus-postgres" is already in use`

**Fix:** The script now detects existing containers and either:
- Starts them if stopped
- Removes and recreates if corrupted

### 2. Backend API Startup Issues ✅
**Error:** `error: unknown option '--port'` + 16 restarts

**Root Cause:** Missing root dependencies (routes require express)

**Fix:** 
- Installs root `node_modules` with `PUPPETEER_SKIP_DOWNLOAD=true`
- Installs service-specific dependencies
- Uses PM2 ecosystem config (environment variables, not CLI args)

### 3. PuaboMusicChain Errors ✅
**Error:** 16 restarts, errored state

**Fix:** Same as above - missing dependencies resolved

### 4. Missing Audit Script ✅
**Error:** `Cannot find audit script`

**Fix:** Created `production-audit.sh` for comprehensive validation

## 🛠️ Available Scripts

### 1. fix-deployment-issues.sh (Main Fix Script)
Fixes all deployment issues automatically.

```bash
./fix-deployment-issues.sh
```

**What it does:**
- Fixes PostgreSQL container
- Installs dependencies
- Cleans up errored processes
- Starts services with PM2
- Runs basic validation

### 2. production-audit.sh (Comprehensive Audit)
Detailed audit of your entire deployment.

```bash
./production-audit.sh
```

**Checks:**
- Docker services
- PM2 service status
- Port availability
- Health endpoints
- Configuration files
- Dependencies
- System resources
- Nginx configuration
- SSL certificates
- Environment variables

### 3. quick-deployment-check.sh (Quick Validation)
Fast check to see if everything is working.

```bash
./quick-deployment-check.sh
```

**Checks:**
- PM2 services online/errored
- PostgreSQL status
- Service endpoints responding
- Ports listening
- System resources

## 📝 Step-by-Step Manual Deployment

If you prefer to understand what's happening:

### Step 1: Navigate to Project Directory
```bash
cd /var/www/nexuscos.online/nexus-cos-app/nexus-cos
```

### Step 2: Pull Latest Changes
```bash
git pull origin copilot/fix-deployment-issues
```

### Step 3: Run the Fix Script
```bash
./fix-deployment-issues.sh
```

### Step 4: Verify Deployment
```bash
./quick-deployment-check.sh
```

### Step 5: Run Full Audit (Optional)
```bash
./production-audit.sh
```

## ✅ Verification Commands

### Check PM2 Services
```bash
pm2 list
```

Expected output: All services showing "online" status

### Test Service Endpoints
```bash
# Backend API
curl http://localhost:3001/health

# PuaboMusicChain
curl http://localhost:3013/health

# V-Screen Hollywood (if running)
curl http://localhost:8088/health
```

### Check PostgreSQL
```bash
docker ps | grep nexus-postgres
docker exec nexus-postgres pg_isready -U nexuscos
```

### View Logs
```bash
# All logs
pm2 logs

# Specific service
pm2 logs backend-api

# Last 50 lines
pm2 logs backend-api --lines 50
```

## 🔧 Troubleshooting

### Service Still Errored After Fix?

1. **Check the logs:**
```bash
pm2 logs <service-name> --lines 50
```

2. **Restart the service:**
```bash
pm2 restart <service-name>
```

3. **Delete and recreate:**
```bash
pm2 delete <service-name>
pm2 start ecosystem.config.js --only <service-name>
```

### PostgreSQL Not Starting?

1. **Check container status:**
```bash
docker ps -a | grep nexus-postgres
```

2. **Check logs:**
```bash
docker logs nexus-postgres
```

3. **Remove and recreate:**
```bash
docker rm -f nexus-postgres
./fix-deployment-issues.sh
```

### Port Already in Use?

1. **Find what's using the port:**
```bash
lsof -i :3001
```

2. **Kill the process:**
```bash
kill -9 <PID>
```

3. **Or use PM2 to manage:**
```bash
pm2 delete <service-name>
pm2 start ecosystem.config.js --only <service-name>
```

## 📊 Expected Results

After running `./fix-deployment-issues.sh`, you should see:

```
✅ PostgreSQL container configured
✅ Root dependencies installed
✅ Service dependencies installed
✅ Errored PM2 processes cleaned up
✅ Services restarted from ecosystem configuration
✅ PM2 configuration saved
```

And when running `pm2 list`:

```
┌────┬────────────────────┬──────────┬──────┬───────────┬──────────┬──────────┐
│ id │ name               │ mode     │ ↺    │ status    │ cpu      │ memory   │
├────┼────────────────────┼──────────┼──────┼───────────┼──────────┼──────────┤
│ 0  │ backend-api        │ cluster  │ 0    │ online    │ 0%       │ 72mb     │
│ 1  │ puabomusicchain    │ cluster  │ 0    │ online    │ 0%       │ 64mb     │
│ ... │ ...                │ ...      │ ...  │ online    │ ...      │ ...      │
└────┴────────────────────┴──────────┴──────┴───────────┴──────────┴──────────┘
```

All services should show **"online"** status with **0 restarts**.

## 🔐 Security Fixes Applied

The following security vulnerabilities were fixed:

1. **body-parser**: Updated from 1.20.2 to 1.20.3
   - Fixed DoS vulnerability

2. **mysql2**: Updated from 3.2.0 to 3.9.8
   - Fixed Remote Code Execution (RCE)
   - Fixed Prototype Pollution
   - Fixed arbitrary code injection

## 📚 Documentation

- **Detailed Troubleshooting:** [FIXING_DEPLOYMENT_ISSUES.md](./FIXING_DEPLOYMENT_ISSUES.md)
- **Ecosystem Config:** [ecosystem.config.js](./ecosystem.config.js)
- **Environment Setup:** [.env.example](./.env.example)

## 🎯 Next Steps

Once everything is running:

1. **Setup PM2 to start on boot:**
```bash
pm2 save
pm2 startup
# Follow the instructions shown
```

2. **Configure Nginx (if needed):**
```bash
sudo cp nginx.conf /etc/nginx/sites-available/nexuscos.online
sudo ln -s /etc/nginx/sites-available/nexuscos.online /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

3. **Setup SSL with Let's Encrypt:**
```bash
sudo certbot --nginx -d nexuscos.online -d www.nexuscos.online
```

4. **Setup monitoring:**
```bash
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

## 💡 Tips

- **Always check logs first:** `pm2 logs`
- **Keep PM2 updated:** `npm install pm2@latest -g`
- **Monitor resources:** `pm2 monit`
- **Backup regularly:** Backup your database and `.env` file
- **Use PM2 ecosystem file:** Don't start services with CLI arguments

## 🆘 Need Help?

If issues persist:

1. Run the diagnostic scripts:
```bash
./quick-deployment-check.sh
./production-audit.sh
```

2. Collect logs:
```bash
pm2 logs --lines 100 > pm2-logs.txt
docker logs nexus-postgres > postgres-logs.txt
```

3. Check environment:
```bash
cat .env
pm2 describe backend-api
```

## 📄 License

Copyright © 2024 Nexus COS. All rights reserved.
