# Rollback Runbook

## Overview

This runbook provides detailed procedures for rolling back deployments and recovering from failed updates in the Nexus COS platform. Follow these procedures to minimize downtime and ensure data integrity during rollback operations.

## Rollback Strategy

### Deployment Types

| Type | Rollback Method | Estimated Time | Data Risk |
|------|----------------|----------------|-----------|
| Application Code | Kubernetes Rollback | 2-5 minutes | Low |
| Database Schema | Migration Rollback | 10-30 minutes | Medium |
| Configuration | ConfigMap Revert | 1-2 minutes | Low |
| Infrastructure | Terraform Revert | 15-60 minutes | Medium-High |

### Rollback Decision Matrix

| Scenario | Action | Priority |
|----------|--------|----------|
| Failed health checks after deployment | Automatic rollback | P0 |
| Error rate > 5% | Immediate rollback | P0 |
| Performance degradation > 50% | Immediate rollback | P1 |
| Minor bugs affecting < 1% users | Hotfix forward | P2 |
| Configuration errors | Revert config | P1 |

## 1. Application Rollback

### Kubernetes Deployment Rollback

#### Quick Rollback (Last Deployment)

```bash
# Rollback to previous version
kubectl rollout undo deployment/<service-name> -n <namespace>

# Example: Rollback backend-api
kubectl rollout undo deployment/backend-api -n nexus-platform

# Check rollback status
kubectl rollout status deployment/backend-api -n nexus-platform

# Verify pods are running
kubectl get pods -n nexus-platform -l app=backend-api
```

#### Rollback to Specific Revision

```bash
# List deployment history
kubectl rollout history deployment/backend-api -n nexus-platform

# View specific revision details
kubectl rollout history deployment/backend-api -n nexus-platform --revision=3

# Rollback to specific revision
kubectl rollout undo deployment/backend-api -n nexus-platform --to-revision=3

# Monitor rollback progress
kubectl rollout status deployment/backend-api -n nexus-platform
```

#### Verify Rollback Success

```bash
# Check pod status
kubectl get pods -n nexus-platform -l app=backend-api

# Check service health
curl https://nexuscos.online/api/health

# Check logs for errors
kubectl logs -n nexus-platform deployment/backend-api --tail=50

# Monitor error rate
# (Check Grafana dashboard or Prometheus)
```

### Rolling Back Multiple Services

If deployment affected multiple services:

```bash
# Create rollback script
cat > rollback-deployment.sh << 'EOF'
#!/bin/bash
SERVICES=("backend-api" "auth-service" "content-management")
NAMESPACE="nexus-platform"

for service in "${SERVICES[@]}"; do
  echo "Rolling back $service..."
  kubectl rollout undo deployment/$service -n $NAMESPACE
  kubectl rollout status deployment/$service -n $NAMESPACE
  echo "✓ $service rolled back"
done
EOF

chmod +x rollback-deployment.sh
./rollback-deployment.sh
```

### Blue-Green Deployment Rollback

If using blue-green deployments:

```bash
# Switch traffic back to blue (previous) environment
kubectl patch service backend-api -n nexus-platform -p '{"spec":{"selector":{"version":"blue"}}}'

# Verify traffic routing
kubectl get service backend-api -n nexus-platform -o yaml | grep selector

# Gradual traffic shift back (if using Istio)
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: backend-api
  namespace: nexus-platform
spec:
  hosts:
  - backend-api
  http:
  - route:
    - destination:
        host: backend-api
        subset: blue
      weight: 100
    - destination:
        host: backend-api
        subset: green
      weight: 0
EOF
```

### Canary Deployment Rollback

If using canary releases:

```bash
# Stop canary traffic immediately
kubectl patch deployment backend-api-canary -n nexus-platform -p '{"spec":{"replicas":0}}'

# Ensure all traffic goes to stable version
kubectl scale deployment/backend-api-stable -n nexus-platform --replicas=10

# Remove canary deployment
kubectl delete deployment backend-api-canary -n nexus-platform
```

## 2. Database Rollback

### PostgreSQL Migration Rollback

#### Using Migration Tool (Flyway/Liquibase)

```bash
# Connect to database
kubectl exec -it postgresql-0 -n nexus-platform -- psql -U nexus -d nexus_cos

# Check migration history
SELECT * FROM flyway_schema_history ORDER BY installed_rank DESC LIMIT 10;

# Rollback last migration (if rollback script exists)
flyway undo

# Verify database state
\dt  # List tables
```

#### Manual Rollback

```bash
# 1. Create backup before rollback
kubectl exec -it postgresql-0 -n nexus-platform -- pg_dump -U nexus nexus_cos > backup-before-rollback.sql

# 2. Run rollback SQL
kubectl exec -it postgresql-0 -n nexus-platform -- psql -U nexus -d nexus_cos << 'EOF'
BEGIN;
-- Rollback migration (example)
DROP TABLE IF EXISTS new_feature_table;
ALTER TABLE users DROP COLUMN IF EXISTS new_column;
-- Add any other rollback statements
COMMIT;
EOF

# 3. Verify rollback
kubectl exec -it postgresql-0 -n nexus-platform -- psql -U nexus -d nexus_cos -c "\d users"
```

