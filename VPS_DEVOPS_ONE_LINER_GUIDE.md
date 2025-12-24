# Nexus COS - VPS SSH One-Liner Deployment Guide
## DevOps Engineering Grade | Based on PRs #174 #175 #176 #177 #178

**Last Updated:** 2025-12-24  
**Version:** 2025.1.0  
**Status:** ✅ PRODUCTION READY  
**Deployment Mode:** Zero-Downtime Overlay  
**Architecture:** DevOps Engineering Grade

---

## 🎯 The Bulletproofed One-Liner

This single command deploys the complete Nexus COS platform with all features from PRs #174-178.

### Option 1: Direct SSH Execution (Recommended for VPS)

```bash
# The Ultimate One-Liner: SSH + Clone + Deploy + Verify
ssh root@YOUR_VPS_IP "curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/VPS_BULLETPROOF_ONE_LINER.sh | sudo bash -s"
```

**Replace `YOUR_VPS_IP` with your actual server IP address.**

### Option 2: Local Wrapper Script (Alternative)

```bash
# Clone repository first
git clone https://github.com/BobbyBlanco400/nexus-cos.git
cd nexus-cos

# Run deployment script
sudo ./VPS_BULLETPROOF_ONE_LINER.sh
```

### Option 3: Manual Download + Execute

```bash
# Download script
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/VPS_BULLETPROOF_ONE_LINER.sh -o deploy.sh

# Make executable
chmod +x deploy.sh

# Execute
sudo ./deploy.sh
```

---

## 📋 What This One-Liner Deploys

### From PR #174: Expansion Layer
- **Jurisdiction Engine**: Runtime toggle for US/EU/ASIA/GLOBAL compliance
- **Marketplace Phase 2**: Asset preview mode (avatars, VR items, cosmetics)
- **AI Dealer Expansion**: PUABO AI-HF personalities for blackjack/poker/roulette
- **Casino Federation**: Multi-casino Vegas Strip architecture
- **Configuration Files**: `config/jurisdiction-engine.yaml`, `config/marketplace-phase2.yaml`, `config/ai-dealers.yaml`, `config/casino-federation.yaml`

### From PR #175: Feature Flags & NexCoin Documentation
- **Feature Flag System**: Hot-reload configuration overlay
- **Canonical NexCoin Model**: Locked language for regulators/investors
- **Compliance Framework**: Runtime region filtering
- **DevOps Enforcement**: Pre-launch verification checklist
- **Architecture Diagrams**: 5 regulator-ready compliance flows

### From PR #176: Casino Nexus Core Add-In
- **NexCoin Enforcement**: Mandatory balance checks (`requireNexCoin()`)
- **Progressive Engine**: Utility-only rewards with 1.5% contribution
- **High Roller Suite**: VIP access with 5K NexCoin minimum
- **Wallet Locking**: Atomic transaction operations
- **Dealer AI Router**: Jurisdiction-aware AI assignment
- **TypeScript Package**: 15 modules, 4,676 LOC in `/addons/casino-nexus-core/`

### From PR #177: Global Launch & Onboarding
- **Nation-by-Nation Rollout**: US/EU/ASIA feature flags
- **Celebrity/Creator Nodes**: 4 nodes with dual branding
- **Investor Demo Environment**: Read-only with frozen wallet
- **Rollout Phases**: Founders (7d) → Creators (14d) → Public
- **Access Rights**: VIP exclusive events, streaming tools, cosmetic sales

### From PR #178: Database Auth Fix & Founder Access Keys
- **Database Users**: `nexus_user` and `nexuscos` with shared connection pool
- **11 Founder Access Keys**:
  - 1x Super Admin (`admin_nexus`) - UNLIMITED balance
  - 2x VIP Whales (`vip_whale_01`, `vip_whale_02`) - 1,000,000 NC each
  - 8x Beta Founders (`beta_tester_01` to `beta_tester_08`) - 50,000 NC each
- **PWA Infrastructure**: Offline-first with service worker
- **PF Verification System**: Last 10 PFs reconciliation
- **Total Pre-loaded**: 2,400,000 NC + UNLIMITED

---

## 🚀 Features of This One-Liner

### DevOps Engineering Grade
- **Lock Management**: Prevents concurrent deployments
- **Comprehensive Logging**: Timestamped logs to `/var/log/nexus-cos/deploy-*.log`
- **Color-Coded Output**: Green (success), Red (error), Yellow (warning), Blue (info)
- **Error Handling**: Auto-diagnostic collection on failure
- **Health Checks**: 120-second validation window with port checking
- **Git Ops**: Automatic stashing, fetching, resetting
- **Prerequisite Validation**: OS check, sudo/root, Docker daemon, disk space (10GB min), memory (4GB min)

