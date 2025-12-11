# Failover & Disaster Recovery Runbook

## Overview

This runbook provides comprehensive procedures for handling failover scenarios and disaster recovery for the Nexus COS platform. These procedures ensure business continuity and minimal data loss during catastrophic failures.

## Recovery Objectives

### RPO & RTO Targets

| Component | RPO (Recovery Point Objective) | RTO (Recovery Time Objective) |
|-----------|-------------------------------|------------------------------|
| Database (PostgreSQL) | 15 minutes | 1 hour |
| Database (MongoDB) | 15 minutes | 1 hour |
| Cache (Redis) | 1 hour | 30 minutes |
| Application Services | 5 minutes | 30 minutes |
| File Storage | 1 hour | 2 hours |
| Full System | 15 minutes | 4 hours |

### Availability Targets

- **Overall System**: 99.99% (52.56 minutes downtime/year)
- **Critical Services**: 99.99%
- **Standard Services**: 99.95%
- **Supporting Services**: 99.9%

## 1. Disaster Scenarios

### Scenario Classification

| Severity | Description | Example | Response |
|----------|-------------|---------|----------|
| P0 - Critical | Complete system failure | Data center outage | Execute full DR plan |
| P1 - High | Major component failure | Database cluster down | Component failover |
| P2 - Medium | Service degradation | Single service failure | Service restart/failover |
| P3 - Low | Minor issues | Single pod failure | Auto-recovery |

## 2. Database Failover

### PostgreSQL Failover

#### Automatic Failover (Patroni)

The system uses Patroni for automatic PostgreSQL failover:

```bash
# Check cluster status
kubectl exec -it postgresql-0 -n nexus-platform -- patronictl list

# Expected output:
# + Cluster: postgresql (7123456789012345678) ---+----+-----------+
# | Member       | Host        | Role    | State   | TL | Lag in MB |
# +--------------+-------------+---------+---------+----+-----------+
# | postgresql-0 | 10.0.1.10   | Leader  | running | 3  |           |
# | postgresql-1 | 10.0.1.11   | Replica | running | 3  |         0 |
# | postgresql-2 | 10.0.1.12   | Replica | running | 3  |         0 |
# +--------------+-------------+---------+---------+----+-----------+
```

#### Manual Failover

If automatic failover fails:

```bash
# 1. Check current leader
kubectl exec -it postgresql-0 -n nexus-platform -- patronictl list

# 2. Failover to specific node
kubectl exec -it postgresql-0 -n nexus-platform -- patronictl failover postgresql --candidate postgresql-1

# 3. Verify new leader
kubectl exec -it postgresql-0 -n nexus-platform -- patronictl list

# 4. Update application connection strings if needed
kubectl set env deployment/backend-api -n nexus-platform \
  DATABASE_URL="postgresql://nexus:password@postgresql-1:5432/nexus_cos"

# 5. Restart affected applications
kubectl rollout restart deployment/backend-api -n nexus-platform
```

#### Point-in-Time Recovery (PITR)

If data corruption occurred:

```bash
# 1. Stop all applications writing to database
kubectl scale deployment --all --replicas=0 -n nexus-platform

# 2. Determine recovery point
# List available backups
aws s3 ls s3://nexus-cos-backups/postgresql/

# 3. Restore base backup
aws s3 cp s3://nexus-cos-backups/postgresql/base-2024-12-11.tar.gz /tmp/
tar -xzf /tmp/base-2024-12-11.tar.gz -C /var/lib/postgresql/data/

# 4. Configure recovery target
cat > /var/lib/postgresql/data/recovery.conf << EOF
restore_command = 'aws s3 cp s3://nexus-cos-backups/postgresql/wal/%f %p'
recovery_target_time = '2024-12-11 10:30:00'
recovery_target_action = 'promote'
EOF

# 5. Start PostgreSQL
kubectl rollout restart statefulset/postgresql -n nexus-platform

# 6. Verify recovery
kubectl exec -it postgresql-0 -n nexus-platform -- psql -U nexus -c "SELECT now();"

# 7. Restart applications
kubectl scale deployment --all --replicas=3 -n nexus-platform
```

### MongoDB Failover

#### Automatic Failover

MongoDB uses replica sets for automatic failover:

```bash
# Check replica set status
kubectl exec -it mongodb-0 -n nexus-platform -- mongo --eval "rs.status()"

# Expected output shows PRIMARY and SECONDARY members
```

