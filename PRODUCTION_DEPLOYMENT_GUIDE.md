# 🚀 Nexus COS Production Deployment Guide

## Overview

This guide provides complete instructions for deploying Nexus COS to production with **forced adherence to the Production Framework (PF)**. The deployment system ensures PM2 environment cache is completely cleared and services start with correct configuration.

## 🎯 What This Solves

### The Problem
PM2 caches environment variables in memory, which can cause:
- Old `DB_HOST` values (like `admin`) persisting even after configuration changes
- `.env` file updates being ignored
- Database connection errors (`getaddrinfo EAI_AGAIN admin`)
- Inconsistent service behavior after deployments

### The Solution
The production deployment script implements **forced PM2 adherence** by:
1. ✅ Killing PM2 daemon completely
2. ✅ Removing PM2 dump file (cached state)
3. ✅ Loading fresh environment from `ecosystem.config.js`
4. ✅ Verifying all services start correctly
5. ✅ Checking database connectivity
6. ✅ Automatic rollback on failure

---

## 📋 Prerequisites

Before deploying, ensure you have:

- [x] **Node.js** (v14 or higher)
- [x] **PM2** installed globally (`npm install -g pm2`)
- [x] **Git** for pulling code updates
- [x] **PostgreSQL** running (or Docker container)
- [x] SSH access to production server
- [x] Application deployed to `/opt/nexus-cos` (or your chosen directory)

### Optional Tools
- `jq` - For prettier JSON output (`apt-get install jq`)
- `curl` - For health endpoint checks (usually pre-installed)

---

## 🚀 Quick Start (First Time Deployment)

### Step 1: SSH to Production Server
```bash
ssh root@nexuscos.online
```

### Step 2: Navigate to Application Directory
```bash
cd /opt/nexus-cos
```

### Step 3: Run Initial Deployment
```bash
./nexus-cos-production-deploy.sh
```

This will:
- ✅ Pull latest code from repository
- ✅ Clear PM2 cache completely
- ✅ Configure database (localhost by default)
- ✅ Start all 33 services
- ✅ Verify deployment health
- ✅ Display status and useful commands

---

## 🔄 Daily Operations

### Starting Services (After System Restart)
```bash
./nexus-start.sh
```

This quick-start script:
- Skips code pull (uses current version)
- Clears PM2 cache
- Starts services immediately
- Perfect for daily use

### Updating and Redeploying
```bash
./nexus-cos-production-deploy.sh
```

### Stopping Services
```bash
pm2 stop all
```

### Restarting Specific Service
```bash
pm2 restart backend-api
```

### Viewing Logs
```bash
# All logs
pm2 logs

# Specific service
pm2 logs backend-api

# Last 100 lines
pm2 logs --lines 100
```

### Monitoring Services
```bash
pm2 monit
```

---

## 🎛️ Advanced Options

### Database Configuration Options

#### Option 1: Localhost PostgreSQL (Default)
```bash
./nexus-cos-production-deploy.sh
```

Uses:
- `DB_HOST: localhost`
- `DB_NAME: nexuscos_db`
- `DB_USER: nexuscos`
- `DB_PASSWORD: password`

#### Option 2: Docker PostgreSQL
```bash
./nexus-cos-production-deploy.sh --db-config=docker
```

Uses:
- `DB_HOST: nexus-cos-postgres`
- `DB_NAME: nexus_db`
- `DB_USER: nexus_user`
- `DB_PASSWORD: Momoney2025$`

#### Option 3: Remote Database
```bash
./nexus-cos-production-deploy.sh --db-config=remote
```

Prompts for:
- Custom DB_HOST
- Custom DB_NAME
- Custom DB_USER
- Custom DB_PASSWORD

### Deployment Options

#### Skip Code Pull (Use Current Version)
```bash
./nexus-cos-production-deploy.sh --no-pull
```

#### Skip Health Verification
```bash
./nexus-cos-production-deploy.sh --skip-verify
```

#### Force Deployment (Ignore Health Check Failures)
```bash
./nexus-cos-production-deploy.sh --force
```

#### Combine Options
```bash
./nexus-cos-production-deploy.sh --no-pull --skip-verify --db-config=docker
```

