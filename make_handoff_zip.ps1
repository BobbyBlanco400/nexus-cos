# Nexus COS THIIO Handoff Package Builder (PowerShell)
# This script generates the complete THIIO handoff ZIP bundle for Windows environments

param(
    [string]$OutputDir = "dist",
    [string]$BundleName = "Nexus-COS-THIIO-FullHandoff"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "THIIO Handoff Package Generator (PowerShell)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
$DistDir = Join-Path $ProjectRoot $OutputDir
$ZipFile = Join-Path $DistDir "$BundleName.zip"
$TempDir = Join-Path $DistDir "$BundleName-temp"

# Files to include in the handoff package (23 files)
$FilesToInclude = @(
    "scripts/package-thiio-bundle.sh",
    "make_handoff_zip.ps1",
    ".github/workflows/bundle-thiio-handoff.yml",
    "docs/THIIO-HANDOFF/README.md",
    "docs/THIIO-HANDOFF/architecture/system-overview.md",
    "docs/THIIO-HANDOFF/architecture/service-map.md",
    "deployment-manifest.json",
    "docs/THIIO-HANDOFF/operations/runbook-daily-ops.md",
    "docs/THIIO-HANDOFF/operations/runbook-rollback.md",
    "docs/THIIO-HANDOFF/operations/runbook-monitoring.md",
    "docs/THIIO-HANDOFF/operations/runbook-performance.md",
    "docs/THIIO-HANDOFF/operations/runbook-failover.md",
    "docs/THIIO-HANDOFF/services/README.md",
    "docs/THIIO-HANDOFF/services/service-template.md",
    "docs/THIIO-HANDOFF/services/core-auth.md",
    "docs/THIIO-HANDOFF/modules/README.md",
    "docs/THIIO-HANDOFF/modules/module-template.md",
    "docs/THIIO-HANDOFF/frontend/vite-guide.md",
    "scripts/generate-k8s-configs.sh",
    "PROJECT-OVERVIEW.md",
    "THIIO-ONBOARDING.md",
    "CHANGELOG.md",
    "scripts/run-local"
)

# Create clean directories
Write-Host "Creating working directories..." -ForegroundColor Yellow
if (Test-Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
New-Item -ItemType Directory -Path $DistDir -Force | Out-Null

# Copy files preserving directory structure
Write-Host "Copying handoff files..." -ForegroundColor Yellow
$CopiedFiles = 0
foreach ($file in $FilesToInclude) {
    $sourcePath = Join-Path $ProjectRoot $file
    $destPath = Join-Path $TempDir $file
    
    if (Test-Path $sourcePath) {
        $destDir = Split-Path $destPath -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        $CopiedFiles++
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file (not found)" -ForegroundColor Red
    }
}

# Create the ZIP file
Write-Host ""
Write-Host "Creating ZIP archive..." -ForegroundColor Yellow
if (Test-Path $ZipFile) {
    Remove-Item -Path $ZipFile -Force
}

# Use .NET compression for better compatibility
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($TempDir, $ZipFile, 'Optimal', $false)

# Calculate file size and hash
$ZipInfo = Get-Item $ZipFile
$FileSize = $ZipInfo.Length
$FileSizeKB = [math]::Round($FileSize / 1KB, 2)
$Hash = (Get-FileHash -Path $ZipFile -Algorithm SHA256).Hash

# Generate manifest
$Manifest = @{
    path = "dist/$BundleName.zip"
    sha256 = $Hash
    size_bytes = $FileSize
    generated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    note = "ZIP reproduced from the 23 handoff files provided in this PR. This ZIP will differ from any earlier reported handoff ZIP that included large artifacts not present here."
} | ConvertTo-Json -Depth 10

$ManifestPath = Join-Path $DistDir "$BundleName-sample-manifest.json"
$Manifest | Out-File -FilePath $ManifestPath -Encoding UTF8 -Force

# Cleanup temp directory
Remove-Item -Path $TempDir -Recurse -Force

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Bundle Created Successfully!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Location: " -NoNewline
Write-Host $ZipFile -ForegroundColor Green
Write-Host "Size: " -NoNewline
Write-Host "$FileSizeKB KB ($FileSize bytes)" -ForegroundColor Green
Write-Host "SHA256: " -NoNewline
Write-Host $Hash -ForegroundColor Green
Write-Host "Files: " -NoNewline
Write-Host "$CopiedFiles / $($FilesToInclude.Count)" -ForegroundColor Green
Write-Host "Manifest: " -NoNewline
Write-Host $ManifestPath -ForegroundColor Green
Write-Host ""
Write-Host "Ready for THIIO handoff!" -ForegroundColor Green
Write-Host ""
