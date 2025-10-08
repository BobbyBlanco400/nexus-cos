# TRAE Solo Builder - Execution Instructions

**Target:** Nexus COS Production Framework Deployment  
**Phase:** 2.5 - OTT Integration + Beta Transition  
**VPS:** 74.208.155.161 (nexuscos.online)  
**Status:** BULLETPROOFED - ZERO ERROR MARGIN  
**PF ID:** PF-HYBRID-FULLSTACK-2025.10.07-PHASE-2.5  
**Date:** 2025-10-07

---

## 🎯 PHASE 2.5 OVERVIEW

**Phase 2.5** introduces unified deployment of three system layers:

1. **OTT Frontend** - `nexuscos.online` (Production streaming interface)
2. **V-Suite Dashboard** - `nexuscos.online/v-suite/` (Creator control center)
3. **Beta Portal** - `beta.nexuscos.online` (Active until Nov 17, 2025)

**Key Features:**
- Dual-domain routing with isolated Nginx configurations
- Automated transition on November 17, 2025
- Shared Nexus ID SSO authentication
- Unified branding and telemetry

---

## ⚡ Quick Execute - Phase 2.5 (One Command)

```bash
ssh root@74.208.155.161 "cd /opt/nexus-cos && ./scripts/deploy-phase-2.5-architecture.sh && ./scripts/validate-phase-2.5-deployment.sh"
```

**Expected Result:** "✅ ALL CHECKS PASSED" + "Phase 2.5 Deployment is Production Ready!"

### Legacy Phase 2.0 Execute (If needed)

```bash
ssh root@74.208.155.161 "cd /opt/nexus-cos && ./bulletproof-pf-deploy.sh && ./bulletproof-pf-validate.sh"
```

---

## 📋 Pre-Execution Checklist

Before executing, ensure you have:

### 1. Access Credentials

- [ ] VPS SSH Key configured
- [ ] Root SSH access to 74.208.155.161
- [ ] GitHub repository access

### 2. IONOS SSL Certificates

- [ ] `nexuscos.online.crt` and `.key` files
- [ ] `hollywood.nexuscos.online.crt` and `.key` files
- [ ] Certificates in PEM format

### 3. OAuth Credentials

- [ ] OAuth Client ID
- [ ] OAuth Client Secret
- [ ] These should be obtained from your OAuth provider

### 4. Generated Secrets

- [ ] JWT Secret (64-character hex string)
- [ ] Database Password (secure random string)

---

## 🚀 Step-by-Step Execution

### Step 1: Connect to VPS

```bash
ssh root@74.208.155.161
```

**Verify:** You are logged in as root

---

### Step 2: Verify Repository

```bash
cd /opt/nexus-cos
ls -la
```

**Expected:** You should see:
- `bulletproof-pf-deploy.sh`
- `bulletproof-pf-validate.sh`
- `docker-compose.pf.yml`
- `.env.pf.example`

**If repository doesn't exist:**

```bash
mkdir -p /opt/nexus-cos
cd /opt/nexus-cos
git clone git@github.com:BobbyBlanco400/nexus-cos.git .
```

---

### Step 3: Configure Environment File

```bash
# Copy example to actual
cp .env.pf.example .env.pf

# Edit the file
nano .env.pf
```

**CRITICAL: Update these values:**

```bash
# OAuth Configuration - REPLACE WITH ACTUAL VALUES
OAUTH_CLIENT_ID=your-actual-oauth-client-id-here
OAUTH_CLIENT_SECRET=your-actual-oauth-client-secret-here

# JWT Configuration - REPLACE WITH GENERATED SECRET
JWT_SECRET=your-64-character-random-hex-string-here

# Database Configuration - REPLACE WITH SECURE PASSWORD
DB_PASSWORD=your-secure-database-password-here
```

**Generate secure secrets:**

```bash
# Generate JWT Secret
openssl rand -hex 32

# Generate DB Password
openssl rand -base64 24
```

**Save and exit:** `Ctrl+X`, then `Y`, then `Enter`

**Verify no placeholders remain:**

```bash
grep -E "(your-|<.*>)" .env.pf
```

**Expected:** No output (all placeholders replaced)

---

### Step 4: Setup SSL Certificates (IONOS)

```bash
# Create SSL directories
mkdir -p /etc/nginx/ssl/apex
mkdir -p /etc/nginx/ssl/hollywood
mkdir -p /etc/nginx/ssl/tv
```

**Place IONOS certificates:**

```bash
# Copy your IONOS certificates to:
/etc/nginx/ssl/apex/nexuscos.online.crt
/etc/nginx/ssl/apex/nexuscos.online.key
/etc/nginx/ssl/hollywood/hollywood.nexuscos.online.crt
/etc/nginx/ssl/hollywood/hollywood.nexuscos.online.key
```

