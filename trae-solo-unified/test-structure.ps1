# NEXUS COS Structure Validation Script
# Tests the unified project structure without requiring Docker

Write-Host "Starting NEXUS COS Structure Validation..." -ForegroundColor Green

$errors = 0
$warnings = 0

# Test project structure
Write-Host "Checking project structure..." -ForegroundColor Yellow

$requiredDirs = @(
    "frontend",
    "admin", 
    "backend-node",
    "backend-python",
    "tv-radio",
    "cos-modules",
    "nginx",
    "nginx/ssl"
)

foreach ($dir in $requiredDirs) {
    if (Test-Path $dir) {
        Write-Host "[OK] Directory exists: $dir" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Missing directory: $dir" -ForegroundColor Red
        $errors++
    }
}

# Test configuration files
Write-Host "`nChecking configuration files..." -ForegroundColor Yellow

$requiredFiles = @(
    "docker-compose.yml",
    "nginx/nginx.conf",
    "trae-solo.yaml",
    "README.md",
    "deploy.ps1",
    "production-deploy.ps1"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "[OK] File exists: $file" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Missing file: $file" -ForegroundColor Red
        $errors++
    }
}

# Test Dockerfiles
Write-Host "`nChecking Dockerfiles..." -ForegroundColor Yellow

$dockerfiles = @(
    "frontend/Dockerfile",
    "admin/Dockerfile",
    "backend-node/Dockerfile",
    "backend-python/Dockerfile",
    "tv-radio/Dockerfile",
    "cos-modules/Dockerfile"
)

foreach ($dockerfile in $dockerfiles) {
    if (Test-Path $dockerfile) {
        Write-Host "[OK] Dockerfile exists: $dockerfile" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Missing Dockerfile: $dockerfile" -ForegroundColor Red
        $errors++
    }
}

# Test SSL certificates
Write-Host "`nChecking SSL certificates..." -ForegroundColor Yellow

if (Test-Path "nginx/ssl/nexuscos.crt" -and Test-Path "nginx/ssl/nexuscos.key") {
    Write-Host "[OK] SSL certificates present" -ForegroundColor Green
    
    $certContent = Get-Content "nginx/ssl/nexuscos.crt" -Raw
    if ($certContent -like "*placeholder*") {
        Write-Host "[WARN] Using placeholder SSL certificates" -ForegroundColor Yellow
        $warnings++
    }
} else {
    Write-Host "[ERROR] SSL certificates missing" -ForegroundColor Red
    $errors++
}

# Test Docker Compose configuration
Write-Host "`nValidating Docker Compose configuration..." -ForegroundColor Yellow

if (Test-Path "docker-compose.yml") {
    $composeContent = Get-Content "docker-compose.yml" -Raw
    
    $services = @("frontend", "admin", "backend-node", "backend-python", "tv-radio", "cos-modules", "nginx")
    
    foreach ($service in $services) {
        if ($composeContent -like "*${service}:*") {
            Write-Host "[OK] Service defined in docker-compose.yml: $service" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] Service missing from docker-compose.yml: $service" -ForegroundColor Red
            $errors++
        }
    }
}

# Test Nginx configuration
Write-Host "`nValidating Nginx configuration..." -ForegroundColor Yellow

if (Test-Path "nginx/nginx.conf") {
    $nginxContent = Get-Content "nginx/nginx.conf" -Raw
    
    if ($nginxContent -like "*ssl_certificate*") {
        Write-Host "[OK] SSL configuration found in nginx.conf" -ForegroundColor Green
    } else {
        Write-Host "[WARN] No SSL configuration in nginx.conf" -ForegroundColor Yellow
        $warnings++
    }
    
    if ($nginxContent -like "*nexuscos.online*") {
        Write-Host "[OK] Domain configuration found in nginx.conf" -ForegroundColor Green
    } else {
        Write-Host "[WARN] No domain configuration in nginx.conf" -ForegroundColor Yellow
        $warnings++
    }
}

# Test TRAE Solo configuration
Write-Host "`nValidating TRAE Solo configuration..." -ForegroundColor Yellow

if (Test-Path "trae-solo.yaml") {
    $traeContent = Get-Content "trae-solo.yaml" -Raw
    
    if ($traeContent -like "*nexuscos.online*") {
        Write-Host "[OK] Domain configuration found in trae-solo.yaml" -ForegroundColor Green
    } else {
        Write-Host "[WARN] No domain configuration in trae-solo.yaml" -ForegroundColor Yellow
        $warnings++
    }
}

# Summary
Write-Host "`n" + "="*60 -ForegroundColor Cyan
Write-Host "NEXUS COS STRUCTURE VALIDATION COMPLETE" -ForegroundColor Green
Write-Host "="*60 -ForegroundColor Cyan

Write-Host "`nValidation Results:" -ForegroundColor White
Write-Host "- Errors: $errors" -ForegroundColor $(if($errors -eq 0) {"Green"} else {"Red"})
Write-Host "- Warnings: $warnings" -ForegroundColor $(if($warnings -eq 0) {"Green"} else {"Yellow"})

if ($errors -eq 0) {
    Write-Host "`n[SUCCESS] Project structure is valid and ready for deployment!" -ForegroundColor Green
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host "1. Install Docker and Docker Compose" -ForegroundColor Gray
    Write-Host "2. Run: .\deploy.ps1 (for local testing)" -ForegroundColor Gray
    Write-Host "3. Run: .\production-deploy.ps1 (for production)" -ForegroundColor Gray
} else {
    Write-Host "`n[FAILED] Project structure has $errors error(s) that need to be fixed." -ForegroundColor Red
}

if ($warnings -gt 0) {
    Write-Host "`n[INFO] There are $warnings warning(s) that should be addressed for production use." -ForegroundColor Yellow
}

Write-Host "`nValidation completed at $(Get-Date)" -ForegroundColor Gray