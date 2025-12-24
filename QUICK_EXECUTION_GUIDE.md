# 🚀 NEXUS COS - QUICK EXECUTION GUIDE

## For TRAE SOLO CODER

This guide provides the commands you need to execute the complete Nexus COS Platform with PF verification.

---

## 🎯 OPTION 1: Full Platform Launch (Recommended)

This single command launches the entire Nexus COS stack with built-in verification:

```bash
cd /home/runner/work/nexus-cos/nexus-cos
./NEXUS_FULL_LAUNCH.sh
```

**What it does:**
1. ✅ Runs PF verification (last 10 PFs)
2. ✅ Initializes database with Founder Access Keys
3. ✅ Launches all microservices
4. ✅ Deploys frontend & PWA
5. ✅ Configures Nginx reverse proxy
6. ✅ Activates monetization stack
7. ✅ Enables tenant features
8. ✅ Enforces admin policies
9. ✅ Runs health checks
10. ✅ Provides access information

**Output:** Beautiful ASCII art display + complete platform status

---

## 🔍 OPTION 2: PF Verification Only

If you just want to verify the platform without launching:

```bash
cd /home/runner/work/nexus-cos/nexus-cos
./devops/run_pf_verification.sh
```

**What it does:**
- 🔎 Loads last 10 executed PFs
- 🧠 Reconciles stack state
- 📄 Generates verification reports
- ✅ Shows what's present vs missing

**Reports generated:**
- `devops/pf_verification_report.json` - Detailed diff
- `devops/pf_apply_report.json` - Apply/skip summary
- `devops/pf_gap_fill_log.txt` - Human-readable log
- `devops/pf_noop_confirmation.txt` - If nothing needed

---

## 📋 OPTION 3: Step-by-Step Manual

If you want to run each component separately:

### Step 1: Verify PF Stack
```bash
./devops/run_pf_verification.sh
```

### Step 2: Setup Database
```bash
./devops/fix_database_and_pwa.sh
```

### Step 3: Load Founder Access Keys
```bash
psql -U nexus_user -d nexus_cos -f database/preload_casino_accounts.sql
```

### Step 4: Launch Services
```bash
pm2 start ecosystem.config.js
```

### Step 5: Verify Services
```bash
pm2 status
pm2 logs
```

---

## 🎰 Access the Platform

After launch, access these endpoints:

### Main Endpoints
```
🌐 Main Portal:    http://localhost:3000
🎰 Casino:         http://localhost:9503
📺 Streaming:      http://localhost:9501
👤 Admin Portal:   http://localhost:9504
```

### Founder Access Keys

**Super Admin:**
- Username: `admin_nexus`
- Password: *(Your System Default)*
- Balance: ∞ Unlimited NC

**VIP Whales (1,000,000 NC each):**
- Username: `vip_whale_01` | Password: `WelcomeToVegas_25`
- Username: `vip_whale_02` | Password: `WelcomeToVegas_25`

**Beta Founders (50,000 NC each):**
- Username: `beta_tester_01` to `beta_tester_08`
- Password: `WelcomeToVegas_25` (all 8 accounts)

See `FOUNDER_ACCESS_KEYS.md` for complete list.

---

## 📊 View Reports

### After verification runs:

**JSON Reports (detailed):**
```bash
cat devops/pf_verification_report.json | jq .
cat devops/pf_apply_report.json | jq .
```

**Text Logs (human-readable):**
```bash
cat devops/pf_gap_fill_log.txt
cat devops/pf_noop_confirmation.txt  # If nothing needed
```

---

## 🔧 Troubleshooting

### If Services Don't Start
```bash
# Check service status
pm2 status

# View logs
pm2 logs

# Restart specific service
pm2 restart skill-games-ms
```

### If Database Connection Fails
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Verify database exists
psql -U nexus_user -l

# Reconnect
psql -U nexus_user -d nexus_cos
```

### If PF Verification Shows Gaps
```bash
# Review what's missing
cat devops/pf_verification_report.json | jq '.newly_applied'

# The system will log what needs attention
# Check the gap fill log for details
cat devops/pf_gap_fill_log.txt
```

---

## 📚 Documentation

Refer to these docs for more details:

- `README_TRAE_SOLO_FIX.md` - Main fix documentation
- `EXECUTION_SUMMARY.md` - Quick reference
- `PF_VERIFICATION_SYSTEM_README.md` - PF verification details
- `FOUNDER_ACCESS_KEYS.md` - Access keys list
- `devops/TRAE_SOLO_CODER_MERGE_GUIDE.md` - PR merge guide
- `devops/DATABASE_PWA_FIX_GUIDE.md` - Database troubleshooting

---

## ✅ Success Checklist

After running, verify these:

- [ ] All services running (`pm2 status`)
- [ ] Database connected (Founder Keys loaded)
- [ ] PF verification passed (no regressions)
- [ ] Frontend accessible (http://localhost:3000)
- [ ] Casino working (http://localhost:9503)
- [ ] Can login with Founder Access Keys
- [ ] NexCoin balances showing correctly

---

## 🎯 The ONE Command You Need

**For complete platform launch with verification:**

```bash
./NEXUS_FULL_LAUNCH.sh
```

That's it! This single command:
- ✅ Verifies all PFs
- ✅ Launches entire platform
- ✅ Shows you access information
- ✅ Provides next steps

---

**Version**: 1.0.0  
**Date**: 2025-12-24  
**Status**: Beta Launched ✅  
**Mode**: Production Ready
