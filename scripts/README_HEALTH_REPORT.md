# Nexus COS Health Report Script

## Overview

The `nexus_health_report.sh` script provides comprehensive health monitoring for Nexus COS infrastructure, including:
- Main site health check (https://n3xuscos.online/health)
- Beta site health check (https://beta.n3xuscos.online/health)
- Database connectivity verification
- Clear exit codes for automation and monitoring

## Features

### 1. Proper URL Quoting and Spacing
- **MAIN_URL**: `"https://n3xuscos.online/health"`
- **BETA_URL**: `"https://beta.n3xuscos.online/health"`

All URLs are properly quoted and spaced to prevent shell parsing issues.

### 2. Robust .env Path Resolution

The script intelligently resolves the `.env` file location using the following priority:

1. **ENV_PATH environment variable** (if set)
2. **Server path**: `/opt/nexus-cos/.env` (preferred on production server)
3. **Local path**: Relative to script location (development fallback)

### 3. Curl Timeouts and Safe Defaults

- **Connection timeout**: 10 seconds
- **Maximum time**: 15 seconds
- **Safe defaults**: Returns clear error codes on timeout

### 4. Clear Exit Codes

The script uses standardized exit codes for easy integration with monitoring systems:

| Exit Code | Status | Description |
|-----------|--------|-------------|
| 0 | SUCCESS | All systems operational |
| 1 | HEALTH_FAILED | Health endpoints not responding |
| 2 | DB_FAILED | Health endpoints OK, but database unreachable |
| 3 | BOTH_FAILED | Both health endpoints and database are down |

### 5. Database Readiness Check

Performs direct database connectivity check:
- Uses `DB_HOST` and `DB_PORT` from `.env` (defaults: localhost:5432)
- Checks TCP connectivity to PostgreSQL port
- Reports clear status and errors

## Usage

### Local Development

```bash
bash scripts/nexus_health_report.sh
```

### Production Server (Default Path)

```bash
/opt/nexus-cos/scripts/nexus_health_report.sh
```

### Custom .env Path

```bash
ENV_PATH="/opt/nexus-cos/.env" /opt/nexus-cos/scripts/nexus_health_report.sh
```

### Integration with Monitoring Systems

```bash
#!/bin/bash
# Example monitoring integration

/opt/nexus-cos/scripts/nexus_health_report.sh
EXIT_CODE=$?

case $EXIT_CODE in
    0)
        echo "✓ All systems healthy"
        ;;
    1)
        echo "✗ Health endpoints down - alerting operations"
        # Send alert
        ;;
    2)
        echo "⚠ Database connectivity issue - alerting database team"
        # Send alert
        ;;
    3)
        echo "✗ Critical failure - all systems down"
        # Send critical alert
        ;;
esac
```

## Output Example

```
========================================
 Nexus COS Health Report
========================================

[INFO] Timestamp: 2025-10-06T21:30:18Z
[INFO] Hostname: nexus-vps
[INFO] Current User: nexus


========================================
 Environment Configuration
========================================

[INFO] Using server .env path: /opt/nexus-cos/.env
[SUCCESS] Found .env file: /opt/nexus-cos/.env


========================================
 Main Site Health Check
========================================

[INFO] Checking Main Site: https://n3xuscos.online/health
[SUCCESS]   ✓ HTTP 200 - Main site is healthy
[WARNING]   ⚠ Database status: down
[ERROR]   ✗ DB Error: getaddrinfo EAI_AGAIN admin


========================================
 Beta Site Health Check
========================================

[INFO] Checking Beta Site: https://beta.n3xuscos.online/health
[ERROR]   ✗ Connection failed - Beta site is unreachable


========================================
 Database Direct Connectivity
========================================

[INFO] Checking direct database connectivity: admin:5432
[ERROR]   ✗ Database port admin:5432 - no response


========================================
 Health Report Summary
========================================

[INFO] Total Checks: 3
[SUCCESS] Passed: 1
[ERROR] Failed: 2

[INFO] Status Details:
[SUCCESS]   ✓ Main site: HEALTHY
[ERROR]   ✗ Beta site: UNHEALTHY
[ERROR]   ✗ Database: UNREACHABLE


========================================
 ⚠ Overall Status: DEGRADED
========================================

[WARNING] Health endpoints OK but database is unreachable

Recommended Actions:
  1. Verify DB_HOST setting in .env (currently: admin)
  2. Check if PostgreSQL is running: systemctl status postgresql
  3. Verify database is listening on port: 5432
  4. Update pg_hba.conf to allow connections from this host
```

## Testing

Run the comprehensive test suite:

```bash
bash scripts/test-health-report.sh
```

The test suite validates:
- Script syntax and structure
- URL configuration
- Environment path resolution
- Curl timeouts and configuration
- Exit codes
- Database configuration
- Runtime behavior

## Troubleshooting

### Issue: Database connection errors

**Symptoms**: Database status shows "down" with error messages like "getaddrinfo EAI_AGAIN"

**Solutions**:
1. Verify `DB_HOST` is set to a resolvable hostname or IP address
2. For local database: Set `DB_HOST=localhost` in `.env`
3. For remote database: Use DNS name or IP address
4. Ensure PostgreSQL is running: `systemctl status postgresql`
5. Check PostgreSQL is listening: `netstat -tlnp | grep 5432`
6. Update `pg_hba.conf` to allow connections from the server

### Issue: Beta site unreachable

**Symptoms**: Beta site returns HTTP 000 or connection failed

**Solutions**:
1. Verify DNS is configured for beta.n3xuscos.online
2. Check nginx configuration for beta subdomain
3. Ensure SSL certificates are valid
4. Verify firewall allows traffic to port 443

### Issue: Wrong .env file loaded

**Symptoms**: Script uses wrong database settings

**Solutions**:
1. Explicitly set `ENV_PATH`: `ENV_PATH="/opt/nexus-cos/.env" ./script.sh`
2. Check file exists: `ls -la /opt/nexus-cos/.env`
3. Verify permissions: `chmod 644 /opt/nexus-cos/.env`

## Next Steps

After running the health report and identifying issues:

1. **Set resolvable DB host**: Update `DB_HOST` in `/opt/nexus-cos/.env`
2. **Open database access**: Configure firewall and `pg_hba.conf`
3. **Restart services**: `pm2 restart nexuscos-app`
4. **Re-run health report**: Verify all checks pass

## Related Files

- `scripts/health-check.sh` - Service-level health checks
- `pf-health-check.sh` - Pre-flight health validation
- `server.js` - Health endpoint implementation
- `test-health-endpoint.js` - Health endpoint testing

## References

- Main health endpoint: https://n3xuscos.online/health
- Beta health endpoint: https://beta.n3xuscos.online/health
- Database configuration: `.env` file (DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD)
