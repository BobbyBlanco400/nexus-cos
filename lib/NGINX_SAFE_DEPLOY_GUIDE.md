# Nginx Safe Deployment Library - User Guide

## Overview

The `nginx-safe-deploy.sh` library provides a collection of safe, battle-tested functions for deploying Nginx configurations. It solves the common problem of broken deployments by adding automatic backups, validation, and rollback capabilities to all nginx configuration operations.

## Quick Start

### 1. Source the Library

At the top of your deployment script:

```bash
#!/bin/bash

# Source the nginx safe deployment library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/nginx-safe-deploy.sh"
```

### 2. Use Safe Functions

Replace dangerous operations with safe functions:

```bash
# OLD (DANGEROUS):
cp myconfig.conf /etc/nginx/sites-available/mysite
ln -sf /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# NEW (SAFE):
safe_deploy_nginx_config "myconfig.conf" "/etc/nginx/sites-available/mysite"
safe_enable_site "mysite"
reload_nginx
```

## Common Use Cases

### Deploy a Configuration File

```bash
#!/bin/bash
source lib/nginx-safe-deploy.sh

# Deploy a configuration file
safe_deploy_nginx_config \
    "deployment/nginx/mysite.conf" \
    "/etc/nginx/sites-available/mysite"

# The function automatically:
# - Creates a timestamped backup
# - Copies the new config
# - Validates with nginx -t
# - Rolls back if validation fails
# - Reloads nginx gracefully
```

### Deploy Configuration from Heredoc

```bash
#!/bin/bash
source lib/nginx-safe-deploy.sh

# Deploy configuration written inline
safe_deploy_nginx_heredoc "/etc/nginx/sites-available/mysite" <<'EOF'
server {
    listen 80;
    server_name example.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
    }
}
EOF

# Enable the site
safe_enable_site "mysite"
```

### Deploy Configuration from String Variable

```bash
#!/bin/bash
source lib/nginx-safe-deploy.sh

# Build configuration dynamically
CONFIG="server {
    listen 80;
    server_name example.com;
"

# Add dynamic routes
for route in api admin health; do
    CONFIG+="
    location /$route {
        proxy_pass http://localhost:3000;
    }
"
done

CONFIG+="
}"

# Deploy the configuration
safe_write_nginx_config "/etc/nginx/sites-available/mysite" "$CONFIG"
```

### Skip Automatic Reload

If you're deploying multiple configs and want to reload once at the end:

```bash
#!/bin/bash
source lib/nginx-safe-deploy.sh

# Deploy multiple configs without reloading
safe_deploy_nginx_config "site1.conf" "/etc/nginx/sites-available/site1" "true"
safe_deploy_nginx_config "site2.conf" "/etc/nginx/sites-available/site2" "true"
safe_deploy_nginx_config "site3.conf" "/etc/nginx/sites-available/site3" "true"

# Enable all sites
safe_enable_site "site1"
safe_enable_site "site2"
safe_enable_site "site3"

# Reload once
reload_nginx
```

## Function Reference

### Configuration Deployment

#### `safe_deploy_nginx_config(source, dest, [skip_reload])`

Deploy a configuration file safely.

**Parameters:**
- `source` - Path to source config file
- `dest` - Destination path in `/etc/nginx/`
- `skip_reload` - (optional) "true" to skip automatic reload

**Example:**
```bash
safe_deploy_nginx_config \
    "/path/to/mysite.conf" \
    "/etc/nginx/sites-available/mysite"
```

#### `safe_write_nginx_config(dest, content, [skip_reload])`

Write configuration from a string variable.

**Parameters:**
- `dest` - Destination path
- `content` - Configuration content as string
- `skip_reload` - (optional) "true" to skip reload

**Example:**
```bash
CONFIG="server { listen 80; }"
safe_write_nginx_config "/etc/nginx/sites-available/mysite" "$CONFIG"
```

#### `safe_deploy_nginx_heredoc(dest, [skip_reload])`

Deploy configuration from heredoc (reads from stdin).

**Parameters:**
- `dest` - Destination path
- `skip_reload` - (optional) "true" to skip reload

**Example:**
```bash
safe_deploy_nginx_heredoc "/etc/nginx/sites-available/mysite" <<'EOF'
server {
    listen 80;
    server_name example.com;
}
EOF
```

### Site Management

#### `safe_enable_site(name)`

Enable a site by creating symlink in sites-enabled.

**Parameters:**
- `name` - Site name (filename in sites-available)

**Example:**
```bash
safe_enable_site "mysite"
```

