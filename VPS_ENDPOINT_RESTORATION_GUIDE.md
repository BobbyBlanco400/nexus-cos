# Nexus COS — VPS Endpoint Restoration Guide

## 🎯 Objective

Restore `https://nexuscos.online/` endpoints and services to production readiness as defined in `deployment-manifest (1).json` where `legal_status` is `CERTIFIED_PRODUCTION_DEPLOYMENT`.

## 📋 Target Endpoints

All endpoints must return the specified HTTP status codes:

| Endpoint | Expected Status | Description |
|----------|----------------|-------------|
| `https://nexuscos.online/` | `301` | Root redirect to `/streaming/` |
| `https://nexuscos.online/api/` | `200` | API base endpoint health check |
| `https://nexuscos.online/streaming/` | `200` | Streaming base endpoint health check |
| `https://nexuscos.online/socket.io/?EIO=4&transport=polling` | `200` | Main Socket.IO endpoint |
| `https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling` | `200` | Streaming Socket.IO endpoint |

## 🔧 Environment

- **VPS:** `root@74.208.155.161` (Plesk-managed)
- **Domain:** `nexuscos.online`
- **Server Management:** Plesk Control Panel
- **Web Server:** Nginx (with Apache as optional backend)
- **SSL Provider:** IONOS

## 📦 Available Scripts

### 1. Main Restoration Script

**Windows PowerShell:**
```powershell
.\restore-vps-endpoints.ps1
```

**Linux/macOS Bash:**
```bash
bash restore-vps-endpoints.sh
```

**What it does:**
- Backs up existing gateway configurations
- Comments out invalid `proxy_set_header` directives
- Adds exact-match base-path handlers to vhost configuration
- Reconfigures domain in Plesk
- Manages SSL certificate assignment
- Tests and restarts Nginx
- Verifies all endpoint statuses

### 2. SSL Auto-Pair Script

```bash
bash ssl-auto-pair.sh
```

**What it does:**
- Finds the certificate in PF gateway config
- Calculates certificate modulus
- Searches for matching private key by modulus
- Updates gateway config with matched certificate/key pair
- Tests and restarts Nginx

### 3. Base Path 200 Blocks Script

```bash
bash base-path-200-blocks.sh
```

**What it does:**
- Inserts exact-match `location = /api/` and `location = /streaming/` blocks
- These blocks return 200 status for base paths
- Does not interfere with subroutes (e.g., `/api/users`, `/streaming/socket.io/`)
- Tests and restarts Nginx

## 🚀 Quick Start

### Option 1: Windows PowerShell (Recommended for Windows Users)

```powershell
# Basic execution
.\restore-vps-endpoints.ps1

# Dry run (preview changes without executing)
.\restore-vps-endpoints.ps1 -DryRun

# Skip SSL configuration
.\restore-vps-endpoints.ps1 -SkipSSL

# Skip endpoint verification
.\restore-vps-endpoints.ps1 -SkipVerification

# Custom VPS IP or domain
.\restore-vps-endpoints.ps1 -VpsIp "74.208.155.161" -Domain "nexuscos.online"
```

### Option 2: Bash (Linux/macOS or Git Bash on Windows)

```bash
# Basic execution
bash restore-vps-endpoints.sh

# Dry run
DRY_RUN=true bash restore-vps-endpoints.sh

# Skip verification
SKIP_VERIFICATION=true bash restore-vps-endpoints.sh

# Custom configuration
DOMAIN=nexuscos.online VPS_IP=74.208.155.161 bash restore-vps-endpoints.sh
```

### Option 3: Direct SSH Execution

If you have direct SSH access to the VPS:

```bash
ssh root@74.208.155.161

# Then run the restoration commands directly on the server
cd /root
curl -O https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/restore-vps-endpoints.sh
chmod +x restore-vps-endpoints.sh
bash restore-vps-endpoints.sh
```

## 📝 Step-by-Step Process

