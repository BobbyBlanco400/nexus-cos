# Nexus COS Deployment Fix Guide

## Issues Identified and Fixed

### 1. Port Configuration Mismatch (CRITICAL - FIXED)

**Problem**: Nginx configuration expected PUABO NEXUS Fleet Services on ports 9001-9004, but PM2 ecosystem configuration had them on ports 3231-3234.

**Impact**: 
- Missing listening ports (9001-9004)
- PUABO NEXUS services unreachable via nginx proxy
- Endpoint health checks failing

**Fix Applied**:
Updated nginx configuration files to use correct ports:
- `deployment/nginx/nexuscos.online.conf` - Production config
- `deployment/nginx/beta.nexuscos.online.conf` - Beta config  
- `nginx/conf.d/nexus-proxy.conf` - Docker/Proxy config

**Port Mapping**:
```
Service                    Old Port → New Port
--------------------------------------------
AI Dispatch               9001     → 3231
Driver Backend            9002     → 3232
Fleet Manager             9003     → 3233
Route Optimizer           9004     → 3234
```

**Verification**:
```bash
# On production server, verify services are listening on correct ports
netstat -tlnp | grep -E "3231|3232|3233|3234"

# Test health endpoints
curl http://localhost:3231/health  # AI Dispatch
curl http://localhost:3232/health  # Driver Backend
curl http://localhost:3233/health  # Fleet Manager
curl http://localhost:3234/health  # Route Optimizer
```

### 2. Apache2 Service Warning (LOW PRIORITY)

**Problem**: Apache2 service failed to start via Plesk

**Root Cause**: The system is primarily using Nginx as the web server, and Apache2 is not required for the current deployment architecture.

**Resolution Options**:

**Option A - Disable Apache2 (Recommended)**:
```bash
# Stop Apache2 completely if nginx is primary
sudo systemctl stop apache2
sudo systemctl disable apache2
```

**Option B - Investigate Apache2 Port Conflict**:
```bash
# Check if port 80/443 is already in use by nginx
sudo netstat -tlnp | grep -E ":80|:443"

# If Apache2 is needed, configure it to use different ports
# Edit /etc/apache2/ports.conf
# Change Listen 80 to Listen 8080
# Change Listen 443 to Listen 8443
```

**Option C - Run Both (Advanced)**:
```bash
# Configure Apache2 to run on alternate ports
# Update Plesk configuration to handle port binding
sudo /opt/psa/admin/sbin/httpdmng --reconfigure-all
```

### 3. PM2 Service Stability Issues

**Problem**: Multiple PM2 services showing as "stopped" after deployment:
- ai-service (id: 0)
- auth-service (id: 2)  
- puabo-nexus-driver-app (id: 9)
- v-stage (id: 20)
- puaboai-sdk (id: 28)
- streaming-service-v2 (id: 29)
- studio-ai (id: 38)
- streamcore (id: 30)

**Root Cause**: Services may have:
- Crashed due to missing dependencies
- Port conflicts
- Configuration errors
- Database connection issues

**Fix Steps**:

1. **Check PM2 logs for specific errors**:
```bash
pm2 logs ai-service --lines 50
pm2 logs puabo-nexus-driver-app-backend --lines 50
pm2 logs v-stage --lines 50
```

2. **Restart stopped services**:
```bash
# Restart all stopped services
pm2 restart all

# Or restart specific services
pm2 restart ai-service
pm2 restart puabo-nexus-driver-app-backend
pm2 restart v-stage
pm2 restart puaboai-sdk
```

3. **Enable automatic restart on failure**:
```bash
# PM2 should already be configured with autorestart: true
# Verify with:
pm2 show ai-service | grep "autorestart"

# If needed, update ecosystem config and reload:
pm2 reload ecosystem.config.js
```

4. **Save PM2 configuration**:
```bash
pm2 save
pm2 startup
```

### 4. Endpoint Testing Failures

**Problem**: All 6 endpoints returning HTTP 000000:
- Main Site
- API Health
- Creator Hub
- Studio AI
- Root Socket.IO
- Streaming Socket.IO

**Root Causes**:
1. Services not running (PM2 stopped services)
2. Port mismatch (fixed above)
3. Nginx not properly configured or reloaded
4. SSL certificate issues

**Fix Steps**:

1. **Reload Nginx configuration**:
```bash
# Test nginx configuration
sudo nginx -t

# If valid, reload nginx
sudo systemctl reload nginx
# OR
sudo service nginx reload
```

2. **Restart all PM2 services**:
```bash
pm2 restart all
pm2 status
```

3. **Test endpoints locally first**:
```bash
# Use the provided test script
./deployment/test-production-endpoints.sh
```

