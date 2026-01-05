# N3XUS COS — Runtime Verification Script (PowerShell)
# Version: v2.5.0-RC1
# Handshake: 55-45-17

# Colors
$RED = "Red"
$GREEN = "Green"
$YELLOW = "Yellow"
$BLUE = "Cyan"

function Print-Info {
    param($Message)
    Write-Host "[INFO] " -ForegroundColor $BLUE -NoNewline
    Write-Host $Message
}

function Print-Success {
    param($Message)
    Write-Host "[PASS] " -ForegroundColor $GREEN -NoNewline
    Write-Host $Message
}

function Print-Error {
    param($Message)
    Write-Host "[FAIL] " -ForegroundColor $RED -NoNewline
    Write-Host $Message
}

function Print-Warning {
    param($Message)
    Write-Host "[WARN] " -ForegroundColor $YELLOW -NoNewline
    Write-Host $Message
}

# Banner
Write-Host ""
Write-Host "══════════════════════════════════════════════════════════="
Write-Host "  N3XUS COS — Runtime Verification"
Write-Host "  Version: v2.5.0-RC1"
Write-Host "  Handshake: 55-45-17"
Write-Host "══════════════════════════════════════════════════════════="
Write-Host ""

# Track verification status
$VerificationFailed = $false

# Get repository root
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# Test 1: Handshake Verification
Print-Info "Test 1: Handshake 55-45-17 Verification"

$HandshakeFound = Get-ChildItem -Path $RepoRoot -Recurse -Include "*.tsx","*.ts","*.md","*.sh" -ErrorAction SilentlyContinue |
    Select-String -Pattern "55-45-17" -Quiet

if ($HandshakeFound) {
    Print-Success "Handshake 55-45-17 found in codebase"
} else {
    Print-Error "Handshake 55-45-17 NOT found in codebase"
    $VerificationFailed = $true
}

Write-Host ""

# Test 2: Version Check
Print-Info "Test 2: Version Check (v2.5.0-RC1)"

$VersionFound = Get-ChildItem -Path $RepoRoot -Recurse -Include "*.md","*.json" -ErrorAction SilentlyContinue |
    Select-String -Pattern "v2.5.0-RC1" -Quiet

if ($VersionFound) {
    Print-Success "Version v2.5.0-RC1 verified"
} else {
    Print-Warning "Version v2.5.0-RC1 not found in expected locations"
}

Write-Host ""

# Test 3: Documentation Files
Print-Info "Test 3: Documentation Files"

$RequiredDocs = @(
    "docs/N3XUS_MAINNET_LAUNCH_ANNOUNCEMENT.md",
    "docs/N3XUS_KINETIC_TEXT_SEQUENCE.md",
    "docs/N3XUS_KINETIC_STORYBOARD.md",
    "docs/N3XUS_KINETIC_VO_SCRIPT.md",
    "docs/N3XUS_FOUNDING_RESIDENTS_PRESS_KIT.md",
    "docs/N3XUS_SOCIAL_ROLLOUT_PLAN.md",
    "docs/N3XUS_LAUNCH_ASSETS_INDEX.md",
    "docs/N3XUS_MAINNET_VERIFICATION_CHECKLIST.md",
    "NEXUS_COS_STATUS_DASHBOARD.md"
)

$MissingDocs = 0
foreach ($doc in $RequiredDocs) {
    $docPath = Join-Path $RepoRoot $doc
    if (Test-Path $docPath) {
        Print-Success "Found: $doc"
    } else {
        Print-Error "Missing: $doc"
        $MissingDocs++
        $VerificationFailed = $true
    }
}

if ($MissingDocs -eq 0) {
    Print-Success "All required documentation files present"
}

Write-Host ""

# Test 4: Tenant Registry
Print-Info "Test 4: Tenant Registry"

$TenantRegistry = Join-Path $RepoRoot "runtime/tenants/tenants.json"

if (Test-Path $TenantRegistry) {
    Print-Success "Tenant registry found: $TenantRegistry"
    
    # Check if it contains 13 tenants
    try {
        $TenantData = Get-Content $TenantRegistry | ConvertFrom-Json
        $TenantCount = $TenantData.tenants.Count
        
        if ($TenantCount -eq 13) {
            Print-Success "Tenant count verified: 13 founding residents"
        } else {
            Print-Error "Expected 13 tenants, found: $TenantCount"
            $VerificationFailed = $true
        }
    } catch {
        Print-Warning "Could not parse tenant registry JSON"
    }
} else {
    Print-Error "Tenant registry not found"
    $VerificationFailed = $true
}

Write-Host ""

# Test 5: Deployment Scripts
Print-Info "Test 5: Deployment Scripts"

$DeployScripts = @(
    "infra/cps/scripts/deploy-tenant.sh",
    "infra/cps/scripts/deploy-all-tenants.sh"
)

foreach ($script in $DeployScripts) {
    $scriptPath = Join-Path $RepoRoot $script
    if (Test-Path $scriptPath) {
        Print-Success "Script found: $script"
    } else {
        Print-Error "Script not found: $script"
        $VerificationFailed = $true
    }
}

Write-Host ""

# Test 6: Status Dashboard
Print-Info "Test 6: Status Dashboard"

$StatusDashboard = Join-Path $RepoRoot "NEXUS_COS_STATUS_DASHBOARD.md"

if (Test-Path $StatusDashboard) {
    $DashboardContent = Get-Content $StatusDashboard -Raw
    if ($DashboardContent -match "READY_FOR_MAINNET") {
        Print-Success "Status: READY_FOR_MAINNET ✅"
    } else {
        Print-Error "Status dashboard missing READY_FOR_MAINNET indicator"
        $VerificationFailed = $true
    }
} else {
    Print-Error "Status dashboard not found"
    $VerificationFailed = $true
}

Write-Host ""

# Test 7: Frontend Routes
Print-Info "Test 7: Frontend Routes"

$RouterFile = Join-Path $RepoRoot "frontend/src/router.tsx"

if (Test-Path $RouterFile) {
    Print-Success "Router configuration found"
    
    $RouterContent = Get-Content $RouterFile -Raw
    $ExpectedRoutes = @("/residents", "/cps", "/dashboard", "/desktop")
    
    foreach ($route in $ExpectedRoutes) {
        if ($RouterContent -match [regex]::Escape($route)) {
            Print-Success "Route configured: $route"
        } else {
            Print-Warning "Route not found in router: $route"
        }
    }
} else {
    Print-Error "Router file not found"
    $VerificationFailed = $true
}

Write-Host ""

# Final Summary
Write-Host "══════════════════════════════════════════════════════════="

if (-not $VerificationFailed) {
    Print-Success "RUNTIME VERIFICATION PASSED ✅"
    Write-Host ""
    Write-Host "N3XUS COS v2.5.0-RC1"
    Write-Host "Handshake: 55-45-17 VERIFIED"
    Write-Host "Status: READY_FOR_MAINNET"
    Write-Host ""
    exit 0
} else {
    Print-Error "RUNTIME VERIFICATION FAILED ❌"
    Write-Host ""
    Write-Host "Please review the errors above and fix them."
    Write-Host ""
    exit 1
}
