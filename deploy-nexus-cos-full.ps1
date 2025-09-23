# Nexus COS Full Deployment PowerShell Script
# This script deploys Nexus COS to a VPS server via SSH

param(
    [string]$VpsHost = "75.208.155.161",
    [string]$SshUser = "root",
    [string]$SshPassword = $env:SSH_PASSWORD,
    [switch]$SkipPrerequisites,
    [switch]$DryRun,
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Enable verbose output if requested
if ($Verbose) {
    $VerbosePreference = "Continue"
}

# Color functions
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    $colorMap = @{
        "Red" = [ConsoleColor]::Red
        "Green" = [ConsoleColor]::Green
        "Yellow" = [ConsoleColor]::Yellow
        "Blue" = [ConsoleColor]::Blue
        "Magenta" = [ConsoleColor]::Magenta
        "Cyan" = [ConsoleColor]::Cyan
        "White" = [ConsoleColor]::White
    }
    
    Write-Host $Message -ForegroundColor $colorMap[$Color]
}

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-ColorOutput "================================" "Magenta"
    Write-ColorOutput $Title "Magenta"
    Write-ColorOutput "================================" "Magenta"
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-ColorOutput "➤ $Message" "Blue"
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✅ $Message" "Green"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠️  $Message" "Yellow"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "❌ $Message" "Red"
}

# Check prerequisites
function Test-Prerequisites {
    Write-Step "Checking prerequisites..."
    
    $missingTools = @()
    
    # Check for required tools
    $requiredTools = @("ssh", "scp", "git")
    
    foreach ($tool in $requiredTools) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            $missingTools += $tool
        }
    }
    
    if ($missingTools.Count -gt 0) {
        Write-Warning "Missing required tools: $($missingTools -join ', ')"
        Write-Step "Please install the following:"
        
        foreach ($tool in $missingTools) {
            switch ($tool) {
                "ssh" { 
                    Write-Host "  - OpenSSH Client (Windows Feature or Git Bash)"
                }
                "scp" { 
                    Write-Host "  - OpenSSH Client (Windows Feature or Git Bash)"
                }
                "git" { 
                    Write-Host "  - Git for Windows (https://git-scm.com/download/win)"
                }
            }
        }
        
        if (-not $SkipPrerequisites) {
            throw "Prerequisites not met. Use -SkipPrerequisites to continue anyway."
        }
    }
    
    Write-Success "Prerequisites check completed"
}

# Test SSH connection
function Test-SshConnection {
    param(
        [string]$VpsHost,
        [string]$User,
        [string]$Password
    )
    
    Write-Step "Testing SSH connection to $VpsHost..."
    
    try {
        # Create a simple test command
        $testCommand = "echo 'SSH connection successful'"
        
        # Use plink if available (PuTTY), otherwise use ssh
        if (Get-Command plink -ErrorAction SilentlyContinue) {
            $result = & plink -ssh -l $User -pw $Password -batch $VpsHost $testCommand 2>&1
        } else {
            # For OpenSSH, we need to handle password differently
            Write-Warning "Using OpenSSH - you may need to enter the password manually"
            $result = & ssh -o "StrictHostKeyChecking=no" "$User@$VpsHost" $testCommand 2>&1
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "SSH connection successful"
            return $true
        } else {
            Write-Error "SSH connection failed: $result"
            return $false
        }
    }
    catch {
        Write-Error "SSH connection error: $($_.Exception.Message)"
        return $false
    }
}

# Upload deployment script
function Copy-DeploymentScript {
    param(
        [string]$VpsHost,
        [string]$User,
        [string]$Password
    )
    
    Write-Step "Uploading deployment script to VPS..."
    
    $localScript = ".\nexus-cos-full-deployment.sh"
    $remoteScript = "/tmp/nexus-cos-full-deployment.sh"
    
    if (-not (Test-Path $localScript)) {
        throw "Deployment script not found: $localScript"
    }
    
    try {
        # Upload script using scp
        if (Get-Command pscp -ErrorAction SilentlyContinue) {
            & pscp -pw $Password -batch $localScript "$User@${VpsHost}:$remoteScript"
        } else {
            Write-Warning "Using scp - you may need to enter the password manually"
            & scp -o "StrictHostKeyChecking=no" $localScript "$User@${VpsHost}:$remoteScript"
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Deployment script uploaded successfully"
        } else {
            throw "Failed to upload deployment script"
        }
    }
    catch {
        throw "Error uploading deployment script: $($_.Exception.Message)"
    }
}

