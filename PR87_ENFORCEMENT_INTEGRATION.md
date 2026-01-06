# PR#87 Enforcement Framework - Integration with PF Deployment

**IRON FIST ENFORCEMENT - COMPLETE INTEGRATION GUIDE**

**Status:** Integrated with Phase 2.5  
**Last Updated:** October 7, 2025

---

## 📋 OVERVIEW

This document describes how the PR#87 landing page enforcement framework integrates with the existing Nexus COS Production Framework (PF) deployment system, including **Phase 2.5 OTT Integration + Beta Transition**.

### What Was Created

1. **PR87_LANDING_PAGE_DEPLOYMENT_CHECKLIST.md** - Complete enforcement checklist (14 checkpoints)
2. **scripts/deploy-pr87-landing-pages.sh** - Automated deployment script
3. **scripts/validate-pr87-landing-pages.sh** - Comprehensive validation script
4. **PR87_QUICK_DEPLOY.md** - Quick reference guide
5. **PR87_ENFORCEMENT_INTEGRATION.md** - This integration guide

### Purpose

To ensure TRAE (or any deployment agent) can deploy the PR#87 landing pages with **ABSOLUTE STRICT ADHERENCE** to:
- PF Standards
- Global Branding Policy
- Phase 2.5 architecture compatibility
- Zero error tolerance
- Complete validation coverage

### Phase 2.5 Integration

PR#87 landing pages are now **fully integrated** with Phase 2.5:
- **Apex landing** deployed to `/var/www/n3xuscos.online/` (OTT layer)
- **Beta landing** deployed to `/var/www/beta.n3xuscos.online/` (Beta layer)
- **Validation** included in Phase 2.5 validation suite
- **Transition** automated for November 17, 2025

**See:** `PF_PHASE_2.5_OTT_INTEGRATION.md` for complete Phase 2.5 specifications

---

## 🔗 INTEGRATION WITH EXISTING PF FRAMEWORK

### How It Fits Into PF Deployment

```
┌─────────────────────────────────────────────────────────────┐
│                    PF DEPLOYMENT FRAMEWORK                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐         ┌───────────────────┐        │
│  │  TRAE_SOLO       │   -->   │  bulletproof-pf-  │        │
│  │  EXECUTION.md    │         │  deploy.sh        │        │
│  └──────────────────┘         └───────────────────┘        │
│           │                              │                  │
│           │                              │                  │
│           v                              v                  │
│  ┌──────────────────┐         ┌───────────────────┐        │
│  │  PF_BULLETPROOF  │         │  bulletproof-pf-  │        │
│  │  _GUIDE.md       │         │  validate.sh      │        │
│  └──────────────────┘         └───────────────────┘        │
│                                                              │
│           ┌──────────────────────────────┐                 │
│           │   PR#87 ENFORCEMENT (NEW)     │                 │
│           ├──────────────────────────────┤                 │
│           │                               │                 │
│           │  ┌────────────────────┐      │                 │
│           │  │ PR87_LANDING_PAGE_ │      │                 │
│           │  │ DEPLOYMENT_        │      │                 │
│           │  │ CHECKLIST.md       │      │                 │
│           │  └────────────────────┘      │                 │
│           │           │                   │                 │
│           │           v                   │                 │
│           │  ┌────────────────────┐      │                 │
│           │  │ deploy-pr87-       │      │                 │
│           │  │ landing-pages.sh   │      │                 │
│           │  └────────────────────┘      │                 │
│           │           │                   │                 │
│           │           v                   │                 │
│           │  ┌────────────────────┐      │                 │
│           │  │ validate-pr87-     │      │                 │
│           │  │ landing-pages.sh   │      │                 │
│           │  └────────────────────┘      │                 │
│           └──────────────────────────────┘                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Integration Points

1. **Pre-Backend Deployment**
   - Deploy landing pages BEFORE backend services
   - Ensures users see professional landing pages immediately
   - Health checks will show neutral status until backend is deployed

2. **During PF Deployment**
   - Can be run as part of `bulletproof-pf-deploy.sh`
   - Or executed separately for focused landing page deployment

3. **Post-Backend Deployment**
   - Validate health check endpoints are working
   - Confirm backend services are properly proxied

---

## 🚀 EXECUTION MODES

### Mode 1: Standalone Landing Page Deployment

**When to use:** Deploy only landing pages without full PF deployment

```bash
# One-liner
ssh root@74.208.155.161 "cd /opt/nexus-cos && ./scripts/deploy-pr87-landing-pages.sh"

