# URGENT: HTTP/2 404 Error - Site Was Working, Now Broken

## Problem
The site was working yesterday but now returns `HTTP/2 404` when accessing nexuscos.online.

## What This Means

A **404 error** means:
- ✅ Nginx IS serving our vhost (not the welcome page)
- ✅ SSL/HTTPS is working (HTTP/2 indicates HTTPS)
- ❌ The file/directory Nginx is looking for does NOT exist
- ❌ The document root path is wrong OR files were deleted/moved

---

## IMMEDIATE DIAGNOSTIC STEPS

### Step 1: Check if Files Exist at Document Root

```bash
# Check if the published site files exist
ls -la /var/www/nexus-cos/

# Should show index.html and other files
# If directory is empty or doesn't exist, that's the problem
```

**Expected**: Directory exists with `index.html` and other site files  
**If empty/missing**: Files were deleted or never published

### Step 2: Verify Nginx Configuration is Active

```bash
# Check what document root Nginx is using
sudo nginx -T | grep "root /var/www"

# Should show: root /var/www/nexus-cos;
```

**Expected**: Points to `/var/www/nexus-cos`  
**If different**: Configuration changed or wrong vhost is active

### Step 3: Check Nginx Error Log

```bash
# See what Nginx is trying to serve
sudo tail -n 50 /var/log/nginx/error.log

# Look for lines like:
# "/var/www/nexus-cos/index.html" is not found
```

This will tell you EXACTLY what path Nginx is looking for.

### Step 4: Test Direct File Access

```bash
# Try to cat the index.html file
cat /var/www/nexus-cos/index.html

# If "No such file or directory", files are missing
```

---

## MOST LIKELY CAUSES & FIXES

### Cause 1: Published Files Were Deleted or Moved

**Symptoms**: 
- Document root exists but is empty
- `ls /var/www/nexus-cos/` shows no index.html

**Fix**: Re-publish the site files

```bash
# If you have a build process, run it and copy files
cd /path/to/your/frontend
npm run build  # or your build command
sudo cp -r dist/* /var/www/nexus-cos/

# OR if files are in the repo
cd /path/to/nexus-cos/nexus-cos
sudo cp -r . /var/www/nexus-cos/

# Verify files are there
ls -la /var/www/nexus-cos/
```

### Cause 2: Wrong Document Root in Configuration

**Symptoms**:
- `nginx -T | grep root` shows wrong path
- Files exist but Nginx can't find them

**Fix**: Update the root directive

```bash
# Check current root
sudo nginx -T | grep "root /var/www"

# If it's wrong, edit the config
sudo nano /etc/nginx/sites-available/nexuscos.online

# Find the line:
# root /var/www/nexus-cos;

# Make sure it points to where your files actually are
# Save and exit (Ctrl+X, Y, Enter)

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

### Cause 3: Permissions Issue

**Symptoms**:
- Files exist at correct path
- Nginx error log shows "permission denied"

**Fix**: Set correct permissions

```bash
# Set ownership to www-data (Nginx user)
sudo chown -R www-data:www-data /var/www/nexus-cos/

# Set correct permissions
sudo chmod -R 755 /var/www/nexus-cos/

# Restart Nginx
sudo systemctl restart nginx
```

### Cause 4: SELinux Blocking Access (Red Hat/CentOS)

**Symptoms**:
- Files exist, permissions correct
- Error log shows "Permission denied" despite correct ownership

**Fix**: Update SELinux context

```bash
# Check if SELinux is enforcing
getenforce

# If "Enforcing", update context
sudo chcon -R -t httpd_sys_content_t /var/www/nexus-cos/

# Or disable SELinux temporarily for testing
sudo setenforce 0

# Test in browser
# If it works, SELinux was the issue
```

### Cause 5: Configuration Was Overwritten or Changed

**Symptoms**:
- Site worked yesterday
- Config looks different today

**Fix**: Re-apply our configuration

```bash
# Re-copy our config
sudo cp /path/to/nexus-cos/deployment/nginx/sites-available/nexuscos.online /etc/nginx/sites-available/nexuscos.online

