# Nexus COS System Check - Quick Reference

**Script:** `scripts/nexus-cos-final-system-check.sh`  
**Version:** PF v2025.10.01

---

## Quick Commands

### Run Complete System Check
```bash
bash scripts/nexus-cos-final-system-check.sh
```

### On VPS (Production)
```bash
ssh user@nexuscos.online
cd /opt/nexus-cos
bash scripts/nexus-cos-final-system-check.sh
```

### With Custom Domain
```bash
DOMAIN=beta.nexuscos.online bash scripts/nexus-cos-final-system-check.sh
```

---

## What Gets Checked (60+ Checks)

### ✅ System Requirements
- Docker & Docker Compose
- Nginx
- Git, curl, openssl
- Disk space & memory

### ✅ Deployment Artifacts
- Scripts (deploy_hybrid_fullstack_pf.sh, update-nginx-puabo-nexus-routes.sh)
- Docker Compose files (docker-compose.pf.yml, docker-compose.pf.nexus.yml)
- Nginx configuration (nginx/nginx.conf)
- Environment files (.env.pf)
- Documentation (PF_v2025.10.01.md, PF_v2025.10.01_HEALTH_CHECKS.md)

### ✅ Docker Stacks
- Compose file syntax validation
- Running services count
- Docker networks (nexus-network, cos-net)

### ✅ Nginx Configuration
- Configuration syntax (nginx -t)
- Service status

### ✅ SSL Certificate
- Certificate retrieval for nexuscos.online
- Issuer, subject, validity dates
- Expiration check (warns if < 30 days)

### ✅ Internal Health Endpoints
- AI Dispatch (127.0.0.1:9001)
- Driver Backend (127.0.0.1:9002)
- Fleet Manager (127.0.0.1:9003)
- Route Optimizer (127.0.0.1:9004)

### ✅ Preview URLs
- Home Page (/)
- Admin Portal (/admin)
- Creator Hub (/hub)
- Studio (/studio)
- V-Suite Prompter (/v-suite/prompter/health)

### ✅ Service Health Endpoints (14 Services)
**Core:**
- Core API Gateway (/api/health)
- Gateway Health (/health/gateway)

**PUABO NEXUS:**
- AI Dispatch (/puabo-nexus/dispatch/health)
- Driver Backend (/puabo-nexus/driver/health)
- Fleet Manager (/puabo-nexus/fleet/health)
- Route Optimizer (/puabo-nexus/routes/health)

**V-Suite:**
- V-Prompter Pro (/v-suite/prompter/health)
- VScreen Hollywood (/v-suite/screen/health)

**Media & Entertainment:**
- Nexus Studio AI (/nexus-studio/health)
- Club Saditty (/club-saditty/health)
- PUABO DSP (/puabo-dsp/health)
- PUABO BLAC (/puabo-blac/health)

**Auth & Payment:**
- Nexus ID OAuth (/auth/health)
- Nexus Pay Gateway (/payment/health)

---

## Understanding Results

### ✓ Green Checkmark
- Check passed successfully
- System component is healthy

### ✗ Red X
- Check failed
- Requires attention

### ⚠ Yellow Warning
- Non-critical issue
- System may still be operational
- Review recommended

---

## Exit Codes

- `0` - All checks passed (system fully operational)
- `1` - Some checks failed (review needed)

---

## Output Sections

1. **System Requirements & Versions** - Infrastructure tools
2. **Deployment Artifacts** - Files and scripts
3. **Docker Stack Validation** - Container orchestration
4. **Nginx Configuration** - Web server config
5. **SSL Certificate Validation** - HTTPS security
6. **Internal Health Endpoints** - Internal service health
7. **Preview URLs** - Public pages
8. **Service Health Endpoints** - API health checks
9. **Summary** - Results overview
10. **Useful Commands** - Next steps
11. **Next Steps** - Recommendations

---

## Useful Commands (From Script Output)

### Re-run Systems Check
```bash
nginx -t
docker compose -f docker-compose.pf.yml ps
docker compose -f docker-compose.pf.nexus.yml ps
curl -I https://nexuscos.online/api/health
curl -I https://nexuscos.online/puabo-nexus/fleet/health
```

