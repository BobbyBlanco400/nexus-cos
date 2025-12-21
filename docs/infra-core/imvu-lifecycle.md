# IMVU Lifecycle Blueprint

## Create → Operate → Scale → Exit

This document defines the complete lifecycle of an Independent Modular Virtual Unit (IMVU) within the Nexus COS infrastructure.

---

## What is an IMVU?

**IMVU = Independent Modular Virtual Unit**

Think of IMVUs as:
- **Sovereign micro-worlds** — Self-contained digital territories
- **Self-contained products/experiences** — Complete applications or services
- **Identity-aware, revenue-aware, policy-aware** — Full governance built-in

**IMVUs are NOT websites. They are living units that use web, media, compute, and network resources.**

---

## 1️⃣ CREATE Phase

### One-Command IMVU Creation

```bash
./tools/imvu-create.sh --name "MyProject" --owner "creator-8891" --jurisdiction "US-CCPA"
```

### What Happens Automatically

**Identity Issued:**
- Creator identity verified and cryptographically signed
- Identity bound to IMVU for all future actions

**IMVU ID Minted:**
- Unique IMVU identifier generated (e.g., `IMVU-042`)
- Registered in IMVU registry with ownership metadata

**Compute Envelope Allocated:**
```yaml
IMVU-042:
  compute:
    cpu_quota: 4_cores
    memory_quota: 8_GB
    io_quota: 100_IOPS
    burst_policy: allow_2x_for_5min
```

**Domain Assigned:**
- Primary domain: `imvu042.world`
- Stage domain: `stage.imvu042.world`
- DNS zones created and bound to IMVU ownership

**DNS Zone Created:**
- Authoritative DNS records initialized
- SOA, NS, A records configured
- DNSSEC signing enabled

**Mail Fabric Instantiated:**
- Mailboxes created: `creator@imvu042.world`, `admin@imvu042.world`
- DKIM keys generated and DNS records published
- SPF and DMARC policies configured

**Nexus-Net Routes Defined:**
```yaml
IMVU-042 Traffic Policy:
  public:
    - users
    - streams
    - public_api
  private:
    - internal_ai
    - ledgers
    - admin_backend
  restricted:
    - admin_console
    - payout_system
```

**Result:** IMVU is fully operational with zero manual setup.

---

## 2️⃣ OPERATE Phase

### Live Operations

**Traffic Flows Through Nexus-Net Hybrid:**
- Public traffic: routed to public endpoints
- Private traffic: isolated within IMVU network
- Restricted traffic: identity-gated admin access

**Compute Usage Metered:**
- CPU, memory, I/O tracked continuously
- Events sent to ledger for revenue calculation
- Quota enforcement prevents overuse

**Email Signed & Logged:**
- All outbound mail signed with DKIM
- Identity attribution: `creator-8891@imvu042.world`
- Audit trail for compliance

**DNS Updates Policy-Checked:**
- IMVU can update its own DNS records
- Policy engine verifies ownership before mutations
- All changes logged and signed

**Revenue Split Auto-Calculated (55-45):**
```
Billing Period: 2025-12-01 to 2025-12-31

compute_cost: $120 (4 cores × 720 hours)
dns_cost: $5 (50,000 queries)
mail_cost: $10 (500 emails + 2GB storage)
network_cost: $15 (150GB bandwidth)

total_cost: $150

creator_share: $82.50 (55%)
platform_share: $67.50 (45%)
```

**No spreadsheets. No reconciliation. Math from ledger.**

---

## 3️⃣ SCALE Phase

### Elastic Growth

**Elastic Compute Envelopes:**
- IMVU requests more resources via API
- Policy engine approves based on payment status
- Envelope expanded: `8_cores, 16_GB, 200_IOPS`
- Usage tracked, revenue split maintained

**Multi-Region Routing:**
- IMVU expands to EU region
- Nexus-Net creates geo-routing policy
- `eu.imvu042.world` routes to EU compute
- Jurisdiction metadata: `EU-GDPR` enforced

**Policy-Preserved Expansion:**
- All 17 gates still enforce
- 55-45 split maintained
- No renegotiation of ownership

**Zero Lock-In:**
- Expansion does not create platform dependency
- Exit capability preserved at all scales

---

## 4️⃣ EXIT Phase (Critical)

### Clean Exit Capability

```bash
./tools/imvu-exit.sh --imvu-id "IMVU-042" --export-path "/exports/imvu042"
```

### What Gets Exported

**Domains:**
- Full DNS zone export (BIND format)
- Domain ownership certificates
- Transfer authorization codes

**Mailboxes:**
- Complete mail archives (mbox format)
- DKIM private keys
- SPF/DMARC policies

**Data:**
- All application data (databases, files)
- Ledger records (revenue, audit logs)
- Metadata (policies, configurations)

**Policies:**
- Traffic routing policies
- Access control policies
- Compliance configurations

