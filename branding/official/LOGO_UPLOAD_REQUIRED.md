# 🎨 N3XUS v-COS Official Logo

## Current Status: ✅ OPERATIONAL

### Current File Information

**Filename:** `N3XUS-vCOS.png` ✅ PRESENT  
**Format:** PNG (512x512, 8-bit RGB)  
**Size:** 226KB  
**Location:** `branding/official/N3XUS-vCOS.png`  
**Status:** Active canonical logo - System fully operational

---

## 📝 How to Update the Official Logo

### Quick Start

To replace the current logo with your new professional logo:

#### Step 1: Prepare Your Logo

Ensure your logo meets these requirements:
- ✅ **Format:** PNG (required)
- ✅ **Size:** Between 1KB and 10MB
- ✅ **Resolution:** Minimum 512x512 pixels recommended
- ✅ **Quality:** High resolution for web and print use

#### Step 2: Replace the Canonical File

**Option A - Local Development:**
```bash
# Navigate to repository
cd /home/runner/work/nexus-cos/nexus-cos

# Replace the canonical logo
cp /path/to/your/new-logo.png branding/official/N3XUS-vCOS.png
```

**Option B - Production VPS (from Windows):**
```powershell
# Upload to VPS canonical location
scp "C:\path\to\your\logo.png" ^
    user@YOUR_VPS_IP:/path/to/nexus-cos/branding/official/N3XUS-vCOS.png
```

**Option B - Production VPS (from Mac/Linux):**
```bash
# Upload to VPS canonical location
scp /path/to/your/logo.png \
    user@YOUR_VPS_IP:/path/to/nexus-cos/branding/official/N3XUS-vCOS.png
```

#### Step 3: Deploy to All Verticals

After replacing the canonical file, propagate it to all application surfaces:

**Local Development:**
```bash
bash scripts/deploy-holographic-logo.sh
```

**Production VPS:**
```bash
ssh user@YOUR_VPS_IP 'cd /path/to/nexus-cos && bash scripts/deploy-holographic-logo.sh'
```

#### Step 4: Verify Deployment

```bash
# Run bootstrap verification
bash scripts/bootstrap.sh
```

Expected output:
```
🎨 Official logo verified at branding/official/N3XUS-vCOS.png
✅ N3XUS LAW compliant - Logo enforcement active
```

---

## 🚀 Complete One-Liner for VPS Deployment

Upload and deploy in a single command:

**PowerShell (Windows):**
```powershell
scp "C:\Users\username\path\to\logo.png" user@YOUR_VPS_IP:/path/to/nexus-cos/branding/official/N3XUS-vCOS.png ; ssh user@YOUR_VPS_IP 'cd /path/to/nexus-cos && bash scripts/deploy-holographic-logo.sh'
```

**Bash (Mac/Linux/WSL):**
```bash
scp /path/to/your/logo.png user@YOUR_VPS_IP:/path/to/nexus-cos/branding/official/N3XUS-vCOS.png && \
ssh user@YOUR_VPS_IP 'cd /path/to/nexus-cos && bash scripts/deploy-holographic-logo.sh'
```

---

## 📍 Deployment Targets

The holographic deployment script automatically copies the canonical logo to:

```
✅ branding/logo.png
✅ frontend/public/assets/branding/logo.png
✅ admin/public/assets/branding/logo.png
✅ creator-hub/public/assets/branding/logo.png
```

**Important:** Never modify these deployed copies directly. Always update the canonical source and run the deployment script.

---

## ⚖️ N3XUS LAW / 55-45-17 Compliance

### Single Source of Truth

Per N3XUS LAW, `branding/official/N3XUS-vCOS.png` is the **exclusive canonical logo location**.

### Enforcement Points

1. **Bootstrap Verification** - System checks for canonical logo at startup
2. **Holographic Deployment** - Automatic propagation prevents branding drift
3. **Canon Verifier** - Validates logo properties and configuration

### Configuration References

The following files reference this canonical PNG logo:
- ✅ `canon-verifier/config/canon_assets.json`
- ✅ `branding/colors.env`
- ✅ `scripts/bootstrap.sh`
- ✅ `scripts/deploy-holographic-logo.sh`

---

## 📚 Documentation

For complete documentation, see:
- **[OFFICIAL_LOGO_DEPLOYMENT_GUIDE.md](../../OFFICIAL_LOGO_DEPLOYMENT_GUIDE.md)** - Complete deployment guide
- **[README.md](./README.md)** - Canonical branding documentation
- **[BRANDING_VERIFICATION.md](../../BRANDING_VERIFICATION.md)** - System verification report

---

## ✅ Verification Checklist

After updating the logo:

- [ ] Logo file is PNG format
- [ ] File is between 1KB and 10MB
- [ ] Canonical file updated at `branding/official/N3XUS-vCOS.png`
- [ ] Deployment script executed successfully
- [ ] Bootstrap verification passes
- [ ] All 4 target locations updated
- [ ] Changes committed to git (if in development)

---

**Status:** ✅ System Operational  
**Canonical Source:** `branding/official/N3XUS-vCOS.png`  
**N3XUS LAW:** Active  
**Deployment:** Ready 🚀
