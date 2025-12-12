# Monitoring Runbook

## Overview

This runbook covers monitoring setup, key metrics, alerting configuration, and troubleshooting procedures for the Nexus COS platform.

## Monitoring Stack

### Components

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert routing and notifications
- **ELK Stack**: Log aggregation (Elasticsearch, Logstash, Kibana)
- **Jaeger**: Distributed tracing
- **Node Exporter**: System metrics
- **cAdvisor**: Container metrics

### Access URLs

- Grafana: https://grafana.nexuscos.example.com
- Prometheus: https://prometheus.nexuscos.example.com
- Alertmanager: https://alertmanager.nexuscos.example.com
- Kibana: https://kibana.nexuscos.example.com
- Jaeger: https://jaeger.nexuscos.example.com

## Key Metrics

### Application Metrics

#### API Metrics
```promql
# Request rate
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# Latency (p95)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Request by endpoint
sum(rate(http_requests_total[5m])) by (endpoint)
```

#### Service Health
```promql
# Service up/down
up{job="nexus-cos-services"}

# Pod restarts
rate(kube_pod_container_status_restarts_total[1h])

# Pod status
kube_pod_status_phase{namespace="nexus-cos"}
```

### Infrastructure Metrics

#### CPU & Memory
```promql
# CPU usage per pod
rate(container_cpu_usage_seconds_total{namespace="nexus-cos"}[5m])

# Memory usage
container_memory_usage_bytes{namespace="nexus-cos"}

# Memory limit
container_spec_memory_limit_bytes{namespace="nexus-cos"}

# CPU throttling
rate(container_cpu_cfs_throttled_seconds_total[5m])
```

#### Disk & Network
```promql
# Disk usage
node_filesystem_avail_bytes{mountpoint="/"}

# Disk I/O
rate(node_disk_io_time_seconds_total[5m])

# Network received
rate(node_network_receive_bytes_total[5m])

# Network transmitted
rate(node_network_transmit_bytes_total[5m])
```

### Database Metrics

#### PostgreSQL
```promql
# Active connections
pg_stat_database_numbackends{datname="nexusdb"}

# Query duration
pg_stat_activity_max_tx_duration

# Lock waits
pg_locks_count

# Cache hit ratio
pg_stat_database_blks_hit / (pg_stat_database_blks_hit + pg_stat_database_blks_read)
```

#### Redis
```promql
# Memory usage
redis_memory_used_bytes

# Connected clients
redis_connected_clients

# Commands per second
rate(redis_commands_processed_total[1m])

# Cache hit rate
redis_keyspace_hits_total / (redis_keyspace_hits_total + redis_keyspace_misses_total)
```

## Grafana Dashboards

### Main Dashboards

1. **Nexus COS Overview** (ID: 1)
   - System health at a glance
   - Key metrics summary
   - Active alerts

2. **Service Metrics** (ID: 2)
   - Per-service request rates
   - Error rates
   - Latencies
   - Resource usage

3. **Infrastructure** (ID: 3)
   - Node metrics
   - Cluster health
   - Resource utilization

4. **Database Performance** (ID: 4)
   - Query performance
   - Connection pools
   - Lock statistics
   - Replication lag

5. **Business Metrics** (ID: 5)
   - User signups
   - Active sessions
   - Revenue metrics
   - Feature usage

### Creating Custom Dashboards

```bash
# Export existing dashboard
curl -H "Authorization: Bearer $GRAFANA_API_KEY" \
  https://grafana.nexuscos.example.com/api/dashboards/uid/<dashboard-uid> \
  > dashboard.json

# Import dashboard
curl -X POST -H "Authorization: Bearer $GRAFANA_API_KEY" \
  -H "Content-Type: application/json" \
  -d @dashboard.json \
  https://grafana.nexuscos.example.com/api/dashboards/db
```

## Alert Configuration

### Alert Rules

```yaml
# prometheus-alerts.yaml
groups:
  - name: nexus-cos-alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} (> 5%)"

      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High API latency"
          description: "P95 latency is {{ $value }}s"

      - alert: ServiceDown
        expr: up{job="nexus-cos-services"} == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Service {{ $labels.instance }} is down"

      - alert: HighCPU
        expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.pod }}"

      - alert: HighMemory
        expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.pod }}"

      - alert: DiskSpaceLow
        expr: node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes < 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"

      - alert: DatabaseConnectionsHigh
        expr: pg_stat_database_numbackends > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High database connections ({{ $value }})"

      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Pod {{ $labels.pod }} is crash looping"
```

### Alertmanager Configuration

