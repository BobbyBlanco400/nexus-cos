@echo off
setlocal

set VPS_HOST=74.208.155.161
set SSH_USER=root
set SSH_KEY=%USERPROFILE%\.ssh\nexuscos_key
set DOMAIN=nexuscos.online

REM Generate SSH key if it doesn't exist
if not exist "%SSH_KEY%" (
    echo 🔑 Generating SSH key...
    ssh-keygen -t rsa -b 4096 -f "%SSH_KEY%" -N "" -C "nexuscos-deploy"
    
    echo 📤 Copying SSH key to VPS...
    type "%SSH_KEY%.pub" | ssh -o "StrictHostKeyChecking=no" %SSH_USER%@%VPS_HOST% "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
)

echo 🚀 Nexus COS VPS Deployment Starting...
echo 📍 Target: %VPS_HOST%
echo 🌐 Domain: %DOMAIN%

if not exist "vps-deploy-script.sh" (
    echo ❌ vps-deploy-script.sh not found!
    echo Please ensure the bash deployment script exists.
    pause
    exit /b 1
)

where ssh >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ SSH client found. Proceeding with deployment...
    
    echo 📤 Creating upload directory on VPS...
     ssh -o "StrictHostKeyChecking=no" "%SSH_USER%@%VPS_HOST%" "mkdir -p /tmp/nexus-cos-upload"
     
     echo 📤 Uploading project files to VPS...
    scp -r -o "StrictHostKeyChecking=no" -i "%SSH_KEY%" . "%SSH_USER%@%VPS_HOST%:/tmp/nexus-cos-upload/"
    
    echo 📤 Uploading deployment script to VPS...
    scp -o "StrictHostKeyChecking=no" -i "%SSH_KEY%" "vps-deploy-script.sh" "%SSH_USER%@%VPS_HOST%:/tmp/"
    
    echo 🚀 Executing deployment on VPS...
    ssh -o "StrictHostKeyChecking=no" -i "%SSH_KEY%" "%SSH_USER%@%VPS_HOST%" "chmod +x /tmp/vps-deploy-script.sh; /tmp/vps-deploy-script.sh"
    
    echo ✅ Deployment completed!
    echo 🌐 Site: https://%DOMAIN%
    echo 🔧 Admin: https://%DOMAIN%/admin
) else (
    echo ❌ No SSH client found. Manual deployment required.
    echo 📋 Manual Instructions:
    echo 1. Copy vps-deploy-script.sh to your VPS
    echo 2. SSH to %VPS_HOST% as %SSH_USER%
    echo 3. Run: chmod +x vps-deploy-script.sh
    echo 4. Run: ./vps-deploy-script.sh
)

echo 🎯 Deployment process completed!
pause