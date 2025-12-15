# Nexus COS Production Launch Gate - Usage Guide

## Overview
The `pf-master-launch-gate.sh` script is a production-ready launch validation tool that performs comprehensive health checks to ensure the Nexus COS platform is fully operational and ready for production traffic.

## Key Features
✅ **Active vhost verification**: Confirms NGINX is configured for the production domain  
✅ **NGINX validation**: Tests and reloads NGINX configuration safely  
✅ **Backend health checks**: Validates local backend API responsiveness  
✅ **Public API verification**: Confirms public-facing API is accessible  
✅ **HTTP/2 validation**: Ensures HTTP/2 is active for optimal performance  
✅ **Fail-fast behavior**: Immediately stops on any critical failure  
✅ **Clear status reporting**: Provides visual feedback on each validation step  

## Prerequisites
- NGINX installed and configured
- Backend service running on port 3000
- Domain `nexuscos.online` configured and pointing to server
- SSL/TLS certificates properly configured
- `curl` command available
- Root/sudo access for NGINX operations

## Usage Examples

### Basic Execution
```bash
# Run the production launch gate
./pf-master-launch-gate.sh
```

### Expected Output (Success)
```
==============================================
🚀 NEXUS COS — PRODUCTION LAUNCH GATE
==============================================
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
✅ Active vhost confirmed
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
✅ NGINX validated and reloaded
✅ Backend responding locally
✅ Public API proxy OK (HTTP 200)
✅ HTTP/2 active
==============================================
🎉 NEXUS COS STATUS: ✅ PRODUCTION GREEN
==============================================
```

### SSH Deployment to Remote Server
```bash
# Copy script to server
scp pf-master-launch-gate.sh root@nexuscos.online:/root/

# Execute on remote server
ssh root@nexuscos.online "./pf-master-launch-gate.sh"
```

## Validation Steps

The script performs the following checks in order:

### 1. Active vhost Check
Confirms that NGINX has an active server block configured for `nexuscos.online`
- **Command**: `nginx -T | grep -q "server_name nexuscos.online"`
- **Success**: Vhost configuration found
- **Failure**: Exits with error if domain is not configured

### 2. NGINX Validation
Tests NGINX configuration syntax and safely reloads the service
- **Commands**: `nginx -t` and `systemctl reload nginx`
- **Success**: Configuration is valid and reloaded
- **Failure**: Exits if configuration has syntax errors

### 3. Backend Local Health
Verifies the backend API is responding on localhost
- **Endpoint**: `http://127.0.0.1:3000/status`
- **Success**: Receives successful response
- **Failure**: Exits if backend is not responding

### 4. Public API Health
Confirms the public-facing API is accessible via HTTPS
- **Endpoint**: `https://nexuscos.online/api/status`
- **Expected**: HTTP 200 status code
- **Failure**: Exits if any other status code is returned

### 5. HTTP/2 Verification
Validates that HTTP/2 protocol is active
- **Method**: Uses curl's `%{http_version}` format specifier
- **Expected**: HTTP version "2"
- **Failure**: Exits if HTTP/2 is not active

## Configuration Variables

```bash
DOMAIN="nexuscos.online"           # Production domain
API_LOCAL="http://127.0.0.1:3000/status"  # Local backend health endpoint
API_PUBLIC="https://${DOMAIN}/api/status" # Public API endpoint
LOG_BACKEND="/var/log/nexus-cos.log"      # Backend log file location
LOG_NGINX="/var/log/nginx/error.log"      # NGINX error log location
```

## Exit Codes
- **0**: All validation checks passed - production green
- **1**: One or more validation checks failed

## Error Handling
The script uses `set -euo pipefail` for strict error handling:
- **-e**: Exit immediately if any command fails
- **-u**: Treat unset variables as an error
- **-o pipefail**: Return exit code of the last failed command in a pipeline

## Integration with CI/CD

### GitHub Actions Example
```yaml
- name: Production Launch Gate
  run: |
    ssh root@nexuscos.online "./pf-master-launch-gate.sh"
```

### Cron Job for Monitoring
```bash
# Run every hour to monitor production status
0 * * * * /root/pf-master-launch-gate.sh >> /var/log/launch-gate.log 2>&1
```

## Troubleshooting

### vhost Check Failure
- Verify NGINX configuration files contain `server_name nexuscos.online`
- Check: `nginx -T | grep server_name`

### Backend Not Responding
- Check backend service is running: `systemctl status nexus-cos`
- Verify port 3000 is listening: `netstat -tuln | grep 3000`
- Check backend logs: `tail -f /var/log/nexus-cos.log`

### Public API Failure
- Verify DNS is resolving correctly: `dig nexuscos.online`
- Check SSL certificates: `openssl s_client -connect nexuscos.online:443`
- Review NGINX error logs: `tail -f /var/log/nginx/error.log`

### HTTP/2 Not Active
- Confirm SSL/TLS is configured (HTTP/2 requires HTTPS)
- Verify NGINX is compiled with HTTP/2 support: `nginx -V | grep http_v2`
- Check NGINX configuration includes `listen 443 ssl http2;`

## Related Scripts
- `health-check-pf-v1.2.sh` - Comprehensive health monitoring
- `bulletproof-pf-validate.sh` - Full deployment validation
- `launch-readiness-check.sh` - Pre-launch assessment
- `nexus-cos-launch-validator.sh` - Infrastructure validation

## Best Practices
1. Run before deploying new code to production
2. Include in automated deployment pipelines
3. Use for production health monitoring
4. Keep script on production server for quick validation
5. Monitor script execution logs for trends

## Author
Based on production validation requirements for Nexus COS v2025

## Version
1.0 - Production Launch Gate

## Last Updated
December 15, 2025
