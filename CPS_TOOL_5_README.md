# CPS Tool #5 - Master Stack Verification

**N3XUS COS MASTER FULL-STACK VERIFICATION PF**

## Quick Start

```bash
# One-command execution
python3 cps_tool_5_master_verification.py
```

## Overview

CPS Tool #5 is a comprehensive Platform Forensic / Systems Validation tool that verifies the integrity, compliance, and operational status of the entire N3XUS COS stack.

### Execution Mode
- **Read-Only:** No modifications to system
- **Non-Destructive:** Safe to run in production
- **Deterministic:** Consistent results
- **Authority:** Canonical
- **Failure Tolerance:** Zero Silent Failures

## What It Does

### Phase 1: System Inventory (Reality Enumeration)
✅ Enumerates all Docker containers (running and stopped)  
✅ Detects all PM2 processes with status and metrics  
✅ Assesses system load with critical thresholds  
✅ Maps runtime units to source directories

### Phase 2: Service Responsibility Validation
✅ Checks HTTP endpoints for health/status  
✅ Validates service availability  
✅ Detects critical blockers (timeouts, connection failures)  
✅ Categorizes services (verified/degraded/ornamental)

### Phase 3: Canon Consistency Check
✅ Verifies "PMMG N3XUS R3CORDINGS" branding (N3XUS LAW)  
✅ Validates "Handshake 55-45-17" protocol  
✅ Confirms Master Blueprint documentation  
✅ Checks supporting documentation files

### Phase 4: Executive Verdict
✅ Generates comprehensive statistics  
✅ Provides GO/NO-GO decision  
✅ Lists critical blockers with recommendations  
✅ Saves detailed JSON report

## Output

### Terminal Output
Color-coded, human-readable verification report with:
- ✅ Pass indicators (green)
- ⚠️ Warning indicators (yellow)
- ✗ Failure indicators (red)
- Detailed statistics and findings

### JSON Report
Machine-readable report saved to:
```
verification_report_YYYYMMDD_HHMMSS.json
```

Contains:
- Timestamp
- Docker container inventory
- PM2 process inventory
- Service verification results
- Canon compliance checks
- Critical blockers
- Executive verdict

## Exit Codes

- `0` - Fully Operational (all checks passed)
- `1` - Degraded (failures detected, non-critical)
- `2` - Critical Issues (requires immediate attention)
- `130` - User interrupted (Ctrl+C)

## Use Cases

### 1. Local Development
Verify canon compliance and documentation before committing:
```bash
python3 cps_tool_5_master_verification.py
```

### 2. CI/CD Pipeline
Add as a verification gate:
```yaml
- name: Run Master Stack Verification
  run: python3 cps_tool_5_master_verification.py
```

### 3. Staging Validation
Pre-deployment system check:
```bash
ssh staging-server "cd /path/to/nexus-cos && python3 cps_tool_5_master_verification.py"
```

### 4. Production Monitoring
Runtime integrity verification:
```bash
# Add to cron for periodic checks
0 * * * * cd /path/to/nexus-cos && python3 cps_tool_5_master_verification.py
```

### 5. Debugging
Identify missing services or broken dependencies:
```bash
python3 cps_tool_5_master_verification.py 2>&1 | tee debug.log
```

## Configuration

Timeout values can be adjusted in the script:
```python
COMMAND_TIMEOUT = 30  # seconds (shell commands)
HTTP_TIMEOUT = 5      # seconds (HTTP health checks)
```

## Requirements

- Python 3.6+
- Standard library only (no external dependencies)
- Optional: Docker (for container checks)
- Optional: PM2 (for process checks)

## Verification Scope

### Services Checked
- Backend API (localhost:3000)
- Backend API System Status (localhost:4000)
- Auth Service (localhost:3001)
- Streaming Service (localhost:3002)

### Canon Checks
- PMMG N3XUS R3CORDINGS branding
- Handshake 55-45-17 protocol
- Master Blueprint documentation
- HoloSnap Technical Specification
- NexCoin Quick Reference
- Founding Tenant Rights Guide

## Example Output

```
================================================================================
                    N3XUS COS MASTER FULL-STACK VERIFICATION                    
================================================================================

CPS Tool #5 - Platform Forensic / Systems Validation
Execution Mode: Read-Only | Non-Destructive | Deterministic

────────────────────────────────────────────────────────────────────────────────
PHASE 1: SYSTEM INVENTORY
────────────────────────────────────────────────────────────────────────────────
✓ Found 12 Docker containers
✓ Found 73 PM2 processes
✓ System load normal: 2.14

────────────────────────────────────────────────────────────────────────────────
PHASE 2: SERVICE RESPONSIBILITY VALIDATION
────────────────────────────────────────────────────────────────────────────────
✓ Backend API is OPERATIONAL - HTTP 200
✓ Auth Service is OPERATIONAL - HTTP 200

────────────────────────────────────────────────────────────────────────────────
PHASE 3: CANON CONSISTENCY CHECK
────────────────────────────────────────────────────────────────────────────────
✓ PMMG N3XUS R3CORDINGS branding verified
✓ Handshake 55-45-17 protocol found in 5 locations
✓ Master Blueprint documentation present

────────────────────────────────────────────────────────────────────────────────
PHASE 4: EXECUTIVE VERDICT
────────────────────────────────────────────────────────────────────────────────

STATUS: FULLY OPERATIONAL

Canon Compliance: 3/3 checks passed
Total Active Units: 85
```

## Troubleshooting

### "Docker not available"
Normal if Docker is not installed or not running. Tool will skip Docker checks.

### "PM2 not available"
Normal if PM2 is not installed. Tool will skip PM2 checks.

### "Service DOWN or UNREACHABLE"
Expected in dev environments. In production, investigate:
1. Check if service is running: `pm2 list` or `docker ps`
2. Check service logs: `pm2 logs` or `docker logs`
3. Verify port is not blocked by firewall
4. Check system resources (CPU, memory, disk)

### High system load warning
If load average > 20:
1. Check running processes: `top` or `htop`
2. Review resource-intensive services
3. Consider scaling or optimization
4. May cause API timeouts

## Integration with N3XUS COS

This tool is registered as:
- **CPS Tool #5** in PF-MASTER-INDEX.md
- Part of the canonical verification suite
- Implements requirements from PR #205
- Enforces N3XUS LAW compliance
- Validates Handshake 55-45-17 protocol

## Author

Created as part of the Master Full-Stack Verification PF execution  
Date: January 8, 2026  
Version: 1.0.0

## See Also

- [MASTER_STACK_VERIFICATION_EXECUTION_SUMMARY.md](./MASTER_STACK_VERIFICATION_EXECUTION_SUMMARY.md) - Complete execution report
- [PF-MASTER-INDEX.md](./PF-MASTER-INDEX.md) - Complete tool registry
- [NEXUS_COS_HOLOSNAP_MASTER_BLUEPRINT.md](./NEXUS_COS_HOLOSNAP_MASTER_BLUEPRINT.md) - Master Blueprint
- [GOVERNANCE_CHARTER_55_45_17.md](./GOVERNANCE_CHARTER_55_45_17.md) - Governance framework
