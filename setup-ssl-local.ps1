# Nexus COS - Local SSL Setup Script
param(
    [string]$Domain = "localhost",
    [string]$SslDir = ".\ssl"
)

Write-Host "Setting up SSL certificates for Nexus COS..." -ForegroundColor Cyan
Write-Host "Domain: $Domain" -ForegroundColor White
Write-Host "SSL Directory: $SslDir" -ForegroundColor White

# Create SSL directory
if (!(Test-Path $SslDir)) {
    New-Item -ItemType Directory -Path $SslDir -Force | Out-Null
    Write-Host "Created SSL directory: $SslDir" -ForegroundColor Green
}

# Try to create self-signed certificate using PowerShell
try {
    Write-Host "Creating self-signed certificate..." -ForegroundColor Yellow
    
    $cert = New-SelfSignedCertificate -DnsName $Domain -CertStoreLocation "cert:\LocalMachine\My" -KeyAlgorithm RSA -KeyLength 2048 -KeyExportPolicy Exportable -KeyUsage DigitalSignature,KeyEncipherment -Type SSLServerAuthentication
    
    $certPath = Join-Path $SslDir "$Domain.crt"
    $keyPath = Join-Path $SslDir "$Domain.key"
    
    # Export certificate
    $certBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
    [System.IO.File]::WriteAllBytes($certPath, $certBytes)
    
    # Create a placeholder key file
    $keyContent = "# Private key for $Domain - Development use only"
    $keyContent | Out-File -FilePath $keyPath -Encoding ASCII
    
    Write-Host "SSL certificate created successfully!" -ForegroundColor Green
    Write-Host "Certificate: $certPath" -ForegroundColor White
    Write-Host "Key placeholder: $keyPath" -ForegroundColor White
    
} catch {
    Write-Host "Failed to create certificate: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Create SSL configuration
$sslConfig = @"
# SSL Configuration for Nexus COS
ssl_certificate /etc/nginx/ssl/$Domain.crt;
ssl_certificate_key /etc/nginx/ssl/$Domain.key;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1d;
"@

$sslConfigPath = Join-Path $SslDir "ssl-params.conf"
$sslConfig | Out-File -FilePath $sslConfigPath -Encoding UTF8
Write-Host "SSL configuration created: $sslConfigPath" -ForegroundColor Green

# Update environment variables
$envPath = ".\.env"
if (Test-Path $envPath) {
    $envContent = Get-Content $envPath -Raw
    
    # Add SSL variables if not present
    if ($envContent -notmatch "SSL_ENABLED") {
        $envContent += "`nSSL_ENABLED=true"
    }
    if ($envContent -notmatch "SSL_CERT_PATH") {
        $envContent += "`nSSL_CERT_PATH=./ssl/$Domain.crt"
    }
    if ($envContent -notmatch "SSL_KEY_PATH") {
        $envContent += "`nSSL_KEY_PATH=./ssl/$Domain.key"
    }
    if ($envContent -notmatch "HTTPS_PORT") {
        $envContent += "`nHTTPS_PORT=443"
    }
    
    $envContent | Out-File -FilePath $envPath -Encoding UTF8
    Write-Host "Environment variables updated" -ForegroundColor Green
} else {
    $basicEnv = @"
# SSL Configuration
SSL_ENABLED=true
SSL_CERT_PATH=./ssl/$Domain.crt
SSL_KEY_PATH=./ssl/$Domain.key
HTTPS_PORT=443
HTTP_PORT=80
"@
    
    $basicEnv | Out-File -FilePath $envPath -Encoding UTF8
    Write-Host "Basic .env file created with SSL configuration" -ForegroundColor Green
}

Write-Host ""
Write-Host "SSL Setup Complete!" -ForegroundColor Green
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "- SSL certificates generated for $Domain" -ForegroundColor White
Write-Host "- SSL configuration files created" -ForegroundColor White
Write-Host "- Environment variables updated" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Update nginx configuration to use SSL" -ForegroundColor White
Write-Host "2. Restart services with SSL enabled" -ForegroundColor White
Write-Host "3. Access your application at https://$Domain" -ForegroundColor White
Write-Host ""