4. **Check SSL certificates**:
```bash
# Verify SSL certificates exist
ls -la /etc/ssl/ionos/

# Expected files:
# - fullchain.pem
# - privkey.pem  
# - chain.pem
```

5. **Test specific endpoints**:
```bash
# Test main site (should redirect to HTTPS)
curl -I http://nexuscos.online

# Test API health
curl https://nexuscos.online/health

# Test PUABO NEXUS services
curl https://nexuscos.online/puabo-nexus/dispatch/health
curl https://nexuscos.online/puabo-nexus/driver/health
curl https://nexuscos.online/puabo-nexus/fleet/health
curl https://nexuscos.online/puabo-nexus/routes/health
```

## Deployment Checklist

Use this checklist after applying fixes:

- [ ] **Nginx Configuration Updated**
  - [ ] Port mappings corrected (9001-9004 → 3231-3234)
  - [ ] Nginx configuration tested: `sudo nginx -t`
  - [ ] Nginx reloaded: `sudo systemctl reload nginx`

- [ ] **PM2 Services Running**
  - [ ] All critical services started: `pm2 status`
  - [ ] No services in "stopped" state
  - [ ] Logs checked for errors: `pm2 logs --lines 50`
  - [ ] PM2 configuration saved: `pm2 save`

- [ ] **Port Availability**
  - [ ] Core ports listening: 3001, 3010, 3014, 3020, 3030, 4000
  - [ ] PUABO NEXUS ports listening: 3231, 3232, 3233, 3234
  - [ ] No port conflicts: `netstat -tlnp`

- [ ] **Health Endpoints**
  - [ ] Local health checks passing
  - [ ] Production URL health checks passing
  - [ ] All PUABO NEXUS health endpoints responding

- [ ] **Production URLs**
  - [ ] https://nexuscos.online - Main site accessible
  - [ ] https://nexuscos.online/health - API health check
  - [ ] https://nexuscos.online/api/ - API endpoints
  - [ ] https://nexuscos.online/puabo-nexus/* - Fleet services

## Quick Recovery Commands

If issues persist, use these commands:

```bash
# 1. Full PM2 restart
pm2 delete all
pm2 start ecosystem.config.js
pm2 save

# 2. Nginx full restart
sudo systemctl restart nginx

# 3. Check all services
pm2 status
sudo systemctl status nginx

# 4. View logs
pm2 logs --lines 100
sudo tail -f /var/log/nginx/error.log

# 5. Test all endpoints
./deployment/test-production-endpoints.sh
```

## Expected Results After Fixes

### PM2 Status
All services should show status "online":
```
┌────┬────────────────────┬──────────┬──────┬───────────┬──────────┬──────────┐
│ id │ name               │ mode     │ ↺    │ status    │ cpu      │ memory   │
├────┼────────────────────┼──────────┼──────┼───────────┼──────────┼──────────┤
│ 0  │ ai-service         │ fork     │ 0    │ online    │ 0%       │ 50mb     │
│ 1  │ auth-service-v2    │ fork     │ 0    │ online    │ 0%       │ 50mb     │
...
└────┴────────────────────┴──────────┴──────┴───────────┴──────────┴──────────┘
```

### Port Listening
All expected ports should be listening:
```
[✓] Backend API (3001) - LISTENING
[✓] AI Service (3010) - LISTENING
[✓] Key Service (3014) - LISTENING
[✓] Creator Hub (3020) - LISTENING
[✓] PuaboVerse (3030) - LISTENING
[✓] Gateway (4000) - LISTENING
[✓] AI Dispatch (3231) - LISTENING
[✓] Driver Backend (3232) - LISTENING
[✓] Fleet Manager (3233) - LISTENING
[✓] Route Optimizer (3234) - LISTENING
```

### Endpoint Testing
All production endpoints should return HTTP 200:
```
Testing Main Site... ✓ HTTP 200
Testing API Health... ✓ HTTP 200
Testing Creator Hub... ✓ HTTP 200
Testing Studio AI... ✓ HTTP 200
Testing Root Socket.IO... ✓ HTTP 200
Testing Streaming Socket.IO... ✓ HTTP 200
```

## Support

If issues persist after applying all fixes:

1. Check system resources: `free -h`, `df -h`
2. Review full logs: `pm2 logs --lines 500`
3. Check database connectivity
4. Verify firewall rules: `sudo ufw status`
5. Check SELinux/AppArmor if applicable

## Files Modified

- `deployment/nginx/nexuscos.online.conf` - Fixed port mappings
- `deployment/nginx/beta.nexuscos.online.conf` - Fixed port mappings
- `nginx/conf.d/nexus-proxy.conf` - Fixed port mappings
- `deployment/test-production-endpoints.sh` - New endpoint testing script
- `deployment/DEPLOYMENT_FIX_GUIDE.md` - This guide
