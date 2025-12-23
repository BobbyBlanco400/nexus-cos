# 🚀 NEXUS COS OPERATIONAL DOCUMENTATION

**Version:** v2025.12.23  
**Status:** ACTIVE  
**Audience:** DevOps, Engineering, Operations Teams

---

## PURPOSE

This directory contains operational documentation for deploying, managing, and executing Nexus COS platform operations. These documents are designed for engineering and DevOps teams to execute production workflows.

---

## 📁 OPERATIONAL PACKAGES

### 7-Day Founder Beta

**Location:** `operational/7DAY_FOUNDER_BETA/`  
**Status:** READY FOR EXECUTION  
**Owner:** TRAE SOLO CODER (Head Dev/Engineer)

Complete operational package for executing the 7-Day Founder Beta launch:

- **README.md** - Execution guide for TRAE SOLO CODER
- **FOUNDER_BETA_VERIFICATION_CHECKLIST.md** - Internal verification checklist
- **FINAL_LAUNCH_DECLARATION.md** - Launch declaration (internal/investor-safe)
- **FOUNDER_ONBOARDING_SCRIPT.md** - Founder onboarding script (non-public)

**Key Features:**
- Day-by-day verification workflow
- Operational commands and health checks
- Critical correction: DAY 4 uses PUABO AI-HF (NOT kei-ai)
- Complete success criteria and sign-off procedures

**Quick Start:**
```bash
cd operational/7DAY_FOUNDER_BETA
cat README.md
```

---

## 🔗 RELATED DOCUMENTATION

### Platform Launch Documentation

These existing documents complement the operational packages:

- **PF_MASTER_LAUNCH_GATE_README.md** - Production launch validation tool
- **BETA_LAUNCH_QUICK_REFERENCE.md** - Beta launch quick reference
- **TRAE_SOLO_START_HERE_NOW.md** - TRAE SOLO execution starting point
- **VERIFICATION_SUITE_README.md** - Verification suite documentation

### System Health & Monitoring

- **NEXUS_COS_HEALTH_CHECK_README.md** - Health check procedures
- **SYSTEM_CHECK_QUICK_REFERENCE.md** - Quick system checks
- **PF_MASTER_LAUNCH_GATE_README.md** - Launch gate health validation

### Deployment & Infrastructure

- **VPS_DEPLOYMENT_GUIDE.md** - VPS deployment procedures
- **DEPLOYMENT_GUIDE.md** - General deployment guide
- **NEXUS_COS_INFRA_CORE_README.md** - Infrastructure core documentation

---

## 🎯 FOR TRAE SOLO CODER

### Starting Points by Task

**Executing 7-Day Founder Beta:**
→ Start here: `operational/7DAY_FOUNDER_BETA/README.md`

**Validating Production Launch:**
→ Start here: `PF_MASTER_LAUNCH_GATE_README.md`

**General Beta Launch:**
→ Start here: `TRAE_SOLO_START_HERE_NOW.md`

**System Health Check:**
→ Start here: `NEXUS_COS_HEALTH_CHECK_README.md`

**Full Deployment:**
→ Start here: `VPS_DEPLOYMENT_GUIDE.md`

---

## 📊 OPERATIONAL WORKFLOWS

### 1. Pre-Launch Validation

```bash
# Run system-wide health check
curl -X GET https://nexuscos.online/api/system/health

# Validate production configuration
./pf-master-launch-gate.sh

# Check all service endpoints
./nexus_cos_health_check.sh
```

### 2. Founder Beta Execution

```bash
# Navigate to operational package
cd operational/7DAY_FOUNDER_BETA

# Review execution guide
cat README.md

# Follow day-by-day workflow
# Use FOUNDER_BETA_VERIFICATION_CHECKLIST.md for tracking
```

### 3. Post-Launch Monitoring

```bash
# System uptime and health
curl -X GET https://nexuscos.online/api/system/uptime

# Service-specific checks
curl -X GET https://nexuscos.online/api/{service}/health

# Resource utilization
curl -X GET https://nexuscos.online/api/system/resource-utilization
```

---

## ⚠️ CRITICAL OPERATIONAL NOTES

### AI Service Configuration (CORRECTED)

**PUABO AI-HF is used for AI identity, NOT kei-ai.**

Always verify:
```bash
# Check AI service chain
curl -X GET https://nexuscos.online/api/ai/service-chain | grep -v "kei-ai" || echo "ERROR: kei-ai detected!"

# Verify PUABO AI-HF health
curl -X GET https://nexuscos.online/api/puabo-ai-hf/health
```

### Tenant Platform Isolation

**Club Saditty is a TENANT, not the front-end.**

Verify isolation:
```bash
# Check tenant status
curl -X GET https://nexuscos.online/api/tenants/club-saditty/status

# Verify core services unaffected
curl -X GET https://nexuscos.online/api/system/health
```

### Identity Persistence

**Single identity must persist across all modules.**

If re-authentication required → critical failure, investigate immediately.

---

## 📞 SUPPORT & ESCALATION

### For Operations Team

- **System Issues:** Check logs, run health commands, escalate to DevOps
- **Deployment Issues:** Reference VPS_DEPLOYMENT_GUIDE.md
- **Launch Validation:** Use PF_MASTER_LAUNCH_GATE_README.md

### For TRAE SOLO CODER

- **7-Day Founder Beta:** Follow operational/7DAY_FOUNDER_BETA/README.md
- **Technical Blockers:** Use health check commands for diagnostics
- **Launch Decision:** Complete verification checklist, obtain sign-offs

---

## 📦 DOCUMENT STRUCTURE

```
nexus-cos/
├── operational/
│   ├── README.md (this file)
│   └── 7DAY_FOUNDER_BETA/
│       ├── README.md
│       ├── FOUNDER_BETA_VERIFICATION_CHECKLIST.md
│       ├── FINAL_LAUNCH_DECLARATION.md
│       └── FOUNDER_ONBOARDING_SCRIPT.md
├── PF_MASTER_LAUNCH_GATE_README.md
├── BETA_LAUNCH_QUICK_REFERENCE.md
├── TRAE_SOLO_START_HERE_NOW.md
├── VERIFICATION_SUITE_README.md
├── NEXUS_COS_HEALTH_CHECK_README.md
├── VPS_DEPLOYMENT_GUIDE.md
└── [other documentation]
```

---

## ✅ DOCUMENT STATUS

- ✅ **7-Day Founder Beta Package** - COMPLETE & READY
- ✅ **Launch Gate Validation** - COMPLETE & READY
- ✅ **Health Check Procedures** - COMPLETE & READY
- ✅ **Deployment Guides** - COMPLETE & READY

---

## 🔄 MAINTENANCE

### Review Cycle

Operational documentation should be reviewed:
- After each founder beta cycle
- After major platform updates
- When architecture changes
- Quarterly at minimum

### Update Procedure

1. Identify needed changes based on execution feedback
2. Update relevant operational documents
3. Increment version numbers
4. Notify operations team of updates
5. Archive previous versions if significant changes

---

**Document Control:**
- **Created:** 2025-12-23
- **Owner:** Nexus COS Operations Team
- **Classification:** INTERNAL OPERATIONS
- **Status:** ACTIVE
