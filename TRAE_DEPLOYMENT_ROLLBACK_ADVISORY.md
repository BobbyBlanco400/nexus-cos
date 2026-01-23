# TRAE DEPLOYMENT ROLLBACK ADVISORY
**Advisory ID:** TRAE-2026-001-ROLLBACK
**Date:** 2026-01-16
**Severity:** CRITICAL
**Target:** Hostinger VPS (72.62.86.217)

## 🚨 CRITICAL INCIDENT REPORT
**Issue:** VPS Resource Exhaustion (CPU/RAM/IO)
**Cause:** Concurrent deployment of 98+ services on 3GB RAM infrastructure.
**Impact:** SSH timeouts, container crashes, system instability.

## 🛑 IMMEDIATE ACTION REQUIRED
**Protocol:** N3XUS LAW 55-45-17
**Action:** Rollback to **Canonical 13-Service Core Stack**.
**Verification:** Ensure "X-N3XUS-Handshake: 55-45-17" compliance.

## 🛠️ CANONICAL 13-SERVICE CORE (Unified Mapping)
The following services constitute the stable core for Phase 3/4 Launch on limited hardware:

1.  **Infrastructure**: `nexus-cos-postgres`
2.  **Infrastructure**: `nexus-cos-redis`
3.  **Core API**: `puabo-api`
4.  **Auth**: `auth-service`
5.  **Orchestration**: `puabo-nexus-fleet-manager` (v-supercore equivalent)
6.  **Dispatch**: `puabo-nexus-ai-dispatch` (Federation Spine equivalent)
7.  **Casino Core**: `casino-nexus-api`
8.  **Ledger**: `ledger-mgr`
9.  **Wallet**: `token-mgr`
10. **Treasury**: `invoice-gen`
11. **Payouts**: `rewards-ms`
12. **Attestation**: `pv-keys`
13. **Gateway**: `nginx` (nexus-nginx)

## 📋 EXECUTION PLAN
1.  **Stop All Containers**: `docker compose -f docker-compose.unified.yml down`
2.  **Prune System**: `docker system prune -f` (Recover disk space)
3.  **Deploy Core**: `docker compose -f docker-compose.unified.yml up -d [SERVICE_LIST]`
4.  **Verify**: Check logs and handshake headers.

## 📜 EXECUTION SCRIPT
Run the following script on the VPS to execute this rollback immediately.

```bash
#!/bin/bash
set -e

echo "🚀 INITIATING TRAE ROLLBACK PROTOCOL..."

# 1. STOP EVERYTHING
echo "🛑 Stopping all containers..."
docker compose -f docker-compose.unified.yml down --remove-orphans || true

# 2. CLEANUP
echo "🧹 Cleaning up resources..."
docker system prune -f

# 3. DEPLOY CANONICAL 13
echo "🚀 Deploying Canonical 13-Service Core..."
export NEXUS_HANDSHAKE="55-45-17"

SERVICES="nexus-cos-postgres nexus-cos-redis puabo-api auth-service puabo-nexus-fleet-manager puabo-nexus-ai-dispatch casino-nexus-api ledger-mgr token-mgr invoice-gen rewards-ms pv-keys nginx"

docker compose -f docker-compose.unified.yml up -d $SERVICES

# 4. VERIFY
echo "✅ Deployment Complete. Checking status..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```
