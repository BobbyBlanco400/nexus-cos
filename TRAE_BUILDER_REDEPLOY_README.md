# TRAE Builder - One-Shot Nexus COS Redeploy Script

## Overview

`trae-builder-redeploy.sh` is a comprehensive, idempotent shell script designed to execute a full redeploy of Nexus COS with minimal manual intervention.

## Purpose

This script automates the complete redeployment process for the n3xuscos.online production environment, integrating all necessary deployment steps, service restarts, configuration updates, and validation checks into a single, self-contained operation.

## Features

- **Self-Contained**: All configuration and logic in a single script
- **Idempotent**: Can be run multiple times safely without side effects
- **Automated**: Requires no manual intervention except initial email configuration
- **Comprehensive Validation**: Tests all critical endpoints after deployment
- **Clear Output**: Echoes every major step with colored, formatted output

## Prerequisites

- Root access (run with `sudo`)
- Repository must exist at `/root/nexus-cos`
- Required tools: `nginx`, `systemctl`, `curl`
- Optional: `pm2` (will be used if available)

## Configuration

Before running the script, you **must** update the email address:

```bash
# Edit the script and change:
export EMAIL="${EMAIL:-your@email.com}"

# To your actual email:
export EMAIL="${EMAIL:-admin@example.com}"
```

## Environment Variables

The script sets the following environment variables:

| Variable | Default Value | Description |
|----------|--------------|-------------|
| `VPS_HOST` | `n3xuscos.online` | VPS hostname |
| `DOMAIN` | `n3xuscos.online` | Primary domain |
| `EMAIL` | `your@email.com` | Contact email (must be changed) |

These can be overridden by exporting them before running the script:

```bash
export EMAIL="admin@example.com"
sudo bash trae-builder-redeploy.sh
```

## Usage

### Standard Deployment

```bash
# 1. Navigate to the repository
cd /root/nexus-cos

# 2. Ensure the script is executable
chmod +x trae-builder-redeploy.sh

# 3. Run the script
sudo bash trae-builder-redeploy.sh
```

### With Custom Configuration

```bash
# Set custom environment variables
export EMAIL="admin@example.com"
export DOMAIN="n3xuscos.online"
export VPS_HOST="n3xuscos.online"

# Run the script
sudo bash trae-builder-redeploy.sh
```

## Deployment Steps

The script executes the following steps in sequence:

### 1. Pre-flight Checks
- Verifies root privileges
- Checks repository existence at `/root/nexus-cos`
- Validates main deployment script presence
- Confirms email configuration
- Verifies required commands are available

### 2. Execute Main Deployment
- Runs `pf-master-deployment.sh` from `/root/nexus-cos`
- Auto-confirms interactive prompts
- Logs output to `/tmp/nexus-deployment.log`

### 3. Restart Backend Service
- Restarts backend Node service using systemctl (`nexus-node-backend`)
- Falls back to alternative service names if primary not found
- Also restarts PM2 processes if PM2 is available
- Waits for services to stabilize

### 4. Configure Nginx API Proxy
- Creates/updates `/etc/nginx/conf.d/nexuscos_api_proxy.conf`
- Configures proxy for `/api` → `http://127.0.0.1:3004`
- Backs up existing configuration with timestamp
- Sets proper headers for WebSocket support

### 5. Reload and Test Nginx
- Tests Nginx configuration syntax with `nginx -t`
- Reloads Nginx using systemctl or service command
- Waits for Nginx to fully reload

### 6. Validate Endpoints
Tests the following endpoints and reports OK or FAILED:
- `/health`
- `/api/system/status`
- `/api/services/test/health`

## Output

The script provides clear, color-coded output for each step:

- **Blue** (▶): Step markers
- **Green** (✓): Success messages
- **Red** (✗): Error messages
- **Cyan** (ℹ): Informational messages

## Exit Codes

- `0`: Successful deployment
- `1`: Deployment failed (with error message)

## Logs

Deployment logs are saved to:
- Main deployment log: `/tmp/nexus-deployment.log`

## Troubleshooting

### Email Not Configured
```
✗ EMAIL environment variable must be set to a valid email address
ℹ Edit this script and change: EMAIL="your@email.com"
```
**Solution**: Edit the script and update the EMAIL variable.

### Repository Not Found
```
✗ Repository not found at /root/nexus-cos
ℹ Expected: /root/nexus-cos
```
**Solution**: Ensure the repository is cloned to `/root/nexus-cos`.

### Backend Service Not Found
```
ℹ Service nexus-node-backend not found (may not be configured)
ℹ Checking for alternative service names...
```
**Solution**: This is informational. The script will attempt alternative service names.

### Endpoint Validation Failed
```
✗ FAILED - /api/system/status (HTTP 502)
```
**Solution**: This may be expected if endpoints are not yet configured. Check service logs.

## Safety Features

1. **Idempotency**: Can be run multiple times without causing issues
2. **Configuration Backup**: Nginx configs are backed up before modification
3. **Error Handling**: Exits on critical errors with clear messages
4. **Validation**: Tests configuration before applying changes
5. **Logging**: All operations are logged for debugging

## Integration

This script is designed to work with the existing Nexus COS deployment infrastructure:

- Calls `pf-master-deployment.sh` for main deployment logic
- Integrates with systemd service management
- Compatible with PM2 process management
- Works with standard Nginx configuration

## Version History

- **v1.0.0** (2025): Initial release
  - Full redeploy automation
  - Environment variable configuration
  - Endpoint validation
  - Nginx proxy configuration

## Support

For issues or questions:
1. Check deployment logs: `/tmp/nexus-deployment.log`
2. Review service status: `systemctl status nexus-node-backend`
3. Check Nginx logs: `journalctl -u nginx -n 100`
4. Verify endpoints manually with `curl`

## See Also

- `pf-master-deployment.sh` - Main deployment script
- `validate-ip-domain-routing.sh` - Routing validation
- `check-backend-logs.sh` - Backend log inspection
