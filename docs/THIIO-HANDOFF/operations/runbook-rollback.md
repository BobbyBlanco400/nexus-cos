# Rollback Procedures

## Overview

This runbook provides step-by-step procedures for rolling back deployments when issues are detected in production.

## When to Rollback

Rollback should be initiated when:
- Critical bugs are discovered in production
- Performance degradation > 50% from baseline
- Error rate > 5%
- Data integrity issues detected
- Security vulnerabilities introduced
- Critical features broken

## Rollback Decision Matrix

| Severity | Impact | Response Time | Rollback Decision |
|----------|--------|---------------|-------------------|
| P1 | System Down | Immediate | Automatic rollback |
| P2 | Major Feature Broken | < 15 min | Manual rollback |
| P3 | Performance Degraded | < 1 hour | Evaluate & decide |
| P4 | Minor Bug | Next day | Fix forward |

## Pre-Rollback Checklist

- [ ] Confirm the issue is deployment-related
- [ ] Identify the deployment version to rollback to
- [ ] Notify team in #nexus-cos-ops Slack channel
- [ ] Update status page: "Investigating issues"
- [ ] Create incident ticket
- [ ] Take snapshot of current state for analysis
- [ ] Verify rollback target is stable

## Kubernetes Rollback Procedures

### Quick Rollback (Single Service)

```bash
# Check deployment history
kubectl rollout history deployment/<service-name> -n nexus-cos

# View specific revision
kubectl rollout history deployment/<service-name> --revision=<N> -n nexus-cos

# Rollback to previous version
kubectl rollout undo deployment/<service-name> -n nexus-cos

# Rollback to specific revision
kubectl rollout undo deployment/<service-name> --to-revision=<N> -n nexus-cos

# Monitor rollback progress
kubectl rollout status deployment/<service-name> -n nexus-cos

# Verify service health
kubectl get pods -n nexus-cos -l app=<service-name>
kubectl logs -n nexus-cos -l app=<service-name> --tail=50
```

### Full Platform Rollback

```bash
# Rollback all core services
for service in auth-service backend-api streaming-service-v2 content-management billing-service; do
  echo "Rolling back $service..."
  kubectl rollout undo deployment/$service -n nexus-cos
  kubectl rollout status deployment/$service -n nexus-cos
done

# Verify all pods are healthy
kubectl get pods -n nexus-cos
```

### Rollback with GitOps

```bash
# If using GitOps (ArgoCD/Flux)
# Revert to previous commit in deployment repo
cd /path/to/deployment-repo
git log --oneline -10
git revert <bad-commit-sha>
git push origin main

# ArgoCD will auto-sync, or manually sync:
argocd app sync nexus-cos
argocd app wait nexus-cos
```

## Docker Compose Rollback

```bash
# Stop current version
docker-compose down

# Checkout previous version
git log --oneline -10
git checkout <previous-commit>

# Deploy previous version
docker-compose pull
docker-compose up -d

# Verify services
docker-compose ps
docker-compose logs -f --tail=50
```

## Database Rollback

### Schema Rollback

```bash
# Using migration tool (e.g., Flyway, Liquibase)
npm run migrate:rollback
# or
flyway undo

# Manual rollback
psql -h localhost -U nexus -d nexusdb < rollback-scripts/rollback-v2.0.1-to-v2.0.0.sql

# Verify schema version
psql -h localhost -U nexus -d nexusdb -c "SELECT version FROM schema_version ORDER BY installed_on DESC LIMIT 1;"
```

### Data Rollback

```bash
# Restore from backup (DESTRUCTIVE - use with extreme caution)
# 1. Stop all services
kubectl scale deployment --all --replicas=0 -n nexus-cos

# 2. Create safety backup
pg_dump -h localhost -U nexus nexusdb > safety-backup-$(date +%Y%m%d-%H%M%S).sql

# 3. Drop and recreate database
psql -h localhost -U nexus -c "DROP DATABASE nexusdb;"
psql -h localhost -U nexus -c "CREATE DATABASE nexusdb;"

# 4. Restore from known-good backup
pg_restore -h localhost -U nexus -d nexusdb /backups/nexus-cos/2025-12-11/postgres.dump

# 5. Restart services
kubectl scale deployment --all --replicas=2 -n nexus-cos
```

## Configuration Rollback

### Environment Variables

```bash
# Kubernetes ConfigMap rollback
kubectl get configmap <config-name> -n nexus-cos -o yaml > current-config.yaml

# Apply previous config
kubectl apply -f configs/previous-config.yaml

# Restart affected pods
kubectl rollout restart deployment/<service-name> -n nexus-cos
```

