# puabo-nexus-ai-dispatch

## Overview

**Service Name**: puabo-nexus-ai-dispatch
**Port**: 3034
**Purpose**: AI dispatch

## Description

AI-powered dispatch system

## Endpoints

### Health Check
- `GET /health` - Service health status
- `GET /health/ready` - Readiness probe
- `GET /health/live` - Liveness probe

### Metrics
- `GET /metrics` - Prometheus metrics

## Configuration

### Environment Variables
- `PORT` - Service port (default: 3034)
- `DATABASE_URL` - Database connection string
- `REDIS_URL` - Redis connection string
- `LOG_LEVEL` - Logging level (debug, info, warn, error)

### Resource Requirements
- **CPU**: Varies by load
- **Memory**: See deployment manifest
- **Storage**: Depends on data volume

## Dependencies

### Internal Services
- Depends on specific services per architecture

### External Dependencies
- PostgreSQL database
- Redis cache
- Message queue (RabbitMQ)

## API Documentation

Detailed API documentation available via OpenAPI/Swagger at `/api-docs`

## Deployment

Deploy using Kubernetes manifests in `docs/THIIO-HANDOFF/deployment/kubernetes/`

## Monitoring

- Prometheus metrics exposed on `/metrics`
- Logs sent to centralized logging system
- Health checks configured for K8s

## Security

- JWT-based authentication
- TLS encryption in transit
- Secrets managed via Kubernetes secrets

## Troubleshooting

### Common Issues
1. **Connection errors**: Check database and Redis connectivity
2. **Performance issues**: Review resource allocation
3. **Authentication failures**: Verify JWT secret configuration

### Logs
Access logs via:
```bash
kubectl logs -n <namespace> deployment/puabo-nexus-ai-dispatch
```

## Contact

For support, refer to operational runbooks in `docs/THIIO-HANDOFF/operations/`
