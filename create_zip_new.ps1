$excludePatterns = @('node_modules', '.git', '__pycache__', 'dist', 'build')

# Get all items to zip, excluding patterns
$itemsToZip = Get-ChildItem -Recurse | Where-Object { 
    $exclude = $false
    foreach ($pattern in $excludePatterns) { 
        if ($_.FullName -match $pattern) { 
            $exclude = $true
            break 
        }
    }
    !$exclude 
}

# Create a new zip file with a different name to avoid lock issues
$zipPath = "nexus-cos-deploy-new.zip"

# Remove existing zip if it exists
if (Test-Path $zipPath) {
    Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
}

# Create the zip file
Write-Host "Creating zip file: $zipPath"
Compress-Archive -Path $itemsToZip.FullName -DestinationPath $zipPath -Force
Write-Host "Zip created successfully: $zipPath"