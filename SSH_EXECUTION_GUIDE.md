# <span style="color:red">**Canon-Verifier SSH Execution Guide for TRAE**</span>

## <span style="color:red">**🔴 N3XUS LAW Compliant Single-Line Execution 🔴**</span>

---

## <span style="color:red">**⚠️ CRITICAL: Single-Line SSH Command ⚠️**</span>

For TRAE to execute canon-verifier on the VPS (72.62.86.217) or any remote server:

### <span style="color:red">**🔴 Full Verification (RECOMMENDED) 🔴**</span>

```bash
# ⚠️ EXECUTE THIS COMMAND ⚠️
ssh user@72.62.86.217 "cd /path/to/nexus-cos && bash canon-verifier/ssh_execute.sh"
```

### <span style="color:red">**Alternative: Direct Python Execution**</span>

```bash
# ⚠️ ALTERNATIVE COMMAND ⚠️
ssh user@72.62.86.217 "cd /path/to/nexus-cos/canon-verifier && python3 run_verification.py && echo 'Artifacts generated in output/'"
```

### <span style="color:red">**With Output Capture**</span>

```bash
# ⚠️ COMMAND WITH LOGGING ⚠️
ssh user@72.62.86.217 "cd /path/to/nexus-cos && bash canon-verifier/ssh_execute.sh" 2>&1 | tee canon_verification_$(date +%Y%m%d_%H%M%S).log
```

---

## <span style="color:red">**🔴 Execution Order (N3XUS LAW Compliant) 🔴**</span>

The execution follows this strict order:

1. <span style="color:red">**Navigate**</span> to repository root
2. <span style="color:red">**Verify**</span> canon-verifier directory exists
3. <span style="color:red">**Execute**</span> `run_verification.py` orchestrator
4. <span style="color:red">**Generate**</span> all 10 JSON artifacts in `output/`
5. <span style="color:red">**Report**</span> exit code and artifact locations

---

## What Happens

### Phase Execution (Automatic)

The orchestrator runs all phases in sequence:

1. ✅ System Inventory
2. ✅ Service Responsibility Validation
3. ✅ Dependency Graph
4. ✅ Event Orchestration
5. ✅ Meta-Claim Validation
6. ✅ Hardware Simulation
7. ✅ Performance Sanity
8. ✅ Docker/PM2 Mapping (Extension)
9. ✅ Service Responsibility Matrix (Extension)
10. ✅ Final Verdict

### Artifacts Generated

All files created in `canon-verifier/output/`:

- `inventory.json` - System inventory
- `service-responsibility-matrix.json` - Service validation
- `dependency-graph.json` - Dependencies
- `event-propagation-report.json` - Event bus
- `meta-claim-validation.json` - Meta-claims
- `hardware-simulation.json` - Hardware logic
- `performance-sanity.json` - Health checks
- `runtime-truth-map.json` - Docker/PM2 mapping
- `service-responsibility-matrix-complete.json` - Complete SRM
- `canon-verdict.json` - **Final verdict**

---

## Exit Codes

- `0` - All phases completed successfully
- `1` - One or more phases failed

---

## Guarantees

### N3XUS LAW Compliance ✅

- **Read-Only**: No system modifications
- **Non-Destructive**: No state changes
- **Deterministic**: Same inputs → same outputs
- **Handshake 55-45-17**: Full compliance

### Safety ✅

- No service restarts
- No configuration changes
- No code modifications
- No database writes
- No deployment actions

---

## <span style="color:red">**🔴 Example Full Session 🔴**</span>