---

## 🔍 Verification

### Check Service Status
```bash
pm2 list
```

Expected output: All 33 services showing "online"

### Check Health Endpoint
```bash
curl -s https://nexuscos.online/health | jq
```

Expected output:
```json
{
  "status": "ok",
  "db": "up",
  "timestamp": "2024-10-06T23:15:30.123Z"
}
```

### Verify Database Connection
```bash
pm2 describe backend-api | grep DB_HOST
```

Should show: `DB_HOST: 'localhost'`

### Check PM2 Environment
```bash
pm2 jlist | jq '.[0].pm2_env.env' | grep DB_HOST
```

Should show: `"DB_HOST": "localhost"`

---

## 🐛 Troubleshooting

### Issue: Database Still Shows "down"

**Symptoms:**
```json
{
  "db": "down",
  "dbError": "getaddrinfo EAI_AGAIN admin"
}
```

**Solution:**
```bash
# Force complete cleanup
pm2 kill
rm -f ~/.pm2/dump.pm2
./nexus-cos-production-deploy.sh --force
```

### Issue: PostgreSQL Not Running

**Check status:**
```bash
sudo systemctl status postgresql
```

**Start PostgreSQL:**
```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql  # Auto-start on boot
```

### Issue: Services Not Starting

**Check logs:**
```bash
pm2 logs --lines 100
```

**Common causes:**
- Port already in use
- Missing dependencies
- Database not accessible
- File permissions

**Solution:**
```bash
# Clear everything and redeploy
pm2 kill
rm -rf ~/.pm2
./nexus-cos-production-deploy.sh
```

### Issue: "Connection Refused" to Database

**Verify PostgreSQL is listening:**
```bash
sudo netstat -nlp | grep 5432
```

**Check PostgreSQL config:**
```bash
sudo cat /etc/postgresql/*/main/postgresql.conf | grep listen_addresses
```

Should be: `listen_addresses = 'localhost'` or `listen_addresses = '*'`

### Issue: Wrong DB_HOST Still Cached

**Force complete PM2 reset:**
```bash
# Nuclear option - complete reset
pm2 kill
rm -rf ~/.pm2
rm -f /tmp/pm2*
./nexus-cos-production-deploy.sh
```

---

## 📊 Service Architecture

### All 33 Services

#### Phase 1: Core Infrastructure (3 services)
- `backend-api` (Port 3001)
- `ai-service` (Port 3010)
- `key-service` (Port 3014)

#### Phase 2: PUABO Ecosystem (18 services)
**Core Platform:**
- `puaboai-sdk` (Port 3012)
- `puabomusicchain` (Port 3013)
- `pv-keys` (Port 3015)
- `streamcore` (Port 3016)
- `glitch` (Port 3017)

**PUABO-DSP Services:**
- `puabo-dsp-upload-mgr` (Port 3211)
- `puabo-dsp-metadata-mgr` (Port 3212)
- `puabo-dsp-streaming-api` (Port 3213)

**PUABO-BLAC Services:**
- `puabo-blac-loan-processor` (Port 3221)
- `puabo-blac-risk-assessment` (Port 3222)

**PUABO-Nexus Services:**
- `puabo-nexus-ai-dispatch` (Port 3231)
- `puabo-nexus-driver-app-backend` (Port 3232)
- `puabo-nexus-fleet-manager` (Port 3233)
- `puabo-nexus-route-optimizer` (Port 3234)

**PUABO-Nuki Services:**
- `puabo-nuki-inventory-mgr` (Port 3241)
- `puabo-nuki-order-processor` (Port 3242)
- `puabo-nuki-product-catalog` (Port 3243)
- `puabo-nuki-shipping-service` (Port 3244)

#### Phase 3: Platform Services (8 services)
- `auth-service` (Port 3301)
- `content-management` (Port 3302)
- `creator-hub` (Port 3303)
- `user-auth` (Port 3304)
- `kei-ai` (Port 3401)
- `nexus-cos-studio-ai` (Port 3402)
- `puaboverse` (Port 3403)
- `streaming-service` (Port 3404)

#### Phase 4: Specialized Services (1 service)
- `boom-boom-room-live` (Port 3601)