**Set proper permissions:**

```bash
chmod 644 /etc/nginx/ssl/apex/*.crt
chmod 600 /etc/nginx/ssl/apex/*.key
chmod 644 /etc/nginx/ssl/hollywood/*.crt
chmod 600 /etc/nginx/ssl/hollywood/*.key
```

**Validate certificates:**

```bash
openssl x509 -in /etc/nginx/ssl/apex/nexuscos.online.crt -noout -text
```

**Expected:** Valid certificate information displayed

---

### Step 5: Run Bulletproof Deployment

```bash
cd /opt/nexus-cos
chmod +x bulletproof-pf-deploy.sh
./bulletproof-pf-deploy.sh
```

**What this does:**

1. ✅ Checks system requirements
2. ✅ Validates repository structure
3. ✅ Configures environment
4. ✅ Sets up SSL certificates
5. ✅ Validates Docker Compose
6. ✅ Deploys all services
7. ✅ Runs health checks
8. ✅ Configures Nginx
9. ✅ Validates deployment
10. ✅ Displays summary

**Expected Output:**

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                   ✅ ALL CHECKS PASSED                         ║
║                                                                ║
║         Nexus COS Production Framework Deployed!               ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

**Deployment Time:** Approximately 5-10 minutes

---

### Step 6: Run Validation Suite

```bash
chmod +x bulletproof-pf-validate.sh
./bulletproof-pf-validate.sh
```

**What this validates:**

1. ✅ Infrastructure (Docker, Compose, files)
2. ✅ Service Status (all containers running)
3. ✅ Health Endpoints (HTTP 200 responses)
4. ✅ Database (connectivity, tables)
5. ✅ Redis (cache operational)
6. ✅ Networking (ports, networks)
7. ✅ SSL Certificates (IONOS, valid)
8. ✅ Environment Variables (no placeholders)
9. ✅ V-Suite Services (Hollywood, StreamCore)
10. ✅ Logs (no critical errors)

**Expected Output:**

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                   ✅ ALL CHECKS PASSED                         ║
║                                                                ║
║           Nexus COS PF is Production Ready!                    ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

---

### Step 7: Verify Service Endpoints

```bash
# Test internal endpoints
curl http://localhost:4000/health  # Gateway API
curl http://localhost:3002/health  # AI SDK / V-Prompter
curl http://localhost:3041/health  # PV Keys
curl http://localhost:8088/health  # V-Screen Hollywood
curl http://localhost:3016/health  # StreamCore
```

**Expected:** All return HTTP 200 OK

---

### Step 8: Check Service Status

```bash
docker compose -f docker-compose.pf.yml ps
```

**Expected Output:**

```
NAME                        STATUS              PORTS
nexus-cos-postgres          Up (healthy)        5432
nexus-cos-redis             Up                  6379
puabo-api                   Up (healthy)        4000
nexus-cos-puaboai-sdk       Up                  3002
nexus-cos-pv-keys           Up                  3041
vscreen-hollywood           Up (healthy)        8088
nexus-cos-streamcore        Up (healthy)        3016
```

All services should show "Up" status.

---

### Step 9: Verify Database

```bash
# Check database tables
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres \
  psql -U nexus_user -d nexus_db -c "\dt"
```

**Expected Tables:**
- users
- sessions
- api_keys
- audit_log

---

### Step 10: Disable Let's Encrypt (IONOS Only)

```bash
# Move Let's Encrypt configs
mkdir -p /etc/nginx/conf.d.disabled
mv /etc/nginx/conf.d/*letsencrypt* /etc/nginx/conf.d.disabled/ 2>/dev/null || true

# Stop Let's Encrypt auto-renewal
systemctl disable certbot.timer 2>/dev/null || true
systemctl stop certbot.timer 2>/dev/null || true
```

**Verify:**

```bash
ls /etc/nginx/conf.d/ | grep -i letsencrypt
```

