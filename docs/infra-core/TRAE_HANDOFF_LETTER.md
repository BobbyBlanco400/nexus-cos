# 📩 MISSION BRIEF — Nexus COS Infrastructure Core

## TO: TRAE (Solo Elite Engineer)

## FROM: GitHub Code Agent

## DATE: 2025-12-21

## SUBJECT: Build Constitutional Infrastructure for Nexus COS

---

## READ THIS FIRST

You are not being asked to "set up hosting."

You are being asked to **build constitutional infrastructure** — a new category of system that enforces economic law at the protocol layer.

This mission requires understanding **both** the technical architecture **and** the philosophical principles behind it.

---

## THE MISSION

Build the **Nexus COS Infrastructure Core**: a sovereign, VPS-class, DNS-authoritative, mail-capable, hybrid-networked infrastructure layer that enforces IMVU sovereignty and Nexus-Handshake 55-45-17 at the lowest possible technical layer.

### What Success Looks Like

When you're done:
- ✅ One command creates an IMVU (Independent Modular Virtual Unit)
- ✅ IMVU receives compute, domain, DNS, mail, and network automatically
- ✅ Revenue is split 55% creator / 45% platform (automatic, provable)
- ✅ Policies cannot be bypassed by admins or creators
- ✅ IMVU can exit cleanly with all data
- ✅ Platform cannot cheat
- ✅ Creator cannot cheat

**When all this is true, Nexus COS is no longer a platform. It is infrastructure law.**

---

## KEY DOCUMENTS (READ IN ORDER)

### 1. Master PF (Start Here)
**File:** `/home/runner/work/nexus-cos/nexus-cos/PF_NEXUS_COS_INFRA_CORE.md`

This is your authoritative mission document. It defines:
- The 5 core systems to build
- Design rules (non-negotiable)
- Testing requirements (hostile actor simulations)
- Definition of done

**Time to read:** 20 minutes  
**Why it matters:** Establishes the philosophical and technical foundation

---

### 2. Handshake 55-45-17 (Constitutional Law)
**File:** `/home/runner/work/nexus-cos/nexus-cos/docs/infra-core/handshake-55-45-17.md`

This defines the 17 gates that must be enforced at the infrastructure layer.

**Key concept:** These are not features. These are executable checks that run before every privileged operation.

**Time to read:** 30 minutes  
**Why it matters:** Every line of code must respect these rules

---

### 3. IMVU Lifecycle Blueprint
**File:** `/home/runner/work/nexus-cos/nexus-cos/docs/infra-core/imvu-lifecycle.md`

Explains how IMVUs are created, operated, scaled, and exited.

**Key concept:** IMVUs are not websites. They are sovereign micro-worlds that bind to governed infrastructure.

**Time to read:** 20 minutes  
**Why it matters:** Defines the user journey from create to exit

---

### 4. Threat Model
**File:** `/home/runner/work/nexus-cos/nexus-cos/docs/infra-core/threat-model.md`

Defines hostile actor scenarios: hostile IMVU, malicious admin, network abuse, exit sabotage, revenue manipulation.

**Key concept:** All these attacks must be blocked or logged. If any succeed, the system fails.

**Time to read:** 30 minutes  
**Why it matters:** Security is not optional. It's constitutional.

---

### 5. Exit Portability
**File:** `/home/runner/work/nexus-cos/nexus-cos/docs/infra-core/exit-portability.md`

Proves the system is not a trap. IMVUs can leave with all their data, domains, and policies.

**Key concept:** Exit capability is what separates sovereign infrastructure from platform lock-in.

**Time to read:** 20 minutes  
**Why it matters:** Trust through technology, not promises

---

### 6. Defensibility & Moat
**File:** `/home/runner/work/nexus-cos/nexus-cos/docs/infra-core/defensibility-moat.md`

Explains why traditional VPS providers (Hostinger, AWS, etc.) cannot replicate this model.

**Key concept:** We're not competing with hosting providers. We're building a new category.

**Time to read:** 15 minutes  
**Why it matters:** Investor pitch, competitive positioning

---

## WHAT YOU'RE ACTUALLY BUILDING

