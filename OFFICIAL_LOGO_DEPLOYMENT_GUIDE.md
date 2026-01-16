# N3XUS v-COS Official Logo Deployment Guide

## 🎨 Overview

This guide provides complete instructions for deploying and managing the official N3XUS v-COS logo across the entire platform. The system enforces **N3XUS LAW / 55-45-17** to maintain a single source of truth for all branding assets.

---

## 📋 Quick Reference

**Canonical Logo Location:**
```
branding/official/N3XUS-vCOS.png
```

**Deployment Command:**
```bash
bash scripts/deploy-holographic-logo.sh
```

**Verification Command:**
```bash
bash scripts/bootstrap.sh
```

---

## 🏗️ Architecture

### Single Source of Truth

The N3XUS v-COS platform uses a **holographic deployment pattern** where:

1. **One canonical file** exists: `branding/official/N3XUS-vCOS.png`
2. **Automatic propagation** to all verticals from that single source
3. **Overwrite-safe**: Updating the canonical source propagates everywhere
4. **Branding drift is impossible** - all surfaces use identical assets

### Deployment Targets

The canonical logo is automatically deployed to:

```
✅ branding/logo.png
✅ frontend/public/assets/branding/logo.png
✅ admin/public/assets/branding/logo.png
✅ creator-hub/public/assets/branding/logo.png
```

---

## 📝 Step-by-Step Logo Update Process

### Prerequisites

- Access to the repository at `/path/to/nexus-cos` or your local clone
- PNG logo file meeting the requirements (see below)
- SSH access to VPS (if deploying to production)

### Logo Requirements

✅ **Format:** PNG (required)  
✅ **Size:** Between 1KB and 10MB  
✅ **Resolution:** Minimum 512x512 pixels recommended  
✅ **Color Mode:** RGB or RGBA  
✅ **Quality:** High resolution for web and print use

### Local Development Workflow

#### Step 1: Replace the Canonical Logo

```bash
# Navigate to repository
cd /home/runner/work/nexus-cos/nexus-cos

# Backup current logo (optional)
cp branding/official/N3XUS-vCOS.png branding/official/N3XUS-vCOS.png.backup

# Replace with your new logo
cp /path/to/your/new-logo.png branding/official/N3XUS-vCOS.png
```

#### Step 2: Verify Logo File

```bash
# Check file exists and is valid PNG
file branding/official/N3XUS-vCOS.png
ls -lh branding/official/N3XUS-vCOS.png
```

Expected output:
```
branding/official/N3XUS-vCOS.png: PNG image data, [dimensions], 8-bit/color RGB
```

#### Step 3: Deploy to All Verticals

```bash
# Run holographic deployment script
bash scripts/deploy-holographic-logo.sh
```

Expected output:
```
🎨 N3XUS v-COS Holographic Logo Deployment
============================================

✅ Canonical logo verified: branding/official/N3XUS-vCOS.png

📦 Deploying logo to all surfaces...

   ✅ Deployed: branding/logo.png
   ✅ Deployed: admin/public/assets/branding/logo.png
   ✅ Deployed: creator-hub/public/assets/branding/logo.png
   ✅ Deployed: frontend/public/assets/branding/logo.png

============================================
📊 Deployment Summary:
   ✅ Deployed: 4
   ⏭️  Skipped: 0
   ❌ Failed: 0

🎉 Holographic logo deployment complete!
```

#### Step 4: Verify Deployment

```bash
# Run bootstrap verification
bash scripts/bootstrap.sh
```

Expected output should include:
```
🎨 Official logo verified at branding/official/N3XUS-vCOS.png
✅ N3XUS LAW compliant - Logo enforcement active
```

#### Step 5: Commit Changes

```bash
# Add all logo files to git
git add branding/official/N3XUS-vCOS.png
git add branding/logo.png
git add admin/public/assets/branding/logo.png
git add creator-hub/public/assets/branding/logo.png
git add frontend/public/assets/branding/logo.png

# Commit with descriptive message
git commit -m "Update N3XUS v-COS official logo - N3XUS LAW compliant"

# Push to repository
git push origin <your-branch>
```

---

## 🚀 Production VPS Deployment

### Option A: Direct Upload and Deploy (Recommended)

#### 1. Upload Logo to VPS

Using SCP from your local machine:

