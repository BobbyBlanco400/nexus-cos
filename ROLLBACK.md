# Zero-Trust Rollback Plan — NΞ3XUS·COS

## Principles

- **No human trust** - All rollback procedures are automated and verified
- **No partial rollbacks** - Either complete rollback or no rollback
- **No live mutation** - No hotfixes or manual edits during rollback
- **Immutable snapshots** - All rollbacks restore from verified snapshots

## Rollback Triggers

Automatic rollback will be initiated if any of the following conditions are met:

### Critical Triggers (Immediate Rollback)
1. **Restart Loop** - Any service restarting more than 3 times in 5 minutes
2. **Ledger Fee Enforcement Failure** - Platform fee not being collected correctly
3. **Cross-Tenant Data Access** - Tenant isolation breach detected
4. **Streaming Outage** - Any tenant streaming service down for >2 minutes
5. **Authentication Failure** - Auth service returning >10% error rate
6. **Database Corruption** - Data integrity check failures
7. **Control Panel Lockdown** - Emergency lockdown activated by founder

### Warning Triggers (Manual Review Required)
1. **High Error Rate** - Any service >5% error rate for >5 minutes
2. **Performance Degradation** - Response time P95 >500ms
3. **Resource Exhaustion** - CPU >90% or Memory >85% for >3 minutes
4. **Compliance Violation** - SOC-2 audit log gaps detected

## Rollback Procedure

### Phase 1: Freeze and Snapshot (60 seconds)

```bash
#!/bin/bash
# Freeze ingress traffic
echo "🔒 Freezing ingress..."
docker exec nginx nginx -s stop
kubectl scale deployment/nginx-ingress --replicas=0

# Create emergency snapshots
echo "📸 Creating emergency snapshots..."
SNAPSHOT_ID=$(date +%s)

# Snapshot critical volumes
docker run --rm -v postgres-data:/data -v /backup:/backup \
  alpine tar czf /backup/postgres-${SNAPSHOT_ID}.tar.gz /data

docker run --rm -v ledger-data:/data -v /backup:/backup \
  alpine tar czf /backup/ledger-${SNAPSHOT_ID}.tar.gz /data

docker run --rm -v wallet-data:/data -v /backup:/backup \
  alpine tar czf /backup/wallet-${SNAPSHOT_ID}.tar.gz /data

echo "✅ Snapshots created: $SNAPSHOT_ID"
```

### Phase 2: Stop Tiers in Reverse Order (120 seconds)

```bash
# Stop Tier 4 (Virtual Casino & AI)
echo "⏹️  Stopping Tier 4..."
docker compose stop avatar-ms world-engine-ms gamecore-ms \
  casino-nexus-api rewards-ms skill-games-ms puabo-nexus-ai-dispatch

# Stop Tier 3 (Streaming Extensions)
echo "⏹️  Stopping Tier 3..."
docker compose stop streaming-service-v2 chat-stream-ms ott-api

# Stop Tier 2 (Platform Services)
echo "⏹️  Stopping Tier 2..."
docker compose stop license-service musicchain-ms puabomusicchain \
  dsp-api content-management

# Stop Tier 1 (Economic Core)
echo "⏹️  Stopping Tier 1..."
docker compose stop ledger-mgr wallet-ms token-mgr invoice-gen

echo "✅ All upper tiers stopped"
```

### Phase 3: Restore Last Known Good Images (180 seconds)

```bash
# Pull last known good images
echo "⬇️  Pulling last known good images..."
LAST_GOOD_TAG=$(cat /var/nexus/last-good-deployment.txt)

docker compose pull --tag ${LAST_GOOD_TAG}

# Verify image checksums
echo "🔐 Verifying image integrity..."
for service in postgres redis streamcore puabo-api auth-service; do
  docker image inspect ${service}:${LAST_GOOD_TAG} | jq -r '.[0].RepoDigests'
done

echo "✅ Images restored and verified"
```

### Phase 4: Restart Tier 0 Only (60 seconds)

```bash
# Start only foundation tier
echo "🚀 Starting Tier 0 (Foundation)..."
docker compose up -d postgres redis streamcore puabo-api auth-service pv-keys puaboai-sdk

# Wait for health checks
echo "⏳ Waiting for Tier 0 health..."
timeout 60 bash << 'EOF'
while true; do
  if curl -sf http://puabo-api:3000/health > /dev/null && \
     curl -sf http://auth-service:3001/health > /dev/null; then
    echo "✅ Tier 0 healthy"
    break
  fi
  echo "Waiting for health..."
  sleep 5
done
EOF

echo "✅ Tier 0 operational"
```

### Phase 5: Validate Foundation (120 seconds)

