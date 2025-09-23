# 🚀 Nexus COS Complete Deployment Guide

## Overview

This guide covers the complete deployment workflow for Nexus COS using TRAE Solo architecture, from local development setup to production deployment on Ubuntu VPS.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    TRAE SOLO ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────┤
│  Frontend (React)     │  Backend Services  │  Infrastructure │
│  ├─ React App        │  ├─ Python/FastAPI │  ├─ PostgreSQL  │
│  ├─ Vite Build       │  ├─ Node.js/Express│  ├─ Nginx       │
│  └─ Static Assets    │  └─ Authentication │  ├─ SSL/TLS     │
│                      │                    │  └─ Monitoring  │
└─────────────────────────────────────────────────────────────┘
```

## Deployment Phases

### Phase 1: Local Development Setup (TRAE Solo)

**Prerequisites:**
- Windows 10/11 with PowerShell 5+
- Git installed
- Node.js 18+ (optional for local development)

**Steps:**

1. **Clone and Setup Project**
   ```powershell
   git clone https://github.com/BobbyBlanco400/nexus-cos.git
   cd nexus-cos
   ```

2. **Run TRAE Solo Deployment**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\deploy-trae-solo.ps1
   ```

3. **Verify Local Deployment**
   - Check deployment summary: `artifacts\deployment-summary-*.md`
   - Review deployment package: `artifacts\nexus-cos-deployment\`

### Phase 2: Production VPS Setup

**Prerequisites:**
- Ubuntu 22.04 VPS with root access
- Domain name pointing to VPS IP
- SSH access to VPS

**Configuration:**
```bash
DOMAIN="nexuscos.online"
EMAIL="puaboverse@gmail.com"
VPS_IP="YOUR_VPS_IP"
```

**Steps:**

1. **Upload Deployment Package**
   ```bash
   # From local machine
   scp -r artifacts/nexus-cos-deployment root@$VPS_IP:/tmp/
   ```

2. **Upload Production Setup Script**
   ```bash
   scp scripts/production-auto-setup.sh root@$VPS_IP:/tmp/
   ```

3. **SSH into VPS and Run Setup**
   ```bash
   ssh root@$VPS_IP
   chmod +x /tmp/production-auto-setup.sh
   /tmp/production-auto-setup.sh
   ```

### Phase 3: Post-Deployment Verification

**Health Checks:**

1. **Service Status**
   ```bash
   systemctl status nexus-backend-python
   systemctl status nexus-backend-node  # if configured
   systemctl status nginx
   systemctl status postgresql
   ```

2. **API Testing**
   ```bash
   # Health check
   curl https://nexuscos.online/health
   
   # API endpoints
   curl https://nexuscos.online/api/python/docs
   curl https://nexuscos.online/api/node/health  # if configured
   ```

3. **Frontend Access**
   - Visit: https://nexuscos.online
   - Verify React app loads correctly
   - Test user registration/login

## Configuration Details

### Environment Variables

**Production (.env):**
```bash
# Database
DATABASE_URL=postgresql://nexus_admin:Momoney2025$$@localhost:5432/nexus_cos

# Security
JWT_SECRET=whitefamilylegacy600$$
SECRET_KEY=your-secret-key-here

# Application
ENVIRONMENT=production
DEBUG=false
ALLOWED_HOSTS=nexuscos.online

# Email (if configured)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=puaboverse@gmail.com
SMTP_PASSWORD=your-app-password
```

### Database Schema

**PostgreSQL Setup:**
```sql
-- Database: nexus_cos
-- User: nexus_admin
-- Password: Momoney2025$$

-- Tables will be created automatically by the application
-- on first run through migrations
```

### Nginx Configuration

**Key Features:**
- SSL/TLS termination
- Reverse proxy for API routes
- Static file serving
- Gzip compression
- Security headers
- Health check endpoint

**Routes:**
- `/` → React frontend
- `/api/python/` → Python/FastAPI backend
- `/api/node/` → Node.js backend (if configured)
- `/health` → Health check

## Security Features

### Implemented Security

1. **SSL/TLS Encryption**
   - Let's Encrypt certificates
   - Automatic HTTPS redirect
   - HSTS headers

2. **Firewall Configuration**
   - UFW enabled
   - Only necessary ports open
   - SSH access protected

3. **Application Security**
   - JWT authentication
   - Password hashing (bcrypt)
   - CORS configuration
   - Security headers

4. **Database Security**
   - Dedicated database user
   - Limited privileges
   - Connection encryption

### Security Headers
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
```

