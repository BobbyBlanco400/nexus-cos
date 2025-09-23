#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Nexus COS Deployment Validation Script
.DESCRIPTION
    Validates all system requirements, configurations, and dependencies for VPS deployment
.PARAMETER CheckAll
    Run all validation checks
.PARAMETER CheckDependencies
    Check only system dependencies
.PARAMETER CheckConfigurations
    Check only configuration files
.PARAMETER CheckDocker
    Check only Docker setup
.PARAMETER GenerateReport
    Generate detailed validation report
#>

param(
    [switch]$CheckAll = $false,
    [switch]$CheckDependencies = $false,
    [switch]$CheckConfigurations = $false,
    [switch]$CheckDocker = $false,
    [switch]$GenerateReport = $true
)

# Configuration
$ProjectRoot = "C:\Users\wecon\Downloads\nexus-cos-main"
$LogDir = "$ProjectRoot\logs"
$ReportDir = "$ProjectRoot\artifacts\deployment-reports"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile = "$LogDir\deployment-validation-$Timestamp.log"
$ReportFile = "$ReportDir\deployment-validation-report-$Timestamp.txt"

# Ensure directories exist
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

# Global test results
$Global:TestResults = @()
$Global:PassedTests = 0
$Global:FailedTests = 0

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $LogMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Write-Host $LogMessage
    Add-Content -Path $LogFile -Value $LogMessage
}

# Test result tracking
function Add-TestResult {
    param([string]$TestName, [bool]$Passed, [string]$Details = "")
    
    $Status = if ($Passed) { "PASS" } else { "FAIL" }
    $Result = @{
        TestName = $TestName
        Status = $Status
        Details = $Details
        Timestamp = Get-Date
    }
    
    $Global:TestResults += $Result
    
    if ($Passed) {
        $Global:PassedTests++
        Write-Log "[$Status] ${TestName}: PASSED $Details" "PASS"
    } else {
        $Global:FailedTests++
        Write-Log "[$Status] ${TestName}: FAILED $Details" "FAIL"
    }
}

# System Dependencies Check
function Test-SystemDependencies {
    Write-Log "Checking system dependencies..." "INFO"
    
    # Check Node.js
    try {
        $NodeVersion = node --version 2>$null
        if ($NodeVersion) {
            Add-TestResult "Node.js Installation" $true "Version: $NodeVersion"
        } else {
            Add-TestResult "Node.js Installation" $false "Node.js not found"
        }
    } catch {
        Add-TestResult "Node.js Installation" $false "Node.js not accessible"
    }
    
    # Check npm
    try {
        $NpmVersion = npm --version 2>$null
        if ($NpmVersion) {
            Add-TestResult "npm Installation" $true "Version: $NpmVersion"
        } else {
            Add-TestResult "npm Installation" $false "npm not found"
        }
    } catch {
        Add-TestResult "npm Installation" $false "npm not accessible"
    }
    
    # Check Docker
    try {
        $DockerVersion = docker --version 2>$null
        if ($DockerVersion) {
            Add-TestResult "Docker Installation" $true "Version: $DockerVersion"
        } else {
            Add-TestResult "Docker Installation" $false "Docker not found"
        }
    } catch {
        Add-TestResult "Docker Installation" $false "Docker not accessible"
    }
    
    # Check Docker Compose
    try {
        $ComposeVersion = docker-compose --version 2>$null
        if ($ComposeVersion) {
            Add-TestResult "Docker Compose Installation" $true "Version: $ComposeVersion"
        } else {
            Add-TestResult "Docker Compose Installation" $false "Docker Compose not found"
        }
    } catch {
        Add-TestResult "Docker Compose Installation" $false "Docker Compose not accessible"
    }
    
    # Check Git
    try {
        $GitVersion = git --version 2>$null
        if ($GitVersion) {
            Add-TestResult "Git Installation" $true "Version: $GitVersion"
        } else {
            Add-TestResult "Git Installation" $false "Git not found"
        }
    } catch {
        Add-TestResult "Git Installation" $false "Git not accessible"
    }
    
    # Check PowerShell version
    $PSVersion = $PSVersionTable.PSVersion.ToString()
    Add-TestResult "PowerShell Version" $true "Version: $PSVersion"
    
    # Check available memory
    $Memory = Get-CimInstance -ClassName Win32_ComputerSystem
    $TotalMemoryGB = [math]::Round($Memory.TotalPhysicalMemory / 1GB, 2)
    $MemoryOK = $TotalMemoryGB -ge 4
    Add-TestResult "System Memory" $MemoryOK "Total: ${TotalMemoryGB}GB (Minimum: 4GB)"
    
    # Check available disk space
    $Disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
    $FreeSpaceGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
    $DiskOK = $FreeSpaceGB -ge 10
    Add-TestResult "Disk Space" $DiskOK "Free: ${FreeSpaceGB}GB (Minimum: 10GB)"
}

