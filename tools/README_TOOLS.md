# 🛠️ Nexus COS Tools - Complete CLI Suite

## Overview

Complete command-line tools for Nexus COS platform management, IMVU lifecycle, testing, and deployment.

---

## 🚀 Master Deployment

### `nexus-final-launch.sh` ⭐ ONE-COMMAND DEPLOYMENT

**Purpose:** Deploy the complete Nexus COS stack with one command

**Usage:**
```bash
./tools/nexus-final-launch.sh
```

**What It Does:**
1. Validates repository structure
2. Audits existing stack
3. Deploys NN-5G browser-native layer
4. Integrates mini-platforms
5. Deploys front-facing modules
6. Initializes core infrastructure
7. Activates compute, DNS, mail, network
8. Runs comprehensive tests
9. Verifies compliance
10. Generates deployment report

**Time:** ~5-10 minutes  
**Result:** Fully operational Nexus COS stack

---

## 🏢 IMVU Management

### `imvu-create.sh` - Create New IMVU

**Purpose:** One-command IMVU creation with full resource allocation

**Usage:**
```bash
./tools/imvu-create.sh \
  --name "ProjectName" \
  --owner "creator-identity" \
  --jurisdiction "US-CCPA" \
  --cpu 4 \
  --memory 8 \
  --storage 100
```

**Creates:**
- IMVU ID (unique identifier)
- Compute envelope (CPU/RAM/storage)
- Domain (projectname.imvuXXX.world)
- DNS zones (authoritative + recursive)
- Mail fabric (creator@domain with DKIM)
- Network routes (public/private/restricted)

**Revenue:** Automatic 55/45 split begins metering

---

### `imvu-exit.sh` - Export IMVU for Clean Exit

**Purpose:** Complete IMVU export with verification

**Usage:**
```bash
./tools/imvu-exit.sh \
  --imvu-id "IMVU-042" \
  --export-path "/exports/imvu042"
```

**Exports:**
- DNS zones (BIND format) + transfer codes
- Mail archives (mbox) + DKIM keys
- VM/container snapshots
- Database dumps (PostgreSQL, Redis)
- Application files (tar.gz)
- Network policies (YAML)
- Ledger records (revenue + audit)

**Verification:** 9-step completeness check

---

## 🌐 NN-5G Integration

### `deploy-nn5g-layer.sh` - Deploy Browser-Native Layer

**Purpose:** Deploy edge micro-gateways and network slices

**Usage:**
```bash
./tools/deploy-nn5g-layer.sh
```

**Configures:**
- Edge micro-gateways (nearest to users)
- Network slices (per IMVU/platform)
- Latency optimization (< 10ms target)
- QoS policies (guaranteed bandwidth)
- Session mobility (seamless handoff)

---

## 🏗️ Mini-Platform Integration

### `integrate-mini-platforms.sh` - Integrate Mini-Platforms

**Purpose:** Bind mini-platforms to ledger with 80/20 economics

**Usage:**
```bash
./tools/integrate-mini-platforms.sh
```

**Integrates:**
- All mini-platforms with ledger
- 80/20 revenue split (automatic)
- Network slice allocation
- Identity binding

---

## 🎬 Front-Facing Deployment

### `deploy-front-facing.sh` - Deploy Stream & OTT

**Purpose:** Deploy Nexus Stream and Nexus OTT Mini

**Usage:**
```bash
./tools/deploy-front-facing.sh
```

**Deploys:**
- Nexus Stream frontend
- Nexus OTT Mini frontend
- Revenue engine bindings
- Backend placeholders

---

## 🔍 Auditing & Testing

### `stack-audit.sh` - Audit Full Stack

**Purpose:** Continuous compliance auditing

**Usage:**
```bash
./tools/stack-audit.sh
```

**Audits:**
- All existing IMVUs
- All mini-platforms
- Stream modules
- OTT modules

**Verifies:**
- 55-45-17 compliance
- 80-20 compliance
- Ledger completeness
- No policy violations

---

### `run-final-tests.sh` - Comprehensive Testing

**Purpose:** Run full test suite

**Usage:**
```bash
./tools/run-final-tests.sh
```

**Tests:**
1. Creator-splits (80/20 and 55/45)
2. Network-slices (NN-5G latency, QoS)
3. Exit capability (portability, clean exit)
4. Audit trail (logging, revenue tracking)

**Expected:** All tests pass ✅

---

## 📊 Verification Tools

### `verify-17-gates.sh` - Verify Gate Enforcement

**Purpose:** Test all 17 constitutional gates

**Usage:**
```bash
./tools/verify-17-gates.sh
```

**Tests:**
- Identity binding
- IMVU isolation
- Domain ownership
- DNS authority
- Mail attribution
- Revenue metering
- Resource quotas
- Network governance
- (and 9 more gates)

---

### `verify-revenue-split.sh` - Verify Revenue Math

**Purpose:** Verify 55-45 or 80-20 split accuracy

