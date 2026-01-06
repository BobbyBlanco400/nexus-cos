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

## Configuration

### Docker Compose (n3xus-net)

```yaml
version: '3.8'

networks:
  n3xus-net:
    driver: bridge
    internal: true
  n3xus-gateway:
    driver: bridge

services:
  n3xus-gateway:
    image: nginx:latest
    networks:
      - n3xus-net
      - n3xus-gateway
    ports:
      - "80:80"
      - "443:443"
    environment:
      - N3XUS_HANDSHAKE=55-45-17
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - /etc/ssl/certs:/etc/ssl/certs:ro

  v-stream:
    image: ghcr.io/bobbyblanco400/n3xus-v-stream:latest
    networks:
      - n3xus-net
    environment:
      - AUTH_SERVICE=http://v-auth:4000
      - PLATFORM_SERVICE=http://v-platform:4001
      - N3XUS_HANDSHAKE=55-45-17
    depends_on:
      - v-auth
      - v-platform

  v-auth:
    image: ghcr.io/bobbyblanco400/n3xus-v-auth:latest
    networks:
      - n3xus-net
    environment:
      - DATABASE_URL=postgres://v-postgres:5432/nexus_auth
      - REDIS_URL=redis://v-redis:6379
      - N3XUS_HANDSHAKE=55-45-17
    depends_on:
      - v-postgres
      - v-redis

  v-platform:
    image: ghcr.io/bobbyblanco400/n3xus-v-platform:latest
    networks:
      - n3xus-net
    environment:
      - DATABASE_URL=postgres://v-postgres:5432/nexus_platform
      - AUTH_SERVICE=http://v-auth:4000
      - N3XUS_HANDSHAKE=55-45-17
    depends_on:
      - v-postgres
      - v-auth

  v-suite:
    image: ghcr.io/bobbyblanco400/n3xus-v-suite:latest
    networks:
      - n3xus-net
    environment:
      - AUTH_SERVICE=http://v-auth:4000
      - CONTENT_SERVICE=http://v-content:4200
      - N3XUS_HANDSHAKE=55-45-17

  v-content:
    image: ghcr.io/bobbyblanco400/n3xus-v-content:latest
    networks:
      - n3xus-net
    environment:
      - MONGO_URL=mongodb://v-mongo:27017/nexus_content
      - N3XUS_HANDSHAKE=55-45-17
    volumes:
      - /data/n3xus/uploads:/uploads

  v-postgres:
    image: postgres:15-alpine
    networks:
      - n3xus-net
    environment:
      - POSTGRES_USER=nexus_admin
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=nexus_v_cos
    volumes:
      - /data/n3xus/postgres:/var/lib/postgresql/data

  v-redis:
    image: redis:7-alpine
    networks:
      - n3xus-net
    volumes:
      - /data/n3xus/redis:/data

  v-mongo:
    image: mongo:6
    networks:
      - n3xus-net
    environment:
      - MONGO_INITDB_ROOT_USERNAME=nexus_admin
      - MONGO_INITDB_ROOT_PASSWORD=${MONGO_PASSWORD}
    volumes:
      - /data/n3xus/mongo:/data/db
```

### Kubernetes (n3xus-net)

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: n3xus-net
  labels:
    handshake: "55-45-17"

---

apiVersion: v1
kind: Service
metadata:
  name: v-stream
  namespace: n3xus-net
spec:
  selector:
    app: v-stream
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
  type: ClusterIP

---

apiVersion: v1
kind: Service
metadata:
  name: v-auth
  namespace: n3xus-net
spec:
  selector:
    app: v-auth
  ports:
    - protocol: TCP
      port: 4000
      targetPort: 4000
  type: ClusterIP
```

---

## Deployment Patterns

### Development

```bash
# Start n3xus-net locally
docker-compose -f docker-compose.n3xus-net.yml up -d

# Verify internal connectivity
docker exec v-stream curl http://v-auth:4000/health

# Check service logs
docker logs v-stream
docker logs v-auth
```

### Production

```bash
# Deploy to Kubernetes
kubectl apply -f k8s/n3xus-net/

# Verify service discovery
kubectl exec -n n3xus-net v-stream-0 -- curl http://v-auth:4000/health

# Scale services
kubectl scale -n n3xus-net deployment/v-stream --replicas=5
```

---

## Monitoring & Observability

### Health Checks

All n3xus-net services expose health endpoints:

```
GET http://{service-hostname}:{port}/health

Response:
{
  "status": "healthy",
  "service": "v-stream",
  "handshake": "verified",
  "connections": {
    "v-auth": "connected",
    "v-platform": "connected"
  }
}
```

### Service Mesh Metrics

```
# Prometheus metrics endpoint
GET http://{service-hostname}:{port}/metrics

# Key metrics:
- n3xus_net_requests_total
- n3xus_net_handshake_failures
- n3xus_net_service_latency
- n3xus_net_connection_pool_size
```

---

## Migration Guide

### From External Domains to n3xus-net

**Before:**
```javascript
// Old: External domain references
const AUTH_URL = 'https://auth.nexuscos.com';
const API_URL = 'https://api.nexuscos.com';
```

**After:**
```javascript
// New: Internal n3xus-net hostnames
const AUTH_URL = 'http://v-auth:4000';
const API_URL = 'http://v-platform:4001';
```

### NGINX Configuration Update

See: [NGINX Gateway Alignment Guide](../../nginx.conf)

---

## Troubleshooting

### Service Cannot Resolve Hostname

```bash
# Check DNS resolution
docker exec v-stream nslookup v-auth

# Verify network connectivity
docker exec v-stream ping v-auth

# Check service is running
docker ps --filter name=v-auth
```

### Handshake Verification Failures

```bash
# Check handshake header
curl -H "X-N3XUS-Handshake: 55-45-17" http://v-auth:4000/health

# View service logs
docker logs v-auth | grep "handshake"
```

---

## References

- [N3XUS v-COS Documentation](../v-COS/)
- [Sovereign Genesis Architecture](../Sovereign-Genesis/)
- [NGINX Gateway Configuration](../../nginx.conf)

---

**Status:** Production Ready  
**Maintained By:** N3XUS Platform Team  
**Last Updated:** January 2026
