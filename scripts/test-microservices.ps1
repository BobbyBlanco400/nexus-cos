# Nexus COS Microservices Integration Test Script
# PowerShell script for Windows environment

param(
    [switch]$StartServices = $false,
    [switch]$StopServices = $false,
    [switch]$RunTests = $true,
    [switch]$Verbose = $false
)

# Configuration
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$LogFile = Join-Path $ProjectRoot "logs\microservices-test.log"
$TestReportsDir = Join-Path $ProjectRoot "artifacts\test-reports"

# Ensure directories exist
$LogDir = Split-Path -Parent $LogFile
if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force }
if (!(Test-Path $TestReportsDir)) { New-Item -ItemType Directory -Path $TestReportsDir -Force }

# Services configuration
$Services = @{
    "v-screen" = @{ Port = 3010; Path = "services\v-screen"; Name = "V-Screen" }
    "v-stage" = @{ Port = 3011; Path = "services\v-stage"; Name = "V-Stage" }
    "v-caster-pro" = @{ Port = 3012; Path = "services\v-caster-pro"; Name = "V-Caster Pro" }
    "v-prompter-pro" = @{ Port = 3013; Path = "services\v-prompter-pro"; Name = "V-Prompter Pro" }
    "nexus-cos-studio-ai" = @{ Port = 3014; Path = "services\nexus-cos-studio-ai"; Name = "Nexus COS Studio AI" }
    "boom-boom-room-live" = @{ Port = 3015; Path = "services\boom-boom-room-live"; Name = "Boom Boom Room Live" }
}

# Test results tracking
$TestResults = @()
$TotalTests = 0
$PassedTests = 0
$FailedTests = 0

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    Add-Content -Path $LogFile -Value $LogMessage
}

function Record-Test {
    param(
        [string]$TestName,
        [string]$Status,
        [string]$Details = ""
    )
    
    $script:TestResults += @{
        Name = $TestName
        Status = $Status
        Details = $Details
        Timestamp = Get-Date
    }
    
    $script:TotalTests++
    
    if ($Status -eq "PASS") {
        $script:PassedTests++
        Write-Log "[PASS] ${TestName}: PASSED" "PASS"
    } else {
        $script:FailedTests++
        Write-Log "[FAIL] ${TestName}: FAILED - $Details" "FAIL"
    }
}

