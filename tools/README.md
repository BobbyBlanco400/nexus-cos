# Nexus COS Tools

This directory contains utility scripts for Nexus COS deployment and maintenance.

## Scripts

### pf_master_gateway_fix.sh

Configures Nginx gateway routing for V-Suite streaming services.

**Usage:**
```bash
DOMAIN=<domain> \
VSCREEN_PORT=<port> \
VSTAGE_PORT=<port> \
VSUITE_PORT=<port> \
SOCKET_PORT=<port> \
/opt/nexus-cos/tools/pf_master_gateway_fix.sh
```

**Required Environment Variables:**
- `DOMAIN` - The domain to configure (required)

**Optional Environment Variables:**
- `VSCREEN_PORT` - V-Screen service port (default: 3004)
- `VSTAGE_PORT` - V-Stage service port (default: 3033)
- `VSUITE_PORT` - V-Suite service port (default: 3005)
- `SOCKET_PORT` - Socket.IO streaming port (default: 3043)

## GitHub Actions Workflow

The `Master PF Gateway` workflow (`.github/workflows/master-pf-gateway.yml`) automates gateway configuration.

### Required Secrets

Configure these secrets in your GitHub repository settings (`Settings > Secrets and variables > Actions`):

| Secret | Description | Required |
|--------|-------------|----------|
| `VPS_HOST` | VPS server hostname or IP address | Yes |
| `VPS_USER` | SSH username for VPS access | Yes |
| `VPS_SSH_KEY` | Private SSH key for VPS authentication | Yes |
| `PF_DOMAIN` | Default domain (used if not provided in workflow input) | No |
| `PF_VSCREEN_PORT` | Default V-Screen port | No |
| `PF_VSTAGE_PORT` | Default V-Stage port | No |
| `PF_VSUITE_PORT` | Default V-Suite port | No |
| `PF_SOCKET_PORT` | Default Socket.IO port | No |

### Workflow Triggers

1. **Manual Dispatch**: Run manually with custom inputs via GitHub Actions UI
2. **Workflow Run**: Automatically runs after successful completion of:
   - `VPS Deploy` workflow
   - `Deploy Nexus COS` workflow

### Example: Setting Up Secrets

```bash
# Using GitHub CLI
gh secret set VPS_HOST --body "your-vps-ip-or-hostname"
gh secret set VPS_USER --body "root"
gh secret set VPS_SSH_KEY < ~/.ssh/vps_private_key
gh secret set PF_DOMAIN --body "nexuscos.online"
```

Or via GitHub web interface:
1. Go to repository Settings
2. Navigate to `Secrets and variables > Actions`
3. Click `New repository secret`
4. Add each secret with its value
