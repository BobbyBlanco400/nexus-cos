# NEXUS COS VPS Deployment Guide

This guide provides complete instructions for deploying Nexus COS to a VPS server.

## Prerequisites

- Ubuntu 20.04+ or Debian 11+ VPS
- Root access to the server
- Domain name pointed to your VPS IP (for SSL)
- At least 2GB RAM and 20GB storage

## Quick Deployment

### Step 1: Prepare Your VPS

1. **Connect to your VPS:**
   ```bash
   ssh root@your-vps-ip
   ```

2. **Upload the deployment script:**
   ```bash
   # Option A: Download directly (if hosted)
   wget https://your-domain.com/vps_deployment_script.sh
   
   # Option B: Copy from local machine
   scp vps_deployment_script.sh root@your-vps-ip:/root/
   ```

3. **Make executable and run:**
   ```bash
   chmod +x vps_deployment_script.sh
   ./vps_deployment_script.sh
   ```

### Step 2: Deploy Your Application

1. **Clone your repository:**
   ```bash
   sudo -u nexus git clone https://github.com/your-username/nexus-cos.git /opt/nexus-cos
   ```

2. **Run the deployment script:**
   ```bash
   /opt/deploy-nexus.sh
   ```

3. **Configure nginx:**
   ```bash
   sudo cp /opt/nexus-cos/deployment/nginx/nexuscos.online.conf /etc/nginx/sites-available/
   sudo ln -sf /etc/nginx/sites-available/nexuscos.online.conf /etc/nginx/sites-enabled/
   sudo nginx -t && sudo systemctl reload nginx
   ```

### Step 3: Setup SSL (After DNS Configuration)

1. **Ensure your domain points to the VPS IP**
2. **Run SSL setup:**
   ```bash
   /opt/setup-ssl.sh
   ```

## What Gets Installed

### System Dependencies
- **Node.js 22.x** - Latest LTS version
- **Python 3.12** - Latest Python with virtual environment support
- **pnpm** - Fast package manager for Node.js
- **nginx** - Web server and reverse proxy
- **certbot** - SSL certificate management
- **PM2** - Process manager for Node.js applications
- **Build tools** - gcc, g++, make for native dependencies

### Application Structure
```
/opt/nexus-cos/           # Main application directory
├── backend/              # Node.js + Python backends
├── frontend/             # React frontend
├── mobile/               # Mobile app source
└── deployment/           # Deployment configurations

/var/www/nexus-cos/       # Web-served frontend files

/etc/nginx/sites-available/nexuscos.online.conf  # Nginx configuration
```

### Services Created
- **nexus-node-backend** - Node.js/TypeScript backend (port 3000)
- **nexus-python-backend** - Python/FastAPI backend (port 3001)

## Service Management

### Check Service Status
```bash
sudo systemctl status nexus-node-backend
sudo systemctl status nexus-python-backend
```

### View Logs
```bash
# Node.js backend logs
sudo journalctl -u nexus-node-backend -f

# Python backend logs
sudo journalctl -u nexus-python-backend -f

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Restart Services
```bash
sudo systemctl restart nexus-node-backend
sudo systemctl restart nexus-python-backend
sudo systemctl reload nginx
```

## Application URLs

After successful deployment:

- **Frontend:** https://nexuscos.online
- **Node.js API:** https://nexuscos.online/api/
- **Python API:** https://nexuscos.online/py/
- **Health Checks:**
  - Node.js: https://nexuscos.online/health
  - Python: https://nexuscos.online/py/health

## Troubleshooting

### Common Issues

1. **Services won't start:**
   ```bash
   # Check logs for errors
   sudo journalctl -u nexus-node-backend --no-pager
   sudo journalctl -u nexus-python-backend --no-pager
   ```

2. **Frontend not loading:**
   ```bash
   # Check nginx configuration
   sudo nginx -t
   
   # Verify files exist
   ls -la /var/www/nexus-cos/
   ```

3. **SSL certificate issues:**
   ```bash
   # Check certificate status
   sudo certbot certificates
   
   # Renew if needed
   sudo certbot renew
   ```

4. **Port conflicts:**
   ```bash
   # Check what's using ports
   sudo netstat -tulpn | grep :3000
   sudo netstat -tulpn | grep :3001
   ```

### Performance Monitoring

```bash
# System resources
htop
df -h
free -h

# Application performance
pm2 monit  # If using PM2
sudo systemctl status nexus-*
```

## Security Considerations

### Firewall Configuration
The script automatically configures UFW with these rules:
- SSH (port 22)
- HTTP/HTTPS (ports 80/443)
- Application ports (3000, 3001) - Consider restricting to localhost only

### Additional Security Steps

1. **Change default SSH port:**
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Change Port 22 to Port 2222
   sudo systemctl restart ssh
   ```

2. **Setup fail2ban:**
   ```bash
   sudo apt install fail2ban
   sudo systemctl enable fail2ban
   ```

3. **Regular updates:**
   ```bash
   sudo apt update && sudo apt upgrade
   ```

## Backup Strategy

### Application Backup
```bash
#!/bin/bash
# Create backup script
BACKUP_DIR="/backup/nexus-cos-$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Backup application
tar -czf $BACKUP_DIR/app.tar.gz /opt/nexus-cos

# Backup web files
tar -czf $BACKUP_DIR/web.tar.gz /var/www/nexus-cos

# Backup nginx config
cp /etc/nginx/sites-available/nexuscos.online.conf $BACKUP_DIR/

# Backup SSL certificates
cp -r /etc/letsencrypt $BACKUP_DIR/
```

## Updating the Application

1. **Pull latest changes:**
   ```bash
   cd /opt/nexus-cos
   sudo -u nexus git pull
   ```

2. **Redeploy:**
   ```bash
   /opt/deploy-nexus.sh
   ```

## Support

For issues or questions:
1. Check the logs first
2. Verify all services are running
3. Test individual components
4. Review nginx configuration

---

**Note:** Replace `nexuscos.online` with your actual domain name throughout the configuration files.