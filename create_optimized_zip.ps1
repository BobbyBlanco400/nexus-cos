$tempDir = "temp-nexus-cos-deploy"
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
New-Item -ItemType Directory -Path $tempDir -Force
Add-Content -Path "zip_log.txt" -Value "Temporary directory created: $tempDir"
function Copy-Excluding {
    param ($source, $dest, $exclude)
    $items = Get-ChildItem $source | Where-Object { $exclude -notcontains $_.Name }
    Add-Content -Path "zip_log.txt" -Value "Processing items in $source : $($items.Count) items found after filtering"
    foreach ($item in $items) {
        $targetPath = Join-Path $dest $item.Name
        if ($item.PSIsContainer) {
            New-Item -ItemType Directory -Path $targetPath
            Add-Content -Path "zip_log.txt" -Value "Created directory: $targetPath"
            Copy-Excluding $item.FullName $targetPath $exclude
        } else {
            Copy-Item $item.FullName $targetPath
            Add-Content -Path "zip_log.txt" -Value "Copied file: $targetPath"
        }
    }
}
Copy-Excluding . $tempDir @("node_modules", ".git", "__pycache__", "dist", "build", "temp-nexus-cos-deploy")
Add-Content -Path "zip_log.txt" -Value "Copy process completed"
try {
    Compress-Archive -Path "$tempDir\*" -DestinationPath "nexus-cos-vps-deploy.zip" -Force
    Add-Content -Path "zip_log.txt" -Value "Zip file created successfully"
} catch {
    Add-Content -Path "zip_log.txt" -Value "Error creating zip: $_"
}
Remove-Item -Recurse -Force $tempDir
Add-Content -Path "zip_log.txt" -Value "Temporary directory removed"
if (Test-Path "nexus-cos-vps-deploy.zip") {
    Add-Content -Path "zip_log.txt" -Value "Zip file exists after creation."
} else {
    Add-Content -Path "zip_log.txt" -Value "Zip file does not exist after creation."
}
Add-Content -Path "zip_log.txt" -Value "Zip creation process completed."