### View Service Logs
```bash
docker compose -f docker-compose.pf.yml logs -f
docker compose -f docker-compose.pf.nexus.yml logs -f
docker compose -f docker-compose.pf.yml logs -f <service-name>
```

### Restart Services
```bash
docker compose -f docker-compose.pf.yml restart
docker compose -f docker-compose.pf.nexus.yml restart
systemctl restart nginx
```

### Redeploy (if needed)
```bash
bash /opt/nexus-cos/scripts/deploy_hybrid_fullstack_pf.sh
```

---

## When to Run

- ✅ **After deployment** - Verify all services
- ✅ **Daily** - During active development
- ✅ **Weekly** - In stable production
- ✅ **Before releases** - Pre-production validation
- ✅ **After configuration changes** - Nginx, Docker, SSL
- ✅ **When debugging issues** - Comprehensive diagnostics

---

## Troubleshooting

### Many Services Failing?
1. Check if Docker services are running
2. Verify environment variables in .env.pf
3. Check Docker logs: `docker compose logs -f`
4. Consider redeployment

### SSL Certificate Issues?
1. Check certificate expiration
2. Verify DNS pointing to correct server
3. Check Let's Encrypt renewal
4. Review Nginx SSL configuration

### Nginx Configuration Errors?
1. Run `sudo nginx -t` for detailed errors
2. Check syntax in nginx/nginx.conf
3. Verify all upstream services are defined
4. Restart Nginx after fixes

### Docker Services Not Running?
1. Check .env.pf file exists and has valid values
2. Verify Docker Compose file syntax
3. Check Docker logs for errors
4. Restart services: `docker compose restart`

---

## Success Criteria

### All Systems Operational (Green)
- Pass rate: 100%
- All services healthy
- No deployment needed
- System ready for use

### Mostly Operational (Yellow)
- Pass rate: 80-99%
- Some non-critical services down
- Review failed checks
- May need service restart

### Needs Attention (Red)
- Pass rate: <80%
- Multiple critical services down
- Review all failed checks
- Redeployment recommended

---

## Related Scripts

| Script | Purpose |
|--------|---------|
| `nexus-cos-final-system-check.sh` | **Complete validation (60+ checks)** |
| `check-pf-v2025-health.sh` | Quick health endpoint check |
| `deploy_hybrid_fullstack_pf.sh` | Full deployment script |
| `pf-final-deploy.sh` | PF final deployment |

---

## Documentation

- **Complete Guide:** [FINAL_SYSTEM_CHECK_COMPLETE.md](FINAL_SYSTEM_CHECK_COMPLETE.md)
- **Health Checks:** [PF_v2025.10.01_HEALTH_CHECKS.md](PF_v2025.10.01_HEALTH_CHECKS.md)
- **Scripts README:** [scripts/README.md](scripts/README.md)
- **PF Version:** [PF_v2025.10.01.md](PF_v2025.10.01.md)

---

## Example Output

```
╔════════════════════════════════════════════════════════════════╗
║     NEXUS COS - FINAL COMPLETE SYSTEM CHECK                   ║
║     PF v2025.10.01 - Full Platform Validation                 ║
╚════════════════════════════════════════════════════════════════╝

Domain: nexuscos.online
VPS IP: 74.208.155.161
Date: 2025-01-08 12:00:00 UTC

═══════════════════════════════════════════════════════════════
  1. SYSTEM REQUIREMENTS & VERSIONS
═══════════════════════════════════════════════════════════════

✓ Docker is installed
✓ Docker Compose (plugin) is available
✓ Nginx is installed
✓ curl is installed
✓ Git is installed

...

╔════════════════════════════════════════════════════════════════╗
║                      RESULTS SUMMARY                           ║
╚════════════════════════════════════════════════════════════════╝

✓ Passed:      58
✗ Failed:      1
⚠ Warnings:    1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Checks:  60
Success Rate:  96%

⚠ SYSTEM STATUS: MOSTLY OPERATIONAL
```

---

**Quick Start:** `bash scripts/nexus-cos-final-system-check.sh`

**For Help:** Check [FINAL_SYSTEM_CHECK_COMPLETE.md](FINAL_SYSTEM_CHECK_COMPLETE.md)
