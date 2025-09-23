# Nexus COS VPS Deployment Script
# Improved version with better error handling and progress reporting

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Configuration
$VPS_IP = "74.208.155.161"
$VPS_USER = "root"
$DEPLOY_DIR = "/opt/nexus-cos"
$DOMAIN = "nexuscos.online"

# Helper Functions
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success($message) {
    Write-ColorOutput Green "[Success] $message"
}

function Write-Info($message) {
    Write-ColorOutput Cyan "[Info] $message"
}

function Write-Error($message) {
    Write-ColorOutput Red "[Error] $message"
    throw $message
}

function Invoke-SshCommand {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Command
    )
    
    Write-Info "Executing: $Command"
    
    try {
        $result = ssh "${VPS_USER}@${VPS_IP}" $Command
        if ($LASTEXITCODE -ne 0) {
            Write-Error "SSH command failed: $Command"
        }
        return $result
    }
    catch {
        Write-Error "SSH command failed: $_"
    }
}

function Invoke-ScpCommand {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Source,
        [Parameter(Mandatory=$true)]
        [string]$Destination
    )
    
    Write-Info "Copying $Source to $Destination"
    
    try {
        scp -r $Source "${VPS_USER}@${VPS_IP}:$Destination"
        if ($LASTEXITCODE -ne 0) {
            Write-Error "SCP command failed"
        }
    }
    catch {
        Write-Error "SCP command failed: $_"
    }
}

# Main Deployment Script
try {
    Write-Info "Starting Nexus COS VPS Deployment"
    Write-Info "Target: $VPS_IP"
    Write-Info "Domain: $DOMAIN"
    
    # Test SSH Connection
    Write-Info "Testing SSH connection..."
    Invoke-SshCommand "echo 'Connection successful'"
    Write-Success "SSH connection test passed"
    
    # Upload Modules
    Get-ChildItem -Path "modules" -Directory | ForEach-Object {
        $moduleName = $_.Name
        Write-Info "Uploading $moduleName module..."
        
        # Create module directory
        Invoke-SshCommand "mkdir -p $DEPLOY_DIR/modules/$moduleName"
        
        # Upload Dockerfile if exists
        if (Test-Path "modules\$moduleName\Dockerfile") {
            Write-Info "  Uploading Dockerfile..."
            Invoke-ScpCommand "modules\$moduleName\Dockerfile" "$DEPLOY_DIR/modules/$moduleName/"
        }
        
        # Upload package.json if exists
        if (Test-Path "modules\$moduleName\package.json") {
            Write-Info "  Uploading package.json..."
            Invoke-ScpCommand "modules\$moduleName\package.json" "$DEPLOY_DIR/modules/$moduleName/"
        }
        
        # Upload server.js if exists
        if (Test-Path "modules\$moduleName\server.js") {
            Write-Info "  Uploading server.js..."
            Invoke-ScpCommand "modules\$moduleName\server.js" "$DEPLOY_DIR/modules/$moduleName/"
        }
        
        # Upload logs directory if exists
        if (Test-Path "modules\$moduleName\logs") {
            Write-Info "  Uploading logs directory..."
            Invoke-ScpCommand "modules\$moduleName\logs" "$DEPLOY_DIR/modules/$moduleName/"
        }
        
        Write-Success "$moduleName module uploaded successfully"
    }
    
    # Upload docker-compose file
    Write-Info "Uploading docker-compose file..."
    Invoke-ScpCommand "docker-compose.prod.yml" "$DEPLOY_DIR/docker-compose.yml"
    Write-Success "Docker compose file uploaded successfully"
    
    # Upload environment file with error handling
    Write-Info "Uploading environment file..."
    if (Test-Path ".env.production.vps") {
        Invoke-ScpCommand ".env.production.vps" "$DEPLOY_DIR/.env"
        Write-Success "Environment file uploaded successfully"
    }
    elseif (Test-Path ".env.production") {
        Invoke-ScpCommand ".env.production" "$DEPLOY_DIR/.env"
        Write-Success "Environment file uploaded successfully"
    }
    elseif (Test-Path ".env") {
        Invoke-ScpCommand ".env" "$DEPLOY_DIR/.env"
        Write-Success "Environment file uploaded successfully"
    }
    else {
        Write-Error "No environment file found (.env.production.vps, .env.production, or .env)"
    }
    
    # Ensure Docker and Docker Compose are installed
    Write-Info "Verifying Docker installation..."
    Invoke-SshCommand @"
        if ! command -v docker &> /dev/null; then
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
        fi
        if ! command -v docker-compose &> /dev/null; then
            curl -L "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
        fi
"@
    Write-Success "Docker installation verified"
    
    # Build and start services
    Write-Info "Building and starting services..."
    Invoke-SshCommand @"
        cd $DEPLOY_DIR
        docker-compose down --remove-orphans
        docker-compose build --no-cache
        docker-compose up -d
"@
    Write-Success "Services started successfully"
    
    # Verify services
    Write-Info "Verifying services..."
    $services = Invoke-SshCommand "cd $DEPLOY_DIR && docker-compose ps"
    Write-Info "Active services:"
    Write-Output $services
    
    Write-Success "Deployment completed successfully!"
    Write-Info "You can access the services at: https://$DOMAIN"
}
catch {
    Write-Error "Deployment failed!`nStack trace:`n$_"
    exit 1
}