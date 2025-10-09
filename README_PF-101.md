# PF-101: Nexus COS Platform Launch

**Complete platform deployment with working apex, beta, and API endpoints**

---

## 🎯 What This Is

PF-101 is a unified deployment that combines:
- ✅ Phase 2.5 deployment (apex + beta domains)
- ✅ API routing configuration
- ✅ Backend detection and proxying
- ✅ Comprehensive validation

**Result:** Fully operational Nexus COS platform in 5 minutes

---

## 📚 Documentation Index

### 🚀 Quick Start

**For TRAE SOLO (executor):**
→ [`PF-101-START-HERE.md`](PF-101-START-HERE.md)

**Quick command reference:**
→ [`PF-101-QUICK-REFERENCE.md`](PF-101-QUICK-REFERENCE.md)

### 📖 Complete Guides

| Document | Purpose | For |
|----------|---------|-----|
| [`PF-101-START-HERE.md`](PF-101-START-HERE.md) | Navigation & overview | Everyone |
| [`PF-101-UNIFIED-DEPLOYMENT.md`](PF-101-UNIFIED-DEPLOYMENT.md) | Complete PF documentation | Bobby/Technical |
| [`PF-101-TRAE-EXECUTION-GUIDE.md`](PF-101-TRAE-EXECUTION-GUIDE.md) | Step-by-step execution | TRAE SOLO |
| [`PF-101-QUICK-REFERENCE.md`](PF-101-QUICK-REFERENCE.md) | Command reference | TRAE SOLO |
| [`PF-100-vs-PF-101-COMPARISON.md`](PF-100-vs-PF-101-COMPARISON.md) | What changed from PF-100 | Technical review |

---

## 🚀 Quick Deploy (For TRAE)

### The Single Command

```bash
ssh root@nexuscos.online 'cd /opt/nexus-cos && git pull origin main && sudo ./DEPLOY_PHASE_2.5.sh'
```

### Or Step-by-Step

```bash
# 1. Connect
ssh root@nexuscos.online

# 2-4. Navigate and pull code
cd /opt/nexus-cos
git pull origin main

# 5. Deploy
sudo ./DEPLOY_PHASE_2.5.sh

# 6-10. Validate
curl -skI https://nexuscos.online/ | head -n 1
curl -skI https://beta.nexuscos.online/ | head -n 1
curl -skI https://nexuscos.online/api/ | head -n 1
curl -skI https://nexuscos.online/api/health | head -n 1
curl -skI https://nexuscos.online/api/system/status | head -n 1
```

**Expected:** All return `HTTP/2 200`

---

## ✅ What Gets Deployed

### 1. Domain Configuration
- **Apex:** https://nexuscos.online/
- **Beta:** https://beta.nexuscos.online/
- SSL/TLS enabled
- Security headers configured

### 2. API Routing
- **Root:** https://nexuscos.online/api/
- **Health:** https://nexuscos.online/api/health
- **Status:** https://nexuscos.online/api/system/status
- All endpoints proxied to working backend

### 3. Backend Integration
- Auto-detects backend on port 3004 or 3001
- Creates dynamic Nginx proxy configuration
- Configures proper headers and timeouts
- Enables WebSocket support

---

## 🔧 Key Files

### Deployment Scripts
- **`DEPLOY_PHASE_2.5.sh`** - Main deployment script
- **`scripts/deploy-phase-2.5-architecture.sh`** - Architecture deployment
- **`scripts/diagnose-deployment.sh`** - Diagnostic tool

### Configuration
- **`deployment/nginx/nexuscos.online.conf`** - Main Nginx config
- **`/etc/nginx/conf.d/nexuscos_api_proxy.conf`** - API proxy (created during deployment)

### Documentation
- **`PF-101-*.md`** - All PF-101 documentation files

---

## 📊 Architecture

```
Internet
    ↓
    │
    ▼
┌─────────────────────────────────────────────┐
│  Nginx (Port 443/80)                        │
│  - SSL/TLS Termination                      │
│  - Domain Routing                           │
│  - /api Proxy Configuration                 │
└────────┬────────────────────────────────────┘
         │
    ┌────┴──────────────────────┐
    │                           │
    ▼                           ▼
┌────────────────┐      ┌──────────────────┐
│  Static Files  │      │  Backend API     │
│  - Apex        │      │  Port: 3004      │
│  - Beta        │      │  Endpoints:      │
└────────────────┘      │  - /api/*        │
                        │  - /api/health   │
                        │  - /api/status   │
                        └──────────────────┘
```

---

## 🎯 Success Criteria

Deployment is successful when all of these return `200 OK`:

1. ✅ `curl -skI https://nexuscos.online/`
2. ✅ `curl -skI https://beta.nexuscos.online/`
3. ✅ `curl -skI https://nexuscos.online/api/`
4. ✅ `curl -skI https://nexuscos.online/api/health`
5. ✅ `curl -skI https://nexuscos.online/api/system/status`