#### Manual Failover

```bash
# 1. Force election on specific node
kubectl exec -it mongodb-1 -n nexus-platform -- mongo --eval "rs.stepDown()"

# 2. Verify new primary
kubectl exec -it mongodb-0 -n nexus-platform -- mongo --eval "rs.status().members.filter(m => m.stateStr === 'PRIMARY')"

# 3. Update connection strings if using direct connections
kubectl set env deployment/backend-api -n nexus-platform \
  MONGO_URL="mongodb://mongodb-1:27017,mongodb-2:27017/nexus_cos?replicaSet=rs0"
```

#### Restore from Backup

```bash
# 1. Stop applications
kubectl scale deployment --all --replicas=0 -n nexus-platform

# 2. Download backup
aws s3 cp s3://nexus-cos-backups/mongodb/backup-2024-12-11.archive /tmp/

# 3. Restore backup
kubectl exec -it mongodb-0 -n nexus-platform -- mongorestore \
  --uri="mongodb://localhost:27017" \
  --archive=/tmp/backup-2024-12-11.archive \
  --drop

# 4. Verify restoration
kubectl exec -it mongodb-0 -n nexus-platform -- mongo nexus_cos --eval "db.stats()"

# 5. Restart applications
kubectl scale deployment --all --replicas=3 -n nexus-platform
```

### Redis Failover

#### Sentinel-based Failover

```bash
# Check Redis Sentinel status
kubectl exec -it redis-sentinel-0 -n nexus-platform -- redis-cli -p 26379 SENTINEL masters

# Force failover
kubectl exec -it redis-sentinel-0 -n nexus-platform -- redis-cli -p 26379 SENTINEL failover mymaster

# Verify new master
kubectl exec -it redis-sentinel-0 -n nexus-platform -- redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
```

#### Rebuild Redis from Snapshot

```bash
# 1. Download snapshot
aws s3 cp s3://nexus-cos-backups/redis/dump-2024-12-11.rdb /tmp/

# 2. Stop Redis
kubectl delete pod redis-0 -n nexus-platform

# 3. Copy snapshot to Redis data directory
kubectl cp /tmp/dump-2024-12-11.rdb nexus-platform/redis-0:/data/dump.rdb

# 4. Start Redis (will load from dump.rdb)
kubectl get pod redis-0 -n nexus-platform

# 5. Verify data
kubectl exec -it redis-0 -n nexus-platform -- redis-cli DBSIZE
```

## 3. Application Service Failover

### Kubernetes Auto-Recovery

Kubernetes automatically restarts failed pods:

```yaml
# Deployment with health checks and auto-restart
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
spec:
  replicas: 5
  template:
    spec:
      containers:
      - name: backend-api
        livenessProbe:
          httpGet:
            path: /health/live
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
          failureThreshold: 3
```

### Manual Service Recovery

```bash
# 1. Identify failed services
kubectl get pods --all-namespaces | grep -v Running

# 2. Check pod events
kubectl describe pod <pod-name> -n <namespace>

# 3. Check logs
kubectl logs <pod-name> -n <namespace> --previous

# 4. Restart deployment
kubectl rollout restart deployment/<service-name> -n <namespace>

# 5. Monitor recovery
kubectl rollout status deployment/<service-name> -n <namespace>

# 6. Verify service health
curl https://nexuscos.online/api/<service>/health
```

### Multi-Region Failover

If primary region fails:

```bash
# 1. Update DNS to point to secondary region
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file://failover-to-secondary.json

# failover-to-secondary.json
{
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "nexuscos.online",
      "Type": "A",
      "TTL": 60,
      "ResourceRecords": [
        {"Value": "203.0.113.10"}  # Secondary region IP
      ]
    }
  }]
}

# 2. Verify DNS propagation
dig nexuscos.online

# 3. Monitor traffic shift
# Check application logs and metrics

# 4. Communicate status
# Update status page and notify stakeholders
```

## 4. Infrastructure Failover

### Kubernetes Cluster Failure

#### Multi-Cluster Setup

```bash
# Check cluster health
kubectl get nodes
kubectl get componentstatuses

# If primary cluster is down, switch to backup cluster
kubectl config use-context backup-cluster

# Verify services in backup cluster
kubectl get pods --all-namespaces

# Update load balancer to point to backup cluster
```

### Network Failover

#### Load Balancer Failover

