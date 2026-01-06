# Agent Deployment Procedures

**Version:** 1.0.0  
**Status:** Production  
**Network:** n3xus-net  
**Handshake:** 55-45-17  
**Date:** January 2026

---

## Overview

This document provides step-by-step procedures for automated agent deployment of N3XUS v-COS infrastructure, services, and configurations across the n3xus-net sovereign architecture.

---

## Prerequisites

### System Requirements

- Docker 20.10+ or Kubernetes 1.24+
- Minimum 16GB RAM
- 100GB available storage
- Ubuntu 22.04+ or equivalent

### Access Requirements

- GitHub repository access
- Docker Hub / GHCR credentials
- SSL certificates (production)
- Admin privileges on target systems

### Network Requirements

- Internal network configured for n3xus-net
- Firewall rules allowing ports: 80, 443, 3000-5000
- DNS resolution for internal hostnames (Docker/K8s network)

---

## Deployment Procedures

### Procedure 1: Initial Infrastructure Setup

**Objective:** Bootstrap n3xus-net network and core infrastructure

```bash
# 1. Clone repository
git clone https://github.com/BobbyBlanco400/nexus-cos.git
cd nexus-cos

# 2. Create n3xus-net network
docker network create n3xus-net --internal
docker network create n3xus-gateway

# 3. Verify network creation
docker network ls | grep n3xus

# 4. Create required directories
mkdir -p /data/n3xus/{postgres,redis,mongo,uploads}
chmod -R 755 /data/n3xus

# Expected Result: Networks created, directories ready
```

**Verification:**
- ✓ n3xus-net network exists and is internal
- ✓ n3xus-gateway network exists
- ✓ Data directories created with proper permissions

---

### Procedure 2: Database Layer Deployment

**Objective:** Deploy PostgreSQL, Redis, and MongoDB on n3xus-net

```bash
# 1. Deploy PostgreSQL
docker run -d \
  --name v-postgres \
  --network n3xus-net \
  -e POSTGRES_USER=nexus_admin \
  -e POSTGRES_PASSWORD=<secure_password> \
  -e POSTGRES_DB=nexus_v_cos \
  -v /data/n3xus/postgres:/var/lib/postgresql/data \
  postgres:15-alpine

# 2. Deploy Redis
docker run -d \
  --name v-redis \
  --network n3xus-net \
  -v /data/n3xus/redis:/data \
  redis:7-alpine

# 3. Deploy MongoDB
docker run -d \
  --name v-mongo \
  --network n3xus-net \
  -e MONGO_INITDB_ROOT_USERNAME=nexus_admin \
  -e MONGO_INITDB_ROOT_PASSWORD=<secure_password> \
  -v /data/n3xus/mongo:/data/db \
  mongo:6

# 4. Verify database deployments
docker ps --filter network=n3xus-net

# Expected Result: All 3 databases running on n3xus-net
```

**Verification:**
- ✓ v-postgres responding on port 5432
- ✓ v-redis responding on port 6379
- ✓ v-mongo responding on port 27017
- ✓ All services on n3xus-net network only

---

### Procedure 3: Core Services Deployment

**Objective:** Deploy v-auth, v-platform, v-stream services

```bash
# 1. Deploy v-auth service
docker run -d \
  --name v-auth \
  --network n3xus-net \
  -e DATABASE_URL=postgres://v-postgres:5432/nexus_auth \
  -e REDIS_URL=redis://v-redis:6379 \
  -e N3XUS_HANDSHAKE=55-45-17 \
  ghcr.io/bobbyblanco400/n3xus-v-auth:latest

# 2. Deploy v-platform service
docker run -d \
  --name v-platform \
  --network n3xus-net \
  -e DATABASE_URL=postgres://v-postgres:5432/nexus_platform \
  -e AUTH_SERVICE=http://v-auth:4000 \
  -e N3XUS_HANDSHAKE=55-45-17 \
  ghcr.io/bobbyblanco400/n3xus-v-platform:latest

# 3. Deploy v-stream service
docker run -d \
  --name v-stream \
  --network n3xus-net \
  -e AUTH_SERVICE=http://v-auth:4000 \
  -e PLATFORM_SERVICE=http://v-platform:4001 \
  -e N3XUS_HANDSHAKE=55-45-17 \
  ghcr.io/bobbyblanco400/n3xus-v-stream:latest

# 4. Verify services
docker exec v-stream curl -H "X-N3XUS-Handshake: 55-45-17" http://v-auth:4000/health

# Expected Result: All services communicating via internal hostnames
```

**Verification:**
- ✓ v-auth responding on port 4000
- ✓ v-platform responding on port 4001
- ✓ v-stream responding on port 3000
- ✓ Inter-service communication working
- ✓ Handshake validation functioning

---

### Procedure 4: NGINX Gateway Deployment

**Objective:** Deploy NGINX gateway as entry point to n3xus-net

```bash
# 1. Copy nginx configuration
cp nginx.conf /etc/nginx/n3xus-gateway.conf

# 2. Deploy NGINX gateway
docker run -d \
  --name n3xus-gateway \
  --network n3xus-net \
  --network n3xus-gateway \
  -p 80:80 \
  -p 443:443 \
  -v /etc/nginx/n3xus-gateway.conf:/etc/nginx/nginx.conf:ro \
  -v /etc/ssl/certs:/etc/ssl/certs:ro \
  nginx:alpine

# 3. Verify gateway
curl -I http://localhost/health

# Expected Result: Gateway routing to v-stream via n3xus-net
```

