# 🚀 VPS One-Liner Deployment - START HERE

## The Bulletproofed Command

```bash
ssh root@72.62.86.217 "curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/VPS_BULLETPROOF_ONE_LINER.sh | sudo bash -s"
```

**Replace `YOUR_VPS_IP` with your actual server IP address.**

---

## 📖 Documentation

Choose your documentation level:

### ⚡ Quick Start (30 seconds)
**File:** `VPS_ONE_LINER_QUICK_REF.md`  
One-page quick reference with copy-paste commands.

### 📚 Comprehensive Guide (Complete)
**File:** `VPS_DEVOPS_ONE_LINER_GUIDE.md`  
Full 12KB guide with troubleshooting, rollback, and security.

### 📊 Executive Summary (Overview)
**File:** `VPS_ONE_LINER_FINAL_SUMMARY.md`  
Complete mission summary with all deliverables and features.

---

## ✅ What This Deploys

All features from PRs **#174 #175 #176 #177 #178**:

- ✓ Jurisdiction Engine (US/EU/ASIA/GLOBAL runtime toggle)
- ✓ Marketplace Phase 2 (asset preview mode)
- ✓ AI Dealer Expansion (PUABO AI-HF personalities)
- ✓ Casino Federation (multi-casino Vegas strip)
- ✓ Feature Flag System (hot-reload config)
- ✓ NexCoin Enforcement (balance checks)
- ✓ Progressive Engine (utility rewards)
- ✓ High Roller Suite (VIP access)
- ✓ Celebrity/Creator Nodes (dual branding)
- ✓ Database Auth Fix (shared connection pool)
- ✓ 11 Founder Access Keys (pre-loaded balances)
- ✓ PWA Infrastructure (offline-first)
- ✓ PF Verification System (reconciliation)

---

## ⏱️ Deployment Time

**3-5 minutes** from start to finish

---

## 🔒 Default Credentials (MUST CHANGE)

### Database
```
User:     nexus_user
Password: nexus_secure_password_2025
Database: nexus_cos
```

### Founder Access Keys
```
Admin:       admin_nexus (UNLIMITED)
VIP Whales:  vip_whale_01, vip_whale_02 (1M NC each)
Beta:        beta_tester_01 to 08 (50K NC each)
Password:    WelcomeToVegas_25
```

---

## 🌐 Service Endpoints

After deployment, access:

```
Frontend:     http://YOUR_VPS_IP:3000
Gateway API:  http://YOUR_VPS_IP:4000
Casino:       http://YOUR_VPS_IP:9503
Streaming:    http://YOUR_VPS_IP:9501
Admin:        http://YOUR_VPS_IP:9504
```

---

## 🛠 Quick Troubleshooting

### Deployment Failed?
```bash
# Check logs
cat /var/log/nexus-cos/deploy-*.log

# Remove lock and retry
sudo rm -f /var/lock/nexus-cos-deploy.lock
```

### Service Not Starting?
```bash
# Check status
docker compose ps

# View logs
docker compose logs SERVICE_NAME

# Restart
docker compose restart
```

---

## 📞 Need Help?

1. **Read:** `VPS_DEVOPS_ONE_LINER_GUIDE.md` (comprehensive troubleshooting)
2. **Check:** `/var/log/nexus-cos/deploy-*.log` (deployment logs)
3. **View:** `docker compose logs` (service logs)

---

## ✅ Success Checklist

- [ ] One-liner executed without errors
- [ ] All services running (`docker compose ps`)
- [ ] Frontend accessible (port 3000)
- [ ] Deployment log created
- [ ] Change default passwords

---

**Status:** ✅ PRODUCTION READY  
**Architecture:** DevOps Engineering Grade  
**Zero Downtime:** YES  
**Version:** 2025.1.0
