# Emergency Stabilization Guide

## 🚨 SSH Connection Failures & System Instability

If you are experiencing SSH connection failures where connections are "instantly closed", this guide provides the safe recovery path.

## ⚠️ DO NOT Attempt These Actions

**NEVER** try these actions when experiencing SSH instability:

- ❌ Repeatedly attempt SSH connections (triggers fail2ban)
- ❌ Run old PF scripts with invalid paths
- ❌ Execute scripts that mix JavaScript in bash context
- ❌ Restart multiple services simultaneously
- ❌ Run scripts that don't validate paths before execution
- ❌ Force service reloads during instability

## ✅ Safe Recovery Path

### Step 1: Access Provider Console

**CRITICAL**: You MUST use your VPS provider's console/panel (IONOS/VPS panel/rescue shell).

SSH is NOT an option during this recovery phase.

### Step 2: Emergency Stabilization Commands

Run these commands in order from the provider console:

```bash
# STEP 1: Disable fail2ban immediately
systemctl stop fail2ban
systemctl disable fail2ban

# STEP 2: Stop the restart storm
systemctl stop apache2
systemctl disable apache2
systemctl stop nginx

# STEP 3: Free memory pressure
docker stop $(docker ps -q)

# STEP 4: Restart SSH cleanly
systemctl restart ssh

# Wait 30 seconds for SSH to stabilize
sleep 30

# STEP 5: Test SSH locally (from console)
ss -tulpn | grep :22
```

Expected output from Step 5:
```
tcp   LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=XXXX,fd=3))
```

### Step 3: Verify System Stability

Before attempting any remote connections:

```bash
# Check memory usage
free -h

# Check OOM killer activity
dmesg | grep -i "killed process"

# Check for restart loops
journalctl -u ssh -n 50 --no-pager

# Verify no fail2ban blocks
iptables -L -n | grep DROP
```

### Step 4: Test SSH Connection

From the console, test SSH locally first:

```bash
ssh -v root@localhost
```

If this works, you can then try from remote.

## 🔧 Safe Platform Fix (PF) Scripts

After SSH is stable, you can safely apply platform fixes using the scripts in this repository.

### IMCU Additive PF

This script safely adds IMCU endpoints without disrupting system services:

```bash
# Navigate to repository
cd /path/to/nexus-cos

# Run the safe additive PF
bash pf-addons/imcu/imcu_additive_pf.sh
```

**What it does:**
- ✅ Validates backend/server.js exists
- ✅ Checks if changes are already applied
- ✅ Creates timestamped backup
- ✅ Inserts endpoints at correct location
- ✅ No service restarts
- ✅ No memory spikes
- ✅ No SSH impact

**What it DOES NOT do:**
- ❌ Restart services
- ❌ Reload configurations
- ❌ Reference invalid paths
- ❌ Mix JavaScript in bash
- ❌ Cause memory pressure
- ❌ Impact running processes

## 🔍 Root Cause Analysis

### Why SSH Connections Were "Instantly Closed"

The connection message:
```
Connection closed by 74.208.155.161 port 22
```

This indicates sshd accepted the TCP connection but the kernel killed the child process.

### The Four Simultaneous Triggers

1. **OOM Killer (Out of Memory)**
   - Multiple services competing for memory
   - Docker containers consuming resources
   - No memory limits configured

2. **systemd Restart Storm**
   - Services failing and auto-restarting
   - nginx, apache2, docker all restarting
   - Plesk retrying operations

3. **Fail2Ban Termination**
   - Failed login attempts triggering bans
   - IP blocking during connection attempts
   - Security daemon active during instability

4. **Invalid Shell Execution**
   - Scripts referencing non-existent paths:
     `/opt/nexus-cos-main/nexus-cos/nexus-cos/puabo-core/node_safe_master_launch_pf.sh`
   - JavaScript code executed in bash context
   - chmod failing on missing files
   - sshd child processes dying from script errors

### The Immediate Trigger

This error in scripts:
```bash
chmod: cannot access '/opt/nexus-cos-main/nexus-cos/nexus-cos/puabo-core/node_safe_master_launch_pf.sh'
```

Attempted to execute non-existent path inside:
- Privileged script
- SSH session
- While nginx failing
- While apache failing
- While docker restarting
- While Plesk retrying
- With fail2ban active

**Result**: Kernel said "enough" → killed sshd child → port 22 drops instantly

## 🛡️ Prevention Guidelines

### Safe Script Requirements

All production scripts MUST:

1. **Path Validation**
   ```bash
   if [ ! -f "$FILE_PATH" ]; then
     echo "File not found, exiting safely"
     exit 0
   fi
   ```

2. **Error Handling**
   ```bash
   set -euo pipefail
   ```

3. **Idempotency Checks**
   ```bash
   if grep -q "MARKER" "$FILE"; then
     echo "Already applied"
     exit 0
   fi
   ```

4. **Backup Before Modify**
   ```bash
   STAMP="$(date +%Y%m%d_%H%M%S)"
   cp "$FILE" "$FILE.bak.$STAMP"
   ```

5. **No Service Disruption**
   - Don't restart services unnecessarily
   - Don't reload configurations during updates
   - Don't mix code contexts (JS in bash)

### Memory Management

```bash
# Check before intensive operations
AVAILABLE_MEM=$(free -m | awk 'NR==2 {print $7}')
if [ "$AVAILABLE_MEM" -lt 1000 ]; then
  echo "Insufficient memory, exiting"
  exit 1
fi
```

### Service Management

```bash
# Check service status before actions
if systemctl is-active --quiet nginx; then
  echo "nginx is running"
else
  echo "nginx is not running"
fi

# Don't restart multiple services at once
# Restart one at a time with verification
```

## 📝 Post-Recovery Checklist

After successfully recovering SSH access:

- [ ] Verify system memory is stable (`free -h`)
- [ ] Check no restart loops (`systemctl status`)
- [ ] Confirm fail2ban is controlled (disabled or configured)
- [ ] Review all scripts for invalid paths
- [ ] Test scripts in non-production first
- [ ] Document any custom paths/configurations
- [ ] Set up monitoring for memory/services
- [ ] Configure resource limits for containers
- [ ] Regular backup verification

## 🆘 If Recovery Fails

If the above steps don't resolve SSH access:

1. Contact VPS provider support
2. Request console/KVM access
3. Check system logs via console
4. Consider rescue mode boot
5. Verify network configuration
6. Check firewall rules
7. Review audit logs

## 📚 Related Documentation

- `pf-addons/README.md` - Safe PF script guidelines
- `pf-addons/imcu/imcu_additive_pf.sh` - Example safe script
- Repository root `.gitignore` - Excludes backup files

## ⚠️ Important Notes

1. **This is process death, not authentication issues**
2. **This is not a networking problem**
3. **The kernel killed sshd children processes**
4. **Old PF scripts are dangerous in this state**
5. **Provider console is the ONLY safe recovery method**

## 🎯 Summary

**Problem**: Four simultaneous system issues causing SSH child process death
**Solution**: Provider console emergency stabilization + safe PF scripts
**Prevention**: Path validation, error handling, no service disruption
**Recovery Time**: ~5-10 minutes with console access
