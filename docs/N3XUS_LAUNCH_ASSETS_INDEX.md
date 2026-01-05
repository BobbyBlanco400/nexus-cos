# N3XUS COS — LAUNCH ASSETS INDEX

**Purpose**: Comprehensive index of all launch-related assets and documentation  
**Version**: v2.5.0-RC1  
**Last Updated**: January 5, 2026

---

## 📄 DOCUMENTATION

### Launch Announcements
- **[N3XUS_MAINNET_LAUNCH_ANNOUNCEMENT.md](./N3XUS_MAINNET_LAUNCH_ANNOUNCEMENT.md)**  
  Official mainnet launch announcement document

- **[N3XUS_FOUNDING_RESIDENTS_PRESS_KIT.md](./N3XUS_FOUNDING_RESIDENTS_PRESS_KIT.md)**  
  Complete press kit with media assets, quotes, and contact information

### Marketing & Media
- **[N3XUS_KINETIC_TEXT_SEQUENCE.md](./N3XUS_KINETIC_TEXT_SEQUENCE.md)**  
  Full kinetic typography script (45s, 15s, 7s versions)

- **[N3XUS_KINETIC_STORYBOARD.md](./N3XUS_KINETIC_STORYBOARD.md)**  
  11-sequence motion storyboard with timing and production notes

- **[N3XUS_KINETIC_VO_SCRIPT.md](./N3XUS_KINETIC_VO_SCRIPT.md)**  
  Voiceover script with timing cues and pronunciation guide

- **[N3XUS_SOCIAL_ROLLOUT_PLAN.md](./N3XUS_SOCIAL_ROLLOUT_PLAN.md)**  
  24-hour, 6-phase social media launch campaign

### Verification & Checklists
- **[N3XUS_MAINNET_VERIFICATION_CHECKLIST.md](./N3XUS_MAINNET_VERIFICATION_CHECKLIST.md)**  
  Complete verification checklist for mainnet readiness

- **[NEXUS_COS_STATUS_DASHBOARD.md](../NEXUS_COS_STATUS_DASHBOARD.md)**  
  System status dashboard with READY_FOR_MAINNET indicator

---

## 🎨 UI SURFACES

### Frontend Routes
- **`/` (Homepage)**  
  Location: `/frontend/src/App.tsx`  
  Main landing page with hero CTA to Founding Residents

- **`/residents` (Founding Residents Showcase)**  
  Location: `/frontend/src/components/FoundingResidents.tsx`  
  Location: `/frontend/src/components/FoundingResidents.css`  
  Cinematic showcase of all 13 founding resident platforms

- **`/cps` (CPS Dashboard)**  
  Location: `/frontend/src/cps/CpsDashboardPage.tsx`  
  Location: `/frontend/src/cps/TenantTable.tsx`  
  Location: `/frontend/src/cps/CreatorOnboardingForm.tsx`  
  Creator Platform Service control panel and onboarding

- **`/dashboard` (System Dashboard)**  
  Location: `/frontend/src/pages/Dashboard.tsx`  
  Platform-wide health and service monitoring

- **`/desktop` (Virtual Desktop)**  
  Location: `/frontend/src/pages/Desktop.tsx`  
  Module-based application environment

### Routing Configuration
- **Router Setup**  
  Location: `/frontend/src/router.tsx`  
  React Router configuration with all routes

---

## 🔧 INFRASTRUCTURE SCRIPTS

### CPS Deployment Scripts
- **`deploy-tenant.sh`**  
  Location: `/infra/cps/scripts/deploy-tenant.sh`  
  Single-tenant deployment script

- **`deploy-all-tenants.sh`**  
  Location: `/infra/cps/scripts/deploy-all-tenants.sh`  
  Mass deployment for all 13 founding residents

### Verification Scripts
- **`verify-runtime.sh`**  
  Location: `/infra/verification/verify-runtime.sh`  
  Unix/Linux runtime verification (Handshake 55-45-17)

