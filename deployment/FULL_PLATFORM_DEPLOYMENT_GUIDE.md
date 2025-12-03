# Nexus COS Full Platform Deployment Guide

## Overview
This guide provides step-by-step instructions for deploying the complete Nexus COS platform (51 services) on a VPS server with Plesk.

**Platform Stack:**
- 38 existing core services
- 13 new content creation modules
- Total: **51 containerized services**

---

## Prerequisites

### Server Requirements
- **OS**: Ubuntu 20.04+ or Debian 11+
- **RAM**: Minimum 16GB (32GB recommended)
- **CPU**: Minimum 8 cores (16 cores recommended)
- **Disk**: Minimum 100GB SSD
- **Panel**: Plesk Obsidian
- **Root Access**: Required

### Required Software
- Node.js 18+ & npm
- PM2 process manager
- Docker & Docker Compose
- Nginx (managed by Plesk)
- Git

---

## Deployment Process

### Phase 1: Pre-Deployment Preparation

#### 1.1 Connect to Server
```bash
ssh root@your-server-ip
```

#### 1.2 Verify System Requirements
```bash
# Check available memory
free -h

# Check CPU cores
nproc

# Check disk space
df -h

# Verify required packages
which node npm pm2 docker docker-compose git nginx
```

#### 1.3 Create Backup Directory
```bash
mkdir -p /root/nexus-backups
```

---

### Phase 2: One-Command Deployment (Recommended)

#### 2.1 Run Master Deployment Script
This bulletproof script handles everything automatically:

```bash
curl -sSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/copilot/fix-proxy-configuration-errors/deployment/master-deploy.sh | sudo bash
```

**What This Script Does:**
1. ✅ Cleans up problematic nginx backup files
2. ✅ Clones/pulls latest repository code
3. ✅ Configures nginx with proxy routes for all 51 services
4. ✅ Fixes Apache/Plesk port conflicts
5. ✅ Removes obsolete PM2 services (kei-ai)
6. ✅ Restarts all stopped services
7. ✅ Tests all critical endpoints
8. ✅ Provides deployment summary

**Expected Output:**
```
[SUCCESS] ✓ Master deployment completed successfully with X warning(s)

Summary:
  Domain:           nexuscos.online
  Repository:       /opt/nexus-cos
  Branch:           copilot/fix-proxy-configuration-errors
  Backups:          /root/nexus-backups/YYYYMMDD_HHMMSS
```

#### 2.2 Verify Deployment Success
```bash
# Check PM2 services status
pm2 status

# Expected: All services showing "online"
# Total services: 51 (38 existing + 13 new)
```

---

### Phase 3: Manual Deployment (Alternative)

If you need to deploy step-by-step or troubleshoot:

#### 3.1 Clone Repository
```bash
cd /opt
git clone -b copilot/fix-proxy-configuration-errors https://github.com/BobbyBlanco400/nexus-cos.git
cd nexus-cos
```

#### 3.2 Configure Nginx
```bash
# Backup current nginx config
VHOST="/var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf"
cp "$VHOST" "$VHOST.backup.$(date +%Y%m%d_%H%M%S)"

# Apply new configuration
bash deployment/nginx/setup-nginx-proxy.sh

# Test configuration
nginx -t

# Reload nginx
systemctl reload nginx
```

#### 3.3 Configure Apache/Plesk
```bash
# Run Plesk setup script
bash deployment/apache/setup-plesk-apache.sh

# Enable required Apache modules
a2enmod proxy proxy_http proxy_wstunnel rewrite headers

# Restart Apache
systemctl restart apache2
```

#### 3.4 Deploy 13 New Content Creation Modules
```bash
# From repository root
bash scripts/deploy-new-modules.sh
```

This deploys:
1. V-Prompter Pro 10x10 (port 3060)
2. Talk Show Studio (port 3020)
3. Game Show Creator (port 3021)
4. Reality TV Producer (port 3022)
5. Documentary Suite (port 3023)
6. Cooking Show Kitchen (port 3024)
7. Home Improvement Hub (port 3025)
8. Kids Programming Studio (port 3026)
9. Music Video Director (port 3027)
10. Comedy Special Suite (port 3028)
11. Drama Series Manager (port 3029)
12. Animation Studio (port 3030)
13. Podcast Producer (port 3031)

#### 3.5 PM2 Cleanup & Management
```bash
# Remove obsolete services
pm2 delete kei-ai

# Restart any stopped services
pm2 restart all

# Save PM2 configuration
pm2 save

# Configure PM2 startup on reboot
pm2 startup
pm2 save
```

---

## Phase 4: Post-Deployment Verification

### 4.1 Service Health Checks

#### Check All PM2 Services
```bash
pm2 status
```

**Expected Output:**
- All 51 services showing status: "online"
- No services in "stopped" or "errored" state

