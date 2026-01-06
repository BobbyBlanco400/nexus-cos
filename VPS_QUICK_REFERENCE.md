# Nexus COS - VPS Deployment Quick Reference

## 🚀 Quick Deploy (Copy & Paste)

```bash
cd /var/www/nexus-cos
ls -l pf-master-deployment.sh
sudo chmod +x /var/www/nexus-cos/pf-master-deployment.sh
sudo DOMAIN=n3xuscos.online bash /var/www/nexus-cos/pf-master-deployment.sh
```

## ✅ Validation

```bash
sudo bash /var/www/nexus-cos/validate-ip-domain-routing.sh
```

## 🔍 Spot-Check Commands

```bash
# HTTP redirect check
curl -I http://74.208.155.161/

# HTTPS domain check
curl -I https://n3xuscos.online/

# Admin panel check
curl -I https://n3xuscos.online/admin

# API health check
curl -I https://n3xuscos.online/api/health
```

## 🛠️ If Something Goes Wrong

```bash
# Check nginx status
sudo systemctl status nginx

# Test nginx config
sudo nginx -t

# View error logs
tail -n 200 /var/log/nginx/error.log

# Manual nginx reload
sudo systemctl reload nginx
```

## 📋 Alternative: Run Individual Scripts

```bash
# 1. IP/Domain routing fix only
sudo bash /var/www/nexus-cos/pf-ip-domain-unification.sh

# 2. Validate
bash /var/www/nexus-cos/validate-ip-domain-routing.sh
```

## ⚠️ Important Notes

1. **NO leading hyphens**: Type commands directly, don't copy bullets/hyphens
2. **Clear browser cache**: Ctrl+Shift+Delete before testing
3. **Use full paths**: `/var/www/nexus-cos/pf-master-deployment.sh`
4. **Include DOMAIN**: `DOMAIN=n3xuscos.online` in the command

## 📊 Expected Results

After successful deployment:
- ✅ `http://74.208.155.161/` redirects to `https://n3xuscos.online/`
- ✅ Both IP and domain show identical UI/branding
- ✅ Admin panel works at `https://n3xuscos.online/admin`
- ✅ API responds at `https://n3xuscos.online/api/health`
- ✅ All security headers present
- ✅ No nginx errors in logs

## 🎯 Success Checklist

- [ ] Scripts executed without errors
- [ ] Validation script shows all/most tests passing
- [ ] Browser cache cleared
- [ ] Both IP and domain work identically
- [ ] HTTP redirects to HTTPS
- [ ] Official UI/branding visible
- [ ] No console errors in browser

## 📖 Full Documentation

See `VPS_DEPLOYMENT_INSTRUCTIONS.md` for complete step-by-step guide.
