# PF Final Deployment - Turnkey Guide

**Date:** 2025-01-04
**Status:** ✅ Production Ready

## Overview

This document provides a turnkey deployment guide for the Nexus COS Pre-Flight (PF) platform, including all prerequisites, build configurations, and deployment steps.

---

## Prerequisites

### System Requirements

- **VPS Access:** SSH access to deployment server
- **Docker:** Version 20.10 or higher
- **Docker Compose:** Version 2.0 or higher
- **Repository:** Cloned at `/opt/nexus-cos`
- **Disk Space:** Minimum 5GB free space
- **Ports:** 80, 443, 4000, 3002, 3016, 3041, 5432, 6379, 8088 available

### Required Credentials

Before deployment, you must configure the following credentials in `/opt/nexus-cos/.env.pf`:

| Credential | Description | Example/Format |
|-----------|-------------|----------------|
| `OAUTH_CLIENT_ID` | OAuth provider client ID | `your-client-id` |
| `OAUTH_CLIENT_SECRET` | OAuth provider client secret | `your-client-secret` |
| `JWT_SECRET` | JWT signing key (secure random string) | `your-jwt-secret-key-here` |
| `DB_PASSWORD` | PostgreSQL database password | `your_secure_password_here` |

**Setup Steps:**

1. Copy the example file:
   ```bash
   cd /opt/nexus-cos
   cp .env.pf.example .env.pf
   ```

2. Edit `.env.pf` and replace all placeholder values:
   ```bash
   nano .env.pf  # or vim, vi, etc.
   ```

3. Verify required variables are set:
   ```bash
   grep -E "OAUTH_CLIENT_ID|OAUTH_CLIENT_SECRET|JWT_SECRET|DB_PASSWORD" .env.pf
   ```

---

## TypeScript Build Configuration

### Frontend Build Prerequisites

The frontend service uses TypeScript for type checking and validation during the build process.

**Configuration Files:**

- `frontend/tsconfig.json` - Main TypeScript configuration
- `frontend/tsconfig.app.json` - Application-specific settings
- `frontend/tsconfig.node.json` - Node.js tooling settings

**Build Process:**

The `frontend/Dockerfile` implements the following build steps:

1. **Install Dependencies**
   ```dockerfile
   COPY package*.json ./
   RUN npm ci
   ```

2. **Copy TypeScript Configuration**
   ```dockerfile
   COPY tsconfig.json .
   COPY tsconfig.app.json .
   COPY tsconfig.node.json .
   ```

3. **Install TypeScript Dev Dependencies**
   ```dockerfile
   RUN npm install -D typescript @types/node
   ```

4. **Validate TypeScript**
   ```dockerfile
   RUN npx tsc --noEmit
   ```

5. **Build Production Assets**
   ```dockerfile
   RUN npm run build
   ```

**TypeScript Configuration:**

The `frontend/tsconfig.json` includes:
- Target: ES2020
- Module: ESNext
- JSX: react-jsx
- Strict type checking enabled
- Module resolution: node

---

## PF Service Stack

### Service Definitions

The PF stack is defined in `docker-compose.pf.yml` and includes:

| Service | Container Name | Port | Health Endpoint |
|---------|---------------|------|-----------------|
| Gateway API | puabo-api | 4000 | /health |
| AI SDK | nexus-cos-puaboai-sdk | 3002 | /health |
| PV Keys | nexus-cos-pv-keys | 3041 | /health |
| V-Screen Hollywood | vscreen-hollywood | 8088 | /health |
| StreamCore | nexus-cos-streamcore | 3016 | /health |
| Database | nexus-cos-postgres | 5432 | pg_isready |
| Cache | nexus-cos-redis | 6379 | redis-cli ping |

### Hollywood and Prompter Endpoints

**V-Screen Hollywood Edition** is now a dedicated service providing browser-based Virtual LED Volume/Virtual Production Suite:

- **V-Screen Hollywood:** Dedicated service on port 8088
  - Direct access: `http://localhost:8088`
  - Path-based: `/v-suite/hollywood`
  - Subdomain: `https://hollywood.nexuscos.online`
  - Features: LED volume rendering, virtual production, OTT/IPTV streaming
  - Dependencies: StreamCore, PUABO AI SDK, Nexus Auth

- **Prompter:** Available via puaboai-sdk (port 3002)
  - Access: `http://localhost:3002`
  - Path-based: `/v-suite/prompter`

Health checks:
```bash
curl -sf http://localhost:3002/health  # Prompter (via AI SDK)
curl -sf http://localhost:8088/health  # V-Screen Hollywood
curl -sf http://localhost:3016/health  # StreamCore (OTT/IPTV)
curl -sf http://localhost:4000/health  # Gateway API
```

---

## Deployment Steps

### Step 1: Pre-Deployment Validation

Run the validation script to check prerequisites:

```bash
cd /opt/nexus-cos
./validate-pf.sh
```

### Step 2: Configure Environment

Ensure `.env.pf` is configured with real credentials (see Prerequisites section above).

### Step 3: Build and Deploy PF Stack

