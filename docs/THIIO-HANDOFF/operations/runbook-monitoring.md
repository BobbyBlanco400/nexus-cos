# Monitoring Runbook

## Overview

This runbook provides comprehensive guidance on monitoring the Nexus COS platform, including dashboards, alerts, metrics collection, and troubleshooting monitoring issues.

## Monitoring Architecture

### Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Services                      │
│          (Expose metrics on /metrics endpoint)               │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                 Prometheus (Metrics Collection)              │
│          - Scrape interval: 15s                              │
│          - Retention: 15 days                                │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                  Grafana (Visualization)                     │
│          - 20+ Dashboards                                    │
│          - Real-time metrics                                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              Application Logs (JSON formatted)               │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│              Filebeat (Log Collection)                       │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│            Logstash (Log Processing)                         │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│         Elasticsearch (Log Storage & Search)                 │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│              Kibana (Log Visualization)                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│           Application Traces (OpenTelemetry)                 │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│         Jaeger (Distributed Tracing)                         │
│          - Retention: 7 days                                 │
└─────────────────────────────────────────────────────────────┘
```

## 1. Access Monitoring Tools

### Dashboard URLs

| Tool | URL | Purpose |
|------|-----|---------|
| Grafana | https://grafana.nexuscos.online | Metrics visualization |
| Prometheus | https://prometheus.nexuscos.online | Metrics storage & queries |
| Kibana | https://logs.nexuscos.online | Log exploration |
| Jaeger | https://tracing.nexuscos.online | Distributed tracing |
| AlertManager | https://alerts.nexuscos.online | Alert management |

### Authentication

```bash
# Get Grafana admin password
kubectl get secret grafana-admin -n monitoring -o jsonpath="{.data.password}" | base64 -d

# Access Prometheus directly
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Then open http://localhost:9090

# Access Kibana
kubectl port-forward -n monitoring svc/kibana 5601:5601
# Then open http://localhost:5601
```

## 2. Key Dashboards

### Overview Dashboard

**URL**: https://grafana.nexuscos.online/d/overview

**Panels**:
- System-wide health score
- Active services count
- Total requests/sec
- Error rate (%)
- Average response time
- CPU/Memory usage across all services
- Database connection pool status
- Cache hit rate

### Service-Specific Dashboards

#### Backend API Dashboard
**URL**: https://grafana.nexuscos.online/d/backend-api

**Key Metrics**:
```
- Request rate: rate(http_requests_total{service="backend-api"}[5m])
- Error rate: rate(http_requests_total{service="backend-api",status=~"5.."}[5m])
- Response time: histogram_quantile(0.95, http_request_duration_seconds{service="backend-api"})
- Active connections: backend_api_active_connections
- Database queries/sec: rate(database_queries_total{service="backend-api"}[5m])
```

#### Auth Service Dashboard
**URL**: https://grafana.nexuscos.online/d/auth-service

**Key Metrics**:
```
- Login attempts/min: rate(auth_login_attempts_total[1m])
- Failed logins/min: rate(auth_login_failures_total[1m])
- Active sessions: auth_active_sessions
- Token generation rate: rate(auth_tokens_generated_total[5m])
- JWT validation time: auth_jwt_validation_duration_seconds
```

#### Database Dashboard
**URL**: https://grafana.nexuscos.online/d/databases

**PostgreSQL Metrics**:
```
- Active connections: pg_stat_activity_count
- Transaction rate: rate(pg_stat_database_xact_commit_total[5m])
- Cache hit ratio: pg_stat_database_blks_hit / (pg_stat_database_blks_hit + pg_stat_database_blks_read)
- Replication lag: pg_replication_lag_seconds
- Deadlocks: rate(pg_stat_database_deadlocks_total[5m])
```

**MongoDB Metrics**:
```
- Operations/sec: rate(mongodb_opcounters_total[5m])
- Connections: mongodb_connections
- Replication lag: mongodb_replset_member_replication_lag
- Document operations: rate(mongodb_document_total[5m])
```

**Redis Metrics**:
```
- Operations/sec: rate(redis_commands_processed_total[5m])
- Hit rate: redis_keyspace_hits_total / (redis_keyspace_hits_total + redis_keyspace_misses_total)
- Memory usage: redis_memory_used_bytes
- Connected clients: redis_connected_clients
- Evicted keys: rate(redis_evicted_keys_total[5m])
```

### Infrastructure Dashboard
**URL**: https://grafana.nexuscos.online/d/infrastructure

**Node Metrics**:
```
- CPU usage: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
- Memory usage: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100
- Disk usage: (node_filesystem_size_bytes - node_filesystem_avail_bytes) / node_filesystem_size_bytes * 100
- Network throughput: rate(node_network_receive_bytes_total[5m]), rate(node_network_transmit_bytes_total[5m])
- Disk I/O: rate(node_disk_read_bytes_total[5m]), rate(node_disk_written_bytes_total[5m])
```

**Kubernetes Metrics**:
```
- Pod CPU usage: sum(rate(container_cpu_usage_seconds_total[5m])) by (pod)
- Pod memory usage: sum(container_memory_usage_bytes) by (pod)
- Pod restarts: kube_pod_container_status_restarts_total
- Pod status: kube_pod_status_phase
```

## 3. Alert Configuration

### Alert Severity Levels

| Level | Description | Response Time | Escalation |
|-------|-------------|---------------|------------|
| Critical | Service down, data loss | Immediate | Page on-call |
| High | Degraded performance | 5 minutes | Slack + Email |
| Medium | Approaching threshold | 15 minutes | Email |
| Low | Informational | 1 hour | Dashboard only |

### Critical Alerts

#### Service Down
```yaml
alert: ServiceDown
expr: up{job="backend-api"} == 0
for: 1m
labels:
  severity: critical
