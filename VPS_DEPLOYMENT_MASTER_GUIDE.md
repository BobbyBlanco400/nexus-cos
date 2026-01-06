# Nexus COS Platform Stack - Complete VPS Deployment Guide

## 🚀 Quick Start - One Command Deployment

**For production deployment to n3xuscos.online (74.208.155.161):**

```bash
ssh root@74.208.155.161 'curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/deploy-nexus-cos-vps-master.sh | bash'
```

## 📋 What Gets Deployed

This deployment includes the complete Nexus COS Platform Stack:

### Services (52 microservices)
- Backend API, AI Service, Key Service, Auth Services
- PUABO DSP (Upload, Metadata, Streaming)
- PUABO BLAC (Loan Processing, Risk Assessment)
- PUABO Nexus (Fleet Manager, Route Optimizer, AI Dispatch, Driver App)
- PUABO NUKI (Inventory, Orders, Products, Shipping)
- Streaming Services, Content Management, Creator Hub
- V-Suite Pro (V-Caster, V-Prompter, V-Screen, VScreen Hollywood)
- Analytics, Notifications, Chat, Recommendations
- And 20+ more services...

### Modules (43 modules)
- **Urban Family** (11 modules): Club Saditty, RoRo Gaming Lounge, Ahshanti's Munch and Mingle, etc.
- Family, Urban, NexusNet modules
- V-Suite modules
- Gaming and entertainment modules

### PUABO Core Banking Platform
- Apache Fineract (Core Banking System)
- PUABO Core Adapter API
- Smart Contracts Engine
- PostgreSQL Database
- Redis Event Bus

### Infrastructure
- Nginx reverse proxy with SSL (IONOS certificates)
- Socket.IO endpoints for real-time communication
- PM2 process management
- Docker containerization
- Plesk integration

## 🔑 Prerequisites

### Required Access
```bash
ssh root@74.208.155.161
```

### SSL Certificates (Already in place)
- Private Key: `/root/ionos/privkey.pem`
- Certificate: `/root/ionos/cert.pem`
- CA Chain: `/root/ionos/chain.pem`

### System Requirements
- **Memory**: 8GB minimum (16GB recommended)
- **Storage**: 20GB minimum free space
- **OS**: Ubuntu 20.04+ or Debian 11+
- **Software** (auto-installed if missing):
  - Docker 20.10+
  - Docker Compose 2.0+
  - Node.js 20.x
  - PM2
  - Nginx
  - Git

## 📦 Deployment Methods

### Method 1: Remote One-Command (Recommended)

Deploy from your local machine without SSHing first:

```bash
ssh root@74.208.155.161 'curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/deploy-nexus-cos-vps-master.sh | bash'
```

### Method 2: Direct SSH Deployment

SSH into the server first, then deploy:

```bash
# Step 1: SSH into VPS
ssh root@74.208.155.161

# Step 2: Run deployment
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/deploy-nexus-cos-vps-master.sh | bash
```

### Method 3: Manual Clone and Deploy

For more control over the process:

```bash
# Step 1: SSH into VPS
ssh root@74.208.155.161

# Step 2: Clone repository
cd /var/www
git clone https://github.com/BobbyBlanco400/nexus-cos.git
cd nexus-cos

# Step 3: Run deployment script
chmod +x deploy-nexus-cos-vps-master.sh
./deploy-nexus-cos-vps-master.sh
```

## 📊 Deployment Process

The deployment script executes 7 phases automatically:

### Phase 1: Pre-Deployment Checks ⏱️ ~2 minutes
- ✅ Verify root access
- ✅ Check system resources (RAM, disk space)
- ✅ Verify SSL certificates
- ✅ Install missing dependencies (Docker, Node.js, PM2, Nginx, Git)

### Phase 2: Repository Setup ⏱️ ~3 minutes
- ✅ Create deployment directory `/var/www/nexus-cos`
- ✅ Backup existing installation (if any)
- ✅ Clone repository from GitHub
- ✅ Verify repository structure

