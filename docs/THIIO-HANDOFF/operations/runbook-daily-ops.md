# Daily Operations Runbook

## Overview

This runbook covers standard daily operational procedures for the Nexus COS platform.

## Daily Checklist

### Morning (Start of Business Day)

- [ ] Check system health dashboard
- [ ] Review overnight alerts and incidents
- [ ] Verify all services are running
- [ ] Check database replication status
- [ ] Review resource utilization metrics
- [ ] Scan error logs for anomalies
- [ ] Verify backup completion status
- [ ] Check SSL certificate expiration dates

### Continuous Monitoring

- [ ] Monitor real-time dashboards
- [ ] Respond to alerts within SLA
- [ ] Track ongoing incidents
- [ ] Monitor API response times
- [ ] Watch database performance
- [ ] Check disk space usage
- [ ] Monitor network traffic

### End of Day

- [ ] Review day's incidents and resolutions
- [ ] Update incident log
- [ ] Document any configuration changes
- [ ] Check scheduled maintenance windows
- [ ] Verify daily backups completed
- [ ] Review security logs
- [ ] Update on-call handoff notes

## Health Checks

### System Health Verification

```bash
# Check all services status
kubectl get pods -n nexus-cos

# Or with Docker Compose
docker-compose ps

# Check service health endpoints
for service in auth-service backend-api streaming-service-v2; do
  curl -s http://localhost:PORT/health | jq
done
```

### Database Health

```bash
# PostgreSQL
psql -h localhost -U nexus -d nexusdb -c "SELECT version();"
psql -h localhost -U nexus -d nexusdb -c "SELECT pg_size_pretty(pg_database_size('nexusdb'));"

# Redis
redis-cli ping
redis-cli info stats

# MongoDB
mongosh --eval "db.adminCommand('ping')"
```

### Resource Monitoring

```bash
# CPU and Memory
top
htop
kubectl top nodes
kubectl top pods -n nexus-cos

# Disk Space
df -h
du -sh /var/lib/docker
du -sh /data/*

# Network
netstat -tulpn
ss -tulpn
```

## Log Management

### Accessing Logs

```bash
# Kubernetes logs
kubectl logs -n nexus-cos <pod-name> --tail=100 -f

# Docker logs
docker-compose logs -f --tail=100 <service-name>

# System logs
journalctl -u nexus-cos.service -f
tail -f /var/log/nexus-cos/*.log
```

### Log Analysis

```bash
# Check for errors
kubectl logs -n nexus-cos --all-containers --since=1h | grep -i error

# Count error types
kubectl logs -n nexus-cos --all-containers --since=1h | grep ERROR | cut -d' ' -f4- | sort | uniq -c | sort -rn

# Search for specific patterns
kubectl logs -n nexus-cos <pod-name> | grep "API timeout"
```

## Performance Monitoring

### Key Metrics to Watch

1. **API Response Time**
   - Target: < 200ms (p95)
   - Alert: > 500ms

2. **Error Rate**
   - Target: < 0.1%
   - Alert: > 1%

3. **CPU Usage**
   - Target: < 70%
   - Alert: > 85%

4. **Memory Usage**
   - Target: < 80%
   - Alert: > 90%

5. **Database Connections**
   - Target: < 80% of pool
   - Alert: > 90% of pool

### Accessing Dashboards

1. **Grafana**: https://monitoring.nexuscos.example.com
   - Default dashboard: "Nexus COS Overview"
   - Service-specific dashboards available

2. **Prometheus**: https://prometheus.nexuscos.example.com
   - Raw metrics queries
   - Alert manager

3. **Kibana**: https://logs.nexuscos.example.com
   - Log aggregation and search
   - Custom visualizations

## Common Maintenance Tasks

### Restarting Services

```bash
# Kubernetes (rolling restart)
kubectl rollout restart deployment/<service-name> -n nexus-cos

# Docker Compose
docker-compose restart <service-name>

# Systemd
sudo systemctl restart nexus-cos-<service-name>
```

### Scaling Services

```bash
# Kubernetes
kubectl scale deployment/<service-name> --replicas=5 -n nexus-cos

# Docker Compose
docker-compose up -d --scale <service-name>=3
```

### Clearing Cache

