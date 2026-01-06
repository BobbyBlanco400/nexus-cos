# IP/Domain Routing Fix - Quick Start

## 🚨 Problem
Accessing `http://74.208.155.161/` shows different UI than `https://n3xuscos.online/`

## ✅ Solution
Complete Platform Fix (PF) ready for deployment

## 🚀 Quick Deploy (Single Command)

```bash
cd /home/runner/work/nexus-cos/nexus-cos
sudo bash pf-master-deployment.sh
```

**That's it!** The script will:
1. Check system requirements
2. Validate environment
3. Build frontend applications
4. Configure Nginx with IP/domain unification
5. Enforce branding consistency
6. Run validation checks
7. Generate deployment report

**Time:** 5-10 minutes

## 📋 Alternative: Step-by-Step

### 1. IP/Domain Fix Only
```bash
sudo bash pf-ip-domain-unification.sh
```

### 2. Validate Deployment
```bash
bash validate-ip-domain-routing.sh
```

### 3. Verify in Browser
- Clear cache: `Ctrl+Shift+Delete`
- Visit: `http://74.208.155.161/` (should redirect)
- Visit: `https://n3xuscos.online/` (should load)

## 📚 Documentation

### Quick Reference
- **[QUICK_FIX_IP_DOMAIN.md](./QUICK_FIX_IP_DOMAIN.md)** - Fast reference guide (5 min read)

### Complete Guides
- **[PF_MASTER_DEPLOYMENT_README.md](./PF_MASTER_DEPLOYMENT_README.md)** - Complete guide (15 min read)
- **[PF_IP_DOMAIN_UNIFICATION.md](./PF_IP_DOMAIN_UNIFICATION.md)** - Technical details (20 min read)

### Summary & Checklist
- **[IP_DOMAIN_FIX_SUMMARY.md](./IP_DOMAIN_FIX_SUMMARY.md)** - Executive summary (10 min read)
- **[DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)** - Deployment checklist (use during deployment)

## 🛠️ Scripts

### Deployment Scripts
| Script | Purpose | Command |
|--------|---------|---------|
| `pf-master-deployment.sh` | Complete deployment (recommended) | `sudo bash pf-master-deployment.sh` |
| `pf-ip-domain-unification.sh` | Core IP/domain fix | `sudo bash pf-ip-domain-unification.sh` |

### Validation Scripts
| Script | Purpose | Command |
|--------|---------|---------|
| `validate-ip-domain-routing.sh` | Comprehensive validation | `bash validate-ip-domain-routing.sh` |

## 🔍 What Gets Fixed

### Nginx Configuration
✅ **Before:** IP requests hit default server (different content)  
✅ **After:** IP requests redirect to domain (identical content)

### Key Changes
- Added `default_server` directive
- Multiple `server_name` entries (domain, www, IP, fallback)
- HTTP redirects to HTTPS
- IP redirects to domain
- Proper CSP headers for React
- Optimized caching (1 year for static, no-cache for HTML)

## ✔️ Verification

### Quick Test
```bash
# Test IP redirect
curl -I http://74.208.155.161/
# Expected: 301 redirect to domain

# Test domain access
curl -I https://n3xuscos.online/
# Expected: 200 OK

# Test admin panel
curl -L https://n3xuscos.online/admin/
# Expected: 200 OK with HTML
```

### Automated Validation
```bash
bash validate-ip-domain-routing.sh
```
Expected: All checks pass ✓

### Browser Test
1. Clear cache completely (`Ctrl+Shift+Delete`)
2. Visit both URLs
3. Verify identical appearance
4. Check console for errors (should be none)

## 🎯 Success Criteria

Your deployment is successful when:
- [ ] IP and domain show identical UI
- [ ] No redirect loops
- [ ] Admin panel works
- [ ] Creator hub works
- [ ] No console errors
- [ ] Branding consistent

## 🔧 Troubleshooting

### Still seeing different UI?
```bash
# Clear browser cache completely
Ctrl + Shift + Delete → All time

# Hard reload
Ctrl + Shift + R
```

### 502 Bad Gateway?
```bash
# Check backend services
systemctl status nexus-backend
systemctl status nexus-python

# Restart if needed
systemctl restart nexus-backend
```

### Configuration error?
```bash
# Test Nginx config
nginx -t

# View errors
nginx -t 2>&1
```

