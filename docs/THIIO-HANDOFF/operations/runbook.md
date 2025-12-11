# Nexus COS Operations Runbook

## Overview

This runbook provides operational procedures for the Nexus COS platform consisting of 43 services and 16 modules.

## Table of Contents

1. [Service Management](#service-management)
2. [Deployment Procedures](#deployment-procedures)
3. [Monitoring & Alerts](#monitoring--alerts)
4. [Incident Response](#incident-response)
5. [Routine Maintenance](#routine-maintenance)
6. [Scaling Operations](#scaling-operations)
7. [Backup & Recovery](#backup--recovery)
8. [Security Operations](#security-operations)

## Service Management

### Starting Services

#### Individual Service
```bash
kubectl scale deployment/<service-name> --replicas=3 -n <namespace>
```

#### All Services
```bash
./scripts/deploy-k8s.sh start-all
```

### Stopping Services

#### Individual Service
```bash
kubectl scale deployment/<service-name> --replicas=0 -n <namespace>
```

#### Graceful Shutdown
```bash
kubectl delete deployment/<service-name> -n <namespace> --grace-period=60
```

### Restarting Services

```bash
kubectl rollout restart deployment/<service-name> -n <namespace>
```

### Checking Service Status

```bash
# Service status
kubectl get deployments -n <namespace>

# Pod status
kubectl get pods -n <namespace>

# Detailed service info
kubectl describe deployment/<service-name> -n <namespace>
```

## Deployment Procedures

### Pre-Deployment Checklist

- [ ] Review change request
- [ ] Verify staging deployment
- [ ] Check resource availability
- [ ] Notify stakeholders
- [ ] Prepare rollback plan
- [ ] Schedule maintenance window

### Standard Deployment

```bash
# 1. Pull latest changes
git pull origin main

# 2. Build containers
./scripts/build-all.sh

# 3. Run pre-deployment checks
./scripts/verify-env.sh

# 4. Deploy to Kubernetes
./scripts/deploy-k8s.sh

# 5. Verify deployment
kubectl rollout status deployment/<service-name> -n <namespace>

# 6. Run smoke tests
./scripts/diagnostics.sh
```

### Rolling Update

```bash
# Update image
kubectl set image deployment/<service-name> \
  <container-name>=<new-image>:<tag> \
  -n <namespace>

# Monitor rollout
kubectl rollout status deployment/<service-name> -n <namespace>
```

### Blue-Green Deployment

```bash
# Deploy green version
kubectl apply -f k8s/deployment-green.yaml

# Verify green
./scripts/diagnostics.sh --env=green

# Switch traffic
kubectl patch service <service-name> -p '{"spec":{"selector":{"version":"green"}}}'

# Monitor for issues
sleep 300

# Decommission blue if successful
kubectl delete -f k8s/deployment-blue.yaml
```

## Monitoring & Alerts

### Key Metrics

#### System Metrics
- CPU utilization
- Memory usage
- Disk I/O
- Network throughput

#### Application Metrics
- Request rate
- Error rate
- Response time (p50, p95, p99)
- Active connections

#### Business Metrics
- Transactions per second
- User sessions
- Revenue metrics
- Content uploads/downloads

### Accessing Monitoring

```bash
# Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000

# Access at http://localhost:3000
```

### Alert Response

#### High Error Rate
1. Check service logs: `kubectl logs -n <namespace> deployment/<service-name>`
2. Check dependencies (database, Redis, etc.)
3. Review recent deployments
4. Scale up if needed
5. Escalate if unresolved in 15 minutes

#### High Latency
1. Check resource utilization
2. Review database query performance
3. Check external API response times
4. Scale horizontally if needed
5. Enable caching if not already enabled

#### Service Down
1. Check pod status: `kubectl get pods -n <namespace>`
2. Review pod logs: `kubectl logs <pod-name> -n <namespace>`
3. Check resource limits
4. Restart pod if needed
5. Review health check configuration

## Incident Response

### Severity Levels

**P0 - Critical**
- Complete service outage
- Data loss
- Security breach
- Response time: Immediate

**P1 - High**
- Major feature down
- Significant performance degradation
- Response time: 15 minutes

**P2 - Medium**
- Minor feature down
- Moderate performance issues
- Response time: 2 hours

**P3 - Low**
- Cosmetic issues
- Minor bugs
- Response time: Next business day

### Incident Procedure

1. **Detection**
   - Alert triggered or reported
   - Log incident in tracking system
   - Assign severity level

2. **Assessment**
   - Determine scope and impact
   - Identify affected services
   - Estimate user impact

3. **Response**
   - Assemble response team
   - Initiate communication plan
   - Begin troubleshooting

4. **Resolution**
   - Implement fix or workaround
   - Verify resolution
   - Monitor for recurrence

5. **Post-Mortem**
   - Document timeline
   - Root cause analysis
   - Action items for prevention

### Emergency Contacts

- Platform Lead: [Contact Info]
- DevOps Team: [Contact Info]
- Database Admin: [Contact Info]
- Security Team: [Contact Info]
- Management: [Contact Info]

## Routine Maintenance

### Daily Tasks

```bash
# Check system health
./scripts/diagnostics.sh

# Review error logs
kubectl logs -n <namespace> -l app=<service> --tail=100 | grep ERROR

# Verify backups
./scripts/verify-backups.sh

# Review metrics
# Access Grafana dashboards
```

### Weekly Tasks

- Review and analyze metrics trends
- Update documentation
- Security patch assessment
- Capacity planning review
- Performance optimization review

### Monthly Tasks

- Review and test disaster recovery
- Update runbooks
- Security audit
- Dependency updates
- Cost optimization review

## Scaling Operations

### Manual Scaling

#### Horizontal Scaling
```bash
# Scale up
kubectl scale deployment/<service-name> --replicas=5 -n <namespace>

# Scale down
kubectl scale deployment/<service-name> --replicas=2 -n <namespace>
```

#### Vertical Scaling
```bash
# Update resource limits
kubectl set resources deployment/<service-name> \
  --limits=cpu=2000m,memory=4Gi \
  --requests=cpu=1000m,memory=2Gi \
  -n <namespace>
```

### Auto-Scaling

#### Configure HPA
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: <service-name>-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: <service-name>
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

#### Monitor Autoscaling
```bash
kubectl get hpa -n <namespace>
kubectl describe hpa <service-name>-hpa -n <namespace>
```

## Backup & Recovery

### Database Backups

```bash
# Manual backup
kubectl exec -n database postgresql-0 -- \
  pg_dump -U postgres nexus_db > backup_$(date +%Y%m%d).sql

# List backups
kubectl exec -n database postgresql-0 -- \
  ls -lh /backups/

# Restore from backup
kubectl exec -i -n database postgresql-0 -- \
  psql -U postgres nexus_db < backup_20250101.sql
```

### Application State Backups

```bash
# Backup persistent volumes
./scripts/backup-volumes.sh

# Backup configurations
kubectl get configmaps -n <namespace> -o yaml > configmaps_backup.yaml
kubectl get secrets -n <namespace> -o yaml > secrets_backup.yaml
```

### Disaster Recovery Testing

```bash
# Monthly DR drill
./scripts/dr-test.sh

# Verify recovery procedures
./scripts/verify-recovery.sh

# Document results
# Update runbooks based on findings
```

## Security Operations

### Certificate Management

```bash
# Check certificate expiry
kubectl get certificates -n <namespace>

# Renew certificates
cert-manager renew <certificate-name>

# Verify TLS
openssl s_client -connect <domain>:443 -servername <domain>
```

### Security Scanning

```bash
# Scan containers
trivy image <image-name>:<tag>

# Scan cluster
kube-bench run

# Review security policies
kubectl get networkpolicies -n <namespace>
```

### Access Control

```bash
# Review RBAC
kubectl get rolebindings -n <namespace>
kubectl get clusterrolebindings

# Audit access logs
kubectl logs -n kube-system kube-apiserver-* | grep audit
```

### Secret Rotation

```bash
# Rotate database password
./scripts/rotate-db-password.sh

# Rotate API keys
./scripts/rotate-api-keys.sh

# Update Kubernetes secrets
kubectl create secret generic <secret-name> \
  --from-literal=key=value \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Troubleshooting Guide

### Common Issues

#### Pods Not Starting
```bash
# Check pod status
kubectl describe pod <pod-name> -n <namespace>

# Common causes:
# - Image pull errors
# - Resource limits
# - Config/secret missing
# - Health check failing
```

#### Database Connection Issues
```bash
# Test connectivity
kubectl run -i --tty --rm debug --image=postgres --restart=Never -- \
  psql -h <db-host> -U <user> -d <database>

# Check connection pool
kubectl logs -n <namespace> deployment/<service-name> | grep "connection pool"
```

#### High Memory Usage
```bash
# Check memory usage
kubectl top pods -n <namespace>

# Check for memory leaks
kubectl exec -n <namespace> <pod-name> -- \
  node --expose-gc --inspect memory-check.js

# Restart pod if needed
kubectl delete pod <pod-name> -n <namespace>
```

## Best Practices

1. Always use rolling updates for zero-downtime deployments
2. Test changes in staging before production
3. Keep runbooks up to date
4. Document all incidents
5. Automate repetitive tasks
6. Monitor continuously
7. Regular backup verification
8. Security-first approach
9. Capacity planning
10. Clear communication

## References

- [Architecture Overview](../architecture/architecture-overview.md)
- [Deployment Manifest](../deployment/deployment-manifest.yaml)
- [Monitoring Guide](./monitoring-guide.md)
- [Rollback Strategy](./rollback-strategy.md)
- [Failover Plan](./failover-plan.md)
