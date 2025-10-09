# 🚀 Nexus COS Phase 2.5 - Deployment Guide

## ✨ One-Command Deployment (Recommended)

Deploy the entire Phase 2.5 architecture with a single command:

```bash
cd /opt/nexus-cos && sudo ./DEPLOY_PHASE_2.5.sh
```

**That's it!** The script will:
- ✅ Deploy apex landing page to nexuscos.online
- ✅ Deploy beta landing page to beta.nexuscos.online  
- ✅ Configure Nginx with Phase 2.5 routing
- ✅ Verify unified Nexus COS branding (#2563eb)
- ✅ Validate all deployments automatically
- ✅ Report success or failure clearly

---

## 📋 Prerequisites

Before deploying, ensure:

1. **Repository Location**: Code must be at `/opt/nexus-cos`
2. **Root Access**: Run deployment with `sudo`
3. **System Requirements**:
   - Nginx installed
   - Docker installed and running
   - SSL certificates configured (IONOS)
   - DNS pointing to your VPS

---

## 🎯 What Gets Deployed

### Three System Layers

| Layer | Domain/Path | Purpose |
|-------|-------------|---------|
| **OTT Frontend** | `nexuscos.online` | Public streaming interface |
| **V-Suite Dashboard** | `nexuscos.online/v-suite/` | Creator control center |
| **Beta Portal** | `beta.nexuscos.online` | Beta launch landing (until Nov 17, 2025) |

### Unified Branding

All landing pages feature:
- 🎨 Nexus COS blue (#2563eb) as primary color
- 📝 Inter font family
- 🖼️ Inline SVG logo (no external dependencies)
- ♿ WCAG AA accessibility compliance
- 🔒 Zero external dependencies for critical rendering

---

## 📖 Manual Deployment (Step-by-Step)

If you prefer to run each step manually:

### Step 1: Deploy Architecture

```bash
cd /opt/nexus-cos
sudo ./scripts/deploy-phase-2.5-architecture.sh
```

This will:
- Create directory structure
- Deploy landing pages
- Configure Nginx
- Start backend services
- Setup transition automation

### Step 2: Validate Deployment

```bash
sudo ./scripts/validate-phase-2.5-deployment.sh
```

This validates:
- Directory structure
- Landing pages deployed correctly
- Nginx configuration valid
- SSL certificates present
- Backend services running
- Health endpoints responding
- Routing configured correctly

---

## ✅ Success Indicators

When deployment succeeds, you'll see:

```
╔════════════════════════════════════════════════════════════════╗
║        ✅  PHASE 2.5 DEPLOYMENT COMPLETE - SUCCESS  ✅         ║
║              ALL MANDATORY REQUIREMENTS MET                    ║
╚════════════════════════════════════════════════════════════════╝
```

Followed by:

```
╔════════════════════════════════════════════════════════════════╗
║                ✅ ALL CHECKS PASSED ✅                         ║
║         Phase 2.5 Deployment is Production Ready!              ║
╚════════════════════════════════════════════════════════════════╝
```

---

## 🔍 Verification

After deployment, verify your sites are live:

1. **Apex Domain**: https://nexuscos.online
   - Should display OTT frontend with Nexus COS branding
   
2. **Beta Domain**: https://beta.nexuscos.online
   - Should display beta landing page
   - Beta badge visible in navigation
   - Correct beta URL in all links

3. **V-Suite Dashboard**: https://nexuscos.online/v-suite/
   - Should proxy to backend services

---

## 🔧 Troubleshooting

### Issue: "Script must be run as root"
**Solution**: Add `sudo` before the command

```bash
sudo ./DEPLOY_PHASE_2.5.sh
```

### Issue: "Repository not found at /opt/nexus-cos"
**Solution**: Clone repository to correct location

```bash
sudo git clone https://github.com/BobbyBlanco400/nexus-cos.git /opt/nexus-cos
cd /opt/nexus-cos
```

### Issue: "Nginx configuration validation failed"
**Solution**: Check nginx syntax manually

```bash
sudo nginx -t
```

### Issue: "Landing page not found"
**Solution**: Verify repository has landing pages

```bash
ls -la /opt/nexus-cos/apex/index.html
ls -la /opt/nexus-cos/web/beta/index.html
```

### Issue: "SSL certificates not found"
**Solution**: Verify SSL certificate paths

```bash
ls -la /etc/nginx/ssl/apex/
ls -la /etc/nginx/ssl/beta/
```

---

## 📊 Deployment Files

| File | Purpose |
|------|---------|
| `DEPLOY_PHASE_2.5.sh` | One-command deployment wrapper |
| `scripts/deploy-phase-2.5-architecture.sh` | Main deployment script |
| `scripts/validate-phase-2.5-deployment.sh` | Validation script |
| `scripts/beta-transition-cutover.sh` | Auto-generated transition script |

---

## 📅 Beta Transition (Nov 17, 2025)

The beta portal will automatically redirect to production on **November 17, 2025**.

To schedule the automatic transition:

```bash
# Add to root crontab
sudo crontab -e

# Add this line:
0 0 17 11 2025 /opt/nexus-cos/scripts/beta-transition-cutover.sh >> /opt/nexus-cos/logs/phase2.5/transition/cutover.log 2>&1
```

---

## 📝 Logs

All logs are written to `/opt/nexus-cos/logs/phase2.5/`:

```
/opt/nexus-cos/logs/phase2.5/
├── ott/          # OTT frontend access/error logs
├── dashboard/    # V-Suite dashboard logs
├── beta/         # Beta landing page logs
└── transition/   # Transition automation logs
```

---

## 🎯 Quick Reference

**Deploy Everything:**
```bash
cd /opt/nexus-cos && sudo ./DEPLOY_PHASE_2.5.sh
```

**Validate Only:**
```bash
cd /opt/nexus-cos && sudo ./scripts/validate-phase-2.5-deployment.sh
```

**View Logs:**
```bash
tail -f /opt/nexus-cos/logs/phase2.5/ott/access.log
```

**Restart Nginx:**
```bash
sudo systemctl reload nginx
```

---

## 🆘 Support

**Primary Contact**: Bobby Blanco (PUABO)  
**Technical Lead**: TRAE SOLO (GitHub Code Agent)  
**Infrastructure**: CloudFlare + IONOS

---

## 📚 Additional Documentation

- `PF_PHASE_2.5_OTT_INTEGRATION.md` - Complete Phase 2.5 PF directive
- `TRAE_SOLO_EXECUTION.md` - TRAE Solo execution guide
- `PR87_LANDING_PAGE_DEPLOYMENT_CHECKLIST.md` - Landing page deployment checklist

---

**Status**: ✅ READY FOR DEPLOYMENT  
**Version**: Phase 2.5  
**Last Updated**: 2025-01-09
