# NEXUS COS PLATFORM - GITHUB CODE AGENT VERIFICATION PROMPT FILE (PF)
**Version:** 1.0.0  
**Date:** November 25, 2025  
**Status:** Dockerized - 37 Services  
**Purpose:** Independent verification of fully dockerized Nexus COS platform

---

## VERIFICATION MISSION

You are tasked with independently verifying that the Nexus COS platform is fully dockerized with all 37 microservices running in individual Docker containers. This is a **READ-ONLY verification** - make NO changes to the system.

---

## SYSTEM OVERVIEW

**Platform:** Nexus COS - Creative Operating System  
**Architecture:** Dockerized Microservices  
**Expected Containers:** 38 total (37 services + 1 postgres database)  
**Domain:** https://nexuscos.online  
**Server Path:** /var/www/nexuscos.online  

---

## VERIFICATION CHECKLIST

### ✓ Phase 1: Docker Infrastructure
- [ ] Docker is installed and running
- [ ] Docker Compose is available
- [ ] Docker daemon is operational
- [ ] Docker network `nexus-network` exists

**Commands to verify:**
```bash
docker --version
docker ps
docker network ls | grep nexus-network
```

**Expected Results:**
- Docker version 20.x or higher
- Docker daemon responding
- nexus-network bridge network present

---

### ✓ Phase 2: Container Count Verification
- [ ] Total containers = 38 (37 services + 1 postgres)
- [ ] All 38 containers are in "running" state
- [ ] No containers in "exited" or "stopped" state

**Commands to verify:**
```bash
docker ps -q | wc -l
docker ps -a --filter "status=exited" -q | wc -l
docker ps --format "table {{.Names}}\t{{.Status}}"
```

**Expected Results:**
- Running containers: 38
- Stopped containers: 0
- All services showing "Up" status

---

### ✓ Phase 3: Service Inventory Verification

**All 37 services must be present as Docker containers:**

#### Authentication Services (3)
- [ ] auth-service
- [ ] auth-service-v2
- [ ] user-auth

#### AI and Studio Services (4)
- [ ] ai-service
- [ ] puabo-ai-core
- [ ] nexus-cos-studio-ai
- [ ] kei-ai

#### Creator and Content Services (4)
- [ ] creator-hub-v2
- [ ] content-management
- [ ] metatwin
- [ ] puaboai-sdk

#### Virtual Production Suite (5)
- [ ] vscreen-hollywood
- [ ] v-stage
- [ ] v-caster-pro
- [ ] key-service
- [ ] pv-keys

#### Streaming Services (4)
- [ ] streamcore
- [ ] socket-io-streaming
- [ ] rtmp-nms
- [ ] streaming-service-v2

#### DSP Services (3)
- [ ] puabo-dsp-metadata-mgr
- [ ] puabo-dsp-streaming-api
- [ ] puabo-dsp-upload-mgr

#### Fleet Management (3)
- [ ] puabo-nexus-fleet-manager
- [ ] puabo-nexus-driver-app-backend
- [ ] puabo-nexus-route-optimizer

#### E-Commerce Services (4)
- [ ] puabo-nuki-inventory-mgr
- [ ] puabo-nuki-order-processor
- [ ] puabo-nuki-product-catalog
- [ ] puabo-nuki-shipping-service

#### Financial Services (2)
- [ ] puabo-blac-loan-processor
- [ ] puabo-blac-risk-assessment

#### Platform Services (3)
- [ ] puabomusicchain
- [ ] puaboverse-v2
- [ ] puabo-nexus-ai-dispatch

#### Backend and API Services (2)
- [ ] nexus-api-complete
- [ ] backend-api

#### Database (1)
- [ ] nexus-postgres

**Command to verify all services:**
```bash
docker ps --format "{{.Names}}" | sort
```

**Expected:** All 38 container names listed above should be present

---

### ✓ Phase 4: Docker Images Verification
- [ ] All 37 service images built with prefix `nexus-cos/`
- [ ] All images tagged as `latest`
- [ ] No image build failures

**Commands to verify:**
```bash
docker images | grep "nexus-cos/"
docker images | grep "nexus-cos/" | wc -l
```

**Expected Results:**
- 37 Docker images with prefix `nexus-cos/`
- All tagged as `latest`
- No `<none>` or failed builds

---

### ✓ Phase 5: Network Configuration
- [ ] All service containers connected to `nexus-network`
- [ ] Network type is `bridge`
- [ ] No network isolation issues

**Commands to verify:**
```bash
docker network inspect nexus-network
docker network inspect nexus-network | grep -c "\"Name\""
```

**Expected Results:**
- Network exists and is type `bridge`
- All 37 service containers listed as connected

---

### ✓ Phase 6: Port Allocation
- [ ] No port conflicts
- [ ] All services bound to appropriate ports
- [ ] Port range: 3000-3033, 3404, 8088