**Verification:**
- ✓ NGINX listening on ports 80/443
- ✓ Connected to both n3xus-net and n3xus-gateway
- ✓ SSL certificates loaded
- ✓ Handshake header injection working
- ✓ Health check passing through to services

---

### Procedure 5: v-Suite Services Deployment

**Objective:** Deploy V-Suite creative tools

```bash
# 1. Deploy v-suite service
docker run -d \
  --name v-suite \
  --network n3xus-net \
  -e AUTH_SERVICE=http://v-auth:4000 \
  -e CONTENT_SERVICE=http://v-content:4200 \
  -e N3XUS_HANDSHAKE=55-45-17 \
  ghcr.io/bobbyblanco400/n3xus-v-suite:latest

# 2. Deploy v-content service
docker run -d \
  --name v-content \
  --network n3xus-net \
  -e DATABASE_URL=mongo://v-mongo:27017/nexus_content \
  -e STORAGE_PATH=/data/uploads \
  -e N3XUS_HANDSHAKE=55-45-17 \
  -v /data/n3xus/uploads:/data/uploads \
  ghcr.io/bobbyblanco400/n3xus-v-content:latest

# Expected Result: v-Suite tools available
```

**Verification:**
- ✓ v-suite responding on port 4100
- ✓ v-content responding on port 4200
- ✓ File uploads working
- ✓ Integration with v-auth working

---

## Automated Deployment Scripts

### Full Stack Deployment

```bash
#!/bin/bash
# deploy-n3xus-v-cos.sh - Full stack automated deployment

set -euo pipefail

echo "=== N3XUS v-COS Automated Deployment ==="

# Step 1: Infrastructure
echo "[1/5] Setting up infrastructure..."
./scripts/setup-infrastructure.sh

# Step 2: Database layer
echo "[2/5] Deploying database layer..."
./scripts/deploy-databases.sh

# Step 3: Core services
echo "[3/5] Deploying core services..."
./scripts/deploy-core-services.sh

# Step 4: Gateway
echo "[4/5] Deploying NGINX gateway..."
./scripts/deploy-gateway.sh

# Step 5: v-Suite
echo "[5/5] Deploying v-Suite services..."
./scripts/deploy-v-suite.sh

echo "=== Deployment Complete ==="
echo "Verifying system health..."
./scripts/verify-deployment.sh
```

### Health Verification Script

```bash
#!/bin/bash
# verify-deployment.sh - Verify all services are healthy

set -euo pipefail

HANDSHAKE="55-45-17"
FAIL_COUNT=0

check_service() {
  local service=$1
  local port=$2
  local endpoint=${3:-/health}
  
  echo -n "Checking $service... "
  
  if docker exec v-stream curl -sf \
    -H "X-N3XUS-Handshake: $HANDSHAKE" \
    "http://$service:$port$endpoint" > /dev/null; then
    echo "✓ OK"
  else
    echo "✗ FAIL"
    ((FAIL_COUNT++))
  fi
}

echo "=== N3XUS v-COS Health Check ==="

check_service "v-postgres" "5432" ""
check_service "v-redis" "6379" ""
check_service "v-mongo" "27017" ""
check_service "v-auth" "4000"
check_service "v-platform" "4001"
check_service "v-stream" "3000"
check_service "v-suite" "4100"
check_service "v-content" "4200"

if [ $FAIL_COUNT -eq 0 ]; then
  echo "✓ All services healthy"
  exit 0
else
  echo "✗ $FAIL_COUNT service(s) failed"
  exit 1
fi
```

---

## Rollback Procedures

### Service Rollback

```bash
# 1. Stop failed service
docker stop v-service-name

# 2. Restore previous version
docker run -d \
  --name v-service-name \
  --network n3xus-net \
  [previous configuration] \
  ghcr.io/bobbyblanco400/n3xus-v-service:previous-tag

# 3. Verify rollback
docker exec v-stream curl http://v-service-name:port/health
```

### Database Rollback

```bash
# 1. Stop service
docker stop v-postgres

# 2. Restore from backup
docker run -d \
  --name v-postgres \
  --network n3xus-net \
  -v /data/n3xus/postgres-backup-YYYYMMDD:/var/lib/postgresql/data \
  postgres:15-alpine

# 3. Verify data integrity
docker exec v-postgres psql -U nexus_admin -c "SELECT version();"
```

---

## Troubleshooting

### Service Cannot Connect to Database

```bash
# 1. Check network connectivity
docker exec v-service-name ping v-postgres

# 2. Check database logs
docker logs v-postgres

# 3. Verify credentials
docker exec v-service-name env | grep DATABASE_URL

# 4. Test connection manually
docker exec v-service-name psql -h v-postgres -U nexus_admin
```

### Handshake Validation Failures

```bash
# 1. Check handshake header in service
docker logs v-auth | grep "handshake"

# 2. Verify environment variable
docker exec v-auth env | grep N3XUS_HANDSHAKE

# 3. Test with explicit header
curl -H "X-N3XUS-Handshake: 55-45-17" http://v-auth:4000/health
```

---

## Acceptance Criteria

See [Acceptance Criteria](./acceptance-criteria.md) for detailed validation requirements.

---

**Status:** Production Ready  
**Maintained By:** N3XUS Platform Team  
**Last Updated:** January 2026
