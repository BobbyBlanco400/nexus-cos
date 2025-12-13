# Nexus COS - Complete Deployment Instructions for Trae

## Overview

This document provides step-by-step instructions for deploying the complete Nexus COS platform on your VPS. This includes all 52+ services, 43 modules, 12 family/urban platforms, license service, and Unreal/RTX enablement.

---

## Prerequisites

### Hardware Requirements
- **CPU**: 8 cores minimum (16 cores recommended)
- **RAM**: 16GB minimum (32GB recommended)
- **Storage**: 100GB SSD minimum (500GB recommended)
- **GPU** (Optional for RTX): NVIDIA RTX 3060 or better with 8GB+ VRAM

### Software Requirements
- Ubuntu 20.04 LTS or later
- Root or sudo access
- Static IP address or domain name

---

## Quick Start (One-Command Deployment)

For rapid deployment, use the automated master script:

```bash
# Download and extract the handoff package
cd /opt
unzip Nexus-COS-THIIO-FullStack.zip
cd Nexus-COS-THIIO-FullStack

# Run the master deployment script
sudo bash scripts/deploy-master.sh
```

This will:
1. Install all dependencies
2. Set up databases
3. Configure services
4. Deploy all 52+ services
5. Configure Nginx
6. Set up SSL
7. Start all services with PM2

---

## Manual Step-by-Step Deployment

### Step 1: VPS Access & Initial Setup

```bash
# SSH into your VPS
ssh root@your-vps-ip

# Update system
apt update && apt upgrade -y

# Install basic tools
apt install -y git curl wget build-essential
```

### Step 2: Install Node.js & Python

```bash
# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Verify Node.js
node --version  # Should be v18.x
npm --version   # Should be 9.x+

# Install Python 3.10+
apt install -y python3 python3-pip python3-venv

# Verify Python
python3 --version  # Should be 3.10+
```

### Step 3: Install Databases

```bash
# Install PostgreSQL
apt install -y postgresql postgresql-contrib

# Start PostgreSQL
systemctl start postgresql
systemctl enable postgresql

# Create database
sudo -u postgres psql -c "CREATE DATABASE nexus_cos;"
sudo -u postgres psql -c "CREATE USER nexusadmin WITH PASSWORD 'your-secure-password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE nexus_cos TO nexusadmin;"

# Install Redis
apt install -y redis-server

# Start Redis
systemctl start redis-server
systemctl enable redis-server
```

### Step 4: Install PM2 Process Manager

```bash
# Install PM2 globally
npm install -g pm2

# Set up PM2 startup script
pm2 startup systemd
# Follow the output instructions
```

### Step 5: Extract & Prepare Platform

```bash
# Create application directory
mkdir -p /opt/nexus-cos
cd /opt/nexus-cos

# Extract the handoff package
unzip /path/to/Nexus-COS-THIIO-FullStack.zip -d .

# Set permissions
chown -R www-data:www-data /opt/nexus-cos
chmod -R 755 /opt/nexus-cos
```

### Step 6: Configure Environment Variables

```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

**Key variables to configure:**
```env
# Database
DATABASE_URL=postgresql://nexusadmin:your-secure-password@localhost:5432/nexus_cos
REDIS_URL=redis://localhost:6379

# Domain
DOMAIN=your-domain.com

# Security
JWT_SECRET=generate-a-strong-random-secret
SESSION_SECRET=generate-another-strong-secret
ADMIN_KEY=secure-admin-key

# License Service
LICENSE_SERVICE_URL=http://localhost:3099
```

### Step 7: Install Dependencies

```bash
# Install root dependencies
npm install

# Install backend Python dependencies
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
deactivate
cd ..

# Run dependency installation script for all services
bash scripts/install-dependencies.sh
```

### Step 8: Database Migration

```bash
# Run banking migration
bash scripts/banking-migration.sh

# Run database migrations for all services
cd backend
source .venv/bin/activate
alembic upgrade head
deactivate
cd ..
```

### Step 9: Deploy License Service

```bash
# Navigate to license service
cd services/license-service

# Install dependencies
npm install