**Usage:**
```bash
./tools/verify-revenue-split.sh \
  --imvu-id "IMVU-042" \
  --month "2025-12"
```

**Output:**
```
Revenue Verification for IMVU-042 (2025-12)
============================================
Total Revenue: $10,000.00
Creator Share (55%): $5,500.00
Platform Share (45%): $4,500.00
Verification: ✅ PASS (sum equals total)
```

---

### `verify-imvu-isolation.sh` - Test Isolation

**Purpose:** Verify IMVUs cannot access each other

**Usage:**
```bash
./tools/verify-imvu-isolation.sh \
  --imvu-a "IMVU-042" \
  --imvu-b "IMVU-043"
```

**Tests:**
- File system isolation
- Network isolation
- DNS isolation
- Mail isolation

---

### `verify-exit-capability.sh` - Test Clean Exit

**Purpose:** End-to-end exit verification

**Usage:**
```bash
./tools/verify-exit-capability.sh \
  --imvu-id "IMVU-TEST-001"
```

**Process:**
1. Creates test IMVU
2. Populates with sample data
3. Executes export
4. Verifies completeness
5. Re-instantiates on local VM
6. Tests functionality
7. Cleans up

---

## 🏥 Health & Monitoring

### `system-health.sh` - Check System Health

**Purpose:** Overall system health check

**Usage:**
```bash
./tools/system-health.sh
```

**Checks:**
- Core services running
- Database connectivity
- DNS servers responding
- Mail servers operational
- Network routing correct
- Ledger accepting writes

---

### `audit-report.sh` - Generate Compliance Report

**Purpose:** Generate audit report for IMVU

**Usage:**
```bash
./tools/audit-report.sh \
  --imvu-id "IMVU-042" \
  --month "2025-12" \
  --format "pdf"
```

**Includes:**
- Revenue calculation (55-45)
- All billable events from ledger
- Audit log of admin actions
- Policy check results

---

## 📋 Tool Categories

### Deployment Tools
- `nexus-final-launch.sh` - Master deployment
- `deploy-nn5g-layer.sh` - NN-5G layer
- `integrate-mini-platforms.sh` - Mini-platforms
- `deploy-front-facing.sh` - Stream & OTT

### IMVU Lifecycle
- `imvu-create.sh` - Create IMVU
- `imvu-exit.sh` - Export IMVU
- `imvu-scale.sh` - Scale resources (TODO)

### Testing & Validation
- `run-final-tests.sh` - Full test suite
- `stack-audit.sh` - Stack auditing
- `verify-17-gates.sh` - Gate verification
- `verify-revenue-split.sh` - Revenue math
- `verify-imvu-isolation.sh` - Isolation tests
- `verify-exit-capability.sh` - Exit tests

### Monitoring & Reporting
- `system-health.sh` - System health
- `audit-report.sh` - Compliance reports

---

## 🎯 Quick Start

### Deploy Everything
```bash
./tools/nexus-final-launch.sh
```

### Create Your First IMVU
```bash
./tools/imvu-create.sh \
  --name "MyProject" \
  --owner "my-identity" \
  --cpu 4 \
  --memory 8
```

### Run Tests
```bash
./tools/run-final-tests.sh
```

### Check Health
```bash
./tools/system-health.sh
```

---

## 📝 Development Status

| Tool | Status | Description |
|------|--------|-------------|
| `nexus-final-launch.sh` | ✅ Complete | Master deployment |
| `imvu-create.sh` | ✅ Complete | IMVU creation |
| `imvu-exit.sh` | ✅ Complete | IMVU export |
| `deploy-nn5g-layer.sh` | ✅ Complete | NN-5G deployment |
| `integrate-mini-platforms.sh` | ✅ Complete | Mini-platform integration |
| `deploy-front-facing.sh` | ✅ Complete | Stream/OTT deployment |
| `run-final-tests.sh` | ✅ Complete | Test suite |
| `stack-audit.sh` | ✅ Complete | Stack auditing |
| `verify-17-gates.sh` | ⏳ Planned | Gate verification |
| `verify-revenue-split.sh` | ⏳ Planned | Revenue verification |
| `verify-imvu-isolation.sh` | ⏳ Planned | Isolation testing |
| `verify-exit-capability.sh` | ⏳ Planned | Exit testing |
| `system-health.sh` | ⏳ Planned | Health monitoring |
| `audit-report.sh` | ⏳ Planned | Report generation |

---

## 🔗 Related Documentation

- **Master PF:** `../PF_NEXUS_COS_INFRA_CORE.md`
- **Quick Start:** `../QUICK_START_INFRA_CORE.md`
- **Integration Guide:** `../FINAL_LAUNCH_INTEGRATION.md`
- **TRAE Guide:** `../docs/infra-core/TRAE_HANDOFF_LETTER.md`

---

*Tools Documentation v1.0*  
*Last Updated: 2025-12-21*  
*Status: ✅ Core Tools Complete*
