# Nexus COS — MASTER PF (GitHub-Ready, Commercial-Grade)

**Status:** ✅ Production-Frozen · Beta/Additive Enabled  
**Platform:** Nexus COS (PUABO Stack)  
**Domain:** https://n3xuscos.online  
**Authoritative Frontend Entry:** https://n3xuscos.online/streaming/  

---

## 1. Executive Launch Declaration (LOCKED)

**As of 12/16/2025 @ 4:01 PM UTC:**  
Nexus COS platform is **fully deployed, verified live over HTTPS, and production-frozen** per owner directive.

**Key Points:**
- ✅ All core infrastructure, frontend routing, backend services, handshake headers, and legal artifacts **validated and locked**
- ✅ No partial state exists
- ✅ No alternative launch outcome accepted
- ✅ **Production endpoints are untouchable** — all new modules are **additive only**

---

## 2. Authoritative Frontend Entry — Nexus Stream

**Canonical Public Entry:**  
👉 **https://n3xuscos.online/streaming/**

**Supported Deep Links (Production):**
- `/streaming/catalog`
- `/streaming/status`
- `/streaming/test`

**Runtime Behavior:**
- HTTP 200 OK responses
- Header: `X-Nexus-Handshake: 55-45-17`
- Header: `X-Location-Tag: streaming`
- Serves SPA from Vite/React build output

**Sources:**
- nginx.conf (main domain configuration)
- Docker service on port 3047 (streaming UI)

**Rules:**
- ✅ Must remain intact, **no alterations**
- ✅ Must always serve SPA from Vite/React build output
- ✅ All internal routing locked to `/streaming/*` for UX integrity

---

## 3. Backend & Handshake Verification

**Production endpoints live over HTTPS:**
- `/status` - System status check
- `/catalog` - Content catalog
- `/test` - Test endpoint

**Handshake Header Enforced:**
```
X-Nexus-Handshake: 55-45-17
```

**Sources:**
- `services/v-caster-pro/server.js`
- `server-lite.js`

**Process Management:**
- PM2 persistence confirmed
- All services auto-restart on failure

---

## 4. Legal Lock & Timestamp

**Official Launch Timestamp:**  
📅 **12/16/2025 @ 4:01 PM UTC**

**Coverage:**
- Domain: n3xuscos.online
- All documented endpoints
- Proxy intent: `/streaming/` → `127.0.0.1:3047`

**Ownership & Control:**
- **Owner:** Robert White Living Trust
- **Trustor:** Robert White
- **Trustees:** 6 children
- **IP Status:** Trust-owned, licensed
- **Coverage Window:** 12/16/2025 → 01/01/2026

**Legal Documentation:**
- Reference: `legal/Master Folder/Nexus COS/Corporate Framework/Nexus-COS_Legal-Packet_v2025.10.13_FINAL.md`

---

## 5. Beta Domain Add-In (Additive Only)

### 5.1 Beta Domain Configuration

**Domain:** beta.n3xuscos.online

**Endpoints:**
- `/` - Beta home/streaming
- `/catalog` - Beta catalog
- `/status` - Beta status
- `/test` - Beta test endpoint

**Handshake Header:**
```
X-Nexus-Handshake: beta-55-45-17
```

**Verification Requirements:**
- ✅ HTTP 200 OK responses
- ✅ Handshake headers present on all endpoints
- ✅ No production mutation
- ✅ Independent SPA serving from `/var/www/beta-nexuscos/frontend/dist`

### 5.2 Beta Nginx Configuration

**Location:** Plesk > Domains > beta.n3xuscos.online > Apache & nginx Settings > "Additional nginx directives"

**Configuration:**

```nginx
# Beta Domain - Nexus COS
# Handshake: beta-55-45-17
# Root: /var/www/beta-nexuscos/frontend/dist

location / {
    root /var/www/beta-nexuscos/frontend/dist;
    try_files $uri /index.html;
    add_header X-Nexus-Handshake "beta-55-45-17" always;
    add_header X-Environment "beta" always;
}

location = /catalog {
    root /var/www/beta-nexuscos/frontend/dist;
    try_files $uri /index.html;
    add_header X-Nexus-Handshake "beta-55-45-17" always;
    add_header X-Environment "beta" always;
}

location = /status {
    root /var/www/beta-nexuscos/frontend/dist;
    try_files $uri /index.html;
    add_header X-Nexus-Handshake "beta-55-45-17" always;
    add_header X-Environment "beta" always;
}

location = /test {
    root /var/www/beta-nexuscos/frontend/dist;
    try_files $uri /index.html;
    add_header X-Nexus-Handshake "beta-55-45-17" always;
    add_header X-Environment "beta" always;
}
```

