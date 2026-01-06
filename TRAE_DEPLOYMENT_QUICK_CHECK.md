# Nexus COS - TRAE Deployment Quick Check

## 🚀 Quick Validation Commands

Use these commands to quickly verify TRAE's deployment claims:

### 1. Domain & Health Check (10 seconds)
```bash
# Root domain
curl -I https://n3xuscos.online/

# Health endpoint
curl -s https://n3xuscos.online/health | jq '.'
```

**Expected:**
- Root: `HTTP/2 200`
- Health: `{"status":"ok","env":"production"}`

---

### 2. V-Screen Routes (15 seconds)
```bash
# Primary route
curl -I https://n3xuscos.online/v-suite/screen

# Alternative route
curl -I https://n3xuscos.online/v-screen
```

**Expected:** Both return `HTTP/2 200`

---

### 3. Container Health (20 seconds - requires VPS access)
```bash
ssh root@n3xuscos.online "docker ps --format 'table {{.Names}}\t{{.Status}}'"
```

**Expected:** All containers show `Up` with `(healthy)` where applicable

---

### 4. Prompter Pro & PUABO API Logs (30 seconds - requires VPS access)
```bash
# Prompter Pro (AI SDK)
ssh root@n3xuscos.online "docker logs nexus-cos-puaboai-sdk --tail 100"

# PUABO API
ssh root@n3xuscos.online "docker logs puabo-api --tail 100"
```

**Look for:** No error messages, successful startup

---

### 5. Nginx Configuration (5 seconds - requires VPS access)
```bash
ssh root@n3xuscos.online "nginx -t"
```

**Expected:** 
```
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

**Note:** Warning about `server_name _` is non-blocking and expected.

---

## 🔍 Automated Verification Script

**Run the comprehensive verification script:**

```bash
./verify-trae-deployment.sh
```

This script automatically checks:
- ✅ Domain accessibility
- ✅ Health endpoint validity
- ✅ V-Screen route availability
- ✅ V-Suite Prompter health
- ✅ SSL/TLS configuration
- ✅ Security headers
- ✅ HTTP to HTTPS redirects

**Expected Output:**
```
✓ ALL CHECKS PASSED
Deployment verified successfully!
READY FOR PRODUCTION LAUNCH 🚀
```

---

## ✅ Quick Launch Checklist

**Check these 5 items before launch:**

1. [ ] `curl -I https://n3xuscos.online/` returns 200
2. [ ] `curl -s https://n3xuscos.online/health | jq '.status'` returns `"ok"`
3. [ ] `curl -I https://n3xuscos.online/v-suite/screen` returns 200
4. [ ] All containers show `Up` status
5. [ ] No critical errors in container logs

**If all 5 pass → READY FOR LAUNCH! 🚀**

---

## 🔧 Container Health Check Commands

```bash
# View all container statuses
docker ps --format 'table {{.Names}}\t{{.Status}}'

# Check specific container logs
docker logs puabo-api --tail 100
docker logs nexus-cos-puaboai-sdk --tail 100
docker logs nexus-cos-postgres --tail 50
docker logs nexus-cos-redis --tail 50
docker logs nexus-cos-pv-keys --tail 50
docker logs vscreen-hollywood --tail 100
```

---

## 📊 Health Check Endpoints

Test all health endpoints at once:

```bash
for endpoint in /health /v-suite/screen /v-screen /v-suite/prompter/health; do
  echo "Testing: https://n3xuscos.online$endpoint"
  curl -I https://n3xuscos.online$endpoint 2>&1 | head -1
  echo ""
done
```

---

## 🎯 One-Line Full Validation

**Complete validation in one command:**

```bash
./verify-trae-deployment.sh && echo "✅ READY FOR LAUNCH"
```

---

## 🚨 Troubleshooting Quick Reference

### If Root Domain Fails
```bash
# Check Nginx status
ssh root@n3xuscos.online "systemctl status nginx"

# Check Nginx config
ssh root@n3xuscos.online "nginx -t"

# Reload Nginx
ssh root@n3xuscos.online "systemctl reload nginx"
```

### If Health Endpoint Fails
```bash
# Check API container
ssh root@n3xuscos.online "docker ps | grep puabo-api"

# View API logs
ssh root@n3xuscos.online "docker logs puabo-api --tail 100"

# Restart API
ssh root@n3xuscos.online "docker restart puabo-api"
```

### If V-Screen Routes Fail
```bash
# Check V-Screen container
ssh root@n3xuscos.online "docker ps | grep vscreen-hollywood"

# View logs
ssh root@n3xuscos.online "docker logs vscreen-hollywood --tail 100"

# Restart container
ssh root@n3xuscos.online "docker restart vscreen-hollywood"
```

### If Database Connection Fails
```bash
# Check PostgreSQL
ssh root@n3xuscos.online "docker exec nexus-cos-postgres pg_isready -U nexus_user"

# Check database logs
ssh root@n3xuscos.online "docker logs nexus-cos-postgres --tail 100"
```

---

## 📱 Mobile-Friendly Test URLs

Open these URLs in a browser to visually verify:

1. **Root Domain:** https://n3xuscos.online/
2. **Health Check:** https://n3xuscos.online/health
3. **V-Screen:** https://n3xuscos.online/v-suite/screen
4. **V-Screen Alt:** https://n3xuscos.online/v-screen

---

## 📈 Success Indicators

### ✅ Good Signs
- All containers show `Up (healthy)`
- Health endpoint returns JSON with `status: "ok"`
- V-Screen routes return 200
- No error messages in recent logs
- Nginx config test passes

### ⚠️ Warning Signs
- Containers show `Up` but not `(healthy)` - check health checks
- Health endpoint shows `db: "down"` - configure database
- Some optional routes return 404 - expected for undeployed services

### 🚨 Critical Issues
- Containers show `Restarting` - check logs immediately
- Health endpoint returns 502/503 - service is down
- V-Screen routes return 502 - container not running
- Critical errors in logs - investigate and fix

---

## 🎉 Launch Confidence Statement

**You can launch with confidence when:**

1. ✅ All containers are `Up (healthy)`
2. ✅ Health endpoint returns `status: "ok"` and `env: "production"`
3. ✅ V-Screen routes accessible (both `/v-suite/screen` and `/v-screen`)
4. ✅ No critical errors in container logs
5. ✅ Nginx configuration valid
6. ✅ SSL certificates valid

**If all 6 criteria are met → EVERYTHING IS WIRED RIGHT! 🚀**

---

## 📞 Quick Support

### Get Full Report
```bash
./verify-trae-deployment.sh
cat /tmp/trae-deployment-verification-*.txt
```

### View All Logs
```bash
ssh root@n3xuscos.online "docker-compose -f /opt/nexus-cos/docker-compose.pf.yml logs --tail=100"
```

### Restart All Services
```bash
ssh root@n3xuscos.online "cd /opt/nexus-cos && docker-compose -f docker-compose.pf.yml restart"
```

---

## 📚 Related Documentation

- **Full Verification Guide:** `DEPLOYMENT_VERIFICATION_TRAE.md`
- **Automated Script:** `verify-trae-deployment.sh`
- **Health Check Script:** `pf-health-check.sh`
- **Deployment Status:** `DEPLOYMENT_STATUS_AND_NEXT_MOVES.md`
- **VPS Guide:** `VPS_DEPLOYMENT_GUIDE.md`

---

**Remember:** The deployment is wired correctly if all endpoints respond and containers are healthy. Launch with confidence! 🚀
