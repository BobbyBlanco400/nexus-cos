# Nginx Deployment Scripts Investigation Report

## Executive Summary

This report documents the investigation into Nginx configuration deployment scripts that have been causing configuration overwrites and system issues in the Nexus COS project.

**Investigation Date:** 2026-01-04  
**Status:** ✅ COMPLETE  
**Scripts Identified:** 7 primary culprits + multiple secondary scripts

---

## 🔍 Investigation Methodology

Following the problem statement requirements, we executed four systematic searches:

### Step 1: Scripts Touching `/etc/nginx`
```bash
grep -R "etc/nginx" -n /opt/nexus-cos
```
**Results:** 100+ references found across scripts and documentation

### Step 2: Copy Commands Involving Nginx
```bash
grep -R "cp " -n /opt/nexus-cos | grep nginx
```
**Results:** 80+ copy operations found

### Step 3: Deploy Scripts Involving Nginx
```bash
grep -R "deploy" -n /opt/nexus-cos | grep nginx
```
**Results:** 70+ deployment references found

### Step 4: Scripts Restarting Nginx
```bash
grep -R "systemctl restart nginx" -n /opt/nexus-cos
```
**Results:** 40+ restart commands found

---

## 🎯 Primary Culprits - The Scripts That Broke Everything

### 1. **`trae-solo-bulletproof-deploy.sh`** ⚠️ HIGHEST RISK
- **Line:** 543
- **Operation:** `cat > /etc/nginx/sites-available/nexuscos << 'NGINX_EOF'`
- **Risk Level:** 🔴 CRITICAL
- **Issue:** 
  - Completely overwrites existing config with hardcoded template
  - Uses heredoc that replaces everything from lines 543-641
  - Does create backup (line 537-540) but still destructive
  - Also calls `systemctl restart nginx` (line 131)
- **Impact:** Total config replacement, loses all customizations

### 2. **`DEPLOY_LANDING_PAGES_NOW.sh`** ⚠️ HIGH RISK
- **Line:** 57
- **Operation:** `cp "${REPO_ROOT}/deployment/nginx/nexuscos-unified.conf" /etc/nginx/sites-available/nexuscos`
- **Risk Level:** 🔴 HIGH
- **Issue:**
  - Direct file copy without checking existing config
  - No backup mechanism
  - No validation of what's being replaced
  - Can be run with one command (designed for quick deployment)
- **Impact:** Replaces working config with template

### 3. **`deploy-direct.sh`** ⚠️ HIGH RISK
- **Lines:** 210-259
- **Operation:** `cat > "$NGINX_CONF" << 'EOF'` (where NGINX_CONF="/etc/nginx/sites-available/nexuscos.conf")
- **Risk Level:** 🔴 HIGH
- **Issue:**
  - Stops nginx first (line 202)
  - Creates new config from scratch
  - Hardcoded SSL paths that may not exist
  - No backup before overwrite
- **Impact:** Complete config replacement, may break SSL

### 4. **`master-fix-trae-solo.sh`**
- **Line:** 517
- **Operation:** `cat > /etc/nginx/sites-available/nexuscos << 'EOF'`
- **Risk Level:** 🟡 MEDIUM
- **Issue:** Similar heredoc pattern, overwrites config

### 5. **`production-deploy-firewall.sh`**
- **Line:** 68
- **Operation:** `cat >/etc/nginx/sites-available/nexuscos <<'EOF'`
- **Risk Level:** 🟡 MEDIUM
- **Issue:** Overwrites config without validation

### 6. **`emergency-fix-react-nginx.sh`**
- **Line:** 50
- **Operation:** `cat > /etc/nginx/sites-available/nexuscos << 'EOF'`
- **Risk Level:** 🟡 MEDIUM
- **Issue:** Emergency script that may be run without thinking

### 7. **`NEXUS_MASTER_ONE_SHOT.sh`**
- **Lines:** 381, 464
- **Operation:** `cat > /etc/nginx/sites-available/nexus-master.conf << 'EOF'`
- **Risk Level:** 🟡 MEDIUM
- **Issue:** Different config file but same pattern

---

## 🔧 Common Anti-Patterns Found

### Destructive Write Operations
All scripts use one of these dangerous patterns:
```bash
# Pattern 1: Heredoc overwrite
cat > /etc/nginx/sites-available/nexuscos << 'EOF'
# ... new config ...
EOF

# Pattern 2: Force copy
cp source.conf /etc/nginx/sites-available/nexuscos

# Pattern 3: Direct write
echo "config" > /etc/nginx/sites-available/nexuscos
```

