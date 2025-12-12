# Failover and Disaster Recovery Runbook

## Overview

This runbook provides procedures for handling infrastructure failures, disaster recovery, and ensuring high availability of the Nexus COS platform.

## High Availability Architecture

### Multi-Region Setup

```
Primary Region (US-East)          Secondary Region (US-West)
├── Kubernetes Cluster            ├── Kubernetes Cluster
├── PostgreSQL Primary            ├── PostgreSQL Replica
├── Redis Primary                 ├── Redis Replica
├── Object Storage (S3)           ├── Object Storage (Replicated)
└── CDN Edge                      └── CDN Edge
```

### Replication Strategy

- **Database**: Streaming replication with 30s lag tolerance
- **Object Storage**: Cross-region replication
- **Cache**: Redis Sentinel for automatic failover
- **DNS**: Route53 with health checks and failover routing

## Failover Scenarios

### 1. Single Service Failure

**Detection**: Health check fails for 2 consecutive checks (20s)

**Automatic Response**:
```bash
# Kubernetes automatically restarts failed pods
# No manual intervention needed for single pod failures

# Monitor recovery
kubectl get pods -n nexus-cos -w
kubectl describe pod <pod-name> -n nexus-cos
```

**Manual Intervention** (if auto-restart fails):
```bash
# Force pod recreation
kubectl delete pod <pod-name> -n nexus-cos

# Scale deployment
kubectl scale deployment/<service-name> --replicas=5 -n nexus-cos

# Check logs
kubectl logs <pod-name> -n nexus-cos --previous
```

### 2. Database Primary Failure

**Detection**: Database connection failures, replication lag spike

**Automatic Failover** (with PostgreSQL HA):
```bash
# Patroni/Stolon automatically promotes replica
# Connection strings via service discovery automatically update

# Verify failover
kubectl exec -it postgres-0 -n nexus-cos -- patroni list

# Check replication status
kubectl exec -it postgres-1 -n nexus-cos -- psql -c "SELECT * FROM pg_stat_replication;"
```

**Manual Failover**:
```bash
# If automatic failover doesn't trigger

# 1. Promote replica to primary
kubectl exec -it postgres-replica-0 -n nexus-cos -- \
  pg_ctl promote -D /var/lib/postgresql/data

# 2. Update application config to point to new primary
kubectl edit configmap postgres-config -n nexus-cos

# 3. Restart services to pick up new config
kubectl rollout restart deployment -n nexus-cos

# 4. Verify connectivity
psql -h new-primary-host -U nexus -d nexusdb -c "SELECT 1;"
```

### 3. Redis Cache Failure

**Detection**: Redis connection errors, cache miss rate = 100%

**Automatic Failover** (Redis Sentinel):
```bash
# Sentinel automatically promotes replica

# Verify failover
redis-cli -h sentinel-host -p 26379 SENTINEL masters
redis-cli -h sentinel-host -p 26379 SENTINEL get-master-addr-by-name mymaster
```

**Manual Failover**:
```bash
# Force failover
redis-cli -h sentinel-host -p 26379 SENTINEL failover mymaster

# Or manual promotion
kubectl exec -it redis-replica-0 -n nexus-cos -- redis-cli SLAVEOF NO ONE

# Update application config
kubectl edit configmap redis-config -n nexus-cos
kubectl rollout restart deployment -n nexus-cos
```

**Graceful Degradation** (No Redis):
```javascript
// Application should degrade gracefully without cache
try {
  const cached = await redis.get(key);
  if (cached) return cached;
} catch (error) {
  console.error('Redis unavailable, bypassing cache');
}
// Continue without cache
const data = await database.query(...);
```

### 4. Entire Cluster Failure

**Detection**: Multiple node failures, cluster unreachable

**Regional Failover Procedure**:

