# NEXUS COS EXPANSION LAYER - QUICK REFERENCE CARD

## 🚀 ONE-SHOT EXECUTION

### Production Deployment Command
```bash
cd /home/runner/work/nexus-cos/nexus-cos && bash deploy-nexus-expansion-layer.sh
```

**Duration:** ~30 seconds  
**Changes:** Config files only, no code rebuild  
**Impact:** Zero downtime (overlay deployment)

---

## 📦 WHAT GETS DEPLOYED

### 5 Core Artifacts

| # | Artifact | File | Purpose |
|---|----------|------|---------|
| 1 | **Jurisdiction Engine** | `config/jurisdiction-engine.yaml` | Runtime region compliance |
| 2 | **Marketplace Phase-2** | `config/marketplace-phase2.yaml` | Asset trading (gated) |
| 3 | **AI Dealers** | `config/ai-dealers.yaml` | PUABO AI-HF personalities |
| 4 | **Casino Federation** | `config/casino-federation.yaml` | Multi-casino system |
| 5 | **Investor Whitepaper** | `docs/NEXUS_COS_INVESTOR_WHITEPAPER.md` | Market docs |

### Additional Files
- `config/features.json` - Frontend feature flags
- `nexus-expansion-layer-pf.yaml` - Master PF coordinator
- `deploy-nexus-expansion-layer.sh` - Deployment script
- `NEXUS_EXPANSION_LAYER_README.md` - Full documentation

---

## ✅ PRE-DEPLOYMENT CHECKLIST

- [ ] Nexus COS core stack is running
- [ ] Docker is available
- [ ] Config directory exists
- [ ] No pending deployments
- [ ] Backup current configuration (optional)

---

## 🎯 POST-DEPLOYMENT ACTIONS

### 1. Verify Deployment
```bash
# Check verification report
cat nexus-expansion-verification-*.txt
```

### 2. Integrate Backend Services
```bash
# Copy configs to production location
cp config/*.yaml /opt/nexus-cos/config/

# Restart relevant services (if needed)
docker restart casino-nexus-api
docker restart nexcoin-ms
docker restart puaboai-sdk
docker restart vr-world-ms
```

### 3. Update Frontend
```bash
# Copy feature flags
cp config/features.json frontend/src/config/

# Rebuild or hot reload
cd frontend && npm run build  # OR npm run dev
```

### 4. Update Nginx
```nginx
# Add to nginx.conf
location /api/jurisdiction/ { proxy_pass http://backend-api:3000; }
location /api/marketplace/ { proxy_pass http://nft-marketplace-ms:7007; }
location /api/ai-dealers/ { proxy_pass http://puaboai-sdk:3200; }
location /api/casino-federation/ { proxy_pass http://casino-nexus-api:7003; }
```

```bash
# Reload nginx
nginx -s reload
```

### 5. Health Checks
```bash
curl http://localhost:3000/api/jurisdiction/health
curl http://localhost:3000/api/marketplace/health
curl http://localhost:3000/api/ai-dealers/health
curl http://localhost:3000/api/casino-federation/health
```

---

## 🧪 UI VERIFICATION

### Test Each Component

1. **Jurisdiction Toggle**
   - URL: `/admin/jurisdiction`
   - Test: Select region (US/EU/GLOBAL)
   - Verify: Features enable/disable correctly

2. **Marketplace**
   - URL: `/marketplace`
   - Test: Browse assets
   - Verify: "Trading available in Phase-3" message

3. **AI Dealers**
   - URL: `/casino/tables`
   - Test: Interact with dealer
   - Verify: Personality responses

4. **Casino Federation**
   - URL: `/casino-strip`
   - Test: Navigate between casinos
   - Verify: Shared NexCoin balance

---

## 🔧 CONFIGURATION HIGHLIGHTS

### Jurisdiction Engine
- **US:** Skill games, NexCoin, VR (no gambling)
- **EU:** Skill games, Marketplace, VR (GDPR compliant)
- **Global:** Social casino, VR (entertainment only)

### Marketplace Phase-2
- **Currency:** NexCoin ONLY
- **Assets:** Avatars, VR items, Casino cosmetics
- **Trading:** GATED until Phase-3
- **Revenue:** 80% creator / 20% platform

### AI Dealers
- **Engine:** PUABO AI-HF (proprietary)
- **Roles:** Blackjack, Poker, Roulette
- **Memory:** Session-only
- **Compliance:** Transparent, no manipulation

### Casino Federation
- **Casinos:** 3 (Nexus Prime, High Roller, Creator Nodes)
- **Economy:** Shared NexCoin
- **Jackpots:** Local + Strip-wide progressive
- **Navigation:** Walk or teleport between casinos

---

## 🚨 TROUBLESHOOTING

### Issue: Script fails to find config files
**Solution:** Run from repository root: `cd /path/to/nexus-cos`

### Issue: Health checks fail
**Solution:** This is expected if services not yet deployed. Proceed with integration.

### Issue: Permission denied on script
**Solution:** `chmod +x deploy-nexus-expansion-layer.sh`

### Issue: Nginx routes not working
**Solution:** Check nginx config syntax: `nginx -t` then reload: `nginx -s reload`

### Issue: Feature flags not loading
**Solution:** Clear frontend cache, rebuild: `cd frontend && npm run build`

---

## 📊 STACK ALIGNMENT

| Component | Value |
|-----------|-------|
| **Platform** | Nexus COS |
| **Casino** | Casino-Nexus (skill-based) |
| **Economy** | NexCoin (closed-loop) |
| **AI** | PUABO AI-HF + MetaTwin + HoloCore |
| **VR** | NexusVision (software layer) |
| **Deploy** | Docker / Config overlay |
| **Owner** | PUABO Holdings |

✅ **NO foreign systems**  
✅ **NO third-party control**  
✅ **NO architectural drift**

---

## 🎉 SUCCESS CRITERIA

- [x] All 5 config files created
- [x] Feature flags generated
- [x] Verification report produced
- [x] No errors in deployment script
- [x] Stack alignment confirmed

---

## 📞 SUPPORT

**Docs:** [NEXUS_EXPANSION_LAYER_README.md](./NEXUS_EXPANSION_LAYER_README.md)  
**Whitepaper:** [docs/NEXUS_COS_INVESTOR_WHITEPAPER.md](./docs/NEXUS_COS_INVESTOR_WHITEPAPER.md)  
**Issues:** https://github.com/BobbyBlanco400/nexus-cos/issues

---

## 🏁 FINAL STATUS

**Status:** ✅ READY FOR INTEGRATION  
**Method:** Config overlay (no core changes)  
**Impact:** Zero downtime  
**Rollback:** Disable feature flags  

**Nexus COS is now:**
- Browser-based immersive OS
- Virtual Vegas Strip
- Closed-loop digital economy
- AI-powered platform
- Jurisdiction-adaptive system

**No one else has this.**