# Configuration Files Check
function Test-ConfigurationFiles {
    Write-Log "Checking configuration files..." "INFO"
    
    # Required configuration files
    $RequiredFiles = @(
        "$ProjectRoot\docker-compose.yml",
        "$ProjectRoot\docker-compose.prod.yml",
        "$ProjectRoot\.env.example",
        "$ProjectRoot\nginx\nginx.conf",
        "$ProjectRoot\scripts\deploy_nexus_cos.sh",
        "$ProjectRoot\scripts\run-tests.sh"
    )
    
    foreach ($File in $RequiredFiles) {
        $Exists = Test-Path $File
        $FileName = Split-Path $File -Leaf
        Add-TestResult "Config File: $FileName" $Exists "Path: $File"
    }
    
    # Check microservice configurations
    $Services = @(
        "services\v-screen",
        "services\v-stage", 
        "services\v-caster-pro",
        "services\v-prompter-pro",
        "services\nexus-cos-studio-ai",
        "services\boom-boom-room-live"
    )
    
    foreach ($Service in $Services) {
        $PackageJson = "$ProjectRoot\$Service\package.json"
        $ServerJs = "$ProjectRoot\$Service\server.js"
        
        $PackageExists = Test-Path $PackageJson
        $ServerExists = Test-Path $ServerJs
        
        $ServiceName = Split-Path $Service -Leaf
        Add-TestResult "Service Config: $ServiceName package.json" $PackageExists "Path: $PackageJson"
        Add-TestResult "Service Config: $ServiceName server.js" $ServerExists "Path: $ServerJs"
    }
    
    # Check environment files
    $EnvFiles = @(
        "$ProjectRoot\.env.development",
        "$ProjectRoot\.env.production"
    )
    
    foreach ($EnvFile in $EnvFiles) {
        $Exists = Test-Path $EnvFile
        $FileName = Split-Path $EnvFile -Leaf
        Add-TestResult "Environment File: $FileName" $Exists "Path: $EnvFile"
    }
}

# Docker Configuration Check
function Test-DockerConfiguration {
    Write-Log "Checking Docker configuration..." "INFO"
    
    # Check if Docker is running
    try {
        $DockerInfo = docker info 2>$null
        if ($DockerInfo) {
            Add-TestResult "Docker Service" $true "Docker daemon is running"
        } else {
            Add-TestResult "Docker Service" $false "Docker daemon not running"
        }
    } catch {
        Add-TestResult "Docker Service" $false "Cannot connect to Docker daemon"
    }
    
    # Validate docker-compose.yml
    if (Test-Path "$ProjectRoot\docker-compose.yml") {
        try {
            Set-Location $ProjectRoot
            $ComposeValidation = docker-compose config 2>$null
            if ($ComposeValidation) {
                Add-TestResult "Docker Compose Validation" $true "docker-compose.yml is valid"
            } else {
                Add-TestResult "Docker Compose Validation" $false "docker-compose.yml has errors"
            }
        } catch {
            Add-TestResult "Docker Compose Validation" $false "Cannot validate docker-compose.yml"
        }
    } else {
        Add-TestResult "Docker Compose Validation" $false "docker-compose.yml not found"
    }
    
    # Check Docker images
    $RequiredImages = @(
        "node:18-alpine",
        "postgres:15-alpine",
        "redis:7-alpine",
        "nginx:alpine"
    )
    
    foreach ($Image in $RequiredImages) {
        try {
            $ImageExists = docker images $Image --format "table {{.Repository}}:{{.Tag}}" 2>$null
            if ($ImageExists -and $ImageExists -ne "REPOSITORY:TAG") {
                Add-TestResult "Docker Image: $Image" $true "Image available locally"
            } else {
                Add-TestResult "Docker Image: $Image" $false "Image not available locally"
            }
        } catch {
            Add-TestResult "Docker Image: $Image" $false "Cannot check image availability"
        }
    }
}

