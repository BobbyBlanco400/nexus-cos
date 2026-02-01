# N3XUS v-COS: LOCAL SYSTEM LAUNCHER
# For Windows PowerShell Environment
# Target: localhost (Own System)

Write-Host "🚀 INITIATING N3XUS v-COS LOCAL SYSTEM LAUNCH..." -ForegroundColor Cyan
Write-Host "📅 Date: $(Get-Date)"
Write-Host "🔒 Lock ID: N3XUS-LOCK-20260129-FINAL"
Write-Host "--------------------------------------------------------"

# 1. ENVIRONMENT CHECK
Write-Host "🔍 CHECKING ENVIRONMENT..." -ForegroundColor Yellow

if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "✅ Docker installed" -ForegroundColor Green
} else {
    Write-Host "❌ Docker not found! Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

# 2. CORE INFRASTRUCTURE LAUNCH (DOCKER)
Write-Host "--------------------------------------------------------"
Write-Host "🏗️ LAUNCHING FULL STACK (PHASES 1-10)..." -ForegroundColor Yellow
Write-Host "   - Including: V-Prompter Lite (3504) & Mic Bridge (8081)"

# Create necessary directories
New-Item -ItemType Directory -Force -Path "logs", "nginx_logs", "postgres_data" | Out-Null

# Run Docker Compose
docker-compose -f docker-compose.full.yml up -d --build

Write-Host "⏳ Waiting for Services to stabilize (20s)..." -ForegroundColor Cyan
Start-Sleep -Seconds 20

# 3. VERIFICATION
Write-Host "--------------------------------------------------------"
Write-Host "🔎 VERIFYING CRITICAL PORTS..." -ForegroundColor Yellow

$Ports = @(3001, 3002, 3010, 3020, 3030, 3040, 3504, 8081, 8080)
$AllGood = $true

foreach ($Port in $Ports) {
    $Result = Test-NetConnection -ComputerName localhost -Port $Port -InformationLevel Quiet
    if ($Result) {
        Write-Host "   [PASS] Port $Port is responding" -ForegroundColor Green
    } else {
        Write-Host "   [FAIL] Port $Port is NOT responding" -ForegroundColor Red
        $AllGood = $false
    }
}

Write-Host "--------------------------------------------------------"
if ($AllGood) {
    Write-Host "🏆 MISSION COMPLETE: N3XUS v-COS IS LIVE ON LOCAL SYSTEM!" -ForegroundColor Green
    Write-Host "🌍 Dashboard:      http://localhost:8080" -ForegroundColor White
    Write-Host "🎤 Mic Bridge:     http://localhost:8081" -ForegroundColor White
    Write-Host "📱 Prompter Lite:  http://localhost:3504" -ForegroundColor White
    Write-Host "🧠 SuperCore:      http://localhost:3001" -ForegroundColor White
} else {
    Write-Host "⚠️ SYSTEM LAUNCHED WITH WARNINGS. CHECK DOCKER LOGS." -ForegroundColor Yellow
    Write-Host "   Command: docker-compose -f docker-compose.full.yml logs -f" -ForegroundColor Gray
}
Write-Host "========================================================"
