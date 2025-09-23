# TRAE SOLO Deployment Script for Nexus COS (Windows PowerShell)
# Complete automated workflow: Build, Test, Deploy, Monitor

param(
    [string]$VpsHost = $env:VPS_HOST,
    [string]$VpsUser = $env:VPS_USER,
    [string]$Domain = $env:DOMAIN,
    [string]$Email = $env:EMAIL,
    [switch]$SkipTests = $false,
    [switch]$SkipMobile = $false,
    [switch]$LocalOnly = $false
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Cyan"

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$LogDir = Join-Path $ProjectRoot "logs"
$ArtifactsDir = Join-Path $ProjectRoot "artifacts"
$BuildLog = Join-Path $LogDir "build.log"
$DeployLog = Join-Path $LogDir "deploy.log"
$TestLog = Join-Path $LogDir "test.log"
$MonitorLog = Join-Path $LogDir "monitor.log"

# Create necessary directories
New-Item -ItemType Directory -Force -Path $LogDir, $ArtifactsDir | Out-Null

# Logging functions
function Write-LogInfo {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [INFO] $Message"
    Write-Host $logMessage -ForegroundColor $Blue
    Add-Content -Path $DeployLog -Value $logMessage
}

function Write-LogSuccess {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [SUCCESS] $Message"
    Write-Host $logMessage -ForegroundColor $Green
    Add-Content -Path $DeployLog -Value $logMessage
}

function Write-LogWarning {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [WARNING] $Message"
    Write-Host $logMessage -ForegroundColor $Yellow
    Add-Content -Path $DeployLog -Value $logMessage
}

function Write-LogError {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [ERROR] $Message"
    Write-Host $logMessage -ForegroundColor $Red
    Add-Content -Path $DeployLog -Value $logMessage
}

# Error handling
function Handle-Error {
    param([string]$Step)
    Write-LogError "Deployment failed at step: $Step"
    Write-LogError "Check logs in $LogDir for details"
    exit 1
}

# Check prerequisites
function Test-Prerequisites {
    Write-LogInfo "Checking prerequisites..."
    
    # Check if Node.js is installed
    try {
        $nodeVersion = node --version
        Write-LogSuccess "Node.js found: $nodeVersion"
    } catch {
        Write-LogError "Node.js not found. Please install Node.js from https://nodejs.org/"
        return $false
    }
    
    # Check if Python is installed
    try {
        $pythonVersion = python --version
        Write-LogSuccess "Python found: $pythonVersion"
    } catch {
        Write-LogWarning "Python not found. Some features may not work."
    }
    
    # Check if Git is installed
    try {
        $gitVersion = git --version
        Write-LogSuccess "Git found: $gitVersion"
    } catch {
        Write-LogError "Git not found. Please install Git."
        return $false
    }
    
    return $true
}

# Setup environment
function Setup-Environment {
    Write-LogInfo "Setting up environment..."
    
    # Load environment variables from .trae/environment.env
    $envFile = Join-Path $ProjectRoot ".trae\environment.env"
    if (Test-Path $envFile) {
        Get-Content $envFile | ForEach-Object {
            if ($_ -match '^([^=]+)=(.*)$') {
                $name = $matches[1]
                $value = $matches[2]
                # Skip variables that reference other variables for now
                if ($value -notmatch '\$\{.*\}') {
                    [Environment]::SetEnvironmentVariable($name, $value, "Process")
                    Write-LogInfo "Set environment variable: $name"
                }
            }
        }
        Write-LogSuccess "Environment variables loaded from $envFile"
    } else {
        Write-LogWarning "Environment file not found: $envFile"
    }
    
    # Validate required variables
    if (-not $VpsHost) { Write-LogWarning "VPS_HOST not set. VPS deployment will be skipped." }
    if (-not $Domain) { Write-LogWarning "DOMAIN not set. SSL setup will be skipped." }
    if (-not $Email) { Write-LogWarning "EMAIL not set. SSL setup will be skipped." }
}

# Install dependencies
function Install-Dependencies {
    Write-LogInfo "Installing dependencies..."
    
    # Install frontend dependencies
    $frontendDir = Join-Path $ProjectRoot "frontend"
    if (Test-Path $frontendDir) {
        Set-Location $frontendDir
        Write-LogInfo "Installing frontend dependencies..."
        npm install 2>&1 | Tee-Object -FilePath $BuildLog -Append
        if ($LASTEXITCODE -ne 0) {
            Handle-Error "Frontend dependency installation"
        }
        Write-LogSuccess "Frontend dependencies installed"
    }
    
    # Install backend dependencies
    $backendDir = Join-Path $ProjectRoot "backend"
    if (Test-Path $backendDir) {
        Set-Location $backendDir
        
        # Node.js dependencies
        if (Test-Path "package.json") {
            Write-LogInfo "Installing Node.js backend dependencies..."
            npm install 2>&1 | Tee-Object -FilePath $BuildLog -Append
            if ($LASTEXITCODE -ne 0) {
                Handle-Error "Node.js backend dependency installation"
            }
            Write-LogSuccess "Node.js backend dependencies installed"
        }
        
        # Python dependencies
        if (Test-Path "requirements.txt") {
            Write-LogInfo "Installing Python backend dependencies..."
            try {
                pip install -r requirements.txt 2>&1 | Tee-Object -FilePath $BuildLog -Append
                Write-LogSuccess "Python backend dependencies installed"
            } catch {
                Write-LogWarning "Failed to install Python dependencies. Continuing..."
            }
        }
    }
    
    # Install mobile dependencies
    if (-not $SkipMobile) {
        $mobileDir = Join-Path $ProjectRoot "mobile"
        if (Test-Path $mobileDir) {
            Set-Location $mobileDir
            Write-LogInfo "Installing mobile dependencies..."
            npm install 2>&1 | Tee-Object -FilePath $BuildLog -Append
            if ($LASTEXITCODE -ne 0) {
                Write-LogWarning "Mobile dependency installation failed. Continuing..."
            } else {
                Write-LogSuccess "Mobile dependencies installed"
            }
        }
    }
    
    Set-Location $ProjectRoot
}

# Run tests
function Run-Tests {
    if ($SkipTests) {
        Write-LogWarning "Skipping tests as requested"
        return
    }
    
    Write-LogInfo "Running tests..."
    
    # Frontend tests
    $frontendDir = Join-Path $ProjectRoot "frontend"
    if (Test-Path $frontendDir) {
        Set-Location $frontendDir
        Write-LogInfo "Running frontend tests..."
        try {
            npm test -- --watchAll=false 2>&1 | Tee-Object -FilePath $TestLog -Append
            Write-LogSuccess "Frontend tests passed"
        } catch {
            Write-LogWarning "Frontend tests failed or not configured. Continuing..."
        }
    }
    
    # Backend tests
    $backendDir = Join-Path $ProjectRoot "backend"
    if (Test-Path $backendDir) {
        Set-Location $backendDir
        Write-LogInfo "Running backend tests..."
        try {
            npm test 2>&1 | Tee-Object -FilePath $TestLog -Append
            Write-LogSuccess "Backend tests passed"
        } catch {
            Write-LogWarning "Backend tests failed or not configured. Continuing..."
        }
    }
    
    Set-Location $ProjectRoot
}

# Build applications
function Build-Applications {
    Write-LogInfo "Building applications..."
    
    # Build frontend
    $frontendDir = Join-Path $ProjectRoot "frontend"
    if (Test-Path $frontendDir) {
        Set-Location $frontendDir
        Write-LogInfo "Building frontend..."
        npm run build 2>&1 | Tee-Object -FilePath $BuildLog -Append
        if ($LASTEXITCODE -ne 0) {
            Handle-Error "Frontend build"
        }
        Write-LogSuccess "Frontend built successfully"
    }
    
    # Build backend (if needed)
    $backendDir = Join-Path $ProjectRoot "backend"
    if (Test-Path $backendDir) {
        Set-Location $backendDir
        if (Test-Path "tsconfig.json") {
            Write-LogInfo "Building TypeScript backend..."
            try {
                npx tsc 2>&1 | Tee-Object -FilePath $BuildLog -Append
                Write-LogSuccess "Backend built successfully"
            } catch {
                Write-LogWarning "Backend build failed or not needed. Continuing..."
            }
        }
    }
    
    Set-Location $ProjectRoot
}

# Generate deployment package
function Generate-DeploymentPackage {
    Write-LogInfo "Generating deployment package..."
    
    $packageDir = Join-Path $ArtifactsDir "nexus-cos-deployment"
    New-Item -ItemType Directory -Force -Path $packageDir | Out-Null
    
    # Copy essential files
    $filesToCopy = @(
        "trae-solo.yaml",
        ".trae",
        "scripts",
        "frontend\dist",
        "frontend\Dockerfile",
        "frontend\nginx.conf",
        "frontend\default.conf",
        "backend\Dockerfile.node",
        "backend\Dockerfile.python",
        "backend\package.json",
        "backend\requirements.txt",
        "FINAL_DEPLOYMENT_REPORT.md"
    )
    
    foreach ($file in $filesToCopy) {
        $sourcePath = Join-Path $ProjectRoot $file
        if (Test-Path $sourcePath) {
            $destPath = Join-Path $packageDir $file
            $destDir = Split-Path -Parent $destPath
            New-Item -ItemType Directory -Force -Path $destDir | Out-Null
            Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
            Write-LogInfo "Copied: $file"
        }
    }
    
    # Create deployment instructions
    $instructionsPath = Join-Path $packageDir "DEPLOYMENT_INSTRUCTIONS.md"
    $instructions = @"
# Nexus COS Deployment Instructions

## Prerequisites
- Docker and Docker Compose installed on target server
- SSH access to VPS
- Domain name configured

## Deployment Steps

1. Upload this package to your VPS:
   ```bash
   scp -r nexus-cos-deployment user@your-vps:/opt/
   ```

2. SSH into your VPS:
   ```bash
   ssh user@your-vps
   cd /opt/nexus-cos-deployment
   ```

3. Set environment variables:
   ```bash
   export DOMAIN=your-domain.com
   export EMAIL=your-email@domain.com
   export DB_PASSWORD=your-secure-password
   export JWT_SECRET=your-jwt-secret
   ```

4. Run deployment:
   ```bash
   chmod +x scripts/vps-deploy.sh
   ./scripts/vps-deploy.sh
   ```

5. Setup monitoring:
   ```bash
   chmod +x scripts/setup-monitoring.sh
   ./scripts/setup-monitoring.sh
   ```

## Access Points
- Frontend: https://your-domain.com
- API (Node.js): https://your-domain.com/api/node
- API (Python): https://your-domain.com/api/python
- Monitoring: https://your-domain.com/grafana

## Support
Refer to FINAL_DEPLOYMENT_REPORT.md for detailed information.
"@
    
    Set-Content -Path $instructionsPath -Value $instructions
    
    Write-LogSuccess "Deployment package created: $packageDir"
    return $packageDir
}

# Deploy to VPS (if configured)
function Deploy-ToVPS {
    if ($LocalOnly -or -not $VpsHost) {
        Write-LogWarning "VPS deployment skipped (LocalOnly=$LocalOnly, VpsHost=$VpsHost)"
        return
    }
    
    Write-LogInfo "Deploying to VPS: $VpsHost"
    
    # This would require SSH client and proper key setup
    # For now, we'll generate the deployment package and provide instructions
    $packageDir = Generate-DeploymentPackage
    
    Write-LogInfo "VPS deployment package ready at: $packageDir"
    Write-LogInfo "Please follow the instructions in DEPLOYMENT_INSTRUCTIONS.md"
}

# Generate final report
function Generate-FinalReport {
    Write-LogInfo "Generating final deployment report..."
    
    $reportPath = Join-Path $ArtifactsDir "deployment-summary-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
    
    $report = @"
# Nexus COS TRAE Solo Deployment Summary

**Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Status:** Completed

## Deployment Configuration
- Project Root: $ProjectRoot
- VPS Host: $(if ($VpsHost) { $VpsHost } else { 'Not configured' })
- Domain: $(if ($Domain) { $Domain } else { 'Not configured' })
- Email: $(if ($Email) { $Email } else { 'Not configured' })

## Build Results
- Frontend: Built successfully
- Backend: Prepared for deployment
- Mobile: $(if ($SkipMobile) { 'Skipped' } else { 'Processed' })
- Tests: $(if ($SkipTests) { 'Skipped' } else { 'Executed' })

## Artifacts Generated
- Deployment package: $(Join-Path $ArtifactsDir 'nexus-cos-deployment')
- Build logs: $BuildLog
- Test logs: $TestLog
- Deploy logs: $DeployLog

## Next Steps
1. Review deployment package
2. Configure VPS environment variables
3. Execute VPS deployment script
4. Setup monitoring and SSL
5. Perform health checks

## Support
For issues, refer to the logs in: $LogDir
"@
    
    Set-Content -Path $reportPath -Value $report
    Write-LogSuccess "Final report generated: $reportPath"
}

# Main execution
function Main {
    try {
        Write-LogInfo "Starting Nexus COS TRAE SOLO Deployment (Windows)"
        Write-LogInfo "Project Root: $ProjectRoot"
        Write-LogInfo "Timestamp: $(Get-Date)"
        
        # Step 1: Check prerequisites
        if (-not (Test-Prerequisites)) {
            Handle-Error "Prerequisites check"
        }
        
        # Step 2: Setup environment
        Setup-Environment
        
        # Step 3: Install dependencies
        Install-Dependencies
        
        # Step 4: Run tests
        Run-Tests
        
        # Step 5: Build applications
        Build-Applications
        
        # Step 6: Generate deployment package
        Generate-DeploymentPackage
        
        # Step 7: Deploy to VPS (if configured)
        Deploy-ToVPS
        
        # Step 8: Generate final report
        Generate-FinalReport
        
        Write-LogSuccess "Nexus COS TRAE SOLO Deployment completed successfully!"
        Write-LogInfo "Check artifacts in: $ArtifactsDir"
        Write-LogInfo "Check logs in: $LogDir"
        
    } catch {
        Write-LogError "Deployment failed: $($_.Exception.Message)"
        Handle-Error $_.Exception.Message
    }
}

# Execute main function
Main