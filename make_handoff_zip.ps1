# Nexus COS THIIO Handoff Package Builder (PowerShell)
# This script generates the complete THIIO handoff ZIP bundle for Windows environments

param(
    [string]$OutputPath = ".\dist",
    [switch]$SkipCleanup,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Define colors for output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "ℹ $Message" "Cyan"
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✓ $Message" "Green"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠ $Message" "Yellow"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "✗ $Message" "Red"
}

# Print header
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "THIIO Handoff Package Generator" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Get project root
$ProjectRoot = (Get-Location).Path
$BundleName = "Nexus-COS-THIIO-FullHandoff"
$DistDir = Join-Path $ProjectRoot $OutputPath
$BundleDir = Join-Path $DistDir $BundleName
$ZipFile = Join-Path $DistDir "$BundleName.zip"

# Create clean bundle directory
Write-Info "Creating bundle directory..."
if (Test-Path $BundleDir) {
    Remove-Item -Path $BundleDir -Recurse -Force
}
New-Item -Path $BundleDir -ItemType Directory -Force | Out-Null

# Helper function to copy directory safely
function Copy-DirectorySafe {
    param(
        [string]$Source,
        [string]$Destination
    )
    
    if (Test-Path $Source) {
        $DestParent = Split-Path $Destination -Parent
        if (-not (Test-Path $DestParent)) {
            New-Item -Path $DestParent -ItemType Directory -Force | Out-Null
        }
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        return $true
    }
    return $false
}

# Helper function to copy file safely
function Copy-FileSafe {
    param(
        [string]$Source,
        [string]$Destination
    )
    
    if (Test-Path $Source) {
        $DestParent = Split-Path $Destination -Parent
        if (-not (Test-Path $DestParent)) {
            New-Item -Path $DestParent -ItemType Directory -Force | Out-Null
        }
        Copy-Item -Path $Source -Destination $Destination -Force
        return $true
    }
    return $false
}

# Copy documentation
Write-Info "Copying THIIO handoff documentation..."
$DocsSource = Join-Path $ProjectRoot "docs\THIIO-HANDOFF"
$DocsDestination = Join-Path $BundleDir "docs\THIIO-HANDOFF"
if (Copy-DirectorySafe -Source $DocsSource -Destination $DocsDestination) {
    Write-Success "Documentation copied"
} else {
    Write-Warning "Documentation directory not found: $DocsSource"
}

# Copy repository structure
Write-Info "Copying monorepo structure..."
$ReposSource = Join-Path $ProjectRoot "repos\nexus-cos-main"
$ReposDestination = Join-Path $BundleDir "repos\nexus-cos-main"
if (Copy-DirectorySafe -Source $ReposSource -Destination $ReposDestination) {
    Write-Success "Repository structure copied"
} else {
    Write-Warning "Repository structure not found (skipping)"
}

# Copy services
Write-Info "Copying services..."
$ServicesSource = Join-Path $ProjectRoot "services"
$ServicesDestination = Join-Path $BundleDir "services"
if (Copy-DirectorySafe -Source $ServicesSource -Destination $ServicesDestination) {
    Write-Success "Services copied"
} else {
    Write-Warning "Services directory not found (skipping)"
}

# Copy modules
Write-Info "Copying modules..."
$ModulesSource = Join-Path $ProjectRoot "modules"
$ModulesDestination = Join-Path $BundleDir "modules"
if (Copy-DirectorySafe -Source $ModulesSource -Destination $ModulesDestination) {
    Write-Success "Modules copied"
} else {
    Write-Warning "Modules directory not found (skipping)"
}

# Copy frontend
Write-Info "Copying Nexus Stream frontend (Vite + React)..."
$FrontendSource = Join-Path $ProjectRoot "frontend"
$FrontendDestination = Join-Path $BundleDir "frontend"
if (Copy-DirectorySafe -Source $FrontendSource -Destination $FrontendDestination) {
    Write-Success "Frontend copied"
} else {
    Write-Warning "Frontend directory not found (skipping)"
}

# Copy scripts
Write-Info "Copying deployment scripts..."
$ScriptsSource = Join-Path $ProjectRoot "scripts"
$ScriptsDestination = Join-Path $BundleDir "scripts"
if (Test-Path $ScriptsSource) {
    New-Item -Path $ScriptsDestination -ItemType Directory -Force | Out-Null
    Get-ChildItem -Path $ScriptsSource -Filter "*.sh" | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $ScriptsDestination -Force
    }
    Write-Success "Scripts copied"
}

# Copy GitHub workflows
Write-Info "Copying GitHub workflows..."
$WorkflowsSource = Join-Path $ProjectRoot ".github\workflows"
$WorkflowsDestination = Join-Path $BundleDir ".github\workflows"
if (Test-Path $WorkflowsSource) {
    New-Item -Path $WorkflowsDestination -ItemType Directory -Force | Out-Null
    Get-ChildItem -Path $WorkflowsSource -Filter "*.yml" | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $WorkflowsDestination -Force
    }
    Write-Success "Workflows copied"
}

