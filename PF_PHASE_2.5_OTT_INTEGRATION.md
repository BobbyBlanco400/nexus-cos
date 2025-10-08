# PF DIRECTIVE: NEXUS COS PHASE 2.5 — OTT INTEGRATION + BETA TRANSITION ORDER

**PF ID:** PF-HYBRID-FULLSTACK-2025.10.07-PHASE-2.5  
**Status:** ACTIVE  
**Priority:** HIGH / EXPEDITED  
**Execution Window:** Immediate → 11/17/2025 (Transition Lock)  
**Authorization:** Bobby Blanco | PUABO | NEXUS COS Command

---

## OBJECTIVE

Formalize the coexistence and integration of the Nexus COS OTT Frontend, V-Suite Dashboard, and Beta Launch Portal under one unified PF deployment, maintaining full operational continuity until the Beta transition date of **November 17, 2025**.

---

## 1. SYSTEM LAYERS

| Layer | Purpose | Domain/Path | Lifecycle |
|-------|---------|-------------|-----------|
| **Beta Launch Portal** | Public pre-launch promo + countdown hub | `beta.nexuscos.online` | Active until Nov 17, 2025 |
| **OTT / Streaming Frontend** | Public-facing app for media, shows, music, live events | `nexuscos.online` | Permanent production |
| **Dashboard / Creator Suite** | Creator & operator control center (V-Suite) | `nexuscos.online/v-suite/` | Permanent production |

**Architecture Principle:** All three layers operate under the Nexus COS ecosystem with isolated Nginx routing and shared authentication via Nexus ID SSO.

---

## 2. TRANSITION PLAN

### Timeline

- **Phase 2.5 Start:** Immediate (October 2025)
- **Beta Active Period:** October 1, 2025 - November 16, 2025
- **Transition Date:** November 17, 2025
- **Post-Transition:** November 18, 2025+

### Deployment Strategy

1. **Maintain** `beta.nexuscos.online` under `/var/www/beta.nexuscos.online/` until 11/17/2025
2. **Deploy** OTT and Dashboard independently under `/var/www/nexuscos.online/`
3. **On Nov 17, 2025:** Redirect all traffic from `beta.nexuscos.online` → `https://nexuscos.online`
4. **Post-transition:** Repurpose Beta domain as staging or enforce permanent redirect
5. **Automation:** TRAE SOLO will automate redirect scheduling through Nginx or CI-based cron execution

---

## 3. USER ACCESS FLOW

### Public Viewers
```
nexuscos.online → OTT Interface → Stream & Interact
```

### Creators/Admins
```
nexuscos.online/v-suite → SSO Login → Access Modules (DSP, BLAC, Dispatch, Nuki, etc.)
```

### Beta Visitors (Until Nov 17, 2025)
```
beta.nexuscos.online → Countdown & Feature Showcase → Register Interest
```

**Architecture Note:** Single backend ecosystem, dynamic UI routing based on user role tokens.

---

## 4. ROUTING STRUCTURE

### 4.1 Production Domain - nexuscos.online

```nginx
server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name nexuscos.online www.nexuscos.online;
    
    # IONOS SSL Certificates
    ssl_certificate /etc/nginx/ssl/apex/nexuscos.online.crt;
    ssl_certificate_key /etc/nginx/ssl/apex/nexuscos.online.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # OTT Frontend - Public Streaming Interface
    location / {
        root /var/www/nexuscos.online;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # V-Suite Dashboard - Creator Control Center
    location /v-suite/ {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # API Gateway - Backend Services
    location /api/ {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Health Check Endpoint
    location /health/gateway {
        proxy_pass http://localhost:4000/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
```

### 4.2 Beta Domain - beta.nexuscos.online (Until Nov 17, 2025)

```nginx
server {
    listen 80;
    server_name beta.nexuscos.online;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name beta.nexuscos.online;
    
    # IONOS SSL Certificates
    ssl_certificate /etc/nginx/ssl/beta/beta.nexuscos.online.crt;
    ssl_certificate_key /etc/nginx/ssl/beta/beta.nexuscos.online.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Beta Landing Page
    location / {
        root /var/www/beta.nexuscos.online;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # Beta Health Check
    location /beta/health {
        proxy_pass http://localhost:4000/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
    
    # V-Suite Prompter Health (Beta-specific)
    location /v-suite/prompter/health {
        proxy_pass http://localhost:3002/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
```

### 4.3 Post-Transition Configuration (After Nov 17, 2025)

```nginx
# Permanent redirect from beta to production
server {
    listen 80;
    server_name beta.nexuscos.online;
    return 301 https://nexuscos.online$request_uri;
}

server {
    listen 443 ssl http2;
    server_name beta.nexuscos.online;
    
    # IONOS SSL Certificates
    ssl_certificate /etc/nginx/ssl/beta/beta.nexuscos.online.crt;
    ssl_certificate_key /etc/nginx/ssl/beta/beta.nexuscos.online.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # Redirect all traffic to production
    return 301 https://nexuscos.online$request_uri;
}
```

