#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Nexus COS Health Check Script
.DESCRIPTION
    Monitors health and status of all Nexus COS services and infrastructure
.PARAMETER Continuous
    Run health checks continuously with specified interval
.PARAMETER Interval
    Interval in seconds for continuous monitoring (default: 30)
.PARAMETER AlertThreshold
    Number of consecutive failures before alerting (default: 3)
.PARAMETER GenerateReport
    Generate detailed health report
.PARAMETER CheckServices
    Check only microservices health
.PARAMETER CheckInfrastructure
    Check only infrastructure health
#>

param(
    [switch]$Continuous = $false,
    [int]$Interval = 30,
    [int]$AlertThreshold = 3,
    [switch]$GenerateReport = $true,
    [switch]$CheckServices = $false,
    [switch]$CheckInfrastructure = $false
)

# Configuration
$ProjectRoot = "C:\Users\wecon\Downloads\nexus-cos-main"
$LogDir = "$ProjectRoot\logs"
$ReportDir = "$ProjectRoot\artifacts\health-reports"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile = "$LogDir\health-check-$Timestamp.log"
$ReportFile = "$ReportDir\health-report-$Timestamp.txt"

# Ensure directories exist
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

# Global health tracking
$Global:HealthResults = @()
$Global:HealthyServices = 0
$Global:UnhealthyServices = 0
$Global:FailureCount = @{}

# Service definitions
$Services = @(
    @{Name="V-Screen"; Port=3010; Path="/health"; Type="microservice"},
    @{Name="V-Stage"; Port=3011; Path="/health"; Type="microservice"},
    @{Name="V-Caster Pro"; Port=3012; Path="/health"; Type="microservice"},
    @{Name="V-Prompter Pro"; Port=3013; Path="/health"; Type="microservice"},
    @{Name="Nexus COS Studio AI"; Port=3014; Path="/health"; Type="microservice"},
    @{Name="Boom Boom Room Live"; Port=3015; Path="/health"; Type="microservice"},
    @{Name="Main Frontend"; Port=3000; Path="/"; Type="frontend"},
    @{Name="Admin Panel"; Port=3001; Path="/"; Type="frontend"},
    @{Name="TV/Radio"; Port=3002; Path="/"; Type="frontend"},
    @{Name="PostgreSQL"; Port=5432; Path=""; Type="database"},
    @{Name="Redis"; Port=6379; Path=""; Type="cache"},
    @{Name="Nginx"; Port=80; Path="/"; Type="proxy"}
)

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $LogMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Write-Host $LogMessage -ForegroundColor $(
        switch($Level) {
            "ERROR" { "Red" }
            "WARN" { "Yellow" }
            "SUCCESS" { "Green" }
            "FAIL" { "Red" }
            "PASS" { "Green" }
            default { "White" }
        }
    )
    Add-Content -Path $LogFile -Value $LogMessage
}

# Health check result tracking
function Add-HealthResult {
    param([string]$ServiceName, [bool]$Healthy, [string]$Details = "", [int]$ResponseTime = 0)
    
    $Status = if ($Healthy) { "HEALTHY" } else { "UNHEALTHY" }
    $Result = @{
        ServiceName = $ServiceName
        Status = $Status
        Healthy = $Healthy
        Details = $Details
        ResponseTime = $ResponseTime
        Timestamp = Get-Date
    }
    
    $Global:HealthResults += $Result
    
    if ($Healthy) {
        $Global:HealthyServices++
        $Global:FailureCount[$ServiceName] = 0
        Write-Log "[$Status] $ServiceName: HEALTHY ($($ResponseTime)ms) $Details" "PASS"
    } else {
        $Global:UnhealthyServices++
        if (-not $Global:FailureCount.ContainsKey($ServiceName)) {
            $Global:FailureCount[$ServiceName] = 0
        }
        $Global:FailureCount[$ServiceName]++
        Write-Log "[$Status] $ServiceName: UNHEALTHY $Details" "FAIL"
        
        # Alert if threshold reached
        if ($Global:FailureCount[$ServiceName] -ge $AlertThreshold) {
            Write-Log "ALERT: $ServiceName has failed $($Global:FailureCount[$ServiceName]) consecutive times!" "ERROR"
        }
    }
}