```powershell
# Windows PowerShell
scp "C:\path\to\your\logo.png" ^
    user@YOUR_VPS_IP:/path/to/nexus-cos/branding/official/N3XUS-vCOS.png
```

Or using Unix/Linux/Mac:

```bash
# Unix/Linux/Mac
scp /path/to/your/logo.png \
    user@YOUR_VPS_IP:/path/to/nexus-cos/branding/official/N3XUS-vCOS.png
```

#### 2. SSH into VPS and Deploy

```bash
# Connect to VPS
ssh user@YOUR_VPS_IP

# Navigate to repository
cd /path/to/nexus-cos

# Deploy logo to all verticals
bash scripts/deploy-holographic-logo.sh

# Verify deployment
bash scripts/bootstrap.sh
```

### Option B: One-Liner Deployment

Execute this single command from your local machine:

```bash
# Upload logo and deploy in one step
scp /path/to/your/logo.png user@YOUR_VPS_IP:/path/to/nexus-cos/branding/official/N3XUS-vCOS.png && \
ssh user@YOUR_VPS_IP 'cd /path/to/nexus-cos && bash scripts/deploy-holographic-logo.sh'
```

PowerShell version:

```powershell
scp "C:\path\to\your\logo.png" user@YOUR_VPS_IP:/path/to/nexus-cos/branding/official/N3XUS-vCOS.png
ssh user@YOUR_VPS_IP 'cd /path/to/nexus-cos && bash scripts/deploy-holographic-logo.sh'
```

### Option C: Propagate Across Full Stack (Advanced)

For complete stack-wide propagation:

```bash
ssh user@YOUR_VPS_IP '
  cd /path/to/nexus-cos
  CANON=branding/official/N3XUS-vCOS.png
  
  # Deploy to all standard targets
  for target in \
    branding/logo.png \
    frontend/public/assets/branding/logo.png \
    admin/public/assets/branding/logo.png \
    creator-hub/public/assets/branding/logo.png
  do
    mkdir -p $(dirname "$target")
    cp "$CANON" "$target"
    echo "✅ Updated $target"
  done
  
  echo "🎉 Full stack logo deployment complete!"
'
```

---

## 🔍 Verification & Troubleshooting

### Verify All Logos are Identical

```bash
# Check MD5 checksums - all should match
md5sum branding/official/N3XUS-vCOS.png
md5sum branding/logo.png
md5sum admin/public/assets/branding/logo.png
md5sum creator-hub/public/assets/branding/logo.png
md5sum frontend/public/assets/branding/logo.png
```

All checksums should be identical.

### Check File Sizes

```bash
# All deployed logos should be the same size
ls -lh branding/official/N3XUS-vCOS.png \
       branding/logo.png \
       admin/public/assets/branding/logo.png \
       creator-hub/public/assets/branding/logo.png \
       frontend/public/assets/branding/logo.png
```

### Common Issues

#### Issue: "Canonical logo not found"

**Solution:**
```bash
# Verify file exists
ls -la branding/official/N3XUS-vCOS.png

# If missing, restore from backup or re-upload
cp branding/official/N3XUS-vCOS.png.backup branding/official/N3XUS-vCOS.png
```

#### Issue: "Permission denied"

**Solution:**
```bash
# Fix permissions
chmod 644 branding/official/N3XUS-vCOS.png

# Ensure directory permissions
chmod 755 branding/official/
```

#### Issue: Deployment script fails

**Solution:**
```bash
# Make script executable
chmod +x scripts/deploy-holographic-logo.sh

# Run with bash explicitly
bash scripts/deploy-holographic-logo.sh
```

---

## 📚 N3XUS LAW / 55-45-17 Compliance

### What is N3XUS LAW?

N3XUS LAW is the governance framework that enforces:

1. **Single Source of Truth**: One canonical location for all assets
2. **Holographic Deployment**: Automatic propagation from canonical source
3. **Bootstrap Verification**: System cannot start without compliant assets
4. **Overwrite Safety**: Updating canonical source updates everything

### Compliance Requirements

✅ Logo MUST exist at: `branding/official/N3XUS-vCOS.png`  
✅ Logo MUST be PNG format  
✅ Logo MUST be between 1KB and 10MB  
✅ All verticals MUST use deployed copies from canonical source  
✅ Bootstrap verification MUST pass before system start

