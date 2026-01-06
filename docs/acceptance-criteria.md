# Acceptance Criteria: N3XUS v-COS Canonization & n3xus-net Architecture

**Version:** 1.0.0  
**Status:** Master PR Acceptance Criteria  
**Network:** n3xus-net  
**Handshake:** 55-45-17  
**Date:** January 2026

---

## Overview

This document defines the acceptance criteria for the Master PR: "Canonize N3XUS v‑COS identity and n3xus‑net sovereign architecture." All criteria must be met for the PR to be considered complete and ready for production deployment.

---

## Phase 1: Branding Updates to N3XUS v-COS

### AC-1.1: Logo Updates

**Criteria:**
- [ ] All logo.svg files updated from "Nexus COS" to "N3XUS v-COS"
- [ ] Logo files maintain visual design (colors, dimensions, styling)
- [ ] Only text content modified (metadata change only)
- [ ] No TRAE-provided asset alterations beyond text

**Files:**
- `branding/logo.svg`
- `admin/public/assets/branding/logo.svg`
- `creator-hub/public/assets/branding/logo.svg`
- `frontend/public/assets/branding/logo.svg`

**Verification:**
```bash
# Check all logos contain "N3XUS v-COS"
grep -r "N3XUS v-COS" branding/ admin/ creator-hub/ frontend/ | grep logo.svg
```

**Expected Output:** 4 files containing "N3XUS v-COS"

---

### AC-1.2: Brand Bible Updates

**Criteria:**
- [ ] Official name updated to "N3XUS v-COS"
- [ ] Taglines reference "Virtual Creative Operating System"
- [ ] n3xus-net references included
- [ ] v-Suite integration mentioned
- [ ] Sovereign architecture referenced

**File:**
- `brand/bible/N3XUS_COS_Brand_Bible.md`

**Verification:**
```bash
# Verify key branding terms
grep "N3XUS v-COS" brand/bible/N3XUS_COS_Brand_Bible.md
grep "n3xus-net" brand/bible/N3XUS_COS_Brand_Bible.md
grep "Virtual Creative Operating System" brand/bible/N3XUS_COS_Brand_Bible.md
```

**Expected Output:** Multiple matches for each term

---

## Phase 2: Network Unification under n3xus-net

### AC-2.1: Network Architecture Documentation

**Criteria:**
- [ ] n3xus-net README created with comprehensive architecture
- [ ] Internal hostname schema documented
- [ ] Service discovery patterns explained
- [ ] Security architecture detailed
- [ ] Network topology diagram included (ASCII art acceptable)

**File:**
- `docs/n3xus-net/README.md`

**Verification:**
```bash
# Check documentation exists and is comprehensive
test -f docs/n3xus-net/README.md
wc -l docs/n3xus-net/README.md  # Should be >200 lines

# Check key concepts documented
grep "v-stream\|v-auth\|v-platform\|v-suite\|v-content" docs/n3xus-net/README.md
grep "55-45-17" docs/n3xus-net/README.md
```

**Expected Output:** File exists with comprehensive content

---

### AC-2.2: Internal Hostname Schema

**Criteria:**
- [ ] All services use `v-` prefix for virtual/sovereign designation
- [ ] Gateway uses `n3xus-gateway` naming
- [ ] Hostname table includes: service name, hostname, port, purpose
- [ ] Database services documented: v-postgres, v-redis, v-mongo

**Verification:**
```bash
# Verify hostname schema documented
grep -E "(v-stream|v-auth|v-platform|v-suite|v-content|v-postgres|v-redis|v-mongo)" \
  docs/n3xus-net/README.md | wc -l
```

**Expected Output:** At least 8 matches (one per core service)

---

## Phase 3: NGINX Gateway Alignment

### AC-3.1: Main NGINX Configuration

**Criteria:**
- [ ] n3xus-net upstreams added with `v-` prefix
- [ ] Legacy PF upstreams maintained for backward compatibility
- [ ] Handshake header comment updated to "N3XUS v-COS"
- [ ] Network architecture comment added

**File:**
- `nginx.conf`

