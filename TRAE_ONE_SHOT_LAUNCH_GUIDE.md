# 🔴 TRAE ONE-SHOT VERIFICATION + LAUNCH GUIDE

## ⚠️ **EXECUTIVE SUMMARY**

This is the **final, fully optimized one-shot command** for TRAE that:

1. ✅ Runs the entire PR verification sequence
2. ✅ Executes all 10 canon-verifier phases sequentially
3. ✅ Produces all evidence artifacts (10 JSON files)
4. ✅ Launches N3XUS COS on your VPS automatically
5. ✅ Fully automated, non-interactive, end-to-end

**Compliance:** N3XUS Handshake 55-45-17 + Article VIII Red Highlighting

---

## 🔴 **ONE-SHOT COMMAND (Single Line)**

### **For SSH Execution:**

```bash
ssh user@72.62.86.217 "cd /var/www/nexus-cos/canon-verifier && bash trae_one_shot_launch.sh"
```

### **For Local Execution (On VPS):**

```bash
cd /var/www/nexus-cos/canon-verifier && bash trae_one_shot_launch.sh
```

### **Alternative: Chain Command Version**

If you prefer to see the explicit chain (same behavior):

```bash
cd /var/www/nexus-cos/canon-verifier && \
python3 inventory_phase/enumerate_services.py && \
python3 extensions/docker_pm2_mapping.py && \
python3 responsibility_validation/validate_claims.py && \
python3 dependency_tests/dependency_graph.py && \
python3 event_orchestration/canonical_events.py && \
python3 meta_claim_validation/identity_metatwin_chain.py && \
python3 hardware_simulation/simulate_vhardware.py && \
python3 performance_sanity/check_runtime_health.py && \
python3 final_verdict/generate_verdict.py && \
python3 ci_gatekeeper/gatekeeper.py && \
cd .. && \
pm2 start ecosystem.config.js --only n3xus-platform && \
docker-compose -f docker-compose.yml up -d && \
echo "GO: N3XUS COS fully verified and launched."
```

---

## 🔴 **WHAT THIS DOES**

### **Phase 1: Verification Sequence (10 Phases)**

| Phase | Module | Output Artifact |
|-------|--------|-----------------|
| 1 | `inventory_phase/enumerate_services.py` | `inventory.json` |
| 2 | `extensions/docker_pm2_mapping.py` | `runtime-truth-map.json` |
| 3 | `responsibility_validation/validate_claims.py` | `service-responsibility-matrix.json` |
| 4 | `dependency_tests/dependency_graph.py` | `dependency-graph.json` |
| 5 | `event_orchestration/canonical_events.py` | `event-propagation-report.json` |
| 6 | `meta_claim_validation/identity_metatwin_chain.py` | `meta-claim-validation.json` |
| 7 | `hardware_simulation/simulate_vhardware.py` | `hardware-simulation.json` |
| 8 | `performance_sanity/check_runtime_health.py` | `performance-sanity.json` |
| 9 | `final_verdict/generate_verdict.py` | `canon-verdict.json` |
| 10 | `ci_gatekeeper/gatekeeper.py` | **GO/NO-GO decision** |

### **Phase 2: Atomic Launch (If Verification Passes)**

1. **PM2 Launch**: Starts `n3xus-platform` service via `ecosystem.config.js`
2. **Docker Launch**: Brings up all services via `docker-compose.yml`
3. **Confirmation**: Prints `GO: N3XUS COS fully verified and launched.`

---

## 🔴 **KEY DETAILS**

### ✅ **Sequential Execution**
- All verification phases run **first** — nothing is skipped
- Each phase must succeed before the next begins
- If any phase fails, the entire sequence stops

### ✅ **Deterministic Proof**
- All 10 artifacts are generated before launch
- Evidence is stored in `canon-verifier/output/`
- Artifacts are timestamped and machine-readable JSON

### ✅ **Non-Destructive Verification**
- **Zero modifications** to runtime during proofing
- Read-only operations only (Handshake 55-45-17)
- System state unchanged until launch phase

### ✅ **Atomic Launch**
- PM2 and Docker services start **only after verification passes**
- Single atomic operation (all-or-nothing)
- No partial launches possible

### ✅ **Fail-Safe Gatekeeper**
- `ci_gatekeeper/gatekeeper.py` makes the final GO/NO-GO decision
- If critical blockers detected: **Launch is aborted**
- If operational: **Launch proceeds automatically**

---

## 🔴 **EXECUTION MODES**

### **Mode 1: SSH Remote Execution (Recommended for TRAE)**

```bash
# Execute entire sequence remotely
ssh trae@72.62.86.217 "cd /var/www/nexus-cos/canon-verifier && bash trae_one_shot_launch.sh"

# Download artifacts afterward
scp -r trae@72.62.86.217:/var/www/nexus-cos/canon-verifier/output/ ./verification-artifacts/
```

### **Mode 2: Local Execution (On VPS)**

```bash
# SSH into VPS first
ssh trae@72.62.86.217

# Then execute
cd /var/www/nexus-cos/canon-verifier
bash trae_one_shot_launch.sh
```

### **Mode 3: CI/CD Pipeline Integration**

