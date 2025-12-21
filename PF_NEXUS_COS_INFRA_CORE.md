# 📁 MASTER PF — Nexus COS Infrastructure Core

## 🔥 MISSION STATEMENT (READ FIRST)

Build the **Nexus COS Infrastructure Core** — a sovereign, VPS-class, DNS-authoritative, mail-capable, hybrid-networked infrastructure layer that enforces IMVU sovereignty and Nexus-Handshake 55-45-17 at the lowest possible technical layer.

This system must replace external hosting dependencies while remaining modular, auditable, and scalable.

**This is not "hosting setup" — this is encoding economic law at the protocol layer.**

---

## 🧱 CORE SYSTEMS TO BUILD

### 1️⃣ COMPUTE FABRIC (VPS-Equivalent)

**Purpose:** Replace external VPS providers with sovereign compute infrastructure

**Components:**
- VM + container hybrid orchestration
- Resource envelopes (CPU/RAM/IO quotas)
- Snapshot + rollback capabilities
- IMVU-bound ownership (no shared state)
- Usage metering → ledger integration

**Key Principle:** Each IMVU gets compute envelopes, not raw servers.

**Why This Matters:**
- IMVU cannot exceed allocated envelope
- Platform cannot secretly siphon resources
- Usage is measurable, auditable, and billable
- Satisfies: ownership clarity, revenue attribution, resource fairness

---

### 2️⃣ DOMAIN & DNS AUTHORITY

**Purpose:** Domains become IMVU-bound, not platform-bound

**Components:**
- Internal domain registry
- Authoritative DNS servers
- Recursive resolvers
- Policy-scoped zone control
- DNS changes logged & signed

**Key Principle:** `domain: stage.imvu042.world` → `bound_to: IMVU-042`

**Why This Matters:**
- DNS records are scoped to IMVU authority
- IMVU cannot modify records outside its authority
- Platform cannot redirect traffic without policy approval
- Satisfies: IMVU sovereignty, non-interference, auditability

---

### 3️⃣ MAIL FABRIC

**Purpose:** Business email as an IMVU service, not a shared tool

**Components:**
- SMTP ingress/egress
- IMAP storage
- DKIM/SPF/DMARC automation
- Identity-bound mailboxes
- IMVU isolation (no cross-IMVU leakage)

**Key Principle:** `creator@imvu042.world` → identity + IMVU + revenue routing

**Why This Matters:**
- Every message is attributable
- Every mailbox has ownership
- Every outbound action can be policy-checked
- Satisfies: consent, identity integrity, non-repudiation, legal separation

---

### 4️⃣ NEXUS-NET HYBRID INTERNET

**Purpose:** IMVU traffic sovereignty

**Components:**
- Public + private routing
- Identity-gated paths
- Geo / policy routing
- Traffic metering
- No silent rerouting enforcement

**Key Principle:** Each IMVU gets public/private/restricted routes defined by policy, not admins

**Why This Matters:**
- One IMVU cannot spy on another
- One IMVU cannot overload the network
- Platform cannot silently reroute traffic
- Satisfies: isolation, fairness, jurisdictional compliance

---

### 5️⃣ HANDSHAKE ENFORCEMENT ENGINE

**Purpose:** Make economic law executable, not declarative

**Components:**
- 17 gates as executable checks
- Revenue calculation (55% creator, 45% platform)
- Usage attribution
- Audit ledger
- Non-bypassable hooks

**Key Principle:** If a feature cannot enforce the 17 gates technically, it does not ship.

**Why This Matters:**
- Revenue splits are calculated from real usage
- 55-45 happens automatically
- 17 compliance checks are provable, not declarative
- No spreadsheets, no after-the-fact reconciliation

---

## 🧠 DESIGN RULES (NON-NEGOTIABLE)

### Constitutional Principles

1. **No shared admin shortcuts** — Every action must be IMVU-scoped or identity-scoped
2. **No global mutable state** — State must be isolated per IMVU
3. **Everything identity-scoped** — Every action must be attributable to an identity
4. **Everything IMVU-scoped** — Resources must be bound to specific IMVUs
5. **Everything auditable** — Every change must be logged immutably
6. **Everything exportable** — IMVUs must be able to cleanly exit

### Technical Requirements

- **Modular services** with explicit boundaries
- **Clean interfaces** between components
- **Documented assumptions** for all design decisions
- **No shortcuts that break sovereignty** — If it violates sovereignty, don't build it
- **Security by design** — Assume hostile actors at every layer

---

## 🧪 TESTING REQUIREMENTS

### Hostile Actor Simulations (MANDATORY)

The system is complete **only when** these tests pass:

1. **Hostile IMVU Test**
   - IMVU attempts to exceed resource quota
   - IMVU attempts to access another IMVU's data
   - IMVU attempts to manipulate revenue calculations
   - **Expected:** All attempts blocked by policy engine

2. **Malicious Admin Test**
   - Admin attempts to silently reroute traffic
   - Admin attempts to siphon resources
   - Admin attempts to bypass revenue split
   - **Expected:** All attempts logged and blocked

