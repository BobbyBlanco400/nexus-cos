# NEXUS MASTER ONE-SHOT: Quick Start Guide

## 🚀 Single-Command Deployment

Deploy the entire NEXUS COS platform with one SSH command:

```bash
ssh root@YOUR_VPS_IP "curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/NEXUS_MASTER_ONE_SHOT.sh | sudo bash -s"
```

**That's it!** 3-7 minutes later, you have a fully operational Tony Stark-level AI-fused control dashboard.

---

## ✨ What Gets Deployed

### Core Platform (12 Services)
- **N3XSTR3AM** - Front-facing platform entrypoint (port 3000)
- **Gateway API** - PUABO API Gateway (port 4000)
- **Casino-Nexus Lounge** - 9-Card interface (port 3060)
- **Casino-Nexus Core** - Gaming backend (port 9503)
- **Streaming Service** - Live/VOD/PPV (port 3070)
- **PUABO AI SDK** - AI services (port 3002)
- **PV Keys** - Key management (port 3041)
- **Auth Service** - Authentication (port 3001)
- **Admin Portal** - Administration (port 9504)
- **PostgreSQL** - Database (port 5432)
- **Redis** - Cache (port 6379)
- **Wallet Service** - NexCoin wallet interface

### Mini Tenants (20 Platforms)
1. ashantis-munch-mingle - Content Creator
2. nee-nee-kids - Educational Hub
3. sassie-lash - Beauty & Lifestyle
4. roro-gamers-lounge - Gaming Community
5. tyshawn-v-dance-studio - Virtual Dance
6. club-sadityy - Urban Nightlife
7. fayeloni-kreations - Creative Services
8. headwinas-comedy-club - Comedy
9. sheda-shay-butter-bar - Food & Beverage
10. idf-live - Live Events
11. clocking-t-with-ya-gurl-p - Fashion
12. gas-or-crash-live - Auto Racing
13. faith-through-fitness - Health
14. rise-sacramento-916 - Community
15. puaboverse - Metaverse Gateway
16. vscreen-hollywood - VR Hollywood
17. nexus-studio-ai - AI Studio
18. metatwin - Digital Twin
19. musicchain - Music Distribution
20. boom-boom-room - Social Entertainment

### Advanced Systems
- **NexusVision** - VR/AR streaming
- **HoloCore** - Holographic UI
- **StreaCore** - Multi-stream management
- **Nexus-Net** - 5G Hybrid connectivity
- **Nexus-Handshake 55-45-17** - Compliance system

---

## 🎮 Interactive Control Panel

After deployment, use the `nexus-control` command:

```bash
# Check status
nexus-control status

# View logs in real-time
nexus-control logs

# Health check
nexus-control health

# Restart all services
nexus-control restart

# Scale a service
nexus-control scale frontend 3

# Redeploy (pull latest changes)
nexus-control deploy
```

---

## 🌐 Production URLs

After deployment, access your platform at:

- **N3XSTR3AM**: https://n3xuscos.online
- **Casino-Nexus Lounge**: https://n3xuscos.online/puaboverse
- **Wallet**: https://n3xuscos.online/wallet
- **Live Streaming**: https://n3xuscos.online/live
- **VOD**: https://n3xuscos.online/vod
- **PPV**: https://n3xuscos.online/ppv
- **Gateway API**: https://n3xuscos.online/api

**Tenant URLs**: https://n3xuscos.online/{tenant-name}

---

## 🔑 Default Credentials

**⚠️ CHANGE IMMEDIATELY AFTER DEPLOYMENT**

### Database
- User: `nexus_user`
- Password: `nexus_secure_password_2025`
- Database: `nexus_cos`

### Founder Access Keys (11 Accounts)
- **admin_nexus** - UNLIMITED balance, Super Admin
- **vip_whale_01** - 1,000,000 NC, VIP Whale
- **vip_whale_02** - 1,000,000 NC, VIP Whale
- **beta_tester_01-08** - 50,000 NC each, Beta Founders

**Total Pre-loaded**: 2,400,000 NC + UNLIMITED

**Default Passwords**:
- Admin: `admin_nexus_2025`
- VIP/Beta: `WelcomeToVegas_25`

