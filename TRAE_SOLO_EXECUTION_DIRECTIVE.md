# TRAE Solo — Unified Execution Directive
## N3XUS COS v3.0 Governance Implementation Guide

**Governance Order:** 55-45-17
**Status:** BINDING & IMMUTABLE
**Audience:** TRAE Solo Operators

---

## Executive Summary

This document provides **complete execution instructions** for implementing and verifying N3XUS COS v3.0 governance under order 55-45-17.

**Time to Complete:** ~15 minutes
**Skill Level:** Intermediate DevOps
**Prerequisites:** Shell access, basic Git knowledge

---

## Table of Contents

1. [Pre-Flight Check](#1-pre-flight-check)
2. [Governance Verification](#2-governance-verification)
3. [Understanding Results](#3-understanding-results)
4. [Troubleshooting](#4-troubleshooting)
5. [Compliance Checklist](#5-compliance-checklist)
6. [Advanced Operations](#6-advanced-operations)

---

## 1. Pre-Flight Check

### Environment Requirements

```bash
# Verify you're in the correct directory
pwd
# Expected: /home/runner/work/nexus-cos/nexus-cos (or similar)

# Check Git status
git status
# Should be on copilot/create-governance-pr-traesolo branch

# Verify key files exist
ls -la trae-governance-verification.sh
ls -la GOVERNANCE_CHARTER_55_45_17.md
ls -la nginx.conf nginx.conf.docker nginx.conf.host
ls -la nexus/tenants/canonical_tenants.json
```

### Verify Permissions

```bash
# Make script executable (if needed)
chmod +x trae-governance-verification.sh

# Verify execution permission
ls -la trae-governance-verification.sh
# Should show: -rwxr-xr-x
```

---

## 2. Governance Verification

### Step 2.1: Run Verification Script

```bash
# Execute governance verification
./trae-governance-verification.sh
```

**Expected Output:**
```
╔══════════════════════════════════════════════════════════════════╗
║     N3XUS COS v3.0 — TRAE Governance Verification               ║
║     Canonical Scrub & Verification Order (55-45-17)             ║
╚══════════════════════════════════════════════════════════════════╝

System state: Online • Stable • Registry-Driven • Tenant-Aware • Phase-Safe

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
0️⃣ PRE-CONDITION: Verifying NGINX Handshake Injection
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ NGINX configuration includes X-N3XUS-Handshake: 55-45-17
...
```

### Step 2.2: Review Audit Report

```bash
# Display audit report
cat PHASE_1_2_CANONICAL_AUDIT_REPORT.md

# Or open in editor
nano PHASE_1_2_CANONICAL_AUDIT_REPORT.md
# vim PHASE_1_2_CANONICAL_AUDIT_REPORT.md
```

### Step 2.3: Check Exit Code

```bash
# Run verification and check exit code
./trae-governance-verification.sh
echo "Exit code: $?"
```

**Exit Codes:**
- `0` = SUCCESS (all checks passed)
- `1` = FAILURE (critical errors found)

---

## 3. Understanding Results

### Verification Phases

#### Phase 0: Pre-Condition
**Checks:** NGINX handshake injection

**Success Criteria:**
- ✅ Header `X-N3XUS-Handshake: 55-45-17` found in nginx.conf
- ✅ Applied to all three config files (nginx.conf, nginx.conf.docker, nginx.conf.host)

#### Phase 1: Phase 1 & 2 Systems
**Checks:** Core system components

**Success Criteria:**
- ✅ Backend API present
- ✅ Auth Service present
- ✅ Gateway API present
- ✅ Frontend present
- ✅ Database configured
- ✅ Redis configured

#### Phase 2: Tenant Scrub
**Checks:** Tenant registry compliance

**Success Criteria:**
- ✅ Exactly 13 tenant platforms
- ✅ 80/20 revenue split locked
- ✅ Tier 1/2 status active
- ✅ No system tenants

#### Phase 3: PMMG Media
**Checks:** Media engine compliance

**Success Criteria:**
- ✅ PMMG is only media engine
- ✅ Browser-only (no DAW installs)
- ✅ Full pipeline implemented

#### Phase 4: Founders Program
**Checks:** Beta program status

**Success Criteria:**
- ✅ Founders program active
- ✅ 30-day loop initialized
- ✅ Daily content system present

#### Phase 5: Immersive Desktop
**Checks:** Desktop implementation

**Success Criteria:**
- ✅ Windowed/panel UI present
- ✅ Session persistence implemented
- ✅ No VR dependency

#### Phase 6: VR/AR Status
**Checks:** VR/AR compliance

**Success Criteria:**
- ✅ VR/AR optional (not required)
- ✅ Disabled by default
- ✅ Non-blocking

#### Phase 7: Streaming Stack
**Checks:** Streaming services

**Success Criteria:**
- ✅ Streaming services functional
- ✅ Browser playback supported
- ✅ Handshake enforced

---

## 4. Troubleshooting

### Issue: Handshake Not Found

**Error Message:**
```
❌ FATAL: Handshake not enforced in NGINX configuration
```

**Solution:**
```bash
# Check if header exists in any config
grep -r "X-N3XUS-Handshake" nginx*.conf

# If missing, add to nginx.conf after "http {" line:
sed -i '/^http {/a\    # N3XUS Governance: Handshake 55-45-17 (REQUIRED)\n    proxy_set_header X-N3XUS-Handshake "55-45-17";' nginx.conf

# Verify addition
grep -A 2 "http {" nginx.conf

# Re-run verification
./trae-governance-verification.sh
```

### Issue: Tenant Count Mismatch

**Error Message:**
```
❌ Tenant Count: X (EXPECTED: 13)
```

**Solution:**
```bash
# Check current tenant count
cat nexus/tenants/canonical_tenants.json | jq '.tenant_count'

# Verify actual tenant entries
cat nexus/tenants/canonical_tenants.json | jq '.tenants | length'

# If mismatch, review tenant file
cat nexus/tenants/canonical_tenants.json | jq '.tenants[].name'

# Ensure exactly 13 tenants with IDs 1-13
```

### Issue: Revenue Split Not 80/20

**Error Message:**
```
❌ Revenue Split: NOT 80/20
```

**Solution:**
```bash
# Check current split
cat nexus/tenants/canonical_tenants.json | jq '.revenue_model.split'

# Should output: "80/20"

# If incorrect, verify full revenue model
cat nexus/tenants/canonical_tenants.json | jq '.revenue_model'

# Correct format:
# {
#   "split": "80/20",
#   "tenant_percentage": 80,
#   "platform_percentage": 20,
#   "enforcement": "ledger-level",
#   "configurable": false,
#   "bypassable": false
# }
```

### Issue: Script Permission Denied

**Error Message:**
```
bash: ./trae-governance-verification.sh: Permission denied
```

**Solution:**
```bash
# Make script executable
chmod +x trae-governance-verification.sh

# Verify permissions
ls -la trae-governance-verification.sh

# Re-run
./trae-governance-verification.sh
```

---

## 5. Compliance Checklist

### Pre-Deployment Verification

Before proceeding with any deployment, verify:

```bash
# 1. Run governance verification
./trae-governance-verification.sh

# 2. Confirm exit code 0
echo $?

# 3. Review audit report
cat PHASE_1_2_CANONICAL_AUDIT_REPORT.md | head -20

# 4. Verify handshake enforcement
grep -c "X-N3XUS-Handshake" nginx.conf nginx.conf.docker nginx.conf.host
# Should output: 3 (one in each file)

# 5. Verify tenant count
cat nexus/tenants/canonical_tenants.json | jq '.tenant_count'
# Should output: 13

# 6. Verify revenue split
cat nexus/tenants/canonical_tenants.json | jq '.revenue_model.split'
# Should output: "80/20"
```

### Checklist Table

| Check | Command | Expected Result |
|-------|---------|----------------|
| Governance Script | `./trae-governance-verification.sh` | Exit code 0 |
| Verified Systems | `cat PHASE_1_2_CANONICAL_AUDIT_REPORT.md \| grep "Total Verified"` | 26 systems |
| Errors | `cat PHASE_1_2_CANONICAL_AUDIT_REPORT.md \| grep "Errors:"` | 0 |
| Handshake | `grep -c X-N3XUS-Handshake nginx.conf` | ≥ 1 |
| Tenants | `cat nexus/tenants/canonical_tenants.json \| jq '.tenant_count'` | 13 |
| Revenue Split | `cat nexus/tenants/canonical_tenants.json \| jq '.revenue_model.split'` | "80/20" |

---

## 6. Advanced Operations

### Archive Audit Reports

```bash
# Create reports directory if needed
mkdir -p reports/governance

# Archive current report with timestamp
cp PHASE_1_2_CANONICAL_AUDIT_REPORT.md \
   reports/governance/audit_$(date +%Y%m%d_%H%M%S).md

# List archived reports
ls -lh reports/governance/
```

### Automated Verification

```bash
# Create a cron job for daily verification
# Edit crontab
crontab -e

# Add line (runs daily at 2 AM):
0 2 * * * cd /path/to/nexus-cos && ./trae-governance-verification.sh >> logs/governance_$(date +\%Y\%m\%d).log 2>&1
```

### CI/CD Integration

```yaml
# Example GitHub Actions workflow
name: Governance Verification

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Governance Verification
        run: |
          chmod +x trae-governance-verification.sh
          ./trae-governance-verification.sh
      
      - name: Upload Audit Report
        uses: actions/upload-artifact@v3
        with:
          name: governance-audit-report
          path: PHASE_1_2_CANONICAL_AUDIT_REPORT.md
```

### Manual Verification Commands

```bash
# Verify each component individually

# 1. Check NGINX configs
for f in nginx.conf nginx.conf.docker nginx.conf.host; do
  echo "=== $f ==="
  grep "X-N3XUS-Handshake" $f || echo "NOT FOUND"
done

# 2. Check tenant registry
echo "=== Tenant Count ==="
cat nexus/tenants/canonical_tenants.json | jq '.tenant_count'

echo "=== Revenue Split ==="
cat nexus/tenants/canonical_tenants.json | jq '.revenue_model.split'

echo "=== Tenant Names ==="
cat nexus/tenants/canonical_tenants.json | jq -r '.tenants[].name'

# 3. Check service directories
echo "=== Phase 1 Services ==="
ls -ld services/backend-api services/auth-service services/gateway 2>/dev/null || echo "Check paths"

# 4. Check frontend
echo "=== Frontend ==="
ls -ld frontend web 2>/dev/null || echo "Check paths"

# 5. Check PMMG references
echo "=== PMMG References ==="
grep -r "pmmg\|PMMG" . --include="*.yaml" --include="*.yml" | grep -v ".git" | head -5

# 6. Check streaming services
echo "=== Streaming Services ==="
ls -ld services/streaming* 2>/dev/null || echo "Check paths"
```

---

## Appendix A: File Locations

### Governance Files
- `trae-governance-verification.sh` - Main verification script
- `GOVERNANCE_CHARTER_55_45_17.md` - Governance charter
- `TRAE_GOVERNANCE_QUICK_START.md` - Quick start guide
- `PHASE_1_2_CANONICAL_AUDIT_REPORT.md` - Latest audit report

### Configuration Files
- `nginx.conf` - Main NGINX configuration
- `nginx.conf.docker` - Docker mode NGINX configuration
- `nginx.conf.host` - Host mode NGINX configuration

### Data Files
- `nexus/tenants/canonical_tenants.json` - Tenant registry
- `nexus/control/nexus_ai_guardrails.yaml` - Guardrails config

---

## Appendix B: Governance Order 55-45-17

### What Does 55-45-17 Mean?

**55-45-17** is the **governance handshake protocol** that ensures:

1. **55:** System integrity (5x5 = 25 core checkpoints)
2. **45:** Compliance validation (4x5 = 20 compliance rules)
3. **17:** Tenant governance (13 tenants + 4 platform layers)

### Handshake Header

**Format:** `X-N3XUS-Handshake: 55-45-17`

**Purpose:**
- Validates request origin
- Enforces governance at gateway
- Ensures service compliance
- Prevents unauthorized access

**Implementation:**
- **Injection Point:** NGINX gateway
- **Validation Point:** All services
- **Bypass Rule:** Zero tolerance
- **Enforcement:** Mandatory

---

## Appendix C: Support & Escalation

### Self-Service

1. Review GOVERNANCE_CHARTER_55_45_17.md
2. Check TRAE_GOVERNANCE_QUICK_START.md
3. Run verification script: `./trae-governance-verification.sh`
4. Review audit report: `PHASE_1_2_CANONICAL_AUDIT_REPORT.md`

### Escalation Path

For issues requiring escalation:

1. **Governance Violations** - Contact Executive Authority
2. **Technical Freeze Violations** - Contact Executive Authority
3. **Handshake Failures** - Review NGINX configuration
4. **Tenant Registry Issues** - Review tenant documentation

**Executive Authority:** Bobby Blanco / TRAE Solo

---

## Appendix D: Document Control

**Document:** TRAE_SOLO_EXECUTION_DIRECTIVE.md
**Version:** 1.0.0
**Status:** ACTIVE & BINDING
**Last Updated:** 2026-01-02
**Next Review:** Public Alpha Launch

### Change Log

| Version | Date | Changes | Approved |
|---------|------|---------|----------|
| 1.0.0 | 2026-01-02 | Initial execution directive | Executive |

---

## Final Notes

This directive is **BINDING** under Governance Order 55-45-17.

**Key Points:**
- ✅ Always run verification before deployment
- ✅ Archive all audit reports
- ✅ Respect technical freeze
- ✅ Maintain handshake enforcement
- ✅ Verify tenant registry integrity

**Governance Status:** ACTIVE
**Enforcement:** MANDATORY
**Compliance:** REQUIRED

---

**For questions or issues, refer to GOVERNANCE_CHARTER_55_45_17.md or escalate to Executive Authority.**
