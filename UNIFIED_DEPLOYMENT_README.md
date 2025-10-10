# Nexus COS Unified Deployment Guide

**Status:** ✅ Production Ready  
**Services:** 38 Containerized Services  
**Modules:** 13 Core Modules  
**Infrastructure:** PostgreSQL, Redis, Nginx

---

## 🚀 Quick Start

### 1. Configure Environment

```bash
# Copy environment template
cp .env.pf.example .env.pf

# Edit with your production values
nano .env.pf
```

**Required variables:**
- `DB_PASSWORD` - PostgreSQL password
- `OAUTH_CLIENT_ID` - OAuth client ID
- `OAUTH_CLIENT_SECRET` - OAuth client secret

### 2. Build All Services

```bash
docker compose -f docker-compose.unified.yml build
```

### 3. Start Infrastructure

```bash
# Start database and cache first
docker compose -f docker-compose.unified.yml up -d nexus-cos-postgres nexus-cos-redis

# Wait for health checks
sleep 10
```

### 4. Start All Services

```bash
docker compose -f docker-compose.unified.yml up -d
```

### 5. Verify Deployment

```bash
# Check service status
docker compose -f docker-compose.unified.yml ps

# Run health checks
bash pf-health-check.sh

# View logs
docker compose -f docker-compose.unified.yml logs --tail=50
```

---

## 📊 Service Architecture

### Infrastructure (2 services)
- **nexus-cos-postgres** - PostgreSQL 15 Database
- **nexus-cos-redis** - Redis 7 Cache

### Core API (2 services)
- **puabo-api** - Main API Gateway (Port 4000)
- **backend-api** - Backend API Service (Port 3001)

### AI & SDK Services (4 services)
- **puaboai-sdk** - AI SDK Service (Port 3002)
- **ai-service** - General AI Service (Port 3003)
- **kei-ai** - KEI AI Service (Port 3009)
- **nexus-studio-ai** - Studio AI (Port 3011)

### Authentication (3 services)
- **auth-service** - Main Auth Service (Port 3080)
- **pv-keys** - Key Management (Port 3041)
- **key-service** - Key Service (Port 3010)

### V-Suite - Virtual Production (5 services)
- **streamcore** - Streaming Engine (Port 3016)
- **vscreen-hollywood** - Virtual Production (Port 8088)
- **v-caster-pro** - Broadcasting (Port 3012)
- **v-prompter-pro** - Teleprompter (Port 3013)
- **v-screen-pro** - Screen Management (Port 3014)

### PUABO NEXUS - Fleet Management (4 services)
- **puabo-nexus-ai-dispatch** - AI Dispatch (Port 3231)
- **puabo-nexus-driver-app** - Driver Backend (Port 3232)
- **puabo-nexus-fleet-manager** - Fleet Management (Port 3233)
- **puabo-nexus-route-optimizer** - Route Optimization (Port 3234)

### PUABO DSP - Digital Service Provider (3 services)
- **puabo-dsp-metadata** - Metadata Manager (Port 3030)
- **puabo-dsp-streaming** - Streaming API (Port 3031)
- **puabo-dsp-upload** - Upload Manager (Port 3032)

### PUABO BLAC - Business Loans (2 services)
- **puabo-blac-loan** - Loan Processor (Port 3020)
- **puabo-blac-risk** - Risk Assessment (Port 3021)

### PUABO NUKI - E-Commerce (4 services)
- **puabo-nuki-inventory** - Inventory (Port 3040)
- **puabo-nuki-orders** - Order Processing (Port 3041)
- **puabo-nuki-catalog** - Product Catalog (Port 3042)
- **puabo-nuki-shipping** - Shipping Service (Port 3043)

### Platform Services (7 services)
- **content-management** - CMS (Port 3006)
- **creator-hub** - Creator Platform (Port 3007)
- **musicchain** - Music Blockchain (Port 3050)
- **puaboverse** - Social Platform (Port 3060)
- **streaming-service** - Streaming (Port 3070)
- **boom-boom-room** - Live Events (Port 3005)
- **glitch** - Glitch Service (Port 3008)
- **scheduler** - Task Scheduler (Port 3090)

### Web Gateway (1 service)
- **nginx** - Reverse Proxy (Ports 80/443)

**Total: 38 Services**

---

## 🔧 Management Commands

### View Service Status
```bash
docker compose -f docker-compose.unified.yml ps
```

### View Logs
```bash
# All services
docker compose -f docker-compose.unified.yml logs -f

# Specific service
docker compose -f docker-compose.unified.yml logs -f puabo-api

# Last 100 lines
docker compose -f docker-compose.unified.yml logs --tail=100
```

### Restart Services
```bash
# All services
docker compose -f docker-compose.unified.yml restart

# Specific service
docker compose -f docker-compose.unified.yml restart puabo-api
```

