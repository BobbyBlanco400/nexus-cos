# 🚀 Nexus COS Platform Stack - Production Deployment

**Status**: ✅ READY FOR DEPLOYMENT  
**Deployment ID**: nexus-cos-production-v1.0.0  
**Domain**: n3xuscos.online  
**VPS IP**: 74.208.155.161  
**Certification**: TIER_1_PRODUCTION  

---

## 🎯 One-Command Deployment

Deploy the complete Nexus COS Platform Stack to your VPS in one command:

```bash
ssh root@74.208.155.161 'curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/deploy-nexus-cos-vps-master.sh | bash'
```

**OR** use the quick deploy script:

```bash
./SSH_QUICK_DEPLOY.sh
```

---

## 📦 What Gets Deployed

### Complete Platform Stack

- ✅ **52 Microservices** (Backend API, Streaming, AI, Auth, PUABO services, V-Suite, etc.)
- ✅ **43 Modules** (Urban Family, V-Suite, Gaming, Entertainment, etc.)
- ✅ **PUABO Core** (Apache Fineract banking platform with Smart Contracts)
- ✅ **Nginx** (Reverse proxy with SSL/TLS)
- ✅ **Socket.IO** (Real-time communication endpoints)
- ✅ **Monitoring** (Health checks and alerts)

### Infrastructure

- **Web Server**: Nginx with IONOS SSL certificates
- **Process Manager**: PM2 for Node.js services
- **Containers**: Docker for PUABO Core and supporting services
- **Platform**: Plesk for domain management
- **SSL/TLS**: IONOS certificates with auto-configuration

---

## 📋 Key Files

| File | Description |
|------|-------------|
| `deploy-nexus-cos-vps-master.sh` | **Master deployment script** - Orchestrates entire deployment |
| `SSH_QUICK_DEPLOY.sh` | **Quick deploy wrapper** - One-command deployment helper |
| `DEPLOYMENT_MANIFEST.json` | **Deployment configuration** - All deployment settings and metadata |
| `VPS_DEPLOYMENT_MASTER_GUIDE.md` | **Complete guide** - Detailed deployment documentation |
| `nexus-cos/puabo-core/deploy-puabo-core.sh` | **PUABO Core deployment** - Banking platform deployment |

---

## 🔑 Prerequisites

### Access Required

```bash
ssh root@74.208.155.161
```

### SSL Certificates (Already in place)

- Private Key: `/root/ionos/privkey.pem`
- Certificate: `/root/ionos/cert.pem`
- CA Chain: `/root/ionos/chain.pem`

### System Requirements

- **RAM**: 8GB minimum (16GB recommended)
- **Disk**: 20GB minimum free space
- **OS**: Ubuntu 20.04+ or Debian 11+

### Software (Auto-installed)

- Docker 20.10+
- Docker Compose 2.0+
- Node.js 20.x
- PM2
- Nginx
- Git

---

## 🚀 Deployment Steps

### Step 1: Review Deployment Manifest

Check `DEPLOYMENT_MANIFEST.json` for deployment configuration:

```bash
cat DEPLOYMENT_MANIFEST.json
```

### Step 2: Run Deployment

Choose one of these methods:

#### Method A: One-Command (Recommended)

```bash
ssh root@74.208.155.161 'curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/deploy-nexus-cos-vps-master.sh | bash'
```

#### Method B: Using Quick Deploy Script

```bash
./SSH_QUICK_DEPLOY.sh
```

#### Method C: Manual SSH

```bash
# SSH into server
ssh root@74.208.155.161

# Run deployment
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/deploy-nexus-cos-vps-master.sh | bash
```

### Step 3: Monitor Progress

Watch the deployment progress. The script will:

1. ✅ Check system requirements (2 min)
2. ✅ Clone repository (3 min)
3. ✅ Deploy PUABO Core (5 min)
4. ✅ Deploy microservices (8 min)
5. ✅ Configure Nginx + SSL (2 min)
6. ✅ Run health checks (3 min)
7. ✅ Display summary (1 min)

**Total Time**: ~20-25 minutes

