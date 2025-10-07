# ==============================================================================
# Nexus COS - PF VPS Deployment Script (PowerShell)
# ==============================================================================
# Purpose: Deploy Nexus COS to production VPS from Windows using OpenSSH/PuTTY
# Target VPS: 74.208.155.161 (nexuscos.online)
# Requirements: OpenSSH Client or PuTTY plink.exe
# ==============================================================================

param(
    [string]$VpsIp = "74.208.155.161",
    [string]$Domain = "nexuscos.online",
    [string]$SshUser = "root",
    [string]$KeyFile = "",
    [string]$RepoUrl = "https://github.com/BobbyBlanco400/nexus-cos.git",
    [switch]$ValidateOnly,
    [switch]$UsePlink
)

# Color output functions
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Header {
    Write-Host ""
    Write-ColorOutput "═══════════════════════════════════════════════════════════════" "Cyan"
    Write-ColorOutput "  NEXUS COS - PF VPS DEPLOYMENT (POWERSHELL)" "Cyan"
    Write-ColorOutput "═══════════════════════════════════════════════════════════════" "Cyan"
    Write-Host ""
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-ColorOutput "═══════════════════════════════════════════════════════════════" "Blue"
    Write-ColorOutput "  $Title" "Blue"
    Write-ColorOutput "═══════════════════════════════════════════════════════════════" "Blue"
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✓ $Message" "Green"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "✗ $Message" "Red"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠ $Message" "Yellow"
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "ℹ $Message" "Cyan"
}

# ==============================================================================
# Pre-deployment Checks
# ==============================================================================

function Test-Prerequisites {
    Write-Section "1. CHECKING PREREQUISITES"
    
    $allGood = $true
    
    # Check for SSH client
    if ($UsePlink) {
        Write-Info "Checking for PuTTY plink..."
        $plinkPath = Get-Command plink.exe -ErrorAction SilentlyContinue
        if ($plinkPath) {
            Write-Success "PuTTY plink found: $($plinkPath.Source)"
        } else {
            Write-Error "PuTTY plink not found. Install PuTTY or use -UsePlink:`$false for OpenSSH"
            $allGood = $false
        }
    } else {
        Write-Info "Checking for OpenSSH client..."
        $sshPath = Get-Command ssh.exe -ErrorAction SilentlyContinue
        if ($sshPath) {
            Write-Success "OpenSSH found: $($sshPath.Source)"
        } else {
            Write-Error "OpenSSH not found. Install OpenSSH or use -UsePlink for PuTTY"
            $allGood = $false
        }
    }
    
    # Check for key file
    if ($KeyFile -and (Test-Path $KeyFile)) {
        Write-Success "SSH key file found: $KeyFile"
    } elseif ($KeyFile) {
        Write-Error "SSH key file not found: $KeyFile"
        $allGood = $false
    } else {
        Write-Warning "No SSH key specified. Will attempt password authentication."
    }
    
    # Check VPS connectivity
    Write-Info "Testing VPS connectivity..."
    if (Test-Connection -ComputerName $VpsIp -Count 2 -Quiet) {
        Write-Success "VPS is reachable: $VpsIp"
    } else {
        Write-Error "Cannot reach VPS: $VpsIp"
        $allGood = $false
    }
    
    return $allGood
}

# ==============================================================================
# SSH Command Execution
# ==============================================================================

function Invoke-SshCommand {
    param(
        [string]$Command,
        [string]$Description = "Executing command"
    )
    
    Write-Info $Description
    
    $sshArgs = @()
    if ($KeyFile) {
        $sshArgs += @("-i", $KeyFile)
    }
    $sshArgs += @("-o", "StrictHostKeyChecking=no")
    $sshArgs += @("-o", "UserKnownHostsFile=/dev/null")
    $sshArgs += "$SshUser@$VpsIp"
    $sshArgs += $Command
    
    if ($UsePlink) {
        # Use PuTTY plink
        $plinkArgs = @("-batch")
        if ($KeyFile) {
            $plinkArgs += @("-i", $KeyFile)
        }
        $plinkArgs += "$SshUser@$VpsIp"
        $plinkArgs += $Command
        
        $output = & plink.exe $plinkArgs 2>&1
    } else {
        # Use OpenSSH
        $output = & ssh.exe $sshArgs 2>&1
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Command completed successfully"
        return @{Success = $true; Output = $output}
    } else {
        Write-Error "Command failed with exit code: $LASTEXITCODE"
        return @{Success = $false; Output = $output}
    }
}

# ==============================================================================
# VPS Deployment
# ==============================================================================

function Start-VpsDeployment {
    Write-Section "2. DEPLOYING TO VPS"
    
    # Download and execute deployment script
    $deployCmd = @"
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/scripts/pf-final-deploy.sh -o /tmp/pf-final-deploy.sh && \
chmod +x /tmp/pf-final-deploy.sh && \
sudo bash /tmp/pf-final-deploy.sh -r $RepoUrl -d $Domain 2>&1 | tee /tmp/nexus-deploy.log
"@
    
    Write-Info "Starting deployment on VPS..."
    Write-Info "This may take several minutes..."
    
    $result = Invoke-SshCommand -Command $deployCmd -Description "Executing pf-final-deploy.sh on VPS"
    
    if ($result.Success) {
        Write-Success "Deployment script executed"
        Write-Host ""
        Write-Info "Deployment output:"
        Write-Host $result.Output
    } else {
        Write-Error "Deployment failed"
        Write-Host $result.Output
        return $false
    }
    
    return $true
}

