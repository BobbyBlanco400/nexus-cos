# 🚀 Nexus COS - VPS Deployment Guide

> **For Agent TRAE SOLO**: Your deployment scripts are now fixed and ready for VPS production deployment!

---

## ✅ What's Been Fixed

Your deployment scripts had hardcoded GitHub Actions paths that prevented them from working on your VPS. **This has been completely resolved**.

### Before (❌ Broken)
```bash
REPO_ROOT="/home/runner/work/nexus-cos/nexus-cos"  # Only works in GitHub Actions
```

### After (✅ Fixed)
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$SCRIPT_DIR}"  # Works anywhere!
```

---

## 🎯 What You Need To Do Now

### Step 1: Upload Repository to Your VPS

Upload the repository to `/var/www/nexus-cos` on your VPS.

### Step 2: Run These Commands

**IMPORTANT**: Copy these commands EXACTLY as shown. Do NOT include any leading hyphens or bullets.

```bash
cd /var/www/nexus-cos
ls -l pf-master-deployment.sh
sudo chmod +x /var/www/nexus-cos/pf-master-deployment.sh
sudo DOMAIN=n3xuscos.online bash /var/www/nexus-cos/pf-master-deployment.sh
```

### Step 3: Validate Deployment

```bash
sudo bash /var/www/nexus-cos/validate-ip-domain-routing.sh
```

### Step 4: Test in Browser

1. **Clear your browser cache** (Very Important!)
   - Press `Ctrl + Shift + Delete` (or `Cmd + Option + E` on Mac)
   - Select "All time" or "Everything"
   - Clear cached images and files

2. **Open these URLs**:
   - `http://74.208.155.161/`
   - `https://n3xuscos.online/`

3. **Verify**:
   - Both URLs should show the SAME UI/branding
   - HTTP should redirect to HTTPS
   - You should see your official Nexus COS interface

---

## 🔍 Spot-Check Commands

Run these to verify everything is working:

```bash
# Check HTTP redirect from IP
curl -I http://74.208.155.161/

# Check HTTPS domain
curl -I https://n3xuscos.online/

# Check admin panel
curl -I https://n3xuscos.online/admin

# Check API health
curl -I https://n3xuscos.online/api/health
```

---

## ⚠️ Common Issues & Solutions

### Issue: "-: command not found"

**Cause**: You copied the command with a leading hyphen/bullet from documentation.

**Solution**: Type the command manually or copy it without any leading characters:

```bash
# ❌ WRONG (has leading hyphen)
- cd /var/www/nexus-cos

# ✅ CORRECT
cd /var/www/nexus-cos
```

### Issue: "pf-master-deployment.sh not found"

**Solution**: Make sure you're in the correct directory:

```bash
cd /var/www/nexus-cos
pwd  # Should show: /var/www/nexus-cos
ls -la pf-master-deployment.sh  # Should show the file
```

### Issue: Nginx fails to reload

**Solution**:

```bash
# Test configuration
sudo nginx -t

# Check logs
sudo tail -n 200 /var/log/nginx/error.log

# Restart nginx
sudo systemctl restart nginx
```

---

## 📚 Documentation Files

We've created several documentation files to help you:

| File | What It's For |
|------|--------------|
| **VPS_QUICK_REFERENCE.md** | Quick copy-paste commands ⚡ |
| **VPS_DEPLOYMENT_INSTRUCTIONS.md** | Complete step-by-step guide 📘 |
| **DEPLOYMENT_FIX_SUMMARY.md** | What was fixed and why 🔍 |
| **CHANGES_MADE.md** | Visual summary of all changes 📊 |
| **test-deployment-scripts.sh** | Run to verify scripts work ✅ |

---

## ✅ Success Checklist

After deployment, you should have:

- [ ] Scripts ran without errors
- [ ] Validation shows all/most tests passing
- [ ] Browser cache is cleared
- [ ] `http://74.208.155.161/` redirects to `https://n3xuscos.online/`
- [ ] Both IP and domain show identical UI/branding
- [ ] Your official Nexus COS interface is visible
- [ ] Admin panel works at `/admin`
- [ ] API responds at `/api/health`
- [ ] No errors in nginx logs
- [ ] **🎉 Ready for global launch!**

---

## 🎉 Expected Result

After following these steps, when you:
- Click `https://n3xuscos.online/`
- Or visit `http://74.208.155.161/`

You will see:
- ✅ Your official Nexus COS UI/branding
- ✅ Consistent interface across all access methods
- ✅ Professional, production-ready platform
- ✅ **Ready for global launch**

---

## 🆘 Need Help?

If you encounter issues:

1. Check the error message carefully
2. Review `/tmp/nexus-cos-master-pf-report.txt` (deployment report)
3. Check `/var/log/nginx/error.log` (nginx errors)
4. See `VPS_DEPLOYMENT_INSTRUCTIONS.md` for detailed troubleshooting

---

## 🎯 Summary

**What was broken**: Scripts had hardcoded GitHub Actions paths  
**What's fixed**: Scripts now auto-detect their location  
**What you do**: Run 4 commands on your VPS  
**What you get**: Full production deployment with unified UI/branding  

**Status**: ✅ READY FOR DEPLOYMENT

Your platform is ready for global launch! 🚀
