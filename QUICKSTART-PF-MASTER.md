# NΞ3XUS·COS PF-MASTER v3.0 Quick Start Guide

## 🚀 5-Minute Quick Start

### Prerequisites Check
```bash
# Check Docker
docker --version

# Check Docker Compose
docker-compose --version

# OR Check Kubernetes
kubectl version
helm version
```

### Step 1: Clone & Setup
```bash
# Clone repository
git clone https://github.com/BobbyBlanco400/nexus-cos.git
cd nexus-cos

# Copy environment file
cp .env.pf-master.example .env

# Edit .env with your passwords
nano .env  # or vim, code, etc.
```

### Step 2: Choose Deployment Mode

#### Option A: Docker Compose (Fastest)
```bash
# Start all services
docker-compose -f docker-compose.pf-master.yml up -d

# Check status
docker-compose -f docker-compose.pf-master.yml ps

# View logs
docker-compose -f docker-compose.pf-master.yml logs -f

# Verify deployment
./scripts/verify-all.sh
```

#### Option B: One-Command Execution
```bash
# Execute complete PF-MASTER
./execute-pf-master.sh

# This will:
# 1. Deploy Tier 0 (Foundation)
# 2. Deploy Tier 1 (Economic Core)
# 3. Deploy Tier 2 (Platform Services)
# 4. Deploy Tier 3 (Streaming)
# 5. Deploy Tier 4 (Gaming)
# 6. Enable autoscaling
# 7. Apply cost governance
# 8. Generate investor deck
# 9. Run full verification
```

#### Option C: Kubernetes/Helm
```bash
# Create namespaces
kubectl apply -f k8s/namespaces/

# Deploy via Helm
helm install nexus-cos ./helm/nexus-cos \
  --namespace nexus-core \
  --create-namespace \
  --values helm/nexus-cos/values.yaml

# Check pods
kubectl get pods --all-namespaces | grep nexus

# Verify
./scripts/verify-all.sh
```

### Step 3: Verify Deployment

```bash
# Check all tiers
./scripts/verify-tier.sh 0  # Foundation
./scripts/verify-tier.sh 1  # Economic
./scripts/verify-tier.sh 2  # Platform
./scripts/verify-tier.sh 3  # Streaming
./scripts/verify-tier.sh 4  # Gaming

# Check ledger enforcement (20% platform fee)
./scripts/verify-ledger.sh

# Full system check
./scripts/verify-all.sh
```

### Step 4: Access Services

#### Health Check Endpoints
```bash
# Backend API
curl http://localhost:3000/health

# Auth Service
curl http://localhost:3001/auth/health

# Ledger Manager
curl http://localhost:4000/ledger/health

# Streaming Service
curl http://localhost:6000/streaming/health

# Casino Nexus
curl http://localhost:7003/casino/health
```

#### Web Interfaces
- Main Platform: http://localhost:3000
- Admin Dashboard: http://localhost:3000/admin
- Monitoring: http://localhost:9090 (if Prometheus enabled)

## 📊 Common Operations

### View Logs
```bash
# Docker
docker-compose -f docker-compose.pf-master.yml logs -f [service-name]

# Kubernetes
kubectl logs -f deployment/[service-name] -n [namespace]
```

### Scale Services
```bash
# Docker
docker-compose -f docker-compose.pf-master.yml up -d --scale streaming-service-v2=10

# Kubernetes (automatic via HPA)
kubectl get hpa --all-namespaces
```

### Stop Services
```bash
# Docker
docker-compose -f docker-compose.pf-master.yml down

# Kubernetes
helm uninstall nexus-cos -n nexus-core
```

### Restart Services
```bash
# Docker
docker-compose -f docker-compose.pf-master.yml restart [service-name]

# Kubernetes
kubectl rollout restart deployment/[service-name] -n [namespace]
```

## 🔧 Troubleshooting

### Service Won't Start
```bash
# Check logs
docker logs [container-name]

# Check resources
docker stats

# Verify environment variables
docker-compose -f docker-compose.pf-master.yml config
```

### Database Connection Issues
```bash
# Test PostgreSQL
docker exec nexus-postgres pg_isready -U nexus

# Test Redis
docker exec nexus-redis redis-cli ping

# Check network
docker network inspect nexus_net
```

### Port Conflicts
```bash
# Check what's using ports
sudo lsof -i :3000
sudo lsof -i :5432

# Change ports in .env or docker-compose file
```

## 📚 Next Steps

1. **Configure SSL**: Add certificates to `./ssl/` directory
2. **Set up monitoring**: Enable Prometheus/Grafana
3. **Configure backups**: Set up automated database backups
4. **Review logs**: Check for any warnings or errors
5. **Performance tuning**: Adjust resource limits based on load

## 🆘 Need Help?

- Documentation: [PF-MASTER-README.md](./PF-MASTER-README.md)
- Issues: https://github.com/BobbyBlanco400/nexus-cos/issues
- Website: https://n3xuscos.online

## ✅ Success Indicators

- ✅ All health checks passing
- ✅ 0 unhealthy containers
- ✅ Ledger service enforcing 20% fee
- ✅ All namespaces created (Kubernetes)
- ✅ HPA configured and active
- ✅ No errors in logs

**Platform is operational when all tiers verify successfully!**
