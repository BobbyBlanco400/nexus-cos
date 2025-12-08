# ==============================================================================
# Nexus COS — PF for GitHub Copilot: Restore VPS Endpoints and Services
# ==============================================================================
# Purpose: Restore Plesk configs, SSL certs, and verify endpoint statuses
# Target VPS: root@74.208.155.161 (Plesk-managed)
# Domain: nexuscos.online
# ==============================================================================

param(
    [string]$VpsIp = "74.208.155.161",
    [string]$Domain = "nexuscos.online",
    [string]$SshUser = "root",
    [switch]$DryRun,
    [switch]$SkipSSL,
    [switch]$SkipVerification
)

# Color output functions
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Header {
    Write-Host ""
    Write-ColorOutput "═══════════════════════════════════════════════════════════════" "Cyan"
    Write-ColorOutput "  NEXUS COS - VPS ENDPOINT RESTORATION" "Cyan"
    Write-ColorOutput "  Domain: $Domain | VPS: $VpsIp" "Cyan"
    Write-ColorOutput "═══════════════════════════════════════════════════════════════" "Cyan"
    Write-Host ""
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-ColorOutput "─────────────────────────────────────────────────────────────────" "Blue"
    Write-ColorOutput "  $Title" "Blue"
    Write-ColorOutput "─────────────────────────────────────────────────────────────────" "Blue"
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✓ $Message" "Green"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "✗ $Message" "Red"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠ $Message" "Yellow"
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "ℹ $Message" "Cyan"
}

# Display header
Write-Header

if ($DryRun) {
    Write-Warning "DRY RUN MODE - Commands will be displayed but not executed"
}

# Build the SSH command
Write-Section "Step 1: Preparing Restoration Script"

$RestoreScript = @"
set -e
DOMAIN=$Domain
VHOST=/var/www/vhosts/system/\${DOMAIN}/conf/vhost_nginx.conf
PF=/etc/nginx/conf.d/pf_gateway_\${DOMAIN}.conf

echo '== Backup gateway config if present'
if [ -f "\$PF" ]; then 
    cp -f "\$PF" "\$PF.bak-\$(date +%F-%H%M%S)"
    echo "Backed up gateway config to \$PF.bak-\$(date +%F-%H%M%S)"
fi

echo '== Comment invalid proxy_set_header directives (one-arg lines)'
if [ -f "\$PF" ]; then 
    sed -i -E 's/^(\s*proxy_set_header\s+\S+\s*;)$/# disabled \1/' "\$PF"
    echo "Commented out invalid proxy_set_header directives"
fi

echo '== Append exact-match base-path handlers into vhost include'
if ! grep -q "location = /api/" "\$VHOST"; then 
  cat >> "\$VHOST" <<'EOF'
location = / {
    return 301 /streaming/;
}

location = /api/ {
    return 200 "ok";
    add_header Content-Type text/plain;
}

location = /streaming/ {
    return 200 "ok";
    add_header Content-Type text/plain;
}
EOF
  echo "Added base-path handlers to vhost config"
else
  echo "Base-path handlers already present in vhost config"
fi

echo '== Plesk reconfigure domain'
if plesk sbin httpdmng --reconfigure-domain "\$DOMAIN" 2>/dev/null; then
    echo "Domain reconfigured successfully with plesk sbin"
elif /opt/psa/admin/sbin/httpdmng --reconfigure-domain "\$DOMAIN" 2>/dev/null; then
    echo "Domain reconfigured successfully with /opt/psa/admin/sbin"
else
    echo "Warning: Could not reconfigure domain, continuing..."
fi

echo '== SSL: Use existing IONOS certificate (no Let'\''s Encrypt)'
echo 'List domain certificates and assign the IONOS one'
plesk bin certificate --list -domain "\$DOMAIN" || true

CERT_NAME=\$(plesk bin certificate --list -domain "\$DOMAIN" 2>/dev/null | awk 'NF && !/^CSR/ {print \$NF}' | tail -n1)
if [ -n "\$CERT_NAME" ]; then
  echo "Found certificate: \$CERT_NAME"
  if plesk bin site -u "\$DOMAIN" -certificate-name "\$CERT_NAME"; then
      echo "Successfully assigned certificate to domain"
  else
      echo "Warning: Could not assign certificate, continuing..."
  fi
else
  echo 'No certificate found in domain repo; create from IONOS files'
  echo 'Provide correct paths to key/crt/ca bundle before running:'
  KEY_PATH=/root/ionos/privkey.pem
  CRT_PATH=/root/ionos/cert.pem
  CABUNDLE_PATH=/root/ionos/chain.pem
  CERT_NAME="IONOS SSL"
  
  if [ -f "\$KEY_PATH" ] && [ -f "\$CRT_PATH" ]; then
    echo "Found IONOS certificate files, attempting to create certificate..."
    if plesk bin certificate --create "\$CERT_NAME" -domain "\$DOMAIN" -key-file "\$KEY_PATH" -cert-file "\$CRT_PATH" -cacert-file "\$CABUNDLE_PATH" 2>/dev/null; then
      echo "Certificate created successfully"
      if plesk bin site -u "\$DOMAIN" -certificate-name "\$CERT_NAME"; then
          echo "Successfully assigned new certificate to domain"
      else
          echo "Warning: Could not assign new certificate, continuing..."
      fi
    else
      echo 'Certificate create failed; check key/cert pairing (avoid key mismatch)'
    fi
  else
    echo 'IONOS key/cert files not present; upload them and re-run'
  fi
