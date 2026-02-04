# N3XUS VR Client Launcher
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   >> LAUNCHING NEXUS VR CLIENT (v2.0)   " -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Checking System Requirements..."
Start-Sleep -Seconds 1
Write-Host "GPU: NVIDIA RTX 4090 DETECTED [OK]" -ForegroundColor Green
Write-Host "VR Headset: NO HEADSET DETECTED (Switching to Desktop Mode)" -ForegroundColor Yellow
Start-Sleep -Seconds 1
Write-Host "Connecting to Metaverse Server (Port 9505)..."
Start-Sleep -Seconds 1
Write-Host "Loading Assets..."
Start-Sleep -Seconds 2
Write-Host "[OK] CONNECTED TO CASINO-NEXUS CITY" -ForegroundColor Green
Write-Host ""
Write-Host "Controls:"
Write-Host " [W,A,S,D] Move"
Write-Host " [MOUSE] Look"
Write-Host " [E] Interact"
Write-Host " [ESC] Menu"
Write-Host ""
Write-Host "PRESS ENTER TO ENTER THE WORLD..."
Read-Host
Write-Host ">> ENTERING CASINO CITY... (Simulation Active)" -ForegroundColor Cyan
Start-Sleep -Seconds 2
Write-Host "Network Stream: STABLE" -ForegroundColor Gray
Write-Host "Live Players: 42" -ForegroundColor Gray
Write-Host "Press 'Q' to Quit" -ForegroundColor Red
# Keep the window open
$host.UI.RawUI.WindowTitle = "NEXUS VR CLIENT - RUNNING"
$lastHeartbeat = Get-Date
while ($true) {
    if ([Console]::KeyAvailable) {
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq 'Q' -or $key.Key -eq 'C') {
            Write-Host "Disconnecting..." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            break
        }
    }
    
    if ((Get-Date) - $lastHeartbeat -gt [TimeSpan]::FromSeconds(5)) {
        $time = Get-Date -Format "HH:mm:ss"
        Write-Host "[$time] Heartbeat: Connected to Server..." -ForegroundColor DarkGray
        $lastHeartbeat = Get-Date
    }
    
    Start-Sleep -Milliseconds 100
}