# Configure environment
cp .env.example .env
nano .env  # Update JWT_SECRET and ADMIN_KEY

# Start with PM2
pm2 start index.js --name license-service

# Verify it's running
curl http://localhost:3099/health

cd /opt/nexus-cos
```

### Step 10: Deploy Backend Services (Node.js)

```bash
# Use PM2 ecosystem files for organized deployment

# Deploy core platform services
pm2 start ecosystem.config.js

# Deploy family/urban platforms
pm2 start ecosystem.family.config.js

# Deploy V-Suite services
pm2 start ecosystem.vsuite.config.js

# Deploy PUABO platforms
pm2 start ecosystem.puabo.config.js

# Verify all services are running
pm2 list
```

### Step 11: Deploy Python Backend

```bash
# Start Python backend with PM2
cd backend
pm2 start "source .venv/bin/activate && uvicorn main:app --host 0.0.0.0 --port 8000" --name python-backend
cd ..

# Verify Python backend
curl http://localhost:8000/py/health
```

### Step 12: Install & Configure Nginx

```bash
# Install Nginx
apt install -y nginx

# Copy Nginx configuration
cp nginx.conf /etc/nginx/sites-available/nexus-cos
ln -s /etc/nginx/sites-available/nexus-cos /etc/nginx/sites-enabled/

# Remove default site
rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart Nginx
systemctl restart nginx
systemctl enable nginx
```

### Step 13: SSL/TLS Setup

```bash
# Install Certbot
apt install -y certbot python3-certbot-nginx

# Get SSL certificate
certbot --nginx -d your-domain.com -d www.your-domain.com

# Certbot will automatically configure Nginx

# Test auto-renewal
certbot renew --dry-run
```

### Step 14: Validate Core Endpoints

```bash
# Test main API
curl https://your-domain.com/api/status

# Test admin API
curl https://your-domain.com/api/admin/status

# Test Python backend
curl https://your-domain.com/py/health

# Test license service
curl http://localhost:3099/health
```

### Step 15: GPU/RTX Enablement (Optional)

If you have an NVIDIA RTX GPU:

```bash
# Run RTX enablement script
sudo bash scripts/generate-unreal-rtx.sh

# Follow Phase 2 instructions from the script output
# Check /root/RTX-ENABLEMENT-CHECKLIST.md for detailed steps
```

### Step 16: Validate License Service

```bash
# Test offline execution
curl -X POST http://localhost:3099/api/license/offline-verify \
  -H "Content-Type: application/json" \
  -d '{"serviceId": "core-service-1"}'

# Test runtime verification
curl -X POST http://localhost:3099/api/license/verify \
  -H "Content-Type: application/json" \
  -d '{"serviceId": "nexus-vision"}'

# Test cross-module recognition
curl -X POST http://localhost:3099/api/license/module-check \
  -H "Content-Type: application/json" \
  -d '{"moduleId": "casino-nexus", "serviceId": "core-service-1"}'
```

### Step 17: Test Family/Urban Platforms

Test each of the 12 family/urban platforms:

```bash
# 1. VSL (Video Streaming Live)
curl https://your-domain.com/vsl/health

# 2. Casino-Nexus
curl https://your-domain.com/casino-nexus/health

# 3. Gas or Crash (Gaming)
curl https://your-domain.com/gc-live/health

# 4. Club Saditty
curl https://your-domain.com/club-saditty/health

# 5. Ro Ro's Gaming Lounge
# (Part of casino-nexus module)

# 6. Headwina Comedy Club
curl https://your-domain.com/headwina-comedy/health

# 7. Sassie Lash
curl https://your-domain.com/sassie-lash/health

# 8. Fayeloni Kreations
curl https://your-domain.com/fayeloni/health

# 9. Sheda Shay's Butter Bar
curl https://your-domain.com/sheda-butter-bar/health

# 10. Ne Ne & Kids
curl https://your-domain.com/nene-kids/health

# 11. Ashanti's Munch & Mingle
curl https://your-domain.com/ashanti-munch/health

