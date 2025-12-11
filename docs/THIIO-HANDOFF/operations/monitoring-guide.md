# Monitoring Guide

## Overview

Comprehensive monitoring setup for Nexus COS platform.

## Monitoring Stack

### Components
- **Prometheus**: Metrics collection
- **Grafana**: Visualization
- **ELK Stack**: Centralized logging
- **Jaeger**: Distributed tracing

## Key Metrics

### Service Metrics

#### Request Metrics
- Request rate (requests/second)
- Error rate (errors/requests)
- Request duration (p50, p95, p99)
- Success rate (%)

#### Resource Metrics
- CPU utilization (%)
- Memory usage (MB/GB)
- Disk I/O (MB/s)
- Network throughput (MB/s)

#### Business Metrics
- Active users
- Transactions per second
- Revenue per minute
- Content uploads/downloads

## Dashboards

### Platform Overview Dashboard
- All services status
- Overall health score
- Request volume
- Error rates
- Resource utilization

### Service-Specific Dashboards
- Per-service metrics
- Dependency health
- API endpoint performance
- Error breakdown

### Infrastructure Dashboard
- Kubernetes cluster health
- Node metrics
- Pod status
- Storage utilization

## Alerts

### Critical Alerts (P0)
- Service down
- Error rate > 10%
- Database connection failure
- Disk space < 10%

### High Priority Alerts (P1)
- Error rate > 5%
- P95 latency > 2x baseline
- Memory usage > 90%
- CPU usage > 85%

### Medium Priority Alerts (P2)
- Error rate > 2%
- P95 latency > 1.5x baseline
- Slow queries
- High connection pool usage

## Log Management

### Log Levels
- **DEBUG**: Detailed debugging info
- **INFO**: General information
- **WARN**: Warning messages
- **ERROR**: Error conditions
- **FATAL**: Critical failures

### Log Aggregation
```bash
# View logs for service
kubectl logs -n <namespace> deployment/<service-name>

# Follow logs
kubectl logs -f -n <namespace> deployment/<service-name>

# Search logs in ELK
# Access Kibana UI for advanced search
```

## Distributed Tracing

### Jaeger Setup
- Trace requests across services
- Identify bottlenecks
- Debug performance issues

### Viewing Traces
```bash
# Port-forward Jaeger UI
kubectl port-forward -n monitoring svc/jaeger-query 16686:16686

# Access at http://localhost:16686
```

## Health Checks

### Endpoints
- `/health` - Basic health
- `/health/ready` - Readiness
- `/health/live` - Liveness

### Monitoring Health
```bash
# Check all services
kubectl get pods -n <namespace>

# Detailed health check
curl http://<service>:port/health
```

## Best Practices

1. Set up meaningful alerts
2. Avoid alert fatigue
3. Dashboard for every service
4. Regular dashboard reviews
5. Correlate metrics with logs
6. Use distributed tracing
7. Monitor business metrics
8. Capacity planning
