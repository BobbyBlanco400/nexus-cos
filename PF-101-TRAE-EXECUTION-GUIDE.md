# PF-101: TRAE SOLO EXECUTION GUIDE

**⚠️ READ THIS ENTIRE DOCUMENT BEFORE STARTING ⚠️**

---

## 🎯 Your Mission

Deploy Nexus COS Platform with working apex, beta, and /api endpoints.

**Time:** 5 minutes  
**Difficulty:** Easy  
**Commands:** 11 total

---

## 🚨 CRITICAL RULES - READ CAREFULLY

### YOU MUST:

1. ✅ **FOLLOW** every step exactly as written
2. ✅ **COPY-PASTE** commands exactly (do not type them)
3. ✅ **WAIT** for each command to finish before running the next
4. ✅ **VERIFY** output matches expected results
5. ✅ **STOP** immediately if you see any error
6. ✅ **REPORT** errors without trying to fix them

### YOU MUST NOT:

1. ❌ **SKIP** any steps
2. ❌ **MODIFY** any commands
3. ❌ **RUN** commands out of order
4. ❌ **TRY TO FIX** errors yourself
5. ❌ **IMPROVISE** or add extra commands
6. ❌ **CONTINUE** if something fails

---

## 📋 Pre-Flight Checklist

Before you start, confirm:

- [ ] You can SSH to: root@nexuscos.online
- [ ] You have the password/key
- [ ] You're on a stable internet connection
- [ ] You've read this entire document

**If ANY item is unchecked, STOP and report.**

---

## 🚀 EXECUTION STEPS

### Command 1: Connect to VPS

**What to type:**
```bash
ssh root@nexuscos.online
```

**What you should see:**
```
Welcome to Ubuntu 20.04.X LTS
...
root@vps:~#
```

**✅ Success Check:** You see `root@vps:~#` prompt

**❌ If you see an error:** Report "Cannot SSH to server"

---

### Command 2: Navigate to Repository

**What to type:**
```bash
cd /opt/nexus-cos
```

**What you should see:**
```
root@vps:/opt/nexus-cos#
```

**✅ Success Check:** Prompt changed to show `/opt/nexus-cos`

**❌ If you see an error:** Report "Directory does not exist"

---

### Command 3: Check Current Branch

**What to type:**
```bash
git branch
```

**What you should see:**
```
* main
```

**✅ Success Check:** You see `* main`

**❌ If different branch:** Run `git checkout main`

---

### Command 4: Pull Latest Code

**What to type:**
```bash
git pull origin main
```

**What you should see:**
```
From https://github.com/BobbyBlanco400/nexus-cos
 * branch            main       -> FETCH_HEAD
Already up to date.
```
OR
```
Updating 1234abc..5678def
Fast-forward
 PF-101-UNIFIED-DEPLOYMENT.md | 500 +++++++++++++
 DEPLOY_PHASE_2.5.sh          | 100 +++++++
 ...
```

**✅ Success Check:** No errors, code updated or already up to date

**❌ If you see conflicts:** STOP and report "Git has conflicts"

---

### Command 5: Verify Deployment Script Exists

**What to type:**
```bash
ls -lah DEPLOY_PHASE_2.5.sh
```

**What you should see:**
```
-rwxr-xr-x 1 root root 6.2K Jan  9 12:00 DEPLOY_PHASE_2.5.sh
```

**✅ Success Check:** File exists and is executable (x in permissions)

**❌ If not executable:** Run `chmod +x DEPLOY_PHASE_2.5.sh`

---

### Command 6: Run Deployment Script

**⚠️ IMPORTANT: This is the main deployment command**

**What to type:**
```bash
sudo ./DEPLOY_PHASE_2.5.sh
```

