#!/bin/bash
# 🚨 NEXUS COS COMPLETE RESTORE COMMAND
# This completes the incomplete command from the problem statement exactly as it was structured

# Complete the original incomplete command:
cd ~ && \
echo "[$(date +'%Y-%m-%d %H:%M:%S %Z')] Starting Nexus COS restore..." && \
curl -L -o nexus-cos-final-snapshot.zip "https://transfer.sh/abc123/nexus-cos-final-snapshot.zip" && \
unzip -o nexus-cos-final-snapshot.zip -d nexus-cos && \
cd nexus-cos && \
echo "[$(date +'%Y-%m-%d %H:%M:%S %Z')] Initial setup and dependency installation..." && \
# Handle nested directory structure from zip extraction
if [ -d "nexus-cos-final-snapshot" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S %Z')] Moving extracted files from nested directory..."
    mv nexus-cos-final-snapshot/* . 2>/dev/null || true
    mv nexus-cos-final-snapshot/.[^.]* . 2>/dev/null || true
    rmdir nexus-cos-final-snapshot 2>/dev/null || true
fi && \
echo "[$(date +'%Y-%m-%d %H:%M:%S %Z')] Installing Node.js dependencies..." && \
npm install && \
echo "[$(date +'%Y-%m-%d %H:%M:%S %Z')] Setting up Git LFS..." && \
git lfs install 2>/dev/null || true && \
git lfs pull 2>/dev/null || true && \
echo "[$(date +'%Y-%m-%d %H:%M:%S %Z')] Making deployment scripts executable..." && \
chmod +x *.sh 2>/dev/null || true && \
echo "[$(date +'%Y-%m-%d %H:%M:%S %Z')] Running TRAE Solo Master Fix deployment..." && \
./master-fix-trae-solo.sh && \
echo "[$(date +'%Y-%m-%d %H:%M:%S %Z')] ✅ Nexus COS restore and deployment completed successfully!"