# With validation
ssh root@74.208.155.161 "cd /opt/nexus-cos && ./scripts/deploy-pr87-landing-pages.sh && ./scripts/validate-pr87-landing-pages.sh"
```

**Use case:** Quick landing page updates without touching backend services

---

### Mode 2: Integrated with Bulletproof PF Deployment

**When to use:** Full system deployment including landing pages

```bash
ssh root@74.208.155.161 "cd /opt/nexus-cos && ./bulletproof-pf-deploy.sh && ./scripts/deploy-pr87-landing-pages.sh"
```

**Order of operations:**
1. Run `bulletproof-pf-deploy.sh` (deploys backend services)
2. Run `deploy-pr87-landing-pages.sh` (deploys landing pages)
3. Run `validate-pr87-landing-pages.sh` (validates everything)

---

### Mode 3: Manual Checklist Execution

**When to use:** Step-by-step execution with human verification

Follow: **PR87_LANDING_PAGE_DEPLOYMENT_CHECKLIST.md**

**Use case:** Initial deployment or when debugging issues

---

## 📊 VALIDATION LEVELS

### Level 1: Quick Validation (1 minute)
```bash
./scripts/validate-pr87-landing-pages.sh
```
- File existence and integrity
- Basic HTTP/HTTPS checks
- Essential feature validation

### Level 2: Comprehensive Checklist (10-15 minutes)
Follow: **PR87_LANDING_PAGE_DEPLOYMENT_CHECKLIST.md**
- All 14 checkpoints
- Manual browser testing
- Complete feature verification

### Level 3: Full PF Validation (15-20 minutes)
```bash
./bulletproof-pf-validate.sh
./scripts/validate-pr87-landing-pages.sh
```
- Complete system validation
- Backend + frontend validation
- Health check verification

---

## 🔧 UPDATING THE TRAE_SOLO_EXECUTION.md

To integrate PR#87 enforcement into TRAE execution, add this step:

### Add After Backend Deployment (Step 6):

```markdown
### Step 6.5: Deploy Landing Pages

```bash
cd /opt/nexus-cos
chmod +x scripts/deploy-pr87-landing-pages.sh
./scripts/deploy-pr87-landing-pages.sh
```

**What this does:**

1. ✅ Validates source files from PR#87
2. ✅ Creates deployment directories
3. ✅ Backs up existing landing pages
4. ✅ Deploys apex landing page (815 lines)
5. ✅ Deploys beta landing page (826 lines)
6. ✅ Sets correct permissions (644, www-data:www-data)
7. ✅ Validates nginx configuration
8. ✅ Reloads nginx
9. ✅ Validates deployment
10. ✅ Generates deployment report

**Expected Output:**

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              ✅  DEPLOYMENT COMPLETED SUCCESSFULLY  ✅         ║
║                                                                ║
║              PR#87 Landing Pages Are LIVE!                     ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

Access your landing pages:
  🔗 Apex:  https://n3xuscos.online
  🔗 Beta:  https://beta.n3xuscos.online
```

**Verify:**
```bash
# Quick validation
./scripts/validate-pr87-landing-pages.sh
```
```

---

## 📁 FILE LOCATIONS

### Deployment Files
```
/opt/nexus-cos/
├── apex/
│   ├── index.html                              # Source (815 lines)
│   └── README.md
├── web/
│   └── beta/
│       ├── index.html                          # Source (826 lines)
│       └── README.md
└── scripts/
    ├── deploy-pr87-landing-pages.sh            # Deployment script
    └── validate-pr87-landing-pages.sh          # Validation script
```

