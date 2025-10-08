# 🚀 Nexus COS - Quick Start Card

**Keep this handy for instant deployment!**

---

## 🎯 THE ONE-LINER

Deploy Nexus COS on your VPS:

```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash
```

---

## 📋 Prerequisites Checklist

- [ ] Ubuntu 20.04+ or Debian 10+
- [ ] 4GB RAM minimum
- [ ] 10GB free disk space
- [ ] Root/sudo access
- [ ] Ports 80, 443 open

**Check VPS readiness:**
```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/check-vps-readiness.sh | bash
```

---

## ⏱️ Deployment Time

**5-10 minutes** for complete setup

---

## 🌐 Access URLs

After deployment:

```
https://YOUR_VPS_IP/          # Main platform
https://YOUR_VPS_IP/admin/    # Admin panel
https://YOUR_VPS_IP/api/      # API endpoints
https://YOUR_VPS_IP/health    # Health check
```

---

## ✅ Quick Health Check

```bash
# Check service
sudo systemctl status nexuscos-app

# Test endpoint
curl http://localhost:3000/health

# View logs
sudo journalctl -u nexuscos-app -f
```

---

## 🔄 Restart Service

```bash
sudo systemctl restart nexuscos-app
sudo systemctl reload nginx
```

---

## 📊 View Deployment Report

```bash
cat /opt/nexus-cos/TRAE_SOLO_BULLETPROOF_DEPLOYMENT_REPORT.md
```

---

## 🐛 Quick Troubleshooting

### Service won't start?
```bash
sudo journalctl -u nexuscos-app -n 50
sudo systemctl restart nexuscos-app
```

### Port in use?
```bash
sudo ss -ltnp | grep ':3000'
sudo kill -9 <PID>
```

### Nginx error?
```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## 📚 Full Documentation

**[VPS_ONE_SHOT_DEPLOY.md](VPS_ONE_SHOT_DEPLOY.md)** - Complete deployment guide

**[BULLETPROOF_ONE_LINER.md](BULLETPROOF_ONE_LINER.md)** - Detailed technical docs

---

## 🎉 What You Get

✅ Complete OTT/Streaming TV Platform  
✅ Live TV channels + On-Demand content  
✅ Integrated modules (Club Saditty, Creator Hub, V-Suite, etc.)  
✅ Admin dashboard  
✅ Real-time analytics  
✅ Auto-configured SSL/HTTPS  
✅ Health monitoring  
✅ Systemd service management  

---

**Nexus COS** - Your complete streaming platform in one command! 🚀