```bash
# Comprehensive foundation validation
echo "🔍 Validating foundation layer..."

# Test database connectivity
docker exec postgres psql -U nexus -c "SELECT 1" || exit 1

# Test Redis
docker exec redis redis-cli ping | grep PONG || exit 1

# Test API authentication
curl -sf -X POST http://auth-service:3001/auth/verify \
  -H "Authorization: Bearer test-token" || exit 1

# Test key service
curl -sf http://pv-keys:3002/keys/health || exit 1

echo "✅ Foundation validated"
```

### Phase 6: Re-enable Ingress (30 seconds)

```bash
# Restore ingress
echo "🔓 Re-enabling ingress..."
docker exec nginx nginx
kubectl scale deployment/nginx-ingress --replicas=3

# Wait for ingress health
timeout 30 bash << 'EOF'
while true; do
  if curl -sf https://n3xuscos.online/health > /dev/null; then
    echo "✅ Ingress healthy"
    break
  fi
  echo "Waiting for ingress..."
  sleep 3
done
EOF

echo "✅ Ingress restored"
```

### Phase 7: Post-Rollback Verification (60 seconds)

```bash
# Final verification
echo "🔍 Post-rollback verification..."

# Run minimal verification suite
./nexus-ai/verify/verify-handshake.sh || exit 1

# Test critical endpoints
curl -sf https://n3xuscos.online/health || exit 1
curl -sf https://n3xuscos.online/api/auth/health || exit 1

# Check no services are in restart loop
docker ps --filter "health=unhealthy" | grep . && exit 1

echo "✅ Rollback complete and verified"
```

## Forbidden Actions During Rollback

The following actions are **strictly prohibited** during rollback:

1. ❌ **Hotfixing containers** - No manual edits to running containers
2. ❌ **Manual DB edits** - No direct database modifications
3. ❌ **Skipping tiers** - All tiers must be stopped/started in order
4. ❌ **Partial rollbacks** - Cannot rollback individual services
5. ❌ **Live debugging** - No exec into containers during rollback
6. ❌ **Configuration changes** - No config file modifications

## Rollback Script

Complete rollback automation is available at:

```bash
./scripts/rollback.sh
```

## Post-Rollback Actions

After successful rollback:

1. **Alert team** - Notify all stakeholders of rollback
2. **Incident report** - Create detailed incident report
3. **Root cause analysis** - Investigate what triggered rollback
4. **Fix and test** - Develop fix in staging environment
5. **Scheduled redeployment** - Deploy fix during maintenance window

## Rollback Testing

Rollback procedures must be tested monthly:

```bash
# Test rollback in staging
./scripts/test-rollback.sh staging

# Verify rollback completed in <10 minutes
# Verify all Tier 0 services healthy
# Verify no data loss
```

## Recovery Time Objectives (RTO)

| Component | Target RTO | Maximum RTO |
|-----------|-----------|-------------|
| Ingress Freeze | 10 seconds | 30 seconds |
| Tier Shutdown | 2 minutes | 5 minutes |
| Image Restore | 3 minutes | 10 minutes |
| Tier 0 Restart | 2 minutes | 5 minutes |
| Foundation Validation | 2 minutes | 5 minutes |
| Ingress Restore | 30 seconds | 2 minutes |
| **Total Rollback** | **10 minutes** | **30 minutes** |

## Data Loss Prevention

To prevent data loss during rollback:

1. **Continuous snapshots** - Every 15 minutes for critical data
2. **Write-ahead logs** - All databases use WAL with replication
3. **Transaction journaling** - Ledger maintains full transaction log
4. **Immutable audit logs** - Cannot be modified or deleted
5. **Point-in-time recovery** - Can restore to any point in last 7 days

## Monitoring During Rollback

Monitor these metrics during rollback:

- Ingress traffic (should drop to zero)
- Database connections (should gracefully close)
- Service restart counts (should be zero after rollback)
- Error rates (should stabilize after Tier 0 restart)
- Control panel status (should show all services operational)

## Success Criteria

Rollback is considered successful when:

- ✅ All Tier 0 services healthy
- ✅ Database and Redis operational
- ✅ Authentication working
- ✅ Health endpoints responding
- ✅ No services in restart loop
- ✅ Ingress accepting traffic
- ✅ No data loss detected
- ✅ Control panel accessible

## Failure Escalation

If rollback fails:

1. **Emergency contact** - Page on-call engineer immediately
2. **Manual intervention** - Senior engineer assessment required
3. **Data preservation** - Prioritize data integrity over uptime
4. **Customer communication** - Status page updated
5. **Extended maintenance** - May require full platform rebuild

---

**Remember:** Rollback must be atomic or not executed. Never attempt partial recovery.

**Last Updated:** December 25, 2025
**Owner:** Nexus COS DevOps Team
**Review Frequency:** Monthly