# Upload environment configuration
function Copy-EnvironmentConfig {
    param(
        [string]$VpsHost,
        [string]$User,
        [string]$Password
    )
    
    Write-Step "Uploading environment configuration..."
    
    $localEnv = ".\.env.deployment"
    $remoteEnv = "/tmp/.env.deployment"
    
    if (-not (Test-Path $localEnv)) {
        Write-Warning "Environment file not found: $localEnv"
        return
    }
    
    try {
        # Upload environment file
        if (Get-Command pscp -ErrorAction SilentlyContinue) {
            & pscp -pw $Password -batch $localEnv "$User@${VpsHost}:$remoteEnv"
        } else {
            & scp -o "StrictHostKeyChecking=no" $localEnv "$User@${VpsHost}:$remoteEnv"
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Environment configuration uploaded successfully"
        } else {
            Write-Warning "Failed to upload environment configuration"
        }
    }
    catch {
        Write-Warning "Error uploading environment configuration: $($_.Exception.Message)"
    }
}

# Execute deployment on VPS
function Invoke-RemoteDeployment {
    param(
        [string]$VpsHost,
        [string]$User,
        [string]$Password,
        [bool]$DryRun = $false
    )
    
    Write-Step "Executing deployment on VPS..."
    
    $commands = @(
        "chmod +x /tmp/nexus-cos-full-deployment.sh",
        "cd /tmp",
        "sudo ./nexus-cos-full-deployment.sh"
    )
    
    if ($DryRun) {
        Write-Warning "DRY RUN MODE - Commands that would be executed:"
        foreach ($cmd in $commands) {
            Write-Host "  $cmd"
        }
        return
    }
    
    try {
        foreach ($cmd in $commands) {
            Write-Verbose "Executing: $cmd"
            
            if (Get-Command plink -ErrorAction SilentlyContinue) {
                $result = & plink -ssh -l $User -pw $Password -batch $VpsHost $cmd
            } else {
                $result = & ssh -o "StrictHostKeyChecking=no" "$User@$VpsHost" $cmd
            }
            
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Command failed: $cmd"
                Write-Error "Output: $result"
                throw "Remote deployment failed"
            }
        }
        
        Write-Success "Remote deployment completed successfully"
    }
    catch {
        throw "Error during remote deployment: $($_.Exception.Message)"
    }
}

# Monitor deployment progress
function Watch-DeploymentProgress {
    param(
        [string]$VpsHost,
        [string]$User,
        [string]$Password
    )
    
    Write-Step "Monitoring deployment progress..."
    
    $logFile = "/opt/nexus-cos/deployment.log"
    $tailCommand = "tail -f $logFile"
    
    try {
        Write-Host "Press Ctrl+C to stop monitoring..."
        
        if (Get-Command plink -ErrorAction SilentlyContinue) {
            & plink -ssh -l $User -pw $Password -batch $VpsHost $tailCommand
        } else {
            & ssh -o "StrictHostKeyChecking=no" "$User@$VpsHost" $tailCommand
        }
    }
    catch {
        Write-Warning "Could not monitor deployment progress: $($_.Exception.Message)"
    }
}

# Verify deployment
function Test-Deployment {
    param(
        [string]$VpsHost,
        [string]$User,
        [string]$Password
    )
    
    Write-Step "Verifying deployment..."
    
    $verifyCommands = @(
        "curl -f http://localhost/health",
        "curl -f http://localhost/api/health",
        "docker-compose -f /opt/nexus-cos/docker-compose.yml ps",
        "cat /opt/nexus-cos/health_report.txt"
    )
    
    foreach ($cmd in $verifyCommands) {
        try {
            Write-Verbose "Verifying: $cmd"
            
            if (Get-Command plink -ErrorAction SilentlyContinue) {
                $result = & plink -ssh -l $User -pw $Password -batch $VpsHost $cmd 2>&1
            } else {
                $result = & ssh -o "StrictHostKeyChecking=no" "$User@$VpsHost" $cmd 2>&1
            }
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "SUCCESS: $cmd"
            } else {
                Write-Warning "FAILED: $cmd - $result"
            }
        }
        catch {
            Write-Warning "ERROR: $cmd - Error: $($_.Exception.Message)"
        }
    }
    
    Write-Success "Deployment verification completed"
}