### Step 4: Verify Deployment

After deployment completes, test endpoints:

```bash
# Test root redirect
curl -I https://n3xuscos.online/

# Test API
curl https://n3xuscos.online/api/

# Test streaming
curl https://n3xuscos.online/streaming/

# Test Socket.IO
curl "https://n3xuscos.online/socket.io/?EIO=4&transport=polling"

# Test PUABO Core
curl http://localhost:7777/health
```

---

## 📊 Expected Endpoints

| Endpoint | URL | Status | Description |
|----------|-----|--------|-------------|
| **Root** | `https://n3xuscos.online/` | 301 | Redirects to `/streaming/` |
| **API** | `https://n3xuscos.online/api/` | 200 | Main API endpoint |
| **Streaming** | `https://n3xuscos.online/streaming/` | 200 | Streaming service |
| **Socket.IO Main** | `https://n3xuscos.online/socket.io/...` | 200 | Real-time communication |
| **Socket.IO Streaming** | `https://n3xuscos.online/streaming/socket.io/...` | 200 | Real-time streaming |
| **PUABO Core** | `https://n3xuscos.online/puabo/` | 200 | Banking API |

---

## 🔧 Post-Deployment Commands

### View Logs

```bash
# Deployment log
ssh root@74.208.155.161 'tail -f /var/log/nexus-cos/deployment-*.log'

# PM2 services
ssh root@74.208.155.161 'pm2 logs'

# Docker services
ssh root@74.208.155.161 'cd /var/www/nexus-cos && docker compose -f docker-compose.unified.yml logs -f'

# PUABO Core
ssh root@74.208.155.161 'cd /var/www/nexus-cos/nexus-cos/puabo-core && docker compose -f docker-compose.core.yml logs -f'
```

### Check Status

```bash
# PM2 services
ssh root@74.208.155.161 'pm2 status'

# Docker containers
ssh root@74.208.155.161 'docker ps'

# Nginx
ssh root@74.208.155.161 'systemctl status nginx'
```

### Restart Services

```bash
# Restart all PM2 services
ssh root@74.208.155.161 'pm2 restart all'

# Restart Nginx
ssh root@74.208.155.161 'systemctl restart nginx'

# Restart Docker services
ssh root@74.208.155.161 'cd /var/www/nexus-cos && docker compose -f docker-compose.unified.yml restart'
```

---

## 🏗️ Architecture

### Service Layers

```
┌─────────────────────────────────────────────────────────────┐
│                      Internet (HTTPS)                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Nginx (SSL/TLS Termination)                     │
│  • Port 80 → 443 redirect                                   │
│  • Port 443 → SSL with IONOS certificates                   │
└────────────────────────┬────────────────────────────────────┘
                         │
            ┌────────────┴────────────┐
            ▼                         ▼
┌─────────────────────┐   ┌─────────────────────┐
│   PM2 Services      │   │   Docker Services   │
│   (52 services)     │   │   (PUABO Core)      │
│                     │   │                     │
│ • Backend API:3000  │   │ • Adapter:7777      │
│ • Streaming:3028    │   │ • Fineract:8880     │
│ • Auth:3034         │   │ • PostgreSQL:5434   │
│ • AI:3001           │   │ • Redis:6379        │
│ • V-Suite:3037-3040 │   │ • Smart Contracts   │
│ • And 47 more...    │   │                     │
└─────────────────────┘   └─────────────────────┘
```

### Routing

```
https://n3xuscos.online/
  ├─ / → 301 redirect → /streaming/
  ├─ /api/ → Backend API (3000)
  ├─ /streaming/ → Streaming Service (3028)
  ├─ /socket.io/ → Backend API Socket.IO (3000)
  ├─ /streaming/socket.io/ → Streaming Socket.IO (3028)
  └─ /puabo/ → PUABO Core Adapter (7777)
```

---

## 📈 Monitoring

### Health Check Endpoints

```bash
# Main API health
curl https://n3xuscos.online/api/health

# Streaming health
curl https://n3xuscos.online/streaming/health

# PUABO Core health
curl http://localhost:7777/health
```