- **`verify-runtime.ps1`**  
  Location: `/infra/verification/verify-runtime.ps1`  
  Windows PowerShell runtime verification

---

## 📦 TENANT REGISTRY

### Canonical Tenant List
- **`tenants.json`**  
  Location: `/runtime/tenants/tenants.json`  
  Canonical registry of all 13 founding residents with metadata

### Tenant Data Structure
```json
{
  "id": 1,
  "name": "Club Saditty",
  "slug": "club-saditty",
  "domain": "clubsaditty.nexuscos.online",
  "category": "Entertainment & Lifestyle",
  "status": "live",
  "deployed": "2026-01-05T00:00:00Z"
}
```

---

## 🏗️ CREATOR STACK TEMPLATE

### Template Directory
- **Location**: `/templates/creator-stack/`

### Template Structure
```
/templates/creator-stack/
├── frontend/          # Frontend template
├── services/          # Services template
├── verification/      # Verification scripts
├── telemetry/         # Telemetry configuration
├── stack.json         # Stack configuration
└── launch.json        # Launch metadata
```

### Key Files
- **`stack.json`**: Infrastructure stack definition
- **`launch.json`**: Deployment metadata and configuration
- **`frontend/`**: React/TypeScript frontend template
- **`services/`**: Microservices templates
- **`verification/`**: Build verification scripts
- **`telemetry/`**: Monitoring and logging configuration

---

## 📊 STATUS & MONITORING

### Status Dashboard
- **`NEXUS_COS_STATUS_DASHBOARD.md`**  
  Location: `/NEXUS_COS_STATUS_DASHBOARD.md`  
  Current status: **READY_FOR_MAINNET**  
  Version: v2.5.0-RC1  
  Residency: v1.0.0

### Health Endpoints
- `/health/gateway` — Gateway health check
- `/api/health` — API services health check
- `/cps/status` — CPS engine status

---

## 🎥 VIDEO ASSETS (TO BE RENDERED)

### Kinetic Text Videos
- **45-second Full Version**  
  Format: 16:9, 9:16, 1:1  
  Resolution: 1920x1080 (HD) or 3840x2160 (4K)  
  Source: N3XUS_KINETIC_TEXT_SEQUENCE.md

- **15-second Cut**  
  Format: 16:9, 9:16, 1:1  
  For: Twitter/X, Instagram Feed  
  Source: N3XUS_KINETIC_TEXT_SEQUENCE.md

- **7-second Teaser**  
  Format: 16:9, 9:16, 1:1  
  For: Instagram Stories, TikTok  
  Source: N3XUS_KINETIC_TEXT_SEQUENCE.md

---

## 🖼️ GRAPHIC ASSETS (TO BE DESIGNED)

### Brand Assets
- N3XUS COS Logo (PNG, SVG, high-res)
- Founding Residents Badge/Seal
- Platform Status Badges (LIVE, ACTIVE, STREAMING)

### Social Media Assets
- Twitter/X Header (1500x500)
- Instagram Profile Image (1080x1080)
- LinkedIn Banner (1584x396)
- Facebook Cover (1200x630)

### Resident Cards
- 13 individual platform cards
- Category-specific icons
- Status indicators

---

## 📱 SOCIAL MEDIA PROFILES

### Platform Accounts
- Twitter/X: [@N3XUSCOS]
- Instagram: [@nexuscos]
- LinkedIn: [N3XUS COS Company Page]
- Facebook: [N3XUS COS]
- TikTok: [@nexuscos]
- YouTube: [N3XUS COS]

---

## 🔗 PUBLIC ACCESS POINTS

### Live URLs
- **Main Portal**: https://nexuscos.online
- **Founding Residents**: https://nexuscos.online/residents
- **CPS Dashboard**: https://nexuscos.online/cps
- **System Dashboard**: https://nexuscos.online/dashboard
- **Virtual Desktop**: https://nexuscos.online/desktop

---

## 📋 FOUNDING RESIDENTS

### Complete List (13 Platforms)