### Enforcement Points

1. **Bootstrap Script** (`scripts/bootstrap.sh`):
   - Verifies canonical logo exists
   - Blocks system start if non-compliant

2. **Canon Verifier** (`canon-verifier/`):
   - Validates logo file properties
   - Checks all configuration references

3. **Deployment Script** (`scripts/deploy-holographic-logo.sh`):
   - Ensures consistent propagation
   - Prevents branding drift

---

## 🛠️ Advanced Operations

### Update Logo Without Disrupting Services

```bash
# 1. Upload new logo to temporary location
scp new-logo.png user@YOUR_VPS_IP:/tmp/new-logo.png

# 2. SSH and perform atomic swap
ssh user@YOUR_VPS_IP '
  cd /path/to/nexus-cos
  # Backup current
  cp branding/official/N3XUS-vCOS.png branding/official/N3XUS-vCOS.png.old
  # Swap in new
  mv /tmp/new-logo.png branding/official/N3XUS-vCOS.png
  # Deploy
  bash scripts/deploy-holographic-logo.sh
'
```

### Rollback to Previous Logo

```bash
# Restore from backup
cp branding/official/N3XUS-vCOS.png.backup branding/official/N3XUS-vCOS.png

# Redeploy
bash scripts/deploy-holographic-logo.sh
```

### Verify Logo Across Live System

```bash
# Check all HTTP endpoints serve correct logo
curl -I https://your-domain.com/assets/branding/logo.png
curl -I https://admin.your-domain.com/assets/branding/logo.png
curl -I https://creator.your-domain.com/assets/branding/logo.png
```

---

## 📖 Configuration Files

### Files That Reference the Logo

1. **Canon Verifier Config**: `canon-verifier/config/canon_assets.json`
   ```json
   {
     "OfficialLogo": "branding/official/N3XUS-vCOS.png"
   }
   ```

2. **Brand Colors**: `branding/colors.env`
   ```env
   LOGO_PATH=branding/official/N3XUS-vCOS.png
   ```

3. **Bootstrap Script**: `scripts/bootstrap.sh`
   ```bash
   OFFICIAL_LOGO_PATH="branding/official/N3XUS-vCOS.png"
   ```

### Do NOT Modify These Locations Manually

❌ `branding/logo.png` - Deployed copy  
❌ `admin/public/assets/branding/logo.png` - Deployed copy  
❌ `creator-hub/public/assets/branding/logo.png` - Deployed copy  
❌ `frontend/public/assets/branding/logo.png` - Deployed copy

Always update the canonical source and run the deployment script.

---

## ✅ Checklist for Logo Updates

Before deploying a new logo, ensure:

- [ ] Logo is in PNG format
- [ ] File size is between 1KB and 10MB
- [ ] Resolution is high quality (minimum 512x512 recommended)
- [ ] Logo has been tested for visual quality
- [ ] You have SSH access (for production deployment)
- [ ] Current logo is backed up
- [ ] Deployment script is executable
- [ ] You've tested in development first

After deployment:

- [ ] All 4 target locations updated
- [ ] Bootstrap verification passes
- [ ] MD5 checksums match across all copies
- [ ] Changes committed to git
- [ ] Live services display new logo (if applicable)

---

## 🆘 Support

For issues or questions:

1. Check [BRANDING_VERIFICATION.md](./BRANDING_VERIFICATION.md) for system details
2. Review [branding/official/README.md](./branding/official/README.md) for canonical source info
3. Verify N3XUS LAW compliance with `bash scripts/bootstrap.sh`
4. Check deployment logs for specific error messages

---

## 📄 Related Documentation

- [BRANDING_VERIFICATION.md](./BRANDING_VERIFICATION.md) - Original branding implementation
- [branding/official/README.md](./branding/official/README.md) - Canonical logo documentation
- [SECURITY_SUMMARY_BRANDING_UPDATE.md](./SECURITY_SUMMARY_BRANDING_UPDATE.md) - Security considerations

---

**Status:** ✅ N3XUS LAW Compliant  
**Last Updated:** January 16, 2026  
**Canonical Source:** `branding/official/N3XUS-vCOS.png`  
**Law Enforcement:** Active  
**System Ready:** 🚀 PRODUCTION