### Stop Services
```bash
# All services
docker compose -f docker-compose.unified.yml down

# Keep volumes
docker compose -f docker-compose.unified.yml down --volumes
```

### Scale Services
```bash
# Scale specific service
docker compose -f docker-compose.unified.yml up -d --scale puabo-api=3
```

### Update Services
```bash
# Rebuild and restart
docker compose -f docker-compose.unified.yml up -d --build

# Pull latest images
docker compose -f docker-compose.unified.yml pull
```

---

## 🏥 Health Checks

### Automated Health Check
```bash
bash pf-health-check.sh
```

### Manual Health Checks

**Infrastructure:**
```bash
# PostgreSQL
docker compose -f docker-compose.unified.yml exec nexus-cos-postgres pg_isready

# Redis
docker compose -f docker-compose.unified.yml exec nexus-cos-redis redis-cli ping
```

**Core Services:**
```bash
curl http://localhost:4000/health  # Main API
curl http://localhost:3002/health  # AI SDK
curl http://localhost:3041/health  # PV Keys
curl http://localhost:3016/health  # StreamCore
curl http://localhost:8088/health  # V-Screen Hollywood
```

**PUABO NEXUS Fleet:**
```bash
curl http://localhost:3231/health  # AI Dispatch
curl http://localhost:3232/health  # Driver App
curl http://localhost:3233/health  # Fleet Manager
curl http://localhost:3234/health  # Route Optimizer
```

---

## 🐛 Troubleshooting

### Service Won't Start

1. **Check logs:**
```bash
docker compose -f docker-compose.unified.yml logs <service-name>
```

2. **Check environment variables:**
```bash
docker compose -f docker-compose.unified.yml exec <service-name> env
```

3. **Rebuild service:**
```bash
docker compose -f docker-compose.unified.yml build --no-cache <service-name>
docker compose -f docker-compose.unified.yml up -d <service-name>
```

### Port Conflicts

**List used ports:**
```bash
docker compose -f docker-compose.unified.yml ps --format json | jq -r '.[].Publishers[].PublishedPort' | sort -n
```

**Check port availability:**
```bash
netstat -tulpn | grep <port>
```

### Database Connection Issues

1. **Verify database is running:**
```bash
docker compose -f docker-compose.unified.yml ps nexus-cos-postgres
```

2. **Check database logs:**
```bash
docker compose -f docker-compose.unified.yml logs nexus-cos-postgres
```

3. **Test connection:**
```bash
docker compose -f docker-compose.unified.yml exec nexus-cos-postgres \
  psql -U nexus_user -d nexus_db -c "SELECT 1;"
```

### Network Issues

1. **List networks:**
```bash
docker network ls | grep cos
```

2. **Inspect network:**
```bash
docker network inspect cos-net
```

3. **Recreate network:**
```bash
docker compose -f docker-compose.unified.yml down
docker network rm cos-net
docker compose -f docker-compose.unified.yml up -d
```

---

## 📈 Monitoring

### Resource Usage
```bash
# All services
docker stats

# Specific service
docker stats <container-name>
```

### Disk Usage
```bash
# Volume usage
docker system df -v

# Clean up
docker system prune -a --volumes
```

---

## 🔐 Security

### Environment Variables
- Never commit `.env.pf` to version control
- Use strong passwords for database and Redis
- Rotate OAuth credentials regularly

### SSL Certificates
Place SSL certificates in `ssl/` directory:
```
ssl/
├── fullchain.pem
└── private.key
```

### Network Security
- Use Docker network isolation (`cos-net`)
- Expose only necessary ports
- Use Nginx reverse proxy for external access

---

## 📚 Additional Resources

- **Main Guide:** `NEXUS_COS_V2025_UNIFIED_BUILD_GUIDE.md`
- **PF Documentation:** `PF_BULLETPROOF_README.md`
- **PF Specification:** `nexus-cos-pf-v2025.10.01.yaml`
- **Health Checks:** `PF_v2025.10.01_HEALTH_CHECKS.md`

---

## 🎯 Validation Checklist

- [ ] Environment variables configured (`.env.pf`)
- [ ] SSL certificates in place (`ssl/`)
- [ ] Docker and Docker Compose installed
- [ ] Port 80, 443 available for Nginx
- [ ] PostgreSQL password set
- [ ] OAuth credentials configured
- [ ] All services build successfully
- [ ] Health checks pass
- [ ] No port conflicts
- [ ] Network connectivity verified

---

## 🧠 Nexus COS v2025 Final Unified Build

**Author:** Bobby Blanco  
**Vision:** The World's First Creative Operating System  
**Status:** ✅ Production Ready

**Total Services:** 38  
**Total Modules:** 13  
**Infrastructure:** PostgreSQL, Redis, Nginx  
**Network:** cos-net (Docker bridge)
