# Nexus COS Beta Launch - Quick Start Deployment Guide

**⚡ Fast-track deployment for TRAE and deployment team**

---

## 🎯 What Was Fixed

Based on TRAE's verification report, we fixed:

1. ✅ Missing `.env` files for admin and creator-hub
2. ✅ PUABO NEXUS fleet routes (404 errors fixed)
3. ✅ `/api/health` endpoint exposure
4. ✅ Frontend branding and landing page
5. ✅ Beta domain configuration

---

## 🚀 Quick Deployment (3 Steps)

### Step 1: SSH to Server

```bash
ssh root@75.208.155.161
cd /opt/nexus-cos
git pull origin main  # or clone if needed
```

### Step 2: Deploy Nginx Configs

```bash
# Backup, deploy, and reload nginx
sudo cp /etc/nginx/sites-available/nexuscos /etc/nginx/backups/nexuscos.backup 2>/dev/null || true
sudo cp deployment/nginx/nexuscos.online.conf /etc/nginx/sites-available/nexuscos
sudo cp deployment/nginx/beta.nexuscos.online.conf /etc/nginx/sites-available/beta.nexuscos
sudo ln -sf /etc/nginx/sites-available/nexuscos /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/beta.nexuscos /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

### Step 3: Validate Endpoints

```bash
# Run validation script
./scripts/validate-beta-launch-endpoints.sh
```

**Expected output:**
```
✅  BETA LAUNCH READY  ✅
All critical endpoints are responding correctly
```

---

## 📋 What Changed

### Nginx Routes Added

```nginx
# NEW: Standardized health endpoint
/api/health → http://127.0.0.1:4000/health

# NEW: PUABO NEXUS Fleet (ports 9001-9004)
/puabo-nexus/dispatch/health
/puabo-nexus/driver/health
/puabo-nexus/fleet/health
/puabo-nexus/routes/health
```

### Environment Files

All frontend modules now use same-origin `/api` paths:

```bash
# These are auto-created in deployment, but templates exist:
admin/.env.example        → VITE_API_URL=/api
creator-hub/.env.example  → VITE_API_URL=/api
frontend/.env             → VITE_API_URL=/api (updated)
```

### Frontend Landing Page

- Fixed corrupted `App.tsx`
- Added professional landing page with Nexus branding
- Services showcase for all platform offerings
- Beta launch section
- Responsive mobile design

---

## 🔍 Quick Health Check (Manual)

Test endpoints after deployment:

```bash
# Core endpoints
curl -I https://nexuscos.online/api/health
curl -I https://nexuscos.online/health/gateway

# PUABO NEXUS fleet
curl -I https://nexuscos.online/puabo-nexus/dispatch/health
curl -I https://nexuscos.online/puabo-nexus/driver/health
curl -I https://nexuscos.online/puabo-nexus/fleet/health
curl -I https://nexuscos.online/puabo-nexus/routes/health

# Beta domain
curl -I https://beta.nexuscos.online/
curl -I https://beta.nexuscos.online/api/health
```

**All should return:** `200 OK` (or `204 No Content` for some health endpoints)

---

## ⚠️ Troubleshooting

### If validation script shows failures:

**404 Errors:**
- Nginx routes not applied → Re-run Step 2
- Verify with: `sudo nginx -t`

**502/503 Errors:**
- Backend services not running on required ports
- Check: `sudo netstat -tlnp | grep ':9001\|:9002\|:9003\|:9004'`
- Start services if needed

**Connection Errors:**
- SSL certificate issues
- DNS not pointing to server
- Firewall blocking: `sudo ufw allow 80,443/tcp`

---

## 📚 Full Documentation

For complete details, see:
- `BETA_LAUNCH_FIXES_COMPLETE.md` - Comprehensive deployment guide
- `scripts/validate-beta-launch-endpoints.sh` - Validation script
- `PF_v2025.10.01_HEALTH_CHECKS.md` - Health endpoint specifications

---

## ✅ Success Criteria

After deployment, you should have:

- ✅ Nginx config valid (`nginx -t` passes)
- ✅ All health endpoints return 200
- ✅ Landing page loads at https://nexuscos.online
- ✅ Beta page loads at https://beta.nexuscos.online
- ✅ No Nginx warnings about conflicting server_name

---

## 🎉 You're Ready!

If validation script shows **"BETA LAUNCH READY"**, you're good to go!

Questions? Check the full documentation or contact the deployment team.

**Last Updated:** 2025-01-09  
**PF Version:** v2025.10.01  
**Status:** ✅ PRODUCTION READY
