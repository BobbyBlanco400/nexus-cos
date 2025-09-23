# Nexus COS Extended - Service Validation Script (PowerShell)
# Validates all service endpoints as specified in the deployment requirements

param(
    [string]$Domain = "nexuscos.online",
    [string]$BaseUrl = "http://localhost",
    [int]$Timeout = 30
)

# Configuration
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Counters
$TotalChecks = 0
$PassedChecks = 0
$FailedChecks = 0

# Logging functions
function Write-Success {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ✓ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ⚠ WARNING: $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ✗ ERROR: $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ℹ INFO: $Message" -ForegroundColor Cyan
}

# Function to check HTTP endpoint
function Test-Endpoint {
    param(
        [string]$Endpoint,
        [int]$ExpectedStatus = 200,
        [string]$Description
    )
    
    $script:TotalChecks++
    
    Write-Info "Checking $Description`: $Endpoint"
    
    try {
        $response = Invoke-WebRequest -Uri $Endpoint -TimeoutSec $Timeout -UseBasicParsing -ErrorAction Stop
        $statusCode = $response.StatusCode
        
        if ($statusCode -eq $ExpectedStatus) {
            Write-Success "$Description - OK (Status: $statusCode)"
            $script:PassedChecks++
            return $true
        } else {
            Write-Error "$Description - FAILED (Status: $statusCode, Expected: $ExpectedStatus)"
            $script:FailedChecks++
            return $false
        }
    } catch {
        $statusCode = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { "Connection Failed" }
        
        if ($statusCode -eq $ExpectedStatus) {
            Write-Success "$Description - OK (Status: $statusCode)"
            $script:PassedChecks++
            return $true
        } else {
            Write-Error "$Description - FAILED (Status: $statusCode, Expected: $ExpectedStatus)"
            $script:FailedChecks++
            return $false
        }
    }
}

# Function to check Docker service
function Test-DockerService {
    param(
        [string]$ServiceName,
        [string]$Description
    )
    
    $script:TotalChecks++
    
    Write-Info "Checking Docker service: $ServiceName"
    
    try {
        $result = docker-compose -f docker-compose.trae-solo-extended.yml ps $ServiceName 2>$null
        
        if ($result -and ($result -match "Up" -or $result -match "running")) {
            Write-Success "$Description - Docker service running"
            $script:PassedChecks++
            return $true
        } else {
            Write-Error "$Description - Docker service not running"
            $script:FailedChecks++
            return $false
        }
    } catch {
        Write-Error "$Description - Docker service check failed: $($_.Exception.Message)"
        $script:FailedChecks++
        return $false
    }
}