#### Check Individual Service Health
```bash
# Test core services
curl -s https://nexuscos.online/ | head -20
curl -s https://nexuscos.online/api/health
curl -s https://nexuscos.online/socket.io/?EIO=4&transport=polling

# Test streaming WebSocket
curl -s https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling

# Test new content creation modules
curl -s http://localhost:3060/health  # V-Prompter Pro
curl -s http://localhost:3020/health  # Talk Show Studio
curl -s http://localhost:3021/health  # Game Show Creator
curl -s http://localhost:3031/health  # Podcast Producer
```

**Expected:** All should return `200 OK` or service-specific health data

### 4.2 Network Port Verification

#### Check Listening Ports
```bash
# Check critical ports
netstat -tlnp | grep -E ":(3001|3020|3026|3060)"

# Check all service ports
ss -tlnp | grep LISTEN | grep -E "300[0-9]|30[1-3][0-9]|3060"
```

**Expected Ports:**
- 3001: Backend API
- 3010: AI Service
- 3020-3031: Content creation modules
- 3026: Streaming Socket.IO

### 4.3 Nginx Configuration Verification

#### Test Nginx Config
```bash
nginx -t
```

**Expected:** 
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

#### Check Proxy Routes
```bash
# View nginx configuration
cat /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf | grep "location"
```

**Expected:** Should see location blocks for:
- `/socket.io/`
- `/streaming/socket.io/`
- `/api/health`
- `/creator`
- `/studio-ai`
- `/v-prompter`, `/talk-show`, etc. (13 modules)

---

## Phase 5: Troubleshooting

### Common Issues & Solutions

#### Issue 1: Services Showing "stopped"
```bash
# Identify stopped services
pm2 list | grep stopped

# Check logs
pm2 logs <service-name> --lines 50

# Restart specific service
pm2 restart <service-name>

# If still failing, check dependencies
cd /path/to/service
npm install
pm2 restart <service-name>
```

#### Issue 2: Port Already in Use
```bash
# Find process using port
lsof -i :PORT_NUMBER

# Kill process if needed
kill -9 PID

# Restart service
pm2 restart <service-name>
```

#### Issue 3: Nginx Proxy 404 Errors
```bash
# Check backend service is running
pm2 status | grep <service-name>

# Check port mapping in nginx config
grep -A 5 "location /<route>" /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf

# Verify backend is listening
netstat -tlnp | grep :PORT

# Reload nginx
systemctl reload nginx
```

#### Issue 4: Apache/Nginx Port Conflict
```bash
# Check what's using port 80
netstat -tlnp | grep :80

# Typically nginx should handle 80/443, Apache on 7080/7081
# Fix Apache ports if needed
vim /etc/apache2/ports.conf
# Change to: Listen 7080

# Restart services
systemctl restart apache2
systemctl restart nginx
```

#### Issue 5: WebSocket Connection Failed
```bash
# Check nginx WebSocket headers
grep -A 3 "Upgrade" /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf

# Should see:
# proxy_set_header Upgrade $http_upgrade;
# proxy_set_header Connection "upgrade";

# Test WebSocket connection
curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" \
  https://nexuscos.online/streaming/socket.io/
```

---

## Phase 6: Maintenance & Monitoring

### 6.1 Regular Monitoring

#### Daily Checks
```bash
# Check all services status
pm2 status

# Check system resources
htop
df -h
free -h

# Check nginx logs
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log
```

#### Weekly Maintenance
```bash
# Update repository
cd /opt/nexus-cos
git pull origin copilot/fix-proxy-configuration-errors

# Update dependencies (if needed)
npm install --production

# Restart services with updates
pm2 restart all

# Clean up old logs
pm2 flush
```

### 6.2 Backup Strategy

#### Create Backup
```bash
# Backup PM2 ecosystem
pm2 save

# Backup nginx configs
cp -r /var/www/vhosts/system/nexuscos.online/conf \
   /root/nexus-backups/nginx-$(date +%Y%m%d)

# Backup repository
cd /opt
tar -czf /root/nexus-backups/nexus-cos-$(date +%Y%m%d).tar.gz nexus-cos/
```

#### Restore from Backup
```bash
# Restore PM2 services
pm2 resurrect

# Restore nginx config
cp /root/nexus-backups/nginx-YYYYMMDD/vhost_nginx.conf \
   /var/www/vhosts/system/nexuscos.online/conf/
systemctl reload nginx
```

---

## Phase 7: Service Architecture

### Port Mapping Reference

| Service | Port | Type | Description |
|---------|------|------|-------------|
| Frontend | 3000 | HTTP | Main web application |
| Backend API | 3001 | HTTP | Core API endpoints |
| AI Service | 3010 | HTTP | AI/ML processing |
| Creator Hub | 3020 | HTTP | Content creator interface |
| Streaming Socket.IO | 3026 | WebSocket | Real-time streaming |
| V-Prompter Pro | 3060 | HTTP | Teleprompter system |
| Game Show Creator | 3021 | HTTP | Game show tools |
| Reality TV Producer | 3022 | HTTP | Reality TV workflow |
| Documentary Suite | 3023 | HTTP | Documentary production |
| Cooking Show Kitchen | 3024 | HTTP | Culinary content tools |
| Home Improvement Hub | 3025 | HTTP | DIY content manager |
| Kids Programming | 3026 | HTTP | Children's content |
| Music Video Director | 3027 | HTTP | Music video tools |
| Comedy Special Suite | 3028 | HTTP | Comedy production |
| Drama Series Manager | 3029 | HTTP | Drama production |
| Animation Studio | 3030 | HTTP | Animation tools |
| Podcast Producer | 3031 | HTTP | Podcast creation |