### Automated Monitoring

The deployment includes automated health checks every 5 minutes for:
- API endpoint
- Streaming endpoint
- Socket.IO endpoints
- PUABO Core

---

## 🔐 Security

- ✅ **SSL/TLS**: IONOS certificates with TLS 1.2/1.3
- ✅ **Security Headers**: HSTS, X-Frame-Options, X-Content-Type-Options, X-XSS-Protection
- ✅ **HTTPS Only**: HTTP automatically redirects to HTTPS
- ✅ **Secure Proxying**: Proper headers for proxied requests
- ✅ **Environment Variables**: Sensitive data in `.env` files (not in repository)

---

## 🔍 Troubleshooting

### Common Issues

#### Services not starting
```bash
ssh root@74.208.155.161 'pm2 logs --err'
```

#### Nginx errors
```bash
ssh root@74.208.155.161 'nginx -t && tail -f /var/log/nginx/error.log'
```

#### PUABO Core issues
```bash
ssh root@74.208.155.161 'cd /var/www/nexus-cos/nexus-cos/puabo-core && docker compose -f docker-compose.core.yml logs -f'
```

#### Port conflicts
```bash
ssh root@74.208.155.161 'lsof -i :3000 && lsof -i :7777'
```

For detailed troubleshooting, see: `VPS_DEPLOYMENT_MASTER_GUIDE.md`

---

## 🔄 Rollback

If deployment fails, automatic backup is created:

```bash
ssh root@74.208.155.161 'ls -la /var/www/nexus-cos-backup-*'
```

To rollback:

```bash
ssh root@74.208.155.161 '
  pm2 stop all &&
  cd /var/www &&
  mv nexus-cos nexus-cos-failed &&
  mv nexus-cos-backup-YYYYMMDD-HHMMSS nexus-cos &&
  pm2 restart all
'
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **VPS_DEPLOYMENT_MASTER_GUIDE.md** | Complete deployment guide with troubleshooting |
| **DEPLOYMENT_MANIFEST.json** | Deployment configuration and metadata |
| **nexus-cos/puabo-core/DEPLOYMENT_GUIDE.md** | PUABO Core specific documentation |
| **nexus-cos/puabo-core/README.md** | PUABO Core overview |

---

## 🎉 Success Criteria

After deployment, verify:

- ✅ All 5 endpoints return correct HTTP status codes
- ✅ SSL certificate is valid and trusted
- ✅ PM2 shows all services online
- ✅ Docker containers are running
- ✅ PUABO Core health check passes
- ✅ Socket.IO connections work
- ✅ No errors in logs

---

## 🚀 Next Steps After Deployment

1. **DNS**: Verify `n3xuscos.online` → `74.208.155.161`
2. **Monitoring**: Set up external monitoring (UptimeRobot, Pingdom)
3. **Backups**: Configure automated daily backups
4. **Alerts**: Set up email/SMS alerts for downtime
5. **Testing**: Perform load testing
6. **CDN**: Configure CDN for static assets
7. **Documentation**: Document any customizations

---

## 📞 Support

- **Deployment Log**: `/var/log/nexus-cos/deployment-*.log`
- **Repository**: https://github.com/BobbyBlanco400/nexus-cos
- **Documentation**: See `VPS_DEPLOYMENT_MASTER_GUIDE.md`

---

## 📝 Deployment Information

```json
{
  "deployment_id": "nexus-cos-production-v1.0.0",
  "domain": "n3xuscos.online",
  "vps_ip": "74.208.155.161",
  "certification": "TIER_1_PRODUCTION",
  "framework": "PF-v2025.10.11",
  "operator": "TRAE_SOLO",
  "services": 52,
  "modules": 43,
  "status": "READY_FOR_DEPLOYMENT"
}
```

---

**🎯 Your Nexus COS Platform Stack is ready to deploy!**

Run the deployment command and your complete platform will be live in ~25 minutes! 🚀

---

**Last Updated**: 2025-12-11  
**Version**: 1.0.0  
**Status**: ✅ PRODUCTION READY
