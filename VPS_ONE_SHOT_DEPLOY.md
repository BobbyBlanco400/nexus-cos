# 🚀 Nexus COS - One-Shot VPS Deployment

**Deploy the entire Nexus COS OTT/Streaming Platform with ONE command!**

---

## ⚡ THE ONE-LINER

Copy and paste this single command to deploy Nexus COS on your VPS:

```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash
```

**That's literally it!** ☝️ This single command deploys your entire OTT/Streaming TV platform.

---

## 🎯 What Gets Deployed

When you run the one-liner, you get a complete **Nexus COS OTT/Streaming TV Platform** including:

### 📺 Core Platform
- **Frontend Application** - React-based streaming interface
- **Live TV Channels** - IPTV/OTT channel grid
- **On-Demand Content** - Video content library
- **Platform Dashboard** - Real-time statistics and metrics

### 🎪 Integrated Modules
- **Club Saditty** - Entertainment venue module
- **Creator Hub** - Content creation dashboard
- **V-Suite** - Business productivity tools
- **PuaboVerse** - Virtual world platform
- **V-Screen Hollywood** - Premium content module
- **Analytics** - Platform analytics and reporting

### 🔧 Infrastructure
- **Backend API** - Node.js + Python services
- **PostgreSQL Database** - Data persistence
- **Redis Cache** - Performance optimization
- **Nginx Reverse Proxy** - Load balancing + SSL/TLS
- **Health Monitoring** - Service health checks
- **Systemd Services** - Auto-restart and management

---

## 📋 Prerequisites

Before running the one-liner, ensure your VPS has:

### Minimum Requirements
- ✅ **OS**: Ubuntu 20.04+ or Debian 10+
- ✅ **RAM**: 4GB minimum (8GB recommended)
- ✅ **Disk**: 10GB free space minimum
- ✅ **CPU**: 2 cores minimum (4 cores recommended)
- ✅ **Access**: Root or sudo privileges
- ✅ **Network**: Internet connectivity + open ports (80, 443)

### What Gets Installed Automatically
The script automatically installs these if missing:
- nginx
- nodejs (v20.x)
- npm
- python3 (3.10+)
- python3-pip
- git
- curl
- systemctl
- PostgreSQL client tools

---

## 🚀 Quick Start Guide

### Step 1: Connect to Your VPS

```bash
ssh root@YOUR_VPS_IP
# Or if using a non-root user:
ssh your_user@YOUR_VPS_IP
```

### Step 2: Run the One-Liner

```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash
```

### Step 3: Wait for Completion

The deployment takes approximately **5-10 minutes** depending on your VPS specs and network speed.

You'll see progress through 12 deployment phases:
1. ✈️ Pre-flight Checks
2. 🔄 File Synchronization
3. ✅ Configuration Validation
4. 📦 Dependency Installation
5. 🏗️ Application Builds
6. 🚀 Main Service Deployment
7. 🔧 Microservices Deployment
8. 🌐 Nginx Configuration
9. 🔍 Service Verification
10. 💚 Health Checks
11. 📋 Log Monitoring
12. ✔️ Final Validation

### Step 4: Access Your Platform

Once deployed, access your platform at:

```
https://YOUR_VPS_IP          # Main platform
https://YOUR_VPS_IP/admin    # Admin panel
https://YOUR_VPS_IP/api/     # API endpoints
https://YOUR_VPS_IP/health   # Health check
```

Or if you've configured a domain:

```
https://nexuscos.online          # Main platform
https://nexuscos.online/admin    # Admin panel
https://nexuscos.online/api/     # API endpoints
https://nexuscos.online/health   # Health check
```

---

## 🎨 Platform Features

After deployment, your Nexus COS platform includes:

### 🏠 Home Section
- Platform overview and welcome screen
- Real-time viewer statistics
- Featured content highlights
- Quick navigation to all sections

### 📺 Live TV
- Live channel grid with status indicators
- Channel categories and organization
- Real-time streaming status
- Channel guide and EPG

### 🎬 On-Demand Content
- Video content library
- Search and filtering
- Categories and playlists
- Watch progress tracking