1. **Club Saditty** — Entertainment & Lifestyle
2. **Faith Through Fitness** — Health & Wellness
3. **Ashanti's Munch & Mingle** — Food & Community
4. **Ro Ro's Gamers Lounge** — Gaming & Esports
5. **IDH-Live!** — Talk & Discussion
6. **Clocking T. Wit Ya Gurl P** — Urban Entertainment
7. **Tyshawn's V-Dance Studio** — Dance & Performing Arts
8. **Fayeloni-Kreations** — Creative Arts
9. **Sassie Lashes** — Beauty & Fashion
10. **Nee Nee & Kids** — Family & Children
11. **Headwina's Comedy Club** — Comedy & Entertainment
12. **Rise Sacramento 916** — Local Community
13. **Sheda Shay's Butter Bar** — Food & Lifestyle

---

## 🔐 TECHNICAL SPECIFICATIONS

### Version Information
- **Platform Version**: v2.5.0-RC1
- **Residency Cohort**: v1.0.0
- **Governance Protocol**: 55-45-17
- **Runtime Status**: READY_FOR_MAINNET

### System Components
- **Static-Core**: Deterministic runtime ✅
- **Service-Brain**: Microservices orchestration ✅
- **CPS Engine**: Creative Platform Service ✅
- **Residency v1.0.0**: First cohort deployed ✅

### Verification
- **Handshake**: 55-45-17 (PASSED)
- **Build Integrity**: VERIFIED
- **Deployment Status**: READY

---

## 📞 CONTACT & SUPPORT

### Press & Media
- Press Kit: `/docs/N3XUS_FOUNDING_RESIDENTS_PRESS_KIT.md`
- Media Contact: [Available in press kit]

### Creator Onboarding
- Access: https://nexuscos.online/cps
- Form: Creator Onboarding Form

### Technical Support
- Documentation: nexuscos.online/docs
- Status Page: nexuscos.online/status

---

## 🚀 DEPLOYMENT COMMANDS

### Single Tenant Deployment
```bash
./infra/cps/scripts/deploy-tenant.sh "Tenant Name" "tenant-slug" "domain.com"
```

### Mass Deployment (All 13)
```bash
./infra/cps/scripts/deploy-all-tenants.sh
```

### Runtime Verification
```bash
# Unix/Linux/macOS
./infra/verification/verify-runtime.sh

# Windows PowerShell
.\infra\verification\verify-runtime.ps1
```

---

## 📚 ADDITIONAL RESOURCES

### Documentation
- API Documentation: `/docs/API_USAGE_GUIDE.md`
- Governance Charter: `/GOVERNANCE_CHARTER_55_45_17.md`
- System Architecture: `/NEXUS_COS_ARCHITECTURE_DIAGRAM.md`

### Compliance & Legal
- Terms of Service: nexuscos.online/terms
- Privacy Policy: nexuscos.online/privacy
- Governance Protocol: 55-45-17 (active)

---

## ✅ LAUNCH READINESS CHECKLIST

- [x] All documentation files created
- [x] All UI routes implemented
- [x] All scripts created and tested
- [x] Tenant registry populated
- [x] Status dashboard updated
- [x] Founding Residents showcase live
- [x] CPS dashboard operational
- [x] Verification scripts functional
- [x] Press kit finalized
- [x] Social rollout plan ready

---

## 📅 LAUNCH TIMELINE

- **T-24 hours**: Final verification
- **T-12 hours**: Pre-launch checks
- **T-1 hour**: System warm-up
- **T-0 (Launch)**: Mainnet activation
- **T+2 hours**: Official announcement
- **T+6 hours**: Resident spotlight
- **T+12 hours**: Feature deep dive
- **T+24 hours**: Lock & sustain

---

**MAINNET CANON SEALED**  
**N3XUS COS v2.5.0-RC1**  
**🔒 Handshake: 55-45-17**

---

*This index provides complete access to all N3XUS COS mainnet launch assets.*