### Phase 3: PUABO Core Deployment ⏱️ ~5 minutes
- ✅ Deploy Apache Fineract banking system
- ✅ Deploy PostgreSQL database
- ✅ Deploy PUABO Core Adapter API
- ✅ Deploy Smart Contracts Engine
- ✅ Initialize banking products
- ✅ Verify health endpoints

### Phase 4: Microservices Deployment ⏱️ ~8 minutes
- ✅ Deploy 52 microservices with PM2
- ✅ Deploy Docker services
- ✅ Configure service discovery
- ✅ Set up inter-service communication

### Phase 5: Nginx Configuration ⏱️ ~2 minutes
- ✅ Configure reverse proxy
- ✅ Set up SSL/TLS with IONOS certificates
- ✅ Configure endpoint routing
- ✅ Set up 301 redirect (/ → /streaming/)
- ✅ Configure Socket.IO proxying
- ✅ Add security headers

### Phase 6: Health Checks ⏱️ ~3 minutes
- ✅ Test all 5 critical endpoints
- ✅ Verify SSL certificates
- ✅ Check PUABO Core health
- ✅ Verify PM2 services
- ✅ Check Docker containers

### Phase 7: Post-Deployment Summary ⏱️ ~1 minute
- ✅ Display deployment status
- ✅ Show all endpoints
- ✅ Provide management commands
- ✅ Generate deployment log

**Total Time**: ~20-25 minutes

## ✅ Verification After Deployment

### Test All Endpoints

```bash
# Root redirect (should return 301 → /streaming/)
curl -I https://n3xuscos.online/

# API endpoint (should return 200)
curl https://n3xuscos.online/api/

# Streaming endpoint (should return 200)
curl https://n3xuscos.online/streaming/

# Socket.IO main (should return 200)
curl "https://n3xuscos.online/socket.io/?EIO=4&transport=polling"

# Socket.IO streaming (should return 200)
curl "https://n3xuscos.online/streaming/socket.io/?EIO=4&transport=polling"

# PUABO Core health (should return healthy)
curl http://localhost:7777/health
```

### Expected Results

| Endpoint | URL | Expected Status | Description |
|----------|-----|-----------------|-------------|
| **Root** | `https://n3xuscos.online/` | **301** | Redirects to `/streaming/` |
| **API Base** | `https://n3xuscos.online/api/` | **200** | Main API endpoint |
| **Streaming** | `https://n3xuscos.online/streaming/` | **200** | Streaming service |
| **Socket.IO Main** | `https://n3xuscos.online/socket.io/...` | **200** | Real-time communication |
| **Socket.IO Streaming** | `https://n3xuscos.online/streaming/socket.io/...` | **200** | Real-time streaming |
| **PUABO Core** | `http://localhost:7777/health` | **200** | Banking API health |

### Check Service Status

```bash
# PM2 services
pm2 status

# Docker containers
docker ps

# Nginx status
systemctl status nginx

# PUABO Core
cd /var/www/nexus-cos/nexus-cos/puabo-core
docker compose -f docker-compose.core.yml ps
```

## 🔧 Post-Deployment Management

### View Logs

```bash
# Deployment log
tail -f /var/log/nexus-cos/deployment-*.log

# PM2 logs (all services)
pm2 logs

# PM2 logs (specific service)
pm2 logs backend-api

# Docker services
cd /var/www/nexus-cos
docker compose -f docker-compose.unified.yml logs -f

# PUABO Core
cd /var/www/nexus-cos/nexus-cos/puabo-core
docker compose -f docker-compose.core.yml logs -f

# Nginx
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### Restart Services

```bash
# Restart all PM2 services
pm2 restart all

# Restart specific PM2 service
pm2 restart backend-api

