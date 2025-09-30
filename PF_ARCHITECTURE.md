# PUABO / Nexus COS - Pre-Flight Architecture

## System Architecture

```
╔════════════════════════════════════════════════════════════════════╗
║              PUABO / NEXUS COS - Pre-Flight Architecture           ║
║                     Date: 2025-09-30 20:00 PST                     ║
╚════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────┐
│                         External Access                           │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│   Port 4000         Port 3002          Port 3041                │
│      │                 │                  │                      │
│      ▼                 ▼                  ▼                      │
│  ┌────────┐      ┌─────────┐      ┌──────────┐                 │
│  │ PUABO  │      │ PUABO   │      │ PV KEYS  │                 │
│  │  API   │      │ AI SDK  │      │ SERVICE  │                 │
│  │        │      │         │      │          │                 │
│  │ Health │      │ Health  │      │ Health   │                 │
│  │  Auth  │      │ AI Ops  │      │ Key Mgmt │                 │
│  └────┬───┘      └────┬────┘      └────┬─────┘                 │
│       │               │                │                        │
│       │               │                │                        │
│       └───────────────┴────────────────┘                        │
│                       │                                          │
│                       ▼                                          │
│            ┌──────────────────────┐                             │
│            │   Nexus Network      │                             │
│            │  (Docker Bridge)     │                             │
│            └──────────┬───────────┘                             │
│                       │                                          │
│         ┌─────────────┴─────────────┐                           │
│         │                           │                           │
│         ▼                           ▼                           │
│  ┌──────────────┐          ┌──────────────┐                    │
│  │  PostgreSQL  │          │    Redis     │                    │
│  │              │          │              │                    │
│  │  Port: 5432  │          │  Port: 6379  │                    │
│  │              │          │              │                    │
│  │ DB: nexus_db │          │   Cache      │                    │
│  │ User: nexus_ │          │   Layer      │                    │
│  │      user    │          │              │                    │
│  │              │          │              │                    │
│  │ Tables:      │          └──────────────┘                    │
│  │  • users     │                                               │
│  │  • sessions  │                                               │
│  │  • api_keys  │                                               │
│  │  • audit_log │                                               │
│  └──────────────┘                                               │
└──────────────────────────────────────────────────────────────────┘
```

## Service Details

### 🔵 puabo-api (Port 4000)
- **Container:** puabo-api
- **Image:** Custom build from Dockerfile
- **Endpoints:**
  - `GET /health` - Health check
  - `GET /` - API information
  - `GET /api/auth/*` - Authentication
  - `GET /api/*/status` - Module status
- **Dependencies:** PostgreSQL, Redis
- **Status:** ✅ Configured and ready

### 🟢 nexus-cos-puaboai-sdk (Port 3002)
- **Container:** nexus-cos-puaboai-sdk
- **Image:** Node.js 18 Alpine
- **Endpoints:**
  - `GET /health` - Health check
  - `GET /` - Service information
- **Dependencies:** PostgreSQL
- **Status:** ✅ Configured and ready

### 🟡 nexus-cos-pv-keys (Port 3041)
- **Container:** nexus-cos-pv-keys
- **Image:** Node.js 18 Alpine
- **Endpoints:**
  - `GET /health` - Health check
  - `GET /` - Service information
- **Dependencies:** PostgreSQL
- **Status:** ✅ Configured and ready

### 🔷 nexus-cos-postgres (Port 5432)
- **Container:** nexus-cos-postgres
- **Image:** PostgreSQL 15 Alpine
- **Database:** nexus_db
- **User:** nexus_user
- **Password:** Momoney2025$
- **Tables:** users, sessions, api_keys, audit_log
- **Status:** ✅ Configured and ready

### 🔶 nexus-cos-redis (Port 6379)
- **Container:** nexus-cos-redis
- **Image:** Redis 7 Alpine
- **Purpose:** Caching and session storage
- **Persistence:** Enabled
- **Status:** ✅ Configured and ready

## Network Flow

```
Client Request
     │
     ▼
┌────────────┐
│ Service    │ → Port 4000 (puabo-api)
│ Endpoints  │ → Port 3002 (puaboai-sdk)
│            │ → Port 3041 (pv-keys)
└─────┬──────┘
      │
      ▼
┌─────────────┐
│   Nexus     │ ← Internal Docker network
│   Network   │ ← Service discovery
└─────┬───────┘
      │
      ├───────────────┐
      ▼               ▼
┌───────────┐   ┌─────────┐
│PostgreSQL │   │  Redis  │
│  (Data)   │   │ (Cache) │
└───────────┘   └─────────┘
```