---

## 📊 Platform Stats

- **Total Services**: 32+ (12 core + 20 tenants)
- **Deployment Time**: 3-7 minutes
- **Health Check Window**: 120 seconds
- **Disk Required**: 12GB minimum
- **RAM Required**: 6GB minimum
- **SSL/TLS**: Let's Encrypt (auto-configured)
- **Protocols**: TLSv1.2, TLSv1.3
- **Nexus-Handshake Score**: 90%+ compliant
- **PWA Status**: Enabled (offline-first)
- **VR/AR Streaming**: Enabled (NexusVision)
- **5G Hybrid**: Enabled (Nexus-Net)

---

## 🛡️ Zero-Downtime Features

- Overlay-only configuration deployment
- No core service rebuilds
- No wallet resets or data loss
- No DNS/SSL changes required
- Instant rollback via feature flags (<30s)
- Atomic transaction operations
- Comprehensive error handling
- Auto-diagnostic collection on failure

---

## 🎯 9-Card Casino Grid

Access via: https://n3xuscos.online/puaboverse

1. **Slots & Skill Games** - Skill-based gameplay
2. **Table Games** - Blackjack, Poker, Roulette
3. **Live Dealers** - Real-time dealer games
4. **VR Casino** - NexusVision immersive experience
5. **High Roller Suite** - 5K NC minimum entry
6. **Progressive Jackpots** - Utility reward pools
7. **Tournament Hub** - Competitive events
8. **Loyalty Rewards** - Founder tier benefits
9. **Marketplace** - Asset preview (Phase 2)

---

## 📁 File Locations

- **Main Script**: `/var/www/nexus-cos/NEXUS_MASTER_ONE_SHOT.sh`
- **Deployment Logs**: `/var/log/nexus-cos/nexus-master-*.log`
- **Feature Flags**: `/var/www/nexus-cos/config/feature-flags.json`
- **Tenant Matrix**: `/var/www/nexus-cos/docs/TENANT_URL_MATRIX.md`
- **Nginx Config**: `/etc/nginx/sites-available/nexus-master.conf`
- **Control Panel**: `/usr/local/bin/nexus-control`

---

## 🔍 Troubleshooting

**Services not starting?**
```bash
nexus-control logs
docker-compose logs -f
```

**404 errors?**
```bash
sudo nginx -t
sudo systemctl reload nginx
```

**Health check failing?**
```bash
nexus-control health
curl https://n3xuscos.online/health
```

**Database issues?**
```bash
docker exec -it nexus-cos-postgres psql -U nexus_user -d nexus_cos
```

---

## 🎉 Success Criteria

After deployment completes, verify:

- ✅ All Docker containers running (`docker ps`)
- ✅ Nginx configuration valid (`nginx -t`)
- ✅ Frontend accessible (https://n3xuscos.online)
- ✅ Gateway API responding (https://n3xuscos.online/api)
- ✅ Casino-Nexus Lounge accessible (https://n3xuscos.online/puaboverse)
- ✅ Database connection working
- ✅ 11 Founder Access Keys created
- ✅ Nexus-Handshake score 90%+
- ✅ Health check passing
- ✅ PWA manifest and service worker installed

---

## 🚀 What Makes This "Tony Stark-Level"?

1. **Single Command Deployment** - Full stack in one SSH command
2. **AI-Fused Control Dashboard** - Interactive nexus-control panel
3. **Zero-Downtime Orchestration** - Overlay deployment, instant rollback
4. **Multi-Layer Architecture** - 32+ microservices, 20+ tenants
5. **VR/AR Integration** - NexusVision, HoloCore, StreaCore
6. **5G Hybrid Connectivity** - Nexus-Net infrastructure
7. **Comprehensive Monitoring** - Health checks, logging, alerts
8. **Production-Grade Security** - SSL/TLS, headers, compliance
9. **PWA Offline-First** - Works without internet
10. **Scalable & Extensible** - Easy to add services and tenants

---

**Version**: 2025.1.0-MASTER  
**Last Updated**: 2025-12-24  
**Status**: ✅ PRODUCTION READY

**Built with ❤️ for the NEXUS COS Platform**
