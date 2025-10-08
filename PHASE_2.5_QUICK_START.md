# Phase 2.5 OTT Integration - Quick Start

**⚡ FAST REFERENCE FOR PHASE 2.5 DEPLOYMENT ⚡**

**Status:** Production Ready | **Enforcement:** MANDATORY | **PF ID:** PF-HYBRID-FULLSTACK-2025.10.07-PHASE-2.5

---

## 🚀 One-Liner Deployment (Use This)

```bash
cd /opt/nexus-cos && \
chmod +x scripts/deploy-phase-2.5-architecture.sh scripts/validate-phase-2.5-deployment.sh && \
sudo ./scripts/deploy-phase-2.5-architecture.sh && \
sudo ./scripts/validate-phase-2.5-deployment.sh
```

**Wait for:** "✅ ALL CHECKS PASSED" message at the end.

---

## ✅ Success = Both Green Boxes

### You MUST see these two boxes:

**After deployment:**
```
╔════════════════════════════════════════════════════════════════╗
║        ✅  PHASE 2.5 DEPLOYMENT COMPLETE - SUCCESS  ✅         ║
║              ALL MANDATORY REQUIREMENTS MET                    ║
╚════════════════════════════════════════════════════════════════╝
```

**After validation:**
```
╔════════════════════════════════════════════════════════════════╗
║                ✅ ALL CHECKS PASSED ✅                         ║
║         Phase 2.5 Deployment is Production Ready!              ║
╚════════════════════════════════════════════════════════════════╝
```

**If you see BOTH green boxes = SUCCESS ✅**  
**If you see ANY red boxes = FAILURE ❌ (fix and re-run)**

---

## 🔍 Quick Pre-Flight Check

Before deploying, verify these:

```bash
# 1. You are root
whoami  # Must show: root

# 2. Repository exists
ls /opt/nexus-cos/scripts/  # Should list scripts

# 3. Landing pages exist
ls /opt/nexus-cos/apex/index.html  # Must exist
ls /opt/nexus-cos/web/beta/index.html  # Must exist

# 4. Docker running
systemctl is-active docker  # Must show: active

# 5. Nginx installed
which nginx  # Must show path to nginx
```

**All 5 checks MUST pass before deploying.**

---

## 📦 What Gets Deployed

1. **OTT Frontend** → `/var/www/nexuscos.online/index.html`
2. **Beta Portal** → `/var/www/beta.nexuscos.online/index.html`
3. **Nginx Config** → `/etc/nginx/sites-enabled/nexuscos`
4. **Log Directories** → `/opt/nexus-cos/logs/phase2.5/`
5. **Transition Script** → `scripts/beta-transition-cutover.sh`

---

## 🎯 What Gets Validated

The validation script checks 40+ items including:

- ✅ All directories exist
- ✅ Landing pages deployed correctly
- ✅ Nginx configuration valid
- ✅ SSL certificates present
- ✅ Backend services healthy
- ✅ All routes accessible
- ✅ Logs properly separated
- ✅ Transition automation ready

**ALL checks must pass = 100% success rate required**

---

## ❌ What Failure Looks Like

**Red boxes with error messages:**
```
╔════════════════════════════════════════════════════════════════╗
║                ❌ VALIDATION FAILED ❌                          ║
║              DEPLOYMENT IS INCOMPLETE                          ║
╚════════════════════════════════════════════════════════════════╝
```

**Or output showing:**
- ✗ Checks Failed: 5 (or any number > 0)
- "ENFORCEMENT FAILURE" messages
- "DO NOT PROCEED" warnings

**If you see failure indicators: STOP, fix issues, re-run from beginning.**

---

## 🔧 Quick Troubleshooting

### Issue: "Landing page not found"
```bash
cd /opt/nexus-cos
git pull origin main
ls apex/index.html web/beta/index.html
```

### Issue: "Permission denied"
```bash
sudo -i
cd /opt/nexus-cos
# Re-run deployment
```

### Issue: "Nginx failed"
```bash
sudo nginx -t  # Check configuration
sudo systemctl restart nginx
```

### Issue: "Docker not running"
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

---

## 📖 Full Documentation

For detailed information, see:

1. **PHASE_2.5_ENFORCEMENT_GUIDE.md** - Comprehensive bulletproof guide
2. **PF_PHASE_2.5_OTT_INTEGRATION.md** - Official PF directive
3. **TRAE_SOLO_EXECUTION.md** - Detailed execution instructions

---

## 🎓 Key Rules

1. ✅ **Follow scripts exactly** - No deviations
2. ✅ **Run validation** - It's mandatory, not optional
3. ✅ **Fix all errors** - Don't proceed with failures
4. ✅ **Verify success** - Must see green boxes
5. ❌ **Don't skip steps** - All steps are required
6. ❌ **Don't ignore errors** - Fix them immediately
7. ❌ **Don't proceed on failure** - Re-run until success

---

## 🏁 Completion Checklist

After deployment, verify ALL of these:

- [ ] Deployment script showed green success box
- [ ] Validation script showed green success box
- [ ] Validation showed "Checks Failed: 0"
- [ ] Landing pages exist at correct paths
- [ ] Nginx is running: `systemctl is-active nginx` = active
- [ ] Can access https://nexuscos.online
- [ ] Can access https://beta.nexuscos.online

**ALL checkboxes must be checked = Deployment is complete ✅**  
**ANY unchecked boxes = Deployment is incomplete ❌**

---

## 🎯 Next Steps After Success

1. ✅ Deployment validated and production-ready
2. ✅ All landing pages accessible
3. ✅ Monitor logs: `/opt/nexus-cos/logs/phase2.5/`
4. ⏳ Schedule transition for Nov 17, 2025:
   ```bash
   crontab -e
   # Add: 0 0 17 11 2025 /opt/nexus-cos/scripts/beta-transition-cutover.sh
   ```

---

## 💡 Remember

**Success = Green Boxes + Zero Failures + All Checks Pass**

**Anything else = Incomplete = Fix and Re-run**

---

**Document Status:** PRODUCTION READY  
**Last Updated:** 2025-10-08  
**Authorization:** Bobby Blanco | PUABO | NEXUS COS Command