# Generate deployment report
function New-DeploymentReport {
    param(
        [string]$VpsHost,
        [datetime]$StartTime,
        [datetime]$EndTime
    )
    
    $duration = $EndTime - $StartTime
    $reportFile = "nexus-cos-deployment-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    
    $reportLines = @()
    $reportLines += "Nexus COS Deployment Report"
    $reportLines += "==========================="
    $reportLines += "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $reportLines += "Target Host: $VpsHost"
    $reportLines += "Duration: $($duration.ToString('hh\:mm\:ss'))"
    $reportLines += ""
    $reportLines += "Deployment Status: COMPLETED"
    $reportLines += "Domain: https://nexuscos.online"
    $reportLines += "Admin Panel: https://nexuscos.online:3001"
    $reportLines += ""
    $reportLines += "Services Deployed:"
    $reportLines += "- PostgreSQL Database"
    $reportLines += "- Redis Cache"
    $reportLines += "- Node.js Backend API"
    $reportLines += "- Python Backend API"
    $reportLines += "- React Frontend"
    $reportLines += "- Nginx Reverse Proxy"
    $reportLines += "- Grafana Monitoring"
    $reportLines += "- Prometheus Metrics"
    $reportLines += ""
    $reportLines += "Next Steps:"
    $reportLines += "1. Verify all services are running: https://nexuscos.online/health"
    $reportLines += "2. Access admin panel: https://nexuscos.online:3001"
    $reportLines += "3. Check logs: /opt/nexus-cos/logs/"
    $reportLines += "4. Monitor health: /opt/nexus-cos/health_report.txt"
    $reportLines += ""
    $reportLines += "Rollback:"
    $reportLines += "If needed, run: /opt/nexus-cos/rollback.sh"
    $reportLines += ""
    $reportLines += "Support:"
    $reportLines += "- Logs: /opt/nexus-cos/deployment.log"
    $reportLines += "- Health Report: /opt/nexus-cos/health_report.txt"
    $reportLines += "- Backup Location: /opt/nexus-cos/backups/"
    
    $report = $reportLines -join "`n"

    $report | Out-File -FilePath $reportFile -Encoding UTF8
    Write-Success "Deployment report generated: $reportFile"
}

# Main deployment function
function Start-NexusCosDeployment {
    $startTime = Get-Date
    
    try {
        Write-Header "🚀 NEXUS COS FULL DEPLOYMENT"
        
        Write-Host "Target VPS: $VpsHost"
        Write-Host "SSH User: $SshUser"
        Write-Host "Domain: nexuscos.online"
        Write-Host ""
        
        if (-not $SkipPrerequisites) {
            Test-Prerequisites
        }
        
        if (-not (Test-SshConnection -VpsHost $VpsHost -User $SshUser -Password $SshPassword)) {
            throw "SSH connection failed"
        }
        
        Copy-DeploymentScript -VpsHost $VpsHost -User $SshUser -Password $SshPassword
        Copy-EnvironmentConfig -VpsHost $VpsHost -User $SshUser -Password $SshPassword
        
        Invoke-RemoteDeployment -VpsHost $VpsHost -User $SshUser -Password $SshPassword -DryRun $DryRun
        
        if (-not $DryRun) {
            Start-Sleep -Seconds 5
            Test-Deployment -VpsHost $VpsHost -User $SshUser -Password $SshPassword
            
            $endTime = Get-Date
            New-DeploymentReport -VpsHost $VpsHost -StartTime $startTime -EndTime $endTime
            
            Write-Header "DEPLOYMENT COMPLETED SUCCESSFULLY"
            Write-Success "Nexus COS is now live at: https://nexuscos.online"
            Write-Success "Admin Panel: https://nexuscos.online:3001"
            Write-Success "Total deployment time: $(($endTime - $startTime).ToString('hh\:mm\:ss'))"
        }
    }
    catch {
        Write-Header "DEPLOYMENT FAILED"
        Write-Error $_.Exception.Message
        Write-Warning "Check the deployment logs for more details"
        exit 1
    }
}

# Script execution
if ($MyInvocation.InvocationName -ne '.') {
    Start-NexusCosDeployment
}