# HTTP health check
function Test-HttpHealth {
    param([string]$ServiceName, [int]$Port, [string]$Path = "/", [int]$TimeoutSeconds = 10)
    
    try {
        $Url = "http://localhost:$Port$Path"
        $StartTime = Get-Date
        
        $Response = Invoke-WebRequest -Uri $Url -TimeoutSec $TimeoutSeconds -UseBasicParsing -ErrorAction Stop
        $EndTime = Get-Date
        $ResponseTime = [int](($EndTime - $StartTime).TotalMilliseconds)
        
        $Healthy = $Response.StatusCode -eq 200
        $Details = "Status: $($Response.StatusCode)"
        
        Add-HealthResult $ServiceName $Healthy $Details $ResponseTime
        return $Healthy
    }
    catch {
        $Details = "Error: $($_.Exception.Message)"
        Add-HealthResult $ServiceName $false $Details 0
        return $false
    }
}

# TCP port health check
function Test-TcpHealth {
    param([string]$ServiceName, [int]$Port, [int]$TimeoutSeconds = 5)
    
    try {
        $StartTime = Get-Date
        $TcpClient = New-Object System.Net.Sockets.TcpClient
        $Connect = $TcpClient.BeginConnect("localhost", $Port, $null, $null)
        $Wait = $Connect.AsyncWaitHandle.WaitOne($TimeoutSeconds * 1000, $false)
        
        if ($Wait) {
            try {
                $TcpClient.EndConnect($Connect)
                $EndTime = Get-Date
                $ResponseTime = [int](($EndTime - $StartTime).TotalMilliseconds)
                $TcpClient.Close()
                
                Add-HealthResult $ServiceName $true "TCP connection successful" $ResponseTime
                return $true
            }
            catch {
                $TcpClient.Close()
                Add-HealthResult $ServiceName $false "TCP connection failed: $($_.Exception.Message)" 0
                return $false
            }
        }
        else {
            $TcpClient.Close()
            Add-HealthResult $ServiceName $false "TCP connection timeout" 0
            return $false
        }
    }
    catch {
        Add-HealthResult $ServiceName $false "TCP test error: $($_.Exception.Message)" 0
        return $false
    }
}

# Docker container health check
function Test-DockerHealth {
    param([string]$ContainerName)
    
    try {
        $ContainerInfo = docker ps --filter "name=$ContainerName" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>$null
        
        if ($ContainerInfo -and $ContainerInfo -notmatch "NAMES") {
            $Lines = $ContainerInfo -split "`n"
            foreach ($Line in $Lines) {
                if ($Line -match $ContainerName) {
                    $Status = ($Line -split "`t")[1]
                    $Healthy = $Status -match "Up"
                    $Details = "Container status: $Status"
                    Add-HealthResult "Docker: $ContainerName" $Healthy $Details 0
                    return $Healthy
                }
            }
        }
        
        Add-HealthResult "Docker: $ContainerName" $false "Container not found or not running" 0
        return $false
    }
    catch {
        Add-HealthResult "Docker: $ContainerName" $false "Docker check error: $($_.Exception.Message)" 0
        return $false
    }
}

