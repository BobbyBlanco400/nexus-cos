# 🔍 NEXUS COS - POST-DEPLOYMENT VERIFICATION GUIDE

**Version:** v2025.10.10 FINAL  
**Purpose:** Comprehensive verification procedures after VPS deployment  
**Date:** 2025-10-11

---

## 📋 OVERVIEW

This guide provides step-by-step verification procedures to confirm that your Nexus COS Beta deployment is fully operational and ready for production use.

---

## ✅ VERIFICATION STAGES

### Stage 1: Container Health (5 minutes)
### Stage 2: Service Connectivity (5 minutes)
### Stage 3: Database & Cache (3 minutes)
### Stage 4: Frontend Access (2 minutes)
### Stage 5: API Endpoints (5 minutes)
### Stage 6: Security & Configuration (5 minutes)

**Total Verification Time: ~25 minutes**

---

## 🔍 STAGE 1: CONTAINER HEALTH

### 1.1 Check All Containers Running

```bash
cd /opt/nexus-cos
docker compose -f docker-compose.unified.yml ps
```

**Expected Output:**
- Total containers: 44
- Status: All showing "Up" or "running"
- No containers in "Restarting" or "Exited" state

**Verification:**
```bash
# Count running containers
RUNNING=$(docker compose -f docker-compose.unified.yml ps --status running | wc -l)
echo "Running containers: $RUNNING/44"
```

✅ **Pass Criteria:** 44 containers running

### 1.2 Check Container Resource Usage

```bash
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

**Expected Output:**
- CPU usage: < 80% per container
- Memory usage: Reasonable per service (varies by service)
- No containers showing 0% CPU (indicates crashed service)

✅ **Pass Criteria:** All containers showing active resource usage

### 1.3 Check for Container Restart Loops

```bash
docker compose -f docker-compose.unified.yml ps --format json | jq -r '.[] | select(.Health != "healthy" and .Health != "") | .Name + ": " + .Health'
```

✅ **Pass Criteria:** No containers in restart loops or unhealthy state

---

## 🌐 STAGE 2: SERVICE CONNECTIVITY

### 2.1 Run Official Health Checks

```bash
cd /opt/nexus-cos
bash pf-health-check.sh
```

**Expected Output:**
```
========================================
PF Health Check - Nexus COS
========================================

Total Checks: [N]
Passed: [N]
Failed: 0

✅ All health checks passed!
PF stack is fully operational.
```

✅ **Pass Criteria:** All health checks passing (Failed: 0)

### 2.2 Manual Service Endpoint Testing

Test critical services manually:

```bash
# Hollywood/Gateway (Main API)
curl -I http://localhost:4000/health
# Expected: HTTP/1.1 200 OK

# Prompter/AI SDK
curl -I http://localhost:3002/health
# Expected: HTTP/1.1 200 OK

# PV Keys Service
curl -I http://localhost:3041/health
# Expected: HTTP/1.1 200 OK
```

✅ **Pass Criteria:** All endpoints return 200 OK

### 2.3 Check Service Logs for Errors

```bash
# Check last 50 lines of all services for errors
docker compose -f docker-compose.unified.yml logs --tail=50 2>&1 | grep -i "error\|fatal\|exception" | head -20
```

✅ **Pass Criteria:** No critical errors in recent logs

---

## 💾 STAGE 3: DATABASE & CACHE

### 3.1 Verify PostgreSQL Connectivity

```bash
# Check PostgreSQL container
docker compose -f docker-compose.unified.yml exec nexus-cos-postgres pg_isready -U postgres
# Expected: "accepting connections"

# Check database existence
docker compose -f docker-compose.unified.yml exec nexus-cos-postgres psql -U postgres -c "\l"
```

✅ **Pass Criteria:** PostgreSQL accepting connections

### 3.2 Verify Redis Connectivity

```bash
# Check Redis container
docker compose -f docker-compose.unified.yml exec nexus-cos-redis redis-cli ping
# Expected: PONG

# Check Redis info
docker compose -f docker-compose.unified.yml exec nexus-cos-redis redis-cli info server | grep redis_version
```

✅ **Pass Criteria:** Redis responding to commands

### 3.3 Database Connection from Services

```bash
# Check service database connections
docker compose -f docker-compose.unified.yml logs | grep -i "database.*connect\|postgres.*connect" | tail -10
```

✅ **Pass Criteria:** Services successfully connecting to database

---

## 🌐 STAGE 4: FRONTEND ACCESS

### 4.1 Test Beta Landing Page

```bash
# Test local access
curl -I http://localhost/
# Expected: HTTP/1.1 200 OK