```bash
# 1. Verify secondary region is healthy
kubectl --context=us-west get nodes
kubectl --context=us-west get pods -n nexus-cos

# 2. Update DNS to point to secondary region
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file://failover-dns.json

# failover-dns.json
{
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "api.nexuscos.example.com",
      "Type": "A",
      "AliasTarget": {
        "HostedZoneId": "Z0987654321XYZ",
        "DNSName": "lb-us-west.amazonaws.com",
        "EvaluateTargetHealth": true
      }
    }
  }]
}

# 3. Promote secondary database to primary
kubectl --context=us-west exec -it postgres-0 -n nexus-cos -- \
  pg_ctl promote -D /var/lib/postgresql/data

# 4. Scale up secondary region
kubectl --context=us-west scale deployment --all --replicas=5 -n nexus-cos

# 5. Verify services
./scripts/verify-platform-health.sh --region=us-west

# 6. Monitor closely
watch -n 5 'kubectl --context=us-west get pods -n nexus-cos'
```

### 5. Network Partition

**Detection**: Services can't communicate, split-brain scenario

**Mitigation**:
```bash
# 1. Identify which partition has quorum
kubectl get nodes -o wide

# 2. If primary has quorum, continue normal operations
# 3. If secondary has quorum, initiate failover as above

# 4. Prevent split-brain with quorum requirements
# Database: Ensure synchronous_standby_names is set
# Kubernetes: Ensure etcd has odd number of nodes (3, 5)

# 5. After network heals, resync data
pg_rewind --target-pgdata=/var/lib/postgresql/data \
  --source-server="host=primary port=5432 user=replicator"
```

## Disaster Recovery

### Backup Strategy

#### Database Backups

```bash
# Automated daily backup (cron)
0 2 * * * /scripts/backup-postgres.sh

# backup-postgres.sh
#!/bin/bash
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/backups/postgres"
mkdir -p $BACKUP_DIR

pg_dump -h localhost -U nexus -Fc nexusdb \
  > $BACKUP_DIR/nexusdb-$DATE.dump

# Upload to S3
aws s3 cp $BACKUP_DIR/nexusdb-$DATE.dump \
  s3://nexus-cos-backups/postgres/$DATE/ \
  --storage-class STANDARD_IA

# Cleanup old local backups (keep 7 days)
find $BACKUP_DIR -name "*.dump" -mtime +7 -delete
```

#### Application State Backup

```bash
# Backup Redis data
redis-cli --rdb /backups/redis/dump-$(date +%Y%m%d).rdb
aws s3 cp /backups/redis/dump-*.rdb s3://nexus-cos-backups/redis/

# Backup Kubernetes state
kubectl get all -n nexus-cos -o yaml > k8s-state-$(date +%Y%m%d).yaml
aws s3 cp k8s-state-*.yaml s3://nexus-cos-backups/k8s/

# Backup configurations
kubectl get configmaps -n nexus-cos -o yaml > configs-$(date +%Y%m%d).yaml
kubectl get secrets -n nexus-cos -o yaml > secrets-$(date +%Y%m%d).yaml.enc
```

### Recovery Procedures

#### Full System Recovery

**RTO**: 4 hours  
**RPO**: 1 hour (hourly backups)

```bash
# 1. Provision infrastructure
terraform apply -var-file=disaster-recovery.tfvars

# 2. Deploy Kubernetes cluster
./scripts/deploy-kubernetes-cluster.sh --region=us-west

# 3. Restore database
aws s3 cp s3://nexus-cos-backups/postgres/latest/nexusdb.dump ./
createdb -h db-host -U nexus nexusdb
pg_restore -h db-host -U nexus -d nexusdb nexusdb.dump

# 4. Restore Redis
aws s3 cp s3://nexus-cos-backups/redis/latest/dump.rdb ./
redis-cli --rdb dump.rdb RESTORE

# 5. Deploy applications
kubectl apply -f k8s-state.yaml
kubectl apply -f configs.yaml

# 6. Verify and test
./scripts/verify-platform-health.sh
./scripts/run-smoke-tests.sh

# 7. Update DNS
aws route53 change-resource-record-sets --hosted-zone-id <id> --change-batch file://dns-update.json

# 8. Monitor closely for 24 hours
```