### Nginx Proxy Routes

| Route | Backend | Port | WebSocket |
|-------|---------|------|-----------|
| `/` | Frontend | 3000 | ❌ |
| `/api/` | Backend API | 3001 | ❌ |
| `/api/health` | Backend API | 3001 | ❌ |
| `/creator` | Creator Hub | 3020 | ❌ |
| `/studio-ai` | AI Service | 3010 | ❌ |
| `/socket.io/` | Streaming | 3026 | ✅ |
| `/streaming/socket.io/` | Streaming | 3026 | ✅ |
| `/v-prompter` | V-Prompter Pro | 3060 | ❌ |
| `/talk-show` | Talk Show Studio | 3020 | ❌ |
| `/game-show` | Game Show Creator | 3021 | ❌ |
| `/reality-tv` | Reality TV Producer | 3022 | ❌ |
| `/documentary` | Documentary Suite | 3023 | ❌ |
| `/cooking-show` | Cooking Show Kitchen | 3024 | ❌ |
| `/home-improvement` | Home Improvement Hub | 3025 | ❌ |
| `/kids-programming` | Kids Programming | 3026 | ❌ |
| `/music-video` | Music Video Director | 3027 | ❌ |
| `/comedy-special` | Comedy Special Suite | 3028 | ❌ |
| `/drama-series` | Drama Series Manager | 3029 | ❌ |
| `/animation` | Animation Studio | 3030 | ❌ |
| `/podcast` | Podcast Producer | 3031 | ❌ |

---

## Phase 8: Security Considerations

### 8.1 Firewall Configuration
```bash
# Allow only necessary ports
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 22/tcp    # SSH
ufw enable
```

### 8.2 SSL/TLS Setup
```bash
# If using Let's Encrypt via Plesk:
# 1. Go to Plesk → Domains → nexuscos.online → SSL/TLS Certificates
# 2. Click "Install" on Let's Encrypt
# 3. Select "Secure the domain and its www subdomain"
# 4. Enable "Redirect HTTP to HTTPS"
```

### 8.3 Environment Variables
```bash
# Store sensitive data in environment files
# Never commit .env files to git

# Example .env structure:
# NODE_ENV=production
# DATABASE_URL=...
# API_KEY=...
# JWT_SECRET=...
```

---

## Quick Reference Commands

### Essential Commands
```bash
# Deploy/Update Platform
curl -sSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/copilot/fix-proxy-configuration-errors/deployment/master-deploy.sh | sudo bash

# Check All Services
pm2 status

# Restart All Services
pm2 restart all

# View Logs
pm2 logs --lines 100

# Reload Nginx
systemctl reload nginx

# Test Nginx Config
nginx -t

# Check System Resources
htop
df -h
free -h
```

### Emergency Recovery
```bash
# Stop all services
pm2 stop all

# Restore nginx from backup
cp /root/nexus-backups/nginx-latest/vhost_nginx.conf \
   /var/www/vhosts/system/nexuscos.online/conf/

# Restore PM2
pm2 resurrect

# Start all services
pm2 start all
```

---

## Support & Documentation

### Key Documentation Files
- **Deployment Guide**: `/opt/nexus-cos/deployment/STREAMING_SOCKET_FIX_README.md`
- **Apache Setup**: `/opt/nexus-cos/deployment/apache/setup-plesk-apache.sh`
- **New Modules**: `/opt/nexus-cos/scripts/deploy-new-modules.sh`

### Log Locations
- **Nginx Access**: `/var/log/nginx/access.log`
- **Nginx Error**: `/var/log/nginx/error.log`
- **PM2 Logs**: `~/.pm2/logs/`
- **Apache**: `/var/log/apache2/`

### Getting Help
1. Check deployment summary in terminal output
2. Review logs: `pm2 logs <service-name>`
3. Check nginx error log: `tail -f /var/log/nginx/error.log`
4. Verify service is listening: `netstat -tlnp | grep :PORT`

---

## Success Criteria

✅ **Deployment is successful when:**
1. All 51 PM2 services show "online" status
2. `pm2 status` shows no "stopped" or "errored" services
3. Nginx configuration test passes: `nginx -t`
4. All health endpoints return 200 OK
5. WebSocket connections work on `/streaming/socket.io/`
6. No critical errors in nginx or PM2 logs
7. Deployment summary shows: `[SUCCESS] ✓ Master deployment completed successfully`

---

**Last Updated**: December 3, 2025  
**Version**: 1.0  
**Deployment Branch**: `copilot/fix-proxy-configuration-errors`
