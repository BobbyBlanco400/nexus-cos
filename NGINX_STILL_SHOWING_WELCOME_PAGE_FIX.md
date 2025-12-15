# URGENT: Nginx Welcome Page Still Showing - Troubleshooting Guide

## Problem
Despite successful deployment and 200 status codes, nexuscos.online still shows the Nginx welcome page.

## Root Cause Analysis

This usually means:
1. **Wrong vhost is active** - The default site is still being served
2. **server_name mismatch** - Nginx isn't matching nexuscos.online to our vhost
3. **Wrong config location** - Config was placed but not in the active path
4. **Browser cache** - Old page cached in browser

---

## IMMEDIATE DIAGNOSTIC STEPS

### Step 1: Check Which Config is Actually Active

```bash
# Check what Nginx is actually using
sudo nginx -T | grep -A 20 "server_name nexuscos.online"
```

**Expected**: Should show our vhost configuration  
**If empty**: Our vhost is NOT loaded

### Step 2: Verify Symlink Exists

```bash
# Check if symlink was created
ls -la /etc/nginx/sites-enabled/ | grep nexuscos

# Should show something like:
# lrwxrwxrwx 1 root root 51 Dec 15 19:00 nexuscos.online -> /etc/nginx/sites-available/nexuscos.online
```

**If missing**: Symlink wasn't created or was removed

### Step 3: Check Default Site Status

```bash
# Check if default site is still enabled
ls -la /etc/nginx/sites-enabled/default

# Should NOT exist (we disabled it)
```

**If exists**: Default site is still active and winning

### Step 4: Check Server Name in Active Config

```bash
# See what server_name nginx is using for port 443
sudo nginx -T | grep -B 5 -A 15 "listen 443"
```

Look for which `server_name` is handling requests on port 443.

---

## FIXES BASED ON DIAGNOSIS

### Fix 1: Symlink Missing - Recreate It

```bash
sudo ln -sf /etc/nginx/sites-available/nexuscos.online /etc/nginx/sites-enabled/nexuscos.online
sudo nginx -t
sudo systemctl reload nginx
```

### Fix 2: Default Site Still Active - Remove It

```bash
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

### Fix 3: Wrong Config Path - Check Where Config Was Placed

The script placed the config at `/etc/nginx/sites-enabled/nexuscos.online.conf.bak` (backup).

But it should be at `/etc/nginx/sites-available/nexuscos.online` (active).

**Fix**:
```bash
# Copy our config to the correct location
sudo cp /home/runner/work/nexus-cos/nexus-cos/deployment/nginx/sites-available/nexuscos.online /etc/nginx/sites-available/nexuscos.online

# Create symlink
sudo ln -sf /etc/nginx/sites-available/nexuscos.online /etc/nginx/sites-enabled/nexuscos.online

# Remove default
sudo rm -f /etc/nginx/sites-enabled/default

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

### Fix 4: Config File Has Wrong Extension

The backup shows `.conf` extension, but our file doesn't use an extension.

**Check**:
```bash
ls -la /etc/nginx/sites-enabled/
```

If you see `nexuscos.online.conf`, rename it:
```bash
sudo mv /etc/nginx/sites-enabled/nexuscos.online.conf /etc/nginx/sites-enabled/nexuscos.online
sudo nginx -t
sudo systemctl reload nginx
```

### Fix 5: Force Nginx Restart (Not Just Reload)

```bash
sudo systemctl restart nginx
```

### Fix 6: Clear Browser Cache

After fixing server-side:
1. Open browser in **Incognito/Private mode**
2. Navigate to https://nexuscos.online/
3. Or hard refresh: Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)

---

## NUCLEAR OPTION - Complete Re-deployment

If nothing above works:

```bash
# 1. Remove all existing configs
sudo rm -f /etc/nginx/sites-enabled/nexuscos.online*
sudo rm -f /etc/nginx/sites-enabled/default

# 2. Copy our config fresh
sudo cp /home/runner/work/nexus-cos/nexus-cos/deployment/nginx/sites-available/nexuscos.online /etc/nginx/sites-available/nexuscos.online

# 3. Create symlink
sudo ln -sf /etc/nginx/sites-available/nexuscos.online /etc/nginx/sites-enabled/nexuscos.online

# 4. Verify only our config exists
ls -la /etc/nginx/sites-enabled/

# 5. Test config
sudo nginx -t

# 6. RESTART (not reload)
sudo systemctl restart nginx

# 7. Verify it's running
sudo systemctl status nginx

# 8. Check in browser (incognito mode)
# https://nexuscos.online/
```

---

## VERIFICATION CHECKLIST

After applying fixes, verify:

```bash
# 1. Nginx is using our config
sudo nginx -T | grep "server_name nexuscos.online"
# Should show our configuration

# 2. Only our site in sites-enabled
ls -la /etc/nginx/sites-enabled/
# Should show ONLY nexuscos.online symlink

# 3. Root directory is correct
sudo nginx -T | grep "root /var/www"
# Should show: root /var/www/nexus-cos;

# 4. Test from command line
curl -I https://nexuscos.online/
# Should NOT show "nginx" in Server header

# 5. Test actual content
curl -s https://nexuscos.online/ | head -20
# Should show your HTML, not "Welcome to nginx!"
```

---

## MOST LIKELY ISSUE

Based on TRAE's report that they created backup at `/etc/nginx/sites-enabled/nexuscos.online.conf.bak`, the issue is likely:

**The config was backed up but the NEW config wasn't properly activated.**

The deployment script should have:
1. ✅ Created backup (done - confirmed by TRAE)
2. ❌ Copied new config to sites-available (may have failed)
3. ❌ Created symlink in sites-enabled (may have failed)
4. ❌ Removed default site (may have failed)

**SOLUTION**: Run the nuclear option commands above to ensure clean deployment.

---

## ALTERNATIVE: Using Plesk

If this server uses Plesk, the config location is DIFFERENT:

```bash
# Check if Plesk is installed
which plesk

# If Plesk exists, use this instead:
sudo cp /home/runner/work/nexus-cos/nexus-cos/deployment/nginx/plesk/vhost_nginx.conf /var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf

# Rebuild Plesk config
sudo plesk repair web -domain nexuscos.online -y

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

---

## CONTACT INFORMATION FOR TRAE

Run these diagnostics and report back:

```bash
echo "=== Active Sites ==="
ls -la /etc/nginx/sites-enabled/

echo "=== Server Names ==="
sudo nginx -T | grep "server_name"

echo "=== Document Roots ==="
sudo nginx -T | grep "root "

echo "=== Listening Ports ==="
sudo nginx -T | grep "listen "

echo "=== Test Content ==="
curl -I https://nexuscos.online/
```

Send the output of all these commands to determine the exact issue.
