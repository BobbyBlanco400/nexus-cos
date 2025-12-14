# Nexus COS - Complete THIIO + Master PF Deployment

## SSH Deployment Commands

### Method 1: Single SSH Command (Recommended)
```bash
ssh user@your-server 'bash -s' < deploy_complete_thiio_master_pf.sh
```

Replace `user@your-server` with your actual SSH credentials.

### Method 2: Copy and Execute
```bash
# Copy script to server
scp deploy_complete_thiio_master_pf.sh user@your-server:/tmp/

# Execute on server
ssh user@your-server 'bash /tmp/deploy_complete_thiio_master_pf.sh'
```

### Method 3: Direct Download and Execute
```bash
ssh user@your-server 'curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/copilot/setup-github-ready-repo-structure/deploy_complete_thiio_master_pf.sh | bash'
```

### Method 4: Manual Execution (if already on server)
```bash
# Clone repository
git clone -b copilot/setup-github-ready-repo-structure https://github.com/BobbyBlanco400/nexus-cos.git /opt/nexus-cos
cd /opt/nexus-cos

# Execute deployment
bash deploy_complete_thiio_master_pf.sh
```

## What the Script Does

1. **Installs Dependencies**: git, python3, curl, wget, zip, bc
2. **Clones/Updates Repository**: Pulls latest from `copilot/setup-github-ready-repo-structure` branch
3. **Verifies THIIO Handoff**: 
   - Checks for existing package with SHA256: `23E511A6F52F17FE12DED43E32F71D748FBEF1B32CA339DBB60C253E03339AB4`
   - Regenerates if missing or hash mismatch
4. **Verifies Master PF Structure**: Validates all directories and scripts
5. **Executes Master PF Pipeline**: Runs the 5-step content production pipeline
6. **Creates Unified Bundle**: Combines THIIO handoff + Master PF into single package

## Output

The script creates:
- `/opt/nexus-cos/` - Complete repository
- `/opt/nexus-cos/dist/Nexus-COS-THIIO-FullStack.zip` - Platform deployment package
- `/opt/nexus-cos/dist/Nexus-COS-THIIO-MasterPF-Unified.zip` - Combined package
- `/opt/nexus-cos/output/` - Master PF execution output

## Requirements

- SSH access to server
- Sudo privileges (for package installation)
- Minimum 5GB free disk space
- Internet connection for git clone

## Configuration

Edit the script to change:
- `WORK_DIR="/opt/nexus-cos"` - Installation directory
- `BRANCH="copilot/setup-github-ready-repo-structure"` - Git branch
- `EXPECTED_SHA256="23E511..."` - Expected THIIO package hash

## Verification

After deployment, verify:
```bash
# Check THIIO package SHA256
ssh user@your-server 'sha256sum /opt/nexus-cos/dist/Nexus-COS-THIIO-FullStack.zip'

# Check Master PF execution
ssh user@your-server 'ls -la /opt/nexus-cos/output/'

# Check unified bundle
ssh user@your-server 'cat /opt/nexus-cos/dist/Nexus-COS-THIIO-MasterPF-Unified-manifest.json'
```

## Troubleshooting

### Permission Denied
If you get permission errors, ensure your user has sudo access or run as root:
```bash
ssh root@your-server 'bash -s' < deploy_complete_thiio_master_pf.sh
```

### Network Issues
If git clone fails, check firewall settings and ensure port 443 (HTTPS) is open.

### Disk Space
Check available space before running:
```bash
ssh user@your-server 'df -h /opt'
```

## Download Unified Bundle

After successful deployment:
```bash
# Download to local machine
scp user@your-server:/opt/nexus-cos/dist/Nexus-COS-THIIO-MasterPF-Unified.zip .

# Extract and use
unzip Nexus-COS-THIIO-MasterPF-Unified.zip
```

## Support

For issues, check the logs in `/opt/nexus-cos/output/logs/` on the server.
