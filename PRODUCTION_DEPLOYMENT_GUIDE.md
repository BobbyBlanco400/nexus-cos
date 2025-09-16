# Nexus COS Production Deployment Guide

## Overview
This document provides complete instructions for automated production deployment and recovery of the Nexus COS platform on nexuscos.online VPS.

## Quick Recovery (Emergency)
If the site is returning 500 errors, run this single command:
```bash
cd /path/to/nexus-cos && sudo ./production-deploy.sh
```

## Deployment Scripts

### 1. `production-deploy.sh` - Full Production Deployment
**Purpose**: Complete automated deployment with zero manual intervention
**Features**:
- Installs all system dependencies (nginx, certbot, nodejs, python3)
- Sets up both Node.js and Python backends
- Builds and deploys frontend assets
- Configures SSL certificates via Let's Encrypt
- Sets up process management (PM2)
- Configures reverse proxy
- Validates all services

**Usage**:
```bash
sudo ./production-deploy.sh
```

### 2. `diagnosis.sh` - Production Environment Diagnosis  
**Purpose**: Diagnose current production issues and status
**Features**:
- Checks all service statuses
- Analyzes logs for errors
- Validates SSL certificates
- Tests health endpoints
- Provides actionable recommendations

**Usage**:
```bash
./diagnosis.sh
```

### 3. `deployment/deploy-complete.sh` - Development/Testing Deploy
**Purpose**: Local development deployment and testing
**Features**:
- Sets up development environment
- Tests both backends
- Builds mobile apps
- Validates health endpoints

## Service Architecture

### Backend Services
1. **Node.js/Express Backend (Port 3000)**
   - TypeScript with ts-node runtime
   - Health endpoint: `/health`
   - API endpoints: `/api/*`
   - Authentication routes: `/api/auth/*`

2. **Python/FastAPI Backend (Port 3001)**
   - FastAPI with Uvicorn server
   - Health endpoint: `/health`
   - API endpoints: `/py/*`

### Frontend
- **React + TypeScript + Vite**
- Built to: `frontend/dist/`
- Deployed to: `/var/www/nexus-cos`
- Mobile-responsive design

### Web Server
- **Nginx** reverse proxy and static file server
- Domains: `nexuscos.online`, `www.nexuscos.online`
- SSL/TLS via Let's Encrypt certificates
- Automatic HTTP to HTTPS redirect

## Process Management

### PM2 Configuration
```javascript
// ecosystem.config.js
{
  "nexus-backend": "ts-node src/server.ts",
  "nexus-python": "uvicorn app.main:app --host 0.0.0.0 --port 3001"
}
```

**Commands**:
```bash
pm2 start ecosystem.config.js  # Start all services
pm2 status                     # Check status
pm2 logs                      # View logs
pm2 restart all               # Restart services
pm2 stop all                  # Stop services
```

### Systemd Services (Alternative)
Located in `deployment/systemd/`:
- `nexus-backend.service` - Node.js backend
- `nexus-python.service` - Python backend

**Commands**:
```bash
sudo systemctl start nexus-backend nexus-python
sudo systemctl status nexus-backend nexus-python
sudo journalctl -f -u nexus-backend
```

## SSL Certificate Management

### Automatic Setup
```bash
sudo certbot --nginx -d nexuscos.online -d www.nexuscos.online
```

### Manual Renewal
```bash
sudo certbot renew
sudo systemctl reload nginx
```

### Auto-renewal Setup
```bash
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
```

## Health Endpoints

### Local Testing
```bash
curl http://localhost:3000/health  # Node.js backend
curl http://localhost:3001/health  # Python backend
```

### Production Testing
```bash
curl https://nexuscos.online/health     # Node.js via nginx
curl https://nexuscos.online/py/health  # Python via nginx
```

Expected response: `{"status":"ok"}`

## Troubleshooting

### Common Issues

#### 1. 500 Internal Server Error
**Cause**: Backend services not running
**Solution**: 
```bash
./diagnosis.sh              # Check what's wrong
sudo ./production-deploy.sh  # Full recovery
```

