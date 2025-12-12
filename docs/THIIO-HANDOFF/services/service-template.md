# Service Documentation Template

## Service Name

[Service Name Here]

## Overview

Brief description of what this service does and its role in the platform.

## Service Information

- **Service Name**: `service-name`
- **Port**: `3XXX`
- **Repository**: `services/service-name`
- **Owner Team**: [Team Name]
- **On-Call Contact**: owner+servicename@nexuscos.example.com

## Responsibilities

- Primary responsibility 1
- Primary responsibility 2
- Primary responsibility 3

## API Endpoints

### Public Endpoints

```
GET    /api/v1/resource          - List resources
POST   /api/v1/resource          - Create resource
GET    /api/v1/resource/:id      - Get specific resource
PUT    /api/v1/resource/:id      - Update resource
DELETE /api/v1/resource/:id      - Delete resource
```

### Internal Endpoints

```
GET    /health                   - Health check
GET    /health/ready             - Readiness probe
GET    /health/live              - Liveness probe
GET    /metrics                  - Prometheus metrics
```

## Dependencies

### Required Services

- `dependency-service-1` - Why it's needed
- `dependency-service-2` - Why it's needed

### Required Infrastructure

- PostgreSQL - Data persistence
- Redis - Caching
- S3/MinIO - Object storage (if applicable)

## Configuration

### Environment Variables

```bash
# Service Configuration
SERVICE_PORT=3XXX
SERVICE_NAME=service-name
NODE_ENV=production

# Database
DATABASE_URL=postgresql://user:pass@host:5432/dbname
DATABASE_POOL_MIN=2
DATABASE_POOL_MAX=10

# Redis
REDIS_URL=redis://host:6379
REDIS_PASSWORD=secret

# External APIs
API_KEY=your-api-key
API_SECRET=your-api-secret

# Monitoring
LOG_LEVEL=info
METRICS_PORT=9090
```

### ConfigMap Example

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: service-name-config
  namespace: nexus-cos
data:
  SERVICE_NAME: "service-name"
  LOG_LEVEL: "info"
  FEATURE_FLAG_X: "true"
```

## Deployment

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-name
  namespace: nexus-cos
spec:
  replicas: 3
  selector:
    matchLabels:
      app: service-name
  template:
    metadata:
      labels:
        app: service-name
        version: v1.0.0
    spec:
      containers:
      - name: service-name
        image: nexus-cos/service-name:latest
        ports:
        - containerPort: 3XXX
          name: http
        env:
        - name: SERVICE_PORT
          value: "3XXX"
        envFrom:
        - configMapRef:
            name: service-name-config
        - secretRef:
            name: service-name-secrets
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /health/live
            port: 3XXX
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 3XXX
          initialDelaySeconds: 15
          periodSeconds: 5
```

### Service Manifest

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-name
  namespace: nexus-cos
spec:
  selector:
    app: service-name
  ports:
  - port: 80
    targetPort: 3XXX
    protocol: TCP
    name: http
  type: ClusterIP