**What you should see:**
```
╔════════════════════════════════════════════════════════════════╗
║       NEXUS COS PHASE 2.5 - ONE-COMMAND DEPLOYMENT            ║
║                      (PF-101)                                  ║
╚════════════════════════════════════════════════════════════════╝

✓ Pre-flight checks passed

▶ Executing Phase 2.5 deployment...

═══════════════════════════════════════════════════════════════
  1. PRE-FLIGHT CHECKS
═══════════════════════════════════════════════════════════════

✓ Running as root
✓ In correct directory
✓ Deployment scripts found
✓ Validation scripts found

... (more output) ...

✓ Deployment completed successfully

ℹ Detecting working backend...
✓ Backend detected on port 3004

ℹ Configuring /api proxy to port 3004...
✓ /api proxy configuration created

ℹ Testing Nginx configuration...
✓ Nginx configuration is valid

ℹ Reloading Nginx...
✓ Nginx reloaded successfully

ℹ Running deployment validation...
ℹ Testing apex domain...
✓ Apex domain: 200 OK

ℹ Testing beta domain...
✓ Beta domain: 200 OK

ℹ Testing API endpoints...
✓ API root: 200 OK
✓ API health: 200 OK
✓ API system status: 200 OK

╔════════════════════════════════════════════════════════════════╗
║         🎉 PHASE 2.5 DEPLOYMENT COMPLETE - SUCCESS 🎉         ║
╚════════════════════════════════════════════════════════════════╝

Your Nexus COS Platform is now live:

  ► Apex Domain:      https://nexuscos.online
  ► Beta Domain:      https://beta.nexuscos.online
  ► API Endpoints:    https://nexuscos.online/api/*

✓ Platform deployed and ready for production use!
✓ All endpoints validated and operational
```

**⏱ Expected Time:** 2-3 minutes

**✅ Success Check:** You see "DEPLOYMENT COMPLETE - SUCCESS"

**❌ If you see errors:**
1. STOP immediately
2. Copy the ENTIRE error message
3. Copy the last 50 lines of output
4. Report: "Deployment failed with errors"

---

### Command 7: Verify Apex Domain

**What to type:**
```bash
curl -skI https://nexuscos.online/ | head -n 1
```

**What you should see:**
```
HTTP/2 200
```

**✅ Success Check:** Response is `HTTP/2 200`

**❌ If different:** Report the actual response

---

### Command 8: Verify Beta Domain

**What to type:**
```bash
curl -skI https://beta.nexuscos.online/ | head -n 1
```

**What you should see:**
```
HTTP/2 200
```

**✅ Success Check:** Response is `HTTP/2 200`

**❌ If different:** Report the actual response

---

### Command 9: Verify API Root

**What to type:**
```bash
curl -skI https://nexuscos.online/api/ | head -n 1
```

**What you should see:**
```
HTTP/2 200
```

**✅ Success Check:** Response is `HTTP/2 200`

**❌ If different:** Report the actual response

---

### Command 10: Verify API Health

**What to type:**
```bash
curl -skI https://nexuscos.online/api/health | head -n 1
```

**What you should see:**
```
HTTP/2 200
```

**✅ Success Check:** Response is `HTTP/2 200`

**❌ If different:** Report the actual response

---

### Command 11: Verify API System Status

**What to type:**
```bash
curl -skI https://nexuscos.online/api/system/status | head -n 1
```

**What you should see:**
```
HTTP/2 200
```

**✅ Success Check:** Response is `HTTP/2 200`

**❌ If different:** Report the actual response

---

## ✅ SUCCESS CRITERIA

All of these must be TRUE:

- [x] Command 1: Connected to VPS ✅
- [x] Command 2: In /opt/nexus-cos directory ✅
- [x] Command 3: On main branch ✅
- [x] Command 4: Code pulled successfully ✅
- [x] Command 5: Deployment script exists ✅
- [x] Command 6: Deployment succeeded ✅
- [x] Command 7: Apex returns 200 ✅
- [x] Command 8: Beta returns 200 ✅
- [x] Command 9: API root returns 200 ✅
- [x] Command 10: API health returns 200 ✅
- [x] Command 11: API status returns 200 ✅

**If ALL are checked: DEPLOYMENT SUCCESSFUL! 🎉**

---

