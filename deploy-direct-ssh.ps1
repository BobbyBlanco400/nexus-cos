# TRAE SOLO - Direct SSH Deployment Script for NEXUS COS
# Deploys to IONOS VPS without requiring WSL

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

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-SSHConnection {
    Write-ColorOutput "🔍 Testing SSH connection to $VpsHost..." "Yellow"
    
    # Create a simple test command
    $testCommand = "echo 'SSH connection successful'"
    
    try {
        # Use plink if available, otherwise try ssh
        if (Get-Command plink -ErrorAction SilentlyContinue) {
            $result = plink -ssh -batch -pw $VpsPassword "$VpsUser@$VpsHost" $testCommand 2>&1
        } elseif (Get-Command ssh -ErrorAction SilentlyContinue) {
            # For OpenSSH, we'll need to handle password differently
            Write-ColorOutput "⚠️  OpenSSH detected. You may need to enter password manually." "Yellow"
            $result = ssh -o "StrictHostKeyChecking=no" "$VpsUser@$VpsHost" $testCommand 2>&1
        } else {
            throw "No SSH client found. Please install PuTTY or OpenSSH."
        }
        
        if ($result -match "SSH connection successful") {
            Write-ColorOutput "✅ SSH connection successful!" "Green"
            return $true
        } else {
            Write-ColorOutput "❌ SSH connection failed: $result" "Red"
            return $false
        }
    } catch {
        Write-ColorOutput "❌ SSH connection error: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Invoke-SSHCommand {
    param(
        [string]$Command,
        [string]$Description = ""
    )
    
    if ($Description) {
        Write-ColorOutput "🔧 $Description" "Cyan"
    }
    
    Write-ColorOutput "Executing: $Command" "Gray"
    
    try {
        if (Get-Command plink -ErrorAction SilentlyContinue) {
            $result = plink -ssh -batch -pw $VpsPassword "$VpsUser@$VpsHost" $Command 2>&1
        } else {
            $result = ssh -o "StrictHostKeyChecking=no" "$VpsUser@$VpsHost" $Command 2>&1
        }
        
        Write-ColorOutput "Output: $result" "White"
        return $result
    } catch {
        Write-ColorOutput "❌ Command failed: $($_.Exception.Message)" "Red"
        return $null
    }
}

function Deploy-NexusCOS {
    Write-ColorOutput "🚀 Starting NEXUS COS deployment..." "Green"
    
    # Step 1: Clean up old installations
    Invoke-SSHCommand "rm -rf /var/www/nexus-cos /opt/nexus-cos" "Cleaning up old installations"
    Invoke-SSHCommand "systemctl stop nexus-backend-node nexus-backend-python nginx" "Stopping old services"
    
    # Step 2: Update system and install dependencies
    Invoke-SSHCommand "apt update; apt upgrade -y" "Updating system packages"
    Invoke-SSHCommand "apt install -y nginx nodejs npm python3 python3-pip git curl certbot python3-certbot-nginx" "Installing system dependencies"
    
    # Step 3: Install Node.js 18+ and PM2
    Invoke-SSHCommand "curl -fsSL https://deb.nodesource.com/setup_18.x | bash -" "Adding Node.js 18 repository"
    Invoke-SSHCommand "apt install -y nodejs" "Installing Node.js 18"
    Invoke-SSHCommand "npm install -g pm2" "Installing PM2 process manager"
    
    # Step 4: Clone repository
    Invoke-SSHCommand "cd /opt; git clone $GitRepo nexus-cos" "Cloning NEXUS COS repository"
    Invoke-SSHCommand "cd /opt/nexus-cos; git pull origin main" "Updating to latest version"
    
    # Step 5: Setup backend services
    Invoke-SSHCommand "cd /opt/nexus-cos/backend; npm install" "Installing Node.js backend dependencies"
    Invoke-SSHCommand "cd /opt/nexus-cos/backend; pip3 install -r requirements.txt" "Installing Python backend dependencies"
    
    # Step 6: Build frontend
    Invoke-SSHCommand "cd /opt/nexus-cos/da-boom-boom-room/frontend; npm install" "Installing frontend dependencies"
    Invoke-SSHCommand "cd /opt/nexus-cos/da-boom-boom-room/frontend; npm run build" "Building frontend application"
    
    # Step 7: Deploy frontend
    Invoke-SSHCommand "mkdir -p /var/www/nexus-cos" "Creating web directory"
    Invoke-SSHCommand "cp -r /opt/nexus-cos/da-boom-boom-room/frontend/dist/* /var/www/nexus-cos/" "Deploying frontend files"
    Invoke-SSHCommand "mkdir -p /var/www/nexus-cos/mobile" "Creating mobile directory"
    
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
        proxy_set_header Connection 'upgrade';
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
        proxy_set_header Connection 'upgrade';
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
    
    # Write nginx config to temporary file and copy
    $tempConfigPath = "$env:TEMP\nexus-nginx.conf"
    $nginxConfig | Out-File -FilePath $tempConfigPath -Encoding UTF8
    
    # Create the config on the server
    Invoke-SSHCommand "rm -f /etc/nginx/sites-available/nexus-cos" "Removing old config"
    
    # Upload config line by line to avoid escaping issues
    $configLines = $nginxConfig -split "`n"
    foreach ($line in $configLines) {
        $escapedLine = $line -replace '"', '\"'
        Invoke-SSHCommand "echo \"$escapedLine\" >> /etc/nginx/sites-available/nexus-cos" ""
    }
    Invoke-SSHCommand "ln -sf /etc/nginx/sites-available/nexus-cos /etc/nginx/sites-enabled/" "Enabling Nginx site"
    Invoke-SSHCommand "rm -f /etc/nginx/sites-enabled/default" "Removing default Nginx site"
    
    # Step 9: Start backend services with PM2
    Invoke-SSHCommand "cd /opt/nexus-cos/backend; pm2 start app.js --name nexus-backend-node" "Starting Node.js backend"
    Invoke-SSHCommand "cd /opt/nexus-cos/backend; pm2 start main.py --name nexus-backend-python --interpreter python3" "Starting Python backend"
    Invoke-SSHCommand "pm2 startup" "Setting up PM2 startup"
    Invoke-SSHCommand "pm2 save" "Saving PM2 configuration"
    
    # Step 10: Test Nginx configuration and restart
    Invoke-SSHCommand "nginx -t" "Testing Nginx configuration"
    Invoke-SSHCommand "systemctl restart nginx" "Restarting Nginx"
    Invoke-SSHCommand "systemctl enable nginx" "Enabling Nginx auto-start"
    
    # Step 11: Setup SSL with Certbot
    Write-ColorOutput "🔒 Setting up SSL certificates..." "Yellow"
    Invoke-SSHCommand "certbot --nginx -d nexuscos.online --non-interactive --agree-tos --email puaboverse@gmail.com" "Installing SSL certificates"
    
    # Step 12: Setup auto-renewal
    Invoke-SSHCommand "systemctl enable certbot.timer" "Enabling SSL auto-renewal"
    
    # Step 13: Final health checks
    Write-ColorOutput "🏥 Running health checks..." "Yellow"
    Start-Sleep -Seconds 10
    
    Invoke-SSHCommand 'curl -f http://localhost:3000/health || echo "Node.js health check failed"' "Testing Node.js backend"
    Invoke-SSHCommand 'curl -f http://localhost:3001/health || echo "Python health check failed"' "Testing Python backend"
    Invoke-SSHCommand 'curl -f http://nexuscos.online/health || echo "Frontend health check failed"' "Testing frontend"
    
    # Step 14: Display status
    Write-ColorOutput "📊 Deployment Status:" "Green"
    Invoke-SSHCommand "pm2 status" "PM2 process status"
    Invoke-SSHCommand "systemctl status nginx --no-pager" "Nginx status"
    Invoke-SSHCommand "certbot certificates" "SSL certificate status"
    
    Write-ColorOutput "✅ NEXUS COS deployment completed!" "Green"
    Write-ColorOutput "🌐 Website: https://nexuscos.online" "Cyan"
    Write-ColorOutput "🔧 Node.js Health: https://nexuscos.online/health" "Cyan"
    Write-ColorOutput "🐍 Python Health: https://nexuscos.online/py/health" "Cyan"
}

# Main execution
Write-ColorOutput "🚀 TRAE SOLO - NEXUS COS Deployment Manager" "Magenta"
Write-ColorOutput "=" * 50 "Magenta"
Write-ColorOutput "Target VPS: $VpsHost" "White"
Write-ColorOutput "Domain: $Domain" "White"
Write-ColorOutput "" "White"

if (-not (Test-SSHConnection)) {
    Write-ColorOutput "❌ Cannot establish SSH connection. Please check:" "Red"
    Write-ColorOutput "   - VPS IP address: $VpsHost" "Red"
    Write-ColorOutput "   - Username: $VpsUser" "Red"
    Write-ColorOutput "   - Password: [HIDDEN]" "Red"
    Write-ColorOutput "   - SSH client (PuTTY plink or OpenSSH)" "Red"
    exit 1
}

if ($FullDeploy) {
    Deploy-NexusCOS
} else {
    Write-ColorOutput "Use -FullDeploy parameter to start deployment" "Yellow"
}

Write-ColorOutput "" "White"
Write-ColorOutput "Deployment script completed." "Green"