### 5.3 Beta Domain Verification Commands

**Test from VPS server:**

```bash
# Reload nginx after adding directives
sudo systemctl reload nginx

# Verify all beta endpoints return correct headers
for endpoint in / /catalog /status /test; do
    echo "Testing: https://beta.n3xuscos.online${endpoint}"
    curl -sSkI "https://beta.n3xuscos.online${endpoint}" | grep -i '^X-Nexus-Handshake'
    curl -sSkI "https://beta.n3xuscos.online${endpoint}" | grep -i '^X-Environment'
    echo "---"
done
```

**Expected Output:**
```
X-Nexus-Handshake: beta-55-45-17
X-Environment: beta
```

### 5.4 Hoppscotch Testing Setup (MANDATORY)

**Testing Tool:** https://hoppscotch.io

**Setup Steps:**

1. Open https://hoppscotch.io
2. Create new collection: "Nexus COS Beta Verification"
3. Add requests for each endpoint:

   **Request 1: Beta Root**
   - Method: GET
   - URL: https://beta.n3xuscos.online/
   - Expected: HTTP 200, X-Nexus-Handshake: beta-55-45-17

   **Request 2: Beta Catalog**
   - Method: GET
   - URL: https://beta.n3xuscos.online/catalog
   - Expected: HTTP 200, X-Nexus-Handshake: beta-55-45-17

   **Request 3: Beta Status**
   - Method: GET
   - URL: https://beta.n3xuscos.online/status
   - Expected: HTTP 200, X-Nexus-Handshake: beta-55-45-17

   **Request 4: Beta Test**
   - Method: GET
   - URL: https://beta.n3xuscos.online/test
   - Expected: HTTP 200, X-Nexus-Handshake: beta-55-45-17

4. Save collection for repeated testing
5. Run all requests to verify beta domain

---

## 6. Production Deployment (One Command)

### 6.1 Master Deployment Script

**Deployment Command:**

```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/copilot/fix-global-launch-issues/deploy-nexus-cos-master.sh | sudo bash
```

**What This Script Does:**

1. ✅ **System Requirements** - Installs Docker, Docker Compose, Git, Nginx, curl, OpenSSL
2. ✅ **Repository Setup** - Clones repository with all fixes
3. ✅ **Environment Configuration** - Creates `.env.pf` with secure credentials
4. ✅ **SSL Certificates** - Sets up SSL for both domains
5. ✅ **Firewall Configuration** - Configures UFW (ports 22, 80, 443)
6. ✅ **Docker Networks** - Creates `cos-net` and `nexus-network`
7. ✅ **Docker Services** - Deploys all services via docker-compose.pf.yml
8. ✅ **Nginx Configuration** - Copies nginx.conf, validates, enables service
9. ✅ **Health Checks** - Tests all endpoints
10. ✅ **Final Verification** - Displays status and next steps

**Deployment Time:** 10-15 minutes  
**Result:** Complete Nexus COS Platform deployed and operational

### 6.2 Post-Deployment Verification

**Run on your VPS server:**

```bash
# Main domain - Streaming UI
curl -I https://n3xuscos.online/ | head -n1  # Should return 200

# Platform launcher
curl -I https://n3xuscos.online/platform | head -n1  # Should return 200

# Brand check
curl -I https://n3xuscos.online/brand-check | head -n1  # Should return 200

# API endpoints
curl -I https://n3xuscos.online/api/status | head -n1  # Should return 200
curl -I https://n3xuscos.online/api/health | head -n1  # Should return 200

# V-Suite modules
curl -I https://n3xuscos.online/v-suite/hollywood | head -n1
curl -I https://n3xuscos.online/v-suite/stage | head -n1
curl -I https://n3xuscos.online/v-suite/caster | head -n1
curl -I https://n3xuscos.online/v-suite/prompter | head -n1

# Local service health
curl -sI http://localhost:4000/health | head -n1  # PF API
curl -sI http://localhost:3002/health | head -n1  # AI SDK
curl -sI http://localhost:3041/health | head -n1  # PV Keys
curl -sI http://localhost:3016/health | head -n1  # StreamCore
curl -sI http://localhost:8088/health | head -n1  # V-Screen Hollywood

# Check running ports
ss -tln | awk 'NR==1 || /:(4000|3002|3041|3016|8088|3231|3232|3233|3234)\b/'
```

---

## 7. Beta Domain Manual Setup (After Production Deploy)

**After running the master deployment script, manually configure beta domain:**

