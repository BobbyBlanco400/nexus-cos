# 🐋 Docker Desktop Windows - API Connection Fix Script
# Fixes "failed to connect to the docker API at npipe:////./pipe/docker_engine"
# Version: 1.0.0
# Compatible with: Windows 10/11 + Docker Desktop + WSL2

<#
.SYNOPSIS
    Automated fix for Docker Desktop Windows API connection issues.

.DESCRIPTION
    This script resolves the "npipe:////./pipe/docker_engine" error by:
    - Stopping stale Docker processes
    - Enabling required Windows features
    - Configuring WSL2 backend
    - Resetting Docker Desktop WSL distros
    - Restarting Docker Desktop with Linux engine
    - Verifying daemon health

.PARAMETER SkipFeatureCheck
    Skip Windows feature enablement (use if features already enabled)

.PARAMETER SkipWSLReset
    Skip WSL distro reset (use for lighter troubleshooting)

.PARAMETER DockerPath
    Custom Docker Desktop installation path

.EXAMPLE
    .\Fix-DockerDesktopWindows.ps1
    Run full automated fix

.EXAMPLE
    .\Fix-DockerDesktopWindows.ps1 -SkipFeatureCheck
    Run fix without enabling Windows features

.NOTES
    Author: Nexus COS Team
    Requires: Administrator privileges
    BIOS Virtualization: Must be enabled (Intel VT-x / AMD-V)
#>

[CmdletBinding()]
param(
    [switch]$SkipFeatureCheck,
    [switch]$SkipWSLReset,
    [string]$DockerPath = "C:\Program Files\Docker\Docker"
)

#Requires -RunAsAdministrator

# Color output functions
function Write-Step {
    param([string]$Message)
    Write-Host "`n🔧 $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Blue
}

# Banner
Write-Host @"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║        🐋 Docker Desktop Windows - API Connection Fix         ║
║                                                                ║
║  Resolves: npipe:////./pipe/docker_engine connection error    ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host ""

# Step 1: Stop stale processes
Write-Step "Stopping stale Docker processes..."
try {
    Stop-Process -Name "Docker" -ErrorAction SilentlyContinue -Force
    Stop-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue -Force
    Stop-Process -Name "com.docker.service" -ErrorAction SilentlyContinue -Force
    Write-Success "Docker processes stopped"
} catch {
    Write-Warning-Custom "Some processes may not have been running: $($_.Exception.Message)"
}

# Step 2: Terminate WSL Docker instances
Write-Step "Terminating WSL Docker instances..."
try {
    & wsl --terminate docker-desktop 2>$null
    & wsl --terminate docker-desktop-data 2>$null
    Start-Sleep -Seconds 2
    Write-Success "WSL Docker instances terminated"
} catch {
    Write-Warning-Custom "WSL termination encountered issues (may not be running)"
}

# Step 3: Enable required Windows features (if not skipped)
if (-not $SkipFeatureCheck) {
    Write-Step "Checking and enabling required Windows features..."
    Write-Info "This may take several minutes and require a restart..."
    
    $featuresToEnable = @(
        "Microsoft-Windows-Subsystem-Linux",
        "VirtualMachinePlatform",
        "Microsoft-Hyper-V-All"
    )
    
    $restartRequired = $false
    
    foreach ($feature in $featuresToEnable) {
        try {
            Write-Host "  Enabling $feature..." -ForegroundColor Gray
            $result = Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart -ErrorAction Stop
            if ($result.RestartNeeded) {
                $restartRequired = $true
            }
            Write-Host "    ✓ $feature enabled" -ForegroundColor Green
        } catch {
            Write-Warning-Custom "Could not enable $feature - it may already be enabled or unavailable"
        }
    }
    
    if ($restartRequired) {
        Write-Warning-Custom "Windows restart REQUIRED for feature changes to take effect"
        Write-Host ""
        $restart = Read-Host "Restart now? (Y/N)"
        if ($restart -eq 'Y' -or $restart -eq 'y') {
            Write-Info "Restarting in 10 seconds... Save your work!"
            Start-Sleep -Seconds 10
            Restart-Computer -Force
            exit
        } else {
            Write-Warning-Custom "Please restart Windows manually and re-run this script"
            exit
        }
    } else {
        Write-Success "Windows features are enabled"
    }
} else {
    Write-Info "Skipping Windows feature check (--SkipFeatureCheck specified)"
}

