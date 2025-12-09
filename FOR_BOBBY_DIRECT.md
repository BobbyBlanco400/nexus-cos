# FOR YOU (Bobby) - Direct VPS Execution

## Skip TRAE - You Run This Yourself

You're right to cut out the middleman. Execute this yourself via SSH to avoid any communication issues.

---

## What You Need

1. SSH access to your VPS
2. Root privileges
3. 2 minutes

---

## Steps to Execute (Just 4 Commands)

### 1. SSH to Your VPS
```bash
ssh root@YOUR_VPS_IP
```

### 2. Download the Script
```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/copilot/fix-nginx-duplicate-entries/YOURVPS_NGINX_FIX.sh -o /root/yourvps-nginx-fix.sh
```

### 3. Make It Executable
```bash
chmod +x /root/yourvps-nginx-fix.sh
```

### 4. Run It
```bash
bash /root/yourvps-nginx-fix.sh
```

---

## Alternative: Copy-Paste Method (If You Prefer)

If you don't want to download from GitHub, you can copy the entire script from `YOURVPS_NGINX_FIX.sh` in this repository and paste it into a file on your VPS, then execute it.

```bash
# On your VPS
nano /root/nginx-fix.sh
# Paste the entire content of YOURVPS_NGINX_FIX.sh
# Save with Ctrl+X, Y, Enter

chmod +x /root/nginx-fix.sh
bash /root/nginx-fix.sh
```

---

## What This Does

✅ **Automatically:**
- Creates backup (in `/root/nginx-backup-bobby-TIMESTAMP/`)
- Fixes all 5 nginx issues
- Validates configuration before applying
- Rolls back automatically if anything fails
- Shows clear progress messages
- Tests live endpoints (if accessible)
- Detects and warns about any remaining issues

❌ **Does NOT:**
- Launch your platform (you do that separately)
- Start PM2/Docker services
- Deploy applications

---

## After the Script Completes

### Check Nginx Status
```bash
nginx -t
systemctl status nginx
```

### Test Your Site
```bash
curl -I https://nexuscos.online/
curl -I http://nexuscos.online/
```

### Launch Your Platform (If Needed)
```bash
# Check what's running
pm2 status
docker ps

# Start PM2 (if using PM2)
pm2 start ecosystem.config.js
pm2 save

# OR start Docker (if using Docker)
docker-compose up -d

# OR start systemd services
systemctl start your-service-name
```

---

## Expected Output

You'll see:
```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║         NEXUS COS - NGINX FIX (Direct Execution)              ║
║              Running as BobbyBlanco400                         ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

✅ Root access confirmed
✅ Nginx detected: nginx/1.x.x

📦 Creating backup...
✅ Backup created: /root/nginx-backup-bobby-20251209_180500

🔧 Phase 1: Creating security headers...
✅ Security headers file created

🔧 Phase 2: Ensuring conf.d inclusion...
✅ conf.d already included

🔧 Phase 3: Fixing vhost configurations...
  📝 Processing: /etc/nginx/sites-enabled/nexuscos.conf
✅ Fixed 3 vhost file(s)

🔧 Phase 4: Removing duplicate configuration files...
  🗑️  Removed zz-redirect.conf
✅ Removed 1 duplicate config(s)

🔧 Phase 5: Validating nginx configuration...
✅ Nginx configuration is VALID

🔄 Phase 6: Reloading nginx...
✅ Nginx reloaded successfully

════════════════════════════════════════════════════════════════
  🎯 VERIFICATION
════════════════════════════════════════════════════════════════

✅ All redirects use $host variable
✅ No backticks found in configs
✅ Security headers file exists

🌐 Testing live endpoints...
  HTTPS Headers for https://nexuscos.online/:
    Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
    Content-Security-Policy: default-src 'self' https://nexuscos.online; ...
    ✅ Headers are clean (no backticks)

  HTTP Redirect for http://nexuscos.online/:
    HTTP/1.1 301 Moved Permanently
    Location: https://nexuscos.online/
    ✅ Redirect is clean (no backticks)

════════════════════════════════════════════════════════════════
  ✅ NGINX FIX COMPLETE
════════════════════════════════════════════════════════════════

🎉 Nginx configuration is now clean and optimized!
```

---

## If Something Goes Wrong

The script creates automatic backups and rolls back on errors.

To manually restore:
```bash
# Find your backup
ls -lt /root/nginx-backup-bobby-* | head -1

# Restore (replace TIMESTAMP)
systemctl stop nginx
rm -rf /etc/nginx
cp -r /root/nginx-backup-bobby-TIMESTAMP/nginx /etc/nginx/
systemctl start nginx
```

---

## Why This Approach Works

**Before:** You → TRAE → VPS (command gets corrupted)
**Now:** You → VPS (direct, no middleman)

**Benefits:**
- No communication breakdown
- You see exactly what runs
- You control the timing
- Automatic backup/rollback
- Clear error messages
- No TRAE misunderstanding commands

---

## Summary

**Download and run:**
```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/copilot/fix-nginx-duplicate-entries/YOURVPS_NGINX_FIX.sh -o /root/yourvps-nginx-fix.sh
chmod +x /root/yourvps-nginx-fix.sh
bash /root/yourvps-nginx-fix.sh
```

**That's it. You're in control. No TRAE needed.**
