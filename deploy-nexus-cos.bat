@echo off
REM TRAE SOLO 🚀 NEXUS COS Deployment Batch Script
REM Simple wrapper to execute the bash deployment script

echo.
echo 🚀 TRAE SOLO - NEXUS COS Deployment Manager
echo ============================================
echo.
echo Target VPS: 74.208.155.161
echo Domain: nexuscos.online
echo.

REM Check if WSL is available
wsl --list --quiet >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ WSL not found. Please install WSL first.
    echo Run: wsl --install
    pause
    exit /b 1
)

echo ✅ WSL is available
echo.

REM Check if deployment script exists
if not exist "trae-solo-full-deploy.sh" (
    echo ❌ Deployment script not found: trae-solo-full-deploy.sh
    pause
    exit /b 1
)

echo ✅ Deployment script found
echo.

REM Install WSL dependencies
echo 📦 Installing WSL dependencies...
wsl -- bash -c "sudo apt update && sudo apt install -y sshpass curl wget"
if %errorlevel% neq 0 (
    echo ❌ Failed to install WSL dependencies
    pause
    exit /b 1
)

echo ✅ WSL dependencies installed
echo.

REM Make script executable
wsl -- bash -c "chmod +x /mnt/c/Users/wecon/Downloads/nexus-cos-main/trae-solo-full-deploy.sh"

REM Execute deployment script
echo 🚀 Starting TRAE SOLO Full NEXUS COS Deployment
echo 🔄 Executing deployment script...
echo.

wsl -- bash -c "cd /mnt/c/Users/wecon/Downloads/nexus-cos-main && ./trae-solo-full-deploy.sh"

if %errorlevel% equ 0 (
    echo.
    echo 🎉 DEPLOYMENT SUCCESSFUL! 🎉
    echo.
    echo 🌐 Your NEXUS COS is now live at: https://nexuscos.online
    echo 📊 Node.js Health: https://nexuscos.online/health
    echo 🐍 Python Health: https://nexuscos.online/py/health
    echo 📱 Mobile Downloads: https://nexuscos.online/mobile/
    echo.
    
    REM Display deployment summary if it exists
    if exist "nexus-cos-deployment-summary.txt" (
        echo 📋 Deployment summary:
        type "nexus-cos-deployment-summary.txt"
        echo.
    )
) else (
    echo.
    echo ❌ DEPLOYMENT FAILED!
    echo Check the deployment logs for details.
    echo.
)

echo 📝 Deployment completed at %date% %time%
echo.
pause