### Zero-Downtime Guarantees
- ❌ **NO** core service rebuilds
- ❌ **NO** wallet resets or data loss
- ❌ **NO** DNS changes or SSL disruption
- ❌ **NO** database schema migrations (overlay-only)
- ✅ **Overlay-only** configuration deployment
- ✅ **Instant rollback** via feature flags
- ✅ **Atomic transactions** with wallet locking
- ✅ **Hot-reload configs** without restarts

### Monitoring & Diagnostics
- Real-time deployment progress with ASCII banners
- Service-by-service health check status
- Docker container status table
- Automatic diagnostic collection on failure:
  - Docker container status
  - Last 50 lines of logs
  - System resource utilization (disk, memory)
- Detailed deployment metrics report

---

## 🔒 Security & Compliance

### Database Credentials (PR #178)
```bash
Database User:     nexus_user
Database Password: nexus_secure_password_2025
Database Name:     nexus_cos
PostgreSQL Port:   5432
```

**⚠️ Change these credentials immediately in production!**

### Founder Access Keys
| Account | Role | Balance | Password |
|---------|------|---------|----------|
| `admin_nexus` | Super Admin | UNLIMITED | `admin_nexus_2025` |
| `vip_whale_01` | VIP | 1,000,000 NC | `WelcomeToVegas_25` |
| `vip_whale_02` | VIP | 1,000,000 NC | `WelcomeToVegas_25` |
| `beta_tester_01-08` | Beta Founder | 50,000 NC each | `WelcomeToVegas_25` |

**⚠️ Change all default passwords before public launch!**

### NexCoin Compliance (PR #175)
- **Closed-Loop**: No fiat withdrawals
- **Utility-Only**: Not a currency or security
- **No Gambling**: Skill-based entertainment platform
- **No Money Transmission**: Internal credits only
- **Regulator-Ready**: 5 defensive architecture diagrams

---

## 🌐 Service Endpoints

After successful deployment, access these endpoints:

| Service | Port | URL |
|---------|------|-----|
| Frontend | 3000 | http://YOUR_VPS_IP:3000 |
| Gateway API | 4000 | http://YOUR_VPS_IP:4000 |
| Casino Nexus | 9503 | http://YOUR_VPS_IP:9503 |
| Skill Games | 9505 | http://YOUR_VPS_IP:9505 |
| Streaming Service | 9501 | http://YOUR_VPS_IP:9501 |
| Admin Portal | 9504 | http://YOUR_VPS_IP:9504 |
| PUABO AI SDK | 3002 | http://YOUR_VPS_IP:3002 |
| PV Keys | 3041 | http://YOUR_VPS_IP:3041 |
| PostgreSQL | 5432 | localhost:5432 |
| Redis | 6379 | localhost:6379 |

---

## 📊 Deployment Process

The one-liner executes these steps in order:

1. **Lock Acquisition** - Prevents concurrent deployments
2. **Prerequisite Validation** - Checks OS, sudo, Docker, disk, memory
3. **Repository Management** - Clone or update from GitHub
4. **Environment Configuration** - Creates `.env` with credentials
5. **Docker Stack Deployment** - Pulls images and starts containers
6. **Health Check Validation** - 120-second comprehensive verification
7. **Summary Report** - Deployment metrics and next steps
8. **Lock Release** - Cleanup and final logging

**Estimated Time:** 3-5 minutes (depending on network speed)

---

## 🔍 Monitoring Deployment

### View Live Logs
```bash
# SSH into your VPS
ssh root@YOUR_VPS_IP

# Monitor deployment log (real-time)
tail -f /var/log/nexus-cos/deploy-*.log

# Or view Docker logs
cd /opt/nexus-cos
docker compose logs -f
```

### Check Service Status
```bash
# Docker container status
docker compose ps

# Individual service logs
docker compose logs frontend
docker compose logs postgres
docker compose logs casino-nexus

# Health check specific service
nc -zv localhost 3000  # Frontend
nc -zv localhost 5432  # PostgreSQL
```

---

## 🛠 Troubleshooting

### Deployment Fails with "Lock Already Acquired"
```bash
# Remove stale lock file
sudo rm -f /var/lock/nexus-cos-deploy.lock

# Try deployment again
sudo ./VPS_BULLETPROOF_ONE_LINER.sh
```

### Docker Daemon Not Running
```bash
# Start Docker
sudo systemctl start docker

# Enable Docker on boot
sudo systemctl enable docker

# Verify Docker is running
docker info
```

