# v-SuperCore Deployment Guide

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Local Development](#local-development)
4. [Production Deployment](#production-deployment)
5. [Kubernetes Deployment](#kubernetes-deployment)
6. [Configuration](#configuration)
7. [Monitoring](#monitoring)
8. [Troubleshooting](#troubleshooting)
9. [Security](#security)
10. [Maintenance](#maintenance)

## Overview

This guide covers deploying v-SuperCore, the world's first fully virtualized Super PC platform, from local development to production Kubernetes clusters.

### Deployment Options

- **Local Development**: Docker Compose for testing
- **Staging**: Single-node Kubernetes
- **Production**: Multi-region Kubernetes clusters

### Architecture

```
                    ┌─────────────────────┐
                    │   Load Balancer     │
                    └──────────┬──────────┘
                               │
                    ┌──────────┴──────────┐
                    │  v-Stream Gateway   │
                    └──────────┬──────────┘
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                    │
    ┌─────┴──────┐      ┌─────┴──────┐      ┌─────┴──────┐
    │ Orchestrator│      │ Orchestrator│      │ Orchestrator│
    └─────┬──────┘      └─────┬──────┘      └─────┬──────┘
          │                    │                    │
    ┌─────┴───────────────────┴────────────────────┴─────┐
    │              Session Pool (StatefulSet)            │
    │    ┌────┐  ┌────┐  ┌────┐  ┌────┐  ┌────┐        │
    │    │Pod │  │Pod │  │Pod │  │Pod │  │Pod │  ...   │
    │    └────┘  └────┘  └────┘  └────┘  └────┘        │
    └────────────────────────────────────────────────────┘
```

## Prerequisites

### Required Software

- **Docker**: >= 20.10
- **Docker Compose**: >= 2.0 (for local dev)
- **Kubernetes**: >= 1.24 (for production)
- **kubectl**: >= 1.24
- **Helm**: >= 3.10 (optional)

### System Requirements

**Development:**
- 8 GB RAM
- 4 CPU cores
- 50 GB disk space

**Production (per node):**
- 64 GB RAM
- 16 CPU cores
- 500 GB SSD
- 10 Gbps network

### Access Requirements

- N3XUS account with admin privileges
- Docker registry credentials
- Kubernetes cluster access
- SSL certificates
- DNS configuration

## Local Development

### Step 1: Clone Repository

```bash
git clone https://github.com/BobbyBlanco400/nexus-cos.git
cd nexus-cos
```

### Step 2: Configure Environment

```bash
# Copy example environment file
cp services/v-supercore/.env.example services/v-supercore/.env

# Edit configuration
nano services/v-supercore/.env
```

Required variables:
```env
NODE_ENV=development
POSTGRES_PASSWORD=your_secure_password
REDIS_PASSWORD=your_secure_password
JWT_SECRET=your_jwt_secret
```

### Step 3: Start Services

```bash
# Start all services
docker-compose -f docker-compose.v-supercore.yml up -d

# View logs
docker-compose -f docker-compose.v-supercore.yml logs -f

# Check status
docker-compose -f docker-compose.v-supercore.yml ps
```

### Step 4: Verify Installation

```bash
# Health check
curl http://localhost:8080/health

# Expected response
{
  "status": "ok",
  "service": "v-supercore",
  "version": "1.0.0",
  "handshake": "55-45-17"
}
```

### Step 5: Access Dashboards

- **API**: http://localhost:8080
- **Metrics**: http://localhost:9091/metrics
- **Prometheus**: http://localhost:9092
- **Grafana**: http://localhost:3005 (admin/admin)

## Production Deployment

### Pre-Deployment Checklist

- [ ] Kubernetes cluster provisioned
- [ ] DNS records configured
- [ ] SSL certificates obtained
- [ ] Docker images built and pushed
- [ ] Database configured
- [ ] Redis cluster configured
- [ ] Monitoring stack ready
- [ ] Backup strategy defined

### Step 1: Prepare Infrastructure

```bash
# Create namespace
kubectl create namespace v-supercore

# Label namespace
kubectl label namespace v-supercore \
  app.kubernetes.io/name=v-supercore \
  app.kubernetes.io/part-of=nexus-vcos \
  nexus.handshake=55-45-17
```

### Step 2: Configure Secrets

```bash
# Database credentials
kubectl create secret generic v-supercore-db \
  --from-literal=host=postgres.n3xuscos.online \
  --from-literal=database=nexus_vcos \
  --from-literal=username=nexus_user \
  --from-literal=password=SECURE_PASSWORD \
  --namespace=v-supercore

# Application secrets
kubectl create secret generic v-supercore-app \
  --from-literal=jwt-secret=SECURE_JWT_SECRET \
  --from-literal=redis-password=SECURE_REDIS_PASSWORD \
  --namespace=v-supercore

# SSL certificates
kubectl create secret tls v-supercore-tls \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key \
  --namespace=v-supercore
```

### Step 3: Deploy Services

```bash
# Option 1: Use deployment script (recommended)
./scripts/deploy-v-supercore.sh

# Option 2: Manual deployment
kubectl apply -f k8s/v-supercore/namespace.yaml
kubectl apply -f k8s/v-supercore/orchestrator-deployment.yaml
kubectl apply -f k8s/v-supercore/session-pool-statefulset.yaml
kubectl apply -f k8s/v-supercore/v-stream-deployment.yaml
```

### Step 4: Verify Deployment

```bash
# Check pod status
kubectl get pods -n v-supercore

# Expected output
NAME                                      READY   STATUS    RESTARTS   AGE
v-supercore-orchestrator-xxx              1/1     Running   0          2m
v-stream-gateway-xxx                      1/1     Running   0          2m
v-supercore-session-pool-0                1/1     Running   0          2m
v-supercore-session-pool-1                1/1     Running   0          2m

# Check services
kubectl get services -n v-supercore

# Check ingress
kubectl get ingress -n v-supercore
```

### Step 5: Configure Load Balancer

```bash
# Get load balancer IP
kubectl get service v-stream-gateway -n v-supercore

# Update DNS records
# A record: supercore.n3xuscos.online -> LOAD_BALANCER_IP
# A record: stream.n3xuscos.online -> LOAD_BALANCER_IP
```

### Step 6: Test Production Deployment

```bash
# Health check
curl https://api.n3xuscos.online/v1/supercore/health

# Create test session
curl -X POST https://api.n3xuscos.online/v1/supercore/sessions/create \
  -H "X-N3XUS-Handshake: 55-45-17" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tier": "basic"}'
```

## Kubernetes Deployment

### Helm Chart (Optional)

```bash
# Add Helm repository
helm repo add nexus-cos https://charts.n3xuscos.online
helm repo update

# Install chart
helm install v-supercore nexus-cos/v-supercore \
  --namespace v-supercore \
  --create-namespace \
  --values values-production.yaml

# Upgrade
helm upgrade v-supercore nexus-cos/v-supercore \
  --namespace v-supercore \
  --values values-production.yaml
```

### Multi-Region Deployment

```bash
# Deploy to multiple regions
for region in us-east us-west eu-west asia-east; do
  kubectl apply -f k8s/v-supercore/ --context=${region}
done

# Configure global load balancer
kubectl apply -f k8s/v-supercore/global-lb.yaml
```

## Configuration

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `NODE_ENV` | Environment | `production` | Yes |
| `PORT` | API port | `8080` | No |
| `LOG_LEVEL` | Log level | `info` | No |
| `POSTGRES_HOST` | Database host | - | Yes |
| `POSTGRES_PORT` | Database port | `5432` | No |
| `POSTGRES_DB` | Database name | `nexus_vcos` | Yes |
| `POSTGRES_USER` | Database user | - | Yes |
| `POSTGRES_PASSWORD` | Database password | - | Yes |
| `REDIS_HOST` | Redis host | - | Yes |
| `REDIS_PORT` | Redis port | `6379` | No |
| `REDIS_PASSWORD` | Redis password | - | No |
| `JWT_SECRET` | JWT signing secret | - | Yes |
| `CORS_ORIGIN` | CORS origin | `*` | No |

### Resource Limits

```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 2000m
    memory: 4Gi
```

### Auto-Scaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 50
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
```

## Monitoring

### Prometheus

```bash
# Access Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090
```

Key metrics:
- `v_supercore_active_sessions`
- `v_supercore_resource_allocation_cpu`
- `v_supercore_resource_allocation_memory`
- `http_request_duration_seconds`

### Grafana

```bash
# Access Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000
```

Pre-built dashboards:
- v-SuperCore Overview
- Session Metrics
- Resource Utilization
- Streaming Performance

### Alerts

Configure alerts for:
- High CPU/memory usage (>80%)
- Session creation failures (>5%)
- API errors (>1%)
- Latency spikes (>100ms)
- Pod restarts (>3 in 5min)

## Troubleshooting

### Pods Not Starting

```bash
# Check pod events
kubectl describe pod POD_NAME -n v-supercore

# Check logs
kubectl logs POD_NAME -n v-supercore

# Common issues:
# - Image pull errors
# - Secret not found
# - Resource constraints
```

### Database Connection Issues

```bash
# Test connection
kubectl run -it --rm debug --image=postgres:15 --restart=Never -- \
  psql -h POSTGRES_HOST -U nexus_user -d nexus_vcos

# Check credentials
kubectl get secret v-supercore-db -n v-supercore -o yaml
```

### High Latency

```bash
# Check network policies
kubectl get networkpolicy -n v-supercore

# Check service mesh
kubectl get virtualservice -n v-supercore

# Test connectivity
kubectl exec -it POD_NAME -n v-supercore -- ping DESTINATION
```

### Session Creation Failures

```bash
# Check orchestrator logs
kubectl logs deployment/v-supercore-orchestrator -n v-supercore --tail=100

# Check Kubernetes API access
kubectl get pod -n v-supercore

# Verify resource quotas
kubectl describe resourcequota -n v-supercore
```

## Security

### Network Policies

```bash
# Apply network policies
kubectl apply -f k8s/v-supercore/network-policy.yaml
```

### RBAC

```bash
# Create service account
kubectl apply -f k8s/v-supercore/rbac.yaml
```

### Pod Security

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
```

### Secrets Management

Use external secrets manager:
- AWS Secrets Manager
- Azure Key Vault
- HashiCorp Vault
- Google Secret Manager

## Maintenance

### Backup

```bash
# Backup database
kubectl exec -n v-supercore postgres-pod -- \
  pg_dump nexus_vcos > backup-$(date +%Y%m%d).sql

# Backup PVCs
kubectl get pvc -n v-supercore
velero backup create v-supercore-backup --include-namespaces=v-supercore
```

### Updates

```bash
# Update image
kubectl set image deployment/v-supercore-orchestrator \
  orchestrator=nexus-cos/v-supercore-orchestrator:v1.1.0 \
  -n v-supercore

# Rollout status
kubectl rollout status deployment/v-supercore-orchestrator -n v-supercore

# Rollback
kubectl rollout undo deployment/v-supercore-orchestrator -n v-supercore
```

### Scaling

```bash
# Scale manually
kubectl scale deployment v-supercore-orchestrator --replicas=5 -n v-supercore

# Scale statefulset
kubectl scale statefulset v-supercore-session-pool --replicas=20 -n v-supercore
```

### Cleanup

```bash
# Delete all resources
kubectl delete namespace v-supercore

# Or use script
./scripts/cleanup-v-supercore.sh
```

## Support

- **Documentation**: https://docs.n3xuscos.online/v-supercore
- **Issues**: https://github.com/BobbyBlanco400/nexus-cos/issues
- **Email**: support@n3xuscos.online
- **Discord**: https://discord.gg/nexuscos

---

**Version**: 1.0.0-alpha  
**Last Updated**: January 12, 2026  
**Next Review**: February 12, 2026
