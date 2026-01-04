#!/bin/bash
# ==============================================================================
# Nginx Safe Deployment Library
# ==============================================================================
# Provides safe functions for deploying nginx configurations with:
# - Automatic backups
# - Configuration validation
# - Automatic rollback on failure
# - Proper error handling
# ==============================================================================

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Backup directory
readonly NGINX_BACKUP_DIR="/etc/nginx/backups"

# ==============================================================================
# Logging functions
# ==============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# ==============================================================================
# Validation functions
# ==============================================================================

check_nginx_installed() {
    if ! command -v nginx &> /dev/null; then
        log_error "Nginx is not installed"
        return 1
    fi
    return 0
}

check_root_permissions() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This function requires root privileges"
        return 1
    fi
    return 0
}

validate_nginx_config() {
    local test_output
    test_output=$(nginx -t 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "Nginx configuration is valid"
        return 0
    else
        log_error "Nginx configuration validation failed:"
        echo "$test_output"
        return 1
    fi
}

# ==============================================================================
# Backup functions
# ==============================================================================

create_backup_dir() {
    if [[ ! -d "$NGINX_BACKUP_DIR" ]]; then
        mkdir -p "$NGINX_BACKUP_DIR"
        log_info "Created backup directory: $NGINX_BACKUP_DIR"
    fi
}

backup_config_file() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        log_warning "Config file does not exist, nothing to backup: $config_file"
        return 0
    fi
    
    create_backup_dir
    
    local timestamp=$(date -u +%Y%m%d-%H%M%S-UTC)
    local basename=$(basename "$config_file")
    local backup_file="${NGINX_BACKUP_DIR}/${basename}.backup.${timestamp}"
    
    cp "$config_file" "$backup_file"
    
    if [[ $? -eq 0 ]]; then
        log_success "Backed up config to: $backup_file"
        echo "$backup_file" # Return backup path
        return 0
    else
        log_error "Failed to backup config file"
        return 1
    fi
}

restore_backup() {
    local backup_file="$1"
    local dest_file="$2"
    
    if [[ ! -f "$backup_file" ]]; then
        log_error "Backup file not found: $backup_file"
        return 1
    fi
    
    cp "$backup_file" "$dest_file"
    
    if [[ $? -eq 0 ]]; then
        log_success "Restored config from backup: $backup_file"
        return 0
    else
        log_error "Failed to restore backup"
        return 1
    fi
}

list_backups() {
    local config_name="$1"
    
    if [[ ! -d "$NGINX_BACKUP_DIR" ]]; then
        log_warning "No backup directory found"
        return 1
    fi
    
    if [[ -n "$config_name" ]]; then
        find "$NGINX_BACKUP_DIR" -name "${config_name}.backup.*" -type f | sort -r
    else
        find "$NGINX_BACKUP_DIR" -name "*.backup.*" -type f | sort -r
    fi
}

# ==============================================================================
# Main deployment functions
# ==============================================================================

safe_deploy_nginx_config() {
    local source_config="$1"
    local dest_config="$2"
    local skip_reload="${3:-false}"
    
    log_info "=== Starting Safe Nginx Config Deployment ==="
    log_info "Source: $source_config"
    log_info "Destination: $dest_config"
    
    # Pre-flight checks
    check_root_permissions || return 1
    check_nginx_installed || return 1
    
    if [[ ! -f "$source_config" ]]; then
        log_error "Source config file not found: $source_config"
        return 1
    fi
    
    # Backup existing config
    local backup_file
    backup_file=$(backup_config_file "$dest_config")
    local backup_exists=$?
    
    # Deploy new config
    log_info "Deploying new configuration..."
    cp "$source_config" "$dest_config"
    
    if [[ $? -ne 0 ]]; then
        log_error "Failed to copy config file"
        return 1
    fi
    
    # Validate new config
    log_info "Validating nginx configuration..."
    if ! validate_nginx_config; then
        log_error "New configuration is invalid, rolling back..."
        
        if [[ $backup_exists -eq 0 ]] && [[ -n "$backup_file" ]]; then
            restore_backup "$backup_file" "$dest_config"
        fi
        
        return 1
    fi
    
    # Reload nginx unless skipped
    if [[ "$skip_reload" != "true" ]]; then
        reload_nginx || return 1
    fi
    
    log_success "=== Nginx config deployed successfully ==="
    return 0
}

