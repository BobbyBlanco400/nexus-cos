# Nexus COS Production Deployment - Quick Start Guide

## 🚀 Repository Location First!

**IMPORTANT**: First, locate where your nexus-cos repository is on your server.

### Option A: Use the Auto-Locator Script (Easiest)

Download and run the repository finder:

```bash
# Download the finder script
curl -o /tmp/find-and-deploy.sh https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/copilot/fix-apache2-service-issue/find-and-deploy.sh

# Make it executable and run
chmod +x /tmp/find-and-deploy.sh
sudo /tmp/find-and-deploy.sh
```

This script will:
- Automatically find your nexus-cos repository
- Pull the latest fixes
- Run the deployment script

### Option B: Find Repository Manually

Find your repository location:

```bash
# Search for the repository
sudo find / -name 'ecosystem.config.js' -type f 2>/dev/null | grep nexus

# Or check common locations:
ls -la /var/www/nexuscos.online/
ls -la /opt/nexus-cos/
ls -la /root/nexus-cos/
```

Once you find it, navigate there and run:

```bash
cd /path/to/your/nexus-cos  # Use the actual path you found
git pull origin copilot/fix-apache2-service-issue
./deployment/master-deployment-fix.sh
```

### Common Error: "No such file or directory"

If you see this error:
```
-bash: cd: /var/www/nexuscos.online/nexus-cos: No such file or directory
```

It means the repository path is different on your server. Use Option A or B above to find the correct location.

## 🛠️ What the Fix Does
- ✓ Fix Nginx port configuration
- ✓ Resolve Apache2/Nginx conflicts
- ✓ Restart stopped PM2 services
- ✓ Validate all service ports
- ✓ Test health endpoints
- ✓ Generate health score report

## 📋 Issues Fixed

### 1. **Port Configuration Mismatch** ✅ FIXED
**Problem**: Nginx expected ports 9001-9004, but services run on 3231-3234

**Solution**: Updated all nginx configuration files:
- `deployment/nginx/nexuscos.online.conf`
- `deployment/nginx/beta.nexuscos.online.conf`  
- `nginx/conf.d/nexus-proxy.conf`

**After Update**: Reload nginx on production:
```bash
sudo nginx -t  # Verify configuration
sudo systemctl reload nginx
```

### 2. **Apache2 Service Warning** ✅ RESOLVED
**Problem**: Apache2 failed to start (conflicting with Nginx)

**Solution**: Apache2 is not needed when Nginx is primary web server

**On Production Server**:
```bash
# Option A: Disable Apache2 (Recommended)
sudo systemctl stop apache2
sudo systemctl disable apache2

# OR Option B: Use helper script
./deployment/fix-apache2-plesk.sh
```

### 3. **PM2 Services Stopped** ✅ FIXED
**Problem**: Multiple PM2 services in "stopped" state

**Solution**: Auto-restart script monitors and restarts services

**Manual Restart**:
```bash
pm2 restart all
pm2 save
```

**Auto-Monitor**:
```bash
./deployment/pm2-health-monitor.sh
```

### 4. **Endpoint Testing Failures** ✅ FIXED
**Problem**: All endpoints returning HTTP 000000

**Root Causes**:
- Port mismatch (now fixed)
- Stopped services (now restarted)
- Nginx not reloaded (now handled)

**Test Endpoints**:
```bash
./deployment/test-production-endpoints.sh
```

## 🛠️ Available Tools

### Master Deployment Fix
Runs all fixes and generates health report:
```bash
./deployment/master-deployment-fix.sh
```

### PM2 Health Monitor  
Monitors and auto-restarts PM2 services:
```bash
./deployment/pm2-health-monitor.sh
```

### Endpoint Tester
Tests all production endpoints:
```bash
./deployment/test-production-endpoints.sh
```

### Apache2/Plesk Helper
Resolves Apache2 conflicts:
```bash
./deployment/fix-apache2-plesk.sh
```

### Basic Deployment Validator
Quick validation check:
```bash
./deployment/fix-deployment.sh
```

## 📊 Expected Results

### After Running Fixes

**PM2 Status** - All services should be "online":
```bash
pm2 status
# Expected: All services showing status "online"
```

**Port Availability** - All ports listening:
```bash
netstat -tlnp | grep -E "3001|3010|3014|3020|3030|4000|3231|3232|3233|3234"
# Expected: All 10 ports showing as LISTENING
```