# Copy configuration files
Write-Info "Copying configuration files..."
$ConfigFiles = @(
    "package.json",
    "docker-compose.yml",
    ".gitignore",
    ".dockerignore",
    ".nvmrc"
)

foreach ($file in $ConfigFiles) {
    $SourceFile = Join-Path $ProjectRoot $file
    $DestFile = Join-Path $BundleDir $file
    if (Copy-FileSafe -Source $SourceFile -Destination $DestFile) {
        if ($Verbose) {
            Write-Host "  ✓ Copied $file" -ForegroundColor Gray
        }
    }
}

# Copy root documentation
Write-Info "Copying root documentation..."
$DocFiles = @(
    "README.md",
    "PROJECT-OVERVIEW.md",
    "THIIO-ONBOARDING.md",
    "CHANGELOG.md"
)

foreach ($file in $DocFiles) {
    $SourceFile = Join-Path $ProjectRoot $file
    $DestFile = Join-Path $BundleDir $file
    if (Copy-FileSafe -Source $SourceFile -Destination $DestFile) {
        if ($Verbose) {
            Write-Host "  ✓ Copied $file" -ForegroundColor Gray
        }
    }
}

# Generate manifest file
Write-Info "Generating bundle manifest..."
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
$ManifestContent = @"
# Nexus COS THIIO Handoff Bundle

## Package Contents

This ZIP file contains the complete Nexus COS platform handoff to THIIO.

### Directory Structure

``````
Nexus-COS-THIIO-FullHandoff/
├── docs/
│   └── THIIO-HANDOFF/
│       ├── architecture/        # Architecture documentation
│       ├── deployment/          # Deployment manifests and configs
│       ├── operations/          # Operational runbooks
│       ├── modules/             # Module descriptions (16 files)
│       └── services/            # Service descriptions (43 files)
├── repos/
│   └── nexus-cos-main/          # Full monorepo structure
├── services/                    # All 43 service implementations
├── modules/                     # All 16 module implementations
├── scripts/                     # Deployment and utility scripts
├── .github/
│   └── workflows/               # CI/CD workflows
├── README.md                    # Main README
├── PROJECT-OVERVIEW.md          # Project overview
├── THIIO-ONBOARDING.md          # Onboarding guide
├── CHANGELOG.md                 # Version history
├── package.json                 # Dependencies
└── MANIFEST.md                  # This file
``````

## Quick Start

1. Extract this ZIP file
2. Read ``THIIO-ONBOARDING.md`` first
3. Review ``docs/THIIO-HANDOFF/architecture/architecture-overview.md``
4. Follow deployment guide in ``docs/THIIO-HANDOFF/deployment/``
5. Use scripts in ``scripts/`` for automation

## Services (43)

Complete list of all services with descriptions in ``docs/THIIO-HANDOFF/services/``

## Modules (16)

Complete list of all modules with descriptions in ``docs/THIIO-HANDOFF/modules/``

## Support

For questions or issues during handoff:
- Review operational runbooks in ``docs/THIIO-HANDOFF/operations/``
- Check deployment manifest in ``docs/THIIO-HANDOFF/deployment/``
- Refer to service/module documentation as needed

## Version Information

- Package Date: $Timestamp
- Platform Version: 2.0.0
- Total Services: 43
- Total Modules: 16

"@

$ManifestPath = Join-Path $BundleDir "MANIFEST.md"
$ManifestContent | Out-File -FilePath $ManifestPath -Encoding UTF8
Write-Success "Manifest generated"

# Create the ZIP file
Write-Info "Creating ZIP archive..."
if (Test-Path $ZipFile) {
    Remove-Item -Path $ZipFile -Force
}

# Use .NET compression for better compatibility
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($BundleDir, $ZipFile)

# Calculate file size
$FileSize = (Get-Item $ZipFile).Length
$FileSizeMB = [math]::Round($FileSize / 1MB, 2)

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Bundle Created Successfully!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Location: " -NoNewline
Write-Host $ZipFile -ForegroundColor Green
Write-Host "Size: " -NoNewline
Write-Host "$FileSizeMB MB" -ForegroundColor Green
Write-Host ""
Write-Host "Contents:" -ForegroundColor Cyan
Write-Host "  - Architecture documentation"
Write-Host "  - Deployment manifests"
Write-Host "  - Operations runbooks"
Write-Host "  - 43 service descriptions"
Write-Host "  - 16 module descriptions"
Write-Host "  - Full monorepo structure"
Write-Host "  - CI/CD workflows"
Write-Host "  - Deployment scripts"
Write-Host ""
Write-Host "Ready for THIIO handoff!" -ForegroundColor Green
Write-Host ""

# Cleanup
if (-not $SkipCleanup) {
    Write-Info "Cleaning up temporary files..."
    Remove-Item -Path $BundleDir -Recurse -Force
    Write-Success "Cleanup complete"
}

exit 0
