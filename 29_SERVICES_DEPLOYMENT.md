# 🚀 Nexus COS - 29 Services Deployment Guide

## Executive Summary
This document provides complete instructions for deploying all 29 services in the Nexus-COS ecosystem for Beta Launch.

## Service Portfolio

### Phase 1: Core Infrastructure Services (3 services)
| Service | Port | Description | Priority |
|---------|------|-------------|----------|
| backend-api | 3001 | Main API gateway | CRITICAL |
| ai-service | 3010 | AI orchestration | CRITICAL |
| key-service | 3014 | Authentication service | CRITICAL |

### Phase 2: PUABO Ecosystem Services (18 services)

#### PUABO Core Platform (5 services)
| Service | Port | Description |
|---------|------|-------------|
| puaboai-sdk | 3012 | AI SDK service |
| puabomusicchain | 3013 | Music blockchain service |
| pv-keys | 3015 | Private key management |
| streamcore | 3016 | Streaming core engine |
| glitch | 3017 | Glitch processing service |

#### PUABO-DSP Services (3 services)
| Service | Port | Description |
|---------|------|-------------|
| puabo-dsp-upload-mgr | 3211 | Upload management |
| puabo-dsp-metadata-mgr | 3212 | Metadata processing |
| puabo-dsp-streaming-api | 3213 | Streaming API |

#### PUABO-BLAC Services (2 services)
| Service | Port | Description |
|---------|------|-------------|
| puabo-blac-loan-processor | 3221 | Loan processing |
| puabo-blac-risk-assessment | 3222 | Risk analysis |

#### PUABO-Nexus Services (4 services)
| Service | Port | Description |
|---------|------|-------------|
| puabo-nexus-ai-dispatch | 3231 | AI dispatch system |
| puabo-nexus-driver-app-backend | 3232 | Driver backend |
| puabo-nexus-fleet-manager | 3233 | Fleet management |
| puabo-nexus-route-optimizer | 3234 | Route optimization |

#### PUABO-Nuki Services (4 services)
| Service | Port | Description |
|---------|------|-------------|
| puabo-nuki-inventory-mgr | 3241 | Inventory management |
| puabo-nuki-order-processor | 3242 | Order processing |
| puabo-nuki-product-catalog | 3243 | Product catalog |
| puabo-nuki-shipping-service | 3244 | Shipping service |

### Phase 3: Platform Services (8 services)
| Service | Port | Description |
|---------|------|-------------|
| auth-service | 3301 | Authentication service |
| content-management | 3302 | Content management |
| creator-hub | 3303 | Creator tools |
| user-auth | 3304 | User authentication |
| kei-ai | 3401 | KEI AI service |
| nexus-cos-studio-ai | 3402 | Studio AI |
| puaboverse | 3403 | Puaboverse platform |
| streaming-service | 3404 | Streaming service |

### Phase 4: Specialized Services (1 service)
| Service | Port | Description |
|---------|------|-------------|
| boom-boom-room-live | 3601 | Live entertainment |

---

## Quick Start

### 1. Deploy All Services
```bash
./deploy-29-services.sh
```

### 2. Verify Deployment
```bash
./verify-29-services.sh
```

### 3. View Service Status
```bash
pm2 list
```

---

## Detailed Deployment Instructions

### Prerequisites
- Node.js v14 or higher
- PM2 process manager (installed automatically by script)
- Sufficient memory (recommend 8GB+ RAM)
- Available ports: 3001-3601

### Step 1: Run Deployment Script
```bash
cd /home/runner/work/nexus-cos/nexus-cos
./deploy-29-services.sh
```

The script will:
1. ✅ Install PM2 if not present
2. ✅ Create logs directory
3. ✅ Install dependencies for all services
4. ✅ Deploy services in phases
5. ✅ Verify all services are running
6. ✅ Run health checks
7. ✅ Save PM2 configuration

### Step 2: Verify Deployment
```bash
# Quick verification
./verify-29-services.sh

# Detailed status
pm2 list

# View logs
pm2 logs

# Monitor in real-time
pm2 monit
```

---

## Service Management

### Start All Services
```bash
pm2 start ecosystem.config.js
```

### Start Specific Phase
```bash
# Phase 1 - Core Infrastructure
pm2 start ecosystem.config.js --only backend-api,ai-service,key-service

# Phase 2 - PUABO Core
pm2 start ecosystem.config.js --only puaboai-sdk,puabomusicchain,pv-keys,streamcore,glitch
```

### Stop Services
```bash
# Stop all
pm2 stop all

# Stop specific service
pm2 stop backend-api
```

### Restart Services
```bash
# Restart all
pm2 restart all

# Restart specific service
pm2 restart backend-api
```

### Delete Services
```bash
# Delete all
pm2 delete all

# Delete specific service
pm2 delete backend-api
```

---

## Nginx Configuration