# 12. Cloc Dat T
curl https://your-domain.com/cloc-dat-t/health
```

### Step 18: Verify SHA256 Checksum

```bash
# Compare deployed ZIP with manifest
cd /opt/nexus-cos/dist

# Check SHA256
sha256sum Nexus-COS-THIIO-FullStack.zip

# Compare with manifest
cat Nexus-COS-THIIO-FullStack-manifest.json | grep sha256

# They should match exactly
```

### Step 19: Set Up Monitoring

```bash
# Install monitoring tools
npm install -g pm2-logrotate

# Configure log rotation
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7

# Enable PM2 monitoring
pm2 monitor

# Set up health checks
crontab -e

# Add health check cron job
*/5 * * * * /opt/nexus-cos/scripts/health-check.sh
```

### Step 20: Final Verification

```bash
# Run comprehensive validation
bash scripts/validate-services.sh

# Check all PM2 services
pm2 list

# Check Nginx status
systemctl status nginx

# Check logs for errors
pm2 logs --lines 50
```

---

## Service Port Reference

| Service | Port | Protocol |
|---------|------|----------|
| License Service | 3099 | HTTP |
| Backend API | 3000 | HTTP |
| Python Backend | 8000 | HTTP |
| Auth Service | 3001 | HTTP |
| Streaming Service | 3010 | HTTP |
| Casino Nexus | 3020 | HTTP |
| V-Screen Pro | 3030 | HTTP |
| PUABO DSP | 3040 | HTTP |
| PUABO Nexus | 3050 | HTTP |
| Redis | 6379 | TCP |
| PostgreSQL | 5432 | TCP |
| Nginx | 80, 443 | HTTP/HTTPS |

---

## Troubleshooting

### Services Won't Start

```bash
# Check logs
pm2 logs service-name

# Check environment variables
cat .env

# Verify database connection
psql -U nexusadmin -d nexus_cos -h localhost
```

### Database Connection Issues

```bash
# Check PostgreSQL status
systemctl status postgresql

# Verify user permissions
sudo -u postgres psql -c "\du"

# Test connection
psql "postgresql://nexusadmin:password@localhost:5432/nexus_cos"
```

### Nginx Issues

```bash
# Check Nginx error log
tail -f /var/log/nginx/error.log

# Verify configuration
nginx -t

# Check if ports are in use
netstat -tulpn | grep :80
netstat -tulpn | grep :443
```

### SSL Certificate Issues

```bash
# Renew certificate manually
certbot renew

# Check certificate status
certbot certificates

# Force renewal
certbot renew --force-renewal
```

### License Service Issues

```bash
# Check if running
pm2 list | grep license-service

# View logs
pm2 logs license-service

# Restart service
pm2 restart license-service

# Test endpoints
curl http://localhost:3099/health
```

### GPU/RTX Issues

```bash
# Check GPU status
nvidia-smi

# Verify CUDA
nvcc --version

# Check Docker GPU access
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu20.04 nvidia-smi

# Review RTX checklist
cat /root/RTX-ENABLEMENT-CHECKLIST.md
```

---

## Performance Optimization

### PM2 Cluster Mode

For high-traffic services, use cluster mode:

```bash
pm2 start index.js -i max --name service-name
```

### Database Optimization

```bash
# Edit PostgreSQL config
nano /etc/postgresql/14/main/postgresql.conf

# Recommended settings for 16GB RAM:
shared_buffers = 4GB
effective_cache_size = 12GB
maintenance_work_mem = 1GB
work_mem = 64MB
```

### Nginx Caching

Nginx is pre-configured with caching. Adjust in `/etc/nginx/sites-available/nexus-cos` if needed.

### Redis Optimization

```bash
# Edit Redis config
nano /etc/redis/redis.conf

# Recommended settings:
maxmemory 2gb
maxmemory-policy allkeys-lru
```

---

## Backup & Recovery

### Database Backup

```bash
# Create backup script
cat > /opt/backup-database.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/opt/backups"
mkdir -p $BACKUP_DIR
pg_dump -U nexusadmin nexus_cos | gzip > $BACKUP_DIR/nexus_cos_$(date +%Y%m%d_%H%M%S).sql.gz
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
EOF

