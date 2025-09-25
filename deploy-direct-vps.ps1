param(
    [string]$VpsHost = "74.208.155.161",
    [string]$SshUser = "root", 
    [string]$Domain = "nexuscos.online"
)

Write-Host "Nexus COS VPS Deployment Starting..." -ForegroundColor Green
Write-Host "Target: $VpsHost" -ForegroundColor Yellow
Write-Host "Domain: $Domain" -ForegroundColor Yellow

if (-not (Test-Path "vps-deploy-script.sh")) {
    Write-Host "vps-deploy-script.sh not found!" -ForegroundColor Red
    exit 1
}

if (Get-Command ssh -ErrorAction SilentlyContinue) {
    Write-Host "SSH client found. Proceeding with deployment..." -ForegroundColor Green
    
    Write-Host "Uploading project snapshot zip to VPS..." -ForegroundColor Yellow
    scp -o "StrictHostKeyChecking=no" "nexus-cos-vps-deploy.zip" "${SshUser}@${VpsHost}:/tmp/"
    Write-Host "Uploading deployment script to VPS..." -ForegroundColor Yellow
    scp -o "StrictHostKeyChecking=no" "vps-deploy-script.sh" "${SshUser}@${VpsHost}:/tmp/"
    
    Write-Host "Executing deployment on VPS..." -ForegroundColor Yellow
    ssh -o "StrictHostKeyChecking=no" "${SshUser}@${VpsHost}" "chmod +x /tmp/vps-deploy-script.sh; /tmp/vps-deploy-script.sh"
    
    Write-Host "Deployment completed!" -ForegroundColor Green
    Write-Host "Site: https://$Domain" -ForegroundColor Cyan
    Write-Host "Admin: https://$Domain/admin" -ForegroundColor Cyan
} else {
    Write-Host "No SSH client found. Manual deployment required." -ForegroundColor Red
    Write-Host "Manual Instructions:" -ForegroundColor Yellow
    Write-Host "1. Copy vps-deploy-script.sh to your VPS" -ForegroundColor White
    Write-Host "2. SSH to $VpsHost as $SshUser" -ForegroundColor White
    Write-Host "3. Run: chmod +x vps-deploy-script.sh" -ForegroundColor White
    Write-Host "4. Run: ./vps-deploy-script.sh" -ForegroundColor White
}

Write-Host "Deployment process completed!" -ForegroundColor Green