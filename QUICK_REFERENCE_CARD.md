# 🚀 Nexus COS Platform Stack - Quick Reference Card

## ⚡ ONE-COMMAND DEPLOYMENT

```bash
ssh root@74.208.155.161 'curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/deploy-nexus-cos-vps-master.sh | bash'
```

**OR**

```bash
./SSH_QUICK_DEPLOY.sh
```

---

## 📋 Deployment Info

| Item | Value |
|------|-------|
| **Deployment ID** | nexus-cos-production-v1.0.0 |
| **Domain** | nexuscos.online |
| **VPS IP** | 74.208.155.161 |
| **Services** | 52 microservices |
| **Modules** | 43 modules |
| **Time** | ~20-25 minutes |
| **Status** | ✅ READY |

---

## 🔗 Endpoints After Deployment

| Endpoint | URL | Status |
|----------|-----|--------|
| Root | `https://nexuscos.online/` | 301 → /streaming/ |
| API | `https://nexuscos.online/api/` | 200 |
| Streaming | `https://nexuscos.online/streaming/` | 200 |
| Socket.IO | `https://nexuscos.online/socket.io/...` | 200 |
| Socket.IO Streaming | `https://nexuscos.online/streaming/socket.io/...` | 200 |
| PUABO Core | `http://localhost:7777/health` | 200 |

---

## ✅ Pre-Deployment Checklist

```bash
# Run validation
./validate-deployment-ready.sh
```

**Prerequisites:**
- [ ] SSH access: `ssh root@74.208.155.161`
- [ ] SSL certificates in `/root/ionos/`
- [ ] 8GB RAM minimum
- [ ] 20GB disk space
- [ ] Docker, Node.js, PM2, Nginx, Git (auto-installed)

---

## 🔧 Post-Deployment Commands

### Check Status
```bash
ssh root@74.208.155.161 'pm2 status'
ssh root@74.208.155.161 'docker ps'
ssh root@74.208.155.161 'systemctl status nginx'
```

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

### Restart Services
```bash
# All PM2 services
ssh root@74.208.155.161 'pm2 restart all'

# Nginx
ssh root@74.208.155.161 'systemctl restart nginx'

# Docker services
ssh root@74.208.155.161 'cd /var/www/nexus-cos && docker compose -f docker-compose.unified.yml restart'

# PUABO Core
ssh root@74.208.155.161 'cd /var/www/nexus-cos/nexus-cos/puabo-core && docker compose -f docker-compose.core.yml restart'
```

---

## 🧪 Test Endpoints

```bash
# Root redirect
curl -I https://nexuscos.online/

# API
curl https://nexuscos.online/api/

# Streaming
curl https://nexuscos.online/streaming/

# Socket.IO
curl "https://nexuscos.online/socket.io/?EIO=4&transport=polling"

# PUABO Core
curl http://localhost:7777/health
```

---

## 🔍 Troubleshooting

### Services not starting
```bash
ssh root@74.208.155.161 'pm2 logs --err'
```

### Nginx errors
```bash
ssh root@74.208.155.161 'nginx -t && tail -f /var/log/nginx/error.log'
```

### PUABO Core issues
```bash
ssh root@74.208.155.161 'cd /var/www/nexus-cos/nexus-cos/puabo-core && docker compose -f docker-compose.core.yml logs -f'
```

### Port conflicts
```bash
ssh root@74.208.155.161 'lsof -i :3000 && lsof -i :7777'
```

---

## 🔄 Rollback

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

- **Quick Start**: `DEPLOYMENT_README.md`
- **Complete Guide**: `VPS_DEPLOYMENT_MASTER_GUIDE.md`
- **Manifest**: `DEPLOYMENT_MANIFEST.json`
- **PUABO Core**: `nexus-cos/puabo-core/DEPLOYMENT_GUIDE.md`

---

## 🏗️ What Gets Deployed

### Services (52)
Backend API, Streaming, AI, Auth, PUABO DSP/BLAC/Nexus/NUKI, V-Suite, Analytics, Chat, and more...

### Modules (43)
Urban Family (11), V-Suite, Gaming, Entertainment, Family, NexusNet, etc.

### PUABO Core
Apache Fineract, PUABO Adapter (7777), Smart Contracts, PostgreSQL, Redis

### Infrastructure
Nginx + SSL (IONOS), PM2, Docker, Plesk

---

## ⏱️ Deployment Timeline

1. **Pre-checks** (2 min) - System verification
2. **Repository** (3 min) - Clone and setup
3. **PUABO Core** (5 min) - Banking platform
4. **Services** (8 min) - 52 microservices
5. **Nginx + SSL** (2 min) - Reverse proxy
6. **Health Checks** (3 min) - Validation
7. **Summary** (1 min) - Status display

**Total: ~25 minutes**

---

## 🎯 Success Criteria

After deployment:
- ✅ All 5 endpoints respond correctly
- ✅ SSL certificate valid
- ✅ PM2 services online
- ✅ Docker containers running
- ✅ PUABO Core healthy
- ✅ Socket.IO working
- ✅ No errors in logs

---

## 📞 Quick Links

- **Repository**: https://github.com/BobbyBlanco400/nexus-cos
- **Logs**: `/var/log/nexus-cos/`
- **Deployment Dir**: `/var/www/nexus-cos`

---

## 🚨 Emergency Commands

### Stop Everything
```bash
ssh root@74.208.155.161 'pm2 stop all && systemctl stop nginx'
```

### Start Everything
```bash
ssh root@74.208.155.161 'pm2 start all && systemctl start nginx'
```

### Check Resources
```bash
ssh root@74.208.155.161 'free -h && df -h'
```

---

**Version**: 1.0.0  
**Framework**: PF-v2025.10.11  
**Operator**: TRAE_SOLO  
**Status**: ✅ PRODUCTION READY

---

## 🎉 Ready to Deploy!

Run the validation first:
```bash
./validate-deployment-ready.sh
```

Then deploy:
```bash
./SSH_QUICK_DEPLOY.sh
```

**Your complete Nexus COS Platform Stack will be live in ~25 minutes!** 🚀