```bash
# Update load balancer to use backup backend
aws elbv2 modify-target-group \
  --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/backup-tg \
  --health-check-enabled \
  --health-check-interval-seconds 10

# Update listener to use backup target group
aws elbv2 modify-listener \
  --listener-arn arn:aws:elasticloadbalancing:region:account:listener/app/lb/id \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:region:account:targetgroup/backup-tg
```

#### CDN Failover

```bash
# Update CloudFlare origin to secondary server
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{record_id}" \
  -H "Authorization: Bearer ${CF_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"content":"203.0.113.10"}'

# Or use CloudFlare Load Balancer for automatic failover
```

## 5. Data Center Failover

### Complete Data Center Failure

#### Activation Checklist

- [ ] Confirm primary data center is unreachable
- [ ] Notify incident commander and stakeholders
- [ ] Activate disaster recovery team
- [ ] Begin failover to secondary data center
- [ ] Update DNS records
- [ ] Restore services from backups
- [ ] Verify application functionality
- [ ] Update monitoring and alerting
- [ ] Communicate with customers
- [ ] Document incident timeline

#### Failover Procedure

```bash
#!/bin/bash
# dr-failover.sh - Complete data center failover

echo "========================================="
echo "DISASTER RECOVERY FAILOVER"
echo "========================================="

# 1. Switch kubectl context to DR site
kubectl config use-context dr-cluster

# 2. Verify cluster is ready
kubectl get nodes

# 3. Deploy infrastructure components
kubectl apply -f dr-manifests/namespaces.yaml
kubectl apply -f dr-manifests/configmaps/
kubectl apply -f dr-manifests/secrets/

# 4. Restore databases from backups
./scripts/restore-databases.sh --from-s3 --date latest

# 5. Deploy applications
kubectl apply -f dr-manifests/deployments/
kubectl apply -f dr-manifests/services/

# 6. Wait for services to be ready
kubectl wait --for=condition=ready pod -l app=backend-api -n nexus-platform --timeout=300s

# 7. Update DNS to DR site
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file://dr-dns-update.json

# 8. Verify health
./scripts/health-check.sh

echo "Failover complete. Monitor dashboards for issues."
```

### Database Restoration in DR Site

```bash
#!/bin/bash
# restore-databases.sh

# PostgreSQL
echo "Restoring PostgreSQL..."
aws s3 cp s3://nexus-cos-backups/postgresql/latest.sql.gz /tmp/
gunzip /tmp/latest.sql.gz
kubectl exec -i postgresql-0 -n nexus-platform -- psql -U nexus < /tmp/latest.sql

# MongoDB
echo "Restoring MongoDB..."
aws s3 cp s3://nexus-cos-backups/mongodb/latest.archive /tmp/
kubectl exec -i mongodb-0 -n nexus-platform -- mongorestore --archive=/tmp/latest.archive

# Redis
echo "Restoring Redis..."
aws s3 cp s3://nexus-cos-backups/redis/latest.rdb /tmp/dump.rdb
kubectl cp /tmp/dump.rdb nexus-platform/redis-0:/data/dump.rdb
kubectl delete pod redis-0 -n nexus-platform

echo "Database restoration complete"
```

## 6. Failback Procedures

### Returning to Primary Site

After primary site is restored:

```bash
#!/bin/bash
# failback.sh

echo "========================================="
echo "FAILBACK TO PRIMARY SITE"
echo "========================================="

# 1. Verify primary site is fully operational
./scripts/health-check.sh --site primary

# 2. Replicate recent data from DR to primary
./scripts/sync-databases.sh --from dr --to primary

# 3. Deploy latest application code to primary
kubectl config use-context primary-cluster
kubectl apply -f manifests/

# 4. Run smoke tests on primary
./scripts/smoke-tests.sh --environment primary

# 5. Gradual traffic shift (10% increments)
for percent in 10 25 50 75 100; do
  echo "Shifting ${percent}% traffic to primary..."
  ./scripts/traffic-shift.sh --primary $percent --dr $((100-percent))
  sleep 300  # Wait 5 minutes
  ./scripts/health-check.sh
done

# 6. Update DNS back to primary
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file://primary-dns-update.json

# 7. Deactivate DR site (keep warm standby)
kubectl config use-context dr-cluster
kubectl scale deployments --all --replicas=1 -n nexus-platform

echo "Failback complete. Primary site is now active."
```

