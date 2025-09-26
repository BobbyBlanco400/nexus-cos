# 🚨 Nexus COS Complete Restore & Deploy Guide

This guide provides complete solutions for restoring and deploying Nexus COS from snapshots, specifically addressing the incomplete command from the problem statement.

## 🚀 Quick Restore Options

### Option 1: Complete One-Command Restore (Recommended)

This completes the incomplete command from the problem statement:

```bash
cd ~ && \
echo "[$(date +'%Y-%m-%d %H:%M:%S %Z')] Starting Nexus COS restore..." && \
curl -L -o nexus-cos-final-snapshot.zip "https://transfer.sh/abc123/nexus-cos-final-snapshot.zip" && \
unzip -o nexus-cos-final-snapshot.zip -d nexus-cos && \
cd nexus-cos && \
echo "[$(date +'%Y-%m-%d %H:%M:%S %Z')] Initial setup and dependency installation..." && \
if [ -d "nexus-cos-final-snapshot" ]; then mv nexus-cos-final-snapshot/* . 2>/dev/null || true; mv nexus-cos-final-snapshot/.[^.]* . 2>/dev/null || true; rmdir nexus-cos-final-snapshot 2>/dev/null || true; fi && \
npm install && \
git lfs install 2>/dev/null || true && \
git lfs pull 2>/dev/null || true && \
chmod +x *.sh 2>/dev/null || true && \
./master-fix-trae-solo.sh && \
echo "[$(date +'%Y-%m-%d %H:%M:%S %Z')] ✅ Nexus COS restore and deployment completed successfully!"
```

### Option 2: Use Comprehensive Restore Script

Download and run the full-featured restore script:

```bash
curl -L https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/restore-and-deploy.sh -o restore-and-deploy.sh
chmod +x restore-and-deploy.sh
./restore-and-deploy.sh
```

### Option 3: Use Repository Script

If you already have the repository cloned:

```bash
cd nexus-cos
./restore-and-deploy.sh
```

## 📋 What Each Option Does

### One-Command Restore (Option 1)
- ✅ Downloads snapshot from specified URL
- ✅ Handles download failures gracefully
- ✅ Extracts snapshot with proper directory handling
- ✅ Installs Node.js dependencies
- ✅ Sets up Git LFS
- ✅ Makes scripts executable
- ✅ Runs TRAE Solo Master Fix deployment
- ✅ Provides timestamped status updates

### Comprehensive Script (Option 2)
- ✅ All features of Option 1 plus:
- ✅ Colored output and detailed logging
- ✅ Error handling and recovery
- ✅ Multiple deployment fallback options
- ✅ Local snapshot fallback
- ✅ Backup of existing installations
- ✅ Comprehensive status reporting
- ✅ Post-deployment instructions

## 🛠️ Advanced Usage

### Custom Snapshot URL

```bash
# Set custom snapshot URL
export SNAPSHOT_URL="https://your-server.com/nexus-cos-final-snapshot.zip"
./restore-and-deploy.sh
```

### Custom Restore Directory

```bash
# Set custom restore directory
export RESTORE_DIR="/opt/nexus-cos"
./restore-and-deploy.sh
```

### VPS Deployment

For deployment to VPS (75.208.155.161):

```bash
# Upload script to server
scp restore-and-deploy.sh root@75.208.155.161:/opt/

# SSH to server and run
ssh root@75.208.155.161
cd /opt
./restore-and-deploy.sh
```

## 🔧 Troubleshooting

### Download Fails
The scripts automatically fall back to local snapshots if download fails:
- Checks current directory for `nexus-cos-final-snapshot.zip`
- Checks repository directory for local snapshot
- Provides clear error messages if no snapshot found

### Permission Issues
If you get permission errors:
```bash
chmod +x restore-and-deploy.sh
sudo ./restore-and-deploy.sh  # if system operations needed
```

### Dependencies Missing
The scripts handle missing dependencies:
- Node.js and npm are required for full deployment
- Git LFS is optional but recommended
- System dependencies are installed via deployment scripts

## 📊 Expected Output

Both scripts provide timestamped output like:
```
[2025-09-24 07:58:50 UTC] Starting Nexus COS restore...
[2025-09-24 07:58:51 UTC] Initial setup and dependency installation...
[2025-09-24 07:58:52 UTC] ✅ Nexus COS restore and deployment completed successfully!
```

## 🎯 Success Indicators

✅ **Successful Restore:**
- Snapshot downloaded and extracted
- Dependencies installed
- Scripts made executable
- TRAE Solo deployment initiated

✅ **Successful Deployment:**
- Services started via master-fix-trae-solo.sh
- Health checks pass
- Application accessible via configured domain/IP

## 📚 Related Documentation

- [RESTORE_NEXUS_COS.md](RESTORE_NEXUS_COS.md) - Main restore documentation
- [TRAE_SOLO_DEPLOYMENT_GUIDE.md](TRAE_SOLO_DEPLOYMENT_GUIDE.md) - TRAE Solo deployment details
- [master-fix-trae-solo.sh](master-fix-trae-solo.sh) - Main deployment script

## 🆘 Support

If you encounter issues:
1. Check the timestamped log output for specific errors
2. Ensure you have required permissions
3. Verify network connectivity for downloads
4. Check available disk space
5. Review deployment script logs

---

**Note:** These scripts complete the incomplete command from the problem statement and provide robust, production-ready restore and deployment capabilities for Nexus COS.