### Need to rollback?
```bash
# Restore backup (created automatically)
sudo cp /etc/nginx/sites-available/nexuscos.backup.[timestamp] \
        /etc/nginx/sites-available/nexuscos
sudo nginx -t && sudo systemctl reload nginx
```

## 📊 Reports & Logs

After deployment, check:
- `/tmp/nexus-cos-master-pf-report.txt` - Master deployment report
- `/tmp/nexus-cos-pf-report.txt` - IP/domain fix report
- `/tmp/nexus-cos-validation-report.txt` - Validation results
- `/var/log/nginx/nexus-cos.error.log` - Nginx errors

## 🔐 Security

### Headers Configured
- ✓ X-Frame-Options: SAMEORIGIN
- ✓ X-Content-Type-Options: nosniff
- ✓ X-XSS-Protection: enabled
- ✓ HSTS: max-age 31536000
- ✓ CSP: configured for React apps

### SSL/TLS
- ✓ TLSv1.2 and TLSv1.3 only
- ✓ Modern cipher suites
- ✓ OCSP stapling enabled

## 📞 Support

### Need Help?
1. Check the detailed guides (links above)
2. Review the deployment checklist
3. Check logs for errors
4. Verify all prerequisites met

### Common Resources
- Nginx config: `/etc/nginx/sites-available/nexuscos`
- Webroot: `/var/www/nexus-cos/`
- Logs: `/var/log/nginx/nexus-cos.*.log`

## 🎓 Learn More

### Architecture
The fix implements:
1. **Unified server block** - Handles both IP and domain
2. **default_server directive** - Captures unmatched requests
3. **Smart redirects** - HTTP→HTTPS, IP→Domain
4. **Optimized caching** - 1yr static, fresh HTML
5. **Security headers** - Full protection suite

### Integration
Compatible with:
- ✓ All existing PF scripts
- ✓ Docker Compose
- ✓ PM2 processes
- ✓ SSL certificates
- ✓ Backend services
- ✓ Databases

## ⏱️ Time Estimates

- **Reading this:** 2 minutes
- **Quick fix guide:** 5 minutes
- **Master deployment:** 5-10 minutes
- **Validation:** 1-2 minutes
- **Browser testing:** 2-3 minutes
- **Total:** ~20 minutes

## 📈 Status

**Current Status:** ✅ READY FOR DEPLOYMENT

**What's Included:**
- ✓ 3 deployment scripts
- ✓ 5 documentation files
- ✓ 1 production Nginx config
- ✓ Complete validation suite
- ✓ Deployment checklist
- ✓ Troubleshooting guides

**Production Ready:**
- ✓ Tested syntax
- ✓ Error handling
- ✓ Automatic backups
- ✓ Rollback procedure
- ✓ Comprehensive logging
- ✓ Validation checks

## 🚦 Next Steps

### 1. Read Quick Fix Guide
```bash
cat QUICK_FIX_IP_DOMAIN.md
```

### 2. Run Master Deployment
```bash
sudo bash pf-master-deployment.sh
```

### 3. Validate Deployment
```bash
bash validate-ip-domain-routing.sh
```

### 4. Test in Browser
- Clear cache
- Visit both URLs
- Verify consistency

### 5. Monitor
```bash
tail -f /var/log/nginx/nexus-cos.error.log
```

## 📝 Checklist

Before deployment:
- [ ] Read quick fix guide
- [ ] VPS access ready
- [ ] Backups taken
- [ ] Team notified

During deployment:
- [ ] Run master script
- [ ] Monitor progress
- [ ] Check for errors
- [ ] Review reports

After deployment:
- [ ] Run validation
- [ ] Test in browser
- [ ] Monitor logs
- [ ] Update documentation

---

## 🎉 Summary

**Problem:** IP shows different UI than domain  
**Solution:** Unified Nginx routing with default_server  
**Deploy:** `sudo bash pf-master-deployment.sh`  
**Verify:** `bash validate-ip-domain-routing.sh`  
**Time:** ~15 minutes total  
**Status:** ✅ Ready to deploy

---

**Version:** 1.0.0  
**Date:** 2024-10-05  
**Maintained By:** Nexus COS Team

For complete documentation, see [PF_INDEX.md](./PF_INDEX.md)
