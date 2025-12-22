# PF Update Script - Nginx Routing Configuration

## Overview

The `pf-update-nginx-routes.sh` script automates the configuration of Nginx routing for the Nexus COS Stack, including:

- **Front-facing Platform**: Netflix-style module served at the root path (`/`)
- **Puaboverse**: Internal Metaverse/Creator Hub accessible at `/puaboverse/`
- **Tenant Platforms**: Individual platform instances (e.g., Club Saditty) at their respective paths

## Features

- ✅ Automated Nginx configuration generation
- ✅ Backup of existing configuration before changes
- ✅ Configuration validation before applying changes
- ✅ Automatic rollback on validation failure
- ✅ Health check endpoints for all services
- ✅ Configurable container IPs via environment variables
- ✅ Colored output for better readability
- ✅ Safe reload of Nginx service

## Prerequisites

- Root/sudo access
- Nginx installed and running
- Docker containers running on specified IPs

## Usage

### Basic Usage

```bash
sudo ./scripts/pf-update-nginx-routes.sh
```

### Custom Container IPs

You can override the default container IPs using environment variables:

```bash
sudo FRONTEND_IP="172.20.0.10:3080" \
     PUABOVERSE_IP="172.20.0.11:3060" \
     CLUB_SADITTY_IP="172.20.0.12:3070" \
     ./scripts/pf-update-nginx-routes.sh
```

### Custom Nginx Configuration Path

```bash
sudo NGINX_CONF="/etc/nginx/sites-available/custom.conf" \
     ./scripts/pf-update-nginx-routes.sh
```

## Configuration

### Default Container IPs

| Service | Default IP:Port | Description |
|---------|----------------|-------------|
| Frontend | `172.20.0.14:3080` | Front-facing Netflix-style module |
| Puaboverse | `172.20.0.13:3060` | Internal Metaverse/Creator Hub |
| Club Saditty | `172.20.0.15:3070` | Tenant Platform example |

### Nginx Routes

| Path | Backend Service | Purpose |
|------|----------------|---------|
| `/` | `puabo-frontend` | Main front-facing platform |
| `/puaboverse/` | `puaboverse` | Internal Metaverse/Creator Hub |
| `/puaboverse/health` | `puaboverse` | Health check endpoint |
| `/club-saditty/` | `club-saditty` | Tenant Platform (Club Saditty) |

## Script Features

### Safety Features

1. **Prerequisite Checks**: Verifies root access and Nginx installation
2. **Automatic Backup**: Creates timestamped backups in `/etc/nginx/backups/`
3. **Configuration Validation**: Tests configuration with `nginx -t` before applying
4. **Automatic Rollback**: Restores from backup if validation fails
5. **Graceful Reload**: Safely reloads Nginx without downtime

### Output

The script provides colored, user-friendly output:
- 🟦 **Blue (ℹ)**: Informational messages
- 🟩 **Green (✓)**: Success messages
- 🟨 **Yellow (⚠)**: Warnings
- 🔴 **Red (✗)**: Error messages
- 🔷 **Cyan (▶)**: Process steps

## Verification

After running the script, you can verify the routes are working:

```bash
# Test front-facing platform
curl -I https://n3xuscos.online/

# Test Puaboverse health check
curl -I https://n3xuscos.online/puaboverse/health

# Test Club Saditty platform
curl -I https://n3xuscos.online/club-saditty/
```

## Adding Additional Tenant Platforms

To add more tenant platforms, modify the script:

1. Add the new container IP variable:
```bash
NEW_TENANT_IP="${NEW_TENANT_IP:-172.20.0.16:3071}"
```

2. Add the upstream block in the configuration:
```nginx
upstream new-tenant {
    server ${NEW_TENANT_IP};
}
```

3. Add the location block:
```nginx
location /new-tenant/ {
    proxy_pass http://new-tenant/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

## Troubleshooting

### Script fails with "This script must be run as root"

Run the script with `sudo`:
```bash
sudo ./scripts/pf-update-nginx-routes.sh
```

### Nginx configuration validation fails

The script will automatically restore the previous configuration. Check the error messages from `nginx -t` for details.

### Container IPs are not reachable

Verify your Docker containers are running and accessible:
```bash
docker ps
curl http://172.20.0.14:3080/
```

### Nginx reload fails

Try manually reloading Nginx:
```bash
sudo systemctl reload nginx
# or
sudo service nginx reload
```

## Backup and Recovery

### Backup Location

Backups are stored in `/etc/nginx/backups/` with timestamp:
```
/etc/nginx/backups/nexus-cos_20251222_143025.conf
```

### Manual Restore

To manually restore from a backup:
```bash
sudo cp /etc/nginx/backups/nexus-cos_TIMESTAMP.conf /etc/nginx/sites-available/nexus-cos.conf
sudo nginx -t
sudo systemctl reload nginx
```

## Integration with Nexus COS

This script is part of the Nexus COS deployment toolchain and follows the established patterns:

- Consistent with other scripts in the `scripts/` directory
- Uses the same color scheme and output format
- Includes proper error handling and rollback mechanisms
- Supports environment variable configuration
- Provides comprehensive logging and verification

## Version History

- **v2025.10.01**: Initial release
  - Support for front-facing platform
  - Support for Puaboverse metaverse hub
  - Support for tenant platforms (Club Saditty example)
  - Automatic backup and rollback
  - Health check endpoints

## Related Scripts

- `scripts/update-nginx-puabo-nexus-routes.sh`: PUABO NEXUS fleet services routing
- `scripts/pf-fix-nginx-headers-redirect.sh`: PF header fixes and redirects
- `scripts/pf-final-deploy.sh`: Complete PF deployment

## License

Part of the Nexus COS project.