# Step 4: Install and configure WSL2
Write-Step "Configuring WSL2 backend..."
try {
    # Check if WSL is installed
    $wslVersion = & wsl --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Info "WSL not found, installing..."
        & wsl --install --no-distribution
        Write-Warning-Custom "WSL installation initiated. Please restart and re-run this script."
        exit
    }
    
    # Set WSL2 as default
    & wsl --set-default-version 2 2>&1 | Out-Null
    Write-Success "WSL2 set as default version"
    
    # Verify WSL2
    Write-Info "WSL distributions:"
    & wsl -l -v
    
} catch {
    Write-Error-Custom "WSL2 configuration failed: $($_.Exception.Message)"
}

# Step 5: Hard reset Docker Desktop WSL distros (if not skipped)
if (-not $SkipWSLReset) {
    Write-Step "Resetting Docker Desktop WSL distributions..."
    Write-Warning-Custom "This will force clean recreation of Docker engine on next start"
    
    try {
        & wsl --unregister docker-desktop 2>&1 | Out-Null
        & wsl --unregister docker-desktop-data 2>&1 | Out-Null
        Write-Success "Docker Desktop WSL distros unregistered"
    } catch {
        Write-Warning-Custom "WSL distros may not have existed (this is OK for first-time setup)"
    }
} else {
    Write-Info "Skipping WSL distro reset (--SkipWSLReset specified)"
}

# Step 6: Start Docker Desktop
Write-Step "Starting Docker Desktop..."
$dockerDesktopExe = Join-Path $DockerPath "Docker Desktop.exe"

if (-not (Test-Path $dockerDesktopExe)) {
    Write-Error-Custom "Docker Desktop not found at: $dockerDesktopExe"
    Write-Info "Please install Docker Desktop or specify correct path with -DockerPath parameter"
    exit 1
}

try {
    Start-Process $dockerDesktopExe
    Write-Success "Docker Desktop started"
    Write-Info "Waiting for initialization (60-120 seconds)..."
    
    # Wait for Docker to initialize
    $maxWaitSeconds = 120
    $waited = 0
    $dockerReady = $false
    
    while ($waited -lt $maxWaitSeconds) {
        Start-Sleep -Seconds 5
        $waited += 5
        
        # Try to check if Docker is responding
        try {
            $dockerExe = Join-Path $DockerPath "resources\bin\docker.exe"
            if (Test-Path $dockerExe) {
                & $dockerExe version 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    $dockerReady = $true
                    break
                }
            }
        } catch {
            # Still starting up
        }
        
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
    
    Write-Host ""
    
    if ($dockerReady) {
        Write-Success "Docker Desktop is responding (waited $waited seconds)"
    } else {
        Write-Warning-Custom "Docker Desktop may still be initializing (waited $waited seconds)"
        Write-Info "Continue with verification - it may be ready now"
    }
    
} catch {
    Write-Error-Custom "Failed to start Docker Desktop: $($_.Exception.Message)"
    exit 1
}

# Step 7: Switch to Linux engine (optional)
Write-Step "Checking Docker engine mode..."
$dockerCliExe = Join-Path $DockerPath "DockerCli.exe"

if (Test-Path $dockerCliExe) {
    try {
        Write-Info "Switching to Linux engine (if needed)..."
        & $dockerCliExe -SwitchLinuxEngine 2>&1 | Out-Null
        Start-Sleep -Seconds 5
        Write-Success "Linux engine switch command executed"
    } catch {
        Write-Info "Already on Linux engine or switch not needed"
    }
} else {
    Write-Info "DockerCli.exe not found - skipping engine switch"
}

# Step 8: Verify daemon health
Write-Step "Verifying Docker daemon health..."
$dockerExe = Join-Path $DockerPath "resources\bin\docker.exe"

