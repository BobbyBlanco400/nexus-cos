# Nexus COS Phase 2.5 - OTT Integration + Beta Transition

**Welcome to Phase 2.5!** This README provides a high-level overview of the Phase 2.5 architecture and guides you to the appropriate documentation.

---

## 🎯 What is Phase 2.5?

Phase 2.5 represents a **bulletproofed, production-ready** deployment framework that unifies three critical system layers under one PF (Platform Framework) deployment:

### The Three Layers

1. **🎬 OTT Frontend** (`n3xuscos.online`)
   - Public-facing streaming interface for media, shows, music, and live events
   - Direct access for all viewers
   - Permanent production layer

2. **🎛️ V-Suite Dashboard** (`n3xuscos.online/v-suite/`)
   - Creator and operator control center
   - Modules: DSP, BLAC, Dispatch, Nuki, and more
   - Secured with Nexus ID SSO
   - Permanent production layer

3. **🚀 Beta Launch Portal** (`beta.n3xuscos.online`)
   - Pre-launch promotional hub with countdown
   - Feature showcase and registration
   - Active until **November 17, 2025**
   - Automatically transitions to production

---

## ⚡ Quick Start

### For System Administrators

```bash
# One-line deployment
cd /opt/nexus-cos
sudo ./scripts/deploy-phase-2.5-architecture.sh && \
sudo ./scripts/validate-phase-2.5-deployment.sh
```

### For Developers

1. **Read the architecture:** [`PF_PHASE_2.5_OTT_INTEGRATION.md`](./PF_PHASE_2.5_OTT_INTEGRATION.md)
2. **Follow execution guide:** [`TRAE_SOLO_EXECUTION.md`](./TRAE_SOLO_EXECUTION.md)
3. **Use quick reference:** [`PHASE_2.5_QUICK_REFERENCE.md`](./PHASE_2.5_QUICK_REFERENCE.md)

### For Operations Teams

1. **Check the index:** [`PHASE_2.5_INDEX.md`](./PHASE_2.5_INDEX.md)
2. **Monitor health:** `curl http://localhost:4000/health`
3. **View logs:** `tail -f /opt/nexus-cos/logs/phase2.5/*/access.log`

---

## 📚 Documentation Structure

### Core Documents

| Document | Purpose | Audience |
|----------|---------|----------|
| [PF_PHASE_2.5_OTT_INTEGRATION.md](./PF_PHASE_2.5_OTT_INTEGRATION.md) | Official PF directive with complete specs | All teams |
| [TRAE_SOLO_EXECUTION.md](./TRAE_SOLO_EXECUTION.md) | Step-by-step deployment instructions | Deployment agents |
| [PHASE_2.5_QUICK_REFERENCE.md](./PHASE_2.5_QUICK_REFERENCE.md) | Quick lookup for operations | Ops teams |
| [PHASE_2.5_INDEX.md](./PHASE_2.5_INDEX.md) | Navigation hub for all docs | All teams |
| [PHASE_2.5_README.md](./PHASE_2.5_README.md) | This file - overview and quickstart | New users |

### Deployment Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `scripts/deploy-phase-2.5-architecture.sh` | Main deployment automation | `sudo ./scripts/deploy-phase-2.5-architecture.sh` |
| `scripts/validate-phase-2.5-deployment.sh` | Comprehensive validation | `sudo ./scripts/validate-phase-2.5-deployment.sh` |
| `scripts/beta-transition-cutover.sh` | Automated transition (auto-generated) | Scheduled for Nov 17, 2025 |

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    NEXUS COS PHASE 2.5                  │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │                                                 │    │
│  │  OTT FRONTEND (n3xuscos.online)                │    │
│  │  Public Streaming Interface                     │    │
│  │  Permanent Production                           │    │
│  │                                                 │    │
│  └────────────────────────────────────────────────┘    │
│                        ▲                                 │
│                        │                                 │
│  ┌────────────────────┼──────────────────────────┐     │
│  │                    │                           │     │
│  │  V-SUITE DASHBOARD │ (/v-suite/)              │     │
│  │  Creator Control   │ Center                    │     │
│  │  Nexus ID SSO     │ Protected                 │     │
│  │  Permanent         │ Production                │     │
│  │                    │                           │     │
│  └────────────────────┴──────────────────────────┘     │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │                                                 │    │
│  │  BETA PORTAL (beta.n3xuscos.online)            │    │
│  │  Pre-Launch Showcase + Countdown               │    │
│  │  Active until Nov 17, 2025                     │    │
│  │                                                 │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  ┌─────────────────────────────────────────┐           │
│  │                                          │           │
│  │  BACKEND SERVICES (Docker Compose)      │           │
│  │  - Gateway API (4000)                   │           │
│  │  - V-Prompter Pro (3002)                │           │
│  │  - PV Keys (3041)                       │           │
│  │  - V-Screen Hollywood (8088)            │           │
│  │  - StreamCore (3016)                    │           │
│  │                                          │           │
│  └─────────────────────────────────────────┘           │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 🔐 Key Features

