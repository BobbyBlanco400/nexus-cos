# 🚨 NEXUS COS PRODUCTION RECOVERY SOLUTION

## 🔥 EMERGENCY RECOVERY (500 Error Fix)

If nexuscos.online is returning **500 Internal Server Error**, run this **ONE COMMAND** for automatic recovery:

```bash
cd /path/to/nexus-cos && sudo ./production-deploy.sh
```

## 📋 COMPLETE AUTOMATED SOLUTION

This repository now includes a **fully automated production deployment and recovery system** that requires **NO MANUAL INTERVENTION**.

### 🛠️ Deployment Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `production-deploy.sh` | **Full production deployment** | `sudo ./production-deploy.sh` |
| `diagnosis.sh` | **Production diagnostics** | `./diagnosis.sh` |
| `test-deploy.sh` | **Local testing** | `./test-deploy.sh` |

### 🎯 What the Production Script Does

✅ **System Setup**
- Installs nginx, certbot, nodejs, npm, python3
- Configures PM2 process manager
- Sets up SSL certificates via Let's Encrypt

✅ **Backend Deployment**  
- Node.js/Express backend (TypeScript) on port 3000
- Python/FastAPI backend on port 3001
- Health endpoints: `/health` returning `{"status":"ok"}`
- Process management with PM2 or systemd

✅ **Frontend Deployment**
- Builds React + TypeScript + Vite frontend
- Deploys to `/var/www/nexus-cos`
- Sets proper permissions (www-data:www-data)

✅ **Web Server Configuration**
- Nginx reverse proxy configuration
- HTTPS with automatic SSL certificate setup
- HTTP to HTTPS redirect
- Static file serving with caching

✅ **Health Validation**
- Tests all backend endpoints
- Validates SSL certificates
- Confirms web UI accessibility
- Generates detailed deployment report

### 🌐 Production Architecture

```
Internet → Nginx (Port 80/443) → Backend Services
                ↓
        /var/www/nexus-cos (Frontend)
                ↓
    ┌─ Node.js (Port 3000) ← /api/* & /health
    └─ Python (Port 3001) ← /py/* & /py/health
```

### 📊 Service Endpoints

- **Website**: https://nexuscos.online
- **Node.js Health**: https://nexuscos.online/health  
- **Python Health**: https://nexuscos.online/py/health
- **Node.js API**: https://nexuscos.online/api/*
- **Python API**: https://nexuscos.online/py/*

### 🔧 Process Management

**PM2 Commands:**
```bash
pm2 status          # Check service status
pm2 logs            # View all logs
pm2 restart all     # Restart services
pm2 stop all        # Stop services
pm2 monit           # Real-time monitoring
```

**Systemd Commands:**
```bash
sudo systemctl status nexus-backend nexus-python
sudo journalctl -f -u nexus-backend
sudo systemctl restart nexus-backend nexus-python
```

### 🔒 SSL Certificate Management

**Automatic Setup:** ✅ Handled by production script  
**Auto-Renewal:** ✅ Configured via cron  
**Manual Renewal:**
```bash
sudo certbot renew
sudo systemctl reload nginx
```

### 📝 Comprehensive Documentation

- **[PRODUCTION_DEPLOYMENT_GUIDE.md](PRODUCTION_DEPLOYMENT_GUIDE.md)** - Complete deployment guide
- **Nginx Configs**: `deployment/nginx/`
- **Systemd Services**: `deployment/systemd/`
- **PM2 Config**: `ecosystem.config.js`

### 🧪 Testing and Validation

**Local Testing:**
```bash
./test-deploy.sh    # Test all components locally
```

**Production Diagnosis:**
```bash
./diagnosis.sh      # Check production status and issues
```

### 🚀 Deployment Process

1. **Transfer code to server:**
   ```bash
   rsync -av . user@nexuscos.online:/var/www/nexus-cos-source/
   ```

2. **Run automated deployment:**
   ```bash
   cd /var/www/nexus-cos-source
   sudo ./production-deploy.sh
   ```

3. **Verify deployment:**
   ```bash
   ./diagnosis.sh
   ```

### 🆘 Troubleshooting

**Common Issues & Solutions:**

| Issue | Solution |
|-------|----------|
| 500 Error | `sudo ./production-deploy.sh` |
| SSL Problems | `sudo certbot renew && sudo systemctl reload nginx` |
| Service Down | `pm2 restart all` |
| Permission Errors | `sudo chown -R www-data:www-data /var/www/nexus-cos` |

**Log Locations:**
- Deployment: `/tmp/nexus-deployment.log`
- Nginx: `/var/log/nginx/error.log`
- PM2: `pm2 logs`
- System: `sudo journalctl -f`

### ✅ SUCCESS CRITERIA

After running `production-deploy.sh`, you should have:

- ✅ https://nexuscos.online fully accessible  
- ✅ No 500 errors
- ✅ SSL certificate working
- ✅ Both backend health endpoints responding
- ✅ Frontend UI fully functional
- ✅ All services auto-restarting on failure

---

## 🎉 MISSION ACCOMPLISHED

**The Nexus COS platform is now fully automated for production deployment with zero manual intervention required!**

**Emergency Recovery**: One command fixes everything  
**Health Monitoring**: Comprehensive diagnostics  
**Documentation**: Complete deployment guide  
**Process Management**: Robust service handling  
**SSL/Security**: Automatic certificate management  

🚀 **Ready for production deployment on nexuscos.online VPS!**