### Deployed Files
```
/var/www/
├── n3xuscos.online/
│   └── index.html                              # Deployed apex (815 lines)
└── beta.n3xuscos.online/
    └── index.html                              # Deployed beta (826 lines)
```

### Documentation
```
/opt/nexus-cos/
├── PR87_LANDING_PAGE_DEPLOYMENT_CHECKLIST.md  # Full checklist
├── PR87_QUICK_DEPLOY.md                        # Quick reference
├── PR87_ENFORCEMENT_INTEGRATION.md             # This file
├── LANDING_PAGE_DEPLOYMENT.md                  # Original guide (from PR#87)
├── TRAE_SOLO_EXECUTION.md                      # TRAE framework
└── PF_BULLETPROOF_GUIDE.md                     # PF guide
```

### Backups
```
/opt/nexus-cos/backups/pr87/
├── apex_index.html.20250108_123456             # Timestamped backups
└── beta_index.html.20250108_123456
```

---

## ⚙️ CONFIGURATION REQUIREMENTS

### Nginx Configuration

**Required for Apex:**
```nginx
server {
    listen 443 ssl http2;
    server_name n3xuscos.online www.n3xuscos.online;
    
    root /var/www/n3xuscos.online;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /health/gateway {
        proxy_pass http://localhost:4000/health;
    }
}
```

**Required for Beta:**
```nginx
server {
    listen 443 ssl http2;
    server_name beta.n3xuscos.online;
    
    root /var/www/beta.n3xuscos.online;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /v-suite/prompter/health {
        proxy_pass http://localhost:3002/health;
    }
}
```

### SSL Certificates

**Required:**
- `/etc/nginx/ssl/apex/n3xuscos.online.crt`
- `/etc/nginx/ssl/apex/n3xuscos.online.key`