### 🎯 Modules
- Integrated module marketplace
- One-click module activation
- Module management dashboard
- Custom module development support

### 💰 Subscription Tiers
- 📺 **Basic** - $9.99/month
- 🎬 **Premium** - $19.99/month
- 🎥 **Studio** - $49.99/month
- 🏢 **Enterprise** - $99.99/month
- 🚀 **Platform** - $199.99/month

---

## ⚙️ Advanced Options

### Custom Installation Path

```bash
export REPO_PATH="/custom/path/to/nexus-cos"
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash
```

### Local Deployment (if repo already cloned)

```bash
cd /opt/nexus-cos
sudo bash trae-solo-bulletproof-deploy.sh
```

### Custom Domain Configuration

Before deployment, set your domain:

```bash
export DOMAIN="your-domain.com"
export WWW_DOMAIN="www.your-domain.com"
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash
```

### WSL/Windows File Sync

If you're developing on Windows with WSL and want to sync files:

```bash
# Set the Windows file path
export FRONTEND_DIST_LOCAL="/mnt/c/path/to/your/frontend/dist"
sudo bash /opt/nexus-cos/trae-solo-bulletproof-deploy.sh
```

---

## 🔐 Security & SSL

The deployment automatically configures:

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
- ✅ Hidden file blocking (.git, .htaccess, .env)
- ✅ Service isolation with systemd
- ✅ Proper file permissions (755/644)
- ✅ Root-level security

### SSL Certificate Setup

For production with a real domain, add SSL certificates:

```bash
# Place your SSL certificates in:
/opt/nexus-cos/ssl/nexus-cos.crt
/opt/nexus-cos/ssl/nexus-cos.key

# Or use Let's Encrypt (recommended):
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

---

## 🔍 Verification & Testing

### Check Service Status

```bash
# Check main service
sudo systemctl status nexuscos-app

# Check all Nexus services
sudo systemctl status nexuscos-*

# View real-time logs
sudo journalctl -u nexuscos-app -f
```

### Test Endpoints

```bash
# Test main health endpoint
curl -I https://YOUR_VPS_IP/health

# Test API health
curl https://YOUR_VPS_IP/api/health

# Test specific modules
curl https://YOUR_VPS_IP/creator-hub/health
curl https://YOUR_VPS_IP/v-suite/health
```

### Check Port Status

```bash
# Check if service is listening on port 3000
ss -ltnp | grep ':3000'

# Check Nginx status
sudo systemctl status nginx

# Test Nginx configuration
sudo nginx -t
```

### View Deployment Report

```bash
# View comprehensive deployment report
cat /opt/nexus-cos/TRAE_SOLO_BULLETPROOF_DEPLOYMENT_REPORT.md

# View deployment logs
cat /opt/nexus-cos/logs/deployment-*.log

# View error logs (if any)
cat /opt/nexus-cos/logs/errors-*.log
```

---

## 📊 Platform Statistics Dashboard

After deployment, your dashboard displays:

### Real-Time Metrics
- **Active Viewers** - Current streaming users
- **Live Channels** - Number of active IPTV channels
- **Available Modules** - Total integrated modules
- **On-Demand Content** - Total video content items

### Platform Performance
- ✅ Automatic statistics updates every 3 seconds
- ✅ Real-time viewer tracking
- ✅ Channel status monitoring
- ✅ Content library sync

---

## 🛠️ Management Commands

### Service Management

```bash
# Start service
sudo systemctl start nexuscos-app

# Stop service
sudo systemctl stop nexuscos-app

# Restart service
sudo systemctl restart nexuscos-app

# Enable auto-start on boot
sudo systemctl enable nexuscos-app

# View service configuration
cat /etc/systemd/system/nexuscos-app.service
```

### Nginx Management

```bash
# Test Nginx config
sudo nginx -t

# Reload Nginx (no downtime)
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# View Nginx logs
sudo tail -f /var/log/nginx/nexus-cos.access.log
sudo tail -f /var/log/nginx/nexus-cos.error.log
```

### Database Management

```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Connect to database
sudo -u postgres psql -d nexus_cos