**Expected:** No output (no Let's Encrypt configs in active directory)

---

### Step 11: Configure Production Nginx

Create Nginx configuration for production domains:

```bash
nano /etc/nginx/sites-available/nexuscos-production
```

**Paste this configuration:**

```nginx
# Apex Domain - nexuscos.online
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

    # API routes
    location /api {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # V-Suite routes
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

    # Frontend (default)
    location / {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Hollywood Subdomain
server {
    listen 80;
    server_name hollywood.nexuscos.online;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name hollywood.nexuscos.online;

    # IONOS SSL Certificates
    ssl_certificate /etc/nginx/ssl/hollywood/hollywood.nexuscos.online.crt;
    ssl_certificate_key /etc/nginx/ssl/hollywood/hollywood.nexuscos.online.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # V-Screen Hollywood
    location / {
        proxy_pass http://localhost:8088;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# TV Subdomain (Optional)
server {
    listen 80;
    server_name tv.nexuscos.online;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name tv.nexuscos.online;

    # Use apex certificates if TV-specific not available
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

    # StreamCore / OTT Platform
    location / {
        proxy_pass http://localhost:3016;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Enable site:**

```bash
ln -s /etc/nginx/sites-available/nexuscos-production /etc/nginx/sites-enabled/
```

**Test and reload:**

```bash
nginx -t && systemctl reload nginx
```

**Expected:** "syntax is ok" and "successful"

---

### Step 12: Test Production Endpoints

```bash
# Test apex domain
curl -I https://nexuscos.online/api/health

# Test Hollywood subdomain
curl -I https://hollywood.nexuscos.online/health

# Test TV subdomain (if configured)
curl -I https://tv.nexuscos.online/health
```

**Expected:** HTTP/2 200 for all

---

### Step 13: Verify SSL Issuer

```bash
openssl s_client -connect nexuscos.online:443 -showcerts 2>/dev/null | grep issuer
```

**Expected Output:** Should contain "IONOS"

---

### Step 14: Final System Check

```bash
# View all services
docker compose -f docker-compose.pf.yml ps

# Check resource usage
docker stats --no-stream

# View recent logs
docker compose -f docker-compose.pf.yml logs --tail=50
```

---

## ✅ Success Confirmation

### You have successfully deployed Nexus COS when:

✅ `bulletproof-pf-deploy.sh` completes with "ALL CHECKS PASSED"  
✅ `bulletproof-pf-validate.sh` shows "Production Ready"  
✅ All services show "Up" in `docker compose ps`  
✅ All health endpoints return HTTP 200  
✅ Database tables are initialized  
✅ SSL certificates are from IONOS  
✅ Production domains respond correctly  
✅ No error messages in logs

---

## 🔧 Troubleshooting

### If deployment fails:

```bash
# Check logs
docker compose -f docker-compose.pf.yml logs -f

# Check specific service
docker compose -f docker-compose.pf.yml logs [service-name]

# Restart services
docker compose -f docker-compose.pf.yml restart

# Full restart
docker compose -f docker-compose.pf.yml down
docker compose -f docker-compose.pf.yml up -d
```

### If validation fails:

```bash
# Re-run with verbose output
./bulletproof-pf-validate.sh 2>&1 | tee validation.log

# Check environment file
cat .env.pf | grep -E "(your-|<.*>)"
# Should return nothing

# Verify Docker is running
systemctl status docker

# Check disk space
df -h
```

### If SSL errors:

```bash
# Verify certificate files exist
ls -la /etc/nginx/ssl/apex/
ls -la /etc/nginx/ssl/hollywood/

# Check certificate validity
openssl x509 -in /etc/nginx/ssl/apex/nexuscos.online.crt -noout -dates

# Test Nginx configuration
nginx -t
```

---

## 📊 Post-Deployment Monitoring

### Monitor service health:

```bash
# Watch logs in real-time
docker compose -f docker-compose.pf.yml logs -f

# Check service status every 5 seconds
watch -n 5 'docker compose -f /opt/nexus-cos/docker-compose.pf.yml ps'

# Monitor resource usage
docker stats
```

### Health check endpoints:

```bash
# Create monitoring script
cat > /opt/nexus-cos/health-monitor.sh << 'EOF'
#!/bin/bash
while true; do
    echo "=== Health Check $(date) ==="
    curl -s http://localhost:4000/health && echo " ✓ Gateway API"
    curl -s http://localhost:3002/health && echo " ✓ AI SDK"
    curl -s http://localhost:3041/health && echo " ✓ PV Keys"
    curl -s http://localhost:8088/health && echo " ✓ Hollywood"
    curl -s http://localhost:3016/health && echo " ✓ StreamCore"
    sleep 60
done
EOF

chmod +x /opt/nexus-cos/health-monitor.sh
```

---

## 📝 Quick Reference Commands

```bash
# Deploy
./bulletproof-pf-deploy.sh

# Validate
./bulletproof-pf-validate.sh

# View services
docker compose -f docker-compose.pf.yml ps

# View logs
docker compose -f docker-compose.pf.yml logs -f

# Restart service
docker compose -f docker-compose.pf.yml restart [service-name]

# Stop all
docker compose -f docker-compose.pf.yml down

# Start all
docker compose -f docker-compose.pf.yml up -d

# Health checks
curl http://localhost:4000/health
curl http://localhost:3002/health
curl http://localhost:3041/health
curl http://localhost:8088/health
curl http://localhost:3016/health

# Production endpoints
curl https://nexuscos.online/api/health
curl https://hollywood.nexuscos.online/health
```

---

## 🚀 PHASE 2.5 SPECIFIC PROCEDURES

### Step 15: Deploy Phase 2.5 Architecture

**Execute Phase 2.5 unified deployment:**

```bash
cd /opt/nexus-cos
chmod +x scripts/deploy-phase-2.5-architecture.sh
./scripts/deploy-phase-2.5-architecture.sh
```

**What this deploys:**

1. ✅ OTT Frontend at `/var/www/nexuscos.online/`
2. ✅ Beta Portal at `/var/www/beta.nexuscos.online/`
3. ✅ Dual-domain Nginx configuration
4. ✅ Isolated logging per layer (`/opt/nexus-cos/logs/phase2.5/`)
5. ✅ Transition automation script
6. ✅ Health check validation

**Expected Output:**

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              PHASE 2.5 DEPLOYMENT COMPLETE                     ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

---

### Step 16: Validate Phase 2.5 Deployment

```bash
chmod +x scripts/validate-phase-2.5-deployment.sh
./scripts/validate-phase-2.5-deployment.sh
```

**What this validates:**

1. ✅ Directory structure (all layers)
2. ✅ Landing pages (apex + beta)
3. ✅ Nginx configuration (dual-domain)
4. ✅ SSL certificates (IONOS)
5. ✅ Backend services (health checks)
6. ✅ Routing (OTT, V-Suite, API)
7. ✅ Transition automation
8. ✅ Logs (separation enforcement)
9. ✅ PR87 integration

**Expected Output:**

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                   ✓ ALL CHECKS PASSED                          ║
║                                                                ║
║          Phase 2.5 Deployment is Production Ready!             ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

---

### Step 17: Schedule Beta Transition (Nov 17, 2025)

**To schedule automatic cutover:**

```bash
# Edit root crontab
crontab -e

# Add this line to schedule transition for Nov 17, 2025 at 00:00 UTC:
0 0 17 11 2025 /opt/nexus-cos/scripts/beta-transition-cutover.sh >> /opt/nexus-cos/logs/phase2.5/transition/cutover.log 2>&1
```

**Verify cron entry:**

```bash
crontab -l | grep beta-transition
```

**Expected:** Entry should be listed

---

### Step 18: Test Phase 2.5 Endpoints

```bash
# Test OTT Frontend (Apex)
curl -I https://nexuscos.online/

# Test V-Suite Dashboard
curl -I https://nexuscos.online/v-suite/

# Test Beta Portal
curl -I https://beta.nexuscos.online/

# Test API Gateway
curl -I https://nexuscos.online/api/

# Test Health Endpoints
curl http://localhost:4000/health  # Gateway
curl http://localhost:3002/health  # V-Prompter
curl http://localhost:3041/health  # PV Keys
```

**Expected:** All return HTTP 200 or 301/302 (redirects)

---

### Step 19: Monitor Phase 2.5 Logs

```bash
# Monitor all Phase 2.5 logs
tail -f /opt/nexus-cos/logs/phase2.5/*/access.log

# Monitor OTT logs specifically
tail -f /opt/nexus-cos/logs/phase2.5/ott/access.log

# Monitor dashboard logs
tail -f /opt/nexus-cos/logs/phase2.5/dashboard/access.log

# Monitor beta logs
tail -f /opt/nexus-cos/logs/phase2.5/beta/access.log
```

---

### Step 20: Manual Transition Test (Optional)

**To test the transition script manually:**

```bash
# Run in dry-run/test mode first (backup will be created)
cd /opt/nexus-cos
./scripts/beta-transition-cutover.sh

# Verify beta now redirects to production
curl -I https://beta.nexuscos.online/
# Expected: Location: https://nexuscos.online/

# If issues, rollback is automatic in the script
```

---

## 🎯 Mission Complete

**When you see:**

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                   ✅ ALL CHECKS PASSED                         ║
║                                                                ║
║          Phase 2.5 Deployment is Production Ready!             ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

**The mission is complete. Nexus COS Phase 2.5 is live!**

### Phase 2.5 Success Criteria

✅ OTT Frontend operational at `nexuscos.online`  
✅ V-Suite Dashboard accessible at `nexuscos.online/v-suite/`  
✅ Beta Portal live at `beta.nexuscos.online`  
✅ All health endpoints returning HTTP 200  
✅ Dual-domain routing validated  
✅ SSL certificates valid for all domains  
✅ Logs separated by layer  
✅ Transition automation scheduled  
✅ PR87 integration validated

---

**Prepared By:** TRAE SOLO (GitHub Code Agent)  
**For:** Robert White (PUABO / Nexus COS Founder)  
**Phase:** 2.5 - OTT Integration + Beta Transition  
**PF ID:** PF-HYBRID-FULLSTACK-2025.10.07-PHASE-2.5  
**Status:** BULLETPROOFED | PRODUCTION READY | ZERO ERROR MARGIN  
**Date:** 2025-10-07  
**Transition Date:** November 17, 2025