## 🎉 WHAT TO DO WHEN SUCCESSFUL

### 1. Take a Screenshot

Open browser and visit:
- https://nexuscos.online/
- https://beta.nexuscos.online/
- https://nexuscos.online/api/

Take screenshots showing they all load.

### 2. Report Success

Post this message:

```
✅ PF-101 DEPLOYMENT SUCCESSFUL

All endpoints validated:
- Apex: https://nexuscos.online/ (200 OK)
- Beta: https://beta.nexuscos.online/ (200 OK)
- API: https://nexuscos.online/api/* (200 OK)

Platform is live and operational.
```

### 3. Monitor for 10 Minutes

Keep an eye on:
```bash
tail -f /var/log/nginx/access.log
```

Watch for any errors or unusual traffic.

---

## ❌ WHAT TO DO IF SOMETHING FAILS

### If ANY Command Fails:

1. **STOP** immediately
2. **DO NOT** try to fix it
3. **DO NOT** run any other commands
4. **COPY** the error message
5. **RUN** this diagnostic:

```bash
./scripts/diagnose-deployment.sh 2>&1 | tee /tmp/diagnostic.log
cat /tmp/diagnostic.log
```

6. **REPORT** the full output
7. **WAIT** for instructions

### Common Issues (DO NOT TRY TO FIX)

**Issue:** "Permission denied"
- **Report:** "Got permission denied error on command X"

**Issue:** "No such file or directory"
- **Report:** "File not found error on command X"

**Issue:** "Connection refused"
- **Report:** "Connection refused on command X"

**Issue:** Nginx test fails
- **Report:** "Nginx configuration test failed"

**Issue:** curl returns 404 or 502
- **Report:** "Endpoint returned [status code]"

---

## 📝 Troubleshooting Reference

### Get Nginx Status
```bash
sudo systemctl status nginx
```

### Check Nginx Configuration
```bash
sudo nginx -t
```

### View Nginx Error Log
```bash
sudo tail -n 50 /var/log/nginx/error.log
```

### Check Backend Status
```bash
curl http://localhost:3004/api/health
```

### Check All Listening Ports
```bash
sudo netstat -tlnp | grep -E ":(3004|3001|80|443)"
```

**⚠️ ONLY RUN THESE FOR DIAGNOSTICS - DO NOT TRY TO FIX ANYTHING**

---

## 🔄 If You Need to Re-Run

If deployment fails and you get new instructions:

1. Make sure you're in `/opt/nexus-cos`
2. Pull latest code: `git pull origin main`
3. Re-run: `sudo ./DEPLOY_PHASE_2.5.sh`

---

## 📞 Support Contacts

**If you encounter issues:**

1. First: Run diagnostic script
2. Second: Report full error output
3. Third: Provide system information:
   ```bash
   uname -a
   cat /etc/os-release
   df -h
   free -m
   ```

---

## 📊 Expected Timeline

- **Command 1-5:** 1 minute (setup)
- **Command 6:** 2-3 minutes (deployment)
- **Command 7-11:** 1 minute (validation)

**Total Time:** ~5 minutes

---

## ✅ Final Checklist Before Starting

Before you run Command 1, verify:

- [ ] I have read this entire document
- [ ] I understand I must follow steps exactly
- [ ] I will not skip or modify any commands
- [ ] I will stop immediately if there's an error
- [ ] I will not try to fix errors myself
- [ ] I have access to SSH
- [ ] I am ready to proceed

**If all checked: You may begin with Command 1**

---

## 🎯 Your Goal

At the end, you should have:

1. ✅ Apex website live at https://nexuscos.online/
2. ✅ Beta website live at https://beta.nexuscos.online/
3. ✅ API working at https://nexuscos.online/api/*
4. ✅ All endpoints returning 200 OK
5. ✅ Platform fully operational

---

**Good luck! Follow the steps carefully and you'll succeed! 🚀**

---

**Version:** 1.0  
**Created:** 2025-01-09  
**For:** TRAE SOLO  
**PF:** PF-101