**Issuer:** IONOS (no Let's Encrypt)

---

## 🎯 SUCCESS CRITERIA

### Deployment Success
- ✅ Both files deployed (apex: 815 lines, beta: 826 lines)
- ✅ File permissions: 644
- ✅ Ownership: www-data:www-data
- ✅ Nginx configuration valid
- ✅ Nginx reloaded successfully
- ✅ Zero deployment errors

### Validation Success
- ✅ HTTPS returns 200 OK for both domains
- ✅ HTML structure valid
- ✅ Beta badge present
- ✅ All features present (theme toggle, tabs, stats, FAQ)
- ✅ Branding elements correct
- ✅ SEO tags present
- ✅ Zero validation failures

---

## 🔍 TROUBLESHOOTING INTEGRATION

### Issue: Script not found
**Cause:** Repository not up-to-date  
**Fix:**
```bash
cd /opt/nexus-cos
git pull origin main
chmod +x scripts/deploy-pr87-landing-pages.sh
chmod +x scripts/validate-pr87-landing-pages.sh
```

### Issue: Conflicts with existing landing pages
**Cause:** Custom landing pages already deployed  
**Fix:** Script automatically creates backups. Review and merge if needed.
```bash
ls -lh /opt/nexus-cos/backups/pr87/
```

### Issue: Nginx configuration conflicts
**Cause:** Custom nginx configuration  
**Fix:** Review nginx config, ensure `root` directive points to correct location
```bash
nginx -t
cat /etc/nginx/sites-available/n3xuscos.online
```

### Issue: Health checks not working
**Cause:** Backend services not deployed yet  
**Status:** EXPECTED - Health checks will work after backend deployment
**Fix:** Complete full PF deployment with backend services

---

## 📈 DEPLOYMENT WORKFLOW

### Complete PF + Landing Pages Deployment

```bash
# Step 1: Connect to VPS
ssh root@74.208.155.161

# Step 2: Navigate to repository
cd /opt/nexus-cos

# Step 3: Update repository
git pull origin main

# Step 4: Deploy backend services (PF)
./bulletproof-pf-deploy.sh

# Step 5: Deploy landing pages (PR#87)
./scripts/deploy-pr87-landing-pages.sh

# Step 6: Validate everything
./bulletproof-pf-validate.sh
./scripts/validate-pr87-landing-pages.sh

# Step 7: Check deployment reports
ls -lh PR87_DEPLOYMENT_REPORT_*.txt
cat PR87_DEPLOYMENT_REPORT_*.txt | tail -50
```

---

## 📞 SUPPORT

### For Deployment Issues
1. Review deployment logs
2. Run validation script: `./scripts/validate-pr87-landing-pages.sh`
3. Check nginx logs: `tail -f /var/log/nginx/error.log`
4. Verify file permissions: `ls -lh /var/www/*/index.html`

### For Validation Issues
1. Review validation output
2. Check specific failing checkpoint
3. Verify prerequisites (nginx running, files exist, etc.)
4. Consult full checklist: **PR87_LANDING_PAGE_DEPLOYMENT_CHECKLIST.md**

### For Integration Issues
1. Verify repository is up-to-date
2. Ensure all scripts are executable
3. Check PF deployment completed successfully
4. Review integration points in this document

---

## ✅ FINAL CHECKLIST

Before considering PR#87 deployment complete:

- [ ] Repository cloned/updated at `/opt/nexus-cos`
- [ ] Scripts are executable (`chmod +x scripts/*pr87*`)
- [ ] Deployment script executed successfully
- [ ] Validation script passed (zero failures)
- [ ] Apex landing page accessible at https://n3xuscos.online
- [ ] Beta landing page accessible at https://beta.n3xuscos.online
- [ ] Beta badge visible on beta page
- [ ] Theme toggle works (dark/light)
- [ ] All 6 module tabs functional
- [ ] Nginx configuration valid
- [ ] SSL certificates configured (IONOS)
- [ ] Deployment report generated and reviewed
- [ ] Integration with existing PF verified

---

## 🎉 COMPLETION

When all checkpoints pass, you should see:

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║              🎉 PR#87 LANDING PAGE DEPLOYMENT COMPLETE 🎉                ║
║                                                                           ║
║                    STRICT ADHERENCE VERIFIED ✅                          ║
║                                                                           ║
║  All steps completed. All validations passed. Zero errors encountered.   ║
║                                                                           ║
║  Production landing pages are live and fully functional!                 ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

Access your landing pages:
  🔗 Apex:  https://n3xuscos.online
  🔗 Beta:  https://beta.n3xuscos.online

Deployment executed with IRON FIST enforcement ✊
Zero tolerance policy: ENFORCED ✓
PF Standards: STRICTLY ADHERED TO ✓
```

---

## 🚀 PHASE 2.5 INTEGRATION NOTES

### Unified Deployment

As of Phase 2.5, PR#87 landing pages are deployed automatically by the Phase 2.5 deployment script:

```bash
# Phase 2.5 includes PR#87 deployment
cd /opt/nexus-cos
./scripts/deploy-phase-2.5-architecture.sh
```

### Validation Integration

PR#87 validation is included in Phase 2.5 validation suite:

```bash
# Validates PR#87 branding integration
./scripts/validate-phase-2.5-deployment.sh
# Section 10: PR87 INTEGRATION VALIDATION
```

### Migration Path

**From PR#87 Standalone → Phase 2.5:**

1. Existing PR#87 deployments continue to work
2. Phase 2.5 enhances with dual-domain routing
3. Adds V-Suite dashboard layer
4. Includes automated transition for Nov 17, 2025

**For New Deployments:**

Use Phase 2.5 deployment script, which includes PR#87 automatically.

### Documentation References

- **Phase 2.5 PF Directive:** `PF_PHASE_2.5_OTT_INTEGRATION.md`
- **Phase 2.5 Execution Guide:** `TRAE_SOLO_EXECUTION.md` (Steps 15-20)
- **Phase 2.5 Quick Reference:** `PHASE_2.5_QUICK_REFERENCE.md`
- **Phase 2.5 Index:** `PHASE_2.5_INDEX.md`

---

**Last Updated:** October 7, 2025  
**Version:** 1.1 PHASE 2.5 INTEGRATION EDITION  
**Author:** GitHub Copilot Agent + TRAE SOLO  
**For:** Robert White (PUABO / Nexus COS Founder)

**TRAE: This framework is production-ready and Phase 2.5 integrated. Execute with confidence.**