**Verification:**
```bash
# Check for n3xus-net upstreams
grep "upstream v_stream\|upstream v_auth\|upstream v_platform" nginx.conf

# Check handshake header
grep "N3XUS v-COS.*Handshake" nginx.conf
grep "n3xus-net" nginx.conf
```

**Expected Output:** All n3xus-net upstreams present, updated comments

---

### AC-3.2: Docker Mode Configuration

**Criteria:**
- [ ] Docker container names used for upstreams
- [ ] n3xus-net upstreams added
- [ ] Comments reference "N3XUS v-COS" and "n3xus-net"
- [ ] Legacy services maintained

**File:**
- `nginx.conf.docker`

**Verification:**
```bash
# Check Docker mode configuration
grep "N3XUS v-COS" nginx.conf.docker
grep "server v-stream:3000" nginx.conf.docker
grep "server v-auth:4000" nginx.conf.docker
```

**Expected Output:** Updated branding and n3xus-net services

---

### AC-3.3: Host Mode Configuration

**Criteria:**
- [ ] Localhost with ports used for upstreams
- [ ] n3xus-net upstreams added with localhost
- [ ] Comments reference "N3XUS v-COS" and "n3xus-net"
- [ ] Legacy services maintained

**File:**
- `nginx.conf.host`

**Verification:**
```bash
# Check host mode configuration
grep "N3XUS v-COS" nginx.conf.host
grep "server localhost:3000" nginx.conf.host
grep "server localhost:4000" nginx.conf.host
```

**Expected Output:** Updated branding and localhost mappings

---

### AC-3.4: 29 Services Configuration

**Criteria:**
- [ ] Header updated to "N3XUS v-COS"
- [ ] Network reference added to header
- [ ] Service upstreams maintained (no breaking changes)

**File:**
- `nginx-29-services.conf`

**Verification:**
```bash
# Check configuration header
head -5 nginx-29-services.conf | grep "N3XUS v-COS"
head -5 nginx-29-services.conf | grep "n3xus-net"
```

**Expected Output:** Updated header with branding and network reference

---

## Phase 4: Documentation Scaffolding

### AC-4.1: v-COS Documentation

**Criteria:**
- [ ] `docs/v-COS/README.md` created
- [ ] Platform overview documented
- [ ] v-Suite integration explained
- [ ] Navigation model detailed (Desktop → Module → App)
- [ ] Technical stack documented
- [ ] Service integration examples provided

**Verification:**
```bash
# Check v-COS documentation
test -f docs/v-COS/README.md
grep "v-Suite\|V-Screen\|V-Caster\|V-Stage\|V-Prompter" docs/v-COS/README.md
grep "Desktop.*Module.*App" docs/v-COS/README.md
```

**Expected Output:** Comprehensive v-COS platform documentation

---

### AC-4.2: n3xus-net Documentation

**Criteria:**
- [ ] `docs/n3xus-net/README.md` created
- [ ] Network topology documented
- [ ] Internal hostname schema detailed
- [ ] Security architecture explained
- [ ] Handshake protocol documented
- [ ] Configuration examples provided

**Verification:**
```bash
# Check n3xus-net documentation
test -f docs/n3xus-net/README.md
grep "55-45-17" docs/n3xus-net/README.md
grep "sovereign\|Sovereign" docs/n3xus-net/README.md
```

**Expected Output:** Complete network architecture documentation

---

### AC-4.3: Sovereign Genesis Documentation

**Criteria:**
- [ ] `docs/Sovereign-Genesis/README.md` created
- [ ] Sovereignty principles documented
- [ ] Genesis architecture explained
- [ ] Handshake protocol detailed
- [ ] Data sovereignty covered
- [ ] Governance model documented

**Verification:**
```bash
# Check Sovereign Genesis documentation
test -f docs/Sovereign-Genesis/README.md
grep "Sovereign\|sovereignty" docs/Sovereign-Genesis/README.md | wc -l
grep "55-45-17" docs/Sovereign-Genesis/README.md
```

**Expected Output:** Foundational architecture documentation (>50 sovereignty mentions)

---

### AC-4.4: SOVEREIGN_HANDOFF_SIGNED.md Preservation

**Criteria:**
- [ ] If file exists, it must remain unmodified
- [ ] No alterations to content, permissions, or metadata
- [ ] File integrity verified via checksum (if exists)

