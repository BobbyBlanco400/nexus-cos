# Nexus COS Production Deployment Guide

This guide explains how to deploy Nexus COS to production and fix the 500 Internal Server Error at nexuscos.online.

## Quick Fix for Production Server

If you have access to the production server at nexuscos.online, run this single command as root:

```bash
# Download and run the production deployment script
curl -sSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/production-deploy.sh | sudo bash
```

Or manually:

```bash
# Clone the repository
git clone https://github.com/BobbyBlanco400/nexus-cos.git /opt/nexus-cos
cd /opt/nexus-cos

# Run the deployment script
sudo ./production-deploy.sh
```

## What the Deployment Script Does

The `production-deploy.sh` script performs a complete automated deployment:

### 1. System Setup
- Updates the system packages
- Installs nginx, certbot, Node.js, npm, Python3, pip
- Installs PM2 globally for process management

### 2. Project Setup
- Clones/updates the project to `/opt/nexus-cos`
- Installs Node.js backend dependencies
- Sets up Python virtual environment and installs FastAPI/uvicorn
- Builds the React frontend with Vite

### 3. Service Configuration
- Deploys frontend assets to `/var/www/nexus-cos`
- Configures nginx with reverse proxy for both backends
- Sets up PM2 ecosystem for process management
- Configures SSL certificates with Let's Encrypt

### 4. Health Monitoring
- Creates health monitoring scripts
- Sets up cron jobs for periodic health checks
- Configures automatic service restart on failure

## Manual Troubleshooting

If the automated script fails, use the health check script:

```bash
cd /opt/nexus-cos
./health-check.sh
```

### Common Issues and Solutions

#### 1. 500 Internal Server Error
Usually caused by backend services not running.

**Check services:**
```bash
sudo systemctl status nginx
pm2 list
```

**Restart services:**
```bash
pm2 restart all
sudo systemctl restart nginx
```

#### 2. Backend Not Responding
**Node.js Backend:**
```bash
cd /opt/nexus-cos/backend
npm install
pm2 restart nexus-node-backend
pm2 logs nexus-node-backend
```

**Python Backend:**
```bash
cd /opt/nexus-cos/backend
source .venv/bin/activate
pip install fastapi uvicorn
pm2 restart nexus-python-backend
pm2 logs nexus-python-backend
```

#### 3. Frontend Not Loading
```bash
cd /opt/nexus-cos/frontend
npm install
npm run build
sudo cp -r dist/* /var/www/nexus-cos/
sudo chown -R www-data:www-data /var/www/nexus-cos
```

#### 4. SSL Certificate Issues
```bash
sudo certbot --nginx -d nexuscos.online -d www.nexuscos.online
```

#### 5. Nginx Configuration Issues
```bash
sudo nginx -t
sudo cp /opt/nexus-cos/deployment/nginx/nexuscos.online.conf /etc/nginx/sites-available/
sudo ln -sf /etc/nginx/sites-available/nexuscos.online.conf /etc/nginx/sites-enabled/
sudo systemctl reload nginx
```

## Service Architecture

### Backend Services
- **Node.js/Express**: Port 3000 - Main API backend with TypeScript
- **Python/FastAPI**: Port 3001 - Alternative backend for specific features

### Frontend
- **React + Vite**: Served from `/var/www/nexus-cos` via nginx
- **Static assets**: Cached with 1-year expiry

### Proxy Configuration
- `/` → Frontend static files
- `/health` → Node.js health endpoint
- `/api/` → Node.js API endpoints
- `/py/` → Python FastAPI endpoints
- `/py/health` → Python health endpoint

## Health Endpoints

Test these URLs to verify services:

- **Main site**: https://nexuscos.online
- **Node.js health**: https://nexuscos.online/health
- **Python health**: https://nexuscos.online/py/health

Expected health response:
```json
{"status":"ok"}
```

## Process Management

All backend services are managed by PM2:

```bash
# View all processes
pm2 list

# View logs
pm2 logs

# Restart all services
pm2 restart all

# Monitor in real-time
pm2 monit

# View specific service logs
pm2 logs nexus-node-backend
pm2 logs nexus-python-backend
```

## File Locations

- **Project**: `/opt/nexus-cos`
- **Frontend**: `/var/www/nexus-cos`
- **Nginx config**: `/etc/nginx/sites-available/nexuscos.online.conf`
- **SSL certificates**: `/etc/letsencrypt/live/nexuscos.online/`
- **Logs**: `/var/log/nginx/`, PM2 logs via `pm2 logs`
- **Health monitor log**: `/var/log/nexus-cos-monitor.log`

## Monitoring

The deployment includes automatic monitoring:

- **Health checks**: Every 5 minutes via cron
- **Auto-restart**: Failed services are automatically restarted
- **Log rotation**: System handles log file rotation
- **SSL renewal**: Automatic via certbot

View monitoring logs:
```bash
tail -f /var/log/nexus-cos-monitor.log
```

## Security Features

- **HTTPS**: Enforced via Let's Encrypt certificates
- **Security headers**: XSS protection, content-type sniffing prevention
- **File access**: Sensitive files blocked
- **Process isolation**: Services run under separate processes
- **Firewall ready**: Only necessary ports exposed

## Development vs Production

**Development** (this environment):
- Services run directly with `npm start` / `uvicorn`
- Frontend served via `npm run dev`
- No SSL, no process management

**Production** (nexuscos.online):
- Services managed by PM2
- Frontend served via nginx
- SSL certificates
- Monitoring and auto-restart
- Optimized builds

## Emergency Procedures

If the site is completely down:

1. **Quick restart everything:**
   ```bash
   sudo systemctl restart nginx
   pm2 restart all
   ```

2. **Check logs for errors:**
   ```bash
   sudo tail -f /var/log/nginx/error.log
   pm2 logs
   ```

3. **Rerun deployment:**
   ```bash
   cd /opt/nexus-cos
   sudo ./production-deploy.sh
   ```

4. **Health check:**
   ```bash
   ./health-check.sh
   ```

## Support Information

The deployment scripts generate detailed logs at:
- `/opt/nexus-cos/deployment-YYYYMMDD-HHMMSS.log`

These logs contain:
- Service status
- Configuration validation
- SSL certificate status
- URLs for testing
- Next steps and troubleshooting tips