# System resource health check
function Test-SystemHealth {
    Write-Log "Checking system resources..." "INFO"
    
    # Memory usage
    try {
        $Memory = Get-CimInstance -ClassName Win32_OperatingSystem
        $TotalMemory = $Memory.TotalVisibleMemorySize / 1MB
        $FreeMemory = $Memory.FreePhysicalMemory / 1MB
        $UsedMemoryPercent = [math]::Round((($TotalMemory - $FreeMemory) / $TotalMemory) * 100, 2)
        
        $MemoryHealthy = $UsedMemoryPercent -lt 90
        Add-HealthResult "System Memory" $MemoryHealthy "Usage: $UsedMemoryPercent% (${FreeMemory}MB free)" 0
    }
    catch {
        Add-HealthResult "System Memory" $false "Memory check failed: $($_.Exception.Message)" 0
    }
    
    # CPU usage
    try {
        $CPU = Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average
        $CPUUsage = [math]::Round($CPU.Average, 2)
        
        $CPUHealthy = $CPUUsage -lt 90
        Add-HealthResult "System CPU" $CPUHealthy "Usage: $CPUUsage%" 0
    }
    catch {
        Add-HealthResult "System CPU" $false "CPU check failed: $($_.Exception.Message)" 0
    }
    
    # Disk space
    try {
        $Disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
        $FreeSpaceGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
        $TotalSpaceGB = [math]::Round($Disk.Size / 1GB, 2)
        $UsedSpacePercent = [math]::Round((($TotalSpaceGB - $FreeSpaceGB) / $TotalSpaceGB) * 100, 2)
        
        $DiskHealthy = $UsedSpacePercent -lt 90
        Add-HealthResult "System Disk" $DiskHealthy "Usage: $UsedSpacePercent% (${FreeSpaceGB}GB free)" 0
    }
    catch {
        Add-HealthResult "System Disk" $false "Disk check failed: $($_.Exception.Message)" 0
    }
}

# Check microservices health
function Test-MicroservicesHealth {
    Write-Log "Checking microservices health..." "INFO"
    
    foreach ($Service in $Services) {
        if ($Service.Type -eq "microservice" -or $Service.Type -eq "frontend") {
            Test-HttpHealth $Service.Name $Service.Port $Service.Path
        }
        elseif ($Service.Type -eq "database" -or $Service.Type -eq "cache" -or $Service.Type -eq "proxy") {
            Test-TcpHealth $Service.Name $Service.Port
        }
    }
}

# Check Docker containers health
function Test-DockerContainersHealth {
    Write-Log "Checking Docker containers health..." "INFO"
    
    $ContainerNames = @(
        "nexus-cos-postgres",
        "nexus-cos-redis", 
        "nexus-cos-nginx",
        "nexus-cos-v-screen",
        "nexus-cos-v-stage",
        "nexus-cos-v-caster-pro",
        "nexus-cos-v-prompter-pro",
        "nexus-cos-studio-ai",
        "nexus-cos-boom-boom-room"
    )
    
    foreach ($ContainerName in $ContainerNames) {
        Test-DockerHealth $ContainerName
    }
}

