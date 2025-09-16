# Nexus COS VPS Deployment Guide

This guide provides complete instructions for deploying Nexus COS on an IONOS VPS with the new domain and server configuration.

## Prerequisites

- IONOS VPS with Ubuntu 22.04 LTS
- Domain name configured and pointing to your VPS IP
- Root access to the VPS
- Basic knowledge of Linux server administration

## Deployment Overview

The application consists of:
- **Frontend**: React application built with Vite
- **Backend**: FastAPI application with Python 3.12
- **Database**: PostgreSQL
- **Web Server**: Nginx with SSL/TLS (Let's Encrypt)
- **Process Manager**: systemd

## Quick Deployment

### Option 1: Automated Deployment Script

1. **Clone the repository on your VPS:**
   ```bash
   git clone https://github.com/BobbyBlanco400/nexus-cos.git
   cd nexus-cos
   ```

2. **Update configuration:**
   ```bash
   # Edit the deployment script
   nano deploy_nexus_cos_vps.sh
   
   # Update these variables:
   DOMAIN="your-actual-domain.com"
   DB_USER="nexus_user"
   # Update other configuration as needed
   ```

3. **Run the deployment script:**
   ```bash
   chmod +x deploy_nexus_cos_vps.sh
   sudo ./deploy_nexus_cos_vps.sh
   ```

### Option 2: Manual Deployment

If you prefer manual control or need to troubleshoot, follow these steps:

#### 1. System Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y curl wget git build-essential
```

#### 2. Install Node.js 22

```bash
# Add Node.js repository
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

# Install Node.js
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should show v22.x.x
npm --version
```

#### 3. Install Python 3.12 and Poetry

```bash
# Install Python 3.12
sudo apt install -y python3.12 python3.12-venv python3-pip python3.12-dev

# Install Poetry
curl -sSL https://install.python-poetry.org | python3 -
export PATH="/root/.local/bin:$PATH"
echo 'export PATH="/root/.local/bin:$PATH"' >> ~/.bashrc
```

#### 4. Install and Configure PostgreSQL

```bash
# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Start and enable PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database and user
sudo -u postgres psql -c "CREATE DATABASE nexus_cos_db;"
sudo -u postgres psql -c "CREATE USER nexus_user WITH PASSWORD 'your_secure_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE nexus_cos_db TO nexus_user;"
```

#### 5. Deploy Application

```bash
# Create application directory
sudo mkdir -p /var/www/nexus-cos
cd /var/www/nexus-cos

# Clone repository
sudo git clone https://github.com/BobbyBlanco400/nexus-cos.git .

# Create environment file
sudo cp backend/.env.example backend/.env
sudo nano backend/.env  # Update with your configuration

# Install and build frontend
cd frontend
sudo npm ci --only=production
sudo npm run build
cd ..

# Install backend dependencies
cd backend
sudo python3.12 -m venv venv
sudo venv/bin/pip install --upgrade pip poetry
sudo venv/bin/poetry install --no-root --only=main

# Run database migrations
sudo venv/bin/alembic upgrade head
cd ..

# Set permissions
sudo chown -R www-data:www-data /var/www/nexus-cos
sudo chmod -R 755 /var/www/nexus-cos
```

#### 6. Configure systemd Service

```bash
# Copy service file
sudo cp config/nexus-cos-backend.service /etc/systemd/system/

# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable nexus-cos-backend
sudo systemctl start nexus-cos-backend

# Check service status
sudo systemctl status nexus-cos-backend
```

#### 7. Configure Nginx

```bash
# Install Nginx
sudo apt install -y nginx

# Copy configuration
sudo cp config/nginx-nexus-cos.conf /etc/nginx/sites-available/nexus-cos

# Update domain in configuration
sudo sed -i 's/your-domain.com/your-actual-domain.com/g' /etc/nginx/sites-available/nexus-cos

# Enable site
sudo ln -sf /etc/nginx/sites-available/nexus-cos /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
sudo nginx -t
sudo systemctl reload nginx
sudo systemctl enable nginx
```

#### 8. Install SSL Certificate

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Set up auto-renewal
sudo systemctl enable certbot.timer
```

#### 9. Configure Firewall

```bash
# Enable firewall
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw reload
```

## Configuration Files

### Backend Environment (.env)

```bash
DATABASE_URL=postgresql://nexus_user:your_secure_password@localhost/nexus_cos_db
ENVIRONMENT=production
DEBUG=false
SECRET_KEY=your_very_secure_secret_key
ALLOWED_HOSTS=your-domain.com,www.your-domain.com
CORS_ALLOWED_ORIGINS=https://your-domain.com,https://www.your-domain.com
```

### Database Configuration

The application uses PostgreSQL with Alembic for migrations. The database schema is managed through migrations in the `backend/migrations/` directory.

## Testing the Deployment

### 1. Backend API Test

```bash
# Test backend directly
curl -f https://your-domain.com/api/

# Should return: {"message":"PUABO Backend API Phase 3 is live"}
```

### 2. Frontend Test

Visit `https://your-domain.com` in your browser. You should see the React application loading.

### 3. Service Status Check

```bash
# Check all services
sudo systemctl status nexus-cos-backend
sudo systemctl status nginx
sudo systemctl status postgresql

# Check logs if there are issues
sudo journalctl -u nexus-cos-backend -f
sudo tail -f /var/log/nginx/error.log
```

## Maintenance and Updates

### Updating the Application

```bash
cd /var/www/nexus-cos

# Pull latest changes
sudo git pull origin main

# Update frontend
cd frontend
sudo npm ci --only=production
sudo npm run build
cd ..

# Update backend dependencies if needed
cd backend
sudo venv/bin/poetry install --no-root --only=main

# Run any new migrations
sudo venv/bin/alembic upgrade head
cd ..

# Restart services
sudo systemctl restart nexus-cos-backend
sudo systemctl reload nginx
```

### Monitoring

```bash
# Check service status
sudo systemctl status nexus-cos-backend nginx postgresql

# Check logs
sudo journalctl -u nexus-cos-backend --since "1 hour ago"
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Check disk space
df -h

# Check memory usage
free -h

# Check process status
ps aux | grep uvicorn
```

### Backup

```bash
# Database backup
sudo -u postgres pg_dump nexus_cos_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Application backup
sudo tar -czf nexus-cos-backup-$(date +%Y%m%d_%H%M%S).tar.gz /var/www/nexus-cos
```

## Troubleshooting

### Common Issues

1. **503 Service Unavailable**
   - Check backend service: `sudo systemctl status nexus-cos-backend`
   - Check logs: `sudo journalctl -u nexus-cos-backend -f`

2. **Database Connection Issues**
   - Check PostgreSQL: `sudo systemctl status postgresql`
   - Verify database credentials in `.env` file
   - Test connection: `sudo -u postgres psql -c "\\l"`

3. **SSL Certificate Issues**
   - Renew certificate: `sudo certbot renew`
   - Check certificate status: `sudo certbot certificates`

4. **Frontend Not Loading**
   - Check Nginx configuration: `sudo nginx -t`
   - Verify build files exist: `ls -la /var/www/nexus-cos/frontend/dist/`

5. **Permission Issues**
   - Fix ownership: `sudo chown -R www-data:www-data /var/www/nexus-cos`
   - Fix permissions: `sudo chmod -R 755 /var/www/nexus-cos`

### Performance Optimization

1. **Enable Gzip Compression** (already configured in Nginx)
2. **Configure Caching** (already configured for static assets)
3. **Monitor Resource Usage**
   ```bash
   # Install monitoring tools
   sudo apt install -y htop iotop
   
   # Monitor resources
   htop
   sudo iotop
   ```

## Security Considerations

1. **Keep System Updated**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Regular Security Audits**
   ```bash
   # Check for security updates
   sudo unattended-upgrades --dry-run
   
   # Check open ports
   sudo netstat -tulpn
   
   # Check firewall status
   sudo ufw status
   ```

3. **Log Monitoring**
   - Monitor `/var/log/nginx/` for suspicious access patterns
   - Monitor system logs: `sudo journalctl --since "1 day ago"`

## GitHub Actions Integration

The GitHub Actions workflow is configured to:
- Build the frontend and backend
- Run tests
- Prepare deployment artifacts
- Provide deployment instructions

The workflow triggers on:
- Push to `main` branch
- Manual trigger via `workflow_dispatch`

## Support

For issues or questions:
1. Check the logs as described in the troubleshooting section
2. Review the GitHub repository issues
3. Check the application documentation

## Final Checklist

- [ ] Domain DNS pointing to VPS IP
- [ ] SSL certificate installed and working
- [ ] Backend API responding at `/api/`
- [ ] Frontend loading correctly
- [ ] Database migrations applied
- [ ] Services auto-starting on reboot
- [ ] Firewall configured
- [ ] Monitoring set up
- [ ] Backup strategy implemented

Your Nexus COS application should now be fully deployed and accessible at `https://your-domain.com`!