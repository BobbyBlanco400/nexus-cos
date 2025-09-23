# NEXUS COS Unified Deployment Script
# Created for TRAE Solo Integration

Write-Host "Starting NEXUS COS Unified Deployment..." -ForegroundColor Green

# Check if Docker is running
try {
    docker --version | Out-Null
    Write-Host "Docker is available" -ForegroundColor Green
} catch {
    Write-Host "Docker is not available. Please install Docker first." -ForegroundColor Red
    exit 1
}

# Build and start services
Write-Host "Building and starting services..." -ForegroundColor Yellow
docker-compose down --remove-orphans
docker-compose build --no-cache
docker-compose up -d

# Wait for services to start
Write-Host "Waiting for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check service health
Write-Host "Checking service health..." -ForegroundColor Yellow

$services = @(
    @{name="Frontend"; url="http://localhost:3000"},
    @{name="Admin"; url="http://localhost:3001"},
    @{name="Backend Node"; url="http://localhost:5000"},
    @{name="Backend Python"; url="http://localhost:8000"},
    @{name="TV Radio"; url="http://localhost:8080"},
    @{name="COS Modules"; url="http://localhost:9000"},
    @{name="Nginx Proxy"; url="http://localhost:80"}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.url -TimeoutSec 10 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "[OK] $($service.name) is healthy" -ForegroundColor Green
        } else {
            Write-Host "[WARN] $($service.name) returned status $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[ERROR] $($service.name) is not responding" -ForegroundColor Red
    }
}

Write-Host "`nDeployment completed!" -ForegroundColor Green
Write-Host "Access the application at: http://localhost" -ForegroundColor Cyan
Write-Host "Admin panel at: http://localhost/admin" -ForegroundColor Cyan
Write-Host "TV/Radio at: http://localhost/tv" -ForegroundColor Cyan

Write-Host "`nTo view logs: docker-compose logs -f" -ForegroundColor Gray
Write-Host "To stop services: docker-compose down" -ForegroundColor Gray