#### Data Recovery

**Recover deleted data**:
```bash
# Find backup containing the data
aws s3 ls s3://nexus-cos-backups/postgres/ --recursive

# Download specific backup
aws s3 cp s3://nexus-cos-backups/postgres/20251211/nexusdb.dump ./

# Restore to temporary database
createdb nexusdb_temp
pg_restore -d nexusdb_temp nexusdb.dump

# Extract specific data
psql -d nexusdb_temp -c "COPY users TO '/tmp/recovered_users.csv' CSV HEADER WHERE id IN (1,2,3);"

# Import to production
psql -d nexusdb -c "COPY users FROM '/tmp/recovered_users.csv' CSV HEADER;"
```

## Health Checks and Monitoring

### Automated Health Checks

```yaml
# health-check-deployment.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: health-check
spec:
  schedule: "*/5 * * * *"  # Every 5 minutes
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: health-check
            image: nexus-cos/health-checker:latest
            command:
            - /bin/sh
            - -c
            - |
              # Check all critical services
              for service in auth-service backend-api streaming-service-v2; do
                curl -f http://$service/health || exit 1
              done
              
              # Check database
              psql -h db-host -U nexus -d nexusdb -c "SELECT 1" || exit 1
              
              # Check Redis
              redis-cli ping || exit 1
              
              echo "All health checks passed"
          restartPolicy: OnFailure
```

### Monitoring Failover Status

```bash
# Monitor replication lag
watch -n 5 'psql -h replica -U nexus -c "SELECT now() - pg_last_xact_replay_timestamp() AS lag;"'

# Monitor Redis replication
watch -n 5 'redis-cli info replication'

# Monitor Kubernetes pod status
watch -n 5 'kubectl get pods -n nexus-cos'
```

## Failover Testing

### Monthly Failover Drill

```bash
# 1. Schedule maintenance window
# 2. Notify team

# 3. Test database failover
./scripts/test-db-failover.sh

# 4. Test Redis failover
./scripts/test-redis-failover.sh

# 5. Test regional failover
./scripts/test-regional-failover.sh

# 6. Document results
# 7. Update runbooks based on learnings
```

## Communication Plan

### Stakeholder Notification

**P1 Incident (System Down)**:
1. Immediate Slack alert (#nexus-cos-critical)
2. PagerDuty escalation
3. Email to executives within 15 minutes
4. Status page update
5. Customer notification if > 30 minutes

**P2 Incident (Degraded Service)**:
1. Slack alert (#nexus-cos-ops)
2. On-call notification
3. Status page update
4. Email update within 1 hour

## Post-Incident Review

### Required for P1/P2 Incidents

```markdown
# Post-Incident Review Template

## Incident Summary
- Date: 
- Duration:
- Impact:
- Services Affected:

## Timeline
- HH:MM - Event occurred
- HH:MM - Detected
- HH:MM - Response started
- HH:MM - Resolved

## Root Cause

## Contributing Factors

## What Went Well

## What Could Be Improved

## Action Items
- [ ] Item 1
- [ ] Item 2

## Prevention Measures
```

## Emergency Contacts

- **Platform Lead**: owner+platform@nexuscos.example.com (On-call 24/7)
- **Database Admin**: owner+dba@nexuscos.example.com
- **Infrastructure**: owner+infra@nexuscos.example.com
- **Security**: owner+security@nexuscos.example.com
- **Executive Escalation**: owner+exec@nexuscos.example.com

---

**Document Version**: 1.0  
**Last Updated**: December 2025  
**Drill Frequency**: Monthly  
**Review Frequency**: Quarterly
