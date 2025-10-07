# PF VPS Deploy - PowerShell Deployment Script

## Overview

`pf-vps-deploy.ps1` is a PowerShell script for deploying Nexus COS to production VPS from Windows machines. It supports both OpenSSH and PuTTY for SSH connectivity and provides automated deployment with validation.

## Features

- ✅ Non-interactive SSH deployment
- ✅ Automatic service validation
- ✅ Streaming route verification
- ✅ Deployment log capture
- ✅ OpenSSH and PuTTY support
- ✅ Production environment validation
- ✅ Health check automation
- ✅ Docker service status monitoring

## Prerequisites

### Windows Requirements

**Option 1: OpenSSH (Recommended)**
- Windows 10/11 with OpenSSH Client installed
- Or install via: `Settings → Apps → Optional Features → OpenSSH Client`

**Option 2: PuTTY**
- Download from: https://www.putty.org/
- Ensure `plink.exe` is in PATH or provide full path

### SSH Key Setup

Before using the script, ensure your SSH key is authorized on the VPS:

```powershell
# Option 1: Copy key using ssh-copy-id (if available)
cat vps_key.pub | ssh root@74.208.155.161 "cat >> /root/.ssh/authorized_keys"

# Option 2: Manual copy
$key = Get-Content vps_key.pub
ssh root@74.208.155.161 "echo '$key' >> /root/.ssh/authorized_keys"

# Option 3: SSH in and paste manually
ssh root@74.208.155.161
# Then paste key content into /root/.ssh/authorized_keys
```

## Usage

### Basic Deployment

```powershell
# Navigate to repository
cd C:\path\to\nexus-cos

# Run with default settings (OpenSSH)
.\scripts\pf-vps-deploy.ps1
```

### Custom VPS and Domain

```powershell
.\scripts\pf-vps-deploy.ps1 `
  -VpsIp "74.208.155.161" `
  -Domain "nexuscos.online" `
  -SshUser "root"
```

### With SSH Key

```powershell
.\scripts\pf-vps-deploy.ps1 `
  -VpsIp "74.208.155.161" `
  -Domain "nexuscos.online" `
  -KeyFile "C:\Users\YourName\.ssh\vps_key"
```

### Using PuTTY

```powershell
.\scripts\pf-vps-deploy.ps1 `
  -VpsIp "74.208.155.161" `
  -Domain "nexuscos.online" `
  -UsePlink
```

### Validation Only (No Deployment)

```powershell
# Just check if services are running
.\scripts\pf-vps-deploy.ps1 -ValidateOnly
```

### Complete Example

```powershell
# Full deployment with all options
.\scripts\pf-vps-deploy.ps1 `
  -VpsIp "74.208.155.161" `
  -Domain "nexuscos.online" `
  -SshUser "root" `
  -KeyFile "C:\Users\YourName\.ssh\nexus_vps_key" `
  -RepoUrl "https://github.com/BobbyBlanco400/nexus-cos.git"
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `VpsIp` | String | 74.208.155.161 | VPS IP address |
| `Domain` | String | nexuscos.online | Production domain name |
| `SshUser` | String | root | SSH username |
| `KeyFile` | String | (empty) | Path to SSH private key |
| `RepoUrl` | String | https://github.com/BobbyBlanco400/nexus-cos.git | Repository URL |
| `ValidateOnly` | Switch | false | Only validate, don't deploy |
| `UsePlink` | Switch | false | Use PuTTY plink instead of OpenSSH |

## What the Script Does

### 1. Prerequisites Check
- ✓ Verifies SSH client (OpenSSH or PuTTY)
- ✓ Validates SSH key file exists
- ✓ Tests VPS connectivity
- ✓ Checks network accessibility

### 2. VPS Deployment
- Downloads `pf-final-deploy.sh` from GitHub
- Executes deployment script on VPS
- Captures deployment logs
- Monitors deployment progress

### 3. Service Validation
Tests the following endpoints:
- Frontend: `https://nexuscos.online/`
- Admin: `https://nexuscos.online/admin`
- API: `https://nexuscos.online/api`
- Health: `https://nexuscos.online/health`
- V-Screen: `https://nexuscos.online/v-suite/screen`
- V-Screen Alt: `https://nexuscos.online/v-screen`
- V-Hollywood: `https://nexuscos.online/v-suite/hollywood`
- V-Prompter: `https://nexuscos.online/v-suite/prompter`
- V-Caster: `https://nexuscos.online/v-suite/caster`
- V-Stage: `https://nexuscos.online/v-suite/stage`

### 4. Streaming Routes Validation
- Tests all V-Suite streaming endpoints
- Validates WebSocket connections
- Checks service health responses

### 5. Service Status
- Lists all running Docker containers
- Shows service health status
- Displays container logs summary

## Output Example