#### `safe_disable_site(name)`

Disable a site by removing symlink from sites-enabled.

**Parameters:**
- `name` - Site name

**Example:**
```bash
safe_disable_site "default"
```

### Nginx Control

#### `reload_nginx()`

Reload nginx gracefully (zero-downtime). If nginx isn't running, starts it instead.

**Example:**
```bash
reload_nginx || {
    echo "Failed to reload nginx"
    exit 1
}
```

#### `restart_nginx()`

Restart nginx completely (brief downtime).

**Example:**
```bash
restart_nginx
```

#### `validate_nginx_config()`

Test nginx configuration without applying changes.

**Example:**
```bash
if validate_nginx_config; then
    echo "Config is valid"
else
    echo "Config has errors"
fi
```

### Backup Management

#### `backup_config_file(path)`

Manually create a backup of a config file.

**Parameters:**
- `path` - Path to file to backup

**Returns:** Path to backup file (via stdout)

**Example:**
```bash
BACKUP=$(backup_config_file "/etc/nginx/sites-available/mysite")
echo "Backed up to: $BACKUP"
```

#### `restore_backup(backup, dest)`

Restore a specific backup file.

**Parameters:**
- `backup` - Path to backup file
- `dest` - Destination to restore to

**Example:**
```bash
restore_backup \
    "/etc/nginx/backups/mysite.backup.20260104-120000" \
    "/etc/nginx/sites-available/mysite"
```

#### `list_backups([name])`

List available backups.

**Parameters:**
- `name` - (optional) Filter by config name

**Example:**
```bash
# List all backups
list_backups

# List backups for specific site
list_backups "mysite"
```

#### `interactive_restore(name)`

Interactive menu to restore from backups.

**Parameters:**
- `name` - Config name to restore

**Example:**
```bash
interactive_restore "mysite"
```

## Advanced Examples

### Deploy with Custom Validation

```bash
#!/bin/bash
source lib/nginx-safe-deploy.sh

# Deploy configuration
safe_deploy_nginx_config "mysite.conf" "/etc/nginx/sites-available/mysite" "true"

# Custom validation checks
if ! curl -sf http://localhost/health > /dev/null; then
    log_error "Health check failed after deployment"
    
    # Restore from backup
    LATEST_BACKUP=$(list_backups "mysite" | head -1)
    restore_backup "$LATEST_BACKUP" "/etc/nginx/sites-available/mysite"
    reload_nginx
    exit 1
fi

# Everything OK, reload
reload_nginx
```

### Deployment with Pre/Post Hooks

```bash
#!/bin/bash
source lib/nginx-safe-deploy.sh

pre_deploy_hook() {
    log_info "Running pre-deployment checks..."
    # Your custom checks here
}

post_deploy_hook() {
    log_success "Running post-deployment tasks..."
    # Your custom tasks here
}

# Main deployment
pre_deploy_hook
safe_deploy_nginx_config "mysite.conf" "/etc/nginx/sites-available/mysite"
post_deploy_hook
```

### Multi-Environment Deployment

```bash
#!/bin/bash
source lib/nginx-safe-deploy.sh

ENVIRONMENT=${1:-production}

case $ENVIRONMENT in
    production)
        safe_deploy_nginx_config \
            "configs/prod.conf" \
            "/etc/nginx/sites-available/mysite"
        ;;
    staging)
        safe_deploy_nginx_config \
            "configs/staging.conf" \
            "/etc/nginx/sites-available/mysite"
        ;;
    development)
        safe_deploy_nginx_config \
            "configs/dev.conf" \
            "/etc/nginx/sites-available/mysite"
        ;;
    *)
        log_error "Unknown environment: $ENVIRONMENT"
        exit 1
        ;;
esac
```

### Rollback Script

```bash
#!/bin/bash
source lib/nginx-safe-deploy.sh

SITE_NAME=${1:-nexuscos}

echo "Available backups for $SITE_NAME:"
list_backups "$SITE_NAME"

echo ""
read -p "Enter backup filename to restore: " backup_file

if [[ -f "/etc/nginx/backups/$backup_file" ]]; then
    restore_backup \
        "/etc/nginx/backups/$backup_file" \
        "/etc/nginx/sites-available/$SITE_NAME"
    
    reload_nginx
    log_success "Rollback complete"
else
    log_error "Backup file not found"
    exit 1
fi
```

## Error Handling

All functions return proper exit codes:

