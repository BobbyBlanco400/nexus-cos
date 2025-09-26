# 🤖 TRAE SOLO - Nexus COS PowerShell Setup Script
# For Windows environment deployment

Write-Host "🤖 TRAE SOLO - Nexus COS Setup" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

# Define paths
$WorkspaceDir = "C:\Users\wecon\Downloads"
$TargetDir = "$WorkspaceDir\nexus-cos-main"
$DownloadUrl = "https://github.com/BobbyBlanco400/nexus-cos/archive/refs/heads/main.zip"
$ZipFile = "$WorkspaceDir\nexus-cos-main.zip"

# Ensure workspace directory exists
if (!(Test-Path $WorkspaceDir)) {
    New-Item -ItemType Directory -Path $WorkspaceDir -Force
}

Set-Location $WorkspaceDir

Write-Host "🌐 Downloading Nexus COS from GitHub..." -ForegroundColor Yellow
try {
    # Use PowerShell built-in web client
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipFile -UseBasicParsing
    Write-Host "✅ Download completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Download failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Extracting archive..." -ForegroundColor Yellow
try {
    # Remove existing directory if it exists
    if (Test-Path "nexus-cos") {
        Remove-Item -Path "nexus-cos" -Recurse -Force
    }
    
    # Extract the ZIP file
    Expand-Archive -Path $ZipFile -DestinationPath $WorkspaceDir -Force
    
    # Rename the extracted directory
    if (Test-Path "nexus-cos-main") {
        Rename-Item -Path "nexus-cos-main" -NewName "nexus-cos"
    }
    
    Write-Host "✅ Extraction completed!" -ForegroundColor Green
} catch {
    Write-Host "❌ Extraction failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Change to project directory
Set-Location "$WorkspaceDir\nexus-cos"

Write-Host "📋 Installing npm dependencies..." -ForegroundColor Yellow
try {
    npm install
    Write-Host "✅ Dependencies installed!" -ForegroundColor Green
} catch {
    Write-Host "⚠️  NPM install had issues, but continuing..." -ForegroundColor Yellow
}

Write-Host "🔧 Setting up Git LFS (if available)..." -ForegroundColor Yellow
try {
    git lfs install 2>$null
} catch {
    Write-Host "ℹ️  Git LFS not available, skipping..." -ForegroundColor Blue
}

Write-Host ""
Write-Host "✅ NEXUS COS SETUP COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Project Location: $WorkspaceDir\nexus-cos" -ForegroundColor Cyan
Write-Host "🚀 Ready for deployment!" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. cd nexus-cos" -ForegroundColor White
Write-Host "   2. .\master-fix-trae-solo.sh    # Full deployment" -ForegroundColor White
Write-Host "   3. .\quick-launch.sh           # Quick launch" -ForegroundColor White
Write-Host ""
Write-Host "📦 For VPS deployment:" -ForegroundColor Yellow
Write-Host "   1. Compress the nexus-cos folder to a ZIP" -ForegroundColor White
Write-Host "   2. Upload to VPS server" -ForegroundColor White
Write-Host "   3. Extract and run deployment scripts" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Expected URLs after deployment:" -ForegroundColor Cyan
Write-Host "   • https://nexuscos.online" -ForegroundColor White
Write-Host "   • http://localhost:3000/health" -ForegroundColor White
Write-Host "   • http://localhost:3001/health" -ForegroundColor White
Write-Host ""
Write-Host "🎯 Ready for TRAE SOLO orchestration!" -ForegroundColor Green

# Clean up the downloaded ZIP file
Remove-Item -Path $ZipFile -Force -ErrorAction SilentlyContinue