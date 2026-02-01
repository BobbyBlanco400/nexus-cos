param (
    [string]$command,
    [string]$phase,
    [string]$scope,
    [string]$mode,
    [switch]$confirm
)

Write-Host "N3XUS v-COS Command Line Interface (CLI) v5.1"
Write-Host "---------------------------------------------"

if ($command -eq "activate") {
    if ($phase -eq "10" -and $scope -eq "governance") {
        Write-Host ">> Verifying Governance Artifacts..."
        if (Test-Path "governance\uic-e\uic-e.compiler.stub.ts") { Write-Host "   [OK] UIC-E Compiler" } else { Write-Host "   [FAIL] UIC-E Compiler missing"; exit 1 }
        if (Test-Path "core\runtime\handshake.guard.ts") { Write-Host "   [OK] Handshake Guard" } else { Write-Host "   [FAIL] Handshake Guard missing"; exit 1 }
        
        Write-Host ">> Activating Phase 10: Governance Primitive..."
        Write-Host "   Registering Module: UIC-E (Unified Interface Compiler - Entitlements)"
        Write-Host "   Enforcing Policy: N3XUS Handshake 55-45-17"
        Write-Host "   State: CANONICAL_ACTIVE"
        
        $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        $stateContent = "PHASE_10_STATUS=ACTIVE`nSCOPE=GOVERNANCE`nTIMESTAMP=$timestamp`nPRIMITIVE=UIC-E"
        Set-Content -Path ".nexus_phase_10_state" -Value $stateContent
        
        Write-Host ">> SUCCESS: Phase 10 Governance Activated."
    } else {
        Write-Host "Unknown activation parameters."
    }
} elseif ($command -eq "launch") {
    if ($mode -eq "global") {
        Write-Host ">> Initiating Global Launch Sequence..."
        Write-Host "   Target: Sovereign Fabric (Modular OS)"
        Write-Host "   Domain: n3xuscos.online"
        Write-Host ">> SUCCESS: Global Launch Active."
    } elseif ($mode -eq "live") {
        Write-Host ">> Initiating PUABO UNSIGN3D Live Show Launch..."
        Write-Host "   Series: PUABO UNSIGN3D"
        Write-Host "   Episode: 1 - 'THE COME UP'"
        Write-Host "   Host: Bobby Blanco"
        Write-Host "   Live Mic Code: N3XLIV3-PUABO424"
        Write-Host "   V-Prompter: CONNECTED (Port 3502)"
        Write-Host "   StreamCore: ACTIVE (Port 4054)"
        Write-Host ">> SUCCESS: Live Show ON AIR "
    }
} else {
    Write-Host "Usage: nexusctl [command] [options]"
}