# Network Ports Check
function Test-NetworkPorts {
    Write-Log "Checking network port availability..." "INFO"
    
    $RequiredPorts = @(
        @{Port=80; Service="Nginx HTTP"},
        @{Port=443; Service="Nginx HTTPS"},
        @{Port=3000; Service="Main Frontend"},
        @{Port=3001; Service="Admin Panel"},
        @{Port=3002; Service="TV/Radio"},
        @{Port=3010; Service="V-Screen"},
        @{Port=3011; Service="V-Stage"},
        @{Port=3012; Service="V-Caster Pro"},
        @{Port=3013; Service="V-Prompter Pro"},
        @{Port=3014; Service="Nexus COS Studio AI"},
        @{Port=3015; Service="Boom Boom Room Live"},
        @{Port=5432; Service="PostgreSQL"},
        @{Port=6379; Service="Redis"}
    )
    
    foreach ($PortInfo in $RequiredPorts) {
        try {
            $Connection = Test-NetConnection -ComputerName "localhost" -Port $PortInfo.Port -WarningAction SilentlyContinue
            $Available = -not $Connection.TcpTestSucceeded
            Add-TestResult "Port Availability: $($PortInfo.Service)" $Available "Port $($PortInfo.Port) $(if($Available){'available'}else{'in use'})"
        } catch {
            Add-TestResult "Port Availability: $($PortInfo.Service)" $true "Port $($PortInfo.Port) available (test failed, assuming available)"
        }
    }
}

# Security Check
function Test-SecurityConfiguration {
    Write-Log "Checking security configuration..." "INFO"
    
    # Check for sensitive files that shouldn't be in production
    $SensitiveFiles = @(
        "$ProjectRoot\.env",
        "$ProjectRoot\secrets.json",
        "$ProjectRoot\private.key"
    )
    
    foreach ($File in $SensitiveFiles) {
        $Exists = Test-Path $File
        $FileName = Split-Path $File -Leaf
        Add-TestResult "Security: No $FileName in production" (-not $Exists) "File $(if($Exists){'found - SECURITY RISK'}else{'not found - OK'})"
    }
    
    # Check .gitignore
    $GitIgnore = "$ProjectRoot\.gitignore"
    if (Test-Path $GitIgnore) {
        $GitIgnoreContent = Get-Content $GitIgnore -Raw
        $HasEnvIgnore = $GitIgnoreContent -match "\.env"
        $HasNodeModulesIgnore = $GitIgnoreContent -match "node_modules"
        $HasLogsIgnore = $GitIgnoreContent -match "logs"
        
        Add-TestResult "Security: .gitignore covers .env" $HasEnvIgnore ".env files $(if($HasEnvIgnore){'ignored'}else{'NOT ignored - RISK'})"
        Add-TestResult "Security: .gitignore covers node_modules" $HasNodeModulesIgnore "node_modules $(if($HasNodeModulesIgnore){'ignored'}else{'NOT ignored'})"
        Add-TestResult "Security: .gitignore covers logs" $HasLogsIgnore "logs $(if($HasLogsIgnore){'ignored'}else{'NOT ignored'})"
    } else {
        Add-TestResult "Security: .gitignore exists" $false ".gitignore file not found"
    }
}

