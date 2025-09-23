# PUABO STUDIO.AI + Nexus COS Deployment Script
# PowerShell version for Windows

param(
    [string]$VpsHost = "nexuscos.online",
    [string]$VpsUser = "root",
    [string]$Domain = "nexuscos.online",
    [string]$Email = "puaboverse@gmail.com"
)

$ErrorActionPreference = "Stop"

# Project variables
$APP_NAME = "PUABO-STUDIO-AI"

# Logging functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

try {
    Write-Info "Starting PUABO STUDIO.AI + Nexus COS deployment..."
    Write-Info "Project: $APP_NAME"
    Write-Info "Domain: $Domain"
    Write-Info "VPS: $VpsHost"
    
    # Step 1: Verify project structure
    Write-Info "Verifying project structure..."
    
    if (-not (Test-Path "nexus-cos-main")) {
        Write-Error "Project directory 'nexus-cos-main' not found"
        exit 1
    }
    
    Write-Success "Project structure verified"
    
    # Step 2: Install main dependencies
    Write-Info "Installing main project dependencies..."
    
    if (Test-Path "package.json") {
        npm install
        Write-Success "Main dependencies installed"
    }
    
    # Step 3: Build Da Boom Boom Room frontend
    if (Test-Path "da-boom-boom-room\frontend") {
        Write-Info "Building Da Boom Boom Room frontend..."
        Push-Location "da-boom-boom-room\frontend"
        npm install
        npm run build
        Pop-Location
        Write-Success "Da Boom Boom Room frontend built"
    }
    
    # Step 4: Build Nexus COS frontend
    if (Test-Path "nexus-cos-main\frontend") {
        Write-Info "Building Nexus COS frontend..."
        Push-Location "nexus-cos-main\frontend"
        npm install
        npm run build
        Pop-Location
        Write-Success "Nexus COS frontend built"
    }
    
    # Step 5: Install backend dependencies
    if (Test-Path "nexus-cos-main\backend") {
        Write-Info "Installing backend dependencies..."
        Push-Location "nexus-cos-main\backend"
        npm install
        Pop-Location
        Write-Success "Backend dependencies installed"
    }
    
    # Step 6: Create environment configuration
    Write-Info "Creating environment configuration..."
    
    $envContent = @"
NODE_ENV=production
DOMAIN=$Domain
EMAIL=$Email
VPS_HOST=$VpsHost
VPS_USER=$VpsUser
DATABASE_URL=postgresql://nexus_user:nexus_secure_password_2024@localhost:5432/nexus_cos
JWT_SECRET=whitefamilylegacy600
SESSION_SECRET=nexus_session_secret_key_2024
FRONTEND_PORT=80
BACKEND_NODE_PORT=3000
BACKEND_PYTHON_PORT=3001
"@
    
    Set-Content -Path ".env" -Value $envContent
    Write-Success "Environment configuration created"
    
    # Step 7: Create deployment package
    Write-Info "Creating deployment package..."
    
    if (-not (Test-Path "artifacts")) {
        New-Item -ItemType Directory -Path "artifacts" | Out-Null
    }
    
    $deploymentFiles = @()
    
    if (Test-Path "da-boom-boom-room\frontend\.next") {
        $deploymentFiles += "da-boom-boom-room\frontend\.next"
    }
    if (Test-Path "nexus-cos-main\frontend\dist") {
        $deploymentFiles += "nexus-cos-main\frontend\dist"
    }
    if (Test-Path "nexus-cos-main\backend") {
        $deploymentFiles += "nexus-cos-main\backend"
    }
    if (Test-Path "scripts") {
        $deploymentFiles += "scripts"
    }
    if (Test-Path ".env") {
        $deploymentFiles += ".env"
    }
    
    $packagePath = "artifacts\$APP_NAME-deployment.zip"
    
    if ($deploymentFiles.Count -gt 0) {
        Compress-Archive -Path $deploymentFiles -DestinationPath $packagePath -Force
        Write-Success "Deployment package created: $packagePath"
    } else {
        Write-Warning "No deployment files found to package"
    }
    
    # Step 8: Display deployment summary
    Write-Success "PUABO STUDIO.AI + Nexus COS deployment preparation completed!"
    
    Write-Info "Deployment Summary:"
    Write-Info "  Project: $APP_NAME"
    Write-Info "  Domain: $Domain"
    Write-Info "  VPS: $VpsHost"
    Write-Info "  Package: $packagePath"
    
    Write-Info "Access Points (after deployment):"
    Write-Info "  Main App: https://$Domain"
    Write-Info "  Da Boom Boom Room: https://$Domain/da-boom-boom-room"
    Write-Info "  API Health: https://$Domain/health"
    
    Write-Info "Next Steps:"
    Write-Info "  1. Upload deployment package to VPS"
    Write-Info "  2. Run production auto-setup script on VPS"
    Write-Info "  3. Configure DNS and SSL"
    Write-Info "  4. Test all features"
    
    Write-Success "PUABO STUDIO.AI is ready for production deployment!"
    
} catch {
    Write-Error "Deployment failed: $($_.Exception.Message)"
    exit 1
}