# Main validation function
function Start-Validation {
    Write-Host "==================================================" -ForegroundColor Magenta
    Write-Host "🚀 Nexus COS Extended - Service Validation" -ForegroundColor Magenta
    Write-Host "==================================================" -ForegroundColor Magenta
    Write-Host ""
    
    Write-Info "Starting validation of all service endpoints..."
    Write-Host ""
    
    # Check if Docker Compose file exists
    if (-not (Test-Path "docker-compose.trae-solo-extended.yml")) {
        Write-Error "Docker Compose file not found. Please run this script from the project root directory."
        exit 1
    }
    
    # Check Docker services first
    Write-Host "📦 Docker Services Health Check" -ForegroundColor Yellow
    Write-Host "--------------------------------" -ForegroundColor Yellow
    Test-DockerService "postgres" "PostgreSQL Database"
    Test-DockerService "redis" "Redis Cache"
    Test-DockerService "nginx" "Nginx Reverse Proxy"
    Test-DockerService "ott-frontend" "OTT Frontend"
    Test-DockerService "puaboverse" "PUABOverse"
    Test-DockerService "creator-hub" "Creator Hub"
    Test-DockerService "v-hollywood-studio" "V-Hollywood Studio"
    Test-DockerService "v-screen" "V-Screen"
    Test-DockerService "v-stage" "V-Stage"
    Test-DockerService "v-caster-pro" "V-Caster Pro"
    Test-DockerService "v-prompter-pro" "V-Prompter Pro"
    Test-DockerService "boom-boom-room-live" "Boom Boom Room Live"
    Test-DockerService "nexus-cos-studio-ai" "Nexus COS Studio AI"
    Test-DockerService "kei-ai-orchestrator" "Kei AI Orchestrator"
    Write-Host ""
    
    # Final checks as specified in requirements
    Write-Host "🎯 Final Endpoint Validation" -ForegroundColor Yellow
    Write-Host "----------------------------" -ForegroundColor Yellow
    
    # 1. Validate OTT Frontend routes → /
    Test-Endpoint "$BaseUrl/" 200 "OTT Frontend Landing Page"
    Test-Endpoint "$BaseUrl/health" 200 "OTT Frontend Health Check"
    
    # 2. Validate V-Hollywood Studio Engine API → /v-suite/hollywood
    Test-Endpoint "$BaseUrl/v-suite/hollywood/health" 200 "V-Hollywood Studio Engine API"
    Test-Endpoint "$BaseUrl/v-suite/hollywood/api/projects" 200 "V-Hollywood Studio Projects API"
    
    # 3. Validate Boom Boom Room Live → /live/boomroom
    Test-Endpoint "$BaseUrl/live/boomroom/health" 200 "Boom Boom Room Live"
    
    # 4. Validate Creator-Hub workspace → /hub
    Test-Endpoint "$BaseUrl/hub/health" 200 "Creator Hub Workspace"
    Test-Endpoint "$BaseUrl/hub/api/projects" 200 "Creator Hub Projects API"
    
    # 5. Validate Studio AI → /studio
    Test-Endpoint "$BaseUrl/studio/health" 200 "Nexus COS Studio AI"
    Test-Endpoint "$BaseUrl/studio/api/workspaces" 200 "Studio AI Workspaces API"
    
    # Additional V-Suite validations
    Write-Host ""
    Write-Host "🎬 V-Suite Extended Validation" -ForegroundColor Yellow
    Write-Host "------------------------------" -ForegroundColor Yellow
    Test-Endpoint "$BaseUrl/v-suite/screen/health" 200 "V-Screen Virtual Backdrops"
    Test-Endpoint "$BaseUrl/v-suite/stage/health" 200 "V-Stage Virtual Stage Builder"
    Test-Endpoint "$BaseUrl/v-suite/caster/health" 200 "V-Caster Pro OTT Broadcast"
    Test-Endpoint "$BaseUrl/v-suite/prompter/health" 200 "V-Prompter Pro AI Teleprompter"
    
    # PUABOverse validation
    Write-Host ""
    Write-Host "🌐 PUABOverse Validation" -ForegroundColor Yellow
    Write-Host "-----------------------" -ForegroundColor Yellow
    Test-Endpoint "$BaseUrl/puaboverse/health" 200 "PUABOverse User Identity"
    Test-Endpoint "$BaseUrl/puaboverse/api/profiles" 200 "PUABOverse Multiworld Profiles"
    Test-Endpoint "$BaseUrl/puaboverse/api/economy" 200 "PUABOverse Virtual Economy"
    
    # Kei AI Integration validation
    Write-Host ""
    Write-Host "🤖 Kei AI Integration Validation" -ForegroundColor Yellow
    Write-Host "--------------------------------" -ForegroundColor Yellow
    Test-Endpoint "$BaseUrl/api/kei-ai/health" 200 "Kei AI Orchestrator"
    Test-Endpoint "$BaseUrl/api/kei-ai/status" 200 "Kei AI Status API"
    
    # Infrastructure validation
    Write-Host ""
    Write-Host "🏗️ Infrastructure Validation" -ForegroundColor Yellow
    Write-Host "----------------------------" -ForegroundColor Yellow
    Test-Endpoint "$BaseUrl/nginx-status" 404 "Nginx Reverse Proxy (404 expected)"
    
    # Generate validation report
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Magenta
    Write-Host "📊 VALIDATION REPORT" -ForegroundColor Magenta
    Write-Host "==================================================" -ForegroundColor Magenta
    Write-Host "Total Checks: $TotalChecks" -ForegroundColor White
    Write-Host "Passed: $PassedChecks" -ForegroundColor Green
    Write-Host "Failed: $FailedChecks" -ForegroundColor Red
    
    if ($FailedChecks -eq 0) {
        Write-Success "🎉 ALL VALIDATIONS PASSED! Nexus COS Extended is ready for production."
        Write-Host ""
        Write-Host "✅ Service Status Summary:" -ForegroundColor Green
        Write-Host "   • OTT Frontend: ✓ Running on /" -ForegroundColor Green
        Write-Host "   • V-Hollywood Studio: ✓ Running on /v-suite/hollywood" -ForegroundColor Green
        Write-Host "   • Boom Boom Room Live: ✓ Running on /live/boomroom" -ForegroundColor Green
        Write-Host "   • Creator Hub: ✓ Running on /hub" -ForegroundColor Green
        Write-Host "   • Studio AI: ✓ Running on /studio" -ForegroundColor Green
        Write-Host "   • V-Suite (All 5 engines): ✓ Unified and operational" -ForegroundColor Green
        Write-Host "   • PUABOverse: ✓ User identity and virtual economy active" -ForegroundColor Green
        Write-Host "   • Kei AI Pipeline: ✓ Orchestration layer functional" -ForegroundColor Green
        Write-Host ""
        Write-Host "🚀 Nexus COS Extended deployment is SUCCESSFUL!" -ForegroundColor Green
        
        # Save success report
        $reportPath = "nexus-cos-validation-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
        @"
Nexus COS Extended - Validation Report
Generated: $(Get-Date)
Status: SUCCESS

Total Checks: $TotalChecks
Passed: $PassedChecks
Failed: $FailedChecks

All services are operational and ready for production use.
"@ | Out-File -FilePath $reportPath -Encoding UTF8
        
        Write-Info "Validation report saved to: $reportPath"
        exit 0
    } else {
        Write-Error "❌ $FailedChecks validation(s) failed. Please check the services and try again."
        Write-Host ""
        Write-Host "🔧 Troubleshooting Tips:" -ForegroundColor Yellow
        Write-Host "   1. Check Docker service logs: docker-compose logs [service-name]" -ForegroundColor Yellow
        Write-Host "   2. Verify environment variables are set correctly" -ForegroundColor Yellow
        Write-Host "   3. Ensure all required ports are available" -ForegroundColor Yellow
        Write-Host "   4. Check Nginx configuration for routing issues" -ForegroundColor Yellow
        Write-Host "   5. Verify Kei AI key is valid and accessible" -ForegroundColor Yellow
        
        # Save failure report
        $reportPath = "nexus-cos-validation-report-FAILED-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
        @"
Nexus COS Extended - Validation Report
Generated: $(Get-Date)
Status: FAILED

Total Checks: $TotalChecks
Passed: $PassedChecks
Failed: $FailedChecks

Please review the failed services and resolve issues before production deployment.
"@ | Out-File -FilePath $reportPath -Encoding UTF8
        
        Write-Info "Validation report saved to: $reportPath"
        exit 1
    }
}

# Run validation
Start-Validation