# 🚀 Nexus COS Production Deployment Guide

## Overview
This document provides complete instructions for deploying the Nexus COS project to production with full automation, zero downtime, and comprehensive monitoring.

## 📋 Quick Start

### Prerequisites
- Ubuntu/Debian server (IONOS VPS)
- Root access
- Domain pointing to server IP (nexuscos.online)
- Port 22, 80, 443 accessible

### One-Command Deployment
```bash
sudo ./comprehensive-production-deploy.sh
```

## 🏗️ Architecture

### Frontend
- **Technology**: React + TypeScript + Vite
- **Location**: `/var/www/nexus-cos`
- **URL**: `https://nexuscos.online`

### Backend APIs
- **Node.js/Express**: Port 3000 → `/api/` routes
- **Python/FastAPI**: Port 3001 → `/py/` routes
- **Health Checks**: `/health` and `/py/health`

### Mobile Applications
- **Android APK**: `/mobile/builds/android/app.apk`
- **iOS IPA**: `/mobile/builds/ios/app.ipa`

## 🔧 Deployment Scripts

### Main Scripts
1. **`comprehensive-production-deploy.sh`** - Complete automated deployment
2. **`nexus-monitor.sh`** - Service monitoring and auto-recovery  
3. **`nexus-recovery.sh`** - Disaster recovery and health checks
4. **`test-deployment.sh`** - Pre-deployment validation

### Script Usage
```bash
# Test before deployment
./test-deployment.sh

# Full production deployment
sudo ./comprehensive-production-deploy.sh

# Monitor services (install monitoring)
sudo ./nexus-monitor.sh install

# Manual monitoring check
sudo ./nexus-monitor.sh monitor

# Health check
sudo ./nexus-recovery.sh health

# System status
sudo ./nexus-recovery.sh status

# Emergency restart
sudo ./nexus-recovery.sh restart

# Full recovery
sudo ./nexus-recovery.sh recover
```

## 🔒 Security Features

### SSL/TLS
- **Wildcard Certificate**: `*.nexuscos.online`
- **Auto-renewal**: Configured with certbot
- **HTTPS Redirect**: Automatic HTTP → HTTPS

### Firewall
- **UFW enabled**: SSH, HTTP, HTTPS only
- **Fail2ban**: Protection against brute force
- **Internal ports**: 3000, 3001 (localhost only)

### Process Management
- **Systemd services**: Auto-restart on failure
- **Process monitoring**: Every 2 minutes
- **Auto-recovery**: Automatic service restart

## 📊 Monitoring & Logging

### Log Files
- **Deployment**: `/var/log/nexus-deployment.log`
- **Recovery**: `/var/log/nexus-recovery-TIMESTAMP.log` 
- **Monitoring**: `/var/log/nexus-monitor.log`
- **Services**: `journalctl -u nexus-backend.service`

### Health Endpoints
- **Node.js**: `https://nexuscos.online/health`
- **Python**: `https://nexuscos.online/py/health`
- **Frontend**: `https://nexuscos.online`

### Automated Testing
- **Puppeteer**: Browser automation testing
- **Response validation**: API endpoint checks
- **SSL verification**: Certificate validation
- **Mobile responsiveness**: Multi-device testing

## 🔄 Service Management

### Systemd Services
```bash
# Node.js Backend
sudo systemctl start/stop/restart nexus-backend.service
sudo systemctl status nexus-backend.service

# Python Backend  
sudo systemctl start/stop/restart nexus-python.service
sudo systemctl status nexus-python.service

# Nginx
sudo systemctl start/stop/restart nginx
sudo systemctl status nginx
```

### Manual Service Start
```bash
# Node.js (development)
cd backend && npx ts-node src/server.ts

# Python (development)
cd backend && python3 -m uvicorn app.main:app --host 0.0.0.0 --port 3001
```

## 🌐 Deployment Steps Detail

### 1️⃣ Environment Cleanup
- Stops existing services
- Removes old systemd configurations
- Cleans deployment directories
- Purges broken installations

