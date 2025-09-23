# TRAE SOLO - Windows PowerShell Deployment Script for NEXUS COS
# Handles SSH key setup and deployment on Windows

param(
    [string]$VpsHost = "74.208.155.161",
    [string]$VpsUser = "root",
    [string]$VpsPassword = "I29FgNi4",
    [string]$Domain = "nexuscos.online",
    [string]$GitRepo = "https://github.com/BobbyBlanco400/nexus-cos.git",
    [switch]$FullDeploy
)

# Configuration
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"
$SSHKeyPath = "$env:USERPROFILE\.ssh\nexus-cos-vps"
$SSHPubKeyPath = "$env:USERPROFILE\.ssh\nexus-cos-vps.pub"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Setup-SSHKey {
    Write-ColorOutput "Setting up SSH key authentication..." "Yellow"
    
    if (-not (Test-Path $SSHPubKeyPath)) {
        Write-ColorOutput "SSH public key not found at $SSHPubKeyPath" "Red"
        Write-ColorOutput "Please run generate-ssh-key.bat first." "Red"
        return $false
    }
    
    # Read the public key
    $publicKey = Get-Content $SSHPubKeyPath -Raw
    $publicKey = $publicKey.Trim()
    
    Write-ColorOutput "Public key found. Setting up on VPS..." "Green"
    
    # Create the authorized_keys setup command
    $setupCommand = @"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo '$publicKey' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
sort ~/.ssh/authorized_keys | uniq > ~/.ssh/authorized_keys.tmp
mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys
echo 'SSH key setup complete'
"@
    
    # Use plink with password to setup the key
    try {
        if (Get-Command plink -ErrorAction SilentlyContinue) {
            Write-ColorOutput "Using PuTTY plink for SSH key setup..." "Cyan"
            $result = echo $setupCommand | plink -ssh -batch -pw $VpsPassword "$VpsUser@$VpsHost" 2>&1
        } else {
            Write-ColorOutput "Using OpenSSH for SSH key setup..." "Cyan"
            # For OpenSSH, we need to use a different approach
            $tempScript = "$env:TEMP\ssh_setup.sh"
            $setupCommand | Out-File -FilePath $tempScript -Encoding UTF8
            
            # Use scp to copy the script and then execute it
            Write-ColorOutput "You may need to enter the VPS password..." "Yellow"
            scp -o "StrictHostKeyChecking=no" $tempScript "$VpsUser@${VpsHost}:/tmp/ssh_setup.sh"
            ssh -o "StrictHostKeyChecking=no" "$VpsUser@$VpsHost" "chmod +x /tmp/ssh_setup.sh && /tmp/ssh_setup.sh && rm /tmp/ssh_setup.sh"
        }
        
        Write-ColorOutput "SSH key setup completed!" "Green"
        return $true
    } catch {
        Write-ColorOutput "SSH key setup failed: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Test-SSHKeyAuth {
    Write-ColorOutput "Testing SSH key authentication..." "Yellow"
    
    try {
        if (Get-Command plink -ErrorAction SilentlyContinue) {
            $result = plink -ssh -batch -i $SSHKeyPath "$VpsUser@$VpsHost" "echo 'SSH key auth successful'" 2>&1
        } else {
            $result = ssh -i $SSHKeyPath -o "StrictHostKeyChecking=no" "$VpsUser@$VpsHost" "echo 'SSH key auth successful'" 2>&1
        }
        
        if ($result -match "SSH key auth successful") {
            Write-ColorOutput "SSH key authentication working!" "Green"
            return $true
        } else {
            Write-ColorOutput "SSH key authentication failed: $result" "Red"
            return $false
        }
    } catch {
        Write-ColorOutput "SSH key test error: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Invoke-SSHKeyCommand {
    param(
        [string]$Command,
        [string]$Description = ""
    )
    
    if ($Description) {
        Write-ColorOutput "$Description" "Cyan"
    }
    
    Write-ColorOutput "Executing: $Command" "Gray"
    
    try {
        if (Get-Command plink -ErrorAction SilentlyContinue) {
            $result = plink -ssh -batch -i $SSHKeyPath "$VpsUser@$VpsHost" $Command 2>&1
        } else {
            $result = ssh -i $SSHKeyPath -o "StrictHostKeyChecking=no" "$VpsUser@$VpsHost" $Command 2>&1
        }
        
        Write-ColorOutput "Output: $result" "White"
        return $result
    } catch {
        Write-ColorOutput "Command failed: $($_.Exception.Message)" "Red"
        return $null
    }
}

function Deploy-NexusCOS {
    Write-ColorOutput "Starting NEXUS COS deployment..." "Green"
    
    # Step 1: Clean up old installations
    Invoke-SSHKeyCommand "rm -rf /var/www/nexus-cos /opt/nexus-cos" "Cleaning up old installations"
    Invoke-SSHKeyCommand "systemctl stop nexus-backend-node nexus-backend-python nginx 2>/dev/null || true" "Stopping old services"
    
    # Step 2: Update system and install dependencies
    Invoke-SSHKeyCommand "apt update; apt upgrade -y" "Updating system packages"
    Invoke-SSHKeyCommand "apt install -y nginx nodejs npm python3 python3-pip git curl certbot python3-certbot-nginx" "Installing system dependencies"
    
    # Step 3: Install Node.js 18+ and PM2
    Invoke-SSHKeyCommand "curl -fsSL https://deb.nodesource.com/setup_18.x | bash -" "Adding Node.js 18 repository"
    Invoke-SSHKeyCommand "apt install -y nodejs" "Installing Node.js 18"
    Invoke-SSHKeyCommand "npm install -g pm2" "Installing PM2 process manager"
    
    # Step 4: Clone repository
    Invoke-SSHKeyCommand "cd /opt; git clone $GitRepo nexus-cos" "Cloning NEXUS COS repository"
    Invoke-SSHKeyCommand "cd /opt/nexus-cos; git pull origin main" "Updating to latest version"
    
    # Step 5: Setup backend services
    Invoke-SSHKeyCommand "cd /opt/nexus-cos/backend; npm install" "Installing Node.js backend dependencies"
    Invoke-SSHKeyCommand "cd /opt/nexus-cos/backend; pip3 install -r requirements.txt" "Installing Python backend dependencies"
    
    # Step 6: Build frontend
    Invoke-SSHKeyCommand "cd /opt/nexus-cos/da-boom-boom-room/frontend; npm install" "Installing frontend dependencies"
    Invoke-SSHKeyCommand "cd /opt/nexus-cos/da-boom-boom-room/frontend; npm run build" "Building frontend application"
    
    # Step 7: Deploy frontend
    Invoke-SSHKeyCommand "mkdir -p /var/www/nexus-cos" "Creating web directory"
    Invoke-SSHKeyCommand "cp -r /opt/nexus-cos/da-boom-boom-room/frontend/dist/* /var/www/nexus-cos/" "Deploying frontend files"
    Invoke-SSHKeyCommand "mkdir -p /var/www/nexus-cos/mobile" "Creating mobile directory"
    
    # Step 8: Configure Nginx
    $nginxConfig = @'
server {
    listen 80;
    server_name nexuscos.online *.nexuscos.online;
    
    location / {
        root /var/www/nexus-cos;
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /py/ {
        proxy_pass http://localhost:3001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /health {
        proxy_pass http://localhost:3000/health;
    }
    
    location /py/health {
        proxy_pass http://localhost:3001/health;
    }
}
'@
    
    # Create nginx config using here-document
    Invoke-SSHKeyCommand "cat > /etc/nginx/sites-available/nexus-cos << 'NGINXEOF'`n$nginxConfig`nNGINXEOF" "Creating Nginx configuration"
    Invoke-SSHKeyCommand "ln -sf /etc/nginx/sites-available/nexus-cos /etc/nginx/sites-enabled/" "Enabling Nginx site"
    Invoke-SSHKeyCommand "rm -f /etc/nginx/sites-enabled/default" "Removing default Nginx site"
    
    # Step 9: Start backend services with PM2
    Invoke-SSHKeyCommand "cd /opt/nexus-cos/backend; pm2 start app.js --name nexus-backend-node" "Starting Node.js backend"
    Invoke-SSHKeyCommand "cd /opt/nexus-cos/backend; pm2 start main.py --name nexus-backend-python --interpreter python3" "Starting Python backend"
    Invoke-SSHKeyCommand "pm2 startup" "Setting up PM2 startup"
    Invoke-SSHKeyCommand "pm2 save" "Saving PM2 configuration"
    
    # Step 10: Test Nginx configuration and restart
    Invoke-SSHKeyCommand "nginx -t" "Testing Nginx configuration"
    Invoke-SSHKeyCommand "systemctl restart nginx" "Restarting Nginx"
    Invoke-SSHKeyCommand "systemctl enable nginx" "Enabling Nginx auto-start"
    
    # Step 11: Setup SSL with Certbot
    Write-ColorOutput "Setting up SSL certificates..." "Yellow"
    Invoke-SSHKeyCommand "certbot --nginx -d nexuscos.online --non-interactive --agree-tos --email puaboverse@gmail.com" "Installing SSL certificates"
    
    # Step 12: Setup auto-renewal
    Invoke-SSHKeyCommand "systemctl enable certbot.timer" "Enabling SSL auto-renewal"
    
    # Step 13: Final health checks
    Write-ColorOutput "Running health checks..." "Yellow"
    Start-Sleep -Seconds 10
    
    Invoke-SSHKeyCommand "curl -f http://localhost:3000/health; if [ `$? -ne 0 ]; then echo 'Node.js health check failed'; fi" "Testing Node.js backend"
    Invoke-SSHKeyCommand "curl -f http://localhost:3001/health; if [ `$? -ne 0 ]; then echo 'Python health check failed'; fi" "Testing Python backend"
    Invoke-SSHKeyCommand "curl -f http://nexuscos.online/health; if [ `$? -ne 0 ]; then echo 'Frontend health check failed'; fi" "Testing frontend"
    
    # Step 14: Display status
    Write-ColorOutput "Deployment Status:" "Green"
    Invoke-SSHKeyCommand "pm2 status" "PM2 process status"
    Invoke-SSHKeyCommand "systemctl status nginx --no-pager" "Nginx status"
    Invoke-SSHKeyCommand "certbot certificates" "SSL certificate status"
    
    Write-ColorOutput "NEXUS COS deployment completed!" "Green"
    Write-ColorOutput "Website: https://nexuscos.online" "Cyan"
    Write-ColorOutput "Node.js Health: https://nexuscos.online/health" "Cyan"
    Write-ColorOutput "Python Health: https://nexuscos.online/py/health" "Cyan"
}

# Main execution
Write-ColorOutput "TRAE SOLO - NEXUS COS Deployment Manager" "Magenta"
Write-ColorOutput "==================================================" "Magenta"
Write-ColorOutput "Target VPS: $VpsHost" "White"
Write-ColorOutput "Domain: $Domain" "White"
Write-ColorOutput "" "White"

if ($FullDeploy) {
    # Setup SSH key authentication first
    if (-not (Setup-SSHKey)) {
        Write-ColorOutput "SSH key setup failed. Cannot proceed with deployment." "Red"
        exit 1
    }
    
    # Test SSH key authentication
    if (-not (Test-SSHKeyAuth)) {
        Write-ColorOutput "SSH key authentication test failed. Cannot proceed with deployment." "Red"
        exit 1
    }
    
    # Proceed with deployment
    Deploy-NexusCOS
} else {
    Write-ColorOutput "Use -FullDeploy parameter to start deployment" "Yellow"
}

Write-ColorOutput "" "White"
Write-ColorOutput "Deployment script completed." "Green"