```bash
# Redis flush (use with caution!)
redis-cli FLUSHDB

# Selective cache clearing
redis-cli KEYS "session:*" | xargs redis-cli DEL
redis-cli DEL cache:api:users

# CDN cache purge
curl -X POST https://api.cloudflare.com/client/v4/zones/<zone-id>/purge_cache \
  -H "Authorization: Bearer <api-token>" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'
```

### Database Maintenance

```bash
# PostgreSQL vacuum
psql -h localhost -U nexus -d nexusdb -c "VACUUM ANALYZE;"

# Check for long-running queries
psql -h localhost -U nexus -d nexusdb -c "
  SELECT pid, now() - pg_stat_activity.query_start AS duration, query 
  FROM pg_stat_activity 
  WHERE state = 'active' AND now() - pg_stat_activity.query_start > interval '5 minutes';
"

# Kill long-running query (if needed)
psql -h localhost -U nexus -d nexusdb -c "SELECT pg_terminate_backend(<pid>);"
```

## Incident Response

### Alert Severity Levels

- **P1 (Critical)**: Service down, data loss - Response: Immediate
- **P2 (High)**: Major feature broken - Response: < 15 minutes
- **P3 (Medium)**: Minor issue, degraded performance - Response: < 1 hour
- **P4 (Low)**: Minor bug, no impact - Response: Next business day

### Initial Response Steps

1. **Acknowledge the alert** in monitoring system
2. **Assess the impact**: How many users affected?
3. **Check the dashboard** for related metrics
4. **Review recent changes**: Deployments, config changes
5. **Gather logs** from affected services
6. **Start incident log** with timeline
7. **Notify stakeholders** if P1/P2
8. **Begin troubleshooting** following service-specific runbooks

### Communication

- **Slack channel**: #nexus-cos-ops
- **Status page**: Update https://status.nexuscos.example.com
- **Email**: For P1/P2 incidents
- **PagerDuty**: For on-call escalation

## Backup Verification

### Daily Backup Check

```bash
# Check backup script status
systemctl status nexus-cos-backup.timer
journalctl -u nexus-cos-backup.service --since today

# Verify backup files
ls -lh /backups/nexus-cos/$(date +%Y-%m-%d)*
du -sh /backups/nexus-cos/$(date +%Y-%m-%d)*

# Test backup integrity
pg_restore --list /backups/nexus-cos/latest/postgres.dump | head
```

### Backup Restoration Test (Weekly)

```bash
# Restore to test environment
./scripts/restore-backup.sh --environment=test --date=2025-12-11
# Verify test environment
./scripts/verify-test-env.sh
```

## Security Checks

### Daily Security Tasks

```bash
# Check for failed login attempts
kubectl logs -n nexus-cos auth-service --since=24h | grep "Failed login"

# Review access logs
tail -1000 /var/log/nginx/access.log | grep -E "404|500|502|503"

# Check SSL certificates
echo | openssl s_client -servername nexuscos.example.com -connect nexuscos.example.com:443 2>/dev/null | openssl x509 -noout -dates

# Verify firewall rules
sudo iptables -L -n -v
```

## Escalation Procedures

### When to Escalate

- P1/P2 incidents not resolved in 30 minutes
- Data integrity concerns
- Security incidents
- Infrastructure failures
- Unknown root causes

### Escalation Contacts

1. **Platform Lead**: owner+platform@nexuscos.example.com
2. **DevOps Lead**: owner+devops@nexuscos.example.com
3. **Security Team**: owner+security@nexuscos.example.com
4. **Executive On-Call**: owner+oncall@nexuscos.example.com

## Documentation Updates

After resolving incidents:

1. Update runbooks with new learnings
2. Document workarounds
3. Create knowledge base articles
4. Update monitoring/alerting rules
5. Schedule post-mortem if needed

## Weekly Tasks

- [ ] Review and analyze weekly metrics
- [ ] Check for pending security updates
- [ ] Review capacity planning metrics
- [ ] Test disaster recovery procedures
- [ ] Review and update documentation
- [ ] Clean up old logs and backups
- [ ] Review cost optimization opportunities

## Monthly Tasks

- [ ] Full system audit
- [ ] Security vulnerability scan
- [ ] Performance tuning review
- [ ] Capacity planning review
- [ ] DR drill execution
- [ ] Update SSL certificates if needed
- [ ] Review and optimize costs

---

**Document Version**: 1.0  
**Last Updated**: December 2025  
**Next Review**: January 2026