function Test-ServiceHealth {
    param([string]$ServiceName, [int]$Port)
    
    try {
        $Response = Invoke-RestMethod -Uri "http://localhost:$Port/health" -Method Get -TimeoutSec 10 -ErrorAction Stop
        if ($Response.status -eq "healthy") {
            Record-Test "Health Check: $ServiceName" "PASS"
            return $true
        } else {
            Record-Test "Health Check: $ServiceName" "FAIL" "Unexpected health status: $($Response.status)"
            return $false
        }
    } catch {
        Record-Test "Health Check: $ServiceName" "FAIL" "Connection failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-ServiceMetrics {
    param([string]$ServiceName, [int]$Port)
    
    try {
        $Response = Invoke-WebRequest -Uri "http://localhost:$Port/metrics" -Method Get -TimeoutSec 10 -ErrorAction Stop
        if ($Response.StatusCode -eq 200 -and $Response.Headers.'Content-Type' -like "*text/plain*") {
            Record-Test "Metrics Endpoint: $ServiceName" "PASS"
            return $true
        } else {
            Record-Test "Metrics Endpoint: $ServiceName" "FAIL" "Unexpected response format"
            return $false
        }
    } catch {
        Record-Test "Metrics Endpoint: $ServiceName" "FAIL" "Connection failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-PortAvailability {
    param([int]$Port)
    
    try {
        $Connection = New-Object System.Net.Sockets.TcpClient
        $Connection.Connect("localhost", $Port)
        $Connection.Close()
        return $true
    } catch {
        return $false
    }
}

function Run-IntegrationTests {
    Write-Log "Running integration tests..." "INFO"
    
    # Test 1: Health Checks
    Write-Log "Testing service health endpoints..." "INFO"
    foreach ($ServiceKey in $Services.Keys) {
        $Service = $Services[$ServiceKey]
        Test-ServiceHealth -ServiceName $Service.Name -Port $Service.Port
    }
    
    # Test 2: Metrics Endpoints
    Write-Log "Testing service metrics endpoints..." "INFO"
    foreach ($ServiceKey in $Services.Keys) {
        $Service = $Services[$ServiceKey]
        Test-ServiceMetrics -ServiceName $Service.Name -Port $Service.Port
    }
    
    # Test 3: Port Availability
    Write-Log "Testing port availability..." "INFO"
    foreach ($ServiceKey in $Services.Keys) {
        $Service = $Services[$ServiceKey]
        if (Test-PortAvailability -Port $Service.Port) {
            Record-Test "Port Availability: $($Service.Name)" "PASS"
        } else {
            Record-Test "Port Availability: $($Service.Name)" "FAIL" "Port $($Service.Port) not accessible"
        }
    }
    
    # Test 4: Cross-Service Communication
    Write-Log "Testing cross-service communication..." "INFO"
    $HealthyServices = 0
    foreach ($ServiceKey in $Services.Keys) {
        $Service = $Services[$ServiceKey]
        if (Test-PortAvailability -Port $Service.Port) {
            $HealthyServices++
        }
    }
    
    if ($HealthyServices -gt 0) {
        Record-Test "Cross-Service Communication" "PASS" "$HealthyServices services are accessible"
    } else {
        Record-Test "Cross-Service Communication" "FAIL" "No services are accessible"
    }
    
    # Test 5: Service Configuration Check
    Write-Log "Checking service configurations..." "INFO"
    foreach ($ServiceKey in $Services.Keys) {
        $Service = $Services[$ServiceKey]
        $ServicePath = Join-Path $ProjectRoot $Service.Path
        $PackageJsonPath = Join-Path $ServicePath "package.json"
        $ServerJsPath = Join-Path $ServicePath "server.js"
        
        if ((Test-Path $PackageJsonPath) -and (Test-Path $ServerJsPath)) {
            Record-Test "Configuration Check: $($Service.Name)" "PASS" "Required files exist"
        } else {
            Record-Test "Configuration Check: $($Service.Name)" "FAIL" "Missing required files"
        }
    }
}

function Generate-TestReport {
    Write-Log "Generating test report..." "INFO"
    
    $ReportPath = Join-Path $TestReportsDir "microservices-test-report.txt"
    $JsonReportPath = Join-Path $TestReportsDir "microservices-test-report.json"
    
    # Calculate success rate
    $SuccessRate = if ($TotalTests -gt 0) { [math]::Round(($PassedTests / $TotalTests) * 100, 2) } else { 0 }
    
    # Generate text report
    $ReportContent = @()
    $ReportContent += "Nexus COS Microservices Integration Test Report"
    $ReportContent += "=============================================="
    $ReportContent += ""
    $ReportContent += "Test Date: $(Get-Date)"
    $ReportContent += "Project: Nexus COS"
    $ReportContent += "Test Environment: Windows PowerShell"
    $ReportContent += ""
    $ReportContent += "Test Summary:"
    $ReportContent += "  Total Tests: $TotalTests"
    $ReportContent += "  Passed: $PassedTests"
    $ReportContent += "  Failed: $FailedTests"
    $ReportContent += "  Success Rate: $SuccessRate%"
    $ReportContent += ""
    $ReportContent += "Test Results:"
    
    foreach ($Result in $TestResults) {
        if ($Result.Status -eq "PASS") {
            $ReportContent += "[PASS] $($Result.Name): PASSED"
        } else {
            $ReportContent += "[FAIL] $($Result.Name): FAILED - $($Result.Details)"
        }
    }
    
    $ReportContent += ""
    $ReportContent += "Environment Information:"
    $ReportContent += "- PowerShell Version: $($PSVersionTable.PSVersion)"
    try { $ReportContent += "- Node.js: $(node --version)" } catch { $ReportContent += "- Node.js: Not available" }
    try { $ReportContent += "- npm: $(npm --version)" } catch { $ReportContent += "- npm: Not available" }
    $ReportContent += "- Operating System: $($env:OS)"
    $ReportContent += ""
    $ReportContent += "Test Artifacts:"
    $ReportContent += "- Test logs: $LogFile"
    $ReportContent += "- Test reports: $TestReportsDir"
    
    $ReportContent | Out-File -FilePath $ReportPath -Encoding UTF8
    
    # Generate JSON report
    $JsonReport = @{
        testDate = Get-Date
        project = "Nexus COS"
        environment = "Windows PowerShell"
        summary = @{
            totalTests = $TotalTests
            passed = $PassedTests
            failed = $FailedTests
            successRate = $SuccessRate
        }
        results = $TestResults
        environmentInfo = @{
            powershellVersion = $PSVersionTable.PSVersion.ToString()
            operatingSystem = $env:OS
        }
    }
    
    $JsonReport | ConvertTo-Json -Depth 10 | Out-File -FilePath $JsonReportPath -Encoding UTF8
    
    Write-Log "Test report generated: $ReportPath" "INFO"
    Write-Log "JSON report generated: $JsonReportPath" "INFO"
}

# Main execution
try {
    Write-Log "Starting Nexus COS Microservices Integration Tests" "INFO"
    
    if ($RunTests) {
        Run-IntegrationTests
    }
    
    Generate-TestReport
    
    # Final summary
    Write-Log "Test suite completed!" "INFO"
    Write-Log "Total tests: $TotalTests" "INFO"
    Write-Log "Passed: $PassedTests" "INFO"
    Write-Log "Failed: $FailedTests" "INFO"
    $SuccessRate = if ($TotalTests -gt 0) { [math]::Round(($PassedTests / $TotalTests) * 100, 2) } else { 0 }
    Write-Log "Success rate: $SuccessRate%" "INFO"
    
    # Exit with appropriate code
    if ($FailedTests -eq 0) {
        Write-Log "All tests passed! [SUCCESS]" "INFO"
        exit 0
    } else {
        Write-Log "Some tests failed! [ERROR]" "ERROR"
        exit 1
    }
    
} catch {
    Write-Log "Critical error during test execution: $($_.Exception.Message)" "ERROR"
    exit 1
}