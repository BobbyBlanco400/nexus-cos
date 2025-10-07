# 📚 Nexus COS VPS Deployment - Complete Index

**Your complete guide to deploying Nexus COS OTT/Streaming Platform on a VPS**

---

## 🚀 Quick Navigation

### For New Users (Start Here!)
1. **[Quick Start Card](QUICK_START_CARD.md)** - Print/bookmark this for instant access
2. **[VPS One-Shot Deploy Guide](VPS_ONE_SHOT_DEPLOY.md)** - Complete deployment documentation
3. **[Readiness Check](#readiness-check)** - Verify your VPS before deployment

### For Existing Users
1. **[Production Deployment Guide](PRODUCTION_DEPLOYMENT_GUIDE.md)** - Advanced deployment options
2. **[Bulletproof One-Liner](BULLETPROOF_ONE_LINER.md)** - Technical deployment details
3. **[TRAE Solo Guide](TRAE_SOLO_DEPLOYMENT_GUIDE.md)** - TRAE Solo orchestration

---

## ⚡ THE ONE-LINER (All You Need)

```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash
```

This single command deploys your complete Nexus COS platform in 5-10 minutes!

---

## 📖 Documentation Structure

### Level 1: Getting Started (Beginners)

| Document | Purpose | Time to Read |
|----------|---------|--------------|
| **[QUICK_START_CARD.md](QUICK_START_CARD.md)** | One-page quick reference | 2 min |
| **[VPS_ONE_SHOT_DEPLOY.md](VPS_ONE_SHOT_DEPLOY.md)** | Complete VPS deployment guide | 10 min |
| **[START_HERE.md](START_HERE.md)** | Project overview and quick start | 5 min |
| **[README.md](README.md)** | Main project documentation | 10 min |

### Level 2: Technical Details

| Document | Purpose | Time to Read |
|----------|---------|--------------|
| **[BULLETPROOF_ONE_LINER.md](BULLETPROOF_ONE_LINER.md)** | Technical deployment details | 15 min |
| **[TRAE_SOLO_DEPLOYMENT_GUIDE.md](TRAE_SOLO_DEPLOYMENT_GUIDE.md)** | TRAE Solo orchestration guide | 15 min |
| **[PRODUCTION_DEPLOYMENT_GUIDE.md](PRODUCTION_DEPLOYMENT_GUIDE.md)** | Advanced production deployment | 20 min |
| **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** | Pre-launch verification | 10 min |

### Level 3: Platform Features

| Document | Purpose | Time to Read |
|----------|---------|--------------|
| **[docs/FRONTEND_TRANSFORMATION.md](docs/FRONTEND_TRANSFORMATION.md)** | Frontend branding and features | 15 min |
| **[PF_README.md](PF_README.md)** | Pre-Flight deployment system | 10 min |
| **[DEPLOYMENT_COMPLETE_SUMMARY.md](DEPLOYMENT_COMPLETE_SUMMARY.md)** | Technical summary | 10 min |

---

## 🎯 Common Deployment Scenarios

### Scenario 1: First-Time VPS Deployment

**You have:** A fresh VPS, root access  
**You want:** Complete Nexus COS platform running

**Steps:**
1. Check readiness: `curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/check-vps-readiness.sh | bash`
2. Deploy platform: `curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash`
3. Access platform: `https://YOUR_VPS_IP/`

**Documentation:**
- [VPS One-Shot Deploy Guide](VPS_ONE_SHOT_DEPLOY.md)
- [Quick Start Card](QUICK_START_CARD.md)

---

### Scenario 2: Existing Repository Update

**You have:** Nexus COS already installed  
**You want:** Update to latest version

**Steps:**
1. Navigate: `cd /opt/nexus-cos`
2. Update: `git pull origin main`
3. Deploy: `./nexus-cos-production-deploy.sh`

**Documentation:**
- [Production Deployment Guide](PRODUCTION_DEPLOYMENT_GUIDE.md)
- [START_HERE.md](START_HERE.md)

---

### Scenario 3: Custom Domain Setup

**You have:** Platform deployed  
**You want:** Use custom domain with SSL

**Steps:**
1. Point DNS to your VPS IP
2. Set domain: `export DOMAIN="your-domain.com"`
3. Install SSL: `sudo certbot --nginx -d your-domain.com -d www.your-domain.com`
4. Test: `https://your-domain.com/health`

**Documentation:**
- [VPS One-Shot Deploy Guide - Security & SSL](VPS_ONE_SHOT_DEPLOY.md#-security--ssl)

---

### Scenario 4: Development Setup

**You have:** Windows machine with WSL  
**You want:** Sync local files to VPS

**Steps:**
1. Set local path: `export FRONTEND_DIST_LOCAL="/mnt/c/path/to/dist"`
2. Run deployment: `sudo bash /opt/nexus-cos/trae-solo-bulletproof-deploy.sh`

**Documentation:**
- [Bulletproof One-Liner - WSL File Sync](BULLETPROOF_ONE_LINER.md#with-wsl-file-sync)

---

### Scenario 5: Troubleshooting Failed Deployment

**You have:** Deployment failed  
**You want:** Diagnose and fix issues

**Steps:**
1. Check logs: `cat /opt/nexus-cos/logs/errors-*.log`
2. View service: `sudo systemctl status nexuscos-app`
3. Test health: `curl http://localhost:3000/health`
4. Review guide: See troubleshooting section below

**Documentation:**
- [VPS One-Shot Deploy Guide - Troubleshooting](VPS_ONE_SHOT_DEPLOY.md#-troubleshooting)

---

## 🔍 Readiness Check

Before deploying, verify your VPS meets requirements:

```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/check-vps-readiness.sh | bash
```

**What it checks:**
- ✅ OS version (Ubuntu 20.04+/Debian 10+)
- ✅ RAM (4GB minimum, 8GB recommended)
- ✅ Disk space (10GB minimum)
- ✅ CPU cores (2 minimum, 4 recommended)
- ✅ Root/sudo access
- ✅ Network connectivity
- ✅ Port availability (80, 443, 3000, 5432, 6379)
- ✅ Required commands (curl, git, nginx, etc.)
- ✅ Firewall configuration
- ✅ SELinux status

---

## 📊 Deployment Process Overview

### Phase 1-3: Pre-Deployment (1-2 minutes)
1. **Pre-flight Checks** - System validation
2. **File Synchronization** - Code preparation
3. **Configuration Validation** - Environment setup

### Phase 4-6: Build & Deploy (3-5 minutes)
4. **Dependency Installation** - npm/pip packages
5. **Application Builds** - Frontend/backend compilation
6. **Main Service Deployment** - Systemd service creation

### Phase 7-9: Infrastructure (1-2 minutes)
7. **Microservices Deployment** - All integrated modules
8. **Nginx Configuration** - Reverse proxy + SSL
9. **Service Verification** - Status checks

### Phase 10-12: Validation (1 minute)
10. **Health Checks** - Endpoint testing
11. **Log Monitoring** - Error detection
12. **Final Validation** - Complete verification

**Total Time:** 5-10 minutes

---

## 🎨 What You Get

### Complete OTT/Streaming TV Platform

**Frontend Features:**
- 📺 Live TV channel grid with status indicators
- 🎬 On-Demand content library with search/filters
- 🎯 Integrated module marketplace
- 📊 Real-time analytics dashboard
- 💰 Subscription tier management
- ⚙️ Platform settings and configuration

**Integrated Modules:**
- 🎪 **Club Saditty** - Entertainment venue
- 💼 **V-Suite** - Business productivity tools
- 🎨 **Creator Hub** - Content creation dashboard
- 🌐 **PuaboVerse** - Virtual world platform
- 🎥 **V-Screen Hollywood** - Premium content
- 📊 **Analytics** - Platform insights

**Backend Infrastructure:**
- Node.js API server (Express.js)
- Python microservices (FastAPI)
- PostgreSQL database
- Redis cache
- Nginx reverse proxy
- SSL/TLS encryption
- Systemd service management
- Automated health monitoring

---

## 🔐 Security Features

After deployment, your platform includes:

### SSL/TLS
- ✅ HTTPS enforcement (HTTP → HTTPS redirect)
- ✅ TLS 1.2 and 1.3 only
- ✅ Strong cipher suites
- ✅ HSTS (HTTP Strict Transport Security)
- ✅ SSL session caching

### Security Headers
- ✅ X-Frame-Options: SAMEORIGIN
- ✅ X-Content-Type-Options: nosniff
- ✅ X-XSS-Protection: 1; mode=block
- ✅ Referrer-Policy: strict-origin-when-cross-origin
- ✅ Content-Security-Policy

### Access Control
- ✅ Hidden file blocking (.git, .env, etc.)
- ✅ Service isolation with systemd
- ✅ Proper file permissions
- ✅ Root-level security

---

## 🛠️ Management Commands

### Service Management
```bash
# Check status
sudo systemctl status nexuscos-app

# Start/stop/restart
sudo systemctl start nexuscos-app
sudo systemctl stop nexuscos-app
sudo systemctl restart nexuscos-app

# View logs
sudo journalctl -u nexuscos-app -f
```

### Health Checks
```bash
# Local health check
curl http://localhost:3000/health

# Public health check
curl https://YOUR_VPS_IP/health

# API health check
curl https://YOUR_VPS_IP/api/health
```

### Nginx Management
```bash
# Test configuration
sudo nginx -t

# Reload (no downtime)
sudo systemctl reload nginx

# Restart
sudo systemctl restart nginx

# View logs
sudo tail -f /var/log/nginx/nexus-cos.error.log
```

---

## 🐛 Quick Troubleshooting

### Service Won't Start
```bash
sudo journalctl -u nexuscos-app -n 50
sudo systemctl restart nexuscos-app
```

### Port Already in Use
```bash
sudo ss -ltnp | grep ':3000'
sudo kill -9 <PID>
```

### Database Connection Issues
```bash
sudo systemctl status postgresql
sudo -u postgres psql -d nexus_cos -c "SELECT 1;"
```

### Nginx 502 Bad Gateway
```bash
curl http://localhost:3000/health
sudo systemctl restart nexuscos-app
sudo systemctl reload nginx
```

### Disk Space Issues
```bash
df -h /opt/nexus-cos
sudo apt-get clean && sudo apt-get autoremove
```

---

## 📈 Performance Optimization

After deployment, your platform includes:

- ✅ Gzip compression for static assets
- ✅ Browser caching (1 year for static files)
- ✅ HTTP/2 enabled
- ✅ SSL session caching
- ✅ Redis caching for API responses
- ✅ Nginx request buffering
- ✅ Keep-alive connections
- ✅ Optimized proxy settings

---

## 🔄 Updates & Maintenance

### Update Platform
```bash
cd /opt/nexus-cos
git pull origin main
sudo bash trae-solo-bulletproof-deploy.sh
```

### Create Backup
```bash
# Backup files
sudo tar -czf /backups/nexus-cos-$(date +%Y%m%d).tar.gz /opt/nexus-cos

# Backup database
sudo -u postgres pg_dump nexus_cos > /backups/nexus-cos-db-$(date +%Y%m%d).sql
```

### Restore Backup
```bash
# Restore files
sudo tar -xzf /backups/nexus-cos-YYYYMMDD.tar.gz -C /

# Restore database
sudo -u postgres psql nexus_cos < /backups/nexus-cos-db-YYYYMMDD.sql

# Restart services
sudo systemctl restart nexuscos-app
```

---

## 📞 Getting Help

### Check Deployment Reports
```bash
# View comprehensive report
cat /opt/nexus-cos/TRAE_SOLO_BULLETPROOF_DEPLOYMENT_REPORT.md

# View deployment logs
cat /opt/nexus-cos/logs/deployment-*.log

# View error logs
cat /opt/nexus-cos/logs/errors-*.log
```

### Community Support
- **GitHub Issues**: https://github.com/BobbyBlanco400/nexus-cos/issues
- **Documentation**: https://github.com/BobbyBlanco400/nexus-cos/tree/main/docs

---

## ✅ Success Checklist

After deployment, verify:

- [ ] Main frontend accessible at `https://YOUR_VPS_IP/`
- [ ] Admin panel accessible at `https://YOUR_VPS_IP/admin/`
- [ ] Health check passes: `curl https://YOUR_VPS_IP/health`
- [ ] API endpoints responding: `curl https://YOUR_VPS_IP/api/health`
- [ ] Service running: `sudo systemctl status nexuscos-app`
- [ ] Nginx working: `sudo systemctl status nginx`
- [ ] Database connected: Check health endpoint shows `"db": "up"`
- [ ] All navigation sections functional
- [ ] Statistics dashboard updating
- [ ] SSL/HTTPS working correctly

---

## 🎉 What's Next?

After successful deployment:

1. **Configure SSL** - Set up Let's Encrypt for production domain
2. **Customize Branding** - Update platform branding in frontend
3. **Add Content** - Upload live channels and on-demand content
4. **Configure Modules** - Enable/disable integrated modules
5. **Set Up Monitoring** - Configure log monitoring and alerts
6. **Create Backups** - Set up automated backup schedule
7. **Invite Users** - Start onboarding users to your platform

---

## 📝 Quick Reference

**Main Command:**
```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash
```

**Readiness Check:**
```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/check-vps-readiness.sh | bash
```

**Health Check:**
```bash
curl http://localhost:3000/health
```

**View Logs:**
```bash
sudo journalctl -u nexuscos-app -f
```

**Restart Service:**
```bash
sudo systemctl restart nexuscos-app
```

---

**Nexus COS** - Complete OTT/Streaming TV Platform | Deploy in minutes! 🚀

© 2025 Nexus COS. All rights reserved.
