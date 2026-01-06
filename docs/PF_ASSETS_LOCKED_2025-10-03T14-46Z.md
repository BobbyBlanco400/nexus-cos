# PF Assets Locked Manifest
**Timestamp:** 2025-10-03T14:46Z  
**Purpose:** Single source of truth for Pre-Flight (PF) deployment assets, locations, and configurations  
**Status:** 🔒 LOCKED - Authoritative reference for all PF deployments

---

## 📋 Overview

This manifest captures all Pre-Flight (PF) assets, their canonical paths, and expected deployment locations to ensure consistent deployments across environments.

---

## 🔐 Environment Configuration

### Repository Locations

| Asset | Repository Path | Purpose |
|-------|----------------|---------|
| **PF Environment** | `/.env.pf` | PF deployment environment variables |
| **Production Environment** | `/.env` | Active runtime environment (copied from .env.pf) |
| **PF Example** | `/.env.pf.example` | Template for PF configuration |
| **General Example** | `/.env.example` | General environment template |

### Environment File Usage

**Primary Source:** `/.env.pf` (repository root)
- Contains all PF-specific environment variables
- Used by deployment scripts as the canonical source
- **Deployment Process:** Scripts copy `.env.pf` to `.env` when deploying

**Key Variables in .env.pf:**
```bash
NODE_ENV=production
PORT=4000
DB_HOST=nexus-cos-postgres
DB_PORT=5432
DB_NAME=nexus_db
DB_USER=nexus_user
REDIS_HOST=nexus-cos-redis
REDIS_PORT=6379
OAUTH_CLIENT_ID=<to-be-configured>
OAUTH_CLIENT_SECRET=<to-be-configured>
JWT_SECRET=<secure-key>
```

**⚠️ Required Actions Before Deployment:**
1. Copy `.env.pf` to `.env`
2. Fill in secrets: `OAUTH_CLIENT_ID`, `OAUTH_CLIENT_SECRET`
3. Verify database credentials
4. Update JWT_SECRET for production

---

## 🔒 SSL Artifacts

### Repository SSL Locations

| Location | Type | Contents |
|----------|------|----------|
| `/fullchain.crt` | File | Full SSL certificate chain (if present in root) |
| `/ssl/` | Directory | SSL certificate storage |
| `/ssl/certs/` | Directory | Certificate candidates (*.crt files) |
| `/ssl/private/` | Directory | Private key candidates (*.key files) |

**Current SSL Assets in Repository:**
```
/ssl/beta.n3xuscos.online.crt
/ssl/beta.n3xuscos.online.key
```

### Canonical PF SSL Deployment Targets

**As defined in PF deployment scripts and documentation:**

| Target | VPS Path | Permissions | Purpose |
|--------|----------|-------------|---------|
| **Certificate** | `/opt/nexus-cos/ssl/nexus-cos.crt` | 644 | Main SSL certificate |
| **Private Key** | `/opt/nexus-cos/ssl/nexus-cos.key` | 600 | SSL private key (restricted) |

**SSL Deployment Process:**
1. Create directory: `sudo mkdir -p /opt/nexus-cos/ssl`
2. Copy valid certificate to: `/opt/nexus-cos/ssl/nexus-cos.crt`
3. Copy private key to: `/opt/nexus-cos/ssl/nexus-cos.key`
4. Set permissions:
   ```bash
   sudo chmod 644 /opt/nexus-cos/ssl/nexus-cos.crt
   sudo chmod 600 /opt/nexus-cos/ssl/nexus-cos.key
   ```
5. Verify ownership: `sudo chown root:root /opt/nexus-cos/ssl/*`

---

## 🎯 V-Prompter Pro (PF Locked Routing)

### Service Configuration

**Service Name:** V-Prompter Pro  
**Backend Service:** nexus-cos-puaboai-sdk  
**Container Port:** 3002  
**Service Target:** http://127.0.0.1:3502/ (production proxy)

### Route Mapping