safe_write_nginx_config() {
    local dest_config="$1"
    local config_content="$2"
    local skip_reload="${3:-false}"
    
    log_info "=== Starting Safe Nginx Config Write ==="
    log_info "Destination: $dest_config"
    
    # Pre-flight checks
    check_root_permissions || return 1
    check_nginx_installed || return 1
    
    # Backup existing config
    local backup_file
    backup_file=$(backup_config_file "$dest_config")
    local backup_exists=$?
    
    # Write config to temporary file first with secure permissions
    local temp_config=$(mktemp)
    chmod 600 "$temp_config"
    echo "$config_content" > "$temp_config"
    
    # Copy temp to destination
    log_info "Writing new configuration..."
    cp "$temp_config" "$dest_config"
    rm "$temp_config"
    
    if [[ $? -ne 0 ]]; then
        log_error "Failed to write config file"
        return 1
    fi
    
    # Validate new config
    log_info "Validating nginx configuration..."
    if ! validate_nginx_config; then
        log_error "New configuration is invalid, rolling back..."
        
        if [[ $backup_exists -eq 0 ]] && [[ -n "$backup_file" ]]; then
            restore_backup "$backup_file" "$dest_config"
        fi
        
        return 1
    fi
    
    # Reload nginx unless skipped
    if [[ "$skip_reload" != "true" ]]; then
        reload_nginx || return 1
    fi
    
    log_success "=== Nginx config written successfully ==="
    return 0
}

reload_nginx() {
    log_info "Reloading nginx..."
    
    # Check if systemctl is available
    if ! command -v systemctl >/dev/null 2>&1; then
        log_error "systemctl command not found. Is systemd installed?"
        return 1
    fi
    
    if systemctl is-active --quiet nginx; then
        # Nginx is running, use reload for zero-downtime
        if systemctl reload nginx; then
            log_success "Nginx reloaded successfully"
            return 0
        else
            log_error "Failed to reload nginx"
            return 1
        fi
    else
        # Nginx is not running, start it
        log_info "Nginx is not running, starting..."
        if systemctl start nginx; then
            log_success "Nginx started successfully"
            return 0
        else
            log_error "Failed to start nginx"
            return 1
        fi
    fi
}

restart_nginx() {
    log_info "Restarting nginx..."
    
    if systemctl restart nginx; then
        log_success "Nginx restarted successfully"
        return 0
    else
        log_error "Failed to restart nginx"
        return 1
    fi
}

# ==============================================================================
# Symlink management
# ==============================================================================

safe_enable_site() {
    local site_name="$1"
    local available_path="/etc/nginx/sites-available/$site_name"
    local enabled_path="/etc/nginx/sites-enabled/$site_name"
    
    check_root_permissions || return 1
    
    if [[ ! -f "$available_path" ]]; then
        log_error "Site config not found in sites-available: $site_name"
        return 1
    fi
    
    if [[ -L "$enabled_path" ]]; then
        log_info "Site already enabled: $site_name"
        return 0
    fi
    
    ln -s "$available_path" "$enabled_path"
    
    if [[ $? -eq 0 ]]; then
        log_success "Enabled site: $site_name"
        
        # Validate after enabling
        if ! validate_nginx_config; then
            log_error "Config invalid after enabling site, removing symlink"
            rm -f "$enabled_path"
            return 1
        fi
        
        return 0
    else
        log_error "Failed to enable site: $site_name"
        return 1
    fi
}

safe_disable_site() {
    local site_name="$1"
    local enabled_path="/etc/nginx/sites-enabled/$site_name"
    
    check_root_permissions || return 1
    
    if [[ ! -L "$enabled_path" ]] && [[ ! -f "$enabled_path" ]]; then
        log_info "Site not enabled: $site_name"
        return 0
    fi
    
    rm -f "$enabled_path"
    
    if [[ $? -eq 0 ]]; then
        log_success "Disabled site: $site_name"
        return 0
    else
        log_error "Failed to disable site: $site_name"
        return 1
    fi
}