### Insufficient Disk Space
```bash
# Check available space
df -h /

# Clean up Docker (WARNING: removes stopped containers, unused images)
docker system prune -a --volumes

# Or expand VPS disk via provider control panel
```

### Health Checks Failing
```bash
# Check which services are failing
docker compose ps

# Restart specific service
docker compose restart frontend

# Check service logs for errors
docker compose logs --tail=100 frontend
```

### Database Connection Issues
```bash
# Check PostgreSQL is running
docker compose ps postgres

# Test database connection
docker exec -it nexus-postgres psql -U nexus_user -d nexus_cos -c "SELECT 1;"

# Reset database password if needed
docker exec -it nexus-postgres psql -U postgres -c "ALTER USER nexus_user PASSWORD 'new_password';"
```

---

## 🔄 Rolling Back Deployment

### Quick Rollback (Feature Flags)
```bash
# SSH into VPS
ssh root@YOUR_VPS_IP

# Edit feature flags (instant effect)
cd /opt/nexus-cos
nano config/features.json

# Set all enabled flags to false
# Restart services if needed
docker compose restart
```

### Full Rollback (Git Reset)
```bash
# SSH into VPS
ssh root@YOUR_VPS_IP
cd /opt/nexus-cos

# View recent commits
git log --oneline -10

# Reset to specific commit
git reset --hard COMMIT_HASH

# Redeploy
docker compose up -d --remove-orphans
```

---

## 📈 Post-Deployment Steps

### 1. Verify All Services
```bash
curl -I http://YOUR_VPS_IP:3000  # Frontend
curl -I http://YOUR_VPS_IP:4000  # Gateway
curl http://YOUR_VPS_IP:9503/health  # Casino health
```

### 2. Change Default Passwords
```bash
# Connect to database
docker exec -it nexus-postgres psql -U nexus_user -d nexus_cos

# Update passwords for founder accounts
UPDATE users SET password_hash = crypt('YOUR_NEW_PASSWORD', gen_salt('bf'))
WHERE username IN ('admin_nexus', 'vip_whale_01', 'vip_whale_02');
```

### 3. Configure SSL/TLS (Production)
```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal
sudo certbot renew --dry-run
```

### 4. Set Up Firewall
```bash
# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow specific service ports
sudo ufw allow 3000/tcp  # Frontend
sudo ufw allow 4000/tcp  # Gateway

# Enable firewall
sudo ufw enable
```

### 5. Enable Feature Flags
```bash
# Edit feature configuration
nano /opt/nexus-cos/config/features.json

# Enable desired features (example)
{
  "jurisdiction_engine": {"enabled": true},
  "marketplace_phase2": {"enabled": true},
  "ai_dealers": {"enabled": true}
}

# Restart services to apply
docker compose restart
```

---

## 📞 Support & Documentation

### Additional Resources
- **Full Documentation**: `/opt/nexus-cos/README.md`
- **PF Index**: `/opt/nexus-cos/PF_MASTER_INDEX.md`
- **Deployment Log**: `/var/log/nexus-cos/deploy-*.log`
- **Docker Logs**: `docker compose logs`
- **GitHub Repository**: https://github.com/BobbyBlanco400/nexus-cos

### Key Documentation Files
- `FOUNDER_ACCESS_KEYS.md` - Complete list of access keys
- `PF_VERIFICATION_SYSTEM_README.md` - PF reconciliation system
- `QUICK_EXECUTION_GUIDE.md` - Quick reference for TRAE SOLO CODER
- `README_TRAE_SOLO_FIX.md` - Master execution guide
- `EXECUTION_SUMMARY.md` - Quick deployment summary

---

## ✅ Success Checklist

After running the one-liner, verify:

- [ ] All Docker containers are running (`docker compose ps`)
- [ ] Frontend accessible at port 3000
- [ ] Gateway API accessible at port 4000
- [ ] Database connection working (`docker exec -it nexus-postgres psql -U nexus_user -d nexus_cos -c "SELECT 1;"`)
- [ ] 11 Founder Access Keys created in database
- [ ] PWA manifest accessible at `/manifest.json`
- [ ] Deployment log created in `/var/log/nexus-cos/`
- [ ] No errors in Docker logs (`docker compose logs --tail=50`)
- [ ] Health checks passing for all services
- [ ] Feature flags configuration exists at `/opt/nexus-cos/config/features.json`

---

## 🎉 You're Done!

The Nexus COS platform is now deployed with all features from PRs #174-178!

**Next:** Test the platform, change default passwords, configure SSL, and enable features as needed.

---

**DevOps Engineering Grade | Zero Downtime | Production Ready**