annotations:
  summary: "Service {{ $labels.job }} is down"
  description: "{{ $labels.job }} has been down for more than 1 minute"
```

#### High Error Rate
```yaml
alert: HighErrorRate
expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
for: 2m
labels:
  severity: critical
annotations:
  summary: "High error rate on {{ $labels.service }}"
  description: "Error rate is {{ $value }} (>5%) for {{ $labels.service }}"
```

#### Database Connection Pool Exhausted
```yaml
alert: DatabaseConnectionPoolExhausted
expr: database_connection_pool_active / database_connection_pool_max > 0.9
for: 5m
labels:
  severity: high
annotations:
  summary: "Database connection pool nearly exhausted"
  description: "{{ $labels.service }} using {{ $value }}% of database connections"
```

#### High Memory Usage
```yaml
alert: HighMemoryUsage
expr: (container_memory_usage_bytes / container_spec_memory_limit_bytes) > 0.9
for: 5m
labels:
  severity: high
annotations:
  summary: "High memory usage on {{ $labels.pod }}"
  description: "Pod {{ $labels.pod }} using {{ $value }}% of memory limit"
```

#### Disk Space Low
```yaml
alert: DiskSpaceLow
expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) < 0.1
for: 5m
labels:
  severity: high
annotations:
  summary: "Low disk space on {{ $labels.instance }}"
  description: "Only {{ $value }}% disk space remaining on {{ $labels.instance }}"
```

### High Priority Alerts

#### Slow Response Time
```yaml
alert: SlowResponseTime
expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
for: 5m
labels:
  severity: high
annotations:
  summary: "Slow response time on {{ $labels.service }}"
  description: "95th percentile response time is {{ $value }}s (>500ms)"
```

#### Certificate Expiring Soon
```yaml
alert: SSLCertificateExpiringSoon
expr: (ssl_certificate_expiry_seconds - time()) / 86400 < 30
for: 1h
labels:
  severity: high
annotations:
  summary: "SSL certificate expiring soon"
  description: "Certificate {{ $labels.domain }} expires in {{ $value }} days"
```

### Managing Alerts

#### View Active Alerts
```bash
# Via AlertManager UI
https://alerts.nexuscos.online