### Phase 1: Restore Plesk Configurations

1. **Backup Gateway Config**
   - Creates timestamped backup of `/etc/nginx/conf.d/pf_gateway_nexuscos.online.conf`
   - Ensures rollback capability

2. **Fix Invalid Nginx Directives**
   - Comments out one-argument `proxy_set_header` directives
   - Prevents Nginx parsing errors

3. **Add Base Path Handlers**
   - Adds exact-match location blocks to vhost config
   - Enables base path health checks without breaking subroutes

### Phase 2: Reconfigure Domain

1. **Plesk Domain Reconfiguration**
   - Runs `plesk sbin httpdmng --reconfigure-domain nexuscos.online`
   - Applies configuration changes
   - Regenerates Nginx configurations

### Phase 3: SSL Certificate Management

1. **List Available Certificates**
   - Queries Plesk for domain certificates
   - Identifies IONOS SSL certificate

2. **Assign Certificate**
   - If certificate exists: Assigns to domain
   - If not exists: Creates from IONOS files at `/root/ionos/`

3. **Auto-Pair Certificate and Key**
   - Matches certificate with correct private key by modulus
   - Prevents SSL key mismatch errors

### Phase 4: Service Restart

1. **Nginx Configuration Test**
   - Runs `nginx -t` to validate configuration
   - Prevents service disruption from invalid configs

2. **Restart Nginx**
   - `systemctl restart nginx` or `service nginx restart`
   - Applies all configuration changes

3. **Start Apache (Optional)**
   - Attempts to start Apache (non-fatal if fails)
   - Some services may use Apache as backend

### Phase 5: Verification

1. **Endpoint Status Checks**
   - Tests all 5 target endpoints
   - Verifies correct HTTP status codes
   - Reports any discrepancies

## 🔒 SSL Certificate Setup

### Prerequisites

Ensure IONOS SSL certificate files are present on the VPS:

```
/root/ionos/privkey.pem     # Private key
/root/ionos/cert.pem        # Certificate
/root/ionos/chain.pem       # CA bundle
```

### Manual SSL Setup (if needed)

```bash
# Upload certificate files to VPS
scp privkey.pem root@74.208.155.161:/root/ionos/
scp cert.pem root@74.208.155.161:/root/ionos/
scp chain.pem root@74.208.155.161:/root/ionos/

# Create certificate in Plesk
ssh root@74.208.155.161
plesk bin certificate --create "IONOS SSL" \
  -domain nexuscos.online \
  -key-file /root/ionos/privkey.pem \
  -cert-file /root/ionos/cert.pem \
  -cacert-file /root/ionos/chain.pem

# Assign to domain
plesk bin site -u nexuscos.online -certificate-name "IONOS SSL"
```

## 🛡️ Safety Features

### Idempotent Design
- Scripts can be run multiple times safely
- Checks for existing configurations before modifying
- Skips unnecessary changes

### Automatic Backups
- All configuration files backed up with timestamps
- Easy rollback in case of issues
- Format: `filename.backup-YYYY-MM-DD-HHMMSS`

### Non-Destructive Operations
- Comments out invalid directives instead of deleting
- Appends configurations instead of replacing
- Preserves existing functionality

### Error Handling
- Continues on non-critical errors
- Validates configurations before applying
- Tests Nginx config before restart

## 🔍 Troubleshooting

### Issue: SSL Certificate Key Mismatch

**Symptom:** Nginx fails to start, SSL errors in logs

**Solution:**
```bash
bash ssl-auto-pair.sh
```

This automatically finds and pairs the correct certificate and key.

### Issue: Endpoints Return 404 or 502

**Symptom:** Base paths return wrong status codes

**Solution:**
```bash
bash base-path-200-blocks.sh
```

This adds exact-match location blocks for base paths.

### Issue: Nginx Configuration Test Fails

**Symptom:** `nginx -t` shows errors

