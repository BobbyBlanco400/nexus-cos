# N3XUS v-COS Logo Deployment - Quick Reference

## 🚀 One-Line Deployment Commands

### Local Development

```bash
# Update canonical logo, then deploy to all verticals
cp /path/to/your/new-logo.png branding/official/N3XUS-vCOS.png && bash scripts/deploy-holographic-logo.sh
```

### Production VPS - Windows PowerShell

```powershell
# Upload and deploy in one step
scp "C:\path\to\your\logo.png" root@72.62.86.217:/root/nexus-cos/branding/official/N3XUS-vCOS.png
ssh root@72.62.86.217 'cd /root/nexus-cos && bash scripts/deploy-holographic-logo.sh'
```

### Production VPS - Mac/Linux/WSL

```bash
# Upload and deploy in one step
scp /path/to/your/logo.png root@72.62.86.217:/root/nexus-cos/branding/official/N3XUS-vCOS.png && \
ssh root@72.62.86.217 'cd /root/nexus-cos && bash scripts/deploy-holographic-logo.sh'
```

---

## 📍 Key Locations

**Canonical Source (ONLY modify this):**
```
branding/official/N3XUS-vCOS.png
```

**Deployment Targets (Auto-updated by script):**
```
branding/logo.png
frontend/public/assets/branding/logo.png
admin/public/assets/branding/logo.png
creator-hub/public/assets/branding/logo.png
```

---

## ✅ Logo Requirements

- **Format:** PNG (required)
- **Size:** 1KB - 10MB
- **Resolution:** Minimum 512x512 pixels
- **Quality:** High resolution for web and print

---

## 🔍 Verification

```bash
# Verify logo deployment
bash scripts/bootstrap.sh

# Check all logos match
md5sum branding/official/N3XUS-vCOS.png branding/logo.png \
       admin/public/assets/branding/logo.png \
       creator-hub/public/assets/branding/logo.png \
       frontend/public/assets/branding/logo.png
```

---

## 📚 Full Documentation

See [OFFICIAL_LOGO_DEPLOYMENT_GUIDE.md](./OFFICIAL_LOGO_DEPLOYMENT_GUIDE.md) for complete instructions.

---

**N3XUS LAW / 55-45-17** - Single source of truth enforced  
**Status:** ✅ Production Ready
