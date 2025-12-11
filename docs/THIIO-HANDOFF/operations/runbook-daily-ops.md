# Daily Operations Runbook

## Overview

This runbook provides detailed procedures for daily operational tasks for the Nexus COS platform. Follow these procedures to ensure smooth operation and early detection of potential issues.

## Daily Operations Checklist

### Morning Health Check (9:00 AM)

- [ ] Check system health dashboard
- [ ] Review overnight alerts and incidents
- [ ] Verify all critical services are running
- [ ] Check database replication status
- [ ] Review backup completion status
- [ ] Monitor resource utilization trends
- [ ] Check SSL certificate expiration dates

### Throughout the Day

- [ ] Monitor real-time dashboards
- [ ] Respond to automated alerts
- [ ] Review application logs for errors
- [ ] Track API performance metrics
- [ ] Monitor user traffic patterns

### End of Day Review (5:00 PM)

- [ ] Review daily metrics summary
- [ ] Document any incidents or anomalies
- [ ] Plan for scheduled maintenance
- [ ] Update on-call handoff notes
- [ ] Review capacity planning metrics

## 1. System Health Monitoring

### Health Check Dashboard

Access the main health dashboard at:
```
https://monitoring.nexuscos.online/dashboard/health
```

**Key Indicators to Check:**

| Metric | Healthy Threshold | Action if Unhealthy |
|--------|-------------------|---------------------|
| Overall System Uptime | > 99.9% | Investigate failed services |
| API Response Time (p95) | < 200ms | Check slow services |
| Error Rate | < 0.1% | Review error logs |
| Active Services | 43/43 | Restart failed services |
| Database Connections | < 80% of max | Check connection leaks |
| Redis Hit Rate | > 90% | Review cache strategy |

### Command-Line Health Check

```bash
# Check all service health
kubectl get pods --all-namespaces | grep -v Running

# Check service endpoints
./scripts/health-check.sh

# Check specific service
curl https://nexuscos.online/api/health
```

### Expected Output

```json
{
  "status": "healthy",
  "timestamp": "2024-12-11T10:00:00Z",
  "services": {
    "backend-api": "healthy",
    "auth-service": "healthy",
    "database": "healthy",
    "redis": "healthy"
  },
  "uptime": "99.99%"
}
```

## 2. Service Verification

### Check All Services

```bash
# List all running services
kubectl get svc --all-namespaces

# Check pod status in each namespace
kubectl get pods -n nexus-auth
kubectl get pods -n nexus-content
kubectl get pods -n nexus-commerce
kubectl get pods -n nexus-ai
kubectl get pods -n nexus-finance
kubectl get pods -n nexus-logistics
kubectl get pods -n nexus-entertainment
kubectl get pods -n nexus-platform
kubectl get pods -n nexus-specialized
```

### Restart a Service

If a service is not healthy:

```bash
# Restart specific deployment
kubectl rollout restart deployment/backend-api -n nexus-platform

# Check restart status
kubectl rollout status deployment/backend-api -n nexus-platform

# View recent logs
kubectl logs -n nexus-platform deployment/backend-api --tail=100
```

### Common Service Issues

#### Service Not Responding

**Symptoms**: HTTP 503 or connection timeout

**Steps**:
1. Check pod status: `kubectl get pods -n <namespace>`
2. Check pod logs: `kubectl logs -n <namespace> <pod-name>`
3. Check resource usage: `kubectl top pods -n <namespace>`
4. Restart if necessary: `kubectl rollout restart deployment/<service> -n <namespace>`

#### High Memory Usage

**Symptoms**: Pod getting OOMKilled

**Steps**:
1. Check current memory: `kubectl top pod <pod-name> -n <namespace>`
2. Review logs for memory leaks: `kubectl logs <pod-name> -n <namespace>`
3. Increase memory limit if needed (see Performance Tuning runbook)
4. Consider horizontal scaling

#### CrashLoopBackOff

**Symptoms**: Pod repeatedly crashing

**Steps**:
1. Get detailed pod info: `kubectl describe pod <pod-name> -n <namespace>`
2. Check recent logs: `kubectl logs <pod-name> -n <namespace> --previous`
3. Check configuration: `kubectl get configmap -n <namespace>`
4. Check secrets: `kubectl get secrets -n <namespace>`
5. Fix underlying issue and restart

## 3. Database Operations

### PostgreSQL Health Check

```bash
# Check database status
kubectl exec -it postgresql-0 -n nexus-platform -- psql -U nexus -c "SELECT version();"

# Check active connections
kubectl exec -it postgresql-0 -n nexus-platform -- psql -U nexus -c "SELECT count(*) FROM pg_stat_activity;"

# Check replication lag
kubectl exec -it postgresql-0 -n nexus-platform -- psql -U nexus -c "SELECT * FROM pg_stat_replication;"

# Check database size
kubectl exec -it postgresql-0 -n nexus-platform -- psql -U nexus -c "SELECT pg_size_pretty(pg_database_size('nexus_cos'));"
```

