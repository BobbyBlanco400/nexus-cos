# TRAE Solo — Quick Start Guide
## N3XUS COS v3.0 Governance Verification

**Governance Order:** 55-45-17
**Status:** ACTIVE & BINDING

---

## 🚀 Quick Start (5 Minutes)

### 1. Run Verification

```bash
# Navigate to repository
cd /home/runner/work/nexus-cos/nexus-cos

# Run governance verification
./trae-governance-verification.sh
```

### 2. Review Report

```bash
# View audit report
cat PHASE_1_2_CANONICAL_AUDIT_REPORT.md
```

### 3. Check Results

**Success Output:**
```
✅ GOVERNANCE CHECK PASSED
   System is compliant with 55-45-17
```

**Verification Summary:**
- ✅ 26 systems verified
- ❌ 0 incorrect systems
- ⚠️  0 warnings
- 🔒 Handshake enforced: YES

---

## 📋 What Gets Verified

### 0️⃣ Pre-Condition
- ✅ NGINX handshake injection (X-N3XUS-Handshake: 55-45-17)
- ✅ All services reject requests without header

### 1️⃣ Phase 1 & 2 Systems
- ✅ Backend API
- ✅ Auth Service
- ✅ Gateway API
- ✅ Frontend
- ✅ Database
- ✅ Redis

### 2️⃣ Tenant Registry
- ✅ 13 Mini-Platforms (exactly)
- ✅ 80/20 revenue split (locked)
- ✅ Tier 1/2 status
- ✅ No system tenants

### 3️⃣ PMMG Media Engine
- ✅ Only media engine
- ✅ Browser-only (no installs)
- ✅ Full pipeline: Recording → Mixing → Publishing

### 4️⃣ Founders Program
- ✅ Active status
- ✅ 30-day feedback loop
- ✅ Daily content system
- ✅ Beta gates labeled

### 5️⃣ Immersive Desktop
- ✅ Windowed/panel UI
- ✅ Session persistence
- ✅ No VR dependency

### 6️⃣ VR/AR Status
- ✅ Optional (not required)
- ✅ Disabled by default
- ✅ Non-blocking
- ✅ No hardware required

### 7️⃣ Streaming Stack
- ✅ streamcore + streaming-service-v2
- ✅ Browser playback (HLS/DASH)
- ✅ Handshake enforced

---

## 📊 Understanding Results

### Exit Codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | All checks passed | ✅ Proceed with deployment |
| 1 | Critical errors found | ❌ Fix errors before deployment |

### Status Indicators

- ✅ **VERIFIED** - System passes all checks
- ❌ **INCORRECT** - System requires fixes
- ⚠️  **WARNING** - Non-critical issue identified
- 🚧 **BETA GATE** - Intentionally gated for Beta

---

## 🔧 Common Tasks

### Re-run Verification
```bash
./trae-governance-verification.sh
```

### View Full Report
```bash
cat PHASE_1_2_CANONICAL_AUDIT_REPORT.md
```

### Check Handshake in NGINX
```bash
grep "X-N3XUS-Handshake" nginx.conf
```

### Verify Tenant Count
```bash
cat nexus/tenants/canonical_tenants.json | grep -o '"id"' | wc -l
# Should output: 13
```

### Check Revenue Split
```bash
cat nexus/tenants/canonical_tenants.json | grep "split"
# Should output: "split": "80/20"
```

---

## 📖 Documentation

### Essential Reading

1. **GOVERNANCE_CHARTER_55_45_17.md** - Complete governance charter
2. **PHASE_1_2_CANONICAL_AUDIT_REPORT.md** - Latest audit report
3. **CANONICAL_TENANT_REGISTRY.md** - Tenant documentation

### Governance Rules

- 🔒 **Handshake Required:** X-N3XUS-Handshake: 55-45-17
- 🔒 **Tenant Count:** 13 (immutable)
- 🔒 **Revenue Split:** 80/20 (locked)
- 🔒 **Technical Freeze:** Active until Public Alpha

---

## ⚠️ Technical Freeze