**Solution:**
1. Check for syntax errors in configuration files
2. Restore from backup:
   ```bash
   cp /etc/nginx/conf.d/pf_gateway_nexuscos.online.conf.backup-* /etc/nginx/conf.d/pf_gateway_nexuscos.online.conf
   nginx -t
   ```

### Issue: SSH Connection Issues from PowerShell

**Symptom:** Arguments not parsed correctly, special characters cause errors

**Solution:**
Use the `--% ` operator:
```powershell
ssh.exe --% -o StrictHostKeyChecking=no root@74.208.155.161 bash -lc "command"
```

## 📊 Expected Output

### Successful Restoration

```
═══════════════════════════════════════════════════════════════
  NEXUS COS - VPS ENDPOINT RESTORATION
  Domain: nexuscos.online | VPS: 74.208.155.161
═══════════════════════════════════════════════════════════════

─────────────────────────────────────────────────────────────────
  Step 1: Preparing Restoration Script
─────────────────────────────────────────────────────────────────
ℹ Restoration script prepared (XXXX bytes)

─────────────────────────────────────────────────────────────────
  Step 2: Executing Restoration on VPS
─────────────────────────────────────────────────────────────────
ℹ Connecting to VPS and executing restoration script...
✓ Restoration completed successfully!

─────────────────────────────────────────────────────────────────
  Step 3: Verifying Endpoints
─────────────────────────────────────────────────────────────────
✓ Root (Redirect): 301 (Expected: 301)
✓ API Base: 200 (Expected: 200)
✓ Streaming Base: 200 (Expected: 200)
✓ Socket.IO Main: 200 (Expected: 200)
✓ Socket.IO Streaming: 200 (Expected: 200)

─────────────────────────────────────────────────────────────────
  Restoration Complete
─────────────────────────────────────────────────────────────────
✓ All restoration tasks completed!
ℹ Check the output above for any warnings or errors.
```

## 📁 File Structure

```
nexus-cos/
├── deployment-manifest (1).json       # Production deployment manifest
├── restore-vps-endpoints.ps1          # PowerShell restoration script
├── restore-vps-endpoints.sh           # Bash restoration script
├── ssl-auto-pair.sh                   # SSL certificate/key matcher
├── base-path-200-blocks.sh            # Base path handler installer
└── VPS_ENDPOINT_RESTORATION_GUIDE.md  # This guide
```

## 🎯 Production Readiness Checklist

- [ ] All 5 endpoints return correct HTTP status codes
- [ ] SSL certificate is valid and properly paired
- [ ] Nginx configuration passes validation (`nginx -t`)
- [ ] All services are running (Nginx, Apache if needed)
- [ ] Base path handlers are in place
- [ ] Subroutes are not affected by base path handlers
- [ ] Socket.IO endpoints are operational
- [ ] Configuration backups are created
- [ ] Deployment manifest confirms `CERTIFIED_PRODUCTION_DEPLOYMENT`

## 🔗 Related Documentation

- `deployment-manifest (1).json` - Production deployment configuration
- `scripts/pf-vps-deploy.ps1` - Full VPS deployment script
- `START_HERE_FINAL_PF.md` - Complete PF deployment guide
- `FINAL_PF_VPS_DEPLOYMENT_HANDOFF.md` - Comprehensive VPS deployment documentation

## 💡 Best Practices

1. **Always run in dry-run mode first** to preview changes
2. **Backup configurations** before making changes (done automatically)
3. **Test endpoints** after each major change
4. **Monitor Nginx logs** during and after restoration
5. **Keep SSL certificates** up to date
6. **Document any custom changes** for future reference

## 🆘 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Nginx error logs: `tail -f /var/log/nginx/error.log`
3. Review Plesk logs: `tail -f /var/log/plesk/panel.log`
4. Restore from backups if needed
5. Consult related documentation files

## 📜 License

This restoration process is part of the Nexus COS deployment framework (PF-v2025.10.11).
