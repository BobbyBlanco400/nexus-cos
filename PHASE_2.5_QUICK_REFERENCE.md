# Nexus COS Phase 2.5 - Quick Reference Guide

**PF ID:** PF-HYBRID-FULLSTACK-2025.10.07-PHASE-2.5  
**Status:** ACTIVE  
**Priority:** HIGH / EXPEDITED

---

## 🎯 What is Phase 2.5?

Phase 2.5 introduces **unified deployment** of three system layers under one PF framework:

| Layer | Domain/Path | Purpose | Status |
|-------|-------------|---------|--------|
| **OTT Frontend** | `nexuscos.online` | Public streaming interface | Permanent |
| **V-Suite Dashboard** | `nexuscos.online/v-suite/` | Creator control center | Permanent |
| **Beta Portal** | `beta.nexuscos.online` | Pre-launch showcase | Until Nov 17, 2025 |

---

## ⚡ Quick Deploy

### One-Liner Deployment

```bash
cd /opt/nexus-cos && ./scripts/deploy-phase-2.5-architecture.sh && ./scripts/validate-phase-2.5-deployment.sh
```

### Step-by-Step

```bash
# 1. Deploy Phase 2.5
cd /opt/nexus-cos
./scripts/deploy-phase-2.5-architecture.sh

# 2. Validate
./scripts/validate-phase-2.5-deployment.sh

# 3. Schedule transition (for Nov 17, 2025)
crontab -e
# Add: 0 0 17 11 2025 /opt/nexus-cos/scripts/beta-transition-cutover.sh >> /opt/nexus-cos/logs/phase2.5/transition/cutover.log 2>&1
```

---

## 📁 Directory Structure

```
/opt/nexus-cos/
├── scripts/
│   ├── deploy-phase-2.5-architecture.sh     # Main deployment
│   ├── validate-phase-2.5-deployment.sh     # Validation
│   └── beta-transition-cutover.sh           # Auto-generated transition
├── logs/
│   └── phase2.5/
│       ├── ott/           # OTT frontend logs
│       ├── dashboard/     # V-Suite logs
│       ├── beta/          # Beta portal logs
│       └── transition/    # Transition logs
└── backups/
    └── phase2.5/          # Configuration backups

/var/www/
├── nexuscos.online/           # OTT frontend files
└── beta.nexuscos.online/      # Beta portal files

/etc/nginx/
├── sites-available/
│   ├── nexuscos-phase-2.5           # Active Phase 2.5 config
│   └── nexuscos-post-transition     # Auto-generated for Nov 17
└── sites-enabled/
    └── nexuscos -> nexuscos-phase-2.5
```

---

## 🔍 Quick Status Check

```bash
# Check all layers
curl -I https://nexuscos.online/              # OTT Frontend
curl -I https://nexuscos.online/v-suite/      # V-Suite Dashboard
curl -I https://beta.nexuscos.online/         # Beta Portal

# Check health endpoints
curl http://localhost:4000/health             # Gateway API
curl http://localhost:3002/health             # V-Prompter
curl http://localhost:3041/health             # PV Keys

# Check nginx
nginx -t && systemctl status nginx

# Check Docker services
docker compose -f /opt/nexus-cos/docker-compose.pf.yml ps

# View logs
tail -f /opt/nexus-cos/logs/phase2.5/*/access.log
```

---

## 🔧 Common Operations

### Restart Services

```bash
cd /opt/nexus-cos
docker compose -f docker-compose.pf.yml restart
systemctl reload nginx
```

### View Logs

```bash
# All Phase 2.5 logs
tail -f /opt/nexus-cos/logs/phase2.5/*/access.log

# Specific layer
tail -f /opt/nexus-cos/logs/phase2.5/ott/access.log
tail -f /opt/nexus-cos/logs/phase2.5/dashboard/access.log
tail -f /opt/nexus-cos/logs/phase2.5/beta/access.log
```

### Check Transition Status

```bash
# Check if transition is scheduled
crontab -l | grep beta-transition

# Test transition script (creates backup, doesn't actually run)
cat /opt/nexus-cos/scripts/beta-transition-cutover.sh
```

### Rollback Nginx Config

```bash
# List backups
ls -la /opt/nexus-cos/backups/phase2.5/

# Restore specific backup
sudo cp /opt/nexus-cos/backups/phase2.5/nexuscos.conf.YYYYMMDD_HHMMSS \
        /etc/nginx/sites-available/nexuscos-phase-2.5
sudo nginx -t && sudo systemctl reload nginx
```