# Restart Docker services
cd /var/www/nexus-cos
docker compose -f docker-compose.unified.yml restart

# Restart PUABO Core
cd /var/www/nexus-cos/nexus-cos/puabo-core
docker compose -f docker-compose.core.yml restart

# Restart Nginx
systemctl restart nginx
```

### Update Deployment

```bash
# Pull latest changes
cd /var/www/nexus-cos
git pull origin main

# Restart services
pm2 restart all
docker compose -f docker-compose.unified.yml restart
cd nexus-cos/puabo-core
docker compose -f docker-compose.core.yml restart
```

## 🔍 Troubleshooting

### Services Not Starting

```bash
# Check PM2 errors
pm2 logs --err

# Check resource usage
free -h
df -h

# Check for port conflicts
lsof -i :3000
lsof -i :7777

# Restart services
pm2 delete all
pm2 start ecosystem.config.js
```

### Nginx Issues

```bash
# Test Nginx configuration
nginx -t

# Check Nginx error log
tail -f /var/log/nginx/error.log

# Reload Nginx
systemctl reload nginx

# Restart Nginx
systemctl restart nginx
```

### SSL Certificate Issues

```bash
# Verify certificates exist
ls -la /root/ionos/

# Check certificate validity
openssl x509 -in /root/ionos/cert.pem -noout -dates

# Test SSL connection
openssl s_client -connect n3xuscos.online:443 -servername n3xuscos.online
```

### PUABO Core Not Responding

```bash
# Check PUABO Core status
cd /var/www/nexus-cos/nexus-cos/puabo-core
docker compose -f docker-compose.core.yml ps

# View PUABO Core logs
docker compose -f docker-compose.core.yml logs -f

# Restart PUABO Core
docker compose -f docker-compose.core.yml restart

# Check health endpoint
curl http://localhost:7777/health
```

### Database Connection Issues

```bash
# Check PostgreSQL
docker exec -it fineract-db psql -U postgres -c "SELECT version();"

# Check Redis
docker exec -it redis-internal redis-cli ping

# Restart databases
cd /var/www/nexus-cos/nexus-cos/puabo-core
docker compose -f docker-compose.core.yml restart fineract-db redis-internal
```

## 🔄 Rollback Procedure

If deployment fails:

```bash
# Stop all services
pm2 stop all
systemctl stop nginx

# Stop Docker services
cd /var/www/nexus-cos
docker compose -f docker-compose.unified.yml down
cd nexus-cos/puabo-core
docker compose -f docker-compose.core.yml down

# Restore from backup
ls -la /var/www/nexus-cos-backup-*
mv /var/www/nexus-cos /var/www/nexus-cos-failed
mv /var/www/nexus-cos-backup-YYYYMMDD-HHMMSS /var/www/nexus-cos

# Restart services
cd /var/www/nexus-cos
pm2 start ecosystem.config.js
systemctl start nginx
```

## 📈 Monitoring Setup

### Create Health Check Script

```bash
# Create monitoring script
cat > /usr/local/bin/nexus-health-check.sh <<'EOF'
#!/bin/bash
# Nexus COS Health Monitoring

ENDPOINTS=(
  "https://n3xuscos.online/api/"
  "https://n3xuscos.online/streaming/"
  "http://localhost:7777/health"
)

for endpoint in "${ENDPOINTS[@]}"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "$endpoint")
  if [ "$status" != "200" ] && [ "$status" != "301" ]; then
    echo "$(date) - ALERT: ${endpoint} returned ${status}" >> /var/log/nexus-cos/health-alerts.log
  fi
done
EOF