chmod +x /opt/backup-database.sh

# Add to crontab (daily at 2 AM)
crontab -e
0 2 * * * /opt/backup-database.sh
```

### PM2 Process Save

```bash
# Save current PM2 process list
pm2 save

# This ensures processes restart on reboot
```

---

## Security Hardening

### Firewall Configuration

```bash
# Install UFW
apt install -y ufw

# Configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp  # SSH
ufw allow 80/tcp  # HTTP
ufw allow 443/tcp # HTTPS

# Enable firewall
ufw enable
```

### SSH Hardening

```bash
# Edit SSH config
nano /etc/ssh/sshd_config

# Recommended settings:
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes

# Restart SSH
systemctl restart sshd
```

### Environment Variable Security

```bash
# Secure .env file
chmod 600 /opt/nexus-cos/.env
chown www-data:www-data /opt/nexus-cos/.env
```

---

## Maintenance

### Weekly Tasks

- Check disk space: `df -h`
- Review logs: `pm2 logs --lines 100`
- Check service health: `pm2 list`
- Database backup verification

### Monthly Tasks

- Update system packages: `apt update && apt upgrade`
- Review SSL certificate expiry: `certbot certificates`
- Analyze performance metrics
- Review security logs

### Quarterly Tasks

- Review and update dependencies
- Performance optimization review
- Security audit
- Backup restoration test

---

## Support & Resources

### Documentation Locations
- **Platform Overview**: `/opt/nexus-cos/PROJECT-OVERVIEW.md`
- **Architecture**: `/opt/nexus-cos/docs/THIIO-HANDOFF/architecture/`
- **Service Docs**: `/opt/nexus-cos/docs/THIIO-HANDOFF/services/`
- **Module Docs**: `/opt/nexus-cos/docs/THIIO-HANDOFF/modules/`

### Useful Commands

```bash
# View all services
pm2 list

# View service logs
pm2 logs service-name

# Restart all services
pm2 restart all

# Stop all services
pm2 stop all

# Monitor resources
pm2 monit

# Check Nginx status
systemctl status nginx

# Check database
sudo -u postgres psql -d nexus_cos

# Test endpoints
bash scripts/validate-services.sh
```

### Emergency Contact

**90-Day Support Period:**
- Email: support@nexus-cos-platform.example
- GitHub Issues: [Repository URL]
- Documentation: This handoff package

---

## Deployment Checklist

Use this checklist to track your deployment progress:

- [ ] VPS access confirmed
- [ ] System updated
- [ ] Node.js installed
- [ ] Python installed
- [ ] PostgreSQL installed and configured
- [ ] Redis installed
- [ ] PM2 installed
- [ ] Platform extracted to /opt/nexus-cos
- [ ] Environment variables configured
- [ ] Dependencies installed
- [ ] Database migrated
- [ ] License service deployed
- [ ] Backend services deployed (Node.js)
- [ ] Python backend deployed
- [ ] Nginx installed and configured
- [ ] SSL certificates obtained
- [ ] All endpoints validated
- [ ] GPU/RTX enabled (if applicable)
- [ ] License service validated
- [ ] 12 family platforms tested
- [ ] SHA256 verified
- [ ] Monitoring configured
- [ ] Backups configured
- [ ] Firewall configured
- [ ] Documentation reviewed

---

## Conclusion

Your Nexus COS platform should now be fully deployed and operational. The platform includes:

✅ 52+ services running and healthy  
✅ 43 modules integrated  
✅ 12 family/urban platforms operational  
✅ License service active (offline-capable)  
✅ Full infrastructure deployed  
✅ SSL/HTTPS enabled  
✅ Monitoring active  

**Next Steps:**
1. Review platform documentation in `/opt/nexus-cos/docs/`
2. Customize branding and configuration as needed
3. Set up additional monitoring and alerting
4. Plan regular maintenance schedule
5. Begin user onboarding

**Support is available for 90 days post-handoff for deployment and configuration assistance.**

---

*Nexus COS - Complete Platform Handoff*  
*Version 2.0.0 - December 13, 2025*
