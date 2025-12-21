# Core Infrastructure Layer

## Purpose

The Core layer provides foundational services that enforce the Nexus-Handshake 55-45-17 at the infrastructure level.

## Components

### 1. Identity (`core/identity/`)
**Purpose:** Cryptographic identity issuance and binding

**Responsibilities:**
- Issue cryptographic identities for creators
- Bind identities to IMVUs
- Verify identity proofs for all privileged operations
- Generate identity attestations

**Key Files:**
- `identity-issuer.go` — Identity creation and signing
- `identity-verifier.go` — Identity proof verification
- `imvu-binding.go` — Bind identity to IMVU
- `identity-store.go` — Identity database interface

---

### 2. Ledger (`core/ledger/`)
**Purpose:** Append-only event log for all billable and audit events

**Responsibilities:**
- Record all billable events (compute, DNS, mail, network)
- Record all audit events (admin actions, policy checks)
- Record all consent events (user permissions)
- Provide immutable audit trail

**Key Files:**
- `ledger-writer.go` — Write events to ledger
- `ledger-query.go` — Query ledger for reports
- `revenue-calculator.go` — Calculate 55-45 split
- `audit-reporter.go` — Generate compliance reports

---

### 3. Policy Engine (`core/policy-engine/`)
**Purpose:** Execute the 17 gates before privileged operations

**Responsibilities:**
- Evaluate policies before DNS mutations
- Evaluate policies before quota changes
- Evaluate policies before traffic rerouting
- Block operations that violate policies

**Key Files:**
- `policy-evaluator.go` — Main policy evaluation engine
- `gates.go` — Implementation of 17 gates
- `policy-hooks.go` — Middleware for API calls
- `policy-store.go` — Policy database

---

### 4. Handshake Engine (`core/handshake/`)
**Purpose:** Enforce 55-45-17 revenue split

**Responsibilities:**
- Calculate creator share (55%)
- Calculate platform share (45%)
- Verify split is exact
- Generate invoices

**Key Files:**
- `revenue-splitter.go` — 55-45 calculation
- `billing-engine.go` — Invoice generation
- `payment-router.go` — Route payments to creator/platform
- `dispute-resolver.go` — Handle billing disputes

---

## Integration Points

**With Compute:** Meters CPU/RAM/IO usage → Ledger  
**With DNS:** Policy checks before zone mutations  
**With Mail:** Identity binding for all mailboxes  
**With Network:** Traffic attribution to IMVU + identity  

---

## Development Status

- [ ] Identity Core implemented
- [ ] Ledger implemented
- [ ] Policy Engine implemented
- [ ] Handshake Engine implemented
- [ ] Integration tests passing

---

*See: [PF_NEXUS_COS_INFRA_CORE.md](../PF_NEXUS_COS_INFRA_CORE.md) for master plan*