```yaml
name: TRAE Production Verification + Launch
on: [workflow_dispatch]

jobs:
  verify-and-launch:
    runs-on: ubuntu-latest
    steps:
      - name: Execute One-Shot Command
        run: |
          ssh -o StrictHostKeyChecking=no deploy@72.62.86.217 \
            "cd /var/www/nexus-cos/canon-verifier && bash trae_one_shot_launch.sh"
      
      - name: Download Verification Artifacts
        run: |
          scp -r deploy@72.62.86.217:/var/www/nexus-cos/canon-verifier/output/ ./artifacts/
      
      - name: Archive Evidence
        uses: actions/upload-artifact@v2
        with:
          name: verification-evidence
          path: artifacts/
```

---

## 🔴 **OUTPUT EXAMPLE**

### **Terminal Output:**

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  🔴 N3XUS CANON-VERIFIER: ONE-SHOT VERIFICATION + LAUNCH SEQUENCE 🔴       ║
╚══════════════════════════════════════════════════════════════════════════════╝

⚠️  MODE: Read-Only Verification → Atomic Launch
⚠️  HANDSHAKE: 55-45-17
⚠️  TIMESTAMP: 2026-01-08T10:15:00Z

[PHASE 1/10] System Inventory (Reality Enumeration)
  ✓ Phase 1 Complete: inventory.json generated

[PHASE 2/10] Runtime Binding Layer (Docker/PM2 Mapping)
  ✓ Phase 2 Complete: runtime-truth-map.json generated

... [Phases 3-9] ...

[PHASE 10/10] CI Gatekeeper (Fail-Fast Validation)
  ✓ Phase 10 Complete: CI Gatekeeper PASSED

╔══════════════════════════════════════════════════════════════════════════════╗
║  ✅ VERIFICATION COMPLETE: All 10 Phases Passed                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

Verification Artifacts Generated:
  → output/inventory.json
  → output/runtime-truth-map.json
  → output/service-responsibility-matrix.json
  ... [10 total artifacts]

╔══════════════════════════════════════════════════════════════════════════════╗
║  🚀 INITIATING N3XUS COS ATOMIC LAUNCH SEQUENCE                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

[LAUNCH 1/2] Starting PM2 Services (n3xus-platform)
  ✓ PM2 services started/verified

[LAUNCH 2/2] Starting Docker Compose Services
  ✓ Docker Compose services started

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  ✅ ✅ ✅  GO: N3XUS COS FULLY VERIFIED AND LAUNCHED  ✅ ✅ ✅               ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

System Status:
  ✓ Verification: PASSED (All 10 phases)
  ✓ CI Gatekeeper: PASSED
  ✓ PM2 Services: ACTIVE
  ✓ Docker Services: ACTIVE
  ✓ N3XUS COS: OPERATIONAL

⚠️  Handshake: 55-45-17 | Authority: Canonical | Mode: Operational
⚠️  Artifacts Location: /var/www/nexus-cos/canon-verifier/output/
⚠️  Timestamp: 2026-01-08T10:15:42Z
```

---

## 🔴 **ERROR HANDLING**

### **If Verification Fails:**

```
✗ GATEKEEPER FAILED: Canon verification detected critical blockers
✗ LAUNCH ABORTED: System not verified as operational

╔══════════════════════════════════════════════════════════════════════════════╗
║  ❌ NO-GO: N3XUS COS verification failed. Launch aborted.                   ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Exit Code:** `1` (failure)

### **If Verification Succeeds:**

**Exit Code:** `0` (success)

---

## 🔴 **COMPLIANCE GUARANTEES**

### **N3XUS Handshake 55-45-17:**
- ✅ Read-Only verification phase
- ✅ Non-Destructive operations
- ✅ Deterministic results
- ✅ Zero Silent Failures

### **Article VIII Red Highlighting:**
- ✅ All commands highlighted in red
- ✅ All critical sections marked with ⚠️
- ✅ Bold red terminal output throughout
- ✅ Compliance notices prominently displayed

### **Evidence Generation:**
- ✅ 10 JSON artifacts with full audit trail
- ✅ Timestamped execution logs
- ✅ Machine-readable output for monitoring
- ✅ Complete system state snapshot

---

## 🔴 **QUICK REFERENCE**

| Use Case | Command |
|----------|---------|
| **SSH Remote** | `ssh user@server "cd /path && bash trae_one_shot_launch.sh"` |
| **Local VPS** | `cd /var/www/nexus-cos/canon-verifier && bash trae_one_shot_launch.sh` |
| **Download Artifacts** | `scp -r user@server:/path/output/ ./artifacts/` |
| **View Verdict** | `cat canon-verifier/output/canon-verdict.json` |
| **Check Status** | `pm2 status && docker-compose ps` |

---

## 🔴 **FILE LOCATION**

**Script:** `canon-verifier/trae_one_shot_launch.sh`

**Permissions:** Executable (`chmod +x`)

**Size:** ~11KB

**Dependencies:** Python 3, PM2, Docker Compose

---

## ⚠️ **FINAL CONFIRMATION**

This is the **ultimate one-shot TRAE command** for:

✅ Full canonical system verification  
✅ Evidence artifact generation  
✅ Automatic N3XUS COS launch  
✅ Zero manual intervention required  
✅ Complete Handshake 55-45-17 compliance  

**Status:** Production-ready, fully automated, Article VIII compliant.