### 2️⃣ Dependencies Installation
- System packages (nginx, certbot, nodejs, python3)
- Node.js and npm (latest versions)
- Python packages (FastAPI, uvicorn)
- Puppeteer dependencies for testing
- Security packages (ufw, fail2ban)

### 3️⃣ Service Configuration
- Creates systemd service files
- Configures auto-restart policies
- Sets proper working directories
- Defines environment variables

### 4️⃣ Frontend Deployment
- Builds React application with Vite
- Deploys to `/var/www/nexus-cos`
- Sets proper permissions
- Configures file ownership

### 5️⃣ Backend Deployment
- Installs Node.js dependencies
- Starts Node.js service (port 3000)
- Starts Python service (port 3001)
- Validates service startup

### 6️⃣ Mobile Build Deployment
- Generates APK/IPA builds
- Deploys to web-accessible location
- Makes builds downloadable via HTTPS

### 7️⃣ Testing & Validation
- Sets up Puppeteer testing
- Validates all endpoints
- Tests SSL configuration
- Performs responsiveness checks
- Generates deployment report

## 🛠️ Troubleshooting

### Common Issues

**Services not starting:**
```bash
sudo ./nexus-recovery.sh status
sudo journalctl -u nexus-backend.service -f
sudo journalctl -u nexus-python.service -f
```

**SSL issues:**
```bash
sudo certbot certificates
sudo certbot renew --dry-run
```

**Permission issues:**
```bash
sudo chown -R www-data:www-data /var/www/nexus-cos
sudo chmod -R 755 /var/www/nexus-cos
```

**Port conflicts:**
```bash
sudo netstat -tulpn | grep :3000
sudo netstat -tulpn | grep :3001
```

### Recovery Procedures

**Quick restart:**
```bash
sudo ./nexus-recovery.sh restart
```

**Full recovery:**
```bash
sudo ./nexus-recovery.sh recover
```

**Manual recovery:**
```bash
sudo systemctl stop nexus-backend nexus-python nginx
sudo ./comprehensive-production-deploy.sh
```

## 📈 Performance Optimization

### Nginx Configuration
- HTTP/2 enabled
- Gzip compression
- Security headers
- SSL optimization
- Proxy optimization

### Service Configuration
- Auto-restart policies
- Resource limits
- Environment optimization
- Log management

## 🔮 Future Enhancements

### Planned Features
- Real Expo mobile builds
- Database integration
- Load balancing
- Container deployment
- CI/CD integration
- Advanced monitoring dashboard

### Upgrade Path
1. Add database services
2. Implement container orchestration
3. Add load balancer
4. Integrate monitoring dashboard
5. Implement backup strategies

## 📞 Support

### Emergency Commands
```bash
# Full system status
sudo ./nexus-recovery.sh status

# Emergency restart all services
sudo ./nexus-recovery.sh restart

# Complete health check
sudo ./nexus-recovery.sh health

# Backup current state
sudo ./nexus-recovery.sh backup
```

### Log Analysis
```bash
# Recent deployment logs
tail -f /var/log/nexus-deployment.log

# Service errors
sudo journalctl -u nexus-backend.service --since "1 hour ago"
sudo journalctl -u nexus-python.service --since "1 hour ago"

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## ✅ Deployment Checklist

- [ ] Server access confirmed
- [ ] Domain DNS configured
- [ ] Firewall ports open (22, 80, 443)
- [ ] Run pre-deployment test: `./test-deployment.sh`
- [ ] Execute deployment: `sudo ./comprehensive-production-deploy.sh`
- [ ] Verify health endpoints
- [ ] Test SSL certificate
- [ ] Confirm mobile builds
- [ ] Install monitoring: `sudo ./nexus-monitor.sh install`
- [ ] Verify auto-recovery: `sudo ./nexus-recovery.sh health`
- [ ] Document deployment details
- [ ] Backup deployment state

---

**Deployment Complete!** 🎉

Your Nexus COS application is now live at: **https://nexuscos.online**