**Commands to verify:**
```bash
docker ps --format "table {{.Names}}\t{{.Ports}}"
netstat -tuln | grep LISTEN
```

**Expected Results:**
- All containers have port mappings
- No port conflicts
- Services listening on assigned ports

---

### ✓ Phase 7: Frontend Pages Accessibility
- [ ] Main landing page accessible
- [ ] V-Screen Hollywood page accessible
- [ ] Subscribe page accessible
- [ ] Pricing page accessible

**Commands to verify:**
```bash
curl -I https://nexuscos.online/
curl -I https://nexuscos.online/apps/v-suite/v-screen/
curl -I https://nexuscos.online/apps/subscribe.html
curl -I https://nexuscos.online/pricing.html
```

**Expected Results:**
- All pages return HTTP 200 OK
- No 404 or 500 errors

---

### ✓ Phase 8: Backend API Health
- [ ] Backend API responding
- [ ] Health endpoints operational
- [ ] Subscription API functional

**Commands to verify:**
```bash
curl -s http://localhost:3001/health
curl -s http://localhost:3001/api/subscriptions/tiers
```

**Expected Results:**
- Health endpoint returns JSON with status
- Subscription tiers endpoint returns data

---

### ✓ Phase 9: Service Directory Structure
- [ ] All 37 service directories exist
- [ ] Each service has Dockerfile
- [ ] Each service has package.json
- [ ] Each service has src/index.js

**Commands to verify:**
```bash
cd /var/www/nexuscos.online
ls -la services/
find services/ -name "Dockerfile" | wc -l
find services/ -name "package.json" | wc -l
```

**Expected Results:**
- 37 service directories in `services/` folder
- 37 Dockerfiles found
- 37 package.json files found

---

### ✓ Phase 10: PM2 Status
- [ ] PM2 services are stopped (replaced by Docker)
- [ ] No PM2 processes running
- [ ] Docker has fully replaced PM2

**Commands to verify:**
```bash
pm2 list
pm2 jlist | jq '[.[] | select(.pm2_env.status=="stopped")] | length'
```

**Expected Results:**
- All PM2 services should be stopped
- Docker containers handling all services

---

## VERIFICATION SCORING

**Total Checks:** 10 phases  
**Passing Grade:** 90% or higher (9/10 phases pass)  
**Critical Phases:** 2, 3, 6, 7, 8 (must all pass)

### Scoring Criteria:
- **100% (10/10):** Platform perfectly dockerized and operational
- **90% (9/10):** Minor issues, platform mostly operational
- **80% (8/10):** Some services need attention
- **<80%:** Significant issues requiring investigation

---

## VERIFICATION OUTPUT FORMAT

Please provide verification results in this format:

```
NEXUS COS DOCKERIZATION VERIFICATION REPORT
Generated: [timestamp]
Verifier: GitHub Code Agent

PHASE 1: Docker Infrastructure ................ [PASS/FAIL]
PHASE 2: Container Count ....................... [PASS/FAIL]
PHASE 3: Service Inventory ..................... [PASS/FAIL]
PHASE 4: Docker Images ......................... [PASS/FAIL]
PHASE 5: Network Configuration ................. [PASS/FAIL]
PHASE 6: Port Allocation ....................... [PASS/FAIL]
PHASE 7: Frontend Accessibility ................ [PASS/FAIL]
PHASE 8: Backend API Health .................... [PASS/FAIL]
PHASE 9: Service Directory Structure ........... [PASS/FAIL]
PHASE 10: PM2 Status ........................... [PASS/FAIL]

OVERALL SCORE: X/10 (XX%)
STATUS: [PASS/FAIL]

CRITICAL FINDINGS:
[List any critical issues found]

RECOMMENDATIONS:
[List any recommendations for improvement]
```

---

## SUCCESS CRITERIA

The platform is considered **FULLY VERIFIED** if:

1. All 38 containers are running (37 services + 1 postgres)
2. All frontend pages return HTTP 200
3. Backend API health checks pass
4. No containers in stopped/exited state
5. All 37 service images exist
6. Docker network properly configured
7. No port conflicts
8. Service directory structure complete

---

## IMPORTANT NOTES

- **READ-ONLY VERIFICATION:** Do not make any changes to the system
- **NO RESTARTS:** Do not restart any containers or services
- **NO MODIFICATIONS:** Do not modify any configuration files
- **REPORT ONLY:** Document findings without making corrections

---

## REFERENCE DOCUMENTATION

- Full dockerization record: `NEXUS_COS_DOCKERIZED_37_SERVICES_*.txt`
- Build logs: Check Docker build output in scripts
- Service list: See Phase 3 checklist above
- Architecture: Fully dockerized microservices

---

## CONTACT

If verification fails or critical issues found:
- Review containerization scripts in `/var/www/nexuscos.online/scripts/`
- Check Docker logs: `docker logs <container-name>`
- Consult full legal documentation in project root

---

**END OF VERIFICATION PROMPT FILE**