---

## 5. CI/CD & VALIDATION

### 5.1 PR87 Harness Continuity

PR87 Harness continues to validate all endpoints:
- `/health` - Gateway API health
- `/v-suite/gateway/health` - V-Suite gateway health
- `/beta/health` - Beta environment health

### 5.2 CI/CD Workflow Structure

```
CI/CD Pipeline
│
├── Production Deploy (nexuscos.online)
│   ├── Deploy OTT Frontend → /var/www/nexuscos.online/
│   ├── Deploy Backend Services → Docker Compose
│   └── Validate Production Endpoints
│
├── Beta Deploy (beta.nexuscos.online)
│   ├── Deploy Beta Landing Page → /var/www/beta.nexuscos.online/
│   └── Validate Beta Endpoints
│
└── Post-Deploy Validation
    ├── Health Checks (All Services)
    ├── SSL Certificate Validation
    └── Route Accessibility Tests
```

### 5.3 Log Separation

Logs are enforced with strict separation:

```
/opt/nexus-cos/logs/
├── phase2/          # Phase 2.0 legacy logs
├── phase2.5/        # Phase 2.5 unified logs
│   ├── ott/         # OTT frontend logs
│   ├── dashboard/   # V-Suite dashboard logs
│   └── transition/  # Transition automation logs
└── beta/            # Beta landing page logs
```

**Log Rotation Policy:**
- Daily rotation for active services
- 30-day retention for production logs
- 90-day retention for transition logs
- Compressed archives after 7 days

---

## 6. BRANDING CONSISTENCY

All layers inherit the **official Nexus Creative Operating System Brand Package**:

### Design System
- **Color Palette:** Unified across all interfaces
- **Typography:** Consistent font family and scale
- **Logo:** SVG logo with proper spacing
- **Icons:** Unified icon library

### Technology Stack
- **Frontend Framework:** React + TypeScript
- **Styling:** Tailwind CSS + shadcn/ui
- **State Management:** React Query + Zustand
- **Analytics:** Shared telemetry stack
- **Communication:** Nexus Service Mesh for inter-module communication

### Brand Assets Location
```
/opt/nexus-cos/branding/
├── logo/
│   ├── nexus-cos-logo.svg
│   ├── nexus-cos-logo-light.svg
│   └── nexus-cos-logo-dark.svg
├── colors/
│   └── palette.json
├── typography/
│   └── fonts/
└── guidelines/
    └── brand-guide.pdf
```

---

## 7. EXECUTION ORDER

### Step 1: TRAE SOLO - Deploy Phase 2.5 Architecture

**Responsibility:** TRAE SOLO  
**Action:** Deploy & validate Phase 2.5 architecture

```bash
# Execute Phase 2.5 deployment
cd /opt/nexus-cos
./scripts/deploy-phase-2.5-architecture.sh

# Validate deployment
./scripts/validate-phase-2.5-deployment.sh
```

**Expected Outcome:** All three layers operational with isolated routing

---

### Step 2: CODE AGENT - Scaffold Centralized UI Access

**Responsibility:** CODE AGENT  
**Action:** Scaffold centralized UI access dashboard with OTT routing layer

**Tasks:**
1. Create OTT frontend structure under `/var/www/nexuscos.online/`
2. Implement role-based routing (Public vs Creator)
3. Integrate Nexus ID SSO for dashboard access
4. Configure service mesh communication

---

### Step 3: NGINX - Apply Dual-Root Configuration

**Responsibility:** NGINX Configuration  
**Action:** Apply dual-root configuration and timed redirect for Beta → Production cutover

```bash
# Apply Phase 2.5 nginx configuration
sudo cp /opt/nexus-cos/nginx/phase-2.5-nexuscos.conf /etc/nginx/sites-available/
sudo ln -sf /etc/nginx/sites-available/phase-2.5-nexuscos.conf /etc/nginx/sites-enabled/nexuscos
sudo nginx -t && sudo systemctl reload nginx
```

---

### Step 4: Monitoring - Establish Telemetry

**Responsibility:** System Monitoring  
**Action:** Maintain PF logging and telemetry under `/opt/nexus-cos/logs/phase2.5/`

**Monitoring Points:**
- Service health endpoints (all layers)
- SSL certificate expiration tracking
- Traffic routing verification
- Error rate monitoring
- Performance metrics (response times, throughput)

---

## 8. TRANSITION AUTOMATION

### 8.1 Automated Cutover Script

**Script Location:** `/opt/nexus-cos/scripts/beta-transition-cutover.sh`

**Execution Date:** November 17, 2025 00:00 UTC

**Actions:**
1. Backup current beta nginx configuration
2. Replace beta configuration with permanent redirect
3. Test nginx configuration
4. Reload nginx gracefully
5. Verify redirect functionality
6. Send transition complete notification

### 8.2 Cron Scheduling

```bash
# Schedule transition for Nov 17, 2025 00:00 UTC
# Add to root crontab
0 0 17 11 2025 /opt/nexus-cos/scripts/beta-transition-cutover.sh >> /opt/nexus-cos/logs/phase2.5/transition/cutover.log 2>&1
```

