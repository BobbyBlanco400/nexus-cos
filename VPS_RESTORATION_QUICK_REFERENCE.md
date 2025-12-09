# Nexus COS — VPS Endpoint Restoration Quick Reference

## 🚀 Quick Commands

### Windows PowerShell

```powershell
# Basic restoration (recommended)
.\restore-vps-endpoints.ps1

# Preview changes without executing
.\restore-vps-endpoints.ps1 -DryRun

# Skip SSL configuration
.\restore-vps-endpoints.ps1 -SkipSSL

# Skip endpoint verification
.\restore-vps-endpoints.ps1 -SkipVerification
```

### Linux/macOS Bash

```bash
# Basic restoration (recommended)
bash restore-vps-endpoints.sh

# Preview changes without executing
DRY_RUN=true bash restore-vps-endpoints.sh

# Skip verification
SKIP_VERIFICATION=true bash restore-vps-endpoints.sh
```

### Individual Scripts

```bash
# Fix SSL certificate/key mismatch
bash ssl-auto-pair.sh

# Add base path 200 blocks
bash base-path-200-blocks.sh
```

## 🎯 Target Endpoints & Expected Results

| Endpoint | Expected | Description |
|----------|----------|-------------|
| `https://nexuscos.online/` | `301` | Redirect to `/streaming/` |
| `https://nexuscos.online/api/` | `200` | API health check |
| `https://nexuscos.online/streaming/` | `200` | Streaming health check |
| `https://nexuscos.online/socket.io/?EIO=4&transport=polling` | `200` | Socket.IO main |
| `https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling` | `200` | Socket.IO streaming |

## 📝 What Gets Done

1. ✅ Backup existing configurations (timestamped)
2. ✅ Fix invalid Nginx directives
3. ✅ Add base path handlers (exact-match, no subroute interference)
4. ✅ Reconfigure domain in Plesk
5. ✅ Assign/create SSL certificate
6. ✅ Test Nginx configuration
7. ✅ Restart services
8. ✅ Verify all endpoints

## 🔧 Environment

- **VPS:** `root@74.208.155.161`
- **Domain:** `nexuscos.online`
- **Management:** Plesk Control Panel
- **SSL:** IONOS certificate

## 📁 Files Created

- `deployment-manifest (1).json` - Production deployment configuration
- `restore-vps-endpoints.ps1` - PowerShell restoration script
- `restore-vps-endpoints.sh` - Bash restoration script
- `ssl-auto-pair.sh` - SSL certificate/key matcher
- `base-path-200-blocks.sh` - Base path handler installer
- `VPS_ENDPOINT_RESTORATION_GUIDE.md` - Complete documentation

## 🛡️ Safety Features

- **Idempotent**: Safe to run multiple times
- **Automatic backups**: All configs backed up before changes
- **Non-destructive**: Comments instead of deletes
- **Error handling**: Continues on non-critical errors
- **Validation**: Tests before applying changes

## 🔍 Verify Manually

```bash
# Check endpoint status
curl -I https://nexuscos.online/
curl -I https://nexuscos.online/api/
curl -I https://nexuscos.online/streaming/
curl -I "https://nexuscos.online/socket.io/?EIO=4&transport=polling"

# Check Nginx status
systemctl status nginx

# Test Nginx config
nginx -t

# View recent logs
tail -20 /var/log/nginx/error.log
```

## 🆘 Quick Troubleshooting

### SSL Key Mismatch
```bash
bash ssl-auto-pair.sh
```

### Endpoints Return 404
```bash
bash base-path-200-blocks.sh
```

### Nginx Won't Start
```bash
# Check configuration
nginx -t

# View error logs
tail -50 /var/log/nginx/error.log

# Restore from backup
cp /etc/nginx/conf.d/pf_gateway_nexuscos.online.conf.backup-* \
   /etc/nginx/conf.d/pf_gateway_nexuscos.online.conf
```

### PowerShell SSH Issues
Use `--% ` to prevent argument parsing:
```powershell
ssh.exe --% -o StrictHostKeyChecking=no root@74.208.155.161 bash -lc "command"
```

## ✅ Production Readiness Checklist

- [ ] All endpoints return correct status codes
- [ ] SSL certificate valid and paired
- [ ] Nginx config passes validation
- [ ] Services running (Nginx, Apache)
- [ ] Base path handlers installed
- [ ] Subroutes still functional
- [ ] Socket.IO operational
- [ ] Backups created
- [ ] Manifest shows `CERTIFIED_PRODUCTION_DEPLOYMENT`

## 📖 Full Documentation

See `VPS_ENDPOINT_RESTORATION_GUIDE.md` for complete documentation.

---

**Last Updated:** 2025-12-08  
**Framework:** PF-v2025.10.11  
**Status:** Production Ready