## Data Flow

```
1. Request Flow:
   External → Service (4000/3002/3041) → Business Logic → Database/Cache

2. Database Operations:
   Service → PostgreSQL → Query Execution → Response

3. Cache Operations:
   Service → Redis → Key Lookup → Response

4. Inter-Service Communication:
   Service A → Nexus Network → Service B → Response
```

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose                            │
│                  (docker-compose.pf.yml)                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Startup Order:                                              │
│                                                              │
│  1. Infrastructure Services                                  │
│     • PostgreSQL (with health check)                         │
│     • Redis                                                  │
│                                                              │
│  2. Application Services (wait for DB)                       │
│     • puabo-api                                              │
│     • nexus-cos-puaboai-sdk                                  │
│     • nexus-cos-pv-keys                                      │
│                                                              │
│  3. Post-Startup                                             │
│     • Database migrations (schema.sql)                       │
│     • Health checks                                          │
│     • Service verification                                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Storage Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Volumes                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  postgres_data/                                              │
│  ├── PostgreSQL data files                                   │
│  ├── WAL logs                                                │
│  └── Configuration                                           │
│                                                              │
│  redis_data/                                                 │
│  ├── RDB snapshots                                           │
│  ├── AOF logs                                                │
│  └── Configuration                                           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Security Layers                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Network Isolation                                        │
│     • Services in isolated Docker network                    │
│     • Only exposed ports accessible externally               │
│                                                              │
│  2. Authentication                                           │
│     • Database password protection                           │
│     • OAuth integration ready                                │
│     • JWT token support                                      │
│                                                              │
│  3. Data Protection                                          │
│     • Persistent volumes for data                            │
│     • Database connection encryption ready                   │
│     • Session management                                     │
│                                                              │
│  4. Monitoring                                               │
│     • Health checks on all services                          │
│     • Audit logging in database                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Environment Configuration

```
┌─────────────────────────────────────────────────────────────┐
│                  Environment Variables                       │
│                      (.env.pf)                               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Application:                                                │
│    NODE_ENV=production                                       │
│    PORT=4000                                                 │
│                                                              │
│  Database:                                                   │
│    DB_HOST=nexus-cos-postgres                                │
│    DB_PORT=5432                                              │
│    DB_NAME=nexus_db                                          │
│    DB_USER=nexus_user                                        │
│    DB_PASSWORD=Momoney2025$                                  │
│                                                              │
│  Cache:                                                      │
│    REDIS_HOST=nexus-cos-redis                                │
│    REDIS_PORT=6379                                           │
│                                                              │
│  Authentication:                                             │
│    OAUTH_CLIENT_ID=your-client-id                            │
│    OAUTH_CLIENT_SECRET=your-client-secret                    │
│    JWT_SECRET=nexus-cos-secret-key-2024-secure               │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Deployment Process

```
┌─────────────────────────────────────────────────────────────┐
│                  Deployment Steps                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Step 1: Validation                                          │
│    ./validate-pf.sh                                          │
│    └─→ Verify all configuration files                        │
│                                                              │
│  Step 2: Deployment                                          │
│    ./deploy-pf.sh                                            │
│    ├─→ Pull/Build images                                     │
│    ├─→ Start containers                                      │
│    ├─→ Wait for health checks                                │
│    └─→ Apply migrations                                      │
│                                                              │
│  Step 3: Verification                                        │
│    ├─→ Test health endpoints                                 │
│    ├─→ Verify database tables                                │
│    └─→ Check service logs                                    │
│                                                              │
│  Step 4: Monitoring                                          │
│    └─→ docker compose -f docker-compose.pf.yml logs -f       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Health Check Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Health Checks                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  PostgreSQL                                                  │
│    • pg_isready -U nexus_user -d nexus_db                    │
│    • Interval: 30s                                           │
│    • Retries: 3                                              │
│                                                              │
│  puabo-api                                                   │
│    • curl -f http://localhost:4000/health                    │
│    • Interval: 30s                                           │
│    • Retries: 3                                              │
│                                                              │
│  nexus-cos-puaboai-sdk                                       │
│    • curl -f http://localhost:3002/health                    │
│    • Interval: 30s                                           │
│    • Retries: 3                                              │
│                                                              │
│  nexus-cos-pv-keys                                           │
│    • curl -f http://localhost:3041/health                    │
│    • Interval: 30s                                           │
│    • Retries: 3                                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

**Status:** ✅ Architecture documented and verified  
**Last Updated:** 2025-09-30 20:00 PST