# Test with domain (if DNS configured)
curl -I http://beta.n3xuscos.online/
# Expected: HTTP/1.1 200 OK
```

### 4.2 Verify Static Assets

```bash
# Check if CSS/JS/images are accessible
curl -I http://localhost/assets/ 2>&1 | grep "HTTP"
curl -I http://localhost/css/ 2>&1 | grep "HTTP"
curl -I http://localhost/js/ 2>&1 | grep "HTTP"
```

✅ **Pass Criteria:** Landing page and assets accessible

### 4.3 Browser Testing

**Manual Steps:**
1. Open browser: `http://[VPS-IP]` or `http://beta.n3xuscos.online`
2. Verify page loads completely
3. Check for console errors (F12 → Console)
4. Verify all images load
5. Test navigation/links

✅ **Pass Criteria:** Page loads without errors, all assets display

---

## 🔌 STAGE 5: API ENDPOINTS

### 5.1 Test Core API Endpoints

```bash
# Create test script
cat > /tmp/test-endpoints.sh << 'EOF'
#!/bin/bash
echo "Testing Nexus COS API Endpoints..."
echo ""

# Test Gateway
echo -n "Gateway Health: "
curl -s http://localhost:4000/health | grep -q "ok" && echo "✅ PASS" || echo "❌ FAIL"

# Test AI SDK
echo -n "AI SDK Health: "
curl -s http://localhost:3002/health | grep -q "ok" && echo "✅ PASS" || echo "❌ FAIL"

# Test PV Keys
echo -n "PV Keys Health: "
curl -s http://localhost:3041/health | grep -q "ok" && echo "✅ PASS" || echo "❌ FAIL"

echo ""
echo "API Endpoint Testing Complete"
EOF

bash /tmp/test-endpoints.sh
```

✅ **Pass Criteria:** All API endpoints responding correctly

### 5.2 Test Module Endpoints

For each major module, verify its health endpoint responds:

```bash
# Test all module health endpoints
for port in 3000 3001 3002 3003 3004 3005 3006 3007 3008 3009 3010; do
    echo -n "Port $port: "
    curl -sf http://localhost:$port/health > /dev/null && echo "✅" || echo "❌"
done
```

✅ **Pass Criteria:** All module endpoints accessible

---

## 🔒 STAGE 6: SECURITY & CONFIGURATION

### 6.1 Verify Environment Configuration

```bash
# Check .env.pf exists and has proper permissions
ls -la /opt/nexus-cos/.env.pf
# Expected: -rw------- (600 permissions)

# Verify no default passwords remain
grep -i "password_here\|changeme\|default" /opt/nexus-cos/.env.pf
# Expected: No output (all defaults changed)
```

✅ **Pass Criteria:** Environment properly secured

### 6.2 Check Network Security

```bash
# Verify firewall rules
sudo ufw status
# Expected: 22/tcp, 80/tcp, 443/tcp ALLOW

# Check open ports
sudo netstat -tulpn | grep LISTEN | grep -E ':(80|443|22)\s'
```

✅ **Pass Criteria:** Only required ports open

### 6.3 Verify SSL/TLS (If Configured)

```bash
# Test SSL certificate (if configured)
curl -I https://beta.n3xuscos.online/ 2>&1 | grep "HTTP"
# Expected: HTTP/2 200 or HTTP/1.1 200

# Check certificate validity
echo | openssl s_client -servername beta.n3xuscos.online -connect beta.n3xuscos.online:443 2>/dev/null | openssl x509 -noout -dates
```

✅ **Pass Criteria:** Valid SSL certificate (if using HTTPS)

---

## 📊 COMPREHENSIVE VERIFICATION SCRIPT

Run this automated comprehensive check:

```bash
cat > /tmp/comprehensive-verify.sh << 'EOF'
#!/bin/bash
set +e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     NEXUS COS - COMPREHENSIVE POST-DEPLOYMENT VERIFICATION     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

PASS=0
FAIL=0

# Container count
echo -n "Container Count Check: "
RUNNING=$(docker compose -f docker-compose.unified.yml ps --status running 2>/dev/null | wc -l)
if [ "$RUNNING" -ge 44 ]; then
    echo "✅ PASS ($RUNNING running)"
    ((PASS++))
else
    echo "❌ FAIL (Only $RUNNING running, expected 44)"
    ((FAIL++))
fi

# Health checks
echo -n "Health Check Script: "
if bash /opt/nexus-cos/pf-health-check.sh &> /dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# PostgreSQL
echo -n "PostgreSQL Connectivity: "
if docker compose -f docker-compose.unified.yml exec -T nexus-cos-postgres pg_isready -U postgres &> /dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Redis
echo -n "Redis Connectivity: "
if docker compose -f docker-compose.unified.yml exec -T nexus-cos-redis redis-cli ping 2>&1 | grep -q "PONG"; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Frontend
echo -n "Frontend Accessibility: "
if curl -sf http://localhost/ > /dev/null 2>&1; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# API Gateway
echo -n "API Gateway: "
if curl -sf http://localhost:4000/health > /dev/null 2>&1; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "VERIFICATION SUMMARY"
echo "════════════════════════════════════════════════════════════════"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "✅ ALL VERIFICATIONS PASSED - DEPLOYMENT SUCCESSFUL"
    exit 0
else
    echo "❌ SOME VERIFICATIONS FAILED - REVIEW REQUIRED"
    exit 1
fi
EOF

chmod +x /tmp/comprehensive-verify.sh
bash /tmp/comprehensive-verify.sh
```

