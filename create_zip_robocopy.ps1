$tempPath = [System.IO.Path]::GetTempPath()
$tempFolderName = "nexus-cos-temp-$(Get-Date -Format 'yyyyMMddHHmmss')"
$tempFolder = Join-Path $tempPath $tempFolderName
New-Item -ItemType Directory -Path $tempFolder | Out-Null

$source = 'c:\Users\wecon\Downloads\nexus-cos-main'
$excludeDirs = @('node_modules', '.git', 'dist', 'build', '__pycache__')

robocopy $source $tempFolder /E /XD $excludeDirs

$zipPath = Join-Path $source 'nexus-cos-vps-deploy.zip'

Compress-Archive -Path (Join-Path $tempFolder '*') -DestinationPath $zipPath -Force

Remove-Item -Path $tempFolder -Recurse -Force

Write-Host "Zip created successfully at $zipPath"