# Rollback Strategy

## Overview

Procedures for rolling back deployments and recovering from failed updates.

## Rollback Decision Tree

### When to Rollback

Rollback immediately if:
- Service is completely down
- Data corruption detected
- Critical security vulnerability introduced
- Error rate > 10%
- P95 latency > 5x baseline

Consider rollback if:
- Error rate > 5%
- P95 latency > 2x baseline
- User complaints increasing
- Functionality broken

## Kubernetes Rollback Procedures

### Automatic Rollback

Kubernetes will automatically rollback if:
- Readiness probes fail for >30s
- Pod crashes repeatedly
- Resource limits exceeded

### Manual Rollback

#### Quick Rollback (Kubernetes)
```bash
# Rollback to previous version
kubectl rollout undo deployment/<service-name> -n <namespace>

# Rollback to specific revision
kubectl rollout undo deployment/<service-name> --to-revision=<number> -n <namespace>

# Check rollout history
kubectl rollout history deployment/<service-name> -n <namespace>
```

#### Full Stack Rollback
```bash
# 1. Stop new deployments
kubectl scale deployment/<service-name> --replicas=0 -n <namespace>

# 2. Restore previous version
kubectl rollout undo deployment/<service-name> -n <namespace>

# 3. Verify rollback
kubectl rollout status deployment/<service-name> -n <namespace>

# 4. Run diagnostics
./scripts/diagnostics.sh
```

## Database Rollback

### Schema Rollback
```bash
# 1. Stop application services
kubectl scale deployment/<service-name> --replicas=0 -n <namespace>

# 2. Restore database backup
kubectl exec -i -n database postgresql-0 -- \
  psql -U postgres nexus_db < backup_pre_migration.sql

# 3. Verify data integrity
./scripts/verify-db-integrity.sh

# 4. Restart services
kubectl scale deployment/<service-name> --replicas=3 -n <namespace>
```

### Data Rollback
```bash
# Restore from point-in-time backup
kubectl exec -n database postgresql-0 -- \
  psql -U postgres -c "SELECT pg_restore_point('pre_deployment');"
```

## Configuration Rollback

### ConfigMaps
```bash
# Backup current config
kubectl get configmap <config-name> -n <namespace> -o yaml > config_backup.yaml

# Restore previous config
kubectl apply -f config_previous.yaml

# Restart pods to pick up config
kubectl rollout restart deployment/<service-name> -n <namespace>
```

### Secrets
```bash
# Restore previous secrets
kubectl apply -f secrets_previous.yaml

# Restart affected services
kubectl rollout restart deployment/<service-name> -n <namespace>
```

## Testing After Rollback

```bash
# 1. Verify service health
kubectl get pods -n <namespace>
kubectl logs -n <namespace> deployment/<service-name>

# 2. Run smoke tests
./scripts/smoke-tests.sh

# 3. Check metrics
# Access Grafana dashboards

# 4. Verify user functionality
# Test critical user flows
```

## Communication During Rollback

1. Notify stakeholders immediately
2. Post status update every 15 minutes
3. Document incident timeline
4. Conduct post-mortem after resolution

## Prevention

- Thorough testing in staging
- Gradual rollouts (canary/blue-green)
- Automated testing
- Feature flags
- Monitoring and alerts
