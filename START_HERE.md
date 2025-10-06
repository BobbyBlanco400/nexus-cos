# 🚀 START HERE - Nexus COS Quick Start

## Welcome to Nexus COS!

This is your complete guide to getting Nexus COS up and running in production.

---

## ⚡ Super Quick Start (3 Commands)

If you're on your production server and just want to start now:

```bash
cd /opt/nexus-cos
git pull origin main
./nexus-cos-production-deploy.sh
```

**That's it!** ✅ Nexus COS will be running with all 33 services.

---

## 🎯 What You Need to Know

### The Problem We Solved

PM2 was caching old environment variables (specifically `DB_HOST=admin`), causing database connection failures even after updating configuration files. The health endpoint showed:

```json
{
  "db": "down",
  "dbError": "getaddrinfo EAI_AGAIN admin"
}
```

### The Solution

We created a **bulletproof deployment system** that:
1. ✅ **Kills PM2 completely** - No more cached environment
2. ✅ **Removes dump files** - Clears all saved state
3. ✅ **Loads fresh config** - From `ecosystem.config.js`
4. ✅ **Verifies health** - Ensures database is connected
5. ✅ **Auto-rollback** - If anything fails

---

## 📦 What's Included

### Scripts

1. **`nexus-cos-production-deploy.sh`** ⭐ Main deployment script
   - Full production deployment
   - Automatic PM2 cache cleanup
   - Health verification
   - Rollback on failure
   
2. **`nexus-start.sh`** 🔄 Quick start script
   - For daily operations
   - Skips code pull
   - Faster startup
   
3. **`fix-db-deploy.sh`** 🔧 Legacy fix script
   - Original database fix
   - Still works but use new scripts instead

### Documentation

1. **`PRODUCTION_DEPLOYMENT_GUIDE.md`** 📚 Complete guide
   - Detailed instructions
   - Troubleshooting
   - All 33 services listed
   
2. **`START_HERE.md`** 📍 This file
   - Quick start
   - Overview
   
3. **`FIX_SUMMARY.md`** 📝 Technical details
   - What was broken
   - How we fixed it
   
4. **`PM2_FIX_README.md`** 🔍 PM2 specifics
   - PM2 cache issues
   - Verification commands

### Configuration

1. **`ecosystem.config.js`** ⚙️ PM2 configuration
   - All 33 services
   - Explicit DB environment variables
   - No hardcoded paths
   - **Ready to use!**

---

## 🎮 Usage Guide

### First Time Setup

```bash
# 1. SSH to your server
ssh root@nexuscos.online

# 2. Navigate to app directory
cd /opt/nexus-cos

# 3. Pull latest code (if not already done)
git pull origin main

# 4. Run deployment
./nexus-cos-production-deploy.sh

# 5. Verify it's working
curl -s https://nexuscos.online/health | jq
```

**Expected output:**
```json
{
  "status": "ok",
  "db": "up"
}
```

✅ **Success!** All 33 services are running.

### Daily Operations

**Start services (after reboot or stop):**
```bash
./nexus-start.sh
```

**Update and redeploy:**
```bash
./nexus-cos-production-deploy.sh
```

**Check status:**
```bash
pm2 list
```

**View logs:**
```bash
pm2 logs
```

**Monitor in real-time:**
```bash
pm2 monit
```

---

## 🔧 Advanced Usage

### Different Database Configurations

**Docker PostgreSQL:**
```bash
./nexus-cos-production-deploy.sh --db-config=docker
```

**Remote Database:**
```bash
./nexus-cos-production-deploy.sh --db-config=remote
```
(Will prompt for DB credentials)

### Deployment Options

**Skip code pull:**
```bash
./nexus-cos-production-deploy.sh --no-pull
```

**Force deployment (ignore health check):**
```bash
./nexus-cos-production-deploy.sh --force
```

**Skip health verification:**
```bash
./nexus-cos-production-deploy.sh --skip-verify
```

**Get help:**
```bash
./nexus-cos-production-deploy.sh --help
```

---

## 🩺 Health Checks

### Quick Health Check
```bash
curl -s https://nexuscos.online/health | jq
```