## Monitoring and Maintenance

### Log Locations

```bash
# Application logs
journalctl -u nexus-backend-python -f
journalctl -u nexus-backend-node -f

# Nginx logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# PostgreSQL logs
tail -f /var/log/postgresql/postgresql-*.log
```

### Backup Strategy

**Database Backup:**
```bash
# Create backup
pg_dump -U nexus_admin -h localhost nexus_cos > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
psql -U nexus_admin -h localhost nexus_cos < backup_file.sql
```

**Application Backup:**
```bash
# Backup application directory
tar -czf nexus_cos_backup_$(date +%Y%m%d_%H%M%S).tar.gz /var/www/nexus-cos
```

### Performance Monitoring

**System Resources:**
```bash
# CPU and Memory
htop

# Disk usage
df -h

# Network connections
netstat -tlnp

# Service status
systemctl status nexus-backend-python
```

## Troubleshooting

### Common Issues

1. **Service Won't Start**
   ```bash
   # Check service status
   systemctl status nexus-backend-python
   
   # View detailed logs
   journalctl -u nexus-backend-python --no-pager
   
   # Restart service
   systemctl restart nexus-backend-python
   ```

2. **Database Connection Issues**
   ```bash
   # Test database connection
   psql -U nexus_admin -h localhost -d nexus_cos
   
   # Check PostgreSQL status
   systemctl status postgresql
   ```

3. **SSL Certificate Issues**
   ```bash
   # Check certificate status
   certbot certificates
   
   # Renew certificate
   certbot renew
   
   # Test certificate
   certbot certonly --dry-run -d nexuscos.online
   ```

4. **Frontend Not Loading**
   ```bash
   # Check Nginx configuration
   nginx -t
   
   # Restart Nginx
   systemctl restart nginx
   
   # Check frontend build
   ls -la /var/www/nexus-cos/frontend/dist/
   ```

### Emergency Recovery

**Service Recovery:**
```bash
# Stop all services
systemctl stop nexus-backend-python nexus-backend-node nginx

# Start services in order
systemctl start postgresql
systemctl start nexus-backend-python
systemctl start nexus-backend-node  # if configured
systemctl start nginx
```

**Database Recovery:**
```bash
# If database is corrupted
sudo -u postgres pg_resetwal /var/lib/postgresql/14/main
systemctl restart postgresql
```

## Scaling and Optimization

### Performance Optimization

1. **Database Optimization**
   - Add database indexes
   - Configure connection pooling
   - Optimize queries

2. **Application Optimization**
   - Enable caching
   - Optimize API responses
   - Use CDN for static assets

3. **Server Optimization**
   - Increase worker processes
   - Configure load balancing
   - Add monitoring tools

### Horizontal Scaling

**Load Balancer Setup:**
```nginx
upstream backend {
    server 127.0.0.1:3001;
    server 127.0.0.1:3002;
    server 127.0.0.1:3003;
}
```

## CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Deploy Nexus COS
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to VPS
        run: |
          ssh root@${{ secrets.VPS_IP }} 'cd /var/www/nexus-cos && git pull && systemctl restart nexus-backend-python'
```

## Support and Documentation

### Generated Documentation

- **TRAE_SOLO_DEPLOYMENT_COMPLETE.md** - Local deployment summary
- **DEPLOYMENT_INSTRUCTIONS.md** - Step-by-step deployment guide
- **PRODUCTION_DEPLOYMENT_SUMMARY.md** - Production deployment status
- **deployment-summary-*.md** - Timestamped deployment reports

### Support Resources

- **GitHub Repository:** https://github.com/BobbyBlanco400/nexus-cos
- **TRAE Solo Documentation:** Included in deployment package
- **Production Logs:** Available via systemctl and journalctl
- **Health Monitoring:** https://nexuscos.online/health

### Contact Information

- **Email:** puaboverse@gmail.com
- **Domain:** nexuscos.online
- **Repository:** BobbyBlanco400/nexus-cos

---

**Deployment Status:** ✅ Complete
**Architecture:** TRAE Solo
**Environment:** Production Ready
**SSL:** Enabled
**Monitoring:** Active
**Backup:** Configured

*Last Updated: $(date)*