### Dual-Domain Routing
- **Production:** `n3xuscos.online` serves OTT + V-Suite
- **Beta:** `beta.n3xuscos.online` serves pre-launch portal
- **Isolated:** Each domain has independent Nginx configuration
- **Unified:** All layers share backend services

### Automated Transition
- **Date:** November 17, 2025 at 00:00 UTC
- **Action:** Beta domain automatically redirects to production
- **Method:** Cron-scheduled cutover script
- **Rollback:** Automatic on failure, manual option available

### Comprehensive Logging
- **Separated by layer:** OTT, Dashboard, Beta
- **Location:** `/opt/nexus-cos/logs/phase2.5/`
- **Rotation:** Daily with 30-day retention
- **Monitoring:** Real-time log streaming available

### SSL/TLS Security
- **Provider:** IONOS certificates
- **Protocols:** TLS 1.2, TLS 1.3
- **HSTS:** Enabled with 1-year max-age
- **Renewal:** Automated 30 days before expiration

### Health Monitoring
- **Gateway API:** `http://localhost:4000/health`
- **V-Prompter:** `http://localhost:3002/health`
- **PV Keys:** `http://localhost:3041/health`
- **Hollywood:** `http://localhost:8088/health`
- **StreamCore:** `http://localhost:3016/health`

---

## 🚀 Getting Started

### Prerequisites

- Ubuntu 20.04+ or similar Linux distribution
- Root or sudo access
- Docker and Docker Compose installed
- Nginx installed
- IONOS SSL certificates available
- Repository cloned to `/opt/nexus-cos`

### Installation Steps

1. **Clone Repository** (if not already done)
   ```bash
   sudo mkdir -p /opt/nexus-cos
   cd /opt/nexus-cos
   sudo git clone https://github.com/BobbyBlanco400/nexus-cos.git .
   ```

2. **Make Scripts Executable**
   ```bash
   sudo chmod +x scripts/deploy-phase-2.5-architecture.sh
   sudo chmod +x scripts/validate-phase-2.5-deployment.sh
   ```

3. **Run Deployment**
   ```bash
   sudo ./scripts/deploy-phase-2.5-architecture.sh
   ```

4. **Validate Deployment**
   ```bash
   sudo ./scripts/validate-phase-2.5-deployment.sh
   ```

5. **Schedule Transition** (for Nov 17, 2025)
   ```bash
   sudo crontab -e
   # Add this line:
   0 0 17 11 2025 /opt/nexus-cos/scripts/beta-transition-cutover.sh >> /opt/nexus-cos/logs/phase2.5/transition/cutover.log 2>&1
   ```

### Expected Results

After successful deployment, you should see:

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              PHASE 2.5 DEPLOYMENT COMPLETE                     ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                   ✓ ALL CHECKS PASSED                          ║
║                                                                ║
║          Phase 2.5 Deployment is Production Ready!             ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

---

## 📊 System Status Check

### Quick Health Check

```bash
# Check all endpoints
curl -I https://n3xuscos.online/
curl -I https://n3xuscos.online/v-suite/
curl -I https://beta.n3xuscos.online/

# Check backend health
curl http://localhost:4000/health
curl http://localhost:3002/health
curl http://localhost:3041/health

# Check nginx
sudo nginx -t && systemctl status nginx

# Check Docker services
docker compose -f /opt/nexus-cos/docker-compose.pf.yml ps
```

### Monitoring

```bash
# Watch logs in real-time
tail -f /opt/nexus-cos/logs/phase2.5/*/access.log

# Monitor specific layer
tail -f /opt/nexus-cos/logs/phase2.5/ott/access.log
tail -f /opt/nexus-cos/logs/phase2.5/dashboard/access.log
tail -f /opt/nexus-cos/logs/phase2.5/beta/access.log
```

---

## 🗓️ Timeline

### Current Status (Oct 2025 - Nov 16, 2025)

- ✅ Phase 2.5 deployed
- ✅ All three layers operational
- ✅ Beta portal active at `beta.n3xuscos.online`
- ✅ OTT and V-Suite live at `n3xuscos.online`

### Transition Day (Nov 17, 2025)

- ⏰ Automated cutover at 00:00 UTC
- 🔄 Beta domain redirects to production
- ✅ No service interruption expected

### Post-Transition (Nov 18, 2025+)

