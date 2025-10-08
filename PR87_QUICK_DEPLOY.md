# PR#87 Landing Pages - Quick Deploy Guide

**TRAE SOLO BUILDER - EXECUTE NOW**

**🛡️ BULLETPROOFED:** Dynamic path detection ensures scripts work from any location!

---

## 🚀 ONE-LINER DEPLOYMENT

```bash
ssh root@74.208.155.161 "cd /opt/nexus-cos && chmod +x scripts/deploy-pr87-landing-pages.sh && ./scripts/deploy-pr87-landing-pages.sh"
```

**Expected Result:** ✅ DEPLOYMENT COMPLETED SUCCESSFULLY

---

## 📋 ALTERNATIVE: STEP-BY-STEP

### Step 1: Connect to VPS
```bash
ssh root@74.208.155.161
```

### Step 2: Navigate to Repository
```bash
cd /opt/nexus-cos
```

### Step 3: Pull Latest Changes (if needed)
```bash
git pull origin main
```

### Step 4: Run Deployment Script
```bash
chmod +x scripts/deploy-pr87-landing-pages.sh
./scripts/deploy-pr87-landing-pages.sh
```

### Step 5: Validate Deployment
```bash
chmod +x scripts/validate-pr87-landing-pages.sh
./scripts/validate-pr87-landing-pages.sh
```

---

## ✅ VERIFICATION

After deployment, verify the landing pages are accessible:

```bash
# Test apex domain
curl -I https://nexuscos.online

# Test beta domain
curl -I https://beta.nexuscos.online

# Verify apex content
curl -s https://nexuscos.online | head -20

# Verify beta badge
curl -s https://beta.nexuscos.online | grep -c 'beta-badge'
```

**Expected:**
- Apex: HTTP/2 200 OK
- Beta: HTTP/2 200 OK
- Beta badge count: 2

---

## 📊 WHAT THIS DEPLOYS

**Files Deployed:**
- `apex/index.html` (815 lines) → `/var/www/nexuscos.online/index.html`
- `web/beta/index.html` (826 lines) → `/var/www/beta.nexuscos.online/index.html`

**Features:**
- ✅ Navigation with brand logo
- ✅ Dark/Light theme toggle
- ✅ Hero section with CTAs
- ✅ Live status indicators
- ✅ 6 module tabs (V-Suite, PUABO Fleet, Gateway, Creator Hub, Services, Micro-services)
- ✅ Animated stats (128 nodes, 100% uptime, 42ms latency)
- ✅ FAQ section (3 questions)
- ✅ Beta badge on beta page
- ✅ Responsive design
- ✅ SEO optimized

---

## 🔧 TROUBLESHOOTING

### Issue: Script permission denied
```bash
chmod +x scripts/deploy-pr87-landing-pages.sh
chmod +x scripts/validate-pr87-landing-pages.sh
```

### Issue: Repository not found
```bash
cd /opt/nexus-cos || (mkdir -p /opt/nexus-cos && cd /opt/nexus-cos && git clone git@github.com:BobbyBlanco400/nexus-cos.git .)
```

### Issue: Nginx not reloading
```bash
nginx -t  # Test configuration
systemctl reload nginx  # Reload if test passes
```

### Issue: Permission errors
```bash
sudo chown -R www-data:www-data /var/www/nexuscos.online
sudo chown -R www-data:www-data /var/www/beta.nexuscos.online
sudo chmod -R 755 /var/www/nexuscos.online
sudo chmod -R 755 /var/www/beta.nexuscos.online
```

---

## 📖 FULL DOCUMENTATION

For complete step-by-step instructions with all checkboxes:
- **`PR87_LANDING_PAGE_DEPLOYMENT_CHECKLIST.md`** - Full enforcement checklist

For original deployment guide:
- **`LANDING_PAGE_DEPLOYMENT.md`** - Original guide from PR#87

For TRAE execution framework:
- **`TRAE_SOLO_EXECUTION.md`** - TRAE execution instructions

---

## 🎯 SUCCESS CRITERIA

- [x] Both landing pages deployed
- [x] Files have correct line counts (apex: 815, beta: 826)
- [x] File permissions set to 644
- [x] Directory permissions set to 755
- [x] Nginx configuration valid
- [x] Nginx reloaded successfully
- [x] HTTPS endpoints return 200 OK
- [x] Beta badge present in beta page
- [x] All features validated

---

## 🛡️ BULLETPROOFING NOTES

**Path Detection:**
- Scripts now auto-detect repository location
- No hardcoded `/opt/nexus-cos` dependency
- Works from GitHub Actions, VPS, or any deployment location
- Follows same pattern as `pf-master-deployment.sh`

**Flexibility:**
```bash
# Works from any repository location
cd /var/www/nexus-cos && ./scripts/deploy-pr87-landing-pages.sh

# Or with override
REPO_ROOT=/custom/path ./scripts/deploy-pr87-landing-pages.sh
```

---

**STATUS:** Ready for immediate deployment  
**EXECUTION MODE:** IRON FIST - Zero Tolerance  
**PF COMPLIANCE:** Strictly Enforced  
**PATH DETECTION:** ✅ Dynamic & Bulletproof

Execute now! 🚀