#### Phase 5: V-Suite Pro Services (3 services)
- `v-caster-pro` (Port 3501)
- `v-prompter-pro` (Port 3502)
- `v-screen-pro` (Port 3503)

---

## 🔒 Security Considerations

### Database Credentials

**Default credentials** (for development):
```javascript
DB_HOST: 'localhost'
DB_NAME: 'nexuscos_db'
DB_USER: 'nexuscos'
DB_PASSWORD: 'password'
```

**⚠️ IMPORTANT:** Change default credentials in production!

### Update Credentials

1. Edit `ecosystem.config.js`
2. Update `DB_PASSWORD` for all services
3. Redeploy:
```bash
./nexus-cos-production-deploy.sh --no-pull
```

### Secure the ecosystem.config.js

```bash
chmod 600 ecosystem.config.js
```

---

## 📁 Backup and Recovery

### Automatic Backups

The deployment script automatically creates backups:
```
/tmp/nexus-cos-backup-YYYYMMDD-HHMMSS/
├── dump.pm2.backup
└── ecosystem.config.js.backup
```

### Manual Backup

```bash
# Backup PM2 configuration
pm2 save
cp ~/.pm2/dump.pm2 ~/nexus-cos-backup/

# Backup ecosystem config
cp ecosystem.config.js ~/nexus-cos-backup/
```

### Restore from Backup

```bash
# Restore PM2 state
cp ~/nexus-cos-backup/dump.pm2 ~/.pm2/
pm2 resurrect

# Restore ecosystem config
cp ~/nexus-cos-backup/ecosystem.config.js ./
pm2 restart all
```

---

## 🎯 Production Checklist

### Pre-Deployment
- [ ] PostgreSQL is running and accessible
- [ ] Database `nexuscos_db` exists with correct schema
- [ ] Database user `nexuscos` has proper permissions
- [ ] PM2 is installed globally
- [ ] Latest code is pulled from repository
- [ ] SSL certificates are valid (for HTTPS health check)
- [ ] Firewall allows required ports

### During Deployment
- [ ] Backup created successfully
- [ ] PM2 cache cleared completely
- [ ] All 33 services started
- [ ] No errors in deployment output

### Post-Deployment
- [ ] All services show "online" in `pm2 list`
- [ ] Health endpoint returns `"db": "up"`
- [ ] No database connection errors in logs
- [ ] Frontend is accessible at https://nexuscos.online
- [ ] PM2 configuration saved with `pm2 save`

### Long-Term Monitoring
- [ ] Set up `pm2 startup` for auto-restart on reboot
- [ ] Configure log rotation
- [ ] Set up monitoring alerts
- [ ] Schedule regular backups

---

## 🔗 Related Scripts

- `nexus-cos-production-deploy.sh` - Full production deployment
- `nexus-start.sh` - Quick start for daily use
- `fix-db-deploy.sh` - Legacy deployment script
- `verify-pm2-env.sh` - PM2 environment verification

---

## 📞 Support

### Quick Commands Reference

```bash
# Start Nexus COS
./nexus-start.sh

# Full deployment
./nexus-cos-production-deploy.sh

# View services
pm2 list

# View logs
pm2 logs

# Monitor services
pm2 monit

# Check health
curl -s https://nexuscos.online/health | jq

# Restart service
pm2 restart <service-name>

# Stop all
pm2 stop all

# Help
./nexus-cos-production-deploy.sh --help
```

### Getting Help

1. Check PM2 logs: `pm2 logs`
2. Check health endpoint: `curl https://nexuscos.online/health`
3. Verify PostgreSQL: `sudo systemctl status postgresql`
4. Check ecosystem config: `node -c ecosystem.config.js`

---

## 🎉 Success Indicators

When deployment is successful, you should see:

✅ All 33 services showing "online" in PM2  
✅ Health endpoint returns `{"status": "ok", "db": "up"}`  
✅ No errors in `pm2 logs`  
✅ Application accessible at https://nexuscos.online  
✅ Database queries working correctly  

**🎊 You're ready to use Nexus COS!**

---

**Version:** 1.0.0  
**Last Updated:** October 2024  
**Maintained by:** Nexus COS Team
