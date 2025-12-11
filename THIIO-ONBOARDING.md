# THIIO Onboarding Guide

## Welcome to Nexus COS

This guide will help you get started with the Nexus COS platform handoff.

## What You're Receiving

- **43 Microservices**: Complete backend infrastructure
- **16 Platform Modules**: Extended functionality modules
- **Full Documentation**: Architecture, deployment, and operations
- **Deployment Automation**: Scripts and CI/CD workflows
- **Kubernetes Configs**: Production-ready manifests

## Quick Start (30 Minutes)

### Step 1: Review Documentation (10 min)
1. Read `PROJECT-OVERVIEW.md` for high-level understanding
2. Review `docs/THIIO-HANDOFF/architecture/architecture-overview.md`
3. Skim through `docs/THIIO-HANDOFF/deployment/deployment-manifest.yaml`

### Step 2: Set Up Local Environment (10 min)
```bash
# Clone the repository
git clone <repository-url>
cd nexus-cos

# Install dependencies
npm install

# Copy environment template
cp .env.example .env

# Edit .env with your configuration
nano .env
```

### Step 3: Start Local Development (10 min)
```bash
# Option 1: Docker Compose (Recommended for first run)
./scripts/run-local.sh

# Option 2: Individual services
cd services/backend-api
npm install
npm run dev
```

## Understanding the Platform

### Architecture
- **API Gateway**: Entry point at `backend-api:3000`
- **Microservices**: 43 independent services
- **Data Layer**: PostgreSQL + Redis + Message Queue
- **Infrastructure**: Kubernetes for orchestration

### Key Services
- `auth-service`: Authentication
- `backend-api`: API Gateway
- `streaming-service-v2`: Video streaming
- `billing-service`: Payments
- `kei-ai`: AI capabilities

### Service Organization
Services are grouped into 9 namespaces:
- nexus-auth (5 services)
- nexus-content (6 services)
- nexus-commerce (4 services)
- nexus-ai (5 services)
- nexus-finance (2 services)
- nexus-logistics (3 services)
- nexus-entertainment (5 services)
- nexus-platform (5 services)
- nexus-specialized (4 services)

## Deployment Options

### Option 1: Local Development
```bash
# Using Docker Compose
docker-compose -f docs/THIIO-HANDOFF/deployment/docker-compose.full.yml up
```

### Option 2: Kubernetes Staging
```bash
# Verify environment
./scripts/verify-env.sh

# Deploy to Kubernetes
./scripts/deploy-k8s.sh

# Monitor deployment
kubectl get pods --all-namespaces
```

### Option 3: Production Deployment
1. Review `docs/THIIO-HANDOFF/deployment/deployment-manifest.yaml`
2. Configure secrets in Kubernetes
3. Run `./scripts/deploy-k8s.sh`
4. Verify with `./scripts/diagnostics.sh`

## Essential Documentation

### Architecture Documentation
- `docs/THIIO-HANDOFF/architecture/architecture-overview.md` - System architecture
- `docs/THIIO-HANDOFF/architecture/service-map.md` - All 43 services
- `docs/THIIO-HANDOFF/architecture/service-dependencies.md` - Dependencies
- `docs/THIIO-HANDOFF/architecture/data-flow.md` - How data flows
- `docs/THIIO-HANDOFF/architecture/api-gateway-map.md` - API routes

### Deployment Documentation
- `docs/THIIO-HANDOFF/deployment/deployment-manifest.yaml` - Deployment config
- `docs/THIIO-HANDOFF/deployment/docker-compose.full.yml` - Docker setup
- `docs/THIIO-HANDOFF/deployment/kubernetes/` - K8s manifests

### Operations Documentation
- `docs/THIIO-HANDOFF/operations/runbook.md` - Day-to-day operations
- `docs/THIIO-HANDOFF/operations/monitoring-guide.md` - Monitoring setup
- `docs/THIIO-HANDOFF/operations/rollback-strategy.md` - Rollback procedures
- `docs/THIIO-HANDOFF/operations/performance-tuning.md` - Performance tips
- `docs/THIIO-HANDOFF/operations/failover-plan.md` - HA and DR