# Ensure symlink exists
sudo ln -sf /etc/nginx/sites-available/nexuscos.online /etc/nginx/sites-enabled/nexuscos.online

# Test and restart
sudo nginx -t
sudo systemctl restart nginx
```

---

## COMPLETE DIAGNOSTIC REPORT

Run all these commands and report the output:

```bash
echo "=== 1. Check if files exist ==="
ls -la /var/www/nexus-cos/

echo ""
echo "=== 2. Check document root in config ==="
sudo nginx -T | grep "root /var/www"

echo ""
echo "=== 3. Check recent error log ==="
sudo tail -n 20 /var/log/nginx/error.log

echo ""
echo "=== 4. Check file permissions ==="
ls -la /var/www/ | grep nexus

echo ""
echo "=== 5. Check active vhost ==="
sudo nginx -T | grep -A 5 "server_name nexuscos.online"

echo ""
echo "=== 6. Test site response ==="
curl -I https://nexuscos.online/

echo ""
echo "=== 7. Check if index.html exists ==="
sudo cat /var/www/nexus-cos/index.html | head -10
```

---

## NUCLEAR OPTION - Complete Rebuild

If nothing above works, completely rebuild:

```bash
# 1. Create fresh directory
sudo mkdir -p /var/www/nexus-cos

# 2. Copy your built site files here
# (Replace with your actual source)
sudo cp -r /path/to/your/built/site/* /var/www/nexus-cos/

# 3. Set permissions
sudo chown -R www-data:www-data /var/www/nexus-cos/
sudo chmod -R 755 /var/www/nexus-cos/

# 4. Verify index.html exists
ls -la /var/www/nexus-cos/index.html

# 5. Re-apply Nginx config
sudo cp /path/to/nexus-cos/deployment/nginx/sites-available/nexuscos.online /etc/nginx/sites-available/nexuscos.online
sudo ln -sf /etc/nginx/sites-available/nexuscos.online /etc/nginx/sites-enabled/nexuscos.online

# 6. Test and restart
sudo nginx -t
sudo systemctl restart nginx

# 7. Test in browser
curl -I https://nexuscos.online/
```

---

## VERIFICATION AFTER FIX

```bash
# 1. Should return 200 (not 404)
curl -I https://nexuscos.online/

# 2. Should show HTML content
curl -s https://nexuscos.online/ | head -20

# 3. Should NOT show errors
sudo tail -n 10 /var/log/nginx/error.log
```

---

## WHERE ARE THE PUBLISHED FILES?

Based on the configuration, files should be at: `/var/www/nexus-cos/`

Check these common locations if files are elsewhere:

```bash
# Common build output directories
ls -la /home/*/nexus-cos/dist/
ls -la /home/*/nexus-cos/build/
ls -la /var/www/html/
ls -la /var/www/vhosts/nexuscos.online/httpdocs/

# Find index.html anywhere
sudo find /var/www -name "index.html" -type f
```

---

## QUICK FIX CHECKLIST

1. [ ] Files exist at `/var/www/nexus-cos/`
2. [ ] `index.html` is present
3. [ ] Permissions are 755 for directories, 644 for files
4. [ ] Owned by `www-data:www-data`
5. [ ] Nginx config points to correct root
6. [ ] Nginx configuration is valid (`nginx -t`)
7. [ ] Nginx has been restarted (not just reloaded)
8. [ ] No errors in `/var/log/nginx/error.log`

---

## MOST LIKELY ISSUE

Since the site worked yesterday and now returns 404:

**The published files were deleted or the document root is now empty.**

**Immediate action**:
1. Check if `/var/www/nexus-cos/index.html` exists
2. If not, re-publish/re-build the site
3. Copy files to `/var/www/nexus-cos/`
4. Restart Nginx

This is a **content** issue, not a configuration issue.