Stop any existing services:
```bash
cd /opt/nexus-cos
docker compose -f docker-compose.pf.yml down
```

Build and start all services:
```bash
docker compose -f docker-compose.pf.yml up -d --build
```

### Step 4: Verify Deployment

Run health checks for all services:

```bash
# Gateway API health check
curl -sf http://localhost:4000/health

# Prompter health check (via AI SDK)
curl -sf http://localhost:3002/health

# PV Keys health check
curl -sf http://localhost:3041/health

# V-Screen Hollywood health check
curl -sf http://localhost:8088/health

# StreamCore health check
curl -sf http://localhost:3016/health

# Check all service statuses
docker compose -f docker-compose.pf.yml ps
```

Expected output: All services should show "Up" status and health checks should return 200 OK.

### Step 5: Verify Database

Check database connection and tables:

```bash
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres \
  psql -U nexus_user -d nexus_db -c "\dt"
```

Expected output: Should list `users`, `sessions`, `api_keys`, and `audit_log` tables.

---

## Troubleshooting

### TypeScript Build Failures

If the frontend build fails with TypeScript errors:

1. Verify `frontend/tsconfig.json` exists and is valid
2. Check that TypeScript dev dependencies are installed during build:
   ```bash
   docker compose -f docker-compose.pf.yml logs puabo-api | grep typescript
   ```
3. Review build logs for specific TypeScript errors:
   ```bash
   docker compose -f docker-compose.pf.yml logs --tail=100
   ```

### Health Check Failures

If health checks return 404 or connection refused:

1. Check service logs:
   ```bash
   docker compose -f docker-compose.pf.yml logs -f [service-name]
   ```

2. Verify ports are not in use:
   ```bash
   netstat -tulpn | grep -E "4000|3002|3041"
   ```

3. Restart the specific service:
   ```bash
   docker compose -f docker-compose.pf.yml restart [service-name]
   ```

### Credential Issues

If services fail to start due to missing credentials:

1. Check `.env.pf` exists:
   ```bash
   ls -la /opt/nexus-cos/.env.pf
   ```

2. Verify all required variables are set (no placeholders):
   ```bash
   grep -E "^(OAUTH_CLIENT_ID|OAUTH_CLIENT_SECRET|JWT_SECRET|DB_PASSWORD)=" .env.pf
   ```

3. Review service logs for authentication errors:
   ```bash
   docker compose -f docker-compose.pf.yml logs puabo-api | grep -i "auth\|oauth"
   ```

---

## Quick Commands Reference

### Deployment
```bash
# Full rebuild and deploy
cd /opt/nexus-cos
docker compose -f docker-compose.pf.yml down
docker compose -f docker-compose.pf.yml up -d --build

# Quick deploy (no rebuild)
./deploy-pf.sh
```

### Health Checks
```bash
# All health endpoints
curl http://localhost:4000/health  # Gateway
curl http://localhost:3002/health  # AI SDK / Prompter
curl http://localhost:3041/health  # PV Keys
```

### Service Management
```bash
# View all service statuses
docker compose -f docker-compose.pf.yml ps

# View logs (all services)
docker compose -f docker-compose.pf.yml logs -f

# View logs (specific service)
docker compose -f docker-compose.pf.yml logs -f puabo-api

# Restart all services
docker compose -f docker-compose.pf.yml restart

# Restart specific service
docker compose -f docker-compose.pf.yml restart puabo-api

# Stop all services
docker compose -f docker-compose.pf.yml down
```

### Database Access
```bash
# Connect to PostgreSQL
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres \
  psql -U nexus_user -d nexus_db

# View tables
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres \
  psql -U nexus_user -d nexus_db -c "\dt"

# Query users
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres \
  psql -U nexus_user -d nexus_db -c "SELECT * FROM users;"
```

---

## Deployment Verification Checklist

Use this checklist to verify a successful deployment:

- [ ] `.env.pf` configured with real credentials (no placeholders)
- [ ] All Docker images built successfully
- [ ] All services show "Up" status in `docker compose ps`
- [ ] Health check: `http://localhost:4000/health` returns 200 OK
- [ ] Health check: `http://localhost:3002/health` returns 200 OK
- [ ] Health check: `http://localhost:3041/health` returns 200 OK
- [ ] Database tables exist: `users`, `sessions`, `api_keys`, `audit_log`
- [ ] No error logs in service outputs
- [ ] Services can connect to database
- [ ] Services can connect to Redis cache

---

## Additional Documentation

- **[PF_DEPLOYMENT_VERIFICATION.md](../PF_DEPLOYMENT_VERIFICATION.md)** - Detailed deployment status and configuration
- **[PF_README.md](../PF_README.md)** - Complete PF platform guide
- **[PF_INDEX.md](../PF_INDEX.md)** - Quick reference index
- **[PF_FINAL_DEPLOYMENT_INDEX.md](./PF_FINAL_DEPLOYMENT_INDEX.md)** - Complete deployment index

---

**Last Updated:** 2025-01-04
**Status:** ✅ Production Ready for Deployment
