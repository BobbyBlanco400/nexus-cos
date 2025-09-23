# Nexus COS Extended - VPS Deployment Guide

## Prerequisites

### 1. VPS Requirements
- **OS**: Ubuntu 20.04 LTS or newer
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: Minimum 100GB SSD
- **CPU**: 4+ cores
- **Network**: Public IP with ports 80, 443, 22 open

### 2. Domain Setup
- Point your domain `nexuscos.online` to your VPS IP address
- Create A records for:
  - `nexuscos.online` → VPS IP
  - `www.nexuscos.online` → VPS IP
  - `*.nexuscos.online` → VPS IP (for subdomains)

### 3. Required Software on VPS
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
sudo apt install git -y

# Install Node.js and npm (for EAS CLI)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install EAS CLI globally
sudo npm install -g @expo/eas-cli

# Install Certbot for SSL
sudo apt install certbot python3-certbot-nginx -y
```

## Deployment Steps

### Step 1: Connect to Your VPS
```bash
# Replace YOUR_VPS_IP with your actual VPS IP address
ssh root@YOUR_VPS_IP

# Or if using a non-root user:
ssh username@YOUR_VPS_IP
```

### Step 2: Upload Files to VPS
You have several options to transfer the deployment files:

#### Option A: Using SCP (from your local machine)
```bash
# Navigate to your project directory
cd C:\Users\wecon\Downloads\nexus-cos-main

# Copy deployment script
scp deploy-nexus-cos-extended.sh root@YOUR_VPS_IP:/root/

# Copy environment file
scp .env.production.vps root@YOUR_VPS_IP:/root/.env.production

# Make script executable
ssh root@YOUR_VPS_IP "chmod +x /root/deploy-nexus-cos-extended.sh"
```

#### Option B: Using Git (recommended)
```bash
# On your VPS, clone your repository
git clone https://github.com/YOUR_USERNAME/nexus-cos-main.git
cd nexus-cos-main

# Copy the environment file
cp .env.production.vps .env.production

# Make script executable
chmod +x deploy-nexus-cos-extended.sh
```

#### Option C: Manual Copy-Paste
1. Create the files manually on your VPS:
```bash
nano /root/deploy-nexus-cos-extended.sh
# Copy and paste the script content

nano /root/.env.production
# Copy and paste the environment variables

chmod +x /root/deploy-nexus-cos-extended.sh
```

### Step 3: Configure Environment Variables
Edit the production environment file with your actual values:
```bash
nano /root/.env.production
```

**Important**: Update these critical variables:
- `DOMAIN=nexuscos.online` (your actual domain)
- Database passwords and secrets
- API keys (KEI AI, Stripe, AWS, etc.)
- OAuth credentials
- Email SMTP settings
- Mobile app credentials (EAS token, Apple ID, etc.)

### Step 4: Run the Deployment Script
```bash
# Navigate to the script location
cd /root

# Run the deployment script
./deploy-nexus-cos-extended.sh
```

The script will:
1. Clean any existing deployment
2. Clone all required repositories
3. Set up Docker containers
4. Configure Nginx reverse proxy
5. Install SSL certificates
6. Build and deploy all services
7. Optionally build mobile apps
8. Run health checks
9. Generate a deployment report

### Step 5: Monitor the Deployment
The script provides real-time feedback. Watch for:
- ✅ Green checkmarks for successful steps
- ❌ Red X marks for failures
- 📊 Progress indicators
- 🔍 Health check results

## Post-Deployment Verification

### 1. Check Service Status
```bash
# Check Docker containers
docker ps

# Check Nginx status
sudo systemctl status nginx

# Check SSL certificate
sudo certbot certificates

# View logs
docker-compose logs -f
```

### 2. Test Endpoints
Visit these URLs in your browser:
- https://nexuscos.online (Main frontend)
- https://nexuscos.online/admin (Admin panel)
- https://nexuscos.online/api/health (API health check)
- https://nexuscos.online/grafana (Monitoring dashboard)

### 3. Mobile App Verification
If mobile apps were built:
- Check EAS build status: `eas build:list`
- Verify app store submissions
- Test deep links and push notifications

## Troubleshooting

### Common Issues and Solutions

#### 1. Domain Not Resolving
```bash
# Check DNS propagation
nslookup nexuscos.online
dig nexuscos.online

# Verify Nginx configuration
sudo nginx -t
sudo systemctl reload nginx
```

#### 2. SSL Certificate Issues
```bash
# Manually obtain certificate
sudo certbot --nginx -d nexuscos.online -d www.nexuscos.online

# Check certificate status
sudo certbot certificates

# Renew certificates
sudo certbot renew --dry-run
```

#### 3. Docker Container Issues
```bash
# Check container logs
docker logs container_name

# Restart specific service
docker-compose restart service_name

# Rebuild containers
docker-compose down
docker-compose up --build -d
```

#### 4. Database Connection Issues
```bash
# Check PostgreSQL container
docker exec -it postgres_container psql -U nexus_admin -d nexus

# Verify environment variables
docker exec container_name env | grep DATABASE
```

#### 5. Port Conflicts
```bash
# Check what's using ports
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Kill conflicting processes
sudo fuser -k 80/tcp
sudo fuser -k 443/tcp
```

## Maintenance Commands

### Regular Maintenance
```bash
# Update containers
docker-compose pull
docker-compose up -d

# Clean up unused Docker resources
docker system prune -f

# Backup database
docker exec postgres_container pg_dump -U nexus_admin nexus > backup_$(date +%Y%m%d).sql

# View resource usage
docker stats

# Check disk space
df -h
```

### Log Management
```bash
# View application logs
docker-compose logs -f --tail=100

# View Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# View system logs
sudo journalctl -f
```

## Security Considerations

### 1. Firewall Configuration
```bash
# Enable UFW firewall
sudo ufw enable

# Allow necessary ports
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS

# Check firewall status
sudo ufw status
```

### 2. Regular Updates
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Docker images
docker-compose pull
docker-compose up -d

# Update SSL certificates
sudo certbot renew
```

### 3. Backup Strategy
- Set up automated database backups
- Configure file system backups
- Test restore procedures regularly
- Store backups in multiple locations

## Support and Monitoring

### Monitoring Dashboard
Access Grafana at: https://nexuscos.online/grafana
- Default login: admin/admin123
- Monitor system metrics, application performance, and user activity

### Health Checks
The deployment includes automated health checks for:
- Database connectivity
- Redis cache
- API endpoints
- Frontend accessibility
- SSL certificate validity

### Getting Help
If you encounter issues:
1. Check the deployment logs
2. Review the troubleshooting section
3. Verify environment variables
4. Check Docker container status
5. Review Nginx configuration

## Success Indicators

Your deployment is successful when:
- ✅ All Docker containers are running
- ✅ Nginx is serving HTTPS traffic
- ✅ SSL certificates are valid
- ✅ All health checks pass
- ✅ Frontend loads at https://nexuscos.online
- ✅ Admin panel accessible
- ✅ API endpoints respond correctly
- ✅ Mobile apps built successfully (if enabled)
- ✅ Monitoring dashboard accessible

Congratulations! Your Nexus COS Extended platform is now live on nexuscos.online! 🎉