### 8.3 Rollback Plan

**If transition fails:**
1. Restore backed-up beta configuration
2. Reload nginx
3. Alert operations team
4. Schedule manual transition review

---

## 9. VALIDATION CHECKLIST

### Pre-Deployment
- [ ] Repository cloned/updated at `/opt/nexus-cos`
- [ ] Phase 2.5 scripts are executable
- [ ] SSL certificates for all domains present
- [ ] Environment variables configured
- [ ] Docker services healthy

### Post-Deployment
- [ ] Apex landing page accessible at `https://nexuscos.online`
- [ ] Beta landing page accessible at `https://beta.nexuscos.online`
- [ ] V-Suite dashboard accessible at `https://nexuscos.online/v-suite/`
- [ ] All health endpoints returning 200 OK
- [ ] SSL certificates valid for all domains
- [ ] Traffic routing correctly to all layers
- [ ] Logs being written to phase2.5 directory
- [ ] Monitoring dashboards operational

### Transition Validation (Nov 17, 2025)
- [ ] Beta domain redirects to production
- [ ] No 404 errors on redirect
- [ ] SSL certificate valid on redirect
- [ ] Transition logged successfully
- [ ] No service interruption detected

---

## 10. SECURITY & COMPLIANCE

### SSL/TLS Configuration
- **Provider:** IONOS
- **Protocol:** TLS 1.2, TLS 1.3
- **Certificate Renewal:** 30 days before expiration
- **HSTS:** Enabled with 1-year max-age

### Access Control
- **Public Layer (OTT):** No authentication required
- **Dashboard Layer (V-Suite):** Nexus ID SSO required
- **Admin Routes:** IP whitelist + SSO + 2FA

### Data Protection
- **Encryption:** All traffic over HTTPS
- **Session Management:** Secure, httpOnly cookies
- **API Security:** Rate limiting, CORS policies
- **Database:** Encrypted at rest and in transit

---

## 11. EMERGENCY PROCEDURES

### Service Down Response
1. **Immediate:** Check health endpoints
2. **Review:** Recent deployment logs
3. **Verify:** SSL certificate status
4. **Check:** CloudFlare status page
5. **Escalate:** To infrastructure team if needed

### Transition Rollback (If Required)
```bash
# Restore beta standalone operation
sudo cp /etc/nginx/backups/beta.nexuscos.online.conf.pre-transition \
       /etc/nginx/sites-available/beta.nexuscos.online.conf
sudo nginx -t && sudo systemctl reload nginx
```

---

## 12. SUCCESS CRITERIA

Phase 2.5 deployment is considered **SUCCESSFUL** when:

✅ All three system layers operational  
✅ Isolated routing verified for each layer  
✅ Health checks passing for all services  
✅ SSL certificates valid for all domains  
✅ Logging and monitoring operational  
✅ PR87 validation suite passing  
✅ Transition automation tested and scheduled  
✅ Documentation updated and accessible  
✅ Team trained on Phase 2.5 architecture  
✅ Rollback procedures tested

---

## 13. CONTACTS & ESCALATION

**Primary Contact:** Bobby Blanco (PUABO)  
**Technical Lead:** TRAE SOLO (GitHub Code Agent)  
**Infrastructure:** CloudFlare + IONOS  
**Escalation Path:** Bobby Blanco → Infrastructure Team → Emergency Response

---

## 14. APPENDIX

### A. Directory Structure
```
/opt/nexus-cos/
├── scripts/
│   ├── deploy-phase-2.5-architecture.sh
│   ├── validate-phase-2.5-deployment.sh
│   └── beta-transition-cutover.sh
├── nginx/
│   ├── phase-2.5-nexuscos.conf
│   └── post-transition-redirect.conf
├── logs/
│   └── phase2.5/
│       ├── ott/
│       ├── dashboard/
│       ├── beta/
│       └── transition/
└── branding/
    └── (brand assets)
```

### B. Port Assignments
- `4000` - Gateway API (Backend)
- `3002` - V-Prompter Pro (AI SDK)
- `3041` - PV Keys Service
- `8088` - V-Screen Hollywood
- `3016` - StreamCore (OTT Engine)

### C. Domain Mappings
- `nexuscos.online` → OTT Frontend + V-Suite Backend
- `beta.nexuscos.online` → Beta Landing (Until Nov 17, 2025)
- `hollywood.nexuscos.online` → V-Screen Hollywood
- `tv.nexuscos.online` → StreamCore Direct Access

---

## SIGNATURE

**Authorized By:** Bobby Blanco  
**Organization:** PUABO | NEXUS COS Command  
**Date:** October 7, 2025  
**PF Version:** Phase 2.5  
**Effective:** Immediate  
**Review Date:** November 17, 2025

---

**END OF PF DIRECTIVE**

*This document supersedes all previous Phase 2.0 directives and establishes Phase 2.5 as the active production framework until transition completion.*