### Missing Safety Mechanisms
- ❌ No validation of existing working config
- ❌ No mechanism to preserve custom modifications
- ❌ Inconsistent or missing backup mechanisms
- ❌ No rollback capability on failure
- ❌ No dry-run or preview mode
- ❌ No confirmation prompts for destructive operations

### Inconsistent Backup Approach
```bash
# Some scripts do this (good):
if [[ -f "/etc/nginx/sites-available/nexuscos" ]]; then
    cp /etc/nginx/sites-available/nexuscos \
       "/etc/nginx/sites-available/nexuscos.backup.$(date +%Y%m%d-%H%M%S)"
fi

# But then immediately overwrite anyway (bad):
cat > /etc/nginx/sites-available/nexuscos << 'EOF'
```

---

## 📊 Analysis Results

### Files Most Frequently Modified
1. `/etc/nginx/sites-available/nexuscos` - Modified by 6+ scripts
2. `/etc/nginx/sites-available/nexuscos.conf` - Modified by 3+ scripts
3. `/etc/nginx/conf.d/*` - Modified by multiple scripts
4. `/etc/nginx/nginx.conf` - Modified by configuration update scripts

### Nginx Restart Patterns
40+ scripts contain `systemctl restart nginx`, often without:
- Testing config first (`nginx -t`)
- Checking if nginx is even installed
- Error handling if restart fails
- Waiting for service to be ready

---

## 🛡️ Recommended Fixes

### Fix Strategy for Each Script

#### For `trae-solo-bulletproof-deploy.sh`:
```bash
# BEFORE (line 543):
cat > /etc/nginx/sites-available/nexuscos << 'NGINX_EOF'

# AFTER: Add safety checks
deploy_nginx_config() {
    local CONFIG_FILE="/etc/nginx/sites-available/nexuscos"
    local BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d-%H%M%S)"
    
    # 1. Test if nginx is installed
    if ! command -v nginx &> /dev/null; then
        print_warning "Nginx not installed, skipping config deployment"
        return 1
    fi
    
    # 2. Always backup existing config
    if [[ -f "$CONFIG_FILE" ]]; then
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        print_info "Backed up to: $BACKUP_FILE"
    fi
    
    # 3. Write new config to temp file first
    local TEMP_CONFIG=$(mktemp)
    cat > "$TEMP_CONFIG" << 'NGINX_EOF'
    # ... config content ...
NGINX_EOF
    
    # 4. Test the new config
    nginx -t -c "$TEMP_CONFIG" 2>&1
    if [[ $? -ne 0 ]]; then
        print_error "New config is invalid, keeping current config"
        rm "$TEMP_CONFIG"
        return 1
    fi
    
    # 5. Deploy the validated config
    cp "$TEMP_CONFIG" "$CONFIG_FILE"
    rm "$TEMP_CONFIG"
    
    # 6. Test full nginx config
    if ! nginx -t; then
        print_error "Config test failed, rolling back"
        [[ -f "$BACKUP_FILE" ]] && cp "$BACKUP_FILE" "$CONFIG_FILE"
        return 1
    fi
    
    # 7. Reload (not restart) nginx
    if systemctl is-active --quiet nginx; then
        systemctl reload nginx
    else
        systemctl restart nginx
    fi
}
```

#### For `DEPLOY_LANDING_PAGES_NOW.sh`:
```bash
# BEFORE (line 57):
cp "${REPO_ROOT}/deployment/nginx/nexuscos-unified.conf" /etc/nginx/sites-available/nexuscos

# AFTER: Add validation and backup
deploy_nginx_safe() {
    local SOURCE="${REPO_ROOT}/deployment/nginx/nexuscos-unified.conf"
    local DEST="/etc/nginx/sites-available/nexuscos"
    local BACKUP="${DEST}.backup.$(date +%Y%m%d-%H%M%S)"
    
    # Check source exists
    if [[ ! -f "$SOURCE" ]]; then
        echo -e "${RED}✗ Source config not found: $SOURCE${NC}"
        return 1
    fi
    
    # Backup existing
    if [[ -f "$DEST" ]]; then
        cp "$DEST" "$BACKUP"
        echo -e "${GREEN}✓${NC} Backed up to: $BACKUP"
    fi
    
    # Copy new config
    cp "$SOURCE" "$DEST"
    
    # Validate
    if ! nginx -t &>/dev/null; then
        echo -e "${RED}✗ Config validation failed, rolling back${NC}"
        [[ -f "$BACKUP" ]] && cp "$BACKUP" "$DEST"
        nginx -t
        return 1
    fi
    
    echo -e "${GREEN}✓${NC} Config deployed and validated"
}

# Replace line 57 with:
deploy_nginx_safe || exit 1
```

