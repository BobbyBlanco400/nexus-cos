# Nexus COS PF - Complete Deployment Guide

## 🎯 For TRAE Solo (Human Operator)

This comprehensive guide provides step-by-step instructions for deploying the complete Nexus COS Production Framework as designed in the problem statement.

---

## Table of Contents

1. [PF Structure Overview](#pf-structure-overview)
2. [Quick Deployment (TRAE Solo)](#quick-deployment-trae-solo)
3. [GitHub Code Agent Usage](#github-code-agent-usage)
4. [Module Details](#module-details)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)

---

## PF Structure Overview

The Production Framework includes:

### Core SPAs
- **Backend**: TypeScript/Express API server
- **Frontend**: React production dashboard
- **Beta**: React testing environment with handshake headers
- **OACP**: Owner/Admin Control Panel for 19+ platforms

### Additive Modules
- **CIM-B**: Creator Investment Module + Blockchain
- **PWA**: Progressive Web App with service worker
- **NexusVision™**: AR/VR immersive experiences
- **HoloCore™**: 3D/AR rendering engine

### Deployment Scripts
- `deploy-pwa.sh`: PWA deployment
- `deploy-nexusvision.sh`: AR/VR deployment
- `deploy-holocore.sh`: 3D/AR deployment
- `full-verify.sh`: Complete system verification

---

## Quick Deployment (TRAE Solo)

### One-Command Deployment:

```bash
cd /opt/nexus-cos && \
git pull origin main && \
for dir in backend frontend beta nexus-oacp/frontend; do (cd $dir && npm ci --quiet); done && \
npm run build --prefix frontend && \
npm run build --prefix beta && \
npm run build --prefix nexus-oacp/frontend && \
./scripts/deploy-pwa.sh && \
./scripts/deploy-nexusvision.sh && \
./scripts/deploy-holocore.sh && \
./scripts/full-verify.sh
```

### Step-by-Step (Recommended for First-Time):

```bash
# 1. Navigate to repository
cd /opt/nexus-cos

# 2. Update code
git pull origin main

# 3. Install backend dependencies
cd backend && npm ci

# 4. Install frontend dependencies
cd ../frontend && npm ci

# 5. Install beta dependencies
cd ../beta && npm ci

# 6. Install OACP dependencies
cd ../nexus-oacp/frontend && npm ci

# 7. Build frontend
cd ../../frontend && npm run build

# 8. Build beta
cd ../beta && npm run build

# 9. Build OACP
cd ../nexus-oacp/frontend && npm run build

# 10. Deploy PWA
cd ../../scripts && ./deploy-pwa.sh

# 11. Deploy NexusVision
./deploy-nexusvision.sh

# 12. Deploy HoloCore
./deploy-holocore.sh

# 13. Initialize CIM-B
node ../src/Modules/CIM_B.ts

# 14. Verify deployment
./full-verify.sh
```

**Total time:** ~10-15 minutes

---

## GitHub Code Agent Usage

For automated deployment via GitHub Code Agent:

```bash
# Clone repository
git clone <repo-url> nexus-cos
cd nexus-cos

# Install all dependencies
cd backend && npm ci
cd ../frontend && npm ci
cd ../beta && npm ci
cd ../nexus-oacp/frontend && npm ci

# Build all SPAs
cd ../frontend && npm run build
cd ../beta && npm run build
cd ../nexus-oacp/frontend && npm run build

# Deploy additive modules
cd ../scripts
./deploy-nexusvision.sh
./deploy-holocore.sh
./deploy-pwa.sh
./full-verify.sh

# Initialize CIM-B across IMCUs
node ../src/Modules/CIM_B.ts

# Reload NGINX (if applicable)
sudo systemctl reload nginx

echo "✅ Nexus COS Full Stack Additive Modules deployed!"
```

---

## Module Details

### 1. CIM-B (Creator Investment Module)

**File:** `src/Modules/CIM_B.ts`

**Features:**
- Tokenized investment opportunities
- Blockchain integration (Ethereum, Polygon, Solana)
- NFT tokenization
- IMCU bulk integration

**Usage:**
```typescript
import { cimBModule } from './src/Modules/CIM_B';

await cimBModule.initialize();
const opportunities = await cimBModule.listTokenizedOpportunities();
await cimBModule.investTokenized(opportunityId, investorId, amount);
const integrations = await cimBModule.bulkIMCUIntegration(imcuIds, opportunityIds);
```

### 2. Beta SPA

**Directory:** `beta/`

**Key Feature:** Handshake header enforcement
```
X-Nexus-Handshake: beta-55-45-17
```

**Endpoints:**
- `https://beta.nexuscos.online/`
- `https://beta.nexuscos.online/catalog`
- `https://beta.nexuscos.online/status`
- `https://beta.nexuscos.online/test`

### 3. PWA Integration

**Deployment:**
```bash
./scripts/deploy-pwa.sh
```

**Components:**
- Service worker (`/service-worker.js`)
- PWA manifest (`/manifest.json`)
- Offline caching
- Mobile app experience

### 4. OACP (Owner/Admin Control Panel)

**Directory:** `nexus-oacp/frontend/`

**Manages 19+ Mini Platforms:**
1. Beta Environment
2. CIM-B Module
3. PWA Service
4. NexusVision
5. HoloCore
6. PUABO Nexus Fleet
7. PUABO DSP
8. PUABO BLAC
9. PUABO NUKI
10. V-Suite
11. StreamCore
12. GameCore
13. MusicChain
14. Nexus Studio AI
15. Casino-Nexus
16. Club Saditty
17. PUABOverse
18. Creator Hub
19. PUABO OTT TV

### 5. NexusVision™

**Deployment:**
```bash
./scripts/deploy-nexusvision.sh
```

**Features:**
- AR experiences
- VR experiences
- WebXR support
- Creative content pipelines

**Access:**
- AR Demo: `/nexusvision/experiences/ar-demo.html`
- VR Demo: `/nexusvision/experiences/vr-demo.html`
- Config: `/nexusvision/nexusvision-config.json`

### 6. HoloCore™

**Deployment:**
```bash
./scripts/deploy-holocore.sh
```

**Features:**
- 3D rendering (Three.js)
- AR engine
- Holographic display
- Scene management

**Access:**
- 3D Viewer: `/holocore/viewer.html`
- AR Experience: `/holocore/ar-experience.html`
- Config: `/holocore/holocore-config.json`

---

## Verification

### Beta Endpoints

Test with handshake header:
```bash
curl -I https://beta.nexuscos.online/ | grep -i '^X-Nexus-Handshake'
curl -I https://beta.nexuscos.online/catalog | grep -i '^X-Nexus-Handshake'
curl -I https://beta.nexuscos.online/status | grep -i '^X-Nexus-Handshake'
curl -I https://beta.nexuscos.online/test | grep -i '^X-Nexus-Handshake'
```

**Expected:** `X-Nexus-Handshake: beta-55-45-17`

### Production Core (Frozen)

```bash
curl -I https://nexuscos.online/streaming/ | grep -i '^X-Nexus-Handshake'
curl -I https://nexuscos.online/streaming/catalog | grep -i '^X-Nexus-Handshake'
curl -I https://nexuscos.online/streaming/status | grep -i '^X-Nexus-Handshake'
curl -I https://nexuscos.online/streaming/test | grep -i '^X-Nexus-Handshake'
```

### Additive Modules

```bash
# CIM-B status
node -e "const {cimBModule} = require('./src/Modules/CIM_B'); console.log(cimBModule.getStatistics());"

# PWA service worker
curl -I https://nexuscos.online/service-worker.js

# NexusVision/HoloCore
curl -I https://nexuscos.online/nexusvision/nexusvision-config.json
curl -I https://nexuscos.online/holocore/holocore-config.json

# OACP UI
curl -I https://nexuscos.online/oacp/
```

### Full System Verification

```bash
./scripts/full-verify.sh
```

**Expected output:**
```
================================================
 Nexus COS - Full System Verification
================================================

Testing Beta Root... ✓ PASS (HTTP 200)
Testing Beta Catalog... ✓ PASS (HTTP 200)
...
Total Tests:  45
Passed:       45
Failed:       0

✅ All tests passed! System is fully operational.
```

---

## Troubleshooting

### Dependencies Won't Install

```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules
rm -rf node_modules package-lock.json

# Reinstall
npm install
```

### Build Failures

```bash
# Ensure Node.js version is correct
node --version  # Should be 20.x+

# Clear dist/build directories
rm -rf dist build

# Rebuild
npm run build
```

### Backend Won't Start

```bash
# Check if port is occupied
lsof -i :3000

# Kill process if needed
kill -9 <PID>

# Check environment variables
cat backend/.env

# Start in development mode
cd backend
npm run dev
```

### Verification Script Fails

```bash
# Check file permissions
chmod +x scripts/*.sh

# Run individual checks
curl -I https://nexuscos.online/
curl -I https://beta.nexuscos.online/

# Check logs
tail -f /var/log/nginx/error.log
```

---

## Environment Configuration

### Backend

```bash
cp backend/.env.example backend/.env
```

Edit `backend/.env`:
```bash
PORT=3000
NODE_ENV=production
DB_HOST=localhost
DB_PORT=5432
DB_NAME=nexus_cos
DB_USER=nexus_user
DB_PASSWORD=your_password
JWT_SECRET=your_secret
```

### Frontend

```bash
cp frontend/.env.example frontend/.env
```

### Beta

```bash
cp beta/.env.example beta/.env
```

Verify:
```bash
cat beta/.env | grep BETA_HANDSHAKE
# Should show: VITE_BETA_HANDSHAKE=beta-55-45-17
```

---

## Success Checklist

- [ ] All dependencies installed
- [ ] All builds completed successfully
- [ ] Backend running on port 3000
- [ ] Frontend build deployed
- [ ] Beta SPA deployed with handshake
- [ ] CIM-B module initialized
- [ ] PWA service worker registered
- [ ] NexusVision deployed
- [ ] HoloCore deployed
- [ ] OACP accessible
- [ ] Full verification passing

---

## Support

- **Documentation:** [NEXUS_COS_PF_README.md](./NEXUS_COS_PF_README.md)
- **Issues:** https://github.com/BobbyBlanco400/nexus-cos/issues
- **PF Structure:** See complete file tree in problem statement

---

**Version:** PF v1.0.0  
**For:** TRAE Solo (Human Operator) & GitHub Code Agent  
**Status:** ✅ Production Ready  
**Updated:** 2025-12-18