#### Point-in-Time Recovery

If migration caused data corruption:

```bash
# 1. Stop application
kubectl scale deployment/backend-api -n nexus-platform --replicas=0

# 2. Restore from backup
aws s3 cp s3://nexus-cos-backups/postgresql/backup-2024-12-11.sql.gz .
gunzip backup-2024-12-11.sql.gz

kubectl exec -i postgresql-0 -n nexus-platform -- psql -U nexus -d postgres -c "DROP DATABASE nexus_cos;"
kubectl exec -i postgresql-0 -n nexus-platform -- psql -U nexus -d postgres -c "CREATE DATABASE nexus_cos;"
kubectl exec -i postgresql-0 -n nexus-platform -- psql -U nexus -d nexus_cos < backup-2024-12-11.sql

# 3. Restart application
kubectl scale deployment/backend-api -n nexus-platform --replicas=5

# 4. Verify data integrity
./scripts/verify-database-integrity.sh
```

### MongoDB Rollback

```bash
# 1. Stop writes to MongoDB
kubectl scale deployment/backend-api -n nexus-platform --replicas=0

# 2. Restore from backup
kubectl exec -it mongodb-0 -n nexus-platform -- mongorestore --uri="mongodb://localhost:27017" --archive=/backups/backup-2024-12-11.archive

# 3. Verify data
kubectl exec -it mongodb-0 -n nexus-platform -- mongo nexus_cos --eval "db.stats()"

# 4. Resume operations
kubectl scale deployment/backend-api -n nexus-platform --replicas=5
```

### Redis Rollback

```bash
# Clear corrupted cache
kubectl exec -it redis-0 -n nexus-platform -- redis-cli FLUSHALL

# Or restore from RDB snapshot
kubectl exec -it redis-0 -n nexus-platform -- redis-cli SHUTDOWN SAVE
kubectl cp backup.rdb nexus-platform/redis-0:/data/dump.rdb
kubectl delete pod redis-0 -n nexus-platform  # Will restart and load dump.rdb
```

## 3. Configuration Rollback

### ConfigMap Rollback

```bash
# Get ConfigMap history
kubectl get configmap app-config -n nexus-platform -o yaml > current-config.yaml

# Restore from backup
kubectl apply -f backups/app-config-2024-12-10.yaml

# Restart pods to pick up old config
kubectl rollout restart deployment/backend-api -n nexus-platform

# Verify configuration
kubectl get configmap app-config -n nexus-platform -o yaml
```

### Secrets Rollback

```bash
# Restore secret from backup
kubectl apply -f backups/secrets-2024-12-10.yaml

# Restart affected deployments
kubectl rollout restart deployment/backend-api -n nexus-platform

# Verify secret
kubectl get secret api-keys -n nexus-platform -o yaml
```

### Environment Variables Rollback

```bash
# Get previous deployment manifest
kubectl get deployment backend-api -n nexus-platform --revision=2 -o yaml > previous-deployment.yaml

# Apply previous version
kubectl apply -f previous-deployment.yaml

# Monitor rollout
kubectl rollout status deployment/backend-api -n nexus-platform
```

## 4. Infrastructure Rollback

### Terraform Rollback

```bash
# Navigate to infrastructure directory
cd infrastructure/terraform

# Check Terraform state
terraform show

# Revert to previous state
git log --oneline  # Find previous commit
git checkout <previous-commit-hash> .

# Plan the rollback
terraform plan

# Apply rollback (with approval)
terraform apply

# Tag the rollback
git tag -a "rollback-$(date +%Y%m%d-%H%M%S)" -m "Rollback infrastructure to previous state"
```

### Kubernetes Cluster Rollback

```bash
# If cluster upgrade failed
kubeadm upgrade node --rollback

# Verify cluster status
kubectl get nodes
kubectl version

# Check component health
kubectl get componentstatuses
```

## 5. DNS and Load Balancer Rollback

### DNS Rollback

```bash
# Update DNS records back to previous IPs
# (Use cloud provider CLI or Terraform)

# AWS Route 53 example
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file://rollback-dns-change.json

# Verify DNS propagation
dig nexuscos.online
nslookup nexuscos.online
```

### Load Balancer Rollback

```bash
# AWS ALB/NLB target group rollback
aws elbv2 modify-listener --listener-arn <arn> \
  --default-actions Type=forward,TargetGroupArn=<previous-target-group-arn>

# Verify load balancer configuration
aws elbv2 describe-listeners --listener-arns <arn>
```

## 6. Rollback Verification

### Post-Rollback Checklist

- [ ] All services are running with correct number of replicas
- [ ] Health check endpoints return 200 OK
- [ ] Error rate is back to normal levels (< 0.1%)
- [ ] Response times are within acceptable range
- [ ] Database connections are stable
- [ ] No critical errors in logs
- [ ] User-facing features are working
- [ ] Monitoring dashboards show normal metrics
- [ ] Security scans pass
- [ ] Smoke tests pass

