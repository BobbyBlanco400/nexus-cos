# DEPLOY_NEXUS_LAW.ps1
# N3XUS LAW Compliance Deployment Script
# Hostinger VPS: 72.62.86.217 (n3xuscos.online)
# 
# This script enforces N3XUS LAW compliance:
# - Uses Hostinger VPS IP: 72.62.86.217 (NOT IONOS: 74.208.155.161)
# - Enforces X-N3XUS-Handshake: 55-45-17
# - Uses Let's Encrypt SSL (NOT IONOS certificates)

param(
    [switch]$Verify,
    [switch]$Deploy
)

$VPS_IP = "72.62.86.217"
$VPS_USER = "root"
$DOMAIN = "n3xuscos.online"

Write-Host "🛡️ N3XUS LAW Compliance Deployment" -ForegroundColor Cyan
Write-Host "Target: $VPS_USER@$VPS_IP ($DOMAIN)" -ForegroundColor Yellow
Write-Host ""

# Verification Mode
if ($Verify) {
    Write-Host "🔍 Verifying N3XUS LAW Compliance..." -ForegroundColor Yellow
    
    # Check for IONOS violations
    Write-Host "Checking for IONOS IP violations (74.208.155.161)..."
    $ionosViolations = Select-String -Path "docker-compose.pf.yml", "nginx.conf.docker" -Pattern "74.208.155.161" -ErrorAction SilentlyContinue
    
    if ($ionosViolations) {
        Write-Host "❌ IONOS IP VIOLATION FOUND!" -ForegroundColor Red
        $ionosViolations | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
        exit 1
    } else {
        Write-Host "✅ No IONOS IP violations" -ForegroundColor Green
    }
    
    # Check for N3XUS Handshake
    Write-Host "Checking for N3XUS Handshake 55-45-17..."
    $handshakeFound = Select-String -Path "nginx.conf.docker" -Pattern "X-N3XUS-Handshake.*55-45-17" -ErrorAction SilentlyContinue
    
    if ($handshakeFound) {
        Write-Host "✅ N3XUS Handshake enforced" -ForegroundColor Green
    } else {
        Write-Host "❌ N3XUS Handshake NOT found!" -ForegroundColor Red
        exit 1
    }
    
    # Check for Let's Encrypt (not IONOS SSL)
    Write-Host "Checking SSL configuration..."
    $letsencryptFound = Select-String -Path "docker-compose.pf.yml" -Pattern "/etc/letsencrypt" -ErrorAction SilentlyContinue
    $ionosSSL = Select-String -Path "docker-compose.pf.yml" -Pattern "ionos" -ErrorAction SilentlyContinue
    
    if ($letsencryptFound -and !$ionosSSL) {
        Write-Host "✅ Let's Encrypt SSL configured" -ForegroundColor Green
    } else {
        Write-Host "❌ SSL configuration violation!" -ForegroundColor Red
        if ($ionosSSL) {
            Write-Host "   IONOS SSL reference found (forbidden)" -ForegroundColor Red
        }
        exit 1
    }
    
    Write-Host ""
    Write-Host "✅ ALL COMPLIANCE CHECKS PASSED" -ForegroundColor Green
    exit 0
}

# Deployment Mode
if ($Deploy) {
    Write-Host "🚀 Deploying to N3XUS LAW Compliant Infrastructure..." -ForegroundColor Cyan
    
    # Build the deployment command
    $deployCommand = @"
cd /opt/nexus-cos && \
git pull origin main && \
cp .env.pf .env && \
docker compose -f docker-compose.pf.yml down && \
docker compose -f docker-compose.pf.yml up -d --build --remove-orphans && \
sleep 15 && \
curl -fsS https://n3xuscos.online/v-suite/prompter/health && \
echo '✅ DEPLOYMENT SUCCESS'
"@
    
    Write-Host "Executing deployment on $VPS_IP..." -ForegroundColor Yellow
    
    # Execute via SSH
    $sshCommand = "ssh -o StrictHostKeyChecking=no $VPS_USER@$VPS_IP `"$deployCommand`""
    
    Write-Host "Command: $sshCommand" -ForegroundColor Gray
    Write-Host ""
    
    Invoke-Expression $sshCommand
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ DEPLOYMENT COMPLETED SUCCESSFULLY" -ForegroundColor Green
        Write-Host "🌐 Site: https://$DOMAIN" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "❌ DEPLOYMENT FAILED" -ForegroundColor Red
        exit 1
    }
    
    exit 0
}

# No parameters - show usage
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  .\DEPLOY_NEXUS_LAW.ps1 -Verify   # Verify compliance"
Write-Host "  .\DEPLOY_NEXUS_LAW.ps1 -Deploy   # Deploy to VPS"
Write-Host ""
Write-Host "One-liner deployment:" -ForegroundColor Yellow
Write-Host @"
ssh -o StrictHostKeyChecking=no root@72.62.86.217 "cd /opt/nexus-cos && git pull origin main && cp .env.pf .env && docker compose -f docker-compose.pf.yml down && docker compose -f docker-compose.pf.yml up -d --build --remove-orphans && sleep 15 && curl -fsS https://n3xuscos.online/v-suite/prompter/health && echo '✅ DEPLOYMENT SUCCESS'"
"@ -ForegroundColor Gray