# View database logs
sudo journalctl -u postgresql -n 50
```

---

## 🐛 Troubleshooting

### Common Issues & Solutions

#### 1. Port Already in Use

```bash
# Check what's using port 3000
sudo ss -ltnp | grep ':3000'

# Kill the process
sudo kill -9 <PID>

# Restart service
sudo systemctl restart nexuscos-app
```

#### 2. Service Won't Start

```bash
# Check service status and errors
sudo systemctl status nexuscos-app

# View detailed logs
sudo journalctl -u nexuscos-app -n 100 --no-pager

# Check if all dependencies are met
cd /opt/nexus-cos/backend
npm list
```

#### 3. Nginx 502 Bad Gateway

```bash
# Check if backend service is running
sudo systemctl status nexuscos-app

# Check if port 3000 is accessible
curl http://localhost:3000/health

# Test Nginx configuration
sudo nginx -t

# Restart both services
sudo systemctl restart nexuscos-app
sudo systemctl reload nginx
```

#### 4. Database Connection Issues

```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Verify database exists
sudo -u postgres psql -l | grep nexus

# Check connection
sudo -u postgres psql -d nexus_cos -c "SELECT 1;"

# Review database configuration
cat /opt/nexus-cos/.env | grep DATABASE
```

#### 5. Insufficient Disk Space

```bash
# Check available space
df -h /opt/nexus-cos

# Clean up if needed
sudo apt-get clean
sudo apt-get autoremove
sudo journalctl --vacuum-time=7d