# Via Prometheus API
curl -s https://prometheus.nexuscos.online/api/v1/alerts | jq '.data.alerts[] | select(.state=="firing")'

# Via kubectl
kubectl get prometheusrules -n monitoring
```

#### Silence an Alert
```bash
# Create silence via amtool
amtool silence add alertname="HighMemoryUsage" --duration=1h --comment="Known issue, working on fix"

# Or via AlertManager UI
# https://alerts.nexuscos.online/#/silences
```

#### Modify Alert Rules
```bash
# Edit Prometheus rules
kubectl edit prometheusrules nexus-cos-alerts -n monitoring

# Reload Prometheus configuration
kubectl rollout restart statefulset/prometheus -n monitoring
```

## 4. Log Monitoring

### Accessing Logs

#### Via Kibana
1. Navigate to https://logs.nexuscos.online
2. Select time range
3. Use KQL (Kibana Query Language) for filtering

**Common Queries**:
```
# Errors in last hour
level:error AND @timestamp:>now-1h

# Specific service logs
service.name:"backend-api" AND level:error

# Slow queries
query_duration:>1000 AND @timestamp:>now-15m

# Authentication failures
event.type:"authentication_failure" AND @timestamp:>now-1h

# Specific user activity
user.id:"user123" AND @timestamp:>now-24h
```

#### Via kubectl
```bash
# Real-time logs
kubectl logs -n nexus-platform deployment/backend-api -f

# Logs from all pods
kubectl logs -n nexus-platform -l app=backend-api --all-containers=true

# Previous pod logs (after crash)
kubectl logs -n nexus-platform <pod-name> --previous

# Logs with timestamps
kubectl logs -n nexus-platform deployment/backend-api --timestamps
```

### Log Levels

| Level | Usage | Example |
|-------|-------|---------|
| ERROR | Application errors | Database connection failed |
| WARN | Warning conditions | High memory usage |
| INFO | Informational messages | User logged in |
| DEBUG | Detailed debugging | Function entry/exit |
| TRACE | Very detailed tracing | Variable values |

### Important Log Patterns

#### Application Errors
```bash
# In Kibana
level:error AND NOT error.message:("known issue" OR "expected error")

# Pattern to monitor
- Database connection errors
- Uncaught exceptions
- Timeout errors
- Authentication failures
- API errors from external services
```

#### Performance Issues
```bash
# Slow database queries
query_duration:>1000 AND query_type:"database"

# Slow API requests
request_duration:>500 AND endpoint:*

# Memory warnings
message:"memory usage high" OR message:"out of memory"
```

#### Security Events
```bash
# Failed login attempts
event.type:"authentication_failure"

# Privilege escalation
event.type:"privilege_escalation"

# Suspicious activity
level:warn AND (message:"suspicious" OR message:"unusual")
```

## 5. Distributed Tracing

### Accessing Jaeger

**URL**: https://tracing.nexuscos.online

### Finding Slow Requests

1. Open Jaeger UI
2. Select service from dropdown
3. Set time range
4. Filter by:
   - Min Duration: > 500ms
   - Max Duration: < inf
   - Tags: error=true

### Analyzing a Trace

**Key Information**:
- Total request duration
- Service call hierarchy
- Time spent in each service
- Database query duration
- External API call duration
- Error messages and stack traces

### Common Trace Patterns

#### Healthy Request
```
frontend (50ms)
  └─ backend-api (40ms)
      ├─ auth-service (10ms)
      ├─ cache lookup (2ms)
      └─ database query (15ms)
```

#### Slow Request (Cache Miss)
```
frontend (850ms)
  └─ backend-api (840ms)
      ├─ auth-service (10ms)
      ├─ cache miss (1ms)
      └─ database query (800ms) ← Problem!
```

#### Error Path
```
frontend (100ms)
  └─ backend-api (90ms)
      ├─ auth-service (10ms)
      └─ external-api (75ms)
          └─ HTTP 500 ← Error!
```

### Trace Analysis Commands

```bash
# Find traces with errors
curl "https://tracing.nexuscos.online/api/traces?service=backend-api&tags={\"error\":\"true\"}"