```
═══════════════════════════════════════════════════════════════
  NEXUS COS - PF VPS DEPLOYMENT (POWERSHELL)
═══════════════════════════════════════════════════════════════

ℹ Target VPS: 74.208.155.161 (nexuscos.online)
ℹ SSH User: root
ℹ Repository: https://github.com/BobbyBlanco400/nexus-cos.git

═══════════════════════════════════════════════════════════════
  1. CHECKING PREREQUISITES
═══════════════════════════════════════════════════════════════

ℹ Checking for OpenSSH client...
✓ OpenSSH found: C:\Windows\System32\OpenSSH\ssh.exe
✓ SSH key file found: C:\Users\YourName\.ssh\vps_key
ℹ Testing VPS connectivity...
✓ VPS is reachable: 74.208.155.161

═══════════════════════════════════════════════════════════════
  2. DEPLOYING TO VPS
═══════════════════════════════════════════════════════════════

ℹ Starting deployment on VPS...
ℹ This may take several minutes...
✓ Deployment script executed

═══════════════════════════════════════════════════════════════
  3. VALIDATING DEPLOYMENT
═══════════════════════════════════════════════════════════════

ℹ Testing Frontend: https://nexuscos.online/
✓ Frontend is accessible (Status: 200)
ℹ Testing Admin: https://nexuscos.online/admin
✓ Admin is accessible (Status: 200)
...

═══════════════════════════════════════════════════════════════
  DEPLOYMENT COMPLETE
═══════════════════════════════════════════════════════════════

✓ Nexus COS has been deployed to nexuscos.online
ℹ Access the platform at: https://nexuscos.online
ℹ V-Screen: https://nexuscos.online/v-suite/screen
ℹ Admin Panel: https://nexuscos.online/admin
```

## Troubleshooting

### SSH Connection Failed

**Error**: `Cannot connect to VPS`

**Solutions**:
1. Check VPS IP is correct
2. Verify firewall allows SSH (port 22)
3. Test manual connection: `ssh root@74.208.155.161`
4. Verify SSH key is authorized on VPS

### OpenSSH Not Found

**Error**: `OpenSSH not found`

**Solutions**:
1. Install OpenSSH Client from Windows Optional Features
2. Use PuTTY with `-UsePlink` flag
3. Add OpenSSH to PATH if installed elsewhere

### Permission Denied

**Error**: `Permission denied (publickey)`

**Solutions**:
1. Verify SSH key is in VPS authorized_keys
2. Check key file permissions (should be restricted)
3. Ensure using correct private key (not .pub file)

### Deployment Script Failed

**Error**: `Deployment failed`

**Solutions**:
1. Check VPS has Docker installed
2. Verify internet connectivity on VPS
3. Review deployment logs on VPS: `/tmp/nexus-deploy.log`
4. Manually SSH and run deployment script

### Service Validation Failed

**Error**: `V-Screen not accessible`

**Solutions**:
1. Wait 30-60 seconds for services to stabilize
2. Check Docker containers are running: `docker ps`
3. Review service logs: `docker logs vscreen-hollywood`
4. Verify Nginx configuration: `sudo nginx -t`

## Advanced Usage

### Custom Deployment Script

```powershell
# Use custom deployment script URL
.\scripts\pf-vps-deploy.ps1 `
  -RepoUrl "https://github.com/YourOrg/custom-fork.git"
```

### Multiple VPS Deployment

```powershell
# Deploy to multiple VPS servers
$vpsServers = @("74.208.155.161", "192.168.1.100")

foreach ($vps in $vpsServers) {
    Write-Host "Deploying to $vps..."
    .\scripts\pf-vps-deploy.ps1 -VpsIp $vps -Domain "nexuscos-$vps.online"
}
```

### Automated Deployment Script

```powershell
# Create automated deployment script
param([switch]$Production)

if ($Production) {
    $confirm = Read-Host "Deploy to PRODUCTION? (yes/no)"
    if ($confirm -ne "yes") { exit }
}

.\scripts\pf-vps-deploy.ps1 `
  -VpsIp "74.208.155.161" `
  -Domain "nexuscos.online" `
  -KeyFile "C:\secure\keys\production_vps_key"

# Send notification
Write-Host "✅ Deployment complete! Check logs for details."
```

## Security Best Practices

1. **SSH Keys**: Use SSH keys, not passwords
2. **Key Storage**: Keep private keys in secure location
3. **Key Permissions**: Restrict key file access (chmod 600 on Linux)
4. **Separate Keys**: Use different keys for dev/staging/production
5. **Key Rotation**: Regularly rotate SSH keys
6. **Audit Logs**: Review deployment logs regularly

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup SSH Key
        run: |
          mkdir -p $HOME\.ssh
          echo "${{ secrets.VPS_SSH_KEY }}" > $HOME\.ssh\vps_key
          
      - name: Deploy to VPS
        run: |
          .\scripts\pf-vps-deploy.ps1 `
            -VpsIp "${{ secrets.VPS_IP }}" `
            -Domain "nexuscos.online" `
            -KeyFile "$HOME\.ssh\vps_key"
```

## Support

For issues or questions:
- Review VPS_DEPLOYMENT_GUIDE.md
- Check deployment logs: `/tmp/nexus-deploy.log`
- Review service logs: `docker compose logs`
- Consult Nginx error logs: `/var/log/nginx/error.log`

## Related Documentation

- **VPS Deployment Guide**: `../VPS_DEPLOYMENT_GUIDE.md`
- **PF Final Deploy Script**: `pf-final-deploy.sh`
- **Validation Script**: `validate-streaming-routes.sh`
- **Nginx Configuration**: `../NGINX_CONFIGURATION_README.md`
- **Architecture**: `../PF_ARCHITECTURE.md`