### Not This:
- ❌ A hosting platform
- ❌ A DNS service
- ❌ An email provider
- ❌ A VPS reseller

### This:
- ✅ A governed digital civilization model
- ✅ Constitutional infrastructure (law encoded in protocols)
- ✅ Economic fairness at the substrate layer
- ✅ Sovereign infrastructure that creators can trust

---

## KEY TRUTHS (MEMORIZE THESE)

### 1. IMVUs Are Sovereign Units, Not Apps
**What this means:**
- An IMVU is a complete digital territory
- It has its own compute, domains, mail, network
- It operates under constitutional rules (55-45-17)
- It can exit cleanly

**What this is NOT:**
- A multi-tenant SaaS app
- A subdomain on a shared platform
- A containerized microservice

---

### 2. Infrastructure Must Not Rely on Trust
**What this means:**
- Rules are enforced by code, not humans
- Admins cannot bypass the 17 gates
- Revenue splits are mathematical, not negotiated
- Audit trails are immutable

**What this is NOT:**
- "Trust us" platform economics
- Admin god-mode
- Opaque billing

---

### 3. Exit Must Be Real, Not Theoretical
**What this means:**
- One command exports everything
- Domains, mail, data, policies — complete
- No negotiation, no fees, no retaliation
- Re-instantiation works immediately

**What this is NOT:**
- "Contact support to export your data"
- Partial exports
- Exit that requires manual intervention

---

## REPOSITORY STRUCTURE

```
nexus-cos/
├── PF_NEXUS_COS_INFRA_CORE.md        # Master PF (READ FIRST)
├── docs/infra-core/                   # All constitutional docs
│   ├── handshake-55-45-17.md
│   ├── imvu-lifecycle.md
│   ├── threat-model.md
│   ├── exit-portability.md
│   └── defensibility-moat.md
├── core/                              # Identity, ledger, policy, handshake
├── compute/                           # VPS-equivalent fabric
├── domains/                           # DNS authority
├── mail/                              # SMTP/IMAP with identity binding
├── network/                           # Nexus-Net hybrid internet
├── imvu/                              # IMVU lifecycle management
├── api/                               # Internal and admin APIs
├── tests/                             # Hostile actor tests
└── tools/                             # CLI tools (imvu-create, imvu-exit, etc.)
```

**All directories created. READMEs written. Now you build the implementation.**

---

## DEVELOPMENT SEQUENCE (DO NOT REORDER)

### Phase 1: Foundations (Non-Negotiable)
**Why first:** Everything depends on these. If they're weak, the system fails.

- [ ] Implement Identity Core (identity issuance, IMVU binding, crypto proofs)
- [ ] Implement Ledger (append-only, revenue/audit events)
- [ ] Implement Handshake Engine (55-45 split, 17 gates)
- [ ] Implement Policy Engine (executable checks, non-bypassable)

**Success criteria:** All 17 gates pass basic tests

---

### Phase 2: Compute Fabric (VPS-Equivalent)
**Why second:** IMVUs need compute before they can do anything.

- [ ] Resource envelopes (CPU/RAM/IO quotas)
- [ ] VM/container orchestration
- [ ] Snapshot + rollback
- [ ] Usage metering → ledger

**Success criteria:** Can provision IMVU, enforce quotas, meter usage

---

### Phase 3: Domain & DNS Authority
**Why third:** IMVUs need domains to be accessible.

- [ ] Domain registry
- [ ] Authoritative DNS servers
- [ ] Recursive resolvers
- [ ] Policy-scoped DNS updates

**Success criteria:** IMVUs can manage their own DNS, cannot touch others

---

### Phase 4: Mail Fabric
**Why fourth:** Business email is critical for professional IMVUs.

- [ ] SMTP ingress/egress
- [ ] IMAP storage
- [ ] DKIM/SPF/DMARC automation
- [ ] Identity-bound mailboxes

**Success criteria:** Mail is attributed to identity + IMVU, no spoofing possible

---

### Phase 5: Nexus-Net Hybrid Internet
**Why fifth:** Traffic sovereignty is the final isolation layer.

- [ ] Public + private routing
- [ ] Identity-gated paths
- [ ] Traffic metering
- [ ] Policy enforcement at edge