### MongoDB Health Check

```bash
# Check MongoDB status
kubectl exec -it mongodb-0 -n nexus-platform -- mongo --eval "db.serverStatus()"

# Check replica set status
kubectl exec -it mongodb-0 -n nexus-platform -- mongo --eval "rs.status()"

# Check database size
kubectl exec -it mongodb-0 -n nexus-platform -- mongo --eval "db.stats()"
```

### Redis Health Check

```bash
# Check Redis status
kubectl exec -it redis-0 -n nexus-platform -- redis-cli INFO

# Check memory usage
kubectl exec -it redis-0 -n nexus-platform -- redis-cli INFO memory

# Check connected clients
kubectl exec -it redis-0 -n nexus-platform -- redis-cli CLIENT LIST
```

### Daily Database Maintenance

```bash
# PostgreSQL vacuum (run during low traffic)
kubectl exec -it postgresql-0 -n nexus-platform -- psql -U nexus -c "VACUUM ANALYZE;"

# Check long-running queries
kubectl exec -it postgresql-0 -n nexus-platform -- psql -U nexus -c "SELECT pid, now() - pg_stat_activity.query_start AS duration, query FROM pg_stat_activity WHERE state = 'active' ORDER BY duration DESC;"

# Kill long-running query if needed
kubectl exec -it postgresql-0 -n nexus-platform -- psql -U nexus -c "SELECT pg_terminate_backend(<pid>);"
```

## 4. Log Monitoring

### Access Logs

```bash
# Centralized logs (Kibana)
https://logs.nexuscos.online

# Service-specific logs
kubectl logs -n <namespace> deployment/<service-name> --tail=100 -f

# All services in namespace
kubectl logs -n nexus-platform --all-containers=true --tail=100
```

### Important Log Patterns to Monitor

**Errors**:
```bash
kubectl logs -n nexus-platform --all-containers=true | grep -i "error\|exception\|fatal"
```

**Authentication Failures**:
```bash
kubectl logs -n nexus-auth --all-containers=true | grep "authentication failed"
```

**Database Connection Issues**:
```bash
kubectl logs --all-namespaces --all-containers=true | grep "database connection"
```

**High Latency Requests**:
```bash
kubectl logs -n nexus-platform deployment/backend-api | grep "slow request"
```

## 5. Performance Monitoring

### Key Performance Metrics

Access performance dashboard:
```
https://monitoring.nexuscos.online/dashboard/performance
```

**Metrics to Monitor**:

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| API Response Time (p50) | < 50ms | > 100ms | > 200ms |
| API Response Time (p95) | < 200ms | > 300ms | > 500ms |
| API Response Time (p99) | < 500ms | > 1s | > 2s |
| CPU Usage | < 60% | > 70% | > 85% |
| Memory Usage | < 70% | > 80% | > 90% |
| Disk Usage | < 70% | > 80% | > 90% |
| Network Throughput | Normal | High | Saturated |

### Check Resource Usage

```bash
# Pod resource usage
kubectl top pods --all-namespaces

# Node resource usage
kubectl top nodes

# Detailed node info
kubectl describe node <node-name>
```

### Traffic Analysis

```bash
# Check request rates (Prometheus query)
rate(http_requests_total[5m])

# Check error rates
rate(http_requests_total{status=~"5.."}[5m])

# Check database query performance
avg(query_duration_seconds) by (query_type)
```

## 6. Backup Verification

### Check Backup Status

```bash
# PostgreSQL backups
kubectl get cronjobs -n nexus-platform | grep backup

# Check last backup completion
kubectl get jobs -n nexus-platform | grep backup | head -5

# Check backup logs
kubectl logs -n nexus-platform job/postgresql-backup-<timestamp>
```

### Verify Backup Integrity

```bash
# List recent backups
aws s3 ls s3://nexus-cos-backups/postgresql/ --recursive | tail -10

# Test backup restore (staging environment)
./scripts/test-backup-restore.sh --environment staging --backup latest
```

### Backup Schedule

| Component | Frequency | Retention | Location |
|-----------|-----------|-----------|----------|
| PostgreSQL | Daily 2 AM | 30 days | S3 bucket |
| MongoDB | Daily 3 AM | 30 days | S3 bucket |
| Redis | Daily 4 AM | 7 days | S3 bucket |
| Configuration | On change | 90 days | Git repository |
| Elasticsearch | Weekly | 14 days | S3 bucket |

## 7. Security Monitoring

### SSL Certificate Check

```bash
# Check certificate expiration
echo | openssl s_client -servername nexuscos.online -connect nexuscos.online:443 2>/dev/null | openssl x509 -noout -dates

# Check all domains
./scripts/check-ssl-certificates.sh
```

### Security Alerts

Monitor for:
- Failed authentication attempts (> 100/hour from single IP)
- Unusual API access patterns
- Privilege escalation attempts
- Unauthorized access to sensitive endpoints
- DDoS attack patterns

