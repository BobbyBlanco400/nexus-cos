# Nexus COS VPS Deployment Package

## 🚀 Complete Production-Ready Deployment Package

This package contains everything needed to deploy Nexus COS to a production VPS server.

### 📋 Package Contents

#### Core Application Files
- **Frontend Applications**: React-based user interfaces
  - Main Frontend (`frontend/`) - Primary user interface
  - Admin Panel (`trae-solo-unified/admin/`) - Administrative dashboard
  - TV/Radio Interface (`trae-solo-unified/tv-radio/`) - Broadcasting interface
  - Mobile App (`nexus-cos-main/mobile/`) - React Native mobile application

#### Microservices
- **V-Suite Services** (Legacy integration)
  - V-Screen (`services/v-screen/`) - Screen management service
  - V-Stage (`services/v-stage/`) - Stage control service
  - V-Caster Pro (`services/v-caster-pro/`) - Broadcasting service
  - V-Prompter Pro (`services/v-prompter-pro/`) - Teleprompter service

- **New Nexus COS Services**
  - Nexus COS Studio AI (`services/nexus-cos-studio-ai/`) - AI-powered studio features
  - Boom Boom Room Live (`services/boom-boom-room-live/`) - Live streaming service

#### Configuration Files
- `docker-compose.prod.yml` - Production Docker Compose configuration
- `.env.production` - Production environment variables (template)
- `.env.development` - Development environment variables
- `.env.example` - Environment variables template
- `.gitignore` - Git ignore rules for security
- `nginx/nginx.conf` - Reverse proxy configuration

#### Deployment Scripts
- `scripts/deploy_nexus_cos.sh` - Main VPS deployment script
- `scripts/validate-deployment.ps1` - Pre-deployment validation
- `scripts/health-check.ps1` - Post-deployment health monitoring
- `scripts/test-microservices.ps1` - Service integration testing

### 🔧 Pre-Deployment Requirements

#### Server Requirements
- **OS**: Ubuntu 20.04+ or CentOS 8+
- **RAM**: Minimum 8GB (16GB+ recommended)
- **Storage**: Minimum 50GB free space
- **CPU**: 4+ cores recommended
- **Network**: Public IP with ports 80, 443 accessible

#### Software Dependencies
- Docker 20.10+
- Docker Compose 2.0+
- Git 2.30+
- Bash shell
- SSL certificates (Let's Encrypt recommended)

### 🚀 Quick Deployment Guide

#### 1. Server Preparation
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login to apply Docker group changes
```

#### 2. Deploy Application
```bash
# Clone or upload the deployment package
git clone <your-repo-url> /opt/nexus-cos
cd /opt/nexus-cos

# Configure environment
cp .env.production .env
nano .env  # Edit with your production values

# Run deployment
chmod +x scripts/deploy_nexus_cos.sh
sudo ./scripts/deploy_nexus_cos.sh
```

#### 3. Verify Deployment
```bash
# Check service status
docker-compose -f docker-compose.prod.yml ps

# Run health checks
./scripts/health-check.ps1 -Quick

# View logs
docker-compose -f docker-compose.prod.yml logs -f
```

### 🔐 Security Configuration

#### Environment Variables Setup
1. Copy `.env.production` to `.env`
2. Update all placeholder values with secure production data:
   - Database passwords
   - JWT secrets
   - API keys
   - SSL certificate paths
   - Domain configuration

#### SSL/TLS Setup
```bash
# Using Let's Encrypt (recommended)
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com

# Or place your certificates in:
# ./ssl/yourdomain.com.crt
# ./ssl/yourdomain.com.key
```

#### Firewall Configuration
```bash
# Configure UFW firewall
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

### 📊 Service Architecture

#### Port Allocation
- **80/443**: Nginx (HTTP/HTTPS)
- **3000**: Main Frontend
- **3001**: Admin Panel
- **3002**: TV/Radio Interface
- **3010-3015**: Microservices
- **5432**: PostgreSQL Database
- **6379**: Redis Cache

#### Service Dependencies
```
Nginx (Reverse Proxy)
├── Frontend Applications (3000-3002)
├── Microservices (3010-3015)
├── Database (PostgreSQL:5432)
└── Cache (Redis:6379)
```

### 🔍 Monitoring & Maintenance

#### Health Monitoring
```bash
# Continuous health monitoring
./scripts/health-check.ps1 -Continuous -Interval 300

# Generate health reports
./scripts/health-check.ps1 -GenerateReport
```

#### Log Management
```bash
# View service logs
docker-compose -f docker-compose.prod.yml logs [service-name]

# Log rotation is configured automatically
# Logs are stored in: /var/log/nexus-cos/
```

#### Backup Procedures
```bash
# Database backup
docker-compose -f docker-compose.prod.yml exec postgres pg_dump -U nexus_user nexus_cos > backup.sql

# Full application backup
tar -czf nexus-cos-backup-$(date +%Y%m%d).tar.gz /opt/nexus-cos
```

### 🛠️ Troubleshooting

#### Common Issues

1. **Services not starting**
   ```bash
   # Check Docker daemon
   sudo systemctl status docker
   
   # Check resource usage
   docker system df
   docker system prune -f
   ```

2. **Database connection issues**
   ```bash
   # Check PostgreSQL logs
   docker-compose -f docker-compose.prod.yml logs postgres
   
   # Test database connection
   docker-compose -f docker-compose.prod.yml exec postgres psql -U nexus_user -d nexus_cos
   ```

3. **SSL certificate issues**
   ```bash
   # Renew Let's Encrypt certificates
   sudo certbot renew
   
   # Test SSL configuration
   openssl s_client -connect yourdomain.com:443
   ```

#### Performance Optimization

1. **Resource Monitoring**
   ```bash
   # Monitor resource usage
   docker stats
   
   # Check system resources
   htop
   df -h
   ```

2. **Database Optimization**
   ```bash
   # Optimize PostgreSQL
   docker-compose -f docker-compose.prod.yml exec postgres psql -U nexus_user -d nexus_cos -c "VACUUM ANALYZE;"
   ```

### 📞 Support & Updates

#### Getting Help
- Check logs: `docker-compose -f docker-compose.prod.yml logs`
- Run diagnostics: `./scripts/validate-deployment.ps1 -CheckAll`
- Health check: `./scripts/health-check.ps1 -Detailed`

#### Updates & Maintenance
```bash
# Update application
git pull origin main
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d --build

# Update system packages
sudo apt update && sudo apt upgrade -y
```

### 📝 Deployment Checklist

- [ ] Server meets minimum requirements
- [ ] Docker and Docker Compose installed
- [ ] Environment variables configured
- [ ] SSL certificates installed
- [ ] Firewall configured
- [ ] DNS records pointing to server
- [ ] Backup strategy implemented
- [ ] Monitoring configured
- [ ] Health checks passing
- [ ] All services accessible

### 🎯 Success Metrics

After successful deployment, you should have:
- ✅ All services running and healthy
- ✅ Frontend accessible via HTTPS
- ✅ Admin panel functional
- ✅ Microservices responding
- ✅ Database connected and operational
- ✅ SSL certificates valid
- ✅ Monitoring active
- ✅ Backups configured

---

**Deployment Package Version**: 1.0.0  
**Last Updated**: September 18, 2025  
**Compatibility**: Ubuntu 20.04+, CentOS 8+, Docker 20.10+