| Route | Purpose | Backend Target | Status Check |
|-------|---------|----------------|--------------|
| `/v-suite/prompter/` | Public API endpoint | http://127.0.0.1:3502/ | Primary route |
| `/v-suite/prompter/health` | Health check endpoint | http://127.0.0.1:3502/health | Returns 200 OK |

**Nginx Configuration Reference:**
```nginx
# V-Suite Prompter (v-prompter-pro)
location /v-suite/prompter {
    proxy_pass http://pf_puaboai_sdk/v-suite/prompter;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

**Upstream Configuration:**
```nginx
upstream pf_puaboai_sdk {
    server nexus-cos-puaboai-sdk:3002;
}
```

**Production URL:** `https://n3xuscos.online/v-suite/prompter/health`  
**Expected Response:** `200 OK` with JSON health status

---

## 📦 Docker Services

### PF Service Stack

| Service | Container Name | Port | Image | Health Endpoint |
|---------|---------------|------|-------|-----------------|
| **Gateway API** | puabo-api | 4000 | nexus-cos/puabo-api | /health |
| **Database** | nexus-cos-postgres | 5432 | postgres:15-alpine | - |
| **Cache** | nexus-cos-redis | 6379 | redis:7-alpine | - |
| **AI SDK** | nexus-cos-puaboai-sdk | 3002 | nexus-cos/puaboai-sdk | /health |
| **PV Keys** | nexus-cos-pv-keys | 3041 | nexus-cos/pv-keys | /health |

**Docker Compose File:** `/docker-compose.pf.yml`

---

## 📚 Reference Documentation

### PF Documentation Files (Repository Root)

| File | Purpose |
|------|---------|
| `PF_README.md` | Main PF deployment guide |
| `PF_DEPLOYMENT_CHECKLIST.md` | Step-by-step deployment checklist |
| `PF_CONFIGURATION_SUMMARY.md` | Nginx and service configuration |
| `PF_ARCHITECTURE.md` | System architecture overview |
| `PF_PRODUCTION_LAUNCH_SIGNOFF.md` | Production readiness sign-off |
| `NGINX_CONFIGURATION_README.md` | Nginx configuration guide |

### Deployment Scripts

| Script | Location | Purpose |
|--------|----------|---------|
| `deploy-pf.sh` | `/deploy-pf.sh` | Quick PF deployment |
| `validate-pf.sh` | `/validate-pf.sh` | PF configuration validation |
| `validate-pf-nginx.sh` | `/validate-pf-nginx.sh` | Nginx route validation |
| `test-pf-configuration.sh` | `/test-pf-configuration.sh` | Comprehensive PF tests |
| `pf-final-deploy.sh` | `/scripts/pf-final-deploy.sh` | Final deployment to VPS (to be created) |

### Nginx Configuration Files

| File | Purpose |
|------|---------|
| `/nginx/nginx.conf` | Main PF gateway configuration |
| `/nginx/conf.d/nexus-proxy.conf` | PF route mappings |
| `/nginx.conf` | Root production nginx config |

---

## ✅ Validation Steps

### Pre-Deployment Validation

1. **Validate PF Configuration:**
   ```bash
   ./validate-pf.sh
   ```
   Expected: All checks passing (34/34)

2. **Validate Nginx Configuration:**
   ```bash
   ./validate-pf-nginx.sh
   ```
   Expected: All routes and upstreams configured

3. **Check SSL Certificates:**
   ```bash
   openssl x509 -in /path/to/cert.crt -text -noout
   ```
   Verify: Valid dates, correct domain

### Post-Deployment Validation

1. **Check Service Health:**
   ```bash
   curl http://localhost:4000/health
   curl http://localhost:3002/health
   curl http://localhost:3041/health
   ```
   Expected: All return `{"status":"ok"}`

2. **Check Docker Services:**
   ```bash
   docker compose -f docker-compose.pf.yml ps
   ```
   Expected: All services "Up"