```yaml
# alertmanager.yml
global:
  slack_api_url: '<slack-webhook-url>'

route:
  receiver: 'default'
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  routes:
    - match:
        severity: critical
      receiver: 'pagerduty'
      continue: true
    - match:
        severity: critical
      receiver: 'slack-critical'
    - match:
        severity: warning
      receiver: 'slack-warnings'

receivers:
  - name: 'default'
    email_configs:
      - to: 'owner+ops@nexuscos.example.com'

  - name: 'slack-critical'
    slack_configs:
      - channel: '#nexus-cos-critical'
        title: 'Critical Alert'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'

  - name: 'slack-warnings'
    slack_configs:
      - channel: '#nexus-cos-ops'
        title: 'Warning Alert'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'

  - name: 'pagerduty'
    pagerduty_configs:
      - service_key: '<pagerduty-service-key>'
```

## Log Management

### Log Aggregation

```bash
# View logs in Kibana
# Navigate to: https://kibana.nexuscos.example.com

# Query examples:
# - All errors: level:error
# - Specific service: service:auth-service AND level:error
# - Time range: @timestamp:[now-1h TO now]
# - User activity: user_id:12345
```

### Log Queries

```bash
# Using Elasticsearch API
curl -X GET "kibana.nexuscos.example.com:9200/nexus-cos-*/_search" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "bool": {
        "must": [
          {"match": {"level": "error"}},
          {"range": {"@timestamp": {"gte": "now-1h"}}}
        ]
      }
    }
  }'
```

## Distributed Tracing

### Jaeger Usage

```bash
# Access Jaeger UI
# Navigate to: https://jaeger.nexuscos.example.com

# Find traces:
# 1. Select service from dropdown
# 2. Set time range
# 3. Add filters (tags, min/max duration)
# 4. Click "Find Traces"

# Analyze slow requests:
# - Sort by duration
# - Look for service dependencies
# - Identify bottlenecks
```

### Trace Analysis

Example trace analysis for slow API request:

1. Identify slow span in trace
2. Check span tags for details
3. Look at logs for that timestamp
4. Check database queries in that timeframe
5. Verify external API calls
6. Review resource metrics during trace

## Monitoring Best Practices

### Dashboard Organization

1. **Executive Dashboard**: High-level KPIs
2. **Operations Dashboard**: Day-to-day metrics
3. **Service Dashboards**: Per-service deep dive
4. **Database Dashboards**: Database performance
5. **Infrastructure Dashboards**: System resources

### Alert Tuning

- Avoid alert fatigue: Only alert on actionable items
- Set appropriate thresholds based on baselines
- Use multi-condition alerts to reduce false positives
- Group related alerts to avoid notification spam
- Regularly review and update alert rules

### Metric Retention

- **High-resolution (15s)**: 7 days
- **Medium-resolution (1m)**: 30 days
- **Low-resolution (5m)**: 1 year
- **Aggregated**: 5 years

## Troubleshooting Common Issues

### High Memory Usage

```bash
# Identify memory-hungry pods
kubectl top pods -n nexus-cos --sort-by=memory

# Check pod details
kubectl describe pod <pod-name> -n nexus-cos

# Review logs for memory leaks
kubectl logs <pod-name> -n nexus-cos | grep -i "out of memory"

# Analyze heap dump (Node.js)
kubectl exec -it <pod-name> -n nexus-cos -- node --heap-snapshot
```

### High CPU Usage

```bash
# Identify CPU-hungry pods
kubectl top pods -n nexus-cos --sort-by=cpu

# Check for infinite loops in logs
kubectl logs <pod-name> -n nexus-cos --tail=1000

# Profile application
# Use Node.js profiler or attach debugger
```

### Slow Database Queries

```sql
-- Find slow queries
SELECT pid, now() - query_start as duration, query
FROM pg_stat_activity
WHERE state = 'active' AND now() - query_start > interval '5 seconds'
ORDER BY duration DESC;

-- Check table statistics
SELECT schemaname, tablename, n_live_tup, n_dead_tup
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC;

-- Analyze query plan
EXPLAIN ANALYZE <your-query>;
```

### Missing Metrics

```bash
# Check Prometheus targets
curl https://prometheus.nexuscos.example.com/api/v1/targets | jq

# Verify service discovery
kubectl get servicemonitors -n nexus-cos

# Check Prometheus logs
kubectl logs -n monitoring prometheus-0
```

## Performance Baselines

### Baseline Metrics

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| API Latency (p95) | < 200ms | > 500ms | > 1s |
| Error Rate | < 0.1% | > 1% | > 5% |
| CPU Usage | < 60% | > 80% | > 90% |
| Memory Usage | < 70% | > 85% | > 95% |
| DB Connections | < 50 | > 80 | > 95 |
| Disk Usage | < 70% | > 85% | > 95% |

## Contacts

- **Monitoring Team**: owner+monitoring@nexuscos.example.com
- **On-Call Engineer**: owner+oncall@nexuscos.example.com
- **Platform Team**: owner+platform@nexuscos.example.com

---

**Document Version**: 1.0  
**Last Updated**: December 2025  
**Review Frequency**: Quarterly