- ✅ Beta domain permanently redirects
- ✅ OTT and V-Suite continue on production
- 🔧 Beta can be repurposed for staging

---

## 🔧 Common Operations

### Restart Services

```bash
# Restart all backend services
cd /opt/nexus-cos
docker compose -f docker-compose.pf.yml restart

# Restart specific service
docker compose -f docker-compose.pf.yml restart [service-name]

# Reload nginx
sudo systemctl reload nginx
```

### View Service Logs

```bash
# All services
docker compose -f /opt/nexus-cos/docker-compose.pf.yml logs -f

# Specific service
docker compose -f /opt/nexus-cos/docker-compose.pf.yml logs -f puabo-api
```

### Update Configuration

```bash
# Edit nginx configuration
sudo nano /etc/nginx/sites-available/nexuscos-phase-2.5

# Test configuration
sudo nginx -t

# Apply changes
sudo systemctl reload nginx
```

---

## 🚨 Troubleshooting

### Landing Pages Not Loading

**Symptoms:** 404 or 403 errors when accessing domains

**Solution:**
```bash
# Check files exist
ls -la /var/www/n3xuscos.online/index.html
ls -la /var/www/beta.n3xuscos.online/index.html

# Fix permissions
sudo chown -R www-data:www-data /var/www/n3xuscos.online
sudo chown -R www-data:www-data /var/www/beta.n3xuscos.online
sudo chmod -R 755 /var/www/n3xuscos.online /var/www/beta.n3xuscos.online

# Reload nginx
sudo systemctl reload nginx
```

### Backend Services Not Responding

**Symptoms:** Health checks return connection refused

**Solution:**
```bash
# Check Docker is running
sudo systemctl status docker

# Check services status
docker compose -f /opt/nexus-cos/docker-compose.pf.yml ps

# Restart services
cd /opt/nexus-cos
docker compose -f docker-compose.pf.yml restart

# Check logs
docker compose -f docker-compose.pf.yml logs -f
```

### SSL Certificate Errors

**Symptoms:** Browser shows certificate warnings

**Solution:**
```bash
# Check certificates exist
ls -la /etc/nginx/ssl/apex/
ls -la /etc/nginx/ssl/beta/

# Check certificate validity
openssl x509 -in /etc/nginx/ssl/apex/n3xuscos.online.crt -noout -dates

# Test SSL connection
openssl s_client -connect n3xuscos.online:443 -showcerts
```

For more troubleshooting, see [PHASE_2.5_QUICK_REFERENCE.md](./PHASE_2.5_QUICK_REFERENCE.md).

---

## 📞 Support

### Documentation

- **Issues with deployment:** [TRAE_SOLO_EXECUTION.md](./TRAE_SOLO_EXECUTION.md)
- **Operational questions:** [PHASE_2.5_QUICK_REFERENCE.md](./PHASE_2.5_QUICK_REFERENCE.md)
- **Architecture details:** [PF_PHASE_2.5_OTT_INTEGRATION.md](./PF_PHASE_2.5_OTT_INTEGRATION.md)
- **All documentation:** [PHASE_2.5_INDEX.md](./PHASE_2.5_INDEX.md)

### Contacts

- **Primary Contact:** Bobby Blanco (PUABO)
- **Technical Lead:** TRAE SOLO (GitHub Code Agent)
- **Infrastructure:** CloudFlare + IONOS

---

## ✅ Success Criteria

Phase 2.5 is **production ready** when:

- ✅ All three system layers operational
- ✅ Dual-domain routing validated
- ✅ All health endpoints returning 200
- ✅ SSL certificates valid for all domains
- ✅ Logs separated by layer
- ✅ Transition automation scheduled
- ✅ Validation script passes all checks
- ✅ Team trained on architecture

---

## 🎯 Next Steps

1. **Review Documentation:** Start with [PHASE_2.5_INDEX.md](./PHASE_2.5_INDEX.md)
2. **Deploy Phase 2.5:** Follow [TRAE_SOLO_EXECUTION.md](./TRAE_SOLO_EXECUTION.md)
3. **Validate Deployment:** Run validation script
4. **Schedule Transition:** Add cron job for Nov 17, 2025
5. **Monitor Operations:** Use [PHASE_2.5_QUICK_REFERENCE.md](./PHASE_2.5_QUICK_REFERENCE.md)

---

**Prepared By:** TRAE SOLO (GitHub Code Agent)  
**For:** Robert White (PUABO / Nexus COS Founder)  
**PF ID:** PF-HYBRID-FULLSTACK-2025.10.07-PHASE-2.5  
**Status:** PRODUCTION READY  
**Date:** October 7, 2025

---

*Welcome to Phase 2.5. Let's build something amazing! 🚀*
