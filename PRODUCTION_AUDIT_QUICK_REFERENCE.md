# Nexus COS Production Audit - Quick Reference

## One-Line Commands

### Run Complete Audit
```bash
./nexus-cos-complete-audit.sh
```

### Run and Save Results
```bash
./nexus-cos-complete-audit.sh > audit-$(date +%Y%m%d-%H%M%S).log 2>&1
```

### Run from Production Directory
```bash
cd /var/www/nexuscos.online/nexus-cos-app && ./nexus-cos-complete-audit.sh
```

## Quick Status Checks

### Check Docker Containers
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep nexus
```

### Check Backend Health
```bash
curl -s http://localhost:8000/health/ | jq '.'
```

### Check V-Screen Hollywood
```bash
curl -s http://localhost:3004/health | jq '.'
```

### Check V-Suite Orchestrator
```bash
curl -s http://localhost:3005/health | jq '.'
```

### Check Monitoring Service
```bash
curl -s http://localhost:3006/health
```

### Check Database
```bash
docker exec nexus-postgres psql -U postgres -d nexus_cos -c "\dt"
```

### Check Frontend Deployment
```bash
ls -1 /var/www/vhosts/nexuscos.online/httpdocs/*.html | wc -l
```

### Check SSL/HTTPS
```bash
curl -I https://nexuscos.online
```

## Readiness Levels

| Level | Exit Code | Meaning | Action |
|-------|-----------|---------|--------|
| ✅ CONFIRMED | 0 | Ready for launch | Proceed with deployment |
| ⚠️ CONDITIONAL | 1 | Review warnings | Fix warnings, re-run audit |
| ❌ NOT READY | 2 | Critical issues | Fix failures, DO NOT LAUNCH |

## 37 Modules Checklist

### Core Platform (8)
- [ ] Landing Page
- [ ] Dashboard
- [ ] Authentication
- [ ] Creator Hub
- [ ] Admin Panel
- [ ] Pricing/Subscriptions
- [ ] User Management
- [ ] Settings

### V-Suite (4)
- [ ] V-Screen Hollywood
- [ ] V-Caster
- [ ] V-Stage
- [ ] V-Prompter

### PUABO Fleet (4)
- [ ] Driver App
- [ ] AI Dispatch
- [ ] Fleet Manager
- [ ] Route Optimizer

### Urban Suite (6)
- [ ] Club Saditty
- [ ] IDH Beauty
- [ ] Clocking T
- [ ] Sheda Shay
- [ ] Ahshanti's Munch
- [ ] Tyshawn's Dance

### Family Suite (5)
- [ ] Fayeloni Kreations
- [ ] Sassie Lashes
- [ ] NeeNee Kids Show
- [ ] RoRo Gaming
- [ ] Faith Through Fitness

### Additional Modules (10)
- [ ] Analytics Dashboard
- [ ] Content Library
- [ ] Live Streaming Hub
- [ ] AI Production Tools
- [ ] Collaboration Workspace
- [ ] Asset Management
- [ ] Render Farm Interface
- [ ] Notifications Center
- [ ] Help & Support
- [ ] API Documentation

## Pre-Launch Checklist

- [ ] All Docker containers running
- [ ] Database migrated and accessible
- [ ] Frontend built and deployed
- [ ] Environment variables configured
- [ ] SSL certificates installed
- [ ] Nginx configured and tested
- [ ] PM2 processes started
- [ ] Firewall rules configured
- [ ] Backup/snapshot created
- [ ] Monitoring enabled
- [ ] Rollback plan prepared
- [ ] Team notified

## Emergency Contacts

**Launch Date:** November 17, 2025 @ 12:00 AM PST  
**Platform:** https://nexuscos.online  

For production issues, escalate immediately to platform administrators.

## Quick Fixes

### Restart All Services
```bash
# Docker
docker-compose -f docker-compose.pf.yml restart

# PM2
pm2 restart all

# Nginx
sudo systemctl restart nginx
```

### View Logs
```bash
# Docker containers
docker logs nexus-backend
docker logs nexus-postgres
docker logs nexus-frontend

# PM2 processes
pm2 logs

# Nginx
sudo tail -f /var/log/nginx/error.log
```

### Database Quick Check
```bash
docker exec nexus-postgres psql -U postgres -c "\l"
docker exec nexus-postgres psql -U postgres -d nexus_cos -c "SELECT COUNT(*) FROM users;"
```

---

**Full Documentation:** See [NEXUS_COS_PRODUCTION_AUDIT_GUIDE.md](./NEXUS_COS_PRODUCTION_AUDIT_GUIDE.md)