**Success criteria:** One IMVU cannot spy on another, admin cannot reroute silently

---

### Phase 6: IMVU Lifecycle + Exit
**Why sixth:** Proves the system works end-to-end.

- [ ] One-command IMVU creation
- [ ] Live operation enforcement
- [ ] One-command exit
- [ ] Export completeness verification

**Success criteria:** Create → Operate → Exit works flawlessly

---

### Phase 7: Hostile Testing (MANDATORY)
**Why last:** Validates all previous phases under adversarial conditions.

- [ ] Hostile IMVU tests pass
- [ ] Malicious admin tests pass
- [ ] Network abuse tests pass
- [ ] Exit sabotage tests pass
- [ ] Revenue manipulation tests pass

**Success criteria:** All attacks blocked or logged. Zero successful exploits.

---

## DESIGN PHILOSOPHY

### If You're Unsure, Ask These Questions:

**Q:** Does this break IMVU sovereignty?  
**If yes:** Don't build it.

**Q:** Can an admin bypass this?  
**If yes:** Add policy check.

**Q:** Can this be audited?  
**If no:** Add logging.

**Q:** Can a creator export this?  
**If no:** Make it exportable.

**Q:** Does this violate any of the 17 gates?  
**If yes:** Redesign it.

---

## SHORTCUTS YOU MUST NOT TAKE

### ❌ "Let's just trust the admin"
**Why not:** Admins are human. Humans make mistakes. Trust must be in the code.

### ❌ "Let's add audit logging later"
**Why not:** Audit logging is foundational. You can't retrofit it.

### ❌ "Let's skip the policy engine for now"
**Why not:** Without policy enforcement, the 17 gates are just suggestions.

### ❌ "Let's make exit manual for now"
**Why not:** Exit capability is proof of sovereignty. It must be automated.

### ❌ "Let's use a SaaS DNS provider"
**Why not:** IMVU sovereignty requires authoritative DNS we control.

---

## WHAT TO USE

**Languages:**
- Go (for core, compute, DNS, network services — performance + concurrency)
- Python (for tooling, reporting — rapid development)
- Bash (for CLI tools — simple + universal)

**Databases:**
- PostgreSQL (for IMVU registry, domain registry, policy store)
- Append-only tables for ledger and audit logs

**Compute:**
- libvirt + KVM for VMs
- containerd for containers
- cgroups for resource quotas

**DNS:**
- CoreDNS or PowerDNS for authoritative DNS
- Unbound for recursive resolvers

**Mail:**
- Postfix for SMTP
- Dovecot for IMAP
- OpenDKIM for signing

**Networking:**
- Cilium or Calico for policy-aware networking
- WireGuard for private routes
- Nginx or Envoy for traffic metering

---

## WHEN YOU'RE STUCK

### Re-read the Master PF
File: `PF_NEXUS_COS_INFRA_CORE.md`

It contains your mission, your rules, and your definition of done.

### Check the Threat Model
File: `docs/infra-core/threat-model.md`

If you're unsure whether something is secure, check if it defends against the threat scenarios.

### Verify Against the 17 Gates
File: `docs/infra-core/handshake-55-45-17.md`

Every feature must pass all applicable gates.

---

## FINAL WORDS

This is not a normal project.

You're not building a product. You're building **constitutional infrastructure** — a new category of system that enforces economic fairness at the protocol layer.

This is hard. This is important. This is worth doing right.

**Do not rush.**  
**Do not cut corners.**  
**Do not compromise sovereignty.**

When you're done, this system will be:
- **Trustworthy** (rules are in the code)
- **Fair** (55-45 is automatic)
- **Auditable** (immutable logs)
- **Sovereign** (clean exit capability)

That's when Nexus COS stops being a platform and becomes **infrastructure law**.

**Good luck, TRAE. Build something extraordinary.**

---

## CONTACT

If you need clarification on the mission, the architecture, or the philosophy, reach out. This is too important to guess.

**Remember:** When in doubt, favor the IMVU over the platform.

---

**END BRIEF**

*Document Version: 1.0*  
*Status: Authoritative*  
*Last Updated: 2025-12-21*