### Automated Verification Script

```bash
#!/bin/bash
# rollback-verification.sh

echo "Starting rollback verification..."

# Check service health
for namespace in nexus-platform nexus-auth nexus-content; do
  echo "Checking $namespace..."
  kubectl get pods -n $namespace | grep -v Running && echo "✗ Unhealthy pods in $namespace" || echo "✓ $namespace healthy"
done

# Check health endpoints
curl -f https://nexuscos.online/api/health || echo "✗ Health check failed"
curl -f https://nexuscos.online/streaming/health || echo "✗ Streaming health check failed"

# Check error rate
ERROR_RATE=$(curl -s 'http://prometheus:9090/api/v1/query?query=rate(http_requests_total{status=~"5.."}[5m])' | jq -r '.data.result[0].value[1]')
if (( $(echo "$ERROR_RATE > 0.01" | bc -l) )); then
  echo "✗ Error rate too high: $ERROR_RATE"
else
  echo "✓ Error rate normal: $ERROR_RATE"
fi

echo "Rollback verification complete"
```

### Smoke Tests

```bash
# Run automated smoke tests
npm run test:smoke

# Or manual smoke tests
./scripts/manual-smoke-tests.sh
```

## 7. Communication During Rollback

### Internal Communication

**Slack Template**:
```
🔴 ROLLBACK IN PROGRESS
Service: <service-name>
Reason: <brief reason>
ETA: <estimated time>
Impact: <user impact>
Status updates: Every 15 minutes
Contact: @oncall-engineer
```

### External Communication

**Status Page Update**:
```
Investigating: We are currently investigating an issue with <feature>.
Users may experience <impact>.
We are working on a resolution and will provide updates every 30 minutes.
```

**After Rollback**:
```
Resolved: The issue has been resolved. Services are now operating normally.
Root cause: <brief explanation>
Preventive measures: <what we're doing to prevent this>
```

## 8. Post-Rollback Activities

### Incident Report

Create incident report with:
- Timeline of events
- Root cause analysis
- Impact assessment
- Rollback steps taken
- Lessons learned
- Action items to prevent recurrence

### Post-Mortem Meeting

Schedule within 24 hours with:
- On-call engineer
- Development team
- DevOps team
- Product manager

### Action Items

- [ ] Document root cause
- [ ] Create ticket to fix underlying issue
- [ ] Update runbooks if needed
- [ ] Improve monitoring/alerting
- [ ] Update deployment procedures
- [ ] Schedule training if needed

## 9. Rollback Prevention

### Pre-Deployment Checks

```bash
# Run pre-deployment checks
./scripts/pre-deployment-checks.sh

# Includes:
# - Linting
# - Unit tests
# - Integration tests
# - Security scans
# - Performance tests
# - Database migration validation
```

### Gradual Rollout

- Deploy to staging first
- Run smoke tests in staging
- Deploy to production with canary (10% traffic)
- Monitor for 30 minutes
- Gradually increase traffic (25%, 50%, 100%)
- Full rollout only after 2 hours of stability

### Automated Rollback Triggers

Configure automatic rollback if:
- Error rate > 5% for 2 minutes
- Response time p99 > 2s for 5 minutes
- Health check failures > 50% for 1 minute
- Memory usage > 95% for 3 minutes

## 10. Emergency Contacts

| Role | Contact | Availability |
|------|---------|--------------|
| On-Call Engineer | Pagerduty | 24/7 |
| DevOps Lead | +1-XXX-XXX-XXXX | 24/7 |
| Platform Architect | +1-XXX-XXX-XXXX | Business hours |
| Database Admin | +1-XXX-XXX-XXXX | On-call rotation |
| Security Team | security@nexuscos.online | 24/7 |

## Appendix: Common Rollback Scenarios

### Scenario 1: Failed API Deployment

```bash
# 1. Immediate rollback
kubectl rollout undo deployment/backend-api -n nexus-platform

# 2. Verify
kubectl get pods -n nexus-platform -l app=backend-api
curl https://nexuscos.online/api/health

# 3. Investigate
kubectl logs -n nexus-platform deployment/backend-api --previous
```

### Scenario 2: Database Migration Failure

```bash
# 1. Stop application
kubectl scale deployment/backend-api -n nexus-platform --replicas=0

# 2. Rollback migration
kubectl exec -it postgresql-0 -n nexus-platform -- psql -U nexus -d nexus_cos -f /rollback-scripts/rollback-migration-001.sql

# 3. Restart application with previous version
kubectl set image deployment/backend-api backend-api=nexus-cos/backend-api:1.2.3 -n nexus-platform
kubectl scale deployment/backend-api -n nexus-platform --replicas=5
```

### Scenario 3: Configuration Error

```bash
# 1. Revert ConfigMap
kubectl apply -f backups/app-config-working.yaml

# 2. Restart affected pods
kubectl rollout restart deployment/backend-api -n nexus-platform

# 3. Verify
kubectl get configmap app-config -n nexus-platform -o yaml
```

---

**Document Version**: 1.0  
**Last Updated**: December 2024  
**Owner**: DevOps Team