#### 2. SSL Certificate Issues
**Cause**: Certificates expired or missing
**Solution**:
```bash
sudo certbot renew
sudo systemctl reload nginx
```

#### 3. Permission Errors
**Cause**: Wrong file ownership
**Solution**:
```bash
sudo chown -R www-data:www-data /var/www/nexus-cos
sudo chmod -R 755 /var/www/nexus-cos
```

#### 4. Port Already in Use
**Cause**: Previous processes still running
**Solution**:
```bash
pm2 kill                    # Stop all PM2 processes
sudo killall node python3   # Kill remaining processes
```

### Log Locations
- **Nginx Access**: `/var/log/nginx/access.log`
- **Nginx Error**: `/var/log/nginx/error.log`
- **PM2 Logs**: `pm2 logs` or `/var/log/pm2/`
- **System Logs**: `sudo journalctl -f`
- **Deployment Log**: `/tmp/nexus-deployment.log`

### Service Status Commands
```bash
# System services
sudo systemctl status nginx
sudo systemctl status nexus-backend
sudo systemctl status nexus-python

# Process management
pm2 status
pm2 monit

# Port usage
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443
sudo netstat -tulpn | grep :3000
sudo netstat -tulpn | grep :3001
```

## Directory Structure
```
nexus-cos/
├── production-deploy.sh       # Main deployment script
├── diagnosis.sh              # Diagnostic script
├── backend/
│   ├── src/server.ts         # Node.js backend
│   ├── app/main.py           # Python backend
│   └── .venv/                # Python virtual environment
├── frontend/
│   ├── dist/                 # Built frontend assets
│   └── src/                  # React source code
├── deployment/
│   ├── nginx/
│   │   ├── nexuscos.online.conf     # HTTPS nginx config
│   │   └── nexuscos-http.conf       # HTTP fallback config
│   └── systemd/
│       ├── nexus-backend.service    # Node.js systemd service
│       └── nexus-python.service     # Python systemd service
└── ecosystem.config.js       # PM2 configuration
```

## Security Considerations

### Firewall Rules
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

### File Permissions
- Frontend assets: `755` (www-data:www-data)
- Backend code: `755` (current user)
- SSL certificates: `600` (root:root)

### Environment Variables
Store sensitive data in:
- `/etc/environment` (system-wide)
- `backend/.env` (application-specific)

## Monitoring and Maintenance

### Daily Checks
```bash
./diagnosis.sh              # Health check
pm2 status                 # Process status
sudo certbot certificates  # SSL status
```

### Weekly Tasks
```bash
sudo apt update && sudo apt upgrade  # System updates
pm2 restart all                     # Service restart
sudo systemctl reload nginx         # Nginx reload
```

### Monthly Tasks
```bash
sudo certbot renew          # SSL renewal check
pm2 flush                   # Clear PM2 logs
sudo logrotate -f /etc/logrotate.conf  # Rotate logs
```

## Performance Optimization

### Nginx Tuning
- Enable gzip compression ✅
- Set proper cache headers ✅
- Use HTTP/2 ✅
- Optimize worker processes

### PM2 Clustering
```javascript
{
  instances: "max",          // Use all CPU cores
  exec_mode: "cluster"       // Cluster mode
}
```

### Database Optimization
- Connection pooling
- Query optimization
- Index optimization
- Regular backups

## Backup Strategy

### Code Backup
```bash
git push origin main  # Code repository backup
```

### Database Backup
```bash
# MongoDB
mongodump --out /backup/$(date +%Y%m%d)

# MySQL
mysqldump database > /backup/db_$(date +%Y%m%d).sql
```

### SSL Certificate Backup
```bash
sudo cp -r /etc/letsencrypt /backup/ssl_$(date +%Y%m%d)
```

## Support and Contacts

- **Repository**: https://github.com/BobbyBlanco400/nexus-cos
- **Domain**: https://nexuscos.online
- **Emergency Contact**: Run `./diagnosis.sh` and `./production-deploy.sh`

---

*Last updated: $(date)*
*Version: 1.0.0*