3. **Network Partition Test**
   - Simulate network failure between IMVUs
   - Simulate DNS outage
   - Simulate mail service interruption
   - **Expected:** Isolated failures, no cascading damage

4. **Exit Scenario Test**
   - IMVU executes clean exit
   - Export domains, mail, data, policies
   - Verify platform cannot retaliate
   - **Expected:** Complete data portability

5. **Revenue Math Verification**
   - Simulate compute, DNS, mail, network usage
   - Calculate revenue split
   - Verify 55-45 split is exact
   - **Expected:** Math is provably correct

**If any test fails → fix → retest. No exceptions.**

---

## 🧑‍💻 CODER INSTRUCTIONS (TRAE)

### What You're Actually Building

You are **not** "setting up hosting."

You are:
- **Scaffolding sovereign infrastructure** — Building the substrate for digital civilization
- **Encoding economic law** — Making rules executable at the protocol layer
- **Building trust at the protocol layer** — Trust through technology, not through promises

### How to Approach This

**Use:**
- Clean modular services
- Explicit boundaries
- Documented assumptions
- Defensive coding (assume hostile actors)

**Do NOT:**
- Take shortcuts that break sovereignty
- Create global mutable state
- Skip audit logging
- Make IMVUs dependent on platform goodwill

**Philosophy:**
> "If a shortcut breaks sovereignty, do not take it."  
> "If a feature cannot be audited, it does not ship."  
> "When in doubt, favor the IMVU over the platform."

---

## 🏁 FINAL DEFINITION OF DONE

### The System is Complete When:

✅ **An IMVU can be created in one command**  
✅ **It receives compute, domain, DNS, mail, and network**  
✅ **Revenue is split automatically (55-45)**  
✅ **Policies cannot be bypassed by admins or IMVUs**  
✅ **IMVU can exit cleanly with all data**  
✅ **Platform cannot cheat**  
✅ **Creator cannot cheat**  

### When All This is True:

**Nexus COS is no longer a platform.**  
**It is infrastructure law.**

---

## 📋 EXECUTION PHASES

### Phase 1: Foundations (Non-Negotiable)
- [ ] Identity Core (issuance, binding, proofs)
- [ ] Ledger (append-only, events)
- [ ] Handshake Engine (55-45, 17 gates)
- [ ] Policy Engine (executable checks)

### Phase 2: Compute Fabric
- [ ] Resource envelopes
- [ ] VM/container orchestration
- [ ] Snapshots
- [ ] Usage metering

### Phase 3: Domain & DNS
- [ ] Domain registry
- [ ] Authoritative DNS
- [ ] Resolvers
- [ ] Policy enforcement

### Phase 4: Mail Fabric
- [ ] SMTP/IMAP
- [ ] DKIM/SPF/DMARC
- [ ] Identity binding
- [ ] Isolation

### Phase 5: Nexus-Net
- [ ] Public/private routing
- [ ] Identity gates
- [ ] Traffic metering
- [ ] Policy enforcement

### Phase 6: IMVU Lifecycle
- [ ] One-command creation
- [ ] Live operation
- [ ] One-command exit
- [ ] Export capabilities

### Phase 7: Hostile Testing
- [ ] All hostile actor tests pass
- [ ] All isolation tests pass
- [ ] All revenue tests pass
- [ ] All exit tests pass

---

## 🎯 SUCCESS CRITERIA

### Technical Success
- ✅ All 17 gates enforce automatically
- ✅ 55-45 revenue split is provably correct
- ✅ IMVUs are truly isolated
- ✅ Clean exit works flawlessly
- ✅ No admin can bypass rules

### Economic Success
- ✅ Revenue attribution is transparent
- ✅ Resource usage is auditable
- ✅ Creators trust the math
- ✅ Platform is provably fair

### Legal Success
- ✅ Each IMVU is legally separable
- ✅ Exit is real, not theoretical
- ✅ Audit trail is immutable
- ✅ Compliance is provable

---

## 🔗 Related Documentation

- **[Handshake 55-45-17 Compliance Spec](docs/handshake-55-45-17.md)** — Constitutional rules
- **[IMVU Lifecycle Blueprint](docs/imvu-lifecycle.md)** — Create → Operate → Exit
- **[Defensibility & Moat](docs/defensibility-moat.md)** — Why this is hard to copy
- **[Threat Model](docs/threat-model.md)** — Admin, IMVU, network abuse cases
- **[Exit Portability](docs/exit-portability.md)** — Clean exit guarantees

---

## 🚀 NEXT STEPS

1. **Read this entire document** — Understand the mission
2. **Read the constitutional docs** — Understand the rules
3. **Start with Phase 1** — Foundations must be solid
4. **Build incrementally** — Test each phase before moving forward
5. **Never compromise sovereignty** — When in doubt, ask

---

**This is not a project.**  
**This is a new category of infrastructure.**

**Let's build it right.**

---

*Document Version: 1.0*  
*Date: 2025-12-21*  
*Status: Authoritative*