# Clear old logs
sudo rm -f /opt/nexus-cos/logs/*.log.old
```

#### 6. Permission Denied Errors

```bash
# Fix ownership
sudo chown -R www-data:www-data /var/www/nexus-cos
sudo chown -R root:root /opt/nexus-cos

# Fix permissions
sudo chmod -R 755 /var/www/nexus-cos
sudo chmod -R 755 /opt/nexus-cos

# Fix service files
sudo chmod 644 /etc/systemd/system/nexuscos-*.service
sudo systemctl daemon-reload
```

---

## 🔄 Updates & Maintenance

### Update Platform to Latest Version

```bash
# Navigate to repository
cd /opt/nexus-cos

# Pull latest changes
git pull origin main

# Re-run deployment
sudo bash trae-solo-bulletproof-deploy.sh
```

### Backup Your Platform

```bash
# Create backup directory
sudo mkdir -p /backups/nexus-cos

# Backup files
sudo tar -czf /backups/nexus-cos/nexus-cos-$(date +%Y%m%d).tar.gz /opt/nexus-cos

# Backup database
sudo -u postgres pg_dump nexus_cos > /backups/nexus-cos/nexus-cos-db-$(date +%Y%m%d).sql
```

### Restore from Backup

```bash
# Restore files
sudo tar -xzf /backups/nexus-cos/nexus-cos-YYYYMMDD.tar.gz -C /

# Restore database
sudo -u postgres psql nexus_cos < /backups/nexus-cos/nexus-cos-db-YYYYMMDD.sql

# Restart services
sudo systemctl restart nexuscos-app
sudo systemctl reload nginx
```

---

## 📈 Performance Optimization

The deployment automatically includes:

### Caching
- ✅ Static asset caching (1 year)
- ✅ Gzip compression enabled
- ✅ Redis caching for API responses
- ✅ Browser cache headers

### HTTP/2
- ✅ HTTP/2 enabled for faster loading
- ✅ SSL session caching
- ✅ Keep-alive connections

### Load Balancing
- ✅ Nginx reverse proxy
- ✅ Upstream connection pooling
- ✅ Request buffering
- ✅ Rate limiting (optional)

---

## 📚 Documentation

### Complete Documentation Set
- **[BULLETPROOF_ONE_LINER.md](BULLETPROOF_ONE_LINER.md)** - Detailed deployment guide
- **[TRAE_SOLO_DEPLOYMENT_GUIDE.md](TRAE_SOLO_DEPLOYMENT_GUIDE.md)** - TRAE Solo specifics
- **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** - Pre-launch checklist
- **[PF_README.md](PF_README.md)** - Pre-Flight deployment docs
- **[README.md](README.md)** - Main project README

### Frontend Transformation Docs
- **[docs/FRONTEND_TRANSFORMATION.md](docs/FRONTEND_TRANSFORMATION.md)** - Frontend branding changes
- Technical details about OTT/Streaming platform rebrand
- Component structure and architecture
- Before/after comparison

---

## 🎉 Success Criteria

After successful deployment, you should have:

- [x] ✅ All system requirements met
- [x] ✅ Dependencies installed and verified
- [x] ✅ Configuration validated
- [x] ✅ Frontend built and deployed
- [x] ✅ Backend services running
- [x] ✅ Database initialized
- [x] ✅ Services deployed with systemd
- [x] ✅ Nginx configured with SSL
- [x] ✅ Health checks passing
- [x] ✅ All endpoints accessible
- [x] ✅ Logs accessible and monitored
- [x] ✅ Final validation completed
- [x] ✅ Deployment report generated

### Expected Platform State
- ✅ Main frontend accessible at root URL
- ✅ Live TV section showing channel grid
- ✅ On-Demand content library available
- ✅ Modules section showing all integrated modules
- ✅ Statistics dashboard updating in real-time
- ✅ All navigation sections functional
- ✅ Subscription tiers displayed correctly
- ✅ Platform branded as "Nexus COS - OTT/Streaming Platform"

---

## 💡 Tips & Best Practices

### Before Deployment
1. ✅ Ensure VPS meets minimum requirements
2. ✅ Back up existing data (if any)
3. ✅ Check available disk space
4. ✅ Verify root/sudo access
5. ✅ Ensure ports 80 and 443 are open

### During Deployment
1. ✅ Keep terminal session active
2. ✅ Monitor output for warnings/errors
3. ✅ Don't interrupt the process
4. ✅ Note any configuration prompts
5. ✅ Wait for full completion (all 12 phases)

### After Deployment
1. ✅ Review deployment report
2. ✅ Test all endpoints in browser
3. ✅ Verify health checks pass
4. ✅ Check service logs for errors
5. ✅ Configure SSL with real certificates
6. ✅ Set up domain DNS if using custom domain
7. ✅ Clear browser cache before testing frontend
8. ✅ Monitor services for 24 hours

---

## 🆘 Getting Help

### Check Logs

```bash
# Deployment logs
cat /opt/nexus-cos/logs/deployment-*.log

# Error logs
cat /opt/nexus-cos/logs/errors-*.log

# Service logs
sudo journalctl -u nexuscos-app -n 100

# Nginx logs
sudo tail -f /var/log/nginx/nexus-cos.error.log
```

### Run Health Checks

```bash
# Quick health check
curl http://localhost:3000/health

# Full system check
cd /opt/nexus-cos
sudo bash validate-deployment-readiness.sh
```

### Community Support
- GitHub Issues: https://github.com/BobbyBlanco400/nexus-cos/issues
- Documentation: https://github.com/BobbyBlanco400/nexus-cos/tree/main/docs

---

## ⚡ Quick Reference Card

### The One-Liner (Main Command)
```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash
```

### Check Status
```bash
sudo systemctl status nexuscos-app
curl http://localhost:3000/health
```

### View Logs
```bash
sudo journalctl -u nexuscos-app -f
```

### Restart Service
```bash
sudo systemctl restart nexuscos-app
```

### Test Endpoints
```bash
curl https://YOUR_VPS_IP/health
curl https://YOUR_VPS_IP/api/health
```

---

## 📝 Changelog

### v1.0.0 (Current)
- ✅ Single command VPS deployment
- ✅ Complete OTT/Streaming platform setup
- ✅ Frontend transformation to Nexus COS branding
- ✅ Club Saditty correctly positioned as module
- ✅ All integrated modules deployed
- ✅ Automatic SSL/TLS configuration
- ✅ Health monitoring and validation
- ✅ Comprehensive error handling
- ✅ Full deployment reporting

---

## 🎬 Ready to Launch!

**Deploy your complete OTT/Streaming TV platform NOW with just one command:**

```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash
```

**That's it! Your entire Nexus COS platform will be up and running in minutes! 🚀**

---

**Nexus COS** - Complete Operating System | OTT/Streaming TV Platform with Integrated Modules

© 2025 Nexus COS. All rights reserved.
