# NEXUS COS VPS Launch Setup Script
# Handles SSH key generation, VPS connection, and automated deployment

param(
    [switch]$GenerateSSHKey,
    [switch]$DeployToVPS,
    [switch]$FullSetup,
    [string]$SSHKeyPath = "$env:USERPROFILE\.ssh\nexus-cos-vps"
)

# Configuration from .env file
$VPS_HOST = "nexuscos.online"
$VPS_USER = "root"
$DOMAIN = "nexuscos.online"
$EMAIL = "puaboverse@gmail.com"

Write-Host "=== NEXUS COS VPS Launch Setup ===" -ForegroundColor Cyan
Write-Host "VPS Host: $VPS_HOST" -ForegroundColor Green
Write-Host "VPS User: $VPS_USER" -ForegroundColor Green
Write-Host "Domain: $DOMAIN" -ForegroundColor Green

# Function to generate SSH key
function Generate-SSHKey {
    Write-Host "`n[1/4] Generating SSH Key Pair..." -ForegroundColor Yellow
    
    # Create .ssh directory if it doesn't exist
    $sshDir = Split-Path $SSHKeyPath
    if (!(Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    }
    
    # Generate SSH key pair
    if (Test-Path "$SSHKeyPath") {
        Write-Host "SSH key already exists at: $SSHKeyPath" -ForegroundColor Yellow
        $overwrite = Read-Host "Overwrite existing key? (y/N)"
        if ($overwrite -ne 'y' -and $overwrite -ne 'Y') {
            Write-Host "Using existing SSH key." -ForegroundColor Green
            return $true
        }
    }
    
    # Use ssh-keygen if available
    try {
        $keygenCmd = "ssh-keygen -t rsa -b 4096 -f `"$SSHKeyPath`" -N `"`" -C `"nexus-cos-vps@$env:COMPUTERNAME`""
        Invoke-Expression $keygenCmd
        Write-Host "SSH key pair generated successfully!" -ForegroundColor Green
        Write-Host "  Private key: $SSHKeyPath" -ForegroundColor Gray
        Write-Host "  Public key: $SSHKeyPath.pub" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "ssh-keygen not found. Please install OpenSSH or Git for Windows." -ForegroundColor Red
        Write-Host "`nAlternative: Use PuTTYgen to generate an SSH key pair:" -ForegroundColor Yellow
        Write-Host "1. Download PuTTYgen from https://www.putty.org/" -ForegroundColor Gray
        Write-Host "2. Generate RSA 4096-bit key pair" -ForegroundColor Gray
        Write-Host "3. Save private key as: $SSHKeyPath.ppk" -ForegroundColor Gray
        Write-Host "4. Save public key as: $SSHKeyPath.pub" -ForegroundColor Gray
        return $false
    }
}

# Function to display public key for VPS setup
function Show-PublicKey {
    Write-Host "`n[2/4] SSH Public Key Setup" -ForegroundColor Yellow
    
    if (Test-Path "$SSHKeyPath.pub") {
        $publicKey = Get-Content "$SSHKeyPath.pub" -Raw
        Write-Host "`nCopy this public key to your VPS:" -ForegroundColor Cyan
        Write-Host "$publicKey" -ForegroundColor White -BackgroundColor DarkBlue
        
        Write-Host "`nVPS Setup Instructions:" -ForegroundColor Yellow
        Write-Host "1. Connect to your VPS: ssh $VPS_USER@$VPS_HOST" -ForegroundColor Gray
        Write-Host "2. Create SSH directory: mkdir -p ~/.ssh" -ForegroundColor Gray
        Write-Host "3. Add public key: echo '$publicKey' >> ~/.ssh/authorized_keys" -ForegroundColor Gray
        Write-Host "4. Set permissions: chmod 600 ~/.ssh/authorized_keys; chmod 700 ~/.ssh" -ForegroundColor Gray
        
        # Copy to clipboard if possible
        try {
            $publicKey | Set-Clipboard
            Write-Host "`nPublic key copied to clipboard!" -ForegroundColor Green
        }
        catch {
            Write-Host "`nPlease manually copy the public key above." -ForegroundColor Yellow
        }
        return $true
    }
    else {
        Write-Host "Public key not found. Please generate SSH key first." -ForegroundColor Red
        return $false
    }
}

# Function to test SSH connection
function Test-SSHConnection {
    Write-Host "`n[3/4] Testing SSH Connection..." -ForegroundColor Yellow
    
    if (!(Test-Path "$SSHKeyPath")) {
        Write-Host "Private key not found: $SSHKeyPath" -ForegroundColor Red
        return $false
    }
    
    try {
        $sshCmd = "ssh -i `"$SSHKeyPath`" -o ConnectTimeout=10 -o StrictHostKeyChecking=no `"$VPS_USER@$VPS_HOST`" `"echo 'SSH connection successful'`""
        $result = Invoke-Expression $sshCmd
        if ($result -eq "SSH connection successful") {
            Write-Host "SSH connection successful!" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "SSH connection failed." -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "SSH connection error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
        Write-Host "1. Ensure the public key is added to VPS ~/.ssh/authorized_keys" -ForegroundColor Gray
        Write-Host "2. Check VPS firewall allows SSH (port 22)" -ForegroundColor Gray
        Write-Host "3. Verify VPS is running and accessible" -ForegroundColor Gray
        return $false
    }
}

# Function to deploy to VPS
function Deploy-ToVPS {
    Write-Host "`n[4/4] Deploying NEXUS COS to VPS..." -ForegroundColor Yellow
    
    # Update environment file with SSH key path
    $envFile = ".trae\environment.env"
    if (Test-Path $envFile) {
        $envContent = Get-Content $envFile
        $newEnvContent = @()
        $sshKeySet = $false
        
        foreach ($line in $envContent) {
            if ($line -match "^VPS_SSH_KEY=") {
                $newEnvContent += "VPS_SSH_KEY=$SSHKeyPath"
                $sshKeySet = $true
            }
            else {
                $newEnvContent += $line
            }
        }
        
        if (!$sshKeySet) {
            $newEnvContent += "VPS_SSH_KEY=$SSHKeyPath"
        }
        
        $newEnvContent | Set-Content $envFile
        Write-Host "Updated environment file with SSH key path" -ForegroundColor Green
    }
    
    # Run the VPS deployment script
    if (Test-Path "scripts\vps-deploy.sh") {
        Write-Host "Starting VPS deployment..." -ForegroundColor Cyan
        
        # Convert to WSL path if running on Windows
        $wslPath = (Get-Location).Path -replace '^([A-Z]):', '/mnt/$1' -replace '\\', '/'
        $wslPath = $wslPath.ToLower()
        
        try {
            $wslCmd = "wsl bash -c `"cd '$wslPath'; chmod +x scripts/vps-deploy.sh; ./scripts/vps-deploy.sh`""
            Invoke-Expression $wslCmd
            Write-Host "VPS deployment completed!" -ForegroundColor Green
        }
        catch {
            Write-Host "VPS deployment failed: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "`nTry running manually:" -ForegroundColor Yellow
            Write-Host "wsl bash -c `"cd '$wslPath'; ./scripts/vps-deploy.sh`"" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "VPS deployment script not found: scripts\vps-deploy.sh" -ForegroundColor Red
    }
}

# Function to show final status
function Show-FinalStatus {
    Write-Host "`n=== DEPLOYMENT STATUS ===" -ForegroundColor Cyan
    
    Write-Host "`nAccess URLs:" -ForegroundColor Yellow
    Write-Host "  Main Site: https://$DOMAIN" -ForegroundColor Green
    Write-Host "  Admin Panel: https://$DOMAIN/admin" -ForegroundColor Green
    Write-Host "  Creator Dashboard: https://$DOMAIN/creator" -ForegroundColor Green
    Write-Host "  API Gateway: https://$DOMAIN/api" -ForegroundColor Green
    
    Write-Host "`nManagement Commands:" -ForegroundColor Yellow
    Write-Host "  SSH to VPS: ssh -i `"$SSHKeyPath`" $VPS_USER@$VPS_HOST" -ForegroundColor Gray
    Write-Host "  View logs: ssh -i `"$SSHKeyPath`" $VPS_USER@$VPS_HOST 'docker-compose -f /opt/nexus-cos/docker-compose.yml logs'" -ForegroundColor Gray
    Write-Host "  Restart services: ssh -i `"$SSHKeyPath`" $VPS_USER@$VPS_HOST 'docker-compose -f /opt/nexus-cos/docker-compose.yml restart'" -ForegroundColor Gray
    
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "1. Verify all services are running" -ForegroundColor Gray
    Write-Host "2. Configure DNS to point to VPS IP" -ForegroundColor Gray
    Write-Host "3. Set up SSL certificates" -ForegroundColor Gray
    Write-Host "4. Configure monitoring and backups" -ForegroundColor Gray
}

# Main execution logic
if ($FullSetup) {
    $GenerateSSHKey = $true
    $DeployToVPS = $true
}

if ($GenerateSSHKey -or $FullSetup) {
    if (Generate-SSHKey) {
        if (Show-PublicKey) {
            Write-Host "`nPlease set up the public key on your VPS and press Enter to continue..." -ForegroundColor Yellow
            Read-Host
            
            if (Test-SSHConnection) {
                if ($DeployToVPS) {
                    Deploy-ToVPS
                    Show-FinalStatus
                }
            }
        }
    }
}
elseif ($DeployToVPS) {
    if (Test-SSHConnection) {
        Deploy-ToVPS
        Show-FinalStatus
    }
}
else {
    Write-Host "`nNEXUS COS VPS Launch Options:" -ForegroundColor Yellow
    Write-Host "  -GenerateSSHKey    Generate SSH key pair for VPS access" -ForegroundColor Gray
    Write-Host "  -DeployToVPS       Deploy to VPS (requires SSH key setup)" -ForegroundColor Gray
    Write-Host "  -FullSetup         Complete setup (generate key + deploy)" -ForegroundColor Gray
    Write-Host "`nExample: .\vps-launch-setup.ps1 -FullSetup" -ForegroundColor Cyan
    
    Write-Host "`nCurrent Configuration:" -ForegroundColor Yellow
    Write-Host "  VPS Host: $VPS_HOST" -ForegroundColor Gray
    Write-Host "  VPS User: $VPS_USER" -ForegroundColor Gray
    Write-Host "  SSH Key: $SSHKeyPath" -ForegroundColor Gray
    Write-Host "  Domain: $DOMAIN" -ForegroundColor Gray
}

Write-Host "`n=== VPS Launch Setup Complete ===" -ForegroundColor Cyan