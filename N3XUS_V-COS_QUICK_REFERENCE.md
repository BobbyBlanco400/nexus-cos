# N3XUS v-COS Quick Reference

**Welcome to N3XUS v-COS** — The Virtual Creative Operating System

This quick reference guide provides key information about the newly canonized N3XUS v-COS identity and n3xus-net sovereign architecture.

---

## 🎯 What's New

### Branding Update
- **Official Name:** N3XUS v-COS (pronounced "Nexus V-C-O-S")
- **Previous Name:** Nexus COS
- **Tagline:** "The Virtual Creative Operating System"
- **Network:** n3xus-net (sovereign architecture)

### Architecture Enhancement
- **Sovereign Network:** All services operate on n3xus-net
- **Internal Hostnames:** v- prefix for all sovereign services
- **Gateway:** n3xus-gateway for external access
- **Handshake:** 55-45-17 protocol enforced throughout

---

## 📚 Documentation

### Core Documentation
- **[v-COS Platform](docs/v-COS/README.md)** - Platform overview and features
- **[n3xus-net Architecture](docs/n3xus-net/README.md)** - Network architecture and patterns
- **[Sovereign Genesis](docs/Sovereign-Genesis/README.md)** - Foundational principles

### Operational Guides
- **[Agent Deployment](docs/agent-deployment-procedures.md)** - Deployment procedures
- **[Acceptance Criteria](docs/acceptance-criteria.md)** - Validation framework
- **[Master PR Summary](docs/MASTER_PR_EXECUTION_SUMMARY.md)** - Complete implementation details

### Brand Guidelines
- **[Brand Bible](brand/bible/N3XUS_COS_Brand_Bible.md)** - Complete brand identity

---

## 🌐 n3xus-net Services

### Core Services
| Service | Hostname | Port | Purpose |
|---------|----------|------|---------|
| Gateway | `n3xus-gateway` | 80/443 | External entry point |
| Streaming | `v-stream` | 3000 | Main streaming service |
| Auth | `v-auth` | 4000 | Identity & access |
| Platform | `v-platform` | 4001 | Core platform API |
| v-Suite | `v-suite` | 4100 | Creative tools |
| Content | `v-content` | 4200 | Content management |

### Database Layer
| Service | Hostname | Port | Purpose |
|---------|----------|------|---------|
| PostgreSQL | `v-postgres` | 5432 | Primary database |
| Redis | `v-redis` | 6379 | Cache & sessions |
| MongoDB | `v-mongo` | 27017 | Document store |

---

## 🔒 Handshake Protocol

Every request requires the handshake header:

```
X-N3XUS-Handshake: 55-45-17
```

**Components:**
- **55:** System integrity (25 checkpoints)
- **45:** Compliance validation (20 rules)
- **17:** Tenant governance (13 tenants + 4 layers)

---

## 🚀 Quick Start

### Development
```bash
# Clone and start
git clone https://github.com/BobbyBlanco400/nexus-cos.git
cd nexus-cos

# Start n3xus-net
docker-compose -f docker-compose.n3xus-net.yml up -d

# Verify
./scripts/verify-pr-acceptance.sh
```

### Production Deployment
```bash
# Deploy infrastructure
./scripts/deploy-n3xus-v-cos.sh

# Verify deployment
kubectl get pods -n n3xus-net
```

---

## ✅ Verification

Run automated verification:
```bash
./scripts/verify-pr-acceptance.sh
```

**Expected Result:** 32/32 tests passing ✓

---

## 📖 Additional Resources

- **Main README:** [README.md](README.md)
- **Phase 2 Status:** [PHASE_2_COMPLETION.md](PHASE_2_COMPLETION.md)
- **Governance:** [GOVERNANCE_CHARTER_55_45_17.md](GOVERNANCE_CHARTER_55_45_17.md)
- **GitHub:** https://github.com/BobbyBlanco400/nexus-cos

---

## 🎨 v-Suite Components

The v-Suite represents our creative tools ecosystem:

1. **V-Screen Hollywood Edition** - Virtual production & LED volumes
2. **V-Caster Pro** - Professional broadcasting
3. **V-Stage** - Virtual staging & performance
4. **V-Prompter Pro** - Professional teleprompter

All integrated seamlessly within N3XUS v-COS on n3xus-net.

---

## 🔐 Security

- **Network Isolation:** Internal services on n3xus-net
- **Gateway Control:** Single entry point (n3xus-gateway)
- **Handshake Verification:** Required on all requests
- **Zero-Trust:** Verified at every layer

---

## 📞 Support

- **Documentation:** All docs in `/docs` directory
- **Issues:** https://github.com/BobbyBlanco400/nexus-cos/issues
- **Verification:** Run `./scripts/verify-pr-acceptance.sh`

---

**Status:** Production Ready  
**Version:** 1.0.0  
**Handshake:** 55-45-17  
**Network:** n3xus-net  
**Last Updated:** January 6, 2026

---

*"Sovereignty is not given; it is built, maintained, and verified at every layer."*