# Find slow traces
curl "https://tracing.nexuscos.online/api/traces?service=backend-api&minDuration=500ms"

# Export trace for analysis
curl "https://tracing.nexuscos.online/api/traces/<trace-id>" > trace.json
```

## 6. Custom Metrics

### Adding Custom Metrics

**Example**: Counter metric
```javascript
const promClient = require('prom-client');

const orderCounter = new promClient.Counter({
  name: 'orders_processed_total',
  help: 'Total number of orders processed',
  labelNames: ['status', 'payment_method']
});

// Increment counter
orderCounter.inc({ status: 'completed', payment_method: 'credit_card' });
```

**Example**: Histogram metric
```javascript
const requestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

// Record duration
const end = requestDuration.startTimer();
// ... process request ...
end({ method: 'GET', route: '/api/orders', status_code: 200 });
```

### Querying Custom Metrics

```promql
# Total orders in last hour
sum(increase(orders_processed_total[1h]))

# Orders by payment method
sum(rate(orders_processed_total[5m])) by (payment_method)

# Order success rate
sum(rate(orders_processed_total{status="completed"}[5m])) / 
sum(rate(orders_processed_total[5m]))
```

## 7. Monitoring Best Practices

### DO's

✓ Set up alerts for all critical services  
✓ Use meaningful alert names and descriptions  
✓ Include runbook links in alert annotations  
✓ Test alerts regularly  
✓ Review and update dashboards monthly  
✓ Use structured logging (JSON format)  
✓ Include correlation IDs in all logs  
✓ Monitor both symptoms and causes  
✓ Set appropriate alert thresholds  
✓ Document custom metrics  

### DON'Ts

✗ Alert on every minor issue  
✗ Set alerts without runbook procedures  
✗ Ignore warning-level alerts  
✗ Log sensitive data (passwords, tokens, PII)  
✗ Use different log formats across services  
✗ Set unrealistic SLOs  
✗ Monitor metrics without taking action  

## 8. Troubleshooting Monitoring Issues

### Prometheus Not Scraping Metrics

```bash
# Check Prometheus targets
curl https://prometheus.nexuscos.online/api/v1/targets | jq

# Check service metrics endpoint
curl https://nexuscos.online/api/metrics

# Check Prometheus logs
kubectl logs -n monitoring deployment/prometheus
```

### Missing Logs in Elasticsearch

```bash
# Check Filebeat status
kubectl get pods -n monitoring -l app=filebeat

# Check Filebeat logs
kubectl logs -n monitoring -l app=filebeat

# Check Logstash status
kubectl logs -n monitoring deployment/logstash

# Verify Elasticsearch is accepting documents
curl -X POST https://logs.nexuscos.online/_bulk
```

### Jaeger Traces Not Appearing

```bash
# Check Jaeger collector
kubectl logs -n monitoring deployment/jaeger-collector

# Check application instrumentation
curl https://nexuscos.online/api/traces/test

# Verify OpenTelemetry configuration
kubectl get configmap otel-collector-config -n monitoring -o yaml
```

## 9. Capacity Planning

### Metrics to Monitor for Growth

- Request rate trend (week-over-week)
- Database size growth
- Storage usage trend
- User growth rate
- Peak concurrent users

### Scaling Triggers

**Horizontal Scaling**:
```yaml
# HPA based on custom metrics
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend-api
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "1000"
```

## 10. Monitoring Checklist

### Daily
- [ ] Check overview dashboard
- [ ] Review active alerts
- [ ] Verify all services are scraped by Prometheus
- [ ] Check log ingestion rate

### Weekly
- [ ] Review slow traces in Jaeger
- [ ] Analyze error trends
- [ ] Check disk space on monitoring stack
- [ ] Review and tune alert thresholds

### Monthly
- [ ] Update dashboards
- [ ] Review and clean up old alerts
- [ ] Analyze capacity trends
- [ ] Update runbooks based on incidents

---

**Document Version**: 1.0  
**Last Updated**: December 2024  
**Owner**: DevOps Team
