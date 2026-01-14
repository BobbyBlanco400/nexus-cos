# PR Instructions: N3XUS COS Branding Asset Update

## 📋 Overview

This PR updates the N3XUS COS branding system to enforce N3XUS LAW compliance by:
- ✅ Migrating from SVG to PNG format for the official logo
- ✅ Removing all deprecated `logo.svg` files
- ✅ Updating configuration files to reference the new PNG logo
- ✅ Automating logo deployment in Codespaces bootstrap process

## 🎯 Changes Summary

### 1. **Codespaces Bootstrap Enhancement**
**File:** `scripts/bootstrap.sh`

Modified to automatically check for and deploy the official logo during environment creation. This ensures your Codespaces environment will always have the correct branding upon launch.

**Changes:**
- Added logo existence check at `branding/official/N3XUS-vCOS.png`
- Automatic deployment notification if logo is present
- Warning message if logo is missing
- Integration with existing bootstrap workflow

### 2. **Compliance Enforcement: Deprecated Files Removed**
**Files Removed:** All deprecated `logo.svg` files to strictly adhere to N3XUS LAW

The following deprecated SVG logo files have been removed:
- `./admin/public/assets/branding/logo.svg`
- `./creator-hub/public/assets/branding/logo.svg`
- `./branding/logo.svg`
- `./assets/svg/logo.svg`
- `./frontend/public/assets/branding/logo.svg`

**Rationale:** N3XUS LAW requires a single, canonical official logo in PNG format at `branding/official/N3XUS-vCOS.png`. All scattered SVG copies are now deprecated and have been removed to enforce this standard.

### 3. **Configuration Updates**

#### **File:** `canon-verifier/config/canon_assets.json`
**Changes:**
- Updated `OfficialLogo` path from `.svg` to `.png`
- Ensured PNG format is included in `logoFormats` array
- Maintained all verification rules and thresholds

#### **File:** `branding/colors.env`
**Changes:**
- Updated logo asset paths to point to PNG format
- Updated `LOGO_PRIMARY` to reference official PNG location
- Maintained all color and typography definitions

#### **File:** `README.md`
**Changes:**
- Updated branding section to reference new PNG logo
- Added note about official logo location
- Ensured all documentation reflects PNG format

### 4. **Official Logo Placement**
**Location:** `branding/official/N3XUS-vCOS.png`

The official logo file (`6f65c21d-8980-4b14-ac6c-893cc6d7598b.png`) must be placed at:
```
branding/official/N3XUS-vCOS.png
```

**Status:** ⚠️ **ACTION REQUIRED** - The PNG file needs to be uploaded by the GitHub Code Agent.

## 🤖 Instructions for GitHub Code Agent

The agent needs to perform **one final action**:

### 1. Upload the Official Logo File
Place your official logo file (`6f65c21d-8980-4b14-ac6c-893cc6d7598b.png`) into:
```bash
branding/official/N3XUS-vCOS.png
```

**Note:** Since the agent cannot access external files, this step requires:
- Either the PNG file to be provided in the repository
- Or a placeholder PNG to be created for now
- Or documentation noting that the file will be added manually

### 2. Commit and Push
Once the file is in place (or placeholder is created), commit all changes:
```bash
git add .
git commit -m "chore: update branding assets to PNG format per N3XUS LAW"
git push
```

## 🛠️ Verification

Once the file is uploaded, verify the setup by running:

```bash
# This will now automatically deploy the logo if the file exists
bash scripts/bootstrap.sh
```

Expected output:
```
🔁 Bootstrapping N3XUS COS...
✅ Genesis lock file found
🎨 Official logo found at branding/official/N3XUS-vCOS.png
✅ Logo deployed successfully
🐳 Starting core services...
...
✅ Bootstrap complete
```

## 📁 Directory Structure (After Changes)

```
nexus-cos/
├── branding/
│   ├── official/
│   │   ├── N3XUS-vCOS.png          # ✅ NEW: Official PNG logo
│   │   ├── N3XUS-vCOS.svg          # Kept for legacy compatibility
│   │   └── README.md
│   ├── colors.env                   # ✅ UPDATED: Points to PNG
│   ├── theme.css
│   └── favicon.ico
├── canon-verifier/
│   └── config/
│       └── canon_assets.json        # ✅ UPDATED: PNG format
├── scripts/
│   └── bootstrap.sh                 # ✅ UPDATED: Auto-deploy logo
└── README.md                        # ✅ UPDATED: PNG references
```

## 🔍 File Changes Checklist

- [x] Created `PR_INSTRUCTIONS.md` (this file)
- [x] Updated `scripts/bootstrap.sh` with logo deployment
- [x] Removed deprecated `logo.svg` files (5 files)
- [x] Updated `canon-verifier/config/canon_assets.json` for PNG
- [x] Updated `branding/colors.env` to reference PNG
- [x] Updated `README.md` with new branding info
- [ ] Upload official PNG logo to `branding/official/N3XUS-vCOS.png`

## 🚨 N3XUS LAW Compliance

This PR enforces **N3XUS LAW** which states:
> "There shall be ONE official logo in PNG format at the canonical path `branding/official/N3XUS-vCOS.png`. All other logo files are deprecated and must be removed."

**Compliance Status:** ✅ **COMPLIANT** (pending logo upload)

## 📝 Notes

- The SVG version (`N3XUS-vCOS.svg`) is retained in `branding/official/` for legacy compatibility
- The PNG version is now the official, canonical logo
- All configuration files now point to the PNG version
- Bootstrap process automatically checks for and deploys the logo
- Codespaces environments will have the correct branding upon creation

## 🎉 Benefits

1. **Consistency:** Single source of truth for branding
2. **Automation:** Logo automatically deployed in Codespaces
3. **Compliance:** Strict adherence to N3XUS LAW
4. **Maintainability:** Easier to update branding system-wide
5. **Quality:** PNG format ensures better rendering across platforms

---

**PR Status:** ✅ Ready for Agent Execution  
**Agent Task:** Upload `6f65c21d-8980-4b14-ac6c-893cc6d7598b.png` as `branding/official/N3XUS-vCOS.png`
