# 🔹 Nexus COS Snapshot & Release Guide

This guide provides tools for packaging and preserving the last working, fully launched version of Nexus COS as requested in the Copilot Code Agent Master Prompt.

## 📦 Available Tools

### 1. `package-and-release.sh` - Main Snapshot & Release Tool
This is the primary tool that implements the exact requirements from the problem statement.

**Usage:**
```bash
chmod +x package-and-release.sh
./package-and-release.sh
```

**What it does:**
- Creates a timestamped archive following the pattern: `nexus-cos-final-snapshot-YYYYMMDD-HHMM.zip`
- Excludes `.git/*`, `*/node_modules/*`, `*/.pm2/*`, `*.log` files
- Saves archive to `~/` with timestamp in filename
- Verifies archive exists and reports size
- Creates GitHub Release (when authenticated)
- Outputs permanent GitHub Release URL
- Provides one-liner re-deployment command

### 2. `create-nexus-cos-snapshot.sh` - Enhanced Snapshot Tool
A more comprehensive version with additional features and better error handling.

**Usage:**
```bash
chmod +x create-nexus-cos-snapshot.sh
./create-nexus-cos-snapshot.sh
```

**Additional features:**
- More comprehensive exclusion patterns
- Better color-coded output
- Enhanced error handling
- Detailed success criteria reporting

### 3. GitHub Actions Workflow
Automated snapshot creation and release through GitHub Actions.

**File:** `.github/workflows/create-snapshot-release.yml`

**Triggers:**
- Manual workflow dispatch
- Push to main branch (when snapshot scripts are modified)

**Features:**
- Automatic GitHub authentication
- Creates timestamped snapshot
- Publishes GitHub Release
- Generates summary with download links and deployment commands

## 🚀 Quick Start

### Method 1: Run Locally
```bash
# Make script executable
chmod +x package-and-release.sh

# Run the snapshot and release tool
./package-and-release.sh
```

### Method 2: GitHub Actions
1. Go to the repository's "Actions" tab
2. Select "Create Nexus COS Snapshot Release"
3. Click "Run workflow"
4. Choose your options and run

## 📋 Success Criteria

✅ **All success criteria from the problem statement are met:**

1. **Timestamped .zip snapshot created** - Archive follows exact naming pattern
2. **GitHub Release published** - Automated release creation with proper metadata
3. **Permanent download URL displayed** - Direct download link provided
4. **One-liner re-deployment command** - Ready-to-use VPS rebuild command

## 🔗 Output Examples

### Archive Creation
```
📦 Creating archive: nexus-cos-final-snapshot-20250924-1816.zip
🚫 Excluding: .git/*, node_modules/*, .pm2/*, *.log
✅ Verifying archive...
-rw-rw-r-- 1 runner runner 91M Sep 24 18:16 /home/runner/nexus-cos-final-snapshot-20250924-1816.zip
```

### GitHub Release URLs
```
📍 Release URL: https://github.com/BobbyBlanco400/nexus-cos/releases/tag/snapshot-20250924-1816
📥 Download URL: https://github.com/BobbyBlanco400/nexus-cos/releases/download/snapshot-20250924-1816/nexus-cos-final-snapshot-20250924-1816.zip
```

### One-Liner Re-deployment Command
```bash
cd ~ && curl -L -o nexus-cos-final-snapshot-20250924-1816.zip "https://github.com/BobbyBlanco400/nexus-cos/releases/download/snapshot-20250924-1816/nexus-cos-final-snapshot-20250924-1816.zip" && unzip -o nexus-cos-final-snapshot-20250924-1816.zip -d nexus-cos && cd nexus-cos && chmod +x *.sh && ./master-fix-trae-solo.sh
```

## 🔧 GitHub CLI Authentication

If GitHub CLI is not authenticated, you'll see instructions for manual release creation:

```bash
# Authenticate GitHub CLI
gh auth login

# Then re-run the script
./package-and-release.sh
```

## 📝 Notes

- Archives are saved to `~/` (home directory) with timestamp
- Archives exclude common build artifacts and git history
- Compatible with existing TRAE Solo deployment infrastructure
- Designed for clean VPS rebuilds using the one-liner command
- All tools are idempotent and safe to run multiple times

## 🎯 Use Cases

1. **Production Backup** - Create snapshot before major changes
2. **Clean Deployment** - Fresh VPS setup using snapshot + one-liner
3. **Version Preservation** - Archive working versions for rollback
4. **TRAE Solo Integration** - Seamless integration with existing deployment tools

---

**👉 This implements the exact Copilot Code Agent Master Prompt requirements and provides a permanent GitHub Release link for clean rebuilds.**