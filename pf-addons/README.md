# Platform Fix (PF) Addons

This directory contains safe, additive platform fix scripts that address specific issues without disrupting system stability.

## Safety Guarantees

All PF addon scripts in this directory follow these safety principles:

✅ **Safe Operations**
- Never touch existing code destructively
- Validate all paths before execution
- Create backups before making changes
- Exit cleanly on any error condition
- No service restarts or reloads
- No memory spikes or resource exhaustion

✅ **System Stability**
- Cannot kill SSH sessions
- Cannot cause restart storms
- Cannot trigger OOM killer
- Cannot disrupt running services
- Idempotent (safe to run multiple times)

## Available PF Addons

### IMCU Additive PF (`imcu/imcu_additive_pf.sh`)

Safely adds IMCU (Infrastructure Management and Compute Unit) endpoints to the backend server.

**What it does:**
- Checks if backend/server.js exists
- Verifies IMCU endpoints are not already present
- Creates timestamped backup before changes
- Appends IMCU endpoint handlers
- Exits safely without restarting services

**Usage:**
```bash
bash /path/to/nexus-cos/pf-addons/imcu/imcu_additive_pf.sh
```

**Features added:**
- `GET /api/v1/imcus/:id/nodes` - List nodes for an IMCU
- `POST /api/v1/imcus/:id/deploy` - Deploy to an IMCU

## Emergency Recovery

If you encounter SSH connection issues or system instability:

1. **DO NOT** run old PF scripts that:
   - Reference non-existent paths
   - Mix JavaScript and bash code
   - Restart multiple services simultaneously
   - Don't validate paths before execution

2. **DO** use scripts in this directory that:
   - Follow safety principles above
   - Are designed for production stability
   - Exit cleanly on any issue
   - Create backups automatically

## Troubleshooting

### Script Won't Execute
```bash
# Make sure script is executable
chmod +x pf-addons/imcu/imcu_additive_pf.sh

# Run with explicit bash
bash pf-addons/imcu/imcu_additive_pf.sh
```

### Changes Not Applied
Check script output for:
- Backend file not found (path validation failed)
- IMCU endpoints already present (changes not needed)
- Backup creation messages

### Rollback Changes
Each script creates timestamped backups:
```bash
# List backups
ls -la backend/server.js.bak.*

# Restore from backup
cp backend/server.js.bak.YYYYMMDD_HHMMSS backend/server.js
```

## Development Guidelines

When creating new PF addon scripts:

1. Use `set -euo pipefail` for strict error handling
2. Validate all paths before using them
3. Create timestamped backups before modifications
4. Check if changes are already applied (idempotency)
5. Exit with status 0 on success, non-zero on failure
6. Never restart services or reload configurations
7. Never mix JavaScript code in bash execution context
8. Log all actions with clear [PF] prefix
9. Document what the script does and why

## Example Safe PF Script Template

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[PF] My PF Script starting"

# Determine paths safely
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET_FILE="$REPO_ROOT/path/to/file"

# Validate file exists
if [ ! -f "$TARGET_FILE" ]; then
  echo "[PF] Target file not found, exiting safely"
  exit 0
fi

# Check if already applied
if grep -q "MY_MARKER" "$TARGET_FILE"; then
  echo "[PF] Changes already applied"
  exit 0
fi

# Create backup
STAMP="$(date +%Y%m%d_%H%M%S)"
cp "$TARGET_FILE" "$TARGET_FILE.bak.$STAMP"

# Apply changes safely
# ... your changes here ...

echo "[PF] Changes complete"
exit 0
```

## Support

For issues or questions about PF addon scripts:
1. Check script output for error messages
2. Verify file paths are correct
3. Review backups before rolling back
4. Test in non-production environment first
