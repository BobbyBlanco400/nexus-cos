@echo off
echo Starting Nexus COS Deployment...

REM Check if SSH key exists
powershell -Command "if (-not (Test-Path $env:USERPROFILE\.ssh\nexus-cos-vps)) { Write-Host 'SSH key not found. Please ensure the key is in place.'; exit 1 }"

REM Set VPS details
set VPS_HOST=74.208.155.161
set SSH_USER=root
set PROJECT_PATH=/var/www/nexus-cos

REM Copy nginx configuration
powershell -Command "scp -i $env:USERPROFILE\.ssh\nexus-cos-vps nginx/nginx.conf %SSH_USER%@%VPS_HOST%:/etc/nginx/nginx.conf"
powershell -Command "ssh -i $env:USERPROFILE\.ssh\nexus-cos-vps %SSH_USER%@%VPS_HOST% 'mkdir -p /etc/nginx/conf.d'"
powershell -Command "scp -i $env:USERPROFILE\.ssh\nexus-cos-vps nginx/conf.d/nexus-proxy.conf %SSH_USER%@%VPS_HOST%:/etc/nginx/conf.d/nexus-proxy.conf"

REM Connect and execute commands
powershell -Command "ssh -i $env:USERPROFILE\.ssh\nexus-cos-vps %SSH_USER%@%VPS_HOST% 'cd %PROJECT_PATH% && docker compose -f docker-compose.prod.yml down && docker compose -f docker-compose.prod.yml up -d && systemctl restart nginx && pm2 delete all && ./nexus-launch.sh'"

echo Deployment completed. Checking status...
powershell -Command "ssh -i $env:USERPROFILE\.ssh\nexus-cos-vps %SSH_USER%@%VPS_HOST% 'pm2 list'"