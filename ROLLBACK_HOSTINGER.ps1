$VPS_IP = "72.62.86.217"
$USER = "root"
$KEY_PATH = "$HOME\.ssh\id_ed25519_vps" # Adjust if needed
$REMOTE_DIR = "/opt/nexus-cos"

Write-Host "🚀 N3XUS ROLLBACK LAUNCHER" -ForegroundColor Cyan
Write-Host "Target: $VPS_IP" -ForegroundColor Gray

# 1. Upload Rollback Script
Write-Host "1. Uploading rollback script..." -ForegroundColor Yellow
scp -i $KEY_PATH .\ROLLBACK_CANONICAL_13.sh ${USER}@${VPS_IP}:${REMOTE_DIR}/ROLLBACK_CANONICAL_13.sh

# 2. Upload Advisory
Write-Host "2. Uploading advisory..." -ForegroundColor Yellow
scp -i $KEY_PATH .\TRAE_DEPLOYMENT_ROLLBACK_ADVISORY.md ${USER}@${VPS_IP}:${REMOTE_DIR}/TRAE_DEPLOYMENT_ROLLBACK_ADVISORY.md

# 3. Execute Remote Rollback
Write-Host "3. Executing remote rollback..." -ForegroundColor Yellow
ssh -i $KEY_PATH ${USER}@${VPS_IP} "chmod +x ${REMOTE_DIR}/ROLLBACK_CANONICAL_13.sh && ${REMOTE_DIR}/ROLLBACK_CANONICAL_13.sh"

Write-Host "✅ MISSION COMPLETE" -ForegroundColor Green