### Install Nginx Configuration
```bash
sudo cp nginx-29-services.conf /etc/nginx/sites-available/nexus-cos
sudo ln -s /etc/nginx/sites-available/nexus-cos /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### API Routes
All services are accessible via the following routes:

**Phase 1: Core Infrastructure**
- `/api/backend/` → backend-api (3001)
- `/api/ai/` → ai-service (3010)
- `/api/keys/` → key-service (3014)

**Phase 2: PUABO Ecosystem**
- `/api/puabo/sdk/` → puaboai-sdk (3012)
- `/api/puabo/musicchain/` → puabomusicchain (3013)
- `/api/puabo/pv-keys/` → pv-keys (3015)
- `/api/puabo/streamcore/` → streamcore (3016)
- `/api/puabo/glitch/` → glitch (3017)
- `/api/puabo-dsp/upload/` → puabo-dsp-upload-mgr (3211)
- `/api/puabo-dsp/metadata/` → puabo-dsp-metadata-mgr (3212)
- `/api/puabo-dsp/streaming/` → puabo-dsp-streaming-api (3213)
- `/api/puabo-blac/loans/` → puabo-blac-loan-processor (3221)
- `/api/puabo-blac/risk/` → puabo-blac-risk-assessment (3222)
- `/api/puabo-nexus/dispatch/` → puabo-nexus-ai-dispatch (3231)
- `/api/puabo-nexus/driver/` → puabo-nexus-driver-app-backend (3232)
- `/api/puabo-nexus/fleet/` → puabo-nexus-fleet-manager (3233)
- `/api/puabo-nexus/routes/` → puabo-nexus-route-optimizer (3234)
- `/api/puabo-nuki/inventory/` → puabo-nuki-inventory-mgr (3241)
- `/api/puabo-nuki/orders/` → puabo-nuki-order-processor (3242)
- `/api/puabo-nuki/catalog/` → puabo-nuki-product-catalog (3243)
- `/api/puabo-nuki/shipping/` → puabo-nuki-shipping-service (3244)

**Phase 3: Platform Services**
- `/api/auth/` → auth-service (3301)
- `/api/content/` → content-management (3302)
- `/api/creator/` → creator-hub (3303)
- `/api/user-auth/` → user-auth (3304)
- `/api/kei-ai/` → kei-ai (3401)
- `/api/studio-ai/` → nexus-cos-studio-ai (3402)
- `/api/puaboverse/` → puaboverse (3403)
- `/api/streaming/` → streaming-service (3404)

**Phase 4: Specialized Services**
- `/api/boom/` → boom-boom-room-live (3601)

---

## Health Checks

### Individual Service Health Check
```bash
curl http://localhost:3001/health  # backend-api
curl http://localhost:3010/health  # ai-service
# ... etc for all services
```

### All Services Health Check
```bash
./verify-29-services.sh
```

### Expected Health Response
```json
{
  "status": "ok",
  "service": "service-name",
  "port": 3001,
  "timestamp": "2024-01-01T00:00:00.000Z",
  "version": "1.0.0"
}
```

---

## Troubleshooting

### Service Won't Start
```bash
# Check logs
pm2 logs service-name --lines 50

# Check if port is in use
lsof -i :3001

# Restart service
pm2 restart service-name
```

### Port Conflicts
```bash
# Find process using port
lsof -i :3001

# Kill process if needed
kill -9 <PID>
```

### Memory Issues
```bash
# Check memory usage
pm2 list
free -h

# Increase max memory restart limit in ecosystem.config.js
max_memory_restart: '1G'
```

### Logs Location
All logs are stored in: `/home/runner/work/nexus-cos/nexus-cos/logs/`

View logs:
```bash
# All logs
pm2 logs

# Specific service
pm2 logs backend-api

# Error logs only
pm2 logs --err

# Last 100 lines
pm2 logs --lines 100
```

---

## Monitoring

### Real-time Monitoring
```bash
pm2 monit
```

### Process Information
```bash
# List all processes
pm2 list

# Detailed info for specific service
pm2 show backend-api

# Get JSON output
pm2 jlist
```

### Resource Usage
```bash
# CPU and Memory usage
pm2 list

# Detailed metrics
pm2 describe backend-api
```

---

## Scaling Services

### Increase Instances (Cluster Mode)
Edit `ecosystem.config.js`:
```javascript
{
  name: 'backend-api',
  instances: 4,  // Change from 1 to 4
  exec_mode: 'cluster'
}
```

Then reload:
```bash
pm2 reload ecosystem.config.js
```

### Scale Specific Service
```bash
pm2 scale backend-api 4
```

---

## Backup and Recovery

### Save Current Configuration
```bash
pm2 save
```

### Restore Configuration
```bash
pm2 resurrect
```

### Export Process List
```bash
pm2 jlist > pm2-processes.json
```

---

## Production Checklist

- [ ] All 29 services running (`pm2 list` shows 29 online)
- [ ] Health checks passing (`./verify-29-services.sh` shows 29 healthy)
- [ ] Nginx reverse proxy configured
- [ ] SSL certificates installed (if production)
- [ ] Logs directory created and writable
- [ ] PM2 startup script configured (`pm2 startup`)
- [ ] Firewall rules configured (allow ports 80, 443)
- [ ] Monitoring alerts configured
- [ ] Backup strategy in place

---

## Support

For issues or questions:
1. Check logs: `pm2 logs service-name`
2. Run health check: `./verify-29-services.sh`
3. Review this documentation
4. Check PM2 documentation: https://pm2.keymetrics.io/

---

## Success Criteria

✅ All 29 services showing "online" status in PM2  
✅ All health checks returning status "ok"  
✅ Nginx reverse proxy routing correctly  
✅ Zero critical errors in logs  
✅ Services auto-restart on failure  
✅ PM2 configuration saved  

---

**Status**: ✅ READY FOR BETA LAUNCH  
**Last Updated**: 2024  
**Version**: 1.0.0