# Generate health report
function Generate-HealthReport {
    Write-Log "Generating health report..." "INFO"
    
    $TotalServices = $Global:HealthyServices + $Global:UnhealthyServices
    $HealthPercentage = if ($TotalServices -gt 0) { [math]::Round(($Global:HealthyServices / $TotalServices) * 100, 2) } else { 0 }
    
    $OverallHealth = if ($HealthPercentage -ge 95) { "EXCELLENT" }
                    elseif ($HealthPercentage -ge 80) { "GOOD" }
                    elseif ($HealthPercentage -ge 60) { "FAIR" }
                    else { "POOR" }
    
    $Report = @"
Nexus COS Health Check Report
============================

Health Check Date: $(Get-Date -Format 'MM/dd/yyyy HH:mm:ss')
Project: Nexus COS
Environment: Production
Monitoring Script: health-check.ps1

Overall Health Summary:
  Total Services: $TotalServices
  Healthy: $Global:HealthyServices
  Unhealthy: $Global:UnhealthyServices
  Health Percentage: $HealthPercentage%
  Overall Status: $OverallHealth

Service Health Details:
"@

    foreach ($Result in $Global:HealthResults) {
        $ResponseTimeInfo = if ($Result.ResponseTime -gt 0) { " ($($Result.ResponseTime)ms)" } else { "" }
        $Report += "`n[$($Result.Status)] $($Result.ServiceName): $($Result.Status)$ResponseTimeInfo $($Result.Details)"
    }
    
    # Alert summary
    $AlertServices = $Global:FailureCount.GetEnumerator() | Where-Object { $_.Value -ge $AlertThreshold }
    if ($AlertServices) {
        $Report += "`n`nALERT SUMMARY:"
        foreach ($Alert in $AlertServices) {
            $Report += "`n- $($Alert.Key): $($Alert.Value) consecutive failures"
        }
    }
    
    $Report += @"

System Information:
- PowerShell Version: $($PSVersionTable.PSVersion)
- Operating System: $($PSVersionTable.OS)
- Computer Name: $($env:COMPUTERNAME)
- Check Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Recommendations:
"@

    if ($Global:UnhealthyServices -gt 0) {
        $Report += "`n- Investigate unhealthy services immediately"
        $Report += "`n- Check service logs for error details"
        $Report += "`n- Verify system resources are adequate"
        $Report += "`n- Consider restarting failed services"
    } else {
        $Report += "`n- All services are healthy!"
        $Report += "`n- Continue regular monitoring"
        $Report += "`n- System is operating normally"
    }
    
    $Report += @"

Health Check Artifacts:
- Health logs: $LogFile
- This report: $ReportFile
"@

    # Save report
    Set-Content -Path $ReportFile -Value $Report
    Write-Log "Health report saved: $ReportFile" "INFO"
    
    # Display summary
    Write-Host "`n" -ForegroundColor Green
    Write-Host "=== NEXUS COS HEALTH SUMMARY ===" -ForegroundColor Cyan
    Write-Host "Total Services: $TotalServices" -ForegroundColor White
    Write-Host "Healthy: $Global:HealthyServices" -ForegroundColor Green
    Write-Host "Unhealthy: $Global:UnhealthyServices" -ForegroundColor $(if($Global:UnhealthyServices -gt 0){'Red'}else{'Green'})
    Write-Host "Health Percentage: $HealthPercentage%" -ForegroundColor $(
        if($HealthPercentage -ge 95){'Green'}
        elseif($HealthPercentage -ge 80){'Yellow'}
        else{'Red'}
    )
    Write-Host "Overall Status: $OverallHealth" -ForegroundColor $(
        if($OverallHealth -eq "EXCELLENT"){'Green'}
        elseif($OverallHealth -eq "GOOD"){'Yellow'}
        else{'Red'}
    )
    Write-Host "Report: $ReportFile" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
}

# Main health check function
function Invoke-HealthCheck {
    Write-Log "Starting Nexus COS health check..." "INFO"
    
    # Reset counters
    $Global:HealthResults = @()
    $Global:HealthyServices = 0
    $Global:UnhealthyServices = 0
    
    # Run health checks based on parameters
    if ($CheckServices -or (-not $CheckInfrastructure)) {
        Test-MicroservicesHealth
    }
    
    if ($CheckInfrastructure -or (-not $CheckServices)) {
        Test-SystemHealth
        Test-DockerContainersHealth
    }
    
    # Generate report
    if ($GenerateReport) {
        Generate-HealthReport
    }
    
    Write-Log "Health check completed!" "INFO"
    
    return ($Global:UnhealthyServices -eq 0)
}

# Main execution
Write-Log "Nexus COS Health Check System starting..." "INFO"
Write-Log "Project root: $ProjectRoot" "INFO"

if ($Continuous) {
    Write-Log "Starting continuous health monitoring (interval: ${Interval}s, alert threshold: $AlertThreshold)" "INFO"
    
    do {
        $HealthCheckPassed = Invoke-HealthCheck
        
        if (-not $HealthCheckPassed) {
            Write-Log "Health check failed! Check the report for details." "ERROR"
        }
        
        if ($Continuous) {
            Write-Log "Waiting $Interval seconds before next check..." "INFO"
            Start-Sleep -Seconds $Interval
        }
    } while ($Continuous)
} else {
    $HealthCheckPassed = Invoke-HealthCheck
    
    if ($HealthCheckPassed) {
        Write-Log "All health checks passed!" "SUCCESS"
        exit 0
    } else {
        Write-Log "Some health checks failed! Review the report." "ERROR"
        exit 1
    }
}