### Service Documentation
- `docs/THIIO-HANDOFF/services/` - Individual service docs (43 files)

### Module Documentation
- `docs/THIIO-HANDOFF/modules/` - Module documentation (16 files)

## Configuration

### Required Environment Variables

Create `.env` file with:
```bash
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/nexus_cos

# Redis
REDIS_URL=redis://localhost:6379

# Authentication
JWT_SECRET=your-secret-key-here

# AWS (for storage)
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret

# Payment Processing
STRIPE_API_KEY=your-stripe-key

# Email
SENDGRID_API_KEY=your-sendgrid-key

# CDN
CDN_URL=https://cdn.example.com

# Blockchain
BLOCKCHAIN_RPC_URL=https://rpc.example.com
```

### Kubernetes Secrets

Configure secrets using:
```bash
# Edit the secrets template
nano docs/THIIO-HANDOFF/deployment/kubernetes/secrets-template.yaml

# Apply secrets
kubectl apply -f docs/THIIO-HANDOFF/deployment/kubernetes/secrets.yaml
```

## Monitoring & Observability

### Access Monitoring Tools
```bash
# Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000

# Logs (ELK)
kubectl port-forward -n monitoring svc/kibana 5601:5601
```

### Key Metrics to Watch
- Request rate and error rate
- Service response times
- Resource utilization (CPU, memory)
- Database connections
- Queue depths

## Common Tasks

### Check Service Health
```bash
# All services
./scripts/diagnostics.sh

# Specific service
kubectl get pods -n nexus-platform
kubectl logs -n nexus-platform deployment/backend-api
```

### Scale a Service
```bash
# Manual scaling
kubectl scale deployment/auth-service --replicas=5 -n nexus-auth
```

### Update a Service
```bash
# Build new image
docker build -t nexus-cos/auth-service:v2.1 ./services/auth-service

# Update deployment
kubectl set image deployment/auth-service auth-service=nexus-cos/auth-service:v2.1 -n nexus-auth
```

### View Logs
```bash
# Recent logs
kubectl logs -n nexus-platform deployment/backend-api --tail=100

# Follow logs
kubectl logs -f -n nexus-platform deployment/backend-api
```

## Troubleshooting

### Service Won't Start
1. Check logs: `kubectl logs <pod-name>`
2. Verify config: `kubectl describe pod <pod-name>`
3. Check dependencies (database, Redis)
4. Review resource limits

### High Error Rate
1. Check service logs for errors
2. Verify database connectivity
3. Check for recent deployments
4. Review monitoring dashboards

### Performance Issues
1. Check resource utilization
2. Review database query performance
3. Check external API response times
4. Consider scaling horizontally

## Getting Help

### Documentation
- Review relevant runbook in `docs/THIIO-HANDOFF/operations/`
- Check service-specific docs in `docs/THIIO-HANDOFF/services/`
- Review architecture docs for understanding dependencies

### Support Channels
- Platform documentation (this repository)
- Operational runbooks
- Architecture diagrams
- Service API documentation

## Next Steps

1. **Week 1**: Familiarize with architecture and services
2. **Week 2**: Deploy to staging environment
3. **Week 3**: Run operational drills (failover, rollback)
4. **Week 4**: Production deployment planning

## Success Checklist

- [ ] Read PROJECT-OVERVIEW.md
- [ ] Reviewed architecture documentation
- [ ] Set up local development environment
- [ ] Successfully ran services locally
- [ ] Deployed to staging Kubernetes cluster
- [ ] Configured monitoring and alerts
- [ ] Tested rollback procedures
- [ ] Reviewed all 43 service docs
- [ ] Reviewed all 16 module docs
- [ ] Practiced incident response procedures
- [ ] Ready for production deployment

## Important Notes

⚠️ **Security**: Never commit secrets to version control
⚠️ **Backups**: Verify backup procedures before production
⚠️ **Monitoring**: Set up alerts before going live
⚠️ **Documentation**: Keep runbooks updated
⚠️ **Testing**: Always test in staging first

## Contact

This platform handoff package was prepared for THIIO.
All necessary documentation and code is included in this package.

---

**Welcome to Nexus COS! 🚀**