```bash
# Check failed auth attempts
kubectl logs -n nexus-auth --all-containers=true | grep "authentication failed" | wc -l

# Check for suspicious IPs
kubectl logs -n nexus-platform deployment/backend-api | grep "403\|401" | awk '{print $1}' | sort | uniq -c | sort -rn | head -20
```

## 8. Capacity Planning

### Daily Capacity Review

Check capacity metrics:
```
https://monitoring.nexuscos.online/dashboard/capacity
```

**Key Metrics**:
- Database storage growth rate
- API request trend
- User growth trend
- Resource utilization trend

### Storage Monitoring

```bash
# Check PVC usage
kubectl get pvc --all-namespaces

# Check detailed storage
kubectl exec -it <pod-name> -n <namespace> -- df -h

# Monitor database growth
kubectl exec -it postgresql-0 -n nexus-platform -- psql -U nexus -c "SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size FROM pg_tables ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC LIMIT 10;"
```

## 9. Incident Response

### Severity Levels

| Level | Response Time | Description |
|-------|---------------|-------------|
| P0 - Critical | < 5 min | System down, data loss |
| P1 - High | < 15 min | Major feature broken |
| P2 - Medium | < 1 hour | Minor feature impaired |
| P3 - Low | < 4 hours | Minor issues |

### Incident Response Process

1. **Detect**: Automated alerts or manual detection
2. **Triage**: Assess severity and impact
3. **Communicate**: Notify stakeholders
4. **Investigate**: Gather logs, metrics, traces
5. **Mitigate**: Apply temporary fix if needed
6. **Resolve**: Implement permanent solution
7. **Document**: Create incident report
8. **Review**: Post-mortem for P0/P1 incidents

### Emergency Contacts

- **On-Call Engineer**: Pagerduty/Slack
- **Platform Lead**: +1-XXX-XXX-XXXX
- **DevOps Lead**: +1-XXX-XXX-XXXX
- **Security Team**: security@nexuscos.online

## 10. Common Tasks

### Scale a Service

```bash
# Scale up
kubectl scale deployment/backend-api -n nexus-platform --replicas=10

# Scale down
kubectl scale deployment/backend-api -n nexus-platform --replicas=3

# Verify scaling
kubectl get deployment backend-api -n nexus-platform
```

### Update Configuration

```bash
# Edit ConfigMap
kubectl edit configmap app-config -n nexus-platform

# Restart pods to pick up new config
kubectl rollout restart deployment/backend-api -n nexus-platform
```

### Clear Cache

```bash
# Clear Redis cache
kubectl exec -it redis-0 -n nexus-platform -- redis-cli FLUSHDB

# Clear specific keys
kubectl exec -it redis-0 -n nexus-platform -- redis-cli DEL "cache:*"
```

### Drain Node for Maintenance

```bash
# Cordon node (prevent new pods)
kubectl cordon <node-name>

# Drain node (evict existing pods)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# After maintenance
kubectl uncordon <node-name>
```

## 11. Reporting

### Daily Status Report

Generate daily report:
```bash
./scripts/generate-daily-report.sh
```

Report includes:
- System uptime
- Incident summary
- Performance metrics
- Resource utilization
- Top errors
- User metrics

### Weekly Report

Generate weekly summary:
```bash
./scripts/generate-weekly-report.sh
```

Additional metrics:
- Week-over-week trends
- Capacity planning insights
- Security incidents
- Deployment frequency
- MTTR/MTTD metrics

## 12. Best Practices

### DO's

✓ Check health dashboard at start of shift  
✓ Respond to alerts within SLA  
✓ Document all manual interventions  
✓ Follow change management process  
✓ Test in staging before production  
✓ Keep runbooks updated  
✓ Communicate with team  

### DON'Ts

✗ Make changes without documentation  
✗ Ignore warning-level alerts  
✗ Skip backup verification  
✗ Deploy during peak hours  
✗ Delete data without backup  
✗ Share credentials insecurely  

## Appendix

### Useful Commands Quick Reference

```bash
# Get pod details
kubectl get pods -n <namespace> -o wide

# Describe pod
kubectl describe pod <pod-name> -n <namespace>

# Get logs
kubectl logs <pod-name> -n <namespace> --tail=100 -f

# Execute command in pod
kubectl exec -it <pod-name> -n <namespace> -- <command>

# Port forward
kubectl port-forward -n <namespace> <pod-name> 8080:8080

# Get events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

### Dashboard URLs

- **Main Dashboard**: https://monitoring.nexuscos.online
- **Grafana**: https://grafana.nexuscos.online
- **Kibana**: https://logs.nexuscos.online
- **Jaeger**: https://tracing.nexuscos.online
- **ArgoCD**: https://cd.nexuscos.online

---

**Document Version**: 1.0  
**Last Updated**: December 2024  
**Owner**: DevOps Team