---

## 🚨 If Something Fails

### 1. Run Diagnostics
```bash
cd /opt/nexus-cos
./scripts/diagnose-deployment.sh
```

### 2. Check Common Issues

**Nginx not reloading:**
```bash
sudo nginx -t
sudo tail -n 50 /var/log/nginx/error.log
```

**Backend not responding:**
```bash
curl http://localhost:3004/api/health
curl http://localhost:3001/api/health
```

**Endpoints returning wrong status:**
```bash
# Check detailed response
curl -skI https://nexuscos.online/api/ 
```

### 3. Report Issues

Include:
- Command that failed
- Full error message
- Output from diagnostic script
- Expected vs actual behavior

---

## 💡 Key Features

### Smart Backend Detection
- Automatically detects working backend
- Tries port 3004 first, then 3001
- Uses whichever is healthy

### Dynamic Configuration
- Creates `/etc/nginx/conf.d/nexuscos_api_proxy.conf`
- Routes /api to detected backend
- No hardcoded ports

### Comprehensive Validation
- Tests all domains
- Validates API endpoints
- Checks backend health
- Reports clear status

### Error Recovery
- Diagnostic script for troubleshooting
- Clear error messages
- Step-by-step guidance

---

## 🔄 Maintenance

### Update Deployment
```bash
cd /opt/nexus-cos
git pull origin main
sudo ./DEPLOY_PHASE_2.5.sh
```

### Check Status
```bash
# Nginx status
sudo systemctl status nginx

# Backend health
curl http://localhost:3004/api/health

# View logs
sudo tail -f /var/log/nginx/access.log
```

### Restart Services
```bash
# Nginx
sudo systemctl restart nginx

# If using PM2 for backend
pm2 restart all
```

---

## 📈 Monitoring

### Health Endpoints
- **System:** https://nexuscos.online/api/system/status
- **API:** https://nexuscos.online/api/health
- **Services:** https://nexuscos.online/api/services/:service/health

### Logs
- **Nginx Access:** `/var/log/nginx/access.log`
- **Nginx Error:** `/var/log/nginx/error.log`
- **Deployment:** `/opt/nexus-cos/logs/phase2.5/`

---

## 📝 Version History

### PF-101 (Current)
- ✅ Complete platform launch
- ✅ Working API endpoints
- ✅ Backend auto-detection
- ✅ Comprehensive validation

### PF-100 (Previous)
- ✅ Apex/Beta deployment
- ❌ API endpoints broken
- ❌ Required manual fixes

---

## 🎉 After Successful Deployment

Your platform is live at:
- **Apex:** https://nexuscos.online/
- **Beta:** https://beta.nexuscos.online/
- **API:** https://nexuscos.online/api/*

### Next Steps
1. Test all functionality in browser
2. Monitor logs for errors
3. Verify SSL certificates
4. Check backend performance
5. Schedule beta transition

---

## 📞 Support

### Documentation
- Full PF guide: [`PF-101-UNIFIED-DEPLOYMENT.md`](PF-101-UNIFIED-DEPLOYMENT.md)
- TRAE guide: [`PF-101-TRAE-EXECUTION-GUIDE.md`](PF-101-TRAE-EXECUTION-GUIDE.md)
- Quick ref: [`PF-101-QUICK-REFERENCE.md`](PF-101-QUICK-REFERENCE.md)

### Tools
- Diagnostic: `./scripts/diagnose-deployment.sh`
- Validation: `./scripts/validate-phase-2.5-deployment.sh`

### Troubleshooting
See [`PF-101-UNIFIED-DEPLOYMENT.md`](PF-101-UNIFIED-DEPLOYMENT.md) section 8

---

## ✅ Checklist Before Deploy

- [ ] SSH access to VPS
- [ ] Read appropriate documentation
- [ ] Understand what will be deployed
- [ ] Know troubleshooting steps
- [ ] Ready to follow instructions exactly

---

## 🚀 Ready to Deploy?

1. **For TRAE:** Start with [`PF-101-START-HERE.md`](PF-101-START-HERE.md)
2. **For Bobby:** Review [`PF-101-UNIFIED-DEPLOYMENT.md`](PF-101-UNIFIED-DEPLOYMENT.md)
3. **For Technical:** Check [`PF-100-vs-PF-101-COMPARISON.md`](PF-100-vs-PF-101-COMPARISON.md)

---

**Version:** 1.0  
**Created:** 2025-01-09  
**Status:** ✅ PRODUCTION READY  
**PF:** PF-101

---

**🎯 Goal:** Get Nexus COS Platform live in 5 minutes  
**🚀 Method:** Single command deployment  
**✅ Result:** All endpoints operational
