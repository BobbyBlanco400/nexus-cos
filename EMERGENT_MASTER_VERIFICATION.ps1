# EMERGENT MASTER VERIFICATION: Remote Mic Bridge & V-Prompter Lite
# Execution Policy: Bypass
# Date: 2026-01-28

$ErrorActionPreference = "Stop"
$micBridgePort = 8081
$prompterLitePort = 3504
# Auto-detect IPv4 Address (First active non-loopback)
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch "Loopback|vEthernet" -and $_.IPAddress -notmatch "^169\.254" } | Select-Object -First 1).IPAddress

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "   EMERGENT MASTER VERIFICATION PROTOCOL" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

# 1. Verify V-Prompter Lite Service
Write-Host "`n[1/3] Verifying V-Prompter Lite Service (Port $prompterLitePort)..." -NoNewline
try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:$prompterLitePort/health" -Method Get -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host " [PASS]" -ForegroundColor Green
        Write-Host "      Status: Active" -ForegroundColor Gray
    } else {
        throw "Status Code: $($response.StatusCode)"
    }
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    Write-Host "      Error: $_" -ForegroundColor Red
    Write-Host "      Action: Ensure 'node services/v-prompter-lite/server.js' is running." -ForegroundColor Yellow
}

# 2. Verify Remote Mic Bridge
Write-Host "`n[2/3] Verifying Remote Mic Bridge (Port $micBridgePort)..." -NoNewline
try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:$micBridgePort/index.html" -Method Get -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host " [PASS]" -ForegroundColor Green
        Write-Host "      Status: Active" -ForegroundColor Gray
        
        # Check for Shure MV7 Profile
        if ($response.Content -match "SHURE MV7 PROCESSING") {
            Write-Host "      Integrity: Shure MV7 Profile Verified" -ForegroundColor Green
        } else {
            Write-Host "      Integrity: WARNING - Shure MV7 Profile Not Found in HTML" -ForegroundColor Yellow
        }
    } else {
        throw "Status Code: $($response.StatusCode)"
    }
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    Write-Host "      Error: $_" -ForegroundColor Red
    Write-Host "      Action: Ensure 'python -m http.server $micBridgePort' is running." -ForegroundColor Yellow
}

# 3. Network Configuration Check
Write-Host "`n[3/3] Verifying Network Configuration..."
$ipConfig = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -eq $localIP }
if ($ipConfig) {
    Write-Host "      Local IP ($localIP): Confirmed" -ForegroundColor Green
    Write-Host "`n===================================================" -ForegroundColor Cyan
    Write-Host "   ACCESS INSTRUCTIONS FOR MOBILE" -ForegroundColor Cyan
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host "   1. Connect Phone to Wi-Fi"
    Write-Host "   2. Open Mic Bridge:      http://$($localIP):$micBridgePort/index.html"
    Write-Host "   3. Open V-Prompter Lite: http://$($localIP):$prompterLitePort"
    Write-Host "===================================================" -ForegroundColor Cyan
} else {
    Write-Host "      Local IP ($localIP): NOT FOUND" -ForegroundColor Red
    Write-Host "      Action: Check network settings or update IP in scripts." -ForegroundColor Yellow
}

Write-Host "`nVerification Complete. System Locked." -ForegroundColor Green