3. **Test V-Prompter Pro:**
   ```bash
   curl https://n3xuscos.online/v-suite/prompter/health
   ```
   Expected: 200 OK

4. **Verify SSL:**
   ```bash
   openssl s_client -connect n3xuscos.online:443 -servername n3xuscos.online
   ```
   Expected: Valid certificate chain

---

## 🚀 Deployment Sequence

### Standard PF Deployment Order

1. **Prepare Environment**
   - Ensure `.env.pf` is configured
   - Validate SSL certificates available
   - Verify VPS access

2. **Deploy SSL Certificates**
   - Create `/opt/nexus-cos/ssl/` directory
   - Copy certificates to canonical paths
   - Set proper permissions (644 for .crt, 600 for .key)

3. **Configure Environment**
   - Copy `.env.pf` to `.env`
   - Fill in all required secrets
   - Validate environment variables

4. **Deploy Services**
   - Run Docker Compose: `docker compose -f docker-compose.pf.yml up -d`
   - Wait for services to be healthy
   - Apply database migrations

5. **Configure Nginx**
   - Deploy nginx configurations
   - Test configuration: `nginx -t`
   - Reload Nginx: `systemctl reload nginx`

6. **Validate Deployment**
   - Test all health endpoints
   - Verify SSL functionality
   - Check V-Prompter Pro routing
   - Monitor logs for errors

---

## 🔧 Troubleshooting

### Common Issues

**Issue:** SSL certificate errors  
**Fix:** Verify certificate paths, check permissions, ensure certificate is valid and not expired

**Issue:** Service health checks failing  
**Fix:** Check Docker logs, verify environment variables, ensure ports are available

**Issue:** V-Prompter Pro 502 errors  
**Fix:** Verify puaboai-sdk container is running, check upstream configuration in Nginx

**Issue:** Environment variables not loading  
**Fix:** Ensure `.env` exists, verify it was copied from `.env.pf`, check file permissions

---

## 📊 System Requirements

### VPS Configuration

**Target VPS:** 74.208.155.161  
**Domain:** n3xuscos.online  
**OS:** Ubuntu/Debian (assumed)

**Required Ports:**
- 80 (HTTP)
- 443 (HTTPS)
- 4000 (puabo-api)
- 3002 (puaboai-sdk)
- 3041 (pv-keys)
- 5432 (PostgreSQL)
- 6379 (Redis)

**Required Software:**
- Docker Engine
- Docker Compose
- Nginx
- OpenSSL

---

## 📝 Next Steps for Production Deployment

1. ✅ Review this manifest for accuracy
2. ⏳ Copy valid SSL certificate/key to `/opt/nexus-cos/ssl/`
3. ⏳ Ensure `.env` exists (copy from `.env.pf` and fill secrets)
4. ⏳ Run full system deployment script: `./scripts/pf-final-deploy.sh`
5. ⏳ Validate deployment: Test all health endpoints
6. ⏳ Configure DNS (if not already done)
7. ⏳ Test V-Prompter Pro: `https://n3xuscos.online/v-suite/prompter/health`
8. ⏳ Monitor logs for 24 hours
9. ⏳ Document any issues and resolutions

---

## 🔖 Manifest Maintenance

**Last Updated:** 2025-10-03T14:46Z  
**Next Review:** After successful production deployment  
**Maintainer:** GitHub Copilot Code Agent  
**Status:** 🟢 Active and Authoritative

**Change Log:**
- 2025-10-03T14:46Z - Initial manifest creation
  - Documented all PF assets and locations
  - Locked V-Prompter Pro routing configuration
  - Defined canonical SSL paths
  - Created authoritative deployment sequence

---

**⚠️ IMPORTANT:** This is a locked manifest. Any changes to PF asset locations, routing, or deployment procedures should be reflected in this document and timestamped in the change log.

---

*Generated by: GitHub Copilot Code Agent*  
*Repository: BobbyBlanco400/nexus-cos*  
*Branch: copilot/fix-4e5445c0-c28e-4114-877d-513f537e2893*