```bash
# Check return code
if safe_deploy_nginx_config "mysite.conf" "/etc/nginx/sites-available/mysite"; then
    echo "Deployment successful"
else
    echo "Deployment failed"
    exit 1
fi

# Or use || operator for error handling
safe_deploy_nginx_config "mysite.conf" "/etc/nginx/sites-available/mysite" || {
    echo "Deployment failed, cleaning up..."
    # cleanup code here
    exit 1
}
```

## Logging

The library provides color-coded logging functions:

```bash
log_info "Informational message"      # Blue
log_success "Success message"         # Green
log_warning "Warning message"         # Yellow
log_error "Error message"             # Red
```

## Best Practices

### 1. Always Source the Library

```bash
# Good
source lib/nginx-safe-deploy.sh

# Bad - using library functions without sourcing
safe_deploy_nginx_config "file.conf" "/etc/nginx/..."
```

### 2. Check Exit Codes

```bash
# Good
if safe_deploy_nginx_config "file.conf" "/etc/nginx/..."; then
    echo "Success"
fi

# Bad - ignoring return code
safe_deploy_nginx_config "file.conf" "/etc/nginx/..."
# Script continues even if it failed
```

### 3. Use Skip Reload for Batch Operations

```bash
# Good - deploy multiple configs, reload once
safe_deploy_nginx_config "site1.conf" "/etc/nginx/sites-available/site1" "true"
safe_deploy_nginx_config "site2.conf" "/etc/nginx/sites-available/site2" "true"
reload_nginx

# Bad - reload after each config (slow)
safe_deploy_nginx_config "site1.conf" "/etc/nginx/sites-available/site1"
safe_deploy_nginx_config "site2.conf" "/etc/nginx/sites-available/site2"
```

### 4. Keep Backups Organized

Backups are automatically stored in `/etc/nginx/backups/` with timestamps. Clean old backups periodically:

```bash
# Keep only last 30 days of backups
find /etc/nginx/backups -name "*.backup.*" -mtime +30 -delete
```

## Troubleshooting

### "nginx-safe-deploy.sh library not found"

**Problem:** Script can't find the library file.

**Solution:**
```bash
# Make sure library exists
ls -la lib/nginx-safe-deploy.sh

# Check your sourcing path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/nginx-safe-deploy.sh"
```

### "This function requires root privileges"

**Problem:** Not running as root.

**Solution:**
```bash
# Run script with sudo
sudo ./deploy-script.sh

# Or check for root at start of script
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi
```

### "Nginx is not installed"

**Problem:** Nginx is not installed on the system.

**Solution:**
```bash
# Install nginx first
apt-get install nginx  # Debian/Ubuntu
yum install nginx      # RHEL/CentOS
```

### Deployment Keeps Failing Validation

**Problem:** New config has syntax errors.

**Solution:**
```bash
# Test your config manually first
nginx -t -c /path/to/your/config.conf

# Check nginx error log
tail -f /var/log/nginx/error.log

# View the backup that was created
ls -lt /etc/nginx/backups/ | head
```

## Integration with Existing Scripts

### Gradual Migration

You don't have to fix all scripts at once. Migrate gradually:

```bash
#!/bin/bash

# Source library
source lib/nginx-safe-deploy.sh

# ... existing code ...

# Replace old nginx deployment
# OLD:
# cp mysite.conf /etc/nginx/sites-available/
# nginx -t && systemctl reload nginx

# NEW:
safe_deploy_nginx_config "mysite.conf" "/etc/nginx/sites-available/mysite"

# ... rest of existing code ...
```

### Compatibility

The library is compatible with:
- ✅ Bash 4.0+
- ✅ Debian/Ubuntu (systemd)
- ✅ RHEL/CentOS (systemd)
- ✅ Other systemd-based distributions
- ✅ Nginx 1.10+

## Getting Help

### View Built-in Help

```bash
# Show usage information
./lib/nginx-safe-deploy.sh --help
```

### Common Questions

**Q: Will this work with Docker containers?**  
A: Yes, if nginx is installed in the container and you're running the script inside it.

**Q: Can I use this with Plesk/cPanel?**  
A: Yes, but you may need to adjust paths. Plesk uses different config locations.

**Q: What if I need to restart instead of reload?**  
A: Use `restart_nginx` instead of `reload_nginx`. Note this causes brief downtime.

**Q: Are backups cleaned up automatically?**  
A: No, you need to implement your own backup retention policy.

## Contributing

Found a bug or have an improvement? The library is designed to be extensible. Add new functions following the existing patterns.

## License

This library is part of the Nexus COS project and follows the same license.