---

## 🚨 TROUBLESHOOTING FAILED VERIFICATIONS

### If Container Count < 44

```bash
# See which containers failed
docker compose -f docker-compose.unified.yml ps -a

# Check failed container logs
docker compose -f docker-compose.unified.yml logs [failed-container-name]

# Restart failed containers
docker compose -f docker-compose.unified.yml restart [container-name]
```

### If Health Checks Fail

```bash
# Wait for services to fully initialize
sleep 180  # Wait 3 minutes

# Re-run health checks
bash pf-health-check.sh

# If still failing, check specific service logs
docker compose -f docker-compose.unified.yml logs -f [service-name]
```

### If Database Connection Fails

```bash
# Check PostgreSQL logs
docker compose -f docker-compose.unified.yml logs nexus-cos-postgres

# Verify environment variables
docker compose -f docker-compose.unified.yml exec nexus-cos-postgres env | grep POSTGRES

# Try manual connection
docker compose -f docker-compose.unified.yml exec nexus-cos-postgres psql -U postgres
```

### If Frontend Not Accessible

```bash
# Check nginx/web server logs
docker compose -f docker-compose.unified.yml logs | grep -i nginx

# Verify web files exist
ls -la /opt/nexus-cos/web/beta/

# Check port bindings
docker compose -f docker-compose.unified.yml port [web-service-name] 80
```

---

## ✅ FINAL VERIFICATION CHECKLIST

Before announcing beta launch, confirm:

- [ ] All 44 containers running
- [ ] pf-health-check.sh passes (0 failures)
- [ ] PostgreSQL accepting connections
- [ ] Redis responding to commands
- [ ] Frontend accessible via browser
- [ ] API endpoints responding correctly
- [ ] No critical errors in logs
- [ ] Environment properly secured
- [ ] Firewall configured correctly
- [ ] SSL/TLS configured (if applicable)

---

## 📝 VERIFICATION REPORT TEMPLATE

Document your verification results:

```
=== NEXUS COS POST-DEPLOYMENT VERIFICATION REPORT ===

Date: [YYYY-MM-DD]
Time: [HH:MM UTC]
Verified By: [Name]

STAGE 1: CONTAINER HEALTH
- Containers Running: [N]/44
- Resource Usage: [NORMAL/ABNORMAL]
- Restart Loops: [NONE/DETECTED]
- Status: [✅ PASS / ❌ FAIL]

STAGE 2: SERVICE CONNECTIVITY
- Health Check Script: [✅ PASS / ❌ FAIL]
- Manual Endpoint Tests: [✅ PASS / ❌ FAIL]
- Log Errors: [NONE/PRESENT]
- Status: [✅ PASS / ❌ FAIL]

STAGE 3: DATABASE & CACHE
- PostgreSQL: [✅ PASS / ❌ FAIL]
- Redis: [✅ PASS / ❌ FAIL]
- Service Connections: [✅ PASS / ❌ FAIL]
- Status: [✅ PASS / ❌ FAIL]

STAGE 4: FRONTEND ACCESS
- Landing Page: [✅ PASS / ❌ FAIL]
- Static Assets: [✅ PASS / ❌ FAIL]
- Browser Test: [✅ PASS / ❌ FAIL]
- Status: [✅ PASS / ❌ FAIL]

STAGE 5: API ENDPOINTS
- Core APIs: [✅ PASS / ❌ FAIL]
- Module APIs: [✅ PASS / ❌ FAIL]
- Status: [✅ PASS / ❌ FAIL]

STAGE 6: SECURITY & CONFIGURATION
- Environment: [✅ PASS / ❌ FAIL]
- Firewall: [✅ PASS / ❌ FAIL]
- SSL/TLS: [✅ PASS / N/A / ❌ FAIL]
- Status: [✅ PASS / ❌ FAIL]

OVERALL STATUS: [✅ VERIFIED / ❌ ISSUES FOUND]

Issues Found: [NONE / LIST]
Resolutions Applied: [N/A / LIST]

Deployment Ready for Production: [YES / NO]
Beta Launch Announced: [YES / NO]

Notes:
[Additional observations]
```

---

## 🎉 SUCCESS CONFIRMATION

When all verifications pass:

1. ✅ **Document success** - Save verification report
2. 📸 **Take screenshots** - Evidence of successful deployment
3. 🎊 **Announce launch** - Post on social media/channels
4. 📧 **Notify stakeholders** - Send confirmation emails
5. 📊 **Monitor metrics** - Track performance for first 24 hours

---

**END OF VERIFICATION GUIDE**

For additional support:
- Review `DEPLOYMENT_TROUBLESHOOTING_REPORT.md`
- Check `TRAE_SOLO_DEPLOYMENT_GUIDE.md`
- Visit: https://github.com/BobbyBlanco400/nexus-cos/issues