**Compute Images:**
- VM/container snapshots
- Configuration files
- Environment variables (secrets redacted, but architecture preserved)

### Exit Guarantees

**IMVU Can:**
- Export all data in open formats
- Rebind domains to new infrastructure
- Continue operations elsewhere
- Preserve revenue history for tax/audit

**Platform Cannot:**
- Retaliate against exiting IMVU
- Hold data hostage
- Deny export request
- Delete data before export completes

**Why This Matters:**
- Exit proves the system is not a trap
- Creators trust the platform because they can leave
- Investors trust the economics because there's no lock-in dependency

---

## Lifecycle Summary

| Phase | Duration | Actions | Cost |
|-------|----------|---------|------|
| **Create** | 5 minutes | Identity, compute, DNS, mail, network | $0 setup |
| **Operate** | Ongoing | Traffic, compute, mail, DNS usage | 55% to creator |
| **Scale** | As needed | Expand resources, add regions | 55% maintained |
| **Exit** | 1 hour | Export all data, domains, policies | $0 exit fee |

---

## Why This Model Works

### Traditional Platforms
- ❌ Complex onboarding (days/weeks)
- ❌ Manual configuration
- ❌ Hidden fees
- ❌ Opaque billing
- ❌ Exit requires negotiation
- ❌ Data exports are incomplete

### Nexus COS (IMVU Model)
- ✅ Instant creation (one command)
- ✅ Zero manual setup
- ✅ Transparent costs
- ✅ Provable billing (from ledger)
- ✅ Exit is one command
- ✅ Complete data portability

**Result:** Creators trust the system. Investors fund with confidence. Regulators approve compliance.

---

## Example: Creator Journey

### Day 1: Create
```bash
$ imvu-create --name "ArtGallery" --owner "alice"
✅ IMVU-123 created
✅ Domain: artgallery.imvu123.world
✅ Mail: alice@imvu123.world
✅ Compute: 2 cores, 4GB RAM
✅ Network: Public + Private routes
```

### Month 1-6: Operate
- Alice builds her art marketplace
- Users visit `artgallery.imvu123.world`
- Revenue: $500/month → Alice keeps $275 (55%)

### Month 7: Scale
```bash
$ imvu-scale --imvu-id "IMVU-123" --cpu 8 --memory 16GB
✅ Envelope expanded
✅ 55-45 split maintained
```

### Month 12: Exit (Optional)
```bash
$ imvu-exit --imvu-id "IMVU-123"
✅ Exported 50GB data
✅ Domain transfer codes provided
✅ Mail archives complete
✅ Revenue ledger included
```

Alice moves to her own infrastructure. No hard feelings. No lock-in.

---

## Technical Implementation Notes

### IMVU Registry Schema

```sql
CREATE TABLE imvus (
  imvu_id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  owner_identity TEXT NOT NULL,
  jurisdiction TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL,
  compute_envelope JSONB NOT NULL,
  domain TEXT NOT NULL,
  status TEXT NOT NULL, -- active, suspended, exited
  metadata JSONB
);
```

### Compute Envelope Schema

```json
{
  "cpu_cores": 4,
  "memory_gb": 8,
  "io_iops": 100,
  "storage_gb": 100,
  "burst_policy": {
    "enabled": true,
    "max_multiplier": 2,
    "duration_minutes": 5
  }
}
```

### Traffic Policy Schema

```yaml
imvu_id: IMVU-042
routes:
  public:
    - path: "/*"
      backend: "public-api"
  private:
    - path: "/internal/*"
      backend: "private-api"
      require_identity: true
  restricted:
    - path: "/admin/*"
      backend: "admin-api"
      require_roles: ["admin"]
```

---

## Compliance Checklist

- [ ] Identity bound to IMVU ✅ (Gate 1)
- [ ] Compute isolated ✅ (Gate 2)
- [ ] Domain ownership clear ✅ (Gate 3)
- [ ] DNS authority scoped ✅ (Gate 4)
- [ ] Mail attributed ✅ (Gate 5)
- [ ] Revenue metered ✅ (Gate 6)
- [ ] Quotas enforced ✅ (Gate 7)
- [ ] Network governed ✅ (Gate 8)
- [ ] Jurisdiction tagged ✅ (Gate 9)
- [ ] Consent logged ✅ (Gate 10)
- [ ] Audit logged ✅ (Gate 11)
- [ ] Snapshots available ✅ (Gate 12)
- [ ] Exit portable ✅ (Gate 13)
- [ ] No silent redirect ✅ (Gate 14)
- [ ] No silent throttle ✅ (Gate 15)
- [ ] No cross-IMVU leak ✅ (Gate 16)
- [ ] Platform non-repudiation ✅ (Gate 17)

**All 17 gates enforce automatically throughout the lifecycle.**

---

*Document Version: 1.0*  
*Status: Authoritative*  
*Last Updated: 2025-12-21*
