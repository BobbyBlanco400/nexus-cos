# PF-101: Quick Reference Card

**⚡ For TRAE SOLO - Copy/Paste These Commands ⚡**

---

## 🚀 The 11 Commands (In Order)

### 1. Connect
```bash
ssh root@nexuscos.online
```

### 2. Navigate
```bash
cd /opt/nexus-cos
```

### 3. Check Branch
```bash
git branch
```

### 4. Pull Code
```bash
git pull origin main
```

### 5. Verify Script
```bash
ls -lah DEPLOY_PHASE_2.5.sh
```

### 6. Deploy (Main Command)
```bash
sudo ./DEPLOY_PHASE_2.5.sh
```
⏱ Wait 2-3 minutes for completion

### 7. Test Apex
```bash
curl -skI https://nexuscos.online/ | head -n 1
```
Expected: `HTTP/2 200`

### 8. Test Beta
```bash
curl -skI https://beta.nexuscos.online/ | head -n 1
```
Expected: `HTTP/2 200`

### 9. Test API Root
```bash
curl -skI https://nexuscos.online/api/ | head -n 1
```
Expected: `HTTP/2 200`

### 10. Test API Health
```bash
curl -skI https://nexuscos.online/api/health | head -n 1
```
Expected: `HTTP/2 200`

### 11. Test API Status
```bash
curl -skI https://nexuscos.online/api/system/status | head -n 1
```
Expected: `HTTP/2 200`

---

## ✅ Success = All 11 Commands Show Expected Results

---

## ❌ If ANY Command Fails:

1. **STOP**
2. **COPY** the error
3. **REPORT** immediately
4. **WAIT** for help

---

## 🔧 Quick Diagnostics (Only if Requested)

```bash
# Check nginx status
sudo systemctl status nginx

# Test nginx config
sudo nginx -t

# View nginx errors
sudo tail -n 50 /var/log/nginx/error.log

# Check backend
curl http://localhost:3004/api/health
```

---

## 📋 One-Liner (All Commands in Sequence)

**⚠️ USE THIS ONLY IF INSTRUCTED**

```bash
cd /opt/nexus-cos && \
git pull origin main && \
sudo ./DEPLOY_PHASE_2.5.sh && \
curl -skI https://nexuscos.online/ | head -n 1 && \
curl -skI https://beta.nexuscos.online/ | head -n 1 && \
curl -skI https://nexuscos.online/api/ | head -n 1 && \
curl -skI https://nexuscos.online/api/health | head -n 1 && \
curl -skI https://nexuscos.online/api/system/status | head -n 1
```

---

## 🎯 What Should Happen

```
╔════════════════════════════════════════════════════════════════╗
║         🎉 PHASE 2.5 DEPLOYMENT COMPLETE - SUCCESS 🎉         ║
╚════════════════════════════════════════════════════════════════╝

Your Nexus COS Platform is now live:

  ► Apex Domain:      https://nexuscos.online
  ► Beta Domain:      https://beta.nexuscos.online
  ► API Endpoints:    https://nexuscos.online/api/*

✓ Platform deployed and ready for production use!
```

---

**Time:** 5 minutes  
**Difficulty:** Easy  
**Rule:** Follow exactly, no improvising

---

**Version:** 1.0  
**PF:** PF-101
