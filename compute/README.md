# Compute Fabric

## Purpose

Replace external VPS providers with sovereign compute infrastructure that enforces IMVU sovereignty and resource fairness.

## Components

### 1. Fabric (`compute/fabric/`)
**Purpose:** VM + container orchestration layer

**Responsibilities:**
- Provision VMs and containers for IMVUs
- Manage lifecycle (create, start, stop, destroy)
- Enforce isolation between IMVUs
- Integrate with network layer

---

### 2. Envelopes (`compute/envelopes/`)
**Purpose:** Resource quota management

**Responsibilities:**
- Define CPU/RAM/IO quotas per IMVU
- Enforce hard limits via cgroups/namespaces
- Track usage and send to ledger
- Support burst policies (temporary overages)

---

### 3. Snapshots (`compute/snapshots/`)
**Purpose:** Point-in-time IMVU state capture

**Responsibilities:**
- Create VM/container snapshots
- Store snapshots immutably
- Restore from snapshot
- Export snapshots for exit

---

### 4. Provisioning (`compute/provisioning/`)
**Purpose:** Blueprint-based IMVU deployment

**Responsibilities:**
- Deploy IMVU from template
- Apply custom configurations
- Verify deployment success
- Rollback on failure

---

## Key Principles

1. **IMVU-Bound Ownership:** No shared state between IMVUs
2. **Metered Usage:** Every CPU cycle, RAM byte, I/O operation tracked
3. **Enforceable Quotas:** Limits enforced by kernel, not application
4. **Snapshot Capability:** Every IMVU can be snapshotted for backup or exit

---

## Development Status

- [ ] Fabric orchestration implemented
- [ ] Envelope quota enforcement implemented
- [ ] Snapshot/restore implemented
- [ ] Blueprint provisioning implemented
- [ ] Integration tests passing

---

*See: [PF_NEXUS_COS_INFRA_CORE.md](../PF_NEXUS_COS_INFRA_CORE.md) for master plan*
