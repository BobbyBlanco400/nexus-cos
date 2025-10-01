# 🚀 Nexus COS - Quick Start Guide for 29 Services

## TL;DR - 3 Simple Steps

```bash
# 1. Deploy all 29 services
./deploy-29-services.sh

# 2. Verify deployment
./verify-29-services.sh

# 3. Check status
pm2 list
```

---

## What You Get

### 📦 29 Services Ready to Deploy
- ✅ 3 Core Infrastructure Services
- ✅ 18 PUABO Ecosystem Services
- ✅ 8 Platform Services
- ✅ 1 Specialized Service

### 🎯 Automatic Setup
- ✅ PM2 installation (if not present)
- ✅ Dependency installation for all services
- ✅ Phased deployment (Core → PUABO → Platform → Specialized)
- ✅ Health checks for all services
- ✅ Auto-restart on failure
- ✅ Centralized logging

---

## Prerequisites

### Required
- Node.js v14+ (v20+ recommended)
- npm v6+
- 4GB+ RAM
- Available ports: 3001-3601

### Optional
- Nginx (for reverse proxy)
- SSL certificates (for production)

---

## Deployment Options

### Option 1: Full Automated Deployment (Recommended)
```bash
./deploy-29-services.sh
```

This will:
1. Install PM2 if needed
2. Install dependencies for all 29 services
3. Deploy services in phases
4. Run health checks
5. Save PM2 configuration

**Time**: ~5-10 minutes depending on your system

### Option 2: Manual Phase-by-Phase Deployment
```bash
# Phase 1: Core Infrastructure
pm2 start ecosystem.config.js --only backend-api,ai-service,key-service

# Phase 2: PUABO Core
pm2 start ecosystem.config.js --only puaboai-sdk,puabomusicchain,pv-keys,streamcore,glitch

# Phase 2: PUABO DSP
pm2 start ecosystem.config.js --only puabo-dsp-upload-mgr,puabo-dsp-metadata-mgr,puabo-dsp-streaming-api

# Phase 2: PUABO BLAC
pm2 start ecosystem.config.js --only puabo-blac-loan-processor,puabo-blac-risk-assessment

# Phase 2: PUABO Nexus
pm2 start ecosystem.config.js --only puabo-nexus-ai-dispatch,puabo-nexus-driver-app-backend,puabo-nexus-fleet-manager,puabo-nexus-route-optimizer

# Phase 2: PUABO Nuki
pm2 start ecosystem.config.js --only puabo-nuki-inventory-mgr,puabo-nuki-order-processor,puabo-nuki-product-catalog,puabo-nuki-shipping-service

# Phase 3: Platform Services
pm2 start ecosystem.config.js --only auth-service,content-management,creator-hub,user-auth,kei-ai,nexus-cos-studio-ai,puaboverse,streaming-service

# Phase 4: Specialized
pm2 start ecosystem.config.js --only boom-boom-room-live
```

### Option 3: Individual Service Deployment
```bash
pm2 start ecosystem.config.js --only backend-api
```

---

## Post-Deployment

### 1. Verify All Services
```bash
./verify-29-services.sh
```

Expected output: "29 healthy out of 29 services"

### 2. Check PM2 Status
```bash
pm2 list
```

All services should show "online" status.

### 3. View Logs
```bash
# All logs
pm2 logs

# Specific service
pm2 logs backend-api

# Last 50 lines
pm2 logs --lines 50
```

### 4. Monitor Services
```bash
pm2 monit
```

---

## Service Endpoints

### Health Checks
Every service has a `/health` endpoint:

```bash
curl http://localhost:3001/health  # backend-api
curl http://localhost:3010/health  # ai-service
curl http://localhost:3014/health  # key-service
# ... and so on for all 29 services
```

### Status Information
Every service has a `/status` endpoint:

```bash
curl http://localhost:3001/status  # backend-api
```

---

## Common Tasks

### Restart All Services
```bash
pm2 restart all
```

### Stop All Services
```bash
pm2 stop all
```

### Delete All Services
```bash
pm2 delete all
```

### Restart Specific Service
```bash
pm2 restart backend-api
```

### View Service Logs
```bash
pm2 logs backend-api --lines 100
```

### Check Resource Usage
```bash
pm2 list
```

---

## Nginx Setup (Optional but Recommended)

### 1. Copy Configuration
```bash
sudo cp nginx-29-services.conf /etc/nginx/sites-available/nexus-cos
sudo ln -s /etc/nginx/sites-available/nexus-cos /etc/nginx/sites-enabled/
```

### 2. Test Configuration
```bash
sudo nginx -t
```

### 3. Reload Nginx
```bash
sudo systemctl reload nginx
```

### 4. Access Services via Nginx
```bash
curl http://your-domain.com/api/backend/health
curl http://your-domain.com/api/ai/health
# ... etc
```

---

## Port Reference

### Phase 1: Core Infrastructure
| Service | Port |
|---------|------|
| backend-api | 3001 |
| ai-service | 3010 |
| key-service | 3014 |

### Phase 2: PUABO Ecosystem
| Service Group | Ports |
|---------------|-------|
| Core Platform | 3012-3017 |
| DSP Services | 3211-3213 |
| BLAC Services | 3221-3222 |
| Nexus Services | 3231-3234 |
| Nuki Services | 3241-3244 |

### Phase 3: Platform Services
| Service Group | Ports |
|---------------|-------|
| Core Platform | 3301-3304 |
| AI Services | 3401-3404 |

### Phase 4: Specialized
| Service | Port |
|---------|------|
| boom-boom-room-live | 3601 |

---

## Troubleshooting

### Services Won't Start
```bash
# Check logs
pm2 logs service-name --lines 50

# Check if dependencies are installed
cd services/service-name
npm install
```

### Port Already in Use
```bash
# Find what's using the port
lsof -i :3001

# Kill the process
kill -9 <PID>
```

### Out of Memory
```bash
# Check memory usage
free -h

# Restart services
pm2 restart all
```

### PM2 Not Found
```bash
# Install PM2 globally
npm install -g pm2
```

---

## Production Checklist

Before going to production, ensure:

- [ ] All 29 services are running (`pm2 list` shows 29 online)
- [ ] Health checks pass (`./verify-29-services.sh`)
- [ ] Nginx reverse proxy is configured
- [ ] SSL certificates are installed
- [ ] Firewall rules are configured (allow ports 80, 443)
- [ ] PM2 startup script is enabled (`pm2 startup`)
- [ ] PM2 configuration is saved (`pm2 save`)
- [ ] Log rotation is configured
- [ ] Monitoring is set up
- [ ] Backup strategy is in place

---

## Get Help

### Documentation
- [Full Deployment Guide](./29_SERVICES_DEPLOYMENT.md)
- [Deployment Test Report](./DEPLOYMENT_TEST_REPORT.md)
- [Nginx Configuration](./nginx-29-services.conf)
- [PM2 Ecosystem Config](./ecosystem.config.js)

### Logs Location
```
/home/runner/work/nexus-cos/nexus-cos/logs/
```

### PM2 Commands
```bash
pm2 --help
pm2 list
pm2 logs
pm2 monit
pm2 describe service-name
```

---

## Success!

If you see all 29 services online in `pm2 list`, congratulations! 🎉

You're ready for Beta Launch! 🚀

---

**Need Support?**
- Check logs: `pm2 logs`
- Run health check: `./verify-29-services.sh`
- Review documentation: `29_SERVICES_DEPLOYMENT.md`