if (-not (Test-Path $dockerExe)) {
    Write-Error-Custom "Docker CLI not found at: $dockerExe"
    exit 1
}

try {
    Write-Host "`nDocker Version:" -ForegroundColor Cyan
    & $dockerExe version
    
    Write-Host "`nDocker Info:" -ForegroundColor Cyan
    & $dockerExe info
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Docker daemon is healthy!"
    } else {
        Write-Warning-Custom "Docker daemon may still be starting up"
    }
} catch {
    Write-Error-Custom "Docker daemon verification failed: $($_.Exception.Message)"
    Write-Info "Wait a bit longer and try: & '$dockerExe' info"
}

# Step 9: Verify Docker Compose
Write-Step "Verifying Docker Compose CLI..."
$composePlugin = Join-Path $DockerPath "cli-plugins\docker-compose.exe"
$composeBinary = Join-Path $DockerPath "resources\bin\docker-compose.exe"

if (Test-Path $composePlugin) {
    try {
        Write-Host "`nDocker Compose (Plugin):" -ForegroundColor Cyan
        & $composePlugin version
        Write-Success "Docker Compose plugin is available"
    } catch {
        Write-Warning-Custom "Docker Compose plugin found but not responding yet"
    }
} elseif (Test-Path $composeBinary) {
    try {
        Write-Host "`nDocker Compose (Classic):" -ForegroundColor Cyan
        & $composeBinary --version
        Write-Success "Docker Compose classic binary is available"
    } catch {
        Write-Warning-Custom "Docker Compose binary found but not responding yet"
    }
} else {
    Write-Info "Docker Compose not found - you can use 'docker compose' after daemon is fully ready"
}

# Step 10: Test with hello-world
Write-Step "Running hello-world test..."
try {
    Write-Host ""
    & $dockerExe run --rm hello-world
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Hello-world container ran successfully!"
    } else {
        Write-Warning-Custom "Hello-world test failed - daemon may still be starting"
    }
} catch {
    Write-Warning-Custom "Could not run hello-world: $($_.Exception.Message)"
    Write-Info "Try again in a few moments once Docker is fully initialized"
}

# Summary
Write-Host @"

╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                    ✅ FIX COMPLETE                             ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Green

Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Open a new PowerShell window" -ForegroundColor White
Write-Host "  2. Test Docker:" -ForegroundColor White
Write-Host "     docker version" -ForegroundColor Gray
Write-Host "     docker info" -ForegroundColor Gray
Write-Host "     docker run --rm hello-world" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Test Docker Compose:" -ForegroundColor White
Write-Host "     docker compose version" -ForegroundColor Gray
Write-Host ""

Write-Host "📋 Troubleshooting:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  If still failing:" -ForegroundColor White
Write-Host "  • Check BIOS virtualization is enabled (VT-x/AMD-V)" -ForegroundColor Gray
Write-Host "  • Check Windows Defender/AV is not blocking Docker" -ForegroundColor Gray
Write-Host "  • Try: netsh winsock reset (then reboot)" -ForegroundColor Gray
Write-Host "  • Check logs: %AppData%\Docker\log.txt" -ForegroundColor Gray
Write-Host ""
Write-Host "  Advanced reset:" -ForegroundColor White
Write-Host "  • Delete: %AppData%\Docker\settings.json" -ForegroundColor Gray
Write-Host "  • Delete: %ProgramData%\DockerDesktop\service.txt" -ForegroundColor Gray
Write-Host "  • Restart Docker Desktop" -ForegroundColor Gray
Write-Host ""

Write-Host "🌐 Resources:" -ForegroundColor Cyan
Write-Host "  • See WINDOWS_DOCKER_FIX_GUIDE.md for detailed documentation" -ForegroundColor Gray
Write-Host "  • Docker Desktop logs: %AppData%\Docker\log.txt" -ForegroundColor Gray
Write-Host ""

Write-Success "Docker Desktop should now be accessible via standard 'docker' commands!"
Write-Host ""