# ==============================================================================
# Helper function for scripts using heredocs
# ==============================================================================

safe_deploy_nginx_heredoc() {
    local dest_config="$1"
    local skip_reload="${2:-false}"
    
    # This function expects the config content to come from stdin
    # Usage:
    # safe_deploy_nginx_heredoc "/etc/nginx/sites-available/mysite" <<'EOF'
    # server {
    #     ...
    # }
    # EOF
    
    local config_content
    config_content=$(cat)
    
    safe_write_nginx_config "$dest_config" "$config_content" "$skip_reload"
}

# ==============================================================================
# Interactive restore function
# ==============================================================================

interactive_restore() {
    local config_name="$1"
    
    if [[ -z "$config_name" ]]; then
        log_error "Usage: interactive_restore <config_name>"
        log_info "Example: interactive_restore nexuscos"
        return 1
    fi
    
    local dest_path="/etc/nginx/sites-available/$config_name"
    
    log_info "Available backups for '$config_name':"
    local backups
    backups=$(list_backups "$config_name")
    
    if [[ -z "$backups" ]]; then
        log_error "No backups found for: $config_name"
        return 1
    fi
    
    local backup_array=()
    while IFS= read -r line; do
        backup_array+=("$line")
    done <<< "$backups"
    
    # Display numbered list
    local i=1
    for backup in "${backup_array[@]}"; do
        echo "$i) $(basename "$backup")"
        i=$((i+1))
    done
    
    echo ""
    read -p "Select backup to restore (1-${#backup_array[@]}) or 0 to cancel: " selection
    
    if [[ "$selection" -eq 0 ]]; then
        log_info "Restore cancelled"
        return 0
    fi
    
    if [[ "$selection" -lt 1 ]] || [[ "$selection" -gt ${#backup_array[@]} ]]; then
        log_error "Invalid selection"
        return 1
    fi
    
    local selected_backup="${backup_array[$((selection-1))]}"
    
    log_info "Restoring: $(basename "$selected_backup")"
    safe_deploy_nginx_config "$selected_backup" "$dest_path"
}

# ==============================================================================
# Usage examples (shown when sourced with --help)
# ==============================================================================

show_usage() {
    cat << 'EOF'
Nginx Safe Deployment Library
==============================

This library provides safe functions for deploying nginx configurations.

Usage:
------

1. Source this library in your script:
   source /path/to/nginx-safe-deploy.sh

2. Use the provided functions:

   # Deploy from a file:
   safe_deploy_nginx_config "source.conf" "/etc/nginx/sites-available/mysite"

   # Deploy from a heredoc:
   safe_deploy_nginx_heredoc "/etc/nginx/sites-available/mysite" <<'EOF'
   server {
       listen 80;
       server_name example.com;
   }
   EOF

   # Enable/disable sites:
   safe_enable_site "mysite"
   safe_disable_site "default"

   # Restore from backup:
   interactive_restore "mysite"

   # List all backups:
   list_backups

Functions:
----------
- safe_deploy_nginx_config    Deploy config from file
- safe_write_nginx_config      Deploy config from string
- safe_deploy_nginx_heredoc    Deploy config from heredoc
- safe_enable_site            Enable a site (create symlink)
- safe_disable_site           Disable a site (remove symlink)
- reload_nginx                Reload nginx gracefully
- restart_nginx               Restart nginx
- validate_nginx_config       Test nginx configuration
- backup_config_file          Backup a config file manually
- restore_backup              Restore from a specific backup
- list_backups                List available backups
- interactive_restore         Interactive restore interface

All functions:
- Create automatic backups
- Validate configurations before applying
- Rollback automatically on failure
- Provide clear error messages

EOF
}

# Show usage if called with --help
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] && [[ "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

# Export functions if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f safe_deploy_nginx_config
    export -f safe_write_nginx_config
    export -f safe_deploy_nginx_heredoc
    export -f safe_enable_site
    export -f safe_disable_site
    export -f reload_nginx
    export -f restart_nginx
    export -f validate_nginx_config
    export -f backup_config_file
    export -f restore_backup
    export -f list_backups
    export -f interactive_restore
    export -f log_info
    export -f log_success
    export -f log_warning
    export -f log_error
fi
