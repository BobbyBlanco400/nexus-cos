# 🛡️ Bulletproof Deployment - Quick Reference Card

## 🚀 One-Liner Deployment (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash
```

**That's it!** This single command deploys everything.

---

## 📋 What Gets Deployed?

- ✅ Main Nexus COS service (Port 3000)
- ✅ V-Suite microservice
- ✅ Metatwin microservice
- ✅ Creator Hub microservice
- ✅ PuaboVerse microservice
- ✅ Nginx reverse proxy with SSL
- ✅ All health checks and monitoring

---

## ⏱️ Deployment Time

**5-10 minutes** from start to finish (depending on network speed)

---

## 🔍 Quick Verification

After deployment, test these:

```bash
# Main health check
curl https://n3xuscos.online/health

# Service status
systemctl status nexuscos-app

# Port check
ss -ltnp | grep ':3000'

# View deployment report
cat /opt/nexus-cos/TRAE_SOLO_BULLETPROOF_DEPLOYMENT_REPORT.md
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| `BULLETPROOF_ONE_LINER.md` | Complete one-liner guide |
| `TRAE_SOLO_BULLETPROOF_GUIDE.md` | Full usage manual |
| `BULLETPROOF_DEPLOYMENT_SUMMARY.md` | Implementation details |
| `README.md` | Main project README |

---

## 🛠️ Service Management

### Main Service
```bash
systemctl status nexuscos-app      # Check status
systemctl restart nexuscos-app     # Restart
journalctl -u nexuscos-app -f      # View logs
```

### All Services
```bash
systemctl status nexuscos-*        # Check all
systemctl restart nexuscos-*       # Restart all
```

### Nginx
```bash
systemctl status nginx             # Status
nginx -t                           # Test config
systemctl reload nginx             # Reload
```

---

## 📊 Logs

```bash
# Deployment logs
cat /opt/nexus-cos/logs/deployment-*.log

# Error logs
cat /opt/nexus-cos/logs/errors-*.log

# Service logs
journalctl -u nexuscos-app -n 100

# Nginx logs
tail -f /var/log/nginx/nexus-cos.error.log
```

---

## 🆘 Troubleshooting

### Port Already in Use
```bash
ss -ltnp | grep ':3000'            # Find what's using port
kill -9 <PID>                      # Kill process
systemctl restart nexuscos-app     # Restart service
```

### Service Won't Start
```bash
systemctl status nexuscos-app      # Check status
journalctl -u nexuscos-app -n 50   # View logs
systemctl daemon-reload            # Reload systemd
systemctl restart nexuscos-app     # Try restart
```

### Nginx Error
```bash
nginx -t                           # Test config
tail -100 /var/log/nginx/nexus-cos.error.log
systemctl reload nginx             # Reload if config OK
```

---

## 🎯 Key Features

- 🛡️ **Compliance Guaranteed** - All validation must pass
- 🔄 **Error Recovery** - Automatic service restoration
- 📊 **Complete Visibility** - Full audit trail
- 🔒 **Security Hardened** - SSL, HTTPS, headers
- ⚡ **Performance Optimized** - Caching, compression
- 🚀 **12-Phase Deployment** - Systematic approach

---

## ✅ Success Indicators

After successful deployment, you should see:
- ✅ `systemctl status nexuscos-app` showing "active (running)"
- ✅ `ss -ltnp | grep ':3000'` showing listening port
- ✅ `curl https://n3xuscos.online/health` returning success
- ✅ Deployment report generated
- ✅ All logs showing no errors

---

## 🔗 URLs After Deployment

- 🌐 Frontend: https://n3xuscos.online
- 🔧 API: https://n3xuscos.online/api/
- 📊 Health: https://n3xuscos.online/health
- 🔍 Alt Health: https://n3xuscos.online/healthz

---

## 💡 Pro Tips

1. Always run with `sudo` - the script needs root access
2. Check logs during deployment: `tail -f /opt/nexus-cos/logs/deployment-*.log`
3. The script is idempotent - safe to run multiple times
4. Review the deployment report after completion
5. Clear browser cache before testing (Ctrl+Shift+Del)

---

## 🆕 Alternative Deployment Methods

### Local Deployment
```bash
cd /opt/nexus-cos
sudo bash trae-solo-bulletproof-deploy.sh
```

### Custom Repository Path
```bash
export REPO_PATH="/custom/path"
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash
```

### Test Before Deploying
```bash
cd /opt/nexus-cos
bash test-bulletproof-deployment.sh
```

---

## 📞 Support

Need help?
1. Check deployment logs: `/opt/nexus-cos/logs/deployment-*.log`
2. Check error logs: `/opt/nexus-cos/logs/errors-*.log`
3. View deployment report: `/opt/nexus-cos/TRAE_SOLO_BULLETPROOF_DEPLOYMENT_REPORT.md`
4. Review documentation: `TRAE_SOLO_BULLETPROOF_GUIDE.md`

---

## ⚙️ Configuration

Environment: `/opt/nexus-cos/.env`
Nginx Config: `/etc/nginx/sites-available/nexuscos`
Service Files: `/etc/systemd/system/nexuscos-*.service`

---

## 🎉 That's It!

Deploy with confidence using the bulletproof one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash
```

**Compliance Guaranteed. Full Launch Ready.**

---

*For complete documentation, see `BULLETPROOF_ONE_LINER.md` and `TRAE_SOLO_BULLETPROOF_GUIDE.md`*