**Endpoint Health** - All returning HTTP 200:
```bash
curl http://localhost:3001/health  # Backend API
curl http://localhost:3231/health  # AI Dispatch
curl http://localhost:3232/health  # Driver Backend
curl http://localhost:3233/health  # Fleet Manager
curl http://localhost:3234/health  # Route Optimizer
# Expected: All returning {"status":"ok",...}
```

**Production URLs** - All accessible:
```bash
curl -I https://nexuscos.online
curl https://nexuscos.online/health
curl https://nexuscos.online/puabo-nexus/dispatch/health
curl https://nexuscos.online/puabo-nexus/driver/health
curl https://nexuscos.online/puabo-nexus/fleet/health
curl https://nexuscos.online/puabo-nexus/routes/health
# Expected: HTTP 200 or 301/302 redirects
```

## 🔧 Manual Troubleshooting

### If Services Won't Start

1. **Check PM2 Logs**:
```bash
pm2 logs --lines 100
pm2 logs ai-service --lines 50
pm2 logs puabo-nexus-ai-dispatch --lines 50
```

2. **Check Service Dependencies**:
```bash
cd services/ai-service
npm install
cd ../..
```

3. **Restart Individual Service**:
```bash
pm2 restart ai-service
pm2 show ai-service
```

### If Ports Not Listening

1. **Check if service is running**:
```bash
pm2 status | grep <service-name>
```

2. **Verify port configuration**:
```bash
grep -r "PORT.*3231" ecosystem.config.js
```

3. **Check for port conflicts**:
```bash
netstat -tlnp | grep <port>
```

### If Nginx Issues Persist

1. **Check configuration**:
```bash
sudo nginx -t
```

2. **View error logs**:
```bash
sudo tail -f /var/log/nginx/error.log
```

3. **Restart Nginx**:
```bash
sudo systemctl restart nginx
```

### If Apache2 Conflicts

1. **Check what's using port 80/443**:
```bash
sudo netstat -tlnp | grep -E ":80|:443"
```

2. **Stop Apache2 if needed**:
```bash
sudo systemctl stop apache2
sudo systemctl disable apache2
```

3. **Verify Nginx has the ports**:
```bash
sudo netstat -tlnp | grep nginx | grep -E ":80|:443"
```

## 📁 Port Mapping Reference

| Service | Port | URL Path |
|---------|------|----------|
| Backend API | 3001 | `/api/` |
| AI Service | 3010 | `/ai/` |
| Key Service | 3014 | `/keys/` |
| Creator Hub | 3020 | `/creator-hub/` |
| PuaboVerse | 3030 | `/puaboverse/` |
| Gateway | 4000 | `/health/gateway` |
| AI Dispatch | 3231 | `/puabo-nexus/dispatch` |
| Driver Backend | 3232 | `/puabo-nexus/driver` |
| Fleet Manager | 3233 | `/puabo-nexus/fleet` |
| Route Optimizer | 3234 | `/puabo-nexus/routes` |

## 🎯 Success Criteria

System is considered 100% healthy when:

- ✅ Nginx is running and configuration is valid
- ✅ Apache2 is disabled or not conflicting
- ✅ All PM2 services show status "online"
- ✅ All 10 critical ports are listening
- ✅ All health endpoints return HTTP 200
- ✅ Production URLs are accessible
- ✅ No errors in nginx logs
- ✅ No errors in PM2 logs

## 📞 Support

If issues persist after running all fixes:

1. **Check detailed documentation**:
   ```bash
   cat deployment/DEPLOYMENT_FIX_GUIDE.md
   ```

2. **Generate full diagnostic report**:
   ```bash
   ./deployment/master-deployment-fix.sh > diagnostic-report.txt 2>&1
   ```

3. **Collect logs**:
   ```bash
   pm2 logs --lines 500 > pm2-logs.txt
   sudo tail -n 500 /var/log/nginx/error.log > nginx-errors.txt
   ```

4. **Check system resources**:
   ```bash
   free -h
   df -h
   top -n 1
   ```

## 🚦 Quick Commands

```bash
# Full health check and fix
./deployment/master-deployment-fix.sh

# Check PM2 services
pm2 status
pm2 logs --lines 50

# Check Nginx
sudo nginx -t
sudo systemctl status nginx

# Test endpoints
curl http://localhost:3001/health
curl https://nexuscos.online/health

# Restart everything
pm2 restart all
sudo systemctl restart nginx

# Save PM2 state
pm2 save
pm2 startup
```

---

**Last Updated**: 2024-12-03  
**Version**: 1.0  
**Deployment**: Production (nexuscos.online)