**Verification:**
```bash
# Check if file exists and is preserved
if [ -f SOVEREIGN_HANDOFF_SIGNED.md ]; then
  git diff --exit-code SOVEREIGN_HANDOFF_SIGNED.md
  echo "File preserved: YES"
else
  echo "File does not exist: OK"
fi
```

**Expected Output:** Either file preserved or does not exist

---

## Phase 5: Agent Instructions & Acceptance Criteria

### AC-5.1: Agent Deployment Procedures

**Criteria:**
- [ ] `docs/agent-deployment-procedures.md` created
- [ ] Prerequisites documented
- [ ] Step-by-step deployment procedures provided
- [ ] Infrastructure, database, services, gateway, v-Suite procedures included
- [ ] Automated scripts documented
- [ ] Rollback procedures included
- [ ] Troubleshooting guide provided

**Verification:**
```bash
# Check deployment procedures
test -f docs/agent-deployment-procedures.md
grep "Procedure\|Step" docs/agent-deployment-procedures.md | wc -l
```

**Expected Output:** Comprehensive deployment documentation (>10 procedures/steps)

---

### AC-5.2: Acceptance Criteria Document

**Criteria:**
- [ ] This document (`docs/acceptance-criteria.md`) created
- [ ] All 5 phases covered
- [ ] Each criterion has verification commands
- [ ] Expected outputs documented
- [ ] Testable and measurable criteria

**Verification:**
```bash
# Check acceptance criteria
test -f docs/acceptance-criteria.md
grep "AC-[0-9]" docs/acceptance-criteria.md | wc -l
```

**Expected Output:** This document with >20 acceptance criteria

---

### AC-5.3: Verification Scripts

**Criteria:**
- [ ] Automated verification script created
- [ ] All acceptance criteria automated where possible
- [ ] Exit codes: 0 for pass, non-zero for fail
- [ ] Clear output showing pass/fail status

**File:**
- `scripts/verify-pr-acceptance.sh`

**Verification:**
```bash
# Run verification script
./scripts/verify-pr-acceptance.sh
echo "Exit code: $?"
```

**Expected Output:** Exit code 0, all checks passing

---

## Overall Acceptance

### Master Acceptance Criteria

**ALL of the following must be true:**

1. ✅ All Phase 1 criteria met (Branding)
2. ✅ All Phase 2 criteria met (Network)
3. ✅ All Phase 3 criteria met (NGINX)
4. ✅ All Phase 4 criteria met (Documentation)
5. ✅ All Phase 5 criteria met (Agent Instructions)
6. ✅ No breaking changes to existing functionality
7. ✅ All documentation comprehensive and accurate
8. ✅ Verification scripts pass successfully
9. ✅ Code review approved
10. ✅ CI/CD pipelines passing

### Final Verification Command

```bash
#!/bin/bash
# Run all acceptance criteria checks

set -e

echo "=== N3XUS v-COS PR Acceptance Verification ==="

echo "[1/5] Verifying branding updates..."
./scripts/verify-branding.sh

echo "[2/5] Verifying network documentation..."
./scripts/verify-network-docs.sh

echo "[3/5] Verifying NGINX configurations..."
./scripts/verify-nginx-configs.sh

echo "[4/5] Verifying documentation scaffolding..."
./scripts/verify-documentation.sh

echo "[5/5] Verifying agent instructions..."
./scripts/verify-agent-instructions.sh

echo "✓ All acceptance criteria met!"
echo "PR is ready for approval and merge."
```

---

## Sign-Off

### Required Approvals

- [ ] Technical Lead: Architecture Review
- [ ] Security Team: Security Audit
- [ ] DevOps Team: Deployment Procedures Review
- [ ] Product Owner: Brand & Documentation Review
- [ ] Platform Team: Final Acceptance

### Deployment Authorization

Once all acceptance criteria are met and approvals obtained:

```
AUTHORIZED FOR PRODUCTION DEPLOYMENT
Date: _______________
Authorized By: _______________
Signature: _______________
```

---

**Status:** Acceptance Criteria Defined  
**Maintained By:** N3XUS Platform Team  
**Last Updated:** January 2026  
**Version:** 1.0.0
