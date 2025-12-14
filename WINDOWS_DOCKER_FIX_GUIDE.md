# Windows Docker Desktop - API Connection Fix Guide

## 🎯 Quick Start

**Experiencing this error?**
```
failed to connect to the docker API at npipe:////./pipe/docker_engine
```

**Quick fix for Windows users:**

```powershell
# Run PowerShell as Administrator
cd C:\path\to\nexus-cos
.\Fix-DockerDesktopWindows.ps1
```

That's it! The script handles everything and verifies Docker daemon health.

---

## 📚 What This Guide Covers

This comprehensive guide provides step-by-step procedures to fix Docker Desktop connectivity issues on Windows, specifically the `npipe:////./pipe/docker_engine` error that prevents Docker daemon communication.

### Key Topics:
1. **[Quick Automated Fix](#automated-fix)** - Use the PowerShell script
2. **[Manual Step-by-Step Fix](#manual-fix-procedure)** - For hands-on troubleshooting
3. **[Validation & Testing](#validation)** - Verify your Docker installation
4. **[Advanced Troubleshooting](#advanced-troubleshooting)** - When basic fixes don't work
5. **[Common Issues](#common-issues--solutions)** - Quick reference for specific errors

---

## 🚨 The Problem

### Symptoms:
- ✗ `docker version` shows Client but no Server section
- ✗ `docker info` returns `error during connect: ... npipe:////./pipe/docker_engine`
- ✗ Docker Desktop icon shows error state
- ✗ Docker commands hang or timeout
- ✗ `docker compose` commands fail

### Root Causes:
1. **Stale Docker processes** - Old Docker processes blocking named pipe
2. **WSL2 issues** - Docker Desktop requires WSL2 backend on Windows
3. **Missing Windows features** - Hyper-V, WSL, or VirtualMachinePlatform not enabled
4. **Corrupted WSL distros** - docker-desktop or docker-desktop-data in bad state
5. **Named pipe blockage** - Windows named pipe communication failure
6. **Wrong engine mode** - Docker stuck on Windows engine instead of Linux

---

## 🤖 Automated Fix

### Prerequisites:
- Windows 10 (build 19041+) or Windows 11
- Administrator privileges
- BIOS virtualization enabled (Intel VT-x / AMD-V)

### Run the Fix Script:

```powershell
# 1. Open PowerShell as Administrator (right-click → Run as Administrator)

# 2. Navigate to the repository
cd C:\path\to\nexus-cos

# 3. Run the automated fix
.\Fix-DockerDesktopWindows.ps1

# Optional: Skip feature checks if already enabled
.\Fix-DockerDesktopWindows.ps1 -SkipFeatureCheck

# Optional: Skip WSL reset for lighter troubleshooting
.\Fix-DockerDesktopWindows.ps1 -SkipWSLReset

# Optional: Custom Docker Desktop installation path
.\Fix-DockerDesktopWindows.ps1 -DockerPath "D:\Docker\Docker"
```

### What the Script Does:
1. ✅ Stops all stale Docker processes
2. ✅ Terminates WSL Docker instances
3. ✅ Enables required Windows features (WSL, Hyper-V, VirtualMachinePlatform)
4. ✅ Configures WSL2 as default
5. ✅ Hard resets Docker Desktop WSL distributions
6. ✅ Starts Docker Desktop with Linux engine
7. ✅ Verifies daemon health
8. ✅ Tests with hello-world container
9. ✅ Checks Docker Compose availability

### Expected Output:
```
╔════════════════════════════════════════════════════════════════╗
║        🐋 Docker Desktop Windows - API Connection Fix         ║
║  Resolves: npipe:////./pipe/docker_engine connection error    ║
╚════════════════════════════════════════════════════════════════╝

🔧 Stopping stale Docker processes...
✅ Docker processes stopped

🔧 Terminating WSL Docker instances...
✅ WSL Docker instances terminated

🔧 Checking and enabling required Windows features...
✅ Windows features are enabled

🔧 Configuring WSL2 backend...
✅ WSL2 set as default version

🔧 Resetting Docker Desktop WSL distributions...
✅ Docker Desktop WSL distros unregistered

🔧 Starting Docker Desktop...
✅ Docker Desktop started
✅ Docker Desktop is responding

🔧 Verifying Docker daemon health...
✅ Docker daemon is healthy!

🔧 Running hello-world test...
✅ Hello-world container ran successfully!

╔════════════════════════════════════════════════════════════════╗
║                    ✅ FIX COMPLETE                             ║
╚════════════════════════════════════════════════════════════════╝
```

---

## 🔧 Manual Fix Procedure

If you prefer to run commands manually or the script doesn't work, follow these steps:

### Step 1: Stop Stale Processes

Open PowerShell as Administrator:

```powershell
# Stop Docker processes
Stop-Process -Name "Docker" -ErrorAction SilentlyContinue
Stop-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
Stop-Process -Name "com.docker.service" -ErrorAction SilentlyContinue

# Terminate WSL Docker instances
wsl --terminate docker-desktop
wsl --terminate docker-desktop-data
```

**Expected result:** All Docker processes terminated cleanly.

---

### Step 2: Enable Required Windows Features

```powershell
# Enable WSL
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart

# Enable Virtual Machine Platform
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart

# Enable Hyper-V (if available)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart
```

**Important:** If prompted to restart, you MUST restart Windows before continuing.

```powershell
# Restart Windows
Restart-Computer
```

---

### Step 3: Install and Configure WSL2

After restart (if needed):

```powershell
# Check if WSL is installed
wsl --version

# If WSL not installed, install it:
wsl --install

# Set WSL2 as default version
wsl --set-default-version 2

# Verify WSL2 is active
wsl -l -v
```

**Expected output:**
```
  NAME                   STATE           VERSION
* Ubuntu                 Stopped         2
```

The VERSION should show `2` for your default distribution.

---

### Step 4: Hard Reset Docker Desktop WSL Distros

This forces clean recreation of the Docker engine:

```powershell
# Unregister Docker WSL distributions
wsl --unregister docker-desktop
wsl --unregister docker-desktop-data
```

**Note:** This removes Docker's internal WSL instances. Docker Desktop will recreate them on next start.

---

### Step 5: Start Docker Desktop

```powershell
# Start Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Wait 60-120 seconds for initialization
Start-Sleep -Seconds 90
```

**During this time:**
- Docker Desktop icon should appear in system tray
- Icon will show "Starting..." status
- Wait until icon shows "Docker Desktop is running"

---

### Step 6: Switch to Linux Engine (if needed)

If Docker is stuck on Windows engine:

```powershell
# Force switch to Linux engine
& "C:\Program Files\Docker\Docker\DockerCli.exe" -SwitchLinuxEngine

# Wait a few seconds
Start-Sleep -Seconds 10
```

---

### Step 7: Verify Daemon Health

```powershell
# Check Docker version
& "C:\Program Files\Docker\Docker\resources\bin\docker.exe" version

# Check Docker info
& "C:\Program Files\Docker\Docker\resources\bin\docker.exe" info
```

**Success indicators:**
- `docker version` shows both Client and **Server** sections
- `docker info` displays server details without npipe errors
- Server shows "Operating System: Docker Desktop" or similar

**Example successful output:**
```
Client:
 Version:           24.0.6
 API version:       1.43
 ...

Server: Docker Desktop
 Engine:
  Version:          24.0.6
  API version:      1.43 (minimum version 1.12)
  ...
```

---

### Step 8: Test with Hello World

```powershell
# Run hello-world container
& "C:\Program Files\Docker\Docker\resources\bin\docker.exe" run --rm hello-world
```

**Expected output:**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

---

### Step 9: Verify Docker Compose

```powershell
# Check for Docker Compose plugin
Test-Path "C:\Program Files\Docker\Docker\cli-plugins\docker-compose.exe"

# If exists, test it:
& "C:\Program Files\Docker\Docker\cli-plugins\docker-compose.exe" version

# Or use classic binary:
& "C:\Program Files\Docker\Docker\resources\bin\docker-compose.exe" --version
```

**After daemon is healthy, open a new PowerShell window and test:**
```powershell
docker compose version
```

---

## ✅ Validation

### Complete Validation Checklist:

```powershell
# 1. Docker version shows server
docker version
# ✓ Both Client and Server sections present

# 2. Docker info shows details
docker info
# ✓ Shows "Server" section
# ✓ No npipe errors
# ✓ Shows storage driver, kernel version, etc.

# 3. Hello-world runs
docker run --rm hello-world
# ✓ Prints "Hello from Docker!" message

# 4. Docker Compose works
docker compose version
# ✓ Shows version like "Docker Compose version v2.x.x"

# 5. List containers works
docker ps -a
# ✓ Shows container list (may be empty)

# 6. List images works
docker images
# ✓ Shows image list
```

### Success Criteria:

All commands should:
- ✅ Execute without "npipe" errors
- ✅ Return expected output
- ✅ Complete in reasonable time (< 5 seconds)
- ✅ Show Docker daemon is running

---

## 🚑 Advanced Troubleshooting

### Issue: Still Getting npipe Errors After Fix

#### Solution 1: Reset Winsock

```powershell
# Reset Windows networking stack
netsh winsock reset

# Reboot
Restart-Computer
```

After reboot, start Docker Desktop and test again.

---

#### Solution 2: Clear Docker Desktop State

```powershell
# Stop Docker Desktop completely
Stop-Process -Name "Docker Desktop" -Force

# Backup and delete settings
Copy-Item "$env:AppData\Docker\settings.json" "$env:AppData\Docker\settings.json.backup"
Remove-Item "$env:AppData\Docker\settings.json" -Force

# Delete service state
Remove-Item "$env:ProgramData\DockerDesktop\service.txt" -Force -ErrorAction SilentlyContinue

# Start Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
```

---

#### Solution 3: Reinstall via Package Manager

**Using winget:**
```powershell
# Uninstall current version
winget uninstall --id Docker.DockerDesktop

# Reinstall latest version
winget install --id Docker.DockerDesktop -e
```

**Using Chocolatey:**
```powershell
# Uninstall
choco uninstall docker-desktop -y

# Reinstall
choco install docker-desktop -y
```

---

### Issue: Windows Features Won't Enable

#### Check Current State:
```powershell
# Check WSL feature
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

# Check Hyper-V
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

# Check Virtual Machine Platform
Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
```

#### Manual Enable via DISM:
```powershell
# Enable WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Enable Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Enable Hyper-V
dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart

# Restart required
Restart-Computer
```

---

### Issue: BIOS Virtualization Not Enabled

Docker Desktop requires hardware virtualization (Intel VT-x or AMD-V) to be enabled in BIOS.

#### Check Virtualization Status:
```powershell
# Check if virtualization is enabled
Get-ComputerInfo | Select-Object -Property CsProcessors, CsSystemType, HyperVisorPresent, HyperVRequirementVirtualizationFirmwareEnabled

# Or use systeminfo
systeminfo | findstr /i "Hyper-V"
```

#### If Virtualization is Disabled:
1. Restart computer
2. Enter BIOS/UEFI setup (usually F2, F10, Del, or Esc during boot)
3. Find virtualization setting:
   - **Intel**: Look for "Intel VT-x", "Intel Virtualization Technology", or "VT-x"
   - **AMD**: Look for "AMD-V", "SVM Mode", or "Virtualization"
4. Enable the setting
5. Save and exit BIOS
6. Boot Windows and re-run the fix script

---

### Issue: Corporate Antivirus Blocking Docker

Some enterprise antivirus or endpoint protection software blocks Docker's named pipes.

#### Solution:
1. Contact IT/Security team
2. Request whitelist for Docker Desktop:
   - Process: `Docker Desktop.exe`
   - Process: `com.docker.service.exe`
   - Named pipe: `\\.\pipe\docker_engine`
   - Directory: `C:\Program Files\Docker\Docker\`
3. Temporary test: Disable AV temporarily and test if Docker works
   - **IMPORTANT**: Only for testing! Re-enable AV immediately after

---

### Issue: WSL2 Kernel Update Required

#### Download and Install WSL2 Kernel:
```powershell
# Download URL (or visit Microsoft docs)
$wslUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"

# Download
Invoke-WebRequest -Uri $wslUpdateUrl -OutFile "$env:TEMP\wsl_update_x64.msi"

# Install
Start-Process msiexec.exe -ArgumentList "/i", "$env:TEMP\wsl_update_x64.msi", "/quiet" -Wait

# Verify
wsl --set-default-version 2
```

---

### Issue: Docker Desktop Crashes on Startup

#### Check Docker Desktop Logs:
```powershell
# View recent logs
Get-Content "$env:AppData\Docker\log.txt" -Tail 50

# Or open in notepad
notepad "$env:AppData\Docker\log.txt"
```

Look for error messages indicating:
- Memory issues
- Disk space issues
- Port conflicts (especially port 2375, 2376)
- WSL integration failures

#### Common Fixes:
```powershell
# Increase Docker Desktop memory allocation
# Open Docker Desktop → Settings → Resources → Advanced
# Increase Memory to at least 4GB

# Free up disk space
# Docker Desktop → Settings → Resources → Advanced
# Change Disk image location if needed

# Reset to factory defaults
# Docker Desktop → Troubleshoot → Reset to factory defaults
```

---

## 🔍 Common Issues & Solutions

### Error: "WSL 2 installation is incomplete"

**Cause:** WSL2 kernel update not installed

**Fix:**
```powershell
# Install WSL2 kernel update
wsl --update

# Or download from Microsoft:
# https://aka.ms/wsl2kernel
```

---

### Error: "Hardware assisted virtualization... is not enabled"

**Cause:** BIOS virtualization disabled

**Fix:** Enable VT-x/AMD-V in BIOS (see [BIOS Virtualization](#issue-bios-virtualization-not-enabled))

---

### Error: "The service cannot be started... Access is denied"

**Cause:** Insufficient permissions

**Fix:**
```powershell
# Run PowerShell as Administrator
# Right-click PowerShell → Run as Administrator
```

---

### Error: "Cannot connect to Docker daemon... Is the docker daemon running?"

**Cause:** Docker Desktop not started or failed to start

**Fix:**
```powershell
# Start Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Wait for initialization
Start-Sleep -Seconds 60

# Check if running
Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
```

---

### Error: docker-desktop WSL distro exited with code 1

**Cause:** Corrupted docker-desktop distro

**Fix:**
```powershell
# Unregister and let Docker recreate
wsl --unregister docker-desktop
wsl --unregister docker-desktop-data

# Restart Docker Desktop
Stop-Process -Name "Docker Desktop" -Force
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
```

---

### Error: "An error occurred mounting one of your file systems"

**Cause:** WSL2 filesystem issues

**Fix:**
```powershell
# Terminate all WSL instances
wsl --shutdown

# Wait 10 seconds
Start-Sleep -Seconds 10

# Restart Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
```

---

### Error: "Port is already allocated"

**Cause:** Another service using Docker's ports

**Fix:**
```powershell
# Find process using port 2375 or 2376
netstat -ano | findstr ":2375"
netstat -ano | findstr ":2376"

# Note the PID and stop the process
Stop-Process -Id <PID> -Force

# Or configure Docker to use different ports
# Docker Desktop → Settings → Docker Engine → edit daemon.json
```

---

## 📋 Pre-Flight Checklist

Before attempting fixes, verify:

- [ ] Windows 10 (build 19041+) or Windows 11
- [ ] 64-bit operating system
- [ ] At least 4GB RAM available
- [ ] At least 10GB free disk space
- [ ] BIOS virtualization enabled (VT-x/AMD-V)
- [ ] Administrator access to Windows
- [ ] No corporate policies blocking Docker
- [ ] Stable internet connection (for pulling images)

---

## 🎓 Understanding the Fix

### Why WSL2?
Docker Desktop for Windows uses WSL2 (Windows Subsystem for Linux 2) to run the Linux-based Docker engine. WSL2 provides:
- Better performance than Hyper-V
- Faster file system operations
- Native Linux kernel
- Seamless integration with Windows

### Why Reset WSL Distros?
The `docker-desktop` and `docker-desktop-data` WSL distributions can become corrupted or misconfigured. Unregistering them forces Docker Desktop to recreate them from scratch, resolving most configuration issues.

### Why Linux Engine?
Docker containers are Linux-based. While Docker Desktop supports Windows containers, most images and workflows expect the Linux engine. The Linux engine provides broader compatibility.

### Named Pipes Explained
On Windows, Docker uses named pipes (`\\.\pipe\docker_engine`) for inter-process communication. When this pipe is blocked, corrupted, or in use by a stale process, Docker commands cannot reach the daemon.

---

## 🛡️ Post-Fix Best Practices

### Keep Docker Updated
```powershell
# Check for updates regularly
# Docker Desktop → Check for updates

# Or via winget
winget upgrade --id Docker.DockerDesktop
```

### Monitor Docker Resource Usage
```powershell
# Check Docker disk usage
docker system df

# Clean up periodically
docker system prune -a

# Or through GUI
# Docker Desktop → Troubleshoot → Clean / Purge data
```

### Regular WSL Maintenance
```powershell
# Update WSL
wsl --update

# Compact WSL disk images
wsl --shutdown
Optimize-VHD -Path "$env:LOCALAPPDATA\Docker\wsl\data\ext4.vhdx" -Mode Full
```

### Backup Docker Volumes
```powershell
# List volumes
docker volume ls

# Backup important volumes
docker run --rm -v my-volume:/data -v C:\backup:/backup alpine tar czf /backup/my-volume.tar.gz /data
```

---

## 📞 Getting Help

### Docker Desktop Built-in Diagnostics
```
Docker Desktop → Troubleshoot → Get support
```

### Gather Diagnostic Information
```powershell
# System info
systeminfo > docker-diag-systeminfo.txt

# Docker version
docker version > docker-diag-version.txt 2>&1

# Docker info
docker info > docker-diag-info.txt 2>&1

# WSL info
wsl -l -v > docker-diag-wsl.txt

# Windows features
Get-WindowsOptionalFeature -Online | Where-Object State -eq "Enabled" > docker-diag-features.txt
```

### Useful Resources
- [Docker Desktop for Windows Documentation](https://docs.docker.com/desktop/windows/)
- [WSL2 Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Docker Community Forums](https://forums.docker.com/)
- [GitHub Issues - Docker for Windows](https://github.com/docker/for-win/issues)

---

## 🎯 Success Indicators

### Your Docker Desktop is working correctly if:

✅ **Docker Desktop UI shows "Running"**  
The system tray icon should be green/blue and show "Docker Desktop is running"

✅ **CLI commands work without npipe errors**  
```powershell
docker version  # Shows Client + Server
docker info     # Shows detailed server info
docker ps       # Lists containers (even if empty)
```

✅ **Hello-world container runs successfully**  
```powershell
docker run --rm hello-world  # Prints success message
```

✅ **Docker Compose is functional**  
```powershell
docker compose version  # Shows version number
```

✅ **Can pull and run images**  
```powershell
docker pull nginx:alpine
docker run -d -p 8080:80 nginx:alpine
# Should start container and respond on http://localhost:8080
```

---

## 📊 Deployment Scenarios

### Scenario 1: Fresh Docker Desktop Installation

```powershell
# 1. Install Docker Desktop
winget install --id Docker.DockerDesktop -e

# 2. Run the fix script to ensure proper setup
.\Fix-DockerDesktopWindows.ps1

# 3. Verify
docker run --rm hello-world
```

---

### Scenario 2: Existing Installation with npipe Errors

```powershell
# 1. Run the full fix
.\Fix-DockerDesktopWindows.ps1

# 2. If still failing, try advanced reset
.\Fix-DockerDesktopWindows.ps1
# Then manually clear state (see Advanced Troubleshooting)

# 3. Last resort: Reinstall
winget install --id Docker.DockerDesktop -e --force
```

---

### Scenario 3: Corporate/Enterprise Environment

```powershell
# 1. Check with IT about restrictions
# - Firewall rules
# - Antivirus exclusions
# - Group policies

# 2. Request necessary permissions/exclusions

# 3. Run fix with feature check skipped (IT may have enabled features)
.\Fix-DockerDesktopWindows.ps1 -SkipFeatureCheck

# 4. Verify with IT-approved testing
docker run --rm hello-world
```

---

### Scenario 4: Development Machine with Multiple Docker Installations

```powershell
# 1. Ensure only one Docker Desktop is installed
winget list Docker

# 2. Uninstall conflicting installations (Docker Toolbox, etc.)

# 3. Clean up old Docker configurations
Remove-Item "$env:USERPROFILE\.docker" -Recurse -Force -ErrorAction SilentlyContinue

# 4. Run the fix
.\Fix-DockerDesktopWindows.ps1

# 5. Verify
docker info
```

---

## 🔐 Security Considerations

### Named Pipe Security
- The `\\.\pipe\docker_engine` named pipe is only accessible by administrators
- This prevents non-admin users from controlling Docker
- Ensure only trusted users have admin access

### WSL2 Security
- WSL2 distributions run in isolated VM
- Keep WSL2 kernel updated: `wsl --update`
- Don't disable Windows Defender for WSL2

### Docker Image Security
```powershell
# Always verify image sources
docker pull nginx:alpine  # Official images only

# Scan images for vulnerabilities (Docker Scout)
docker scout quickview nginx:alpine

# Use minimal base images
# Prefer: alpine, distroless
# Avoid: latest tag in production
```

---

## 📈 Performance Optimization

### Allocate Adequate Resources
```
Docker Desktop → Settings → Resources → Advanced
- CPUs: At least 2 (4+ recommended)
- Memory: At least 4GB (8GB+ recommended)
- Swap: 1-2GB
- Disk image size: 64GB+ (depends on usage)
```

### Optimize WSL2 Memory Usage
Create or edit `%USERPROFILE%\.wslconfig`:
```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
localhostForwarding=true
```

### Optimize Docker Daemon
Edit daemon.json (Docker Desktop → Settings → Docker Engine):
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
```

---

## 🎉 Result

Once deployed successfully:
- ✅ Docker daemon accessible via npipe
- ✅ `docker` commands work without errors
- ✅ `docker compose` functional
- ✅ WSL2 backend configured correctly
- ✅ Container operations (pull, run, build) working
- ✅ **READY FOR DEVELOPMENT**

---

**Priority**: 🔴 CRITICAL  
**Time to Deploy**: 10-20 minutes (including potential Windows restart)  
**Confidence**: 95%  
**Impact**: Unblocks Docker-based development on Windows immediately  

---

*This comprehensive guide provides everything needed to resolve Windows Docker Desktop API connection issues and restore full functionality.*
