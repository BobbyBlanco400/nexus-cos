# Nexus COS Health Check & Repair Script

## Overview

The `nexus_cos_health_check.sh` script provides automated Docker container health monitoring and repair functionality for the Nexus COS platform. It identifies unhealthy containers, saves diagnostic logs, attempts automatic restart, and waits for containers to fully recover.

## Problem Solved

This script addresses the issue where containers appear "unhealthy" immediately after restart because the health check script doesn't wait for containers to complete their startup sequence. Containers often show a "starting" status which is a transitional state, not a failure state.

### Key Improvements

1. **Proper Wait Logic**: Waits up to 120 seconds (configurable) for containers to become healthy after restart
2. **State Distinction**: Distinguishes between transitional states ("starting", "restarting") and true failure states ("exited", "dead", "unhealthy")
3. **Healthcheck Support**: Handles both containers with Docker healthchecks and those without
4. **Diagnostic Logging**: Saves container logs before restart for troubleshooting

## Usage

### Basic Usage
```bash
./nexus_cos_health_check.sh
```

### Custom Log Directory
```bash
LOG_DIR=/custom/log/path ./nexus_cos_health_check.sh
```

### Custom Wait Time
Edit the script to adjust `MAX_WAIT_TIME` and `CHECK_INTERVAL` variables:
```bash
MAX_WAIT_TIME=180  # Wait up to 3 minutes
CHECK_INTERVAL=15  # Check every 15 seconds
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `LOG_DIR` | `/root/nexus_cos_logs` | Directory for container logs |
| `MAX_WAIT_TIME` | `120` | Maximum seconds to wait for container health (120s = 2 minutes) |
| `CHECK_INTERVAL` | `10` | Seconds between health checks |

## How It Works

1. **Detection**: Scans all Docker containers for unhealthy states
   - Containers with healthcheck status "unhealthy"
   - Containers not running and not restarting

2. **Logging**: Saves container logs to timestamped files before restart
   - Format: `{container-name}_{timestamp}.log`
   - Location: `$LOG_DIR` (default: `/root/nexus_cos_logs`)

3. **Restart**: Restarts unhealthy containers using `docker restart`

4. **Validation**: Waits and monitors containers for successful startup
   - For containers with healthchecks: waits for "healthy" status
   - For containers without healthchecks: waits for "running" status
   - Shows progress updates every 10 seconds
   - Distinguishes "starting" (OK, transitional) from "exited" (FAILED)

5. **Reporting**: Provides clear success/failure status for each container

## Output Example

**Note:** The following is example output from the problem statement. Timestamps and container IDs will vary based on your environment.

```
===== NΞ3XUS·COS Health Check & Repair Script =====
Timestamp: Mon Dec 22 22:45:40 UTC 2025
Logs will be saved in /root/nexus_cos_logs

Found unhealthy containers:
3b59f732f758 nexus-cos-nexus-cos-streamcore-1 0.0.0.0:3016->3016/tcp

------------------------------------------
Processing: nexus-cos-nexus-cos-streamcore-1 (3b59f732f758)
Ports: 0.0.0.0:3016->3016/tcp
Logs saved to: /root/nexus_cos_logs/nexus-cos-nexus-cos-streamcore-1_20251222_224546.log
Attempting restart...
3b59f732f758
Waiting for nexus-cos-nexus-cos-streamcore-1 to become healthy (max 120s)...
  Status: running, Health: starting (0s elapsed)
  Status: running, Health: starting (10s elapsed)
  Status: running, Health: starting (20s elapsed)
✓ nexus-cos-nexus-cos-streamcore-1 is healthy
✓ nexus-cos-nexus-cos-streamcore-1 is now healthy
------------------------------------------

===== Health Check & Repair Completed =====
Check /root/nexus_cos_logs for logs from each container.
```

## Services Supported

The script works with all Nexus COS services including:
- `nexus-cos-puaboai-sdk` (Port 3002)
- `nexus-cos-streamcore` (Port 3016)
- `puabo-nexus-ai-dispatch` (Port 3231)
- `puabo-nexus-driver-app-backend` (Port 3232)
- `puabo-nexus-fleet-manager` (Port 3233)
- `puabo-nexus-route-optimizer` (Port 3234)
- `nexus-cos-pv-keys` (Port 3041)
- And all other Docker containers in the Nexus COS stack

## Testing

Run the test suite to validate the script:
```bash
./test-nexus-cos-health-check.sh
```

The test suite validates:
- Script existence and executability
- Syntax correctness
- Proper function definitions
- Wait logic implementation
- State distinction logic
- Log saving functionality
- Container restart functionality

## Exit Codes

- `0`: All containers are healthy
- Non-zero: Errors during execution (from `set -e`)

## Troubleshooting

### Container remains unhealthy after restart
1. Check the saved logs in `$LOG_DIR`
2. Look for application errors or dependency issues
3. Manually inspect container: `docker logs <container-id>`
4. Check if dependencies (database, redis) are healthy

### Script times out waiting for container
1. Check if `MAX_WAIT_TIME` is sufficient for your services
2. Increase `MAX_WAIT_TIME` if containers need longer startup
3. Verify container healthcheck configuration in docker-compose

### Container shows "starting" indefinitely
This is now handled correctly - the script waits for the transition to complete. If it times out:
1. Check if the healthcheck endpoint is responding
2. Verify network connectivity between containers
3. Check for dependency issues

## Integration

The script can be:
- Run manually for ad-hoc health checks
- Integrated into cron for scheduled monitoring
- Called from deployment scripts for post-deployment validation
- Used in CI/CD pipelines for automated testing

### Cron Example
```bash
# Check every hour
0 * * * * /path/to/nexus_cos_health_check.sh >> /var/log/health-check.log 2>&1
```

## Related Scripts

- `health-check.sh` - General Nexus COS health check
- `pf-health-check.sh` - PF-specific health validation
- `health-check-pf-v1.2.sh` - PF v1.2 comprehensive health check
- `scripts/nexus-cos-final-system-check.sh` - Complete system validation

## Version History

- **v1.0** (2025-12-22): Initial implementation
  - Proper wait logic after container restart
  - State distinction between starting/unhealthy
  - Diagnostic log saving
  - Support for containers with and without healthchecks
