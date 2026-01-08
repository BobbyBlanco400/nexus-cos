# Canon-Verifier: Modular Verification Harness

**Full-stack non-destructive system truth validation framework**

Handshake Compliance: **55-45-17**  
Execution Mode: **Read-Only | Non-Destructive | Deterministic**  
Authority: **Canonical**  
Failure Tolerance: **Zero Silent Failures**

---

## Overview

Canon-verifier is a modular, machine-executable verification harness that orchestrates comprehensive system truth validation across all layers of N3XUS COS.

This is the **full atomic implementation** with:
- ✅ Organized phase modules
- ✅ Runtime binding layer (Docker + PM2)
- ✅ Service Responsibility Matrix (SRM)
- ✅ CI Gatekeeper mode
- ✅ Structured JSON artifacts

---

## Directory Structure

```
canon-verifier/
├─ inventory_phase/
│  └─ enumerate_services.py           # System inventory enumeration
├─ responsibility_validation/
│  └─ validate_claims.py              # Service responsibility proof
├─ dependency_tests/
│  └─ dependency_graph.py             # Dependency graph mapping
├─ event_orchestration/
│  └─ canonical_events.py             # Event bus verification
├─ meta_claim_validation/
│  └─ identity_metatwin_chain.py      # Meta-claim testing
├─ hardware_simulation/
│  └─ simulate_vhardware.py           # Hardware orchestration logic
├─ performance_sanity/
│  └─ check_runtime_health.py         # Performance & deadlock detection
├─ final_verdict/
│  └─ generate_verdict.py             # 4-category verdict generation
├─ ci_gatekeeper/
│  └─ gatekeeper.py                   # CI fail-fast validation
├─ extensions/
│  ├─ docker_pm2_mapping.py           # Docker/PM2 → repo mapping
│  └─ service_responsibility_matrix.py # Complete SRM generation
├─ output/                            # Generated JSON artifacts
│  ├─ inventory.json
│  ├─ service-responsibility-matrix.json
│  ├─ dependency-graph.json
│  ├─ event-propagation-report.json
│  ├─ meta-claim-validation.json
│  ├─ hardware-simulation.json
│  ├─ performance-sanity.json
│  ├─ runtime-truth-map.json
│  ├─ service-responsibility-matrix-complete.json
│  └─ canon-verdict.json
└─ run_verification.py                # Main orchestrator
```

---

## Quick Start

### Run Complete Verification

```bash
# Execute all phases
cd canon-verifier
python3 run_verification.py
```

### Run Individual Phases

```bash
# Phase 1: System Inventory
python3 inventory_phase/enumerate_services.py

# Phase 2: Service Responsibility
python3 responsibility_validation/validate_claims.py

# Phase 3: Dependency Graph
python3 dependency_tests/dependency_graph.py

# Extensions: Runtime Mapping
python3 extensions/docker_pm2_mapping.py

# Extensions: Service Responsibility Matrix
python3 extensions/service_responsibility_matrix.py

# Final: Generate Verdict
python3 final_verdict/generate_verdict.py
```

### Run CI Gatekeeper

```bash
# After running verification, check CI status
python3 ci_gatekeeper/gatekeeper.py

# Exit codes:
#   0 = CI PASS (canon integrity verified)
#   1 = CI FAIL (canon truth broken)
```

---

## Verification Phases

### Phase 1: System Inventory (Reality Enumeration)
- Enumerates Docker containers (running + stopped)
- Enumerates PM2 processes with metrics
- Lists listening ports
- Assesses system load
- **Output:** `output/inventory.json`

### Phase 2: Service Responsibility Validation
- Validates each service proves its purpose
- Tests HTTP endpoints
- Categorizes: VERIFIED / DEGRADED / BLOCKED
- **Output:** `output/service-responsibility-matrix.json`

### Phase 3: Dependency Graph
- Maps inter-service dependencies
- Identifies dead links
- Flags critical services
- **Output:** `output/dependency-graph.json`

### Phase 4: Event Bus & Orchestration
- Defines canonical events
- Analyzes propagation patterns
- Identifies potential issues
- **Output:** `output/event-propagation-report.json`

### Phase 5: Meta-Claim Validation
- Tests Identity → MetaTwin → Runtime chain
- Validates component integration
- **Output:** `output/meta-claim-validation.json`

### Phase 6: Hardware Simulation
- Simulates hardware orchestration workflow
- Checks hardware module presence
- Validates logic completeness
- **Output:** `output/hardware-simulation.json`

### Phase 7: Performance Sanity
- Detects zombie processes
- Identifies high CPU/memory consumers
- Checks system load
- Flags potential deadlocks
- **Output:** `output/performance-sanity.json`

### Phase 8: Final Verdict
- Categorizes all systems (4 categories)
- Generates executive truth statement
- **Output:** `output/canon-verdict.json`

---

## Extensions

### Docker + PM2 Runtime Mapping
Maps runtime units to source paths and responsibilities:

```bash
python3 extensions/docker_pm2_mapping.py
```

**Output:** `output/runtime-truth-map.json`

**Structure:**
```json
{
  "docker_mappings": [
    {
      "container_name": "nexus-backend",
      "repo_path": "backend/",
      "runtime": "docker",
      "interfaces": ["http://localhost:3000"],
      "declared_responsibility": "Core API gateway",
      "observed_activity": true,
      "canon_status": "verified"
    }
  ],
  "pm2_mappings": [...]
}
```