### Prohibited
❌ New infrastructure
❌ New engines
❌ VR/AR layers (beyond optional)
❌ Desktop abstractions
❌ Streaming clients
❌ OS constructs
❌ Unapproved expansions

### Permitted
✅ Bug corrections
✅ Security audits
✅ Governance enforcement
✅ Content updates
✅ Documentation
✅ Approved tenant onboarding

---

## 🚨 Troubleshooting

### Verification Fails

**Problem:** Script exits with error code 1

**Solution:**
1. Check error messages in console output
2. Review PHASE_1_2_CANONICAL_AUDIT_REPORT.md
3. Fix reported issues
4. Re-run verification

### Handshake Not Found

**Problem:** "NGINX handshake not found" error

**Solution:**
```bash
# Verify file exists
ls -la nginx.conf nginx.conf.docker nginx.conf.host

# Add handshake header to nginx.conf
# Add after "http {" line:
# proxy_set_header X-N3XUS-Handshake "55-45-17";

# Re-run verification
./trae-governance-verification.sh
```

### Tenant Count Mismatch

**Problem:** "Expected 13 tenants, found X"

**Solution:**
```bash
# Check tenant file
cat nexus/tenants/canonical_tenants.json | jq '.tenant_count'

# Verify tenant IDs
cat nexus/tenants/canonical_tenants.json | jq '.tenants[].id'

# Should have exactly 13 tenants with IDs 1-13
```

### Revenue Split Incorrect

**Problem:** "Revenue split not 80/20"

**Solution:**
```bash
# Check current split
cat nexus/tenants/canonical_tenants.json | jq '.revenue_model'

# Should show:
# {
#   "split": "80/20",
#   "tenant_percentage": 80,
#   "platform_percentage": 20,
#   ...
# }
```

---

## 🎯 Pre-Deployment Checklist

Before any deployment, ensure:

- [ ] Run `./trae-governance-verification.sh`
- [ ] Exit code = 0 (success)
- [ ] Review `PHASE_1_2_CANONICAL_AUDIT_REPORT.md`
- [ ] All systems show ✅ VERIFIED
- [ ] Handshake enforcement: YES
- [ ] Tenant count: 13
- [ ] Revenue split: 80/20
- [ ] Technical freeze respected

---

## 📞 Support

### For Issues

1. Check GOVERNANCE_CHARTER_55_45_17.md
2. Review PHASE_1_2_CANONICAL_AUDIT_REPORT.md
3. Run verification script with detailed output
4. Escalate to Executive Authority if needed

### For Questions

- **Governance:** See GOVERNANCE_CHARTER_55_45_17.md
- **Tenants:** See CANONICAL_TENANT_REGISTRY.md
- **Handshake:** See Section IV in Governance Charter
- **Technical Freeze:** See Section II in Governance Charter

---

## 🔄 Regular Operations

### Daily
```bash
# Verify system compliance
./trae-governance-verification.sh
```

### Before Deployment
```bash
# Full verification
./trae-governance-verification.sh

# Review report
cat PHASE_1_2_CANONICAL_AUDIT_REPORT.md

# Confirm handshake
grep "X-N3XUS-Handshake" nginx.conf
```

### After Changes
```bash
# Always re-verify
./trae-governance-verification.sh

# Archive report
cp PHASE_1_2_CANONICAL_AUDIT_REPORT.md \
   reports/audit_$(date +%Y%m%d_%H%M%S).md
```

---

## ✅ Success Criteria

Your system is **COMPLIANT** when:

✅ Verification script exits with code 0
✅ Audit report shows 0 errors
✅ Handshake enforcement: YES
✅ 26 systems verified
✅ 13 tenants confirmed
✅ 80/20 split locked
✅ Technical freeze respected

---

## 🚀 Next Steps

Once verification passes:

1. ✅ Archive audit report
2. ✅ Update deployment docs
3. ✅ Proceed with deployment
4. ✅ Monitor system health
5. ✅ Gather Founders feedback

---

**Governance Order:** 55-45-17
**Status:** ACTIVE & BINDING
**Enforcement:** MANDATORY

*This system is governed and compliant. Maintain verification before all deployments.*