### Verify PM2 Environment
```bash
pm2 describe backend-api | grep DB_HOST
```

Should show: `DB_HOST: 'localhost'`

### Check All Services
```bash
pm2 list
```

All 33 services should show "online" status.

---

## 🐛 Troubleshooting

### Database Still Shows "admin" Error?

**Nuclear option (guaranteed fix):**
```bash
pm2 kill
rm -f ~/.pm2/dump.pm2
rm -rf ~/.pm2/logs/*
./nexus-cos-production-deploy.sh
```

### PostgreSQL Not Running?

```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Services Not Starting?

```bash
pm2 logs --lines 100
```

Check for error messages and address specific issues.

### Need to Start Fresh?

```bash
# Complete reset
pm2 kill
rm -rf ~/.pm2
./nexus-cos-production-deploy.sh
```

---

## 📊 The 33 Services

Your Nexus COS deployment includes:

### Core Services (3)
- backend-api
- ai-service
- key-service

### PUABO Ecosystem (18)
- puaboai-sdk
- puabomusicchain
- pv-keys
- streamcore
- glitch
- puabo-dsp-* (3 services)
- puabo-blac-* (2 services)
- puabo-nexus-* (4 services)
- puabo-nuki-* (4 services)

### Platform Services (8)
- auth-service
- content-management
- creator-hub
- user-auth
- kei-ai
- nexus-cos-studio-ai
- puaboverse
- streaming-service

### Specialized Services (1)
- boom-boom-room-live

### V-Suite Pro (3)
- v-caster-pro
- v-prompter-pro
- v-screen-pro

**Total: 33 services** running in production! 🎉

---

## ✅ Success Checklist

After deployment, verify:

- [ ] Run `pm2 list` - All 33 services showing "online"
- [ ] Run `curl https://nexuscos.online/health` - Shows `"db": "up"`
- [ ] Check `pm2 logs` - No error messages
- [ ] Access https://nexuscos.online - Site loads correctly
- [ ] Run `pm2 save` - Configuration saved for auto-restart

---

## 🎓 Learning More

### Read These Next:

1. **`PRODUCTION_DEPLOYMENT_GUIDE.md`** - Comprehensive deployment guide
2. **`FIX_SUMMARY.md`** - Technical details of what was fixed
3. **`ecosystem.config.js`** - Review service configuration

### Useful PM2 Commands:

```bash
pm2 list              # List all services
pm2 logs              # View all logs
pm2 logs <service>    # View specific service logs
pm2 monit             # Real-time monitoring
pm2 restart all       # Restart all services
pm2 restart <service> # Restart specific service
pm2 stop all          # Stop all services
pm2 delete all        # Delete all services
pm2 save              # Save current state
pm2 resurrect         # Restore saved state
pm2 startup           # Enable auto-start on boot
```

---

## 🆘 Quick Reference Card

### Start Nexus COS
```bash
./nexus-start.sh
```

### Deploy Updates
```bash
./nexus-cos-production-deploy.sh
```

### Check Health
```bash
curl -s https://nexuscos.online/health | jq
```

### View Status
```bash
pm2 list
```

### View Logs
```bash
pm2 logs
```

### Monitor Services
```bash
pm2 monit
```

### Fix Database Issues
```bash
pm2 kill
rm -f ~/.pm2/dump.pm2
./nexus-cos-production-deploy.sh
```

---

## 🎉 You're Ready!

Nexus COS is now configured with **forced adherence to the Production Framework**.

The deployment system ensures:
- ✅ No more cached environment variables
- ✅ Clean PM2 state on every deployment
- ✅ Automatic health verification
- ✅ Database connectivity guaranteed
- ✅ All 33 services running correctly

**Go build something amazing!** 🚀

---

## 📞 Need Help?

1. Check the logs: `pm2 logs`
2. Read the full guide: `PRODUCTION_DEPLOYMENT_GUIDE.md`
3. Verify config: `node -c ecosystem.config.js`
4. Check database: `sudo systemctl status postgresql`
5. Force redeploy: `./nexus-cos-production-deploy.sh --force`

---

**Version:** 1.0.0  
**Status:** ✅ Production Ready  
**Last Updated:** October 2024
