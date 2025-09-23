# TRAE SOLO 🚀 NEXUS COS Deployment Wrapper for Windows
# PowerShell script to execute full automated deployment

param(
    [switch]$FullDeploy,
    [switch]$HealthCheck,
    [switch]$ShowStatus
)

# Configuration
$VPS_HOST = "74.208.155.161"
$VPS_USER = "root"
$VPS_AUTH = "I29FgNi4"
$DOMAIN = "nexuscos.online"
$SCRIPT_DIR = $PSScriptRoot
$DEPLOY_SCRIPT = "$SCRIPT_DIR\trae-solo-full-deploy.sh"
$LOG_FILE = "$SCRIPT_DIR\nexus-cos-deploy.log"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $LOG_FILE -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
}

function Test-Prerequisites {
    Write-ColorOutput "🔍 Checking prerequisites..." "Yellow"
    
    # Check if WSL is available
    try {
        $wslCheck = wsl --list --quiet 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ WSL not found. Installing WSL..." "Red"
            wsl --install
            Write-ColorOutput "⚠️ WSL installed. Please restart your computer and run this script again." "Yellow"
            exit 1
        }
        Write-ColorOutput "✅ WSL is available" "Green"
    }
    catch {
        Write-ColorOutput "❌ Error checking WSL: $($_.Exception.Message)" "Red"
        exit 1
    }
    
    # Check if deployment script exists
    if (-not (Test-Path $DEPLOY_SCRIPT)) {
        Write-ColorOutput "❌ Deployment script not found: $DEPLOY_SCRIPT" "Red"
        exit 1
    }
    Write-ColorOutput "✅ Deployment script found" "Green"
    
    # Test VPS connectivity
    Write-ColorOutput "🔗 Testing VPS connectivity..." "Yellow"
    try {
        $testConnection = Test-NetConnection -ComputerName $VPS_HOST -Port 22 -WarningAction SilentlyContinue
        if ($testConnection.TcpTestSucceeded) {
            Write-ColorOutput "✅ VPS is reachable on port 22" "Green"
        } else {
            Write-ColorOutput "❌ Cannot reach VPS on port 22" "Red"
            exit 1
        }
    }
    catch {
        Write-ColorOutput "❌ Error testing VPS connectivity: $($_.Exception.Message)" "Red"
        exit 1
    }
}

function Install-WSLDependencies {
    Write-ColorOutput "📦 Installing WSL dependencies..." "Yellow"
    
    # Install required packages in WSL
    $wslCommands = @(
        "sudo apt update",
        "sudo apt install -y sshpass curl wget",
        "chmod +x /mnt/c/Users/wecon/Downloads/nexus-cos-main/trae-solo-full-deploy.sh"
    )
    
    foreach ($cmd in $wslCommands) {
        Write-ColorOutput "Executing: $cmd" "Cyan"
        wsl -- bash -c $cmd
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ Failed to execute: $cmd" "Red"
            exit 1
        }
    }
    
    Write-ColorOutput "✅ WSL dependencies installed" "Green"
}

function Start-FullDeployment {
    Write-ColorOutput "🚀 Starting TRAE SOLO Full NEXUS COS Deployment" "Magenta"
    Write-ColorOutput "Target VPS: $VPS_HOST" "Cyan"
    Write-ColorOutput "Domain: $DOMAIN" "Cyan"
    Write-ColorOutput "" "White"
    
    # Convert Windows path to WSL path
    $wslScriptPath = $DEPLOY_SCRIPT -replace 'C:\\', '/mnt/c/' -replace '\\', '/'
    
    Write-ColorOutput "📝 Deployment log will be saved to: $LOG_FILE" "Yellow"
    Write-ColorOutput "" "White"
    
    # Execute deployment script in WSL
    Write-ColorOutput "🔄 Executing deployment script..." "Yellow"
    try {
        wsl -- bash -c "cd /mnt/c/Users/wecon/Downloads/nexus-cos-main && ./trae-solo-full-deploy.sh"
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "" "White"
            Write-ColorOutput "🎉 DEPLOYMENT SUCCESSFUL! 🎉" "Green"
            Write-ColorOutput "" "White"
            Write-ColorOutput "🌐 Your NEXUS COS is now live at: https://$DOMAIN" "Green"
            Write-ColorOutput "📊 Node.js Health: https://$DOMAIN/health" "Green"
            Write-ColorOutput "🐍 Python Health: https://$DOMAIN/py/health" "Green"
            Write-ColorOutput "📱 Mobile Downloads: https://$DOMAIN/mobile/" "Green"
            Write-ColorOutput "" "White"
            
            # Copy deployment summary if it exists
            if (Test-Path "$SCRIPT_DIR\nexus-cos-deployment-summary.txt") {
                Write-ColorOutput "📋 Deployment summary:" "Yellow"
                Get-Content "$SCRIPT_DIR\nexus-cos-deployment-summary.txt" | ForEach-Object {
                    Write-ColorOutput $_ "White"
                }
            }
        } else {
            Write-ColorOutput "❌ DEPLOYMENT FAILED!" "Red"
            Write-ColorOutput "Check the log file for details: $LOG_FILE" "Yellow"
            exit 1
        }
    }
    catch {
        Write-ColorOutput "❌ Error during deployment: $($_.Exception.Message)" "Red"
        exit 1
    }
}