### Service Responsibility Matrix (SRM)
Complete evidence-backed matrix of all services:

```bash
python3 extensions/service_responsibility_matrix.py
```

**Output:** `output/service-responsibility-matrix-complete.json`

**Includes:**
- Claimed responsibility
- Source path
- Observed behavior
- Canon status
- Evidence (HTTP response, runtime activity)

---

## CI Gatekeeper Mode

Fail-fast CI validation ensuring canon truth:

```bash
# Run after verification
python3 ci_gatekeeper/gatekeeper.py
```

**CI Rules:**
- ✅ PASS: Fully operational OS
- ✅ PASS: Operational with ≤2 degradations
- ❌ FAIL: Partially operational (critical blockers)
- ❌ FAIL: Insufficient evidence

**Example CI Integration:**

```yaml
# .github/workflows/canon-check.yml
name: Canon Integrity Check

on: [push, pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Run Canon Verifier
        run: |
          cd canon-verifier
          python3 run_verification.py
      
      - name: CI Gatekeeper
        run: |
          cd canon-verifier
          python3 ci_gatekeeper/gatekeeper.py
```

---

## Output Artifacts

All phases generate structured JSON artifacts in `output/`:

| File | Description |
|------|-------------|
| `inventory.json` | Docker, PM2, ports, system load |
| `service-responsibility-matrix.json` | Service validation results |
| `dependency-graph.json` | Service dependencies and analysis |
| `event-propagation-report.json` | Canonical events and flows |
| `meta-claim-validation.json` | Identity→MetaTwin→Runtime chain |
| `hardware-simulation.json` | Hardware orchestration workflow |
| `performance-sanity.json` | System health and deadlocks |
| `runtime-truth-map.json` | Docker/PM2 → repo mappings |
| `service-responsibility-matrix-complete.json` | Complete SRM with evidence |
| `canon-verdict.json` | **Final verdict and truth statement** |

---

## Executive Truth Statement

The `canon-verdict.json` file contains the definitive answer:

```json
{
  "verdict": {
    "verified_systems": [...],
    "degraded_systems": [...],
    "ornamental_systems": [...],
    "critical_blockers": [...],
    "executive_truth": "Fully operational operating system",
    "rationale": "3/3 services verified (100%)"
  }
}
```

**Possible Truth Statements:**
- "Fully operational operating system"
- "Operational with degradations"
- "Partially operational architecture"
- "Insufficient evidence for determination"

---

## Compliance

### Handshake 55-45-17 ✅
All components strictly comply with N3XUS Handshake 55-45-17:
- ✅ Read-only operations
- ✅ Non-destructive execution
- ✅ Deterministic results
- ✅ Zero Silent Failures

### Read-Only Guarantee
**Never modifies:**
- Runtime state
- Service configurations
- Code or files
- Database state
- Deployed services

**Only reads:**
- System processes
- HTTP endpoints
- File presence
- System metrics

---

## Use Cases

### 1. Local Development
```bash
# Verify local changes don't break canon
python3 run_verification.py
```

### 2. CI/CD Pipeline
```bash
# Automated verification gate
python3 run_verification.py && python3 ci_gatekeeper/gatekeeper.py
```

### 3. Production Monitoring
```bash
# Scheduled verification (read-only safe)
python3 run_verification.py
# Review output/canon-verdict.json
```

### 4. Debugging
```bash
# Run specific phases to isolate issues
python3 inventory_phase/enumerate_services.py
python3 responsibility_validation/validate_claims.py
```

### 5. Architecture Audits
```bash
# Generate complete Service Responsibility Matrix
python3 extensions/service_responsibility_matrix.py
# Review output/service-responsibility-matrix-complete.json
```

---

## Requirements

- Python 3.6+
- Standard library only (no external dependencies)
- Optional: Docker (for container enumeration)
- Optional: PM2 (for process enumeration)
- Optional: ss/netstat (for port enumeration)

---

## Differences from Monolithic Canon-Verifier

| Feature | Monolithic | Modular |
|---------|-----------|---------|
| Structure | Single 850-line file | Organized phase modules |
| Extensibility | Hard to extend | Easy to add phases |
| Testability | Test entire file | Test individual phases |
| Reusability | Limited | High - use phases independently |
| Maintenance | Complex | Simple - isolated modules |
| CI Integration | Basic | Full gatekeeper mode |
| Output | Single JSON | Multiple structured artifacts |
| Runtime Mapping | Basic | Complete Docker/PM2 mapping |
| SRM | Inline | Dedicated complete matrix |

---

## Author

Created as part of the N3XUS Canon Verification Framework  
Date: January 8, 2026  
Version: 2.0.0 (Modular)  
Authority: Canonical

---

## See Also

- [../CANON_VERIFIER_README.md](../CANON_VERIFIER_README.md) - Monolithic version docs
- [../GOVERNANCE_CHARTER_55_45_17.md](../GOVERNANCE_CHARTER_55_45_17.md) - Handshake protocol
- [../NEXUS_COS_HOLOSNAP_MASTER_BLUEPRINT.md](../NEXUS_COS_HOLOSNAP_MASTER_BLUEPRINT.md) - Master Blueprint