```

## Database Schema

### Tables

```sql
-- Example table structure
CREATE TABLE resource (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

CREATE INDEX idx_resource_name ON resource(name);
```

## Monitoring

### Key Metrics

```promql
# Request rate
rate(http_requests_total{service="service-name"}[5m])

# Error rate
rate(http_requests_total{service="service-name",status=~"5.."}[5m]) / 
rate(http_requests_total{service="service-name"}[5m])

# Latency (p95)
histogram_quantile(0.95, 
  rate(http_request_duration_seconds_bucket{service="service-name"}[5m])
)

# Resource usage
container_memory_usage_bytes{pod=~"service-name.*"}
rate(container_cpu_usage_seconds_total{pod=~"service-name.*"}[5m])
```

### Alerts

- **HighErrorRate**: Error rate > 5% for 5 minutes
- **HighLatency**: P95 latency > 1s for 5 minutes
- **ServiceDown**: Health check failing for 2 minutes
- **HighMemory**: Memory usage > 90% for 5 minutes

## Logging

### Log Format

```json
{
  "timestamp": "2025-12-12T00:00:00.000Z",
  "level": "info",
  "service": "service-name",
  "message": "Request processed",
  "requestId": "uuid",
  "userId": "12345",
  "duration": 45,
  "statusCode": 200
}
```

### Important Logs to Monitor

- Authentication failures
- Database connection errors
- External API timeouts
- Rate limit violations

## Troubleshooting

### Common Issues

#### Issue 1: Service won't start

**Symptoms**: Pod in CrashLoopBackOff

**Possible Causes**:
- Database connection failure
- Missing required environment variables
- Port already in use

**Resolution**:
```bash
# Check logs
kubectl logs -n nexus-cos <pod-name>

# Verify config
kubectl get configmap service-name-config -n nexus-cos -o yaml

# Verify secrets
kubectl get secret service-name-secrets -n nexus-cos -o yaml

# Test database connection
kubectl exec -it <pod-name> -n nexus-cos -- psql $DATABASE_URL -c "SELECT 1"
```

#### Issue 2: High response times

**Symptoms**: P95 latency > 1s

**Possible Causes**:
- Database query optimization needed
- Cache not working
- External API slow

**Resolution**:
```bash
# Check database slow queries
kubectl exec -it postgres-0 -n nexus-cos -- psql -c "
  SELECT query, mean_exec_time, calls
  FROM pg_stat_statements
  WHERE query LIKE '%tablename%'
  ORDER BY mean_exec_time DESC
  LIMIT 10;
"

# Check cache hit rate
redis-cli info stats | grep hit_rate

# Review logs for slow external calls
kubectl logs -n nexus-cos <pod-name> | grep "external_api_call" | grep "duration"
```

## Testing

### Unit Tests

```bash
npm test
```

### Integration Tests

```bash
npm run test:integration
```

### Load Tests

```bash
artillery run load-tests/service-name.yml
```

## Development

### Local Setup

```bash
# Clone repository
git clone https://github.com/nexus-cos/service-name
cd service-name

# Install dependencies
npm install

# Set up environment
cp .env.example .env
# Edit .env with your local configuration

# Run database migrations
npm run migrate

# Start service
npm run dev
```

### API Documentation

Swagger/OpenAPI documentation available at:
- Development: http://localhost:3XXX/api-docs
- Production: https://api.nexuscos.example.com/service-name/docs

## Performance

### Baseline Metrics

- **Throughput**: 1000 requests/second
- **Latency (p50)**: < 50ms
- **Latency (p95)**: < 200ms
- **Error Rate**: < 0.1%

### Scaling Guidelines

- Scale horizontally: Add replicas when CPU > 70%
- Database connections: Max 10 per replica
- Cache aggressively: Cache hit rate should be > 80%

## Security

### Authentication

- All endpoints require JWT authentication
- Admin endpoints require specific role
- API rate limiting: 1000 requests/hour per user

### Data Protection

- Sensitive data encrypted at rest
- PII redacted from logs
- Audit logging for all mutations

## Disaster Recovery

### Backup

- Database: Daily full backup, hourly incremental
- Configuration: Versioned in Git

### Recovery

```bash
# Restore from backup
kubectl exec -it postgres-0 -n nexus-cos -- \
  pg_restore -d dbname /backups/latest.dump

# Redeploy service
kubectl rollout restart deployment/service-name -n nexus-cos
```

## Support

- **Documentation**: https://docs.nexuscos.example.com/services/service-name
- **Team Contact**: owner+team@nexuscos.example.com
- **On-Call**: owner+oncall@nexuscos.example.com

## Change Log

### v1.0.0 (2025-12-12)
- Initial release
- Core functionality implemented
- Production ready

---

**Status**: Production  
**Last Updated**: December 2025  
**Next Review**: March 2026