### Feature Flags

```bash
# Disable new feature via feature flag
curl -X POST https://api.nexuscos.example.com/admin/feature-flags \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"feature": "new-payment-flow", "enabled": false}'

# Or via Redis directly
redis-cli SET feature:new-payment-flow false
```

## Frontend Rollback

### CDN Cache Purge

```bash
# Purge CDN cache
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'

# Or purge specific files
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"files":["https://nexuscos.example.com/assets/app.js", "https://nexuscos.example.com/assets/app.css"]}'
```

### Static Asset Rollback

```bash
# Redeploy previous frontend build
cd frontend
git checkout <previous-commit>
npm run build
aws s3 sync dist/ s3://nexus-cos-frontend/ --delete
```

## Post-Rollback Verification

### Service Health Checks

```bash
# Check all service health endpoints
./scripts/verify-platform-health.sh

# Manual health check
for service in auth-service backend-api streaming-service-v2; do
  echo "Checking $service..."
  curl -f http://$service.nexuscos.example.com/health || echo "FAILED"
done
```

### Smoke Tests

```bash
# Run automated smoke tests
npm run test:smoke

# Manual smoke tests
# 1. User can login
curl -X POST https://api.nexuscos.example.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# 2. API is responsive
curl https://api.nexuscos.example.com/api/v1/health

# 3. Can fetch user data
curl https://api.nexuscos.example.com/api/v1/users/me \
  -H "Authorization: Bearer $TEST_TOKEN"
```

### Metrics Verification

- Check Grafana dashboards for normal metrics
- Verify error rate < 1%
- Confirm response times back to normal
- Check database connection pool
- Verify no memory leaks

## Communication Protocol

### During Rollback

1. **Announce rollback start** in #nexus-cos-ops
2. **Update status page**: "Rolling back recent deployment"
3. **Post progress updates** every 5 minutes
4. **Notify stakeholders** if customer-facing impact

### After Rollback

1. **Announce rollback completion** in #nexus-cos-ops
2. **Update status page**: "Systems operational"
3. **Send incident summary** to stakeholders
4. **Document root cause** in incident ticket
5. **Schedule post-mortem** for P1/P2 incidents

## Root Cause Analysis

After successful rollback:

```markdown
# Incident Post-Mortem Template

## Incident Summary
- Date/Time:
- Duration:
- Services Affected:
- User Impact:

## Timeline
- XX:XX - Deployment started
- XX:XX - Issue detected
- XX:XX - Rollback decision made
- XX:XX - Rollback initiated
- XX:XX - Services restored

## Root Cause
[Detailed explanation]

## Contributing Factors
1.
2.

## Resolution
[What was done to resolve]

## Action Items
- [ ] Fix underlying issue
- [ ] Add monitoring for early detection
- [ ] Update deployment checklist
- [ ] Improve testing coverage
- [ ] Update documentation

## Lessons Learned
1.
2.
```

## Rollback Prevention

To minimize future rollbacks:

### Pre-Deployment
- [ ] Comprehensive test coverage
- [ ] Staging environment testing
- [ ] Performance testing
- [ ] Load testing
- [ ] Security scanning
- [ ] Code review completed
- [ ] Deployment checklist followed

### During Deployment
- [ ] Blue-green deployment
- [ ] Canary releases
- [ ] Progressive rollout
- [ ] Feature flags for new features
- [ ] Automated health checks
- [ ] Real-time monitoring

### Post-Deployment
- [ ] Smoke tests passed
- [ ] Metrics normal
- [ ] Error logs reviewed
- [ ] Performance baseline met
- [ ] User feedback monitored

## Emergency Contacts

- **Platform Lead**: owner+platform@nexuscos.example.com
- **DevOps On-Call**: owner+oncall-devops@nexuscos.example.com
- **Database Admin**: owner+dba@nexuscos.example.com
- **Security Team**: owner+security@nexuscos.example.com

## Automated Rollback

### Health Check-Based Auto Rollback

```yaml
# Kubernetes deployment with auto-rollback
spec:
  progressDeadlineSeconds: 600
  minReadySeconds: 30
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    spec:
      containers:
      - name: app
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 5
          failureThreshold: 3
```

### GitOps Auto-Rollback

```yaml
# ArgoCD auto-rollback on sync failure
apiVersion: argoproj.io/v1alpha1
kind: Application
spec:
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
```

---

**Document Version**: 1.0  
**Last Updated**: December 2025  
**Critical Procedure**: Review quarterly