# ==============================================================================
# Validation
# ==============================================================================

function Test-Deployment {
    Write-Section "3. VALIDATING DEPLOYMENT"
    
    $endpoints = @(
        @{Name = "Frontend"; Url = "https://$Domain/"},
        @{Name = "Admin"; Url = "https://$Domain/admin"},
        @{Name = "API"; Url = "https://$Domain/api"},
        @{Name = "Health"; Url = "https://$Domain/health"},
        @{Name = "V-Screen"; Url = "https://$Domain/v-suite/screen"},
        @{Name = "V-Screen Alt"; Url = "https://$Domain/v-screen"},
        @{Name = "V-Hollywood"; Url = "https://$Domain/v-suite/hollywood"},
        @{Name = "V-Prompter"; Url = "https://$Domain/v-suite/prompter"},
        @{Name = "V-Caster"; Url = "https://$Domain/v-suite/caster"},
        @{Name = "V-Stage"; Url = "https://$Domain/v-suite/stage"}
    )
    
    $passCount = 0
    $failCount = 0
    
    foreach ($endpoint in $endpoints) {
        Write-Info "Testing $($endpoint.Name): $($endpoint.Url)"
        try {
            $response = Invoke-WebRequest -Uri $endpoint.Url -Method Head -TimeoutSec 10 -SkipCertificateCheck -ErrorAction Stop
            if ($response.StatusCode -in @(200, 301, 302)) {
                Write-Success "$($endpoint.Name) is accessible (Status: $($response.StatusCode))"
                $passCount++
            } else {
                Write-Warning "$($endpoint.Name) returned status: $($response.StatusCode)"
                $failCount++
            }
        } catch {
            Write-Error "$($endpoint.Name) is not accessible: $($_.Exception.Message)"
            $failCount++
        }
    }
    
    Write-Host ""
    Write-Info "Validation Summary: $passCount passed, $failCount failed"
    
    return ($failCount -eq 0)
}

function Get-ServiceStatus {
    Write-Section "4. SERVICE STATUS"
    
    $statusCmd = "docker compose -f /opt/nexus-cos/docker-compose.pf.yml ps"
    $result = Invoke-SshCommand -Command $statusCmd -Description "Checking service status"
    
    if ($result.Success) {
        Write-Host $result.Output
    }
}

function Get-StreamingRoutes {
    Write-Section "5. STREAMING ROUTES VALIDATION"
    
    Write-Info "Testing V-Suite streaming routes..."
    
    $testCmd = @"
echo "Testing V-Suite Routes:" && \
curl -I https://$Domain/v-suite/screen 2>&1 | head -n 1 && \
curl -I https://$Domain/v-screen 2>&1 | head -n 1 && \
curl -I https://$Domain/v-suite/hollywood 2>&1 | head -n 1 && \
curl -I https://$Domain/v-suite/prompter 2>&1 | head -n 1 && \
curl -I https://$Domain/v-suite/caster 2>&1 | head -n 1 && \
curl -I https://$Domain/v-suite/stage 2>&1 | head -n 1
"@
    
    $result = Invoke-SshCommand -Command $testCmd -Description "Testing streaming routes"
    
    if ($result.Success) {
        Write-Host $result.Output
    }
}

# ==============================================================================
# Main Execution
# ==============================================================================

function Main {
    Write-Header
    
    Write-Info "Target VPS: $VpsIp ($Domain)"
    Write-Info "SSH User: $SshUser"
    Write-Info "Repository: $RepoUrl"
    if ($KeyFile) {
        Write-Info "SSH Key: $KeyFile"
    }
    Write-Host ""
    
    # Prerequisites check
    if (-not (Test-Prerequisites)) {
        Write-Error "Prerequisites check failed. Aborting."
        exit 1
    }
    
    # Validation only mode
    if ($ValidateOnly) {
        Write-Info "Running in validation-only mode"
        Test-Deployment
        Get-ServiceStatus
        Get-StreamingRoutes
        exit 0
    }
    
    # Confirm deployment
    Write-Warning "This will deploy Nexus COS to production VPS: $Domain"
    $confirm = Read-Host "Continue? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Info "Deployment cancelled"
        exit 0
    }
    
    # Execute deployment
    if (-not (Start-VpsDeployment)) {
        Write-Error "Deployment failed. Check logs above."
        exit 1
    }
    
    # Wait for services to start
    Write-Info "Waiting 30 seconds for services to stabilize..."
    Start-Sleep -Seconds 30
    
    # Validate deployment
    Test-Deployment
    Get-ServiceStatus
    Get-StreamingRoutes
    
    # Summary
    Write-Section "DEPLOYMENT COMPLETE"
    Write-Success "Nexus COS has been deployed to $Domain"
    Write-Info "Access the platform at: https://$Domain"
    Write-Info "V-Screen: https://$Domain/v-suite/screen or https://$Domain/v-screen"
    Write-Info "V-Hollywood: https://$Domain/v-suite/hollywood"
    Write-Info "Admin Panel: https://$Domain/admin"
    Write-Host ""
}

# Run main function
Main
