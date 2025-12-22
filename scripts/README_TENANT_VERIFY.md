# Tenant Verify & Add-in Script

## Overview

The `tenant-verify-and-add.sh` script is the authoritative tenant management tool for the NΞ3XUS·COS Mini-Platform. It verifies existing tenant configurations, creates necessary directory structures, manages network assignments, and registers tenants in the ledger layer.

## Purpose

This script maintains the canonical list of all platform tenants and ensures they are properly configured with:
- Directory structure in the filesystem
- Network connectivity via Docker
- Ledger registration for platform fee management (20%)

## Tenant Categories

### Family Urban Tenants (Locked)
These are established tenants with locked configurations:
- Ashanti's Munch & Mingle
- Clocking T with Yo Gurl P
- Gas or Crash
- Headwina's Comedy Jam
- sHEDA sHAY's Butter Bar
- Ro Ro's Gamer Lounge
- Sassie Lash
- Fayeloni Kreations
- Tyshawn's V-Dance Studio
- Nee Nee & Kids
- PUABO FOOD & LIFESTYLE

### Other Confirmed Tenants
- Faith Through Fitness
- Rise Sacramento 916
- PUABO TV
- PUABO UNSIGNED
- PUABO RADIO
- PUABO PODCAST NETWORK
- PUABO MUSIC NETWORK

### Newly Added Tenants
- Club Saditty

**Total Tenants: 19**

## Configuration

### Default Settings

| Setting | Default Value | Description |
|---------|--------------|-------------|
| PF_REPO_PATH | `/root/n3xuscos` | Platform repository path |
| PF_LOG | `$PF_REPO_PATH/logs/tenant_update.log` | Log file location |
| NETWORK | `cos-net` | Docker network name |
| LEDGER_LAYER | `nexus-cos-ledger` | Ledger service name |

### Environment Variables

You can override the default paths using environment variables:

```bash
PF_REPO_PATH=/custom/path ./scripts/tenant-verify-and-add.sh
```

## Usage

### Basic Usage

```bash
sudo ./scripts/tenant-verify-and-add.sh
```

The script will:
1. Verify each tenant in the canonical list
2. Create missing tenant directories at `$PF_REPO_PATH/tenants/{tenant_name}`
3. Ensure Docker network `cos-net` exists
4. Assign each tenant to the network
5. Register tenants in the ledger layer for 20% platform fee
6. Generate a summary report

### Custom Repository Path

```bash
sudo PF_REPO_PATH=/opt/n3xuscos ./scripts/tenant-verify-and-add.sh
```

### Log Location

By default, logs are written to:
```
/root/n3xuscos/logs/tenant_update.log
```

You can tail the log to monitor progress:
```bash
tail -f /root/n3xuscos/logs/tenant_update.log
```

## Script Actions

### 1. Tenant Directory Verification

For each tenant, the script checks if a directory exists at:
```
$PF_REPO_PATH/tenants/{Tenant_Name_With_Underscores}
```

Examples:
- "Club Saditty" → `/root/n3xuscos/tenants/Club_Saditty`
- "Ashanti's Munch & Mingle" → `/root/n3xuscos/tenants/Ashanti's_Munch_&_Mingle`

If a directory doesn't exist, it creates a placeholder.

### 2. Network Assignment

The script ensures the Docker network `cos-net` exists:
```bash
docker network inspect cos-net || docker network create cos-net
```

Each tenant is then assigned to this network for inter-service communication.

### 3. Ledger Registration

Tenants are registered in the `nexus-cos-ledger` service for platform fee tracking (20%).

**Note:** The actual ledger registration command is currently a placeholder. To enable it, uncomment:
```bash
# nexus-cos-ledger register-tenant --name "$tenant" --fee 20
```

## Output

The script produces timestamped output showing:
- Verification status for each tenant (✅ exists, ⚠️ created)
- Network assignments
- Ledger registrations
- Final summary with tenant count

Example output:
```
[2025-12-22 14:30:00] Starting mini-platform tenant verify & add-in...
Verifying tenant: Ashanti's Munch & Mingle
✅ Tenant directory exists.
Tenant Ashanti's Munch & Mingle assigned to network cos-net
Registering tenant Ashanti's Munch & Mingle in nexus-cos-ledger for 20% platform fee
...
[2025-12-22 14:30:15] Tenant verify & add-in completed.
Canonical Tenant List:
 - Ashanti's Munch & Mingle
 - Clocking T with Yo Gurl P
 ...
 - Club Saditty
✅ Total tenants: 19
```

## Integration with Nexus COS

This script integrates with:

### PF Update Script
The tenant list aligns with the routing configuration in `pf-update-nginx-routes.sh`:
- Club Saditty is configured for routing at `/club-saditty/`
- Additional tenants can be added to the Nginx routing as needed

### Docker Compose
Tenants should have corresponding service definitions in `docker-compose.unified.yml` or separate compose files. The `cos-net` network ensures all services can communicate.

### Ledger Layer
The `nexus-cos-ledger` service tracks platform fees (20%) for each tenant's revenue.

## Adding New Tenants

To add a new tenant:

1. Edit `scripts/tenant-verify-and-add.sh`
2. Add the tenant name to the appropriate array:
   - `FAMILY_URBAN_TENANTS` for locked family/urban tenants
   - `OTHER_TENANTS` for additional confirmed tenants
   - Or add to `NEW_TENANT` if it's a single new addition
3. Run the script to create directories and configure the tenant
4. Add Nginx routing in `pf-update-nginx-routes.sh` if needed
5. Add Docker Compose service definition if needed

Example:
```bash
# In tenant-verify-and-add.sh
declare -a OTHER_TENANTS=(
    ...
    "PUABO MUSIC NETWORK"
    "My New Tenant"  # Added
)
```

## Tenant Directory Structure

Expected structure for each tenant:
```
/root/n3xuscos/tenants/
├── Ashanti's_Munch_&_Mingle/
├── Club_Saditty/
├── Clocking_T_with_Yo_Gurl_P/
├── Faith_Through_Fitness/
...
```

Each tenant directory can contain:
- Configuration files
- Static assets
- Service-specific data
- Deployment manifests

## Prerequisites

- Root or sudo access
- Docker installed and running
- Write access to `$PF_REPO_PATH`
- `nexus-cos-ledger` service (for ledger registration)

## Troubleshooting

### "Permission denied" error
Run with sudo:
```bash
sudo ./scripts/tenant-verify-and-add.sh
```

### Docker network creation fails
Ensure Docker daemon is running:
```bash
sudo systemctl status docker
```

### Log file not created
Ensure the logs directory exists:
```bash
mkdir -p /root/n3xuscos/logs
```

### Tenant directory creation fails
Check permissions and available disk space:
```bash
df -h
ls -ld /root/n3xuscos/tenants
```

## Platform Fee Structure

All tenants are registered with a **20% platform fee**. This fee structure is managed by the `nexus-cos-ledger` service and applies to all revenue generated through the platform.

## Version History

- **v2025.12.22**: Initial release
  - Support for 19 tenants across 3 categories
  - Directory verification and creation
  - Network assignment via cos-net
  - Ledger registration placeholder
  - Comprehensive logging

## Related Scripts

- `scripts/pf-update-nginx-routes.sh`: Nginx routing configuration for tenants
- Docker Compose files: Service definitions for tenant platforms

## License

Part of the Nexus COS project.