### General Safety Pattern Template

```bash
#!/bin/bash
# Safe Nginx Config Deployment Template

safe_deploy_nginx_config() {
    local source_config="$1"
    local dest_config="$2"
    local backup_dir="/etc/nginx/backups"
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    # Generate backup filename
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_file="${backup_dir}/$(basename "$dest_config").${timestamp}"
    
    # Step 1: Validate inputs
    if [[ ! -f "$source_config" ]]; then
        echo "ERROR: Source config not found: $source_config"
        return 1
    fi
    
    # Step 2: Backup existing config
    if [[ -f "$dest_config" ]]; then
        cp "$dest_config" "$backup_file"
        echo "Backed up existing config to: $backup_file"
    fi
    
    # Step 3: Test new config syntax
    if [[ "$source_config" == *".conf" ]]; then
        # For individual site configs, we can't test in isolation easily
        # So we'll test after copying
        :
    fi
    
    # Step 4: Copy new config
    cp "$source_config" "$dest_config"
    
    # Step 5: Test full nginx configuration
    if ! nginx -t 2>/dev/null; then
        echo "ERROR: New config failed validation"
        nginx -t # Show the error
        
        # Rollback
        if [[ -f "$backup_file" ]]; then
            echo "Rolling back to previous config"
            cp "$backup_file" "$dest_config"
        fi
        return 1
    fi
    
    # Step 6: Reload nginx gracefully
    if systemctl is-active --quiet nginx; then
        systemctl reload nginx
    else
        systemctl start nginx
    fi
    
    echo "✓ Nginx config deployed successfully"
    return 0
}
```

---

## 🚀 Recommended Implementation Plan

### Phase 1: Immediate Fixes (Priority 1)
1. Add backup mechanisms to all 7 primary scripts
2. Add `nginx -t` validation before any restart
3. Add rollback on failure

### Phase 2: Safety Improvements (Priority 2)
1. Create shared utility function for safe nginx deployment
2. Replace all `cat >` operations with safe function calls
3. Add confirmation prompts for production deployments

### Phase 3: Process Improvements (Priority 3)
1. Document which script should be used in which scenario
2. Create pre-deployment checklist
3. Add dry-run mode to all deployment scripts
4. Implement config versioning

---

## 📝 Additional Scripts Requiring Attention

### Scripts with nginx operations:
- `fix-nginx-deployment.sh` - Copies from deployment/nginx/
- `bulletproof-pf-deploy.sh` - Manages SSL directories  
- `deployment/nginx/scripts/deploy-vanilla.sh` - Lines 37, 46, 74
- `deployment/nginx/scripts/deploy-plesk.sh` - Lines 53, 62, 90
- `scripts/pf-fix-nginx-headers-redirect.sh` - Lines 149, 205, 240
- `scripts/pf-update-nginx-routes.sh` - Lines 99, 193
- `scripts/update-nginx-puabo-nexus-routes.sh` - Lines 102, 269

### README/Documentation mentions:
- Multiple README files contain one-liner copy commands
- These should be updated to reference safe deployment scripts

---

## 🔄 The Cascade Effect

**How the problem propagates:**

1. Developer runs one of the problematic scripts (e.g., `DEPLOY_LANDING_PAGES_NOW.sh`)
2. Script overwrites working nginx config with template
3. Template may have wrong SSL paths, wrong ports, or missing locations
4. Script restarts nginx
5. Nginx either fails to start, or starts with broken config
6. Services become inaccessible (502/503 errors)
7. Developer tries to fix by running another deployment script
8. That script also overwrites config, making it worse
9. Cycle repeats...

**Root Cause:** Too many scripts doing the same thing in slightly different ways, all destructively.

---

## ✅ Success Criteria

After implementing fixes, these should be true:

- [ ] No script can overwrite nginx config without creating a backup
- [ ] All scripts validate nginx config before applying changes
- [ ] All scripts have rollback capability on failure
- [ ] Only one canonical "safe deploy" function is used
- [ ] All dangerous one-liners are removed from documentation
- [ ] Deployment scripts log all actions to audit trail
- [ ] Scripts fail safely without leaving system in broken state

---

## 📚 References

- Search Results: See investigation commands above
- Config Files: `/etc/nginx/sites-available/*`
- Backup Location: `/etc/nginx/backups/` (recommended)
- Scripts Directory: `/home/runner/work/nexus-cos/nexus-cos/`

---

**Report Prepared By:** GitHub Copilot  
**Review Status:** Ready for Implementation  
**Next Action:** Create fix implementation PRs for all 7 scripts