### Step 1: DNS Configuration
- Ensure `beta.n3xuscos.online` points to your VPS IP
- Wait for DNS propagation (5-10 minutes)

### Step 2: Plesk Beta Domain Setup
1. Log into Plesk
2. Go to: Domains > Add Domain
3. Domain name: `beta.n3xuscos.online`
4. Document root: `/var/www/beta-nexuscos/frontend/dist`
5. SSL/TLS: Enable Let's Encrypt

### Step 3: Add Nginx Directives
1. Go to: Domains > beta.n3xuscos.online > Apache & nginx Settings
2. Scroll to "Additional nginx directives"
3. Paste the beta nginx configuration from section 5.2
4. Click "Apply"

### Step 4: Create Beta Frontend Directory
```bash
sudo mkdir -p /var/www/beta-nexuscos/frontend/dist
sudo chown -R www-data:www-data /var/www/beta-nexuscos
```

### Step 5: Deploy Beta Frontend
```bash
# Copy production build or deploy separate beta build
sudo cp -r /opt/nexus-cos/frontend/dist/* /var/www/beta-nexuscos/frontend/dist/
```

### Step 6: Reload Nginx
```bash
sudo nginx -t && sudo systemctl reload nginx
```

### Step 7: Verify Beta Domain
```bash
# Run verification commands from section 5.3
curl -I https://beta.n3xuscos.online/ | grep "X-Nexus-Handshake"
```

---

## 8. Final Launch Checklist

### Production Domain (n3xuscos.online)
- [x] Database driver fixed (MySQL → PostgreSQL)
- [x] Missing API endpoints added (/api/status, /api/health)
- [x] Service paths corrected
- [x] Netflix-style streaming UI at root (/)
- [x] Platform launcher (/platform)
- [x] Intelligent fallback (/pf-fallback)
- [x] Brand validation (/brand-check)
- [x] All V-Suite routes operational
- [x] All documented API endpoints functional
- [x] Security hardening (rate limiting)
- [x] SSL certificates configured
- [x] Error interception enabled

### Beta Domain (beta.n3xuscos.online)
- [ ] DNS configured and propagated
- [ ] Plesk domain added
- [ ] SSL certificate active
- [ ] Nginx directives applied
- [ ] Frontend deployed
- [ ] All endpoints return 200
- [ ] Handshake headers present
- [ ] Hoppscotch collection created
- [ ] Verification tests passing

### Legal & Documentation
- [x] Launch timestamp recorded (12/16/2025 @ 4:01 PM UTC)
- [x] Legal packet updated
- [x] Architecture documentation complete
- [x] Deployment guides created
- [x] Verification commands documented

---

## 9. Support & Troubleshooting

### Common Issues

**Issue: Beta domain returns 404**
- Check DNS propagation: `dig beta.n3xuscos.online`
- Verify nginx config: `sudo nginx -t`
- Check document root exists: `ls -la /var/www/beta-nexuscos/frontend/dist`

**Issue: Missing handshake headers**
- Verify nginx directives applied in Plesk
- Reload nginx: `sudo systemctl reload nginx`
- Check headers: `curl -I https://beta.n3xuscos.online/ | grep X-Nexus-Handshake`

**Issue: SSL certificate errors**
- Check Let's Encrypt in Plesk
- Manually renew: `certbot renew`

### Deployment Logs
- Main deployment: `/var/log/nexus-cos-deployment.log`
- Nginx errors: `/var/log/nginx/error.log`
- Nginx access: `/var/log/nginx/access.log`

### Contact
For deployment support, refer to:
- `DEPLOYMENT_GUIDE.md` - Complete deployment instructions
- `DEPLOY_DIRECT_GUIDE.md` - Manual deployment steps
- `SECURITY_SUMMARY.md` - Security review and checklist

---

## 10. Final Status

**Platform Status:** ✅ PRODUCTION READY  
**Production Domain:** ✅ FULLY OPERATIONAL  
**Beta Domain:** ⏳ READY FOR MANUAL SETUP  
**All Critical Issues:** ✅ RESOLVED  
**Documentation:** ✅ COMPLETE  
**Security:** ✅ REVIEWED  
**Deployment:** ✅ ONE-COMMAND AVAILABLE  

---

**🚀 READY TO LAUNCH INTO THE PUABOVERSE! 🚀**

Deploy now with:
```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/copilot/fix-global-launch-issues/deploy-nexus-cos-master.sh | sudo bash
```

Then manually configure beta domain following Section 7.

---

*Document Version: 1.0*  
*Last Updated: 12/18/2025*  
*Repository: BobbyBlanco400/nexus-cos*  
*Branch: copilot/fix-global-launch-issues*
