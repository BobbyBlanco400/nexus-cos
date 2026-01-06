# n3xus-net: Sovereign Network Architecture

**Version:** 1.0.0  
**Status:** Production  
**Handshake:** 55-45-17  
**Date:** January 2026

---

## Overview

**n3xus-net** is the sovereign network architecture powering N3XUS v-COS. It provides a secure, self-contained networking layer that enables internal service communication with complete network sovereignty and zero external dependencies for core operations.

### Key Principles

1. **Sovereign by Design** - Complete control over network topology and routing
2. **Internal-First** - All core services communicate via internal hostnames
3. **Gateway-Secured** - Single NGINX gateway for external access
4. **Service Discovery** - Built-in DNS resolution for n3xus-net services
5. **Zero-Trust Architecture** - Handshake verification (55-45-17) at every layer

---

## Network Topology

### Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    External Internet                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              NGINX Gateway (n3xus-gateway)                   │
│          - SSL Termination                                   │
│          - Handshake Injection (55-45-17)                    │
│          - Rate Limiting                                     │
│          - Request Routing                                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    n3xus-net (Internal)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   v-stream   │  │   v-suite    │  │  v-platform  │      │
│  │  (Streaming) │  │  (Creative)  │  │    (Core)    │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐      │
│  │   v-auth     │  │   v-content  │  │   v-compute  │      │
│  │ (Identity)   │  │    (CDN)     │  │  (Workers)   │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│  ┌──────▼──────────────────▼──────────────────▼───────┐    │
│  │            v-data (Database Layer)                  │    │
│  │  - PostgreSQL (v-postgres)                          │    │
│  │  - Redis (v-redis)                                  │    │
│  │  - MongoDB (v-mongo)                                │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## Internal Hostname Schema

### Core Services

All services use the `v-` prefix to denote virtual/n3xus-net services:

| Service | Internal Hostname | Port | Purpose |
|---------|------------------|------|---------|
| **Gateway** | `n3xus-gateway` | 80/443 | External entry point |
| **Streaming** | `v-stream` | 3000 | Main streaming service |
| **Authentication** | `v-auth` | 4000 | Identity & access |
| **Platform Core** | `v-platform` | 4001 | Core platform API |
| **v-Suite** | `v-suite` | 4100 | Creative tools suite |
| **Content Service** | `v-content` | 4200 | Content management |
| **Compute** | `v-compute` | 5000 | Background workers |
| **Database (PostgreSQL)** | `v-postgres` | 5432 | Primary datastore |
| **Cache (Redis)** | `v-redis` | 6379 | Session & cache |
| **Documents (MongoDB)** | `v-mongo` | 27017 | Document store |

### Service Discovery

All services can resolve each other using internal hostnames:

```bash
# Example: v-stream connecting to v-auth
curl http://v-auth:4000/api/verify

# Example: v-suite connecting to v-content
curl http://v-content:4200/api/assets

# Example: v-platform connecting to v-postgres
psql -h v-postgres -p 5432 -U nexus_admin
```

---

## Security Architecture

### Handshake Protocol (55-45-17)

Every request within n3xus-net must include the handshake header:

```
X-N3XUS-Handshake: 55-45-17
```

**Enforcement Points:**
1. NGINX Gateway - Injects header for external requests
2. Service Middleware - Validates header on every endpoint
3. Database Proxies - Rejects connections without handshake
4. Inter-service Communication - Required for all internal calls

### Network Isolation

- **External Access:** Only through NGINX gateway
- **Internal Services:** Cannot be accessed directly from outside
- **Service-to-Service:** Uses internal hostnames only
- **Database Layer:** Completely isolated, internal-only access

---

## References

- [N3XUS v-COS Documentation](../v-COS/)
- [Sovereign Genesis Architecture](../Sovereign-Genesis/)
- [NGINX Gateway Configuration](../../nginx.conf)

---

**Status:** Production Ready  
**Maintained By:** N3XUS Platform Team  
**Last Updated:** January 2026
