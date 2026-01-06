# 🚀 Nexus COS Phase 2.5 - Quick Deploy

## One-Command Deployment for VPS

Deploy the entire Phase 2.5 architecture (OTT + Beta + V-Suite) with a single command:

```bash
cd /opt/nexus-cos && sudo ./DEPLOY_PHASE_2.5.sh
```

## What Gets Deployed

✅ **Apex Landing Page** → `n3xuscos.online`  
✅ **Beta Landing Page** → `beta.n3xuscos.online`  
✅ **V-Suite Dashboard** → `n3xuscos.online/v-suite/`  
✅ **Unified Nexus COS Branding** (#2563eb blue)  
✅ **Phase 2.5 Nginx Configuration**  
✅ **Automatic Validation**

## Success Indicators

When successful, you'll see:

```
╔════════════════════════════════════════════════════════════════╗
║        ✅  PHASE 2.5 DEPLOYMENT COMPLETE - SUCCESS  ✅         ║
║              ALL MANDATORY REQUIREMENTS MET                    ║
╚════════════════════════════════════════════════════════════════╝
```

## Prerequisites

- Repository at `/opt/nexus-cos`
- Nginx installed
- Docker running
- SSL certificates configured
- Run with `sudo`

## Documentation

📚 **Complete Guide**: `PHASE_2.5_DEPLOYMENT_GUIDE.md`  
📋 **PF Directive**: `PF_PHASE_2.5_OTT_INTEGRATION.md`  
🔍 **Manual Validation**: `./scripts/validate-phase-2.5-deployment.sh`

## Need Help?

1. Check the deployment guide: `PHASE_2.5_DEPLOYMENT_GUIDE.md`
2. Review validation output for specific errors
3. Check logs in `/opt/nexus-cos/logs/phase2.5/`

---

**Ready to Deploy?**

```bash
cd /opt/nexus-cos && sudo ./DEPLOY_PHASE_2.5.sh
```