```bash
# ⚠️ CRITICAL: Connect and execute ⚠️
ssh trae@72.62.86.217 "cd /var/www/nexus-cos && bash canon-verifier/ssh_execute.sh"

# Output:
# ======================================================================================================
# N3XUS CANON-VERIFIER - SSH EXECUTION MODE
# ======================================================================================================
# Mode: Read-Only | Non-Destructive | Deterministic
# Handshake: 55-45-17
# Timestamp: 2026-01-08T09:35:00Z
#
# Starting Canon-Verifier Execution...
#
# ======================================================================================================
# PHASE 1-8: MAIN VERIFICATION ORCHESTRATOR
# ======================================================================================================
# [... all phases execute ...]
#
# ======================================================================================================
# VERIFICATION COMPLETE - EXIT CODE: 0
# ======================================================================================================
#
# ✓ Artifacts generated successfully
#
# Generated Artifacts:
#   ✓ inventory.json (4230 bytes)
#   ✓ service-responsibility-matrix.json (4120 bytes)
#   ✓ dependency-graph.json (3120 bytes)
#   ✓ event-propagation-report.json (2880 bytes)
#   ✓ meta-claim-validation.json (2560 bytes)
#   ✓ hardware-simulation.json (1950 bytes)
#   ✓ performance-sanity.json (2100 bytes)
#   ✓ runtime-truth-map.json (3400 bytes)
#   ✓ service-responsibility-matrix-complete.json (5670 bytes)
#   ✓ canon-verdict.json (2450 bytes)
#
# ======================================================================================================
# EXECUTION SUMMARY
# ======================================================================================================
# Verification Exit Code: 0
# Artifacts Location: /var/www/nexus-cos/canon-verifier/output/
# Execution Mode: SSH | Non-Destructive | Read-Only
# Handshake Compliance: 55-45-17
# ======================================================================================================
```

---

## <span style="color:red">**🔴 Retrieve Artifacts 🔴**</span>

After execution, download artifacts:

```bash
# ⚠️ Download all artifacts ⚠️
scp -r trae@72.62.86.217:/var/www/nexus-cos/canon-verifier/output/ ./canon_artifacts_$(date +%Y%m%d)/

# ⚠️ Download just the verdict ⚠️
scp trae@72.62.86.217:/var/www/nexus-cos/canon-verifier/output/canon-verdict.json ./

# ⚠️ View verdict remotely ⚠️
ssh trae@72.62.86.217 "cat /var/www/nexus-cos/canon-verifier/output/canon-verdict.json" | jq .
```

---

## Troubleshooting

### "canon-verifier directory not found"

Ensure you're in the repository root:
```bash
ssh trae@72.62.86.217 "cd /var/www/nexus-cos && bash canon-verifier/ssh_execute.sh"
```

### "Python3 not found"

Check Python installation:
```bash
ssh trae@72.62.86.217 "which python3"
```

### "Permission denied"

Make script executable:
```bash
ssh trae@72.62.86.217 "chmod +x /var/www/nexus-cos/canon-verifier/ssh_execute.sh"
```

---

## CI/CD Integration

For automated execution in pipelines:

```yaml
- name: Run Canon Verifier via SSH
  run: |
    ssh -o StrictHostKeyChecking=no deploy@server \
      "cd /var/www/nexus-cos && bash canon-verifier/ssh_execute.sh"
  
- name: Download Artifacts
  run: |
    scp -r deploy@server:/var/www/nexus-cos/canon-verifier/output/ ./artifacts/
  
- name: Archive Artifacts
  uses: actions/upload-artifact@v2
  with:
    name: canon-verification-reports
    path: artifacts/
```

---

## <span style="color:red">**🔴 Quick Reference 🔴**</span>

| <span style="color:red">**Task**</span> | <span style="color:red">**Command**</span> |
|------|---------|
| <span style="color:red">**Run verification**</span> | `ssh user@host "cd /path && bash canon-verifier/ssh_execute.sh"` |
| <span style="color:red">**Check verdict**</span> | `ssh user@host "cat /path/canon-verifier/output/canon-verdict.json" \| jq .verdict.executive_truth` |
| <span style="color:red">**Download artifacts**</span> | `scp -r user@host:/path/canon-verifier/output/ ./` |
| <span style="color:red">**View logs**</span> | Add `2>&1 \| tee verification.log` to command |

---

## <span style="color:red">**🔴 CRITICAL STATUS 🔴**</span>

**<span style="color:red">Status:</span>** <span style="color:red">**Ready for TRAE execution on staging/production VPS**</span>

**<span style="color:red">Compliance:</span>** <span style="color:red">**Full N3XUS LAW 55-45-17 compliance guaranteed**</span>

**<span style="color:red">Safety:</span>** <span style="color:red">**100% read-only, non-destructive, deterministic**</span>