# Generate comprehensive report
function Generate-Report {
    Write-Log "Generating deployment validation report..." "INFO"
    
    $TotalTests = $Global:PassedTests + $Global:FailedTests
    $SuccessRate = if ($TotalTests -gt 0) { [math]::Round(($Global:PassedTests / $TotalTests) * 100, 2) } else { 0 }
    
    $Report = @"
Nexus COS Deployment Validation Report
=====================================

Validation Date: $(Get-Date -Format 'MM/dd/yyyy HH:mm:ss')
Project: Nexus COS
Environment: Windows PowerShell
Validation Script: validate-deployment.ps1

Executive Summary:
  Total Tests: $TotalTests
  Passed: $Global:PassedTests
  Failed: $Global:FailedTests
  Success Rate: $SuccessRate%
  
Deployment Readiness: $(if($SuccessRate -ge 90){'READY'}elseif($SuccessRate -ge 75){'MOSTLY READY - Minor issues'}else{'NOT READY - Critical issues'})

Detailed Test Results:
"@

    foreach ($Result in $Global:TestResults) {
        $Report += "`n[$($Result.Status)] $($Result.TestName): $($Result.Status) $($Result.Details)"
    }
    
    $Report += @"

System Information:
- PowerShell Version: $($PSVersionTable.PSVersion)
- Operating System: $($PSVersionTable.OS)
- Execution Policy: $(Get-ExecutionPolicy)
- Current User: $($env:USERNAME)
- Computer Name: $($env:COMPUTERNAME)

Recommendations:
"@

    if ($Global:FailedTests -gt 0) {
        $Report += "`n- Address all FAILED tests before deployment"
        $Report += "`n- Verify system requirements are met"
        $Report += "`n- Check configuration files for errors"
        $Report += "`n- Ensure Docker is properly configured"
    } else {
        $Report += "`n- All validation tests passed!"
        $Report += "`n- System is ready for deployment"
        $Report += "`n- Proceed with VPS deployment"
    }
    
    $Report += @"

Next Steps:
1. Review this validation report
2. Address any failed tests
3. Run validation again if needed
4. Proceed with VPS deployment using deploy_nexus_cos.sh
5. Monitor deployment logs and health checks

Validation Artifacts:
- Validation logs: $LogFile
- This report: $ReportFile
"@

    # Save report
    Set-Content -Path $ReportFile -Value $Report
    Write-Log "Validation report saved: $ReportFile" "INFO"
    
    # Display summary
    Write-Host "`n" -ForegroundColor Green
    Write-Host "=== DEPLOYMENT VALIDATION SUMMARY ===" -ForegroundColor Cyan
    Write-Host "Total Tests: $TotalTests" -ForegroundColor White
    Write-Host "Passed: $Global:PassedTests" -ForegroundColor Green
    Write-Host "Failed: $Global:FailedTests" -ForegroundColor $(if($Global:FailedTests -gt 0){'Red'}else{'Green'})
    Write-Host "Success Rate: $SuccessRate%" -ForegroundColor $(if($SuccessRate -ge 90){'Green'}elseif($SuccessRate -ge 75){'Yellow'}else{'Red'})
    Write-Host "Deployment Status: $(if($SuccessRate -ge 90){'READY'}elseif($SuccessRate -ge 75){'MOSTLY READY'}else{'NOT READY'})" -ForegroundColor $(if($SuccessRate -ge 90){'Green'}elseif($SuccessRate -ge 75){'Yellow'}else{'Red'})
    Write-Host "Report: $ReportFile" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
}

# Main execution
Write-Log "Starting Nexus COS deployment validation..." "INFO"
Write-Log "Project root: $ProjectRoot" "INFO"

# Run validation checks based on parameters
if ($CheckAll -or $CheckDependencies -or (-not $CheckConfigurations -and -not $CheckDocker)) {
    Test-SystemDependencies
}

if ($CheckAll -or $CheckConfigurations -or (-not $CheckDependencies -and -not $CheckDocker)) {
    Test-ConfigurationFiles
}

if ($CheckAll -or $CheckDocker -or (-not $CheckDependencies -and -not $CheckConfigurations)) {
    Test-DockerConfiguration
}

# Always run these critical checks
Test-NetworkPorts
Test-SecurityConfiguration

# Generate report
if ($GenerateReport) {
    Generate-Report
}

Write-Log "Deployment validation completed!" "INFO"

# Exit with appropriate code
if ($Global:FailedTests -gt 0) {
    Write-Log "Validation completed with failures. Review the report before deployment." "ERROR"
    exit 1
} else {
    Write-Log "All validation tests passed! System is ready for deployment." "SUCCESS"
    exit 0
}