---

## 🚨 Troubleshooting

### Landing Pages Not Loading

```bash
# Check files exist
ls -la /var/www/nexuscos.online/index.html
ls -la /var/www/beta.nexuscos.online/index.html

# Check permissions
sudo chown -R www-data:www-data /var/www/nexuscos.online
sudo chown -R www-data:www-data /var/www/beta.nexuscos.online
sudo chmod -R 755 /var/www/nexuscos.online
sudo chmod -R 755 /var/www/beta.nexuscos.online
```

### Nginx Errors

```bash
# Test configuration
sudo nginx -t

# View error logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /opt/nexus-cos/logs/phase2.5/*/error.log

# Restart nginx
sudo systemctl restart nginx
```

### Backend Services Down

```bash
# Check service status
docker compose -f /opt/nexus-cos/docker-compose.pf.yml ps

# View service logs
docker compose -f /opt/nexus-cos/docker-compose.pf.yml logs -f [service-name]

# Restart specific service
docker compose -f /opt/nexus-cos/docker-compose.pf.yml restart [service-name]

# Restart all services
docker compose -f /opt/nexus-cos/docker-compose.pf.yml restart
```

### SSL Certificate Issues

```bash
# Check certificate exists
ls -la /etc/nginx/ssl/apex/
ls -la /etc/nginx/ssl/beta/

# Check certificate validity
openssl x509 -in /etc/nginx/ssl/apex/nexuscos.online.crt -noout -dates
openssl x509 -in /etc/nginx/ssl/beta/beta.nexuscos.online.crt -noout -dates

# Test SSL connection
openssl s_client -connect nexuscos.online:443 -showcerts
openssl s_client -connect beta.nexuscos.online:443 -showcerts
```

---

## 📅 Transition Timeline

### Pre-Transition (Now - Nov 16, 2025)
- Beta portal active at `beta.nexuscos.online`
- OTT and V-Suite operational at `nexuscos.online`
- All three layers coexist

### Transition Day (Nov 17, 2025)
- Automated cutover at 00:00 UTC
- Beta domain redirects to production
- No service interruption

### Post-Transition (Nov 18, 2025+)
- Beta domain permanently redirects
- OTT and V-Suite continue on production
- Beta can be repurposed as staging

---

## ✅ Validation Checklist

### Deployment Validation
- [ ] Phase 2.5 scripts executed successfully
- [ ] All directories created
- [ ] Landing pages deployed
- [ ] Nginx configuration active
- [ ] SSL certificates valid
- [ ] Backend services running

### Operational Validation
- [ ] `nexuscos.online` accessible
- [ ] `beta.nexuscos.online` accessible
- [ ] `/v-suite/` routes correctly
- [ ] Health endpoints returning 200
- [ ] Logs being written
- [ ] Transition script created

### Transition Readiness
- [ ] Transition script tested
- [ ] Cron job scheduled
- [ ] Rollback procedure documented
- [ ] Team notified of transition date

---

## 📞 Emergency Contacts

**Primary:** Bobby Blanco (PUABO)  
**Technical Lead:** TRAE SOLO (GitHub Code Agent)  
**Infrastructure:** CloudFlare + IONOS  

### Emergency Procedures

1. **Service Down:** Check health endpoints → Review logs → Restart services
2. **SSL Issues:** Verify certificates → Check nginx config → Reload nginx
3. **Transition Rollback:** Run rollback commands → Restore beta config → Notify team

---

## 📚 Related Documentation

- **Main PF Directive:** `PF_PHASE_2.5_OTT_INTEGRATION.md`
- **TRAE Execution Guide:** `TRAE_SOLO_EXECUTION.md`
- **PR87 Integration:** `PR87_ENFORCEMENT_INTEGRATION.md`
- **Deployment Scripts:** `scripts/deploy-phase-2.5-architecture.sh`
- **Validation Scripts:** `scripts/validate-phase-2.5-deployment.sh`

---

## 🎯 Success Criteria

Phase 2.5 is **production ready** when:

✅ All three layers operational  
✅ Dual-domain routing validated  
✅ Health checks passing  
✅ SSL certificates valid  
✅ Logs separated by layer  
✅ Transition automation scheduled  
✅ Team trained on architecture

---

**Last Updated:** October 7, 2025  
**Version:** 1.0  
**Status:** ACTIVE
