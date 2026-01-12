# Phase 4 Quick Reference Card

**Version:** 1.0.0 | **Target:** January 15, 2026 | **Status:** Audit-Ready

---

## 🚀 One-Line Deployment

```bash
cd /opt/nexus-cos && sudo ./deploy-phase-4-full-launch.sh
```

---

## 📋 Pre-Flight Checklist (30 seconds)

```bash
# Quick system check
sudo systemctl status docker nginx
df -h /opt/nexus-cos
free -h
docker ps
```

✅ **All green?** → Proceed with deployment  
❌ **Any red?** → Resolve issues first

---

## 🔍 12 Prechecks

1. ✅ System Requirements
2. ✅ Required Services  
3. ✅ Docker Health
4. ✅ Disk Space (5GB+ free)
5. ✅ Memory (4GB+ recommended)
6. ✅ Repository State
7. ✅ Configuration Files
8. ✅ API Health
9. ✅ Database Connection
10. ✅ Previous Phases
11. ✅ Security & Compliance
12. ✅ Backup Capability

**All Pass Required** before deployment proceeds

---

## 📂 Key Files

| File | Purpose |
|------|---------|
| `deploy-phase-4-full-launch.sh` | Main deployment script |
| `pfs/marketplace-phase3.yaml` | Phase 3 marketplace config |
| `pfs/global-launch.yaml` | Phase 4 launch config |
| `pfs/founder-public-transition.yaml` | Transition config |
| `/var/log/nexus-cos/phase4-audit/` | Audit logs directory |

---

## 🎮 Phase 3: Marketplace Trading

### Activation Steps

```bash
# Step 1: Founders only (Day 0-7)
nexusctl marketplace enable --phase 3 --step 1

# Step 2: Founders + Creators (Day 7-14)
nexusctl marketplace enable --phase 3 --step 2

# Step 3: All verified users (Day 14-21)
nexusctl marketplace enable --phase 3 --step 3

# Step 4: Full marketplace (Day 21+)
nexusctl marketplace enable --phase 3 --step 4
```

### Key Features
- Peer-to-peer trading
- Fixed price listings
- Auction system (Step 4)
- Progressive access control
- Anti-wash trading rules

### Limits
- **Founders:** 10,000 NexCoin/day
- **Creators:** 5,000 NexCoin/day
- **Public:** 1,000 NexCoin/day

---

## 🌍 Phase 4: Full Public Launch

### Activation Command

```bash
# Enable full public launch
nexusctl launch --mode global --confirm
```

### What Changes
- ✅ Public signups enabled
- ✅ SEO activated
- ✅ Marketing channels live
- ✅ Auto-scaling enabled
- ✅ 24/7 access granted

### Success Metrics
- **Day 1:** Zero critical incidents
- **Week 1:** User retention > 60%
- **Month 1:** Sustainable growth

---

## 🔄 Emergency Rollback

### Instant Revert (<30 seconds)

```bash
# Execute auto-generated rollback
sudo /var/log/nexus-cos/phase4-audit/rollback-[timestamp].sh
```

### Manual Feature Flag Rollback

```bash
# Disable Phase 4
nexusctl launch --mode founder --confirm

# Disable Phase 3
nexusctl marketplace disable --phase 3
```

---

## 📊 Health Checks

```bash
# Gateway API
curl http://localhost:4000/health

# Marketplace Phase 3
curl http://localhost:4000/api/pf/marketplace/health

# Launch Status
curl http://localhost:4000/api/pf/launch/health

# All services
docker ps --format "table {{.Names}}\t{{.Status}}"
```

---

## 📝 Audit Trail

### View Deployment Log
```bash
tail -f /var/log/nexus-cos/phase4-audit/deployment-*.log
```

### View Precheck Results
```bash
cat /var/log/nexus-cos/phase4-audit/precheck-*.log
```

### Verify Rollback Script
```bash
ls -la /var/log/nexus-cos/phase4-audit/rollback-*.sh
```

---

## ⚠️ Troubleshooting

### Deployment Fails at Prechecks

```bash
# Check system resources
df -h
free -h
docker info

# Check services
sudo systemctl status docker nginx

# Review precheck log
cat /var/log/nexus-cos/phase4-audit/precheck-*.log
```

### Services Not Responding

```bash
# Restart Docker services
cd /opt/nexus-cos
docker compose restart

# Check logs
docker compose logs --tail=100 -f
```

### Configuration Missing

```bash
# Verify required files
ls -la /opt/nexus-cos/pfs/marketplace-phase3.yaml
ls -la /opt/nexus-cos/pfs/global-launch.yaml
ls -la /opt/nexus-cos/pfs/founder-public-transition.yaml
```

---

## 📞 Emergency Response

### Critical Issue Protocol

1. **Stop New Activations**
   ```bash
   # Disable public access immediately
   nexusctl launch --mode founder --confirm
   ```

2. **Execute Rollback**
   ```bash
   sudo /var/log/nexus-cos/phase4-audit/rollback-*.sh
   ```

3. **Notify Team**
   - Incident response channel
   - Status page update
   - User communication

4. **Investigate & Resolve**
   - Review audit logs
   - Identify root cause
   - Implement fix
   - Test thoroughly

5. **Gradual Restoration**
   - Re-enable features incrementally
   - Monitor closely
   - Communicate updates

---

## 🎯 Deployment Timeline

```
T-0: Deploy script execution (2-3 min)
  ├─ Prechecks (1 min)
  ├─ Validation (30 sec)
  ├─ Configuration check (30 sec)
  └─ Summary generation (30 sec)

T+0: Phase 3 Ready
  └─ Manual activation required

T+0: Phase 4 Ready  
  └─ Manual activation required

T+X: Feature flag activation
  └─ Based on team decision
```

---

## ✅ Success Indicators

### Deployment Complete When:
- ✅ All 12 prechecks pass
- ✅ Audit log generated
- ✅ Rollback script created
- ✅ No critical errors
- ✅ Configurations validated
- ✅ System health confirmed

### Ready for Activation When:
- ✅ Team briefed
- ✅ Monitoring active
- ✅ Support ready
- ✅ Communication prepared
- ✅ Rollback tested
- ✅ Stakeholder approval

---

## 📚 Documentation Links

- [Full Deployment Guide](./PHASE_4_DEPLOYMENT_GUIDE.md)
- [Phase 2.5 README](./PHASE_2.5_README.md)
- [Implementation Complete](./IMPLEMENTATION_COMPLETE.md)
- [Phase 1 & 2 Audit](./PHASE_1_2_CANONICAL_AUDIT_REPORT.md)

---

## 🔑 Key Commands Summary

```bash
# Deploy Phase 4
sudo ./deploy-phase-4-full-launch.sh

# Activate Phase 3
nexusctl marketplace enable --phase 3 --step 1

# Activate Phase 4
nexusctl launch --mode global --confirm

# Health Check
curl http://localhost:4000/health

# View Logs
tail -f /var/log/nexus-cos/phase4-audit/deployment-*.log

# Rollback
sudo /var/log/nexus-cos/phase4-audit/rollback-*.sh
```

---

**Print this card and keep it accessible during deployment!**

*Prepared for January 15, 2026 deployment*