## 7. Communication Templates

### Internal Communication

**Initial Alert**:
```
🚨 DISASTER RECOVERY ACTIVATED
Site: Primary Data Center
Impact: All services
Action: Failing over to DR site
ETA: 4 hours
War Room: https://zoom.us/j/xxx
Status Updates: Every 30 minutes
Commander: @oncall-lead
```

**Progress Update**:
```
📊 DR FAILOVER UPDATE
Status: In Progress
Completed:
✅ DNS updated to DR site
✅ Databases restored
✅ Applications deployed
In Progress:
🔄 Verifying service health
🔄 Running smoke tests
Remaining:
⏳ Customer communication
⏳ Full system verification
Next Update: 30 minutes
```

**Resolution**:
```
✅ DR FAILOVER COMPLETE
All services operational in DR site
Uptime: 99.98%
Downtime: ~45 minutes
Impact: Brief service interruption during failover
Post-Mortem: Scheduled for tomorrow 2PM
```

### External Communication

**Status Page Update**:
```
Investigating: We are experiencing issues with our primary data center.
Our team is working to restore service from our backup site.
Expected restoration: Within 4 hours
Updates: Every 30 minutes
```

**After Restoration**:
```
Resolved: Services have been restored and are operating normally from our backup data center.
We are monitoring closely to ensure stability.
Total downtime: Approximately 45 minutes
We apologize for any inconvenience.
```

## 8. Testing DR Plan

### Quarterly DR Drills

```bash
#!/bin/bash
# dr-drill.sh - Disaster recovery drill

echo "========================================="
echo "DR DRILL - Test failover without production impact"
echo "========================================="

# 1. Document current production state
./scripts/snapshot-production-state.sh

# 2. Deploy to DR environment
kubectl config use-context dr-cluster-test
kubectl apply -f dr-test-manifests/

# 3. Restore test data
./scripts/restore-test-data.sh

# 4. Run verification tests
./scripts/verify-dr-readiness.sh

# 5. Measure RTO/RPO
echo "Failover completed in: $(cat /tmp/failover-duration)"
echo "Data loss: $(cat /tmp/data-loss-minutes) minutes"

# 6. Generate drill report
./scripts/generate-dr-drill-report.sh

# 7. Cleanup test environment
kubectl delete namespace dr-drill-test
```

### DR Readiness Checklist

- [ ] Backups are running successfully
- [ ] DR site is provisioned and ready
- [ ] DNS failover is configured
- [ ] Runbooks are updated
- [ ] Team is trained on procedures
- [ ] Communication templates are prepared
- [ ] Monitoring is configured for DR site
- [ ] Network connectivity to DR site is verified
- [ ] Encryption keys are backed up
- [ ] Restoration procedures are tested

## 9. Post-Incident Activities

### Post-Mortem Template

**Incident Summary**:
- Date/Time: 
- Duration:
- Impact:
- Root Cause:

**Timeline**:
- HH:MM - Incident detected
- HH:MM - DR activation initiated
- HH:MM - Databases restored
- HH:MM - Services deployed
- HH:MM - Traffic shifted
- HH:MM - Incident resolved

**Root Cause Analysis**:
- What happened:
- Why it happened:
- How it was detected:

**Resolution**:
- Actions taken:
- Effectiveness:

**Lessons Learned**:
- What went well:
- What could be improved:

**Action Items**:
- [ ] Update runbooks
- [ ] Improve monitoring
- [ ] Additional training
- [ ] Infrastructure improvements

## 10. Emergency Contacts

### Escalation Path

| Level | Contact | Phone | Availability |
|-------|---------|-------|--------------|
| L1 - On-Call Engineer | Pagerduty | 24/7 Alert | 24/7 |
| L2 - DevOps Lead | +1-XXX-XXX-XXXX | 24/7 | 24/7 |
| L3 - Platform Architect | +1-XXX-XXX-XXXX | 24/7 | 24/7 |
| L4 - CTO | +1-XXX-XXX-XXXX | Emergency Only | 24/7 |

### External Contacts

- **AWS Support**: 1-866-XXX-XXXX (Premium Support)
- **CloudFlare Support**: support.cloudflare.com
- **Database Vendor**: support@vendor.com
- **Security Team**: security@nexuscos.online

---

**Document Version**: 1.0  
**Last Updated**: December 2024  
**Owner**: DevOps Team & DR Committee