chmod +x /usr/local/bin/nexus-health-check.sh
```

### Add to Crontab

```bash
# Run health check every 5 minutes
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/nexus-health-check.sh") | crontab -
```

## 🏗️ Architecture Overview

### Port Mapping

| Component | Port | Protocol | Description |
|-----------|------|----------|-------------|
| Nginx HTTP | 80 | HTTP | Redirects to HTTPS |
| Nginx HTTPS | 443 | HTTPS | Main gateway |
| Backend API | 3000 | HTTP | Main API service |
| Streaming Service | 3028 | HTTP | Streaming platform |
| PUABO Core Adapter | 7777 | HTTP | Banking API |
| Apache Fineract | 8880 | HTTP | Core banking |
| PostgreSQL | 5434 | TCP | Database |
| Redis | 6379 | TCP | Cache/messaging |

### Service Groups

1. **PM2 Services** (52 services on ports 3000-3051)
2. **PUABO Core** (Docker: ports 7777, 8880, 5434, 6379)
3. **Infrastructure** (Nginx, Plesk, PM2, Docker)

### Data Flow

```
Internet → Nginx (443) → Routes:
  ├─ / → 301 redirect → /streaming/
  ├─ /api/ → Backend API (3000)
  ├─ /streaming/ → Streaming Service (3028)
  ├─ /socket.io/ → Backend API Socket.IO (3000)
  ├─ /streaming/socket.io/ → Streaming Socket.IO (3028)
  └─ /puabo/ → PUABO Core Adapter (7777)
```

## 🔐 Security Features

- ✅ **SSL/TLS**: IONOS certificates with TLS 1.2/1.3
- ✅ **Security Headers**: HSTS, X-Frame-Options, X-Content-Type-Options
- ✅ **Environment Variables**: Secure storage, not in repository
- ✅ **Firewall**: Only necessary ports exposed
- ✅ **Process Isolation**: Services run in separate processes/containers
- ✅ **Log Rotation**: Automatic log management

## 📚 Additional Resources

- **Deployment Manifest**: `DEPLOYMENT_MANIFEST.json`
- **PUABO Core Guide**: `nexus-cos/puabo-core/DEPLOYMENT_GUIDE.md`
- **Repository**: https://github.com/BobbyBlanco400/nexus-cos
- **Deployment Logs**: `/var/log/nexus-cos/`

## 🎯 Success Criteria

✅ All 5 endpoints responding with correct status codes  
✅ SSL certificate valid and properly configured  
✅ PM2 showing all services online  
✅ Docker containers running and healthy  
✅ PUABO Core health check passing  
✅ Nginx routing working correctly  
✅ Socket.IO connections working  
✅ No errors in logs  

## 🚀 Next Steps After Deployment

1. **DNS Configuration**: Ensure `n3xuscos.online` → `74.208.155.161`
2. **Automated Backups**: Set up daily backups
3. **External Monitoring**: Configure UptimeRobot or Pingdom
4. **Alerts**: Set up email/SMS alerts for downtime
5. **Performance Tuning**: Optimize based on traffic
6. **Documentation**: Document customizations
7. **Load Testing**: Test with expected traffic
8. **CDN Setup**: Configure CDN for static assets

## 📞 Support

For issues during deployment:
1. Check deployment log: `/var/log/nexus-cos/deployment-*.log`
2. Review troubleshooting section above
3. Check service logs (PM2, Docker, Nginx)
4. Verify system resources (RAM, disk, CPU)

---

**Deployment Information:**
- **Version**: 1.0.0
- **Deployment ID**: nexus-cos-production-v1.0.0
- **Framework**: PF-v2025.10.11
- **Method**: VPS_PLESK_NGINX
- **Operator**: TRAE_SOLO
- **Status**: ✅ PRODUCTION READY

---

## 🎉 Quick Command Reference

```bash
# Deploy
ssh root@74.208.155.161 'curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/deploy-nexus-cos-vps-master.sh | bash'

# Check status
pm2 status && docker ps

# View logs
pm2 logs

# Restart all
pm2 restart all

# Health check
curl https://n3xuscos.online/api/
```

---

**🎉 Your Nexus COS Platform Stack is ready for production deployment!** 🚀