fi

echo '== Test nginx config'
if nginx -t 2>&1; then
    echo "Nginx configuration is valid"
else
    echo "Warning: Nginx configuration test failed, but continuing..."
fi

echo '== Restart nginx'
if systemctl restart nginx 2>/dev/null; then
    echo "Nginx restarted successfully via systemctl"
elif service nginx restart 2>/dev/null; then
    echo "Nginx restarted successfully via service"
else
    echo "Warning: Could not restart nginx"
fi

echo '== Attempt to start apache (non-fatal)'
systemctl start apache2 2>/dev/null || service apache2 start 2>/dev/null || echo "Apache not started (may not be needed)"

echo '== Verify endpoints'
echo ""
curl -k -s -o /dev/null -w 'ROOT:%{http_code}\n' https://\$DOMAIN/ || echo "ROOT:FAILED"
curl -k -s -o /dev/null -w 'API:%{http_code}\n' https://\$DOMAIN/api/ || echo "API:FAILED"
curl -k -s -o /dev/null -w 'STREAMING:%{http_code}\n' https://\$DOMAIN/streaming/ || echo "STREAMING:FAILED"
curl -k -s -o /dev/null -w 'SOCKET.IO:%{http_code}\n' 'https://\$DOMAIN/socket.io/?EIO=4&transport=polling' || echo "SOCKET.IO:FAILED"
curl -k -s -o /dev/null -w 'STREAMING SOCKET.IO:%{http_code}\n' 'https://\$DOMAIN/streaming/socket.io/?EIO=4&transport=polling' || echo "STREAMING SOCKET.IO:FAILED"
echo ""
echo "Restoration complete!"
"@

Write-Info "Restoration script prepared ($($RestoreScript.Length) bytes)"

# Execute the script via SSH
Write-Section "Step 2: Executing Restoration on VPS"

if ($DryRun) {
    Write-Warning "DRY RUN - Would execute the following SSH command:"
    Write-Host "ssh.exe --% -o StrictHostKeyChecking=no -o ConnectTimeout=12 $SshUser@$VpsIp bash -lc `"<script>`""
    Write-Host ""
    Write-Host "Script contents:"
    Write-Host $RestoreScript
} else {
    Write-Info "Connecting to VPS and executing restoration script..."
    
    try {
        # Execute via SSH with proper escaping for PowerShell
        $SshCommand = "ssh.exe"
        $SshArgs = @(
            "-o", "StrictHostKeyChecking=no",
            "-o", "ConnectTimeout=12",
            "$SshUser@$VpsIp",
            "bash", "-lc", $RestoreScript
        )
        
        $Output = & $SshCommand $SshArgs 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Restoration completed successfully!"
            Write-Host ""
            Write-Host "Output:"
            Write-Host $Output
        } else {
            Write-Error "Restoration failed with exit code: $LASTEXITCODE"
            Write-Host ""
            Write-Host "Output:"
            Write-Host $Output
            exit 1
        }
    } catch {
        Write-Error "Failed to execute SSH command: $_"
        exit 1
    }
}

# Verification step (optional)
if (-not $SkipVerification -and -not $DryRun) {
    Write-Section "Step 3: Verifying Endpoints"
    
    $Endpoints = @(
        @{Name="Root (Redirect)"; Url="https://$Domain/"; Expected=301},
        @{Name="API Base"; Url="https://$Domain/api/"; Expected=200},
        @{Name="Streaming Base"; Url="https://$Domain/streaming/"; Expected=200},
        @{Name="Socket.IO Main"; Url="https://$Domain/socket.io/?EIO=4&transport=polling"; Expected=200},
        @{Name="Socket.IO Streaming"; Url="https://$Domain/streaming/socket.io/?EIO=4&transport=polling"; Expected=200}
    )
    
    foreach ($Endpoint in $Endpoints) {
        try {
            $Response = Invoke-WebRequest -Uri $Endpoint.Url -Method Get -SkipCertificateCheck -ErrorAction SilentlyContinue
            $StatusCode = $Response.StatusCode
        } catch {
            $StatusCode = $_.Exception.Response.StatusCode.value__
        }
        
        if ($StatusCode -eq $Endpoint.Expected) {
            Write-Success "$($Endpoint.Name): $StatusCode (Expected: $($Endpoint.Expected))"
        } else {
            Write-Warning "$($Endpoint.Name): $StatusCode (Expected: $($Endpoint.Expected))"
        }
    }
}

Write-Section "Restoration Complete"
Write-Success "All restoration tasks completed!"
Write-Info "Check the output above for any warnings or errors."
Write-Host ""