function Test-HealthEndpoints {
    Write-ColorOutput "🏥 Testing health endpoints..." "Yellow"
    
    $endpoints = @(
        @{Name="Frontend"; Url="https://$DOMAIN"},
        @{Name="Node.js Health"; Url="https://$DOMAIN/health"},
        @{Name="Python Health"; Url="https://$DOMAIN/py/health"}
    )
    
    foreach ($endpoint in $endpoints) {
        try {
            Write-ColorOutput "Testing $($endpoint.Name): $($endpoint.Url)" "Cyan"
            $response = Invoke-WebRequest -Uri $endpoint.Url -UseBasicParsing -TimeoutSec 10
            
            if ($response.StatusCode -eq 200) {
                Write-ColorOutput "✅ $($endpoint.Name) is healthy" "Green"
            } else {
                Write-ColorOutput "⚠️ $($endpoint.Name) returned status: $($response.StatusCode)" "Yellow"
            }
        }
        catch {
            Write-ColorOutput "❌ $($endpoint.Name) is not accessible: $($_.Exception.Message)" "Red"
        }
    }
}

function Show-DeploymentStatus {
    Write-ColorOutput "📊 NEXUS COS Deployment Status" "Magenta"
    Write-ColorOutput "" "White"
    
    # Test VPS connectivity
    Write-ColorOutput "🔗 VPS Connectivity:" "Yellow"
    $testConnection = Test-NetConnection -ComputerName $VPS_HOST -Port 22 -WarningAction SilentlyContinue
    if ($testConnection.TcpTestSucceeded) {
        Write-ColorOutput "✅ VPS is reachable" "Green"
    } else {
        Write-ColorOutput "❌ VPS is not reachable" "Red"
    }
    
    Write-ColorOutput "" "White"
    
    # Test health endpoints
    Test-HealthEndpoints
    
    Write-ColorOutput "" "White"
    Write-ColorOutput "🌐 Access URLs:" "Yellow"
    Write-ColorOutput "Frontend: https://$DOMAIN" "Cyan"
    Write-ColorOutput "Node.js API: https://$DOMAIN/api/" "Cyan"
    Write-ColorOutput "Python API: https://$DOMAIN/py/" "Cyan"
    Write-ColorOutput "Mobile Downloads: https://$DOMAIN/mobile/" "Cyan"
}

# Main execution
Clear-Host
Write-ColorOutput "" "White"
Write-ColorOutput "🚀 TRAE SOLO - NEXUS COS Deployment Manager" "Magenta"
Write-ColorOutput "============================================" "Magenta"
Write-ColorOutput "" "White"

# Initialize log file
"TRAE SOLO - NEXUS COS Deployment Log" | Out-File -FilePath $LOG_FILE -Encoding UTF8
"Started: $(Get-Date)" | Add-Content -Path $LOG_FILE
"VPS: $VPS_HOST" | Add-Content -Path $LOG_FILE
"Domain: $DOMAIN" | Add-Content -Path $LOG_FILE
"========================================" | Add-Content -Path $LOG_FILE

if ($FullDeploy) {
    Test-Prerequisites
    Install-WSLDependencies
    Start-FullDeployment
}
elseif ($HealthCheck) {
    Test-HealthEndpoints
}
elseif ($ShowStatus) {
    Show-DeploymentStatus
}
else {
    Write-ColorOutput "Usage:" "Yellow"
    Write-ColorOutput "  .\deploy-nexus-cos.ps1 -FullDeploy    # Run complete deployment" "Cyan"
    Write-ColorOutput "  .\deploy-nexus-cos.ps1 -HealthCheck   # Test health endpoints" "Cyan"
    Write-ColorOutput "  .\deploy-nexus-cos.ps1 -ShowStatus    # Show deployment status" "Cyan"
    Write-ColorOutput "" "White"
    Write-ColorOutput "Examples:" "Yellow"
    Write-ColorOutput "  .\deploy-nexus-cos.ps1 -FullDeploy" "Green"
    Write-ColorOutput "  .\deploy-nexus-cos.ps1 -HealthCheck" "Green"
    Write-ColorOutput "" "White"
}

Write-ColorOutput "" "White"
Write-ColorOutput "📝 Log file: $LOG_FILE" "Yellow"
Write-ColorOutput "" "White"