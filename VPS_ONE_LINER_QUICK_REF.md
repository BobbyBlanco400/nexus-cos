# 🚀 NEXUS COS - VPS ONE-LINER QUICK REFERENCE
## DevOps Engineering Grade | Zero Downtime | PRs #174-178

---

## ⚡ THE ONE-LINER (Copy & Paste)

```bash
ssh root@YOUR_VPS_IP "curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/VPS_BULLETPROOF_ONE_LINER.sh | sudo bash -s"
```

**Replace `YOUR_VPS_IP` with your server IP address.**

---

## 📋 WHAT IT DOES

### ✅ Validates
- OS compatibility
- Sudo/root access
- Docker daemon running
- 10GB+ disk space
- 4GB+ RAM
- Git, curl, nc, docker installed

### ✅ Deploys
- **PR #174**: Jurisdiction Engine, Marketplace Phase 2, AI Dealers, Casino Federation
- **PR #175**: Feature Flags, NexCoin Documentation, Compliance Framework
- **PR #176**: NexCoin Enforcement, Progressive Engine, High Roller Suite, Wallet Locking
- **PR #177**: Global Launch, Celebrity/Creator Nodes, Nation-by-Nation Rollout
- **PR #178**: Database Auth Fix, 11 Founder Access Keys, PWA, PF Verification

### ✅ Configures
- PostgreSQL (nexus_user/nexus_secure_password_2025)
- 11 Founder Access Keys (1 Admin UNLIMITED + 2 Whales + 8 Beta)
- Feature Flags (all disabled by default, Founder Beta enabled)
- Environment variables (.env with PR #178 credentials)

### ✅ Validates
- 10 services health check (120s window)
- Port connectivity (3000, 4000, 9503, 9501, 9504, 3002, 3041, 5432, 6379)
- Docker container status
- Service startup completion

---

## 🎯 POST-DEPLOYMENT (30 seconds)

### 1. Verify Services
```bash
ssh root@YOUR_VPS_IP
cd /opt/nexus-cos
docker compose ps
```

### 2. Check Frontend
```bash
curl -I http://YOUR_VPS_IP:3000
```

### 3. View Deployment Log
```bash
cat /var/log/nexus-cos/deploy-*.log
```

### 4. Monitor Live
```bash
docker compose logs -f
```

---

## 🔑 DEFAULT CREDENTIALS (⚠️ CHANGE IMMEDIATELY)

### Database
```
Host:     localhost
Port:     5432
Database: nexus_cos
User:     nexus_user
Password: nexus_secure_password_2025
```

### Founder Access Keys
| Account | Balance | Password |
|---------|---------|----------|
| admin_nexus | UNLIMITED | admin_nexus_2025 |
| vip_whale_01 | 1,000,000 NC | WelcomeToVegas_25 |
| vip_whale_02 | 1,000,000 NC | WelcomeToVegas_25 |
| beta_tester_01-08 | 50,000 NC | WelcomeToVegas_25 |

---

## 🌐 SERVICE ENDPOINTS

```
Frontend:        http://YOUR_VPS_IP:3000
Gateway API:     http://YOUR_VPS_IP:4000
Casino Nexus:    http://YOUR_VPS_IP:9503
Streaming:       http://YOUR_VPS_IP:9501
Admin Portal:    http://YOUR_VPS_IP:9504
PUABO AI SDK:    http://YOUR_VPS_IP:3002
```

---

## 🛠 TROUBLESHOOTING

### Deployment Stalled?
```bash
# Check if lock file exists
sudo rm -f /var/lock/nexus-cos-deploy.lock

# Re-run
ssh root@YOUR_VPS_IP "curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/VPS_BULLETPROOF_ONE_LINER.sh | sudo bash -s"
```

### Service Not Starting?
```bash
# Check logs
docker compose logs SERVICE_NAME

# Restart specific service
docker compose restart SERVICE_NAME

# Restart all
docker compose restart
```

### Health Check Failed?
```bash
# Check which port is failing
nc -zv localhost 3000
nc -zv localhost 5432

# View deployment log
tail -100 /var/log/nexus-cos/deploy-*.log
```

---

## 🔄 ROLLBACK

### Quick Rollback (Feature Flags)
```bash
ssh root@YOUR_VPS_IP
cd /opt/nexus-cos
nano config/features.json
# Set enabled: false for all features
docker compose restart
```

### Full Rollback (Git)
```bash
ssh root@YOUR_VPS_IP
cd /opt/nexus-cos
git log --oneline -10
git reset --hard COMMIT_HASH
docker compose up -d --remove-orphans
```

---

## 📊 DEPLOYMENT METRICS

- **Estimated Time**: 3-5 minutes
- **Services Deployed**: 10
- **Health Check Window**: 120 seconds
- **Disk Space Required**: 10GB minimum
- **RAM Required**: 4GB minimum
- **Zero Downtime**: ✅ Yes
- **Rollback Time**: < 30 seconds (feature flags)

---

## 📖 FULL DOCUMENTATION

- **Comprehensive Guide**: `VPS_DEVOPS_ONE_LINER_GUIDE.md`
- **PR Details**: PRs #174, #175, #176, #177, #178
- **Deployment Log**: `/var/log/nexus-cos/deploy-*.log`
- **Repository**: https://github.com/BobbyBlanco400/nexus-cos

---

## ✅ SUCCESS CHECKLIST

- [ ] One-liner executed without errors
- [ ] All 10 services healthy
- [ ] Frontend accessible (port 3000)
- [ ] Gateway API responding (port 4000)
- [ ] Database connection working
- [ ] 11 Founder Access Keys created
- [ ] Deployment log created
- [ ] No errors in Docker logs

---

## 🎉 YOU'RE DONE!

**The Nexus COS platform is deployed with all features from PRs #174-178!**

**Next:** Test platform → Change passwords → Configure SSL → Enable features

---

**DevOps Engineering Grade | Zero Downtime | Production Ready**  
**Version:** 2025.1.0 | **Last Updated:** 2025-12-24
