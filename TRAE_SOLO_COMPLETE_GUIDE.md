# 🎯 TRAE SOLO CODER - Complete Execution Guide

## 📋 Overview

This guide provides **complete instructions** for TRAE SOLO CODER to:
1. ✅ **Merge PRs individually** (173, 174, 175, 177)
2. ✅ **Fix database authentication** for all casino services
3. ✅ **Reactivate PWA** functionality

## 🚀 Quick Start (One Command Each)

### Step 1: Merge PRs Individually
```bash
cd /home/runner/work/nexus-cos/nexus-cos
./devops/execute_trae_solo_merge.sh --verify-only  # Check status first
./devops/execute_trae_solo_merge.sh --all          # Merge all PRs
```

### Step 2: Fix Database & PWA
```bash
./devops/fix_database_and_pwa.sh
```

### Step 3: Execute Manual Steps
Follow the output instructions to:
- Create database users
- Restart services
- Verify functionality

## 📖 Detailed Execution

### Phase 1: PR Merge Orchestration

**Purpose:** Safely merge PRs 173, 174, 175, and 177 individually to avoid conflicts

**Status:**
- PR 173: ✅ Already Merged (NexCoin wallet clarifications)
- PR 174: 🔄 Needs Merging (Expansion Layer)
- PR 175: ✅ Already Merged (Feature-flag overlay)
- PR 177: ✅ Already Merged (Global Launch)

**Execution:**
```bash
# Check all PR statuses
./devops/execute_trae_solo_merge.sh --verify-only

# Merge specific PR (e.g., PR 174)
./devops/execute_trae_solo_merge.sh --pr 174

# OR merge all PRs in sequence
./devops/execute_trae_solo_merge.sh --all
```

**Expected Output:**
```
╔══════════════════════════════════════════════════════════════╗
║          TRAE SOLO CODER - PR MERGE ORCHESTRATOR            ║
║    Safe, Individual PR Merging with Full Verification       ║
╚══════════════════════════════════════════════════════════════╝

[SUCCESS] Pre-flight checks passed
[SUCCESS] Repository state check complete
[WARNING] PR #173 is already merged
[INFO] Processing PR #174...
[SUCCESS] PR #174 is ready to merge
[SUCCESS] Test merge successful - no conflicts
[SUCCESS] Merge completed successfully
[SUCCESS] Changes pushed successfully
```

**Documentation:** See [TRAE_SOLO_CODER_MERGE_GUIDE.md](devops/TRAE_SOLO_CODER_MERGE_GUIDE.md)

---

### Phase 2: Database Authentication Fix

**Purpose:** Fix "password authentication failed for user 'nexus_user'" errors

**Issues Being Fixed:**
- ❌ Nexus Poker: Balance shows "Error NC", "Sit Down" fails
- ❌ Nexus Slots: Balance shows "Error NC", "SPIN" fails  
- ❌ 21X Blackjack: Balance shows "Error NC", "Deal Cards" fails
- ❌ Crypto Spin: Same authentication error
- ❌ NFT Marketplace: Database connection fails
- ❌ $NEXCOIN: Database connection fails

**Execution:**
```bash
./devops/fix_database_and_pwa.sh
```

**What This Does:**
1. Creates database users: `nexus_user` and `nexuscos`
2. Sets secure passwords: `nexus_secure_password_2025`
3. Updates `.env` file with correct credentials
4. Updates `ecosystem.config.js` PM2 configuration
5. Creates shared database module for casino services
6. Updates skill-games microservice with full DB integration
7. Adds balance tracking and transaction logging
8. Creates necessary database tables
9. Reactivates PWA with service worker and manifest

**After Script Completes:**

**Step 1: Create Database Users**
```bash
sudo -u postgres psql -f /tmp/create_nexus_db_user.sql
```

**Step 2: Apply Schema**
```bash
psql -U nexus_user -d nexus_cos -f database/schema.sql
```

**Step 3: Restart Services**
```bash
pm2 restart all
# OR
pm2 restart backend-api
pm2 restart skill-games-ms
```

**Step 4: Verify**
```bash
# Health check
curl http://localhost:9503/health

# Balance check (should return actual balance, not error)
curl http://localhost:9503/api/balance/admin_nexus
```

**Expected Result:**
```json
{
  "username": "admin_nexus",
  "balance": 1000,
  "currency": "NC"
}
```

**Documentation:** See [DATABASE_PWA_FIX_GUIDE.md](devops/DATABASE_PWA_FIX_GUIDE.md)

---

### Phase 3: PWA Reactivation

**Purpose:** Enable Progressive Web App functionality

**What Gets Created:**
- `frontend/public/manifest.json` - PWA manifest
- `frontend/public/service-worker.js` - Service worker
- `frontend/public/pwa-register.js` - Registration script

**Verification:**
1. Open your Nexus COS site in browser
2. Open Dev Tools (F12) → Console
3. Look for: `✅ PWA: Service Worker registered successfully`
4. Go to Application tab → Service Workers
5. Service worker should show as "activated"
6. Try "Add to Home Screen" in browser menu

**PWA Features:**
- ✅ Offline caching
- ✅ Background sync
- ✅ Push notifications (ready)
- ✅ Install to home screen
- ✅ Standalone app mode
- ✅ App shortcuts (Casino, Wallet)

---

## 🎮 Testing Casino Services

After completing all phases, test each service:

### Test Nexus Poker
1. Navigate to Nexus Poker in UI
2. Should see: `Balance: 1000 NC` (or your actual balance)
3. Click "Sit Down & Post Blind (100 NC)"
4. Should work without errors
5. Balance should update correctly

### Test Nexus Slots
1. Navigate to Nexus Slots
2. Should see: `Balance: 1000 NC`
3. Click "SPIN (50 NC)"
4. Should work without errors
5. Win/loss result displayed
6. Balance updates

### Test 21X Blackjack
1. Navigate to 21X Blackjack
2. Should see: `Balance: 1000 NC`
3. Click "Deal Cards (100 NC)"
4. Should work without errors
5. Cards dealt, balance updated

### Test Crypto Spin
1. Navigate to Crypto Spin
2. Should see: `Balance: 1000 NC`
3. Spin functionality works
4. Balance updates correctly

### Test NFT Marketplace
1. Navigate to NFT Marketplace
2. Should load without database errors
3. Can browse/view NFTs

### Test $NEXCOIN Service
1. Access $NEXCOIN endpoints
2. Should respond without database errors

---

## 📊 Success Criteria

### Merge Success ✅
- [ ] All PRs merged to main branch
- [ ] No merge conflicts remaining
- [ ] Clean git history maintained

### Database Fix Success ✅
- [ ] No "password authentication failed" errors
- [ ] All services show correct balances
- [ ] All game buttons work
- [ ] Transactions logged to database
- [ ] NFT Marketplace accessible
- [ ] $NEXCOIN service responds

### PWA Success ✅
- [ ] Service worker registered
- [ ] Manifest loads correctly
- [ ] "Add to Home Screen" available
- [ ] Offline functionality works
- [ ] App shortcuts present

---

## 🐛 Common Issues & Solutions

### Issue: PRs Won't Merge
**Symptom:** Merge conflicts detected

**Solution:**
```bash
# The script will show conflicted files
# Manually resolve conflicts:
git status  # See conflicted files
# Edit files, resolve conflicts
git add <resolved-files>
git commit
./devops/execute_trae_solo_merge.sh --pr 174  # Re-run
```

### Issue: Database Authentication Still Failing
**Symptom:** Still seeing "password authentication failed"

**Solution:**
```bash
# Verify user created
sudo -u postgres psql -c "\du" | grep nexus

# Manually set password
sudo -u postgres psql -c "ALTER USER nexus_user WITH PASSWORD 'nexus_secure_password_2025';"

# Update .env file
nano .env  # Check DATABASE_PASSWORD

# Restart services
pm2 restart all
```

### Issue: Balance Shows "Error NC"
**Symptom:** Balance not displaying correctly

**Solution:**
```bash
# Check if tables exist
psql -U nexus_user -d nexus_cos -c "\dt"

# Create user wallet manually
psql -U nexus_user -d nexus_cos -c "INSERT INTO user_wallets (username, balance) VALUES ('admin_nexus', 1000) ON CONFLICT DO NOTHING;"

# Check service logs
pm2 logs skill-games-ms

# Restart service
pm2 restart skill-games-ms
```

### Issue: PWA Not Registering
**Symptom:** Service worker not showing up

**Solution:**
```bash
# Verify files exist
ls -la frontend/public/service-worker.js
ls -la frontend/public/manifest.json

# Clear browser cache
# Dev Tools → Application → Clear Storage → Clear site data

# Reload page
# Check console for errors
```

---

## 📁 File Locations

### Merge Scripts
- `devops/trae_solo_merge_orchestrator.sh` - Main merge orchestration
- `devops/execute_trae_solo_merge.sh` - Wrapper script
- `devops/TRAE_SOLO_CODER_MERGE_GUIDE.md` - Detailed merge guide
- `devops/QUICK_REFERENCE.md` - Quick command reference

### Database & PWA Fix
- `devops/fix_database_and_pwa.sh` - Main fix script
- `devops/DATABASE_PWA_FIX_GUIDE.md` - Detailed fix guide
- `/tmp/create_nexus_db_user.sql` - DB user creation (generated)

### Casino Services
- `modules/casino-nexus/services/shared/database.js` - Shared DB module
- `modules/casino-nexus/services/skill-games-ms/index.js` - Updated service

### PWA Files
- `frontend/public/manifest.json` - PWA manifest
- `frontend/public/service-worker.js` - Service worker
- `frontend/public/pwa-register.js` - Registration script

### Logs
- `logs/merge_orchestration/merge_*.log` - Merge logs
- `logs/db_pwa_fix_*.log` - Fix script logs

---

## 🎯 Execution Checklist

### Before Starting
- [ ] Repository cloned and accessible
- [ ] Git configured (user.name, user.email)
- [ ] PostgreSQL installed and running
- [ ] Node.js and npm installed
- [ ] PM2 installed (`npm install -g pm2`)
- [ ] No uncommitted changes

### Phase 1: Merge PRs
- [ ] Run verify-only mode
- [ ] Review PR statuses
- [ ] Merge open PRs individually or all at once
- [ ] Verify merges successful
- [ ] Check logs for any issues

### Phase 2: Fix Database
- [ ] Run fix_database_and_pwa.sh script
- [ ] Create database users (sudo -u postgres psql)
- [ ] Apply database schema
- [ ] Restart PM2 services
- [ ] Verify health endpoints
- [ ] Test balance endpoints

### Phase 3: Verify PWA
- [ ] Check service worker registration
- [ ] Verify manifest loads
- [ ] Test "Add to Home Screen"
- [ ] Check offline functionality

### Phase 4: Test Casino Services
- [ ] Test Nexus Poker
- [ ] Test Nexus Slots
- [ ] Test 21X Blackjack
- [ ] Test Crypto Spin
- [ ] Test NFT Marketplace
- [ ] Test $NEXCOIN

### Final Verification
- [ ] No error messages in logs
- [ ] All balances display correctly
- [ ] All game actions work
- [ ] PWA installs properly
- [ ] Database transactions logged
- [ ] System stable and responsive

---

## 📞 Support

If you encounter issues:

1. **Check logs first:**
   - `tail -f logs/merge_orchestration/merge_*.log`
   - `tail -f logs/db_pwa_fix_*.log`
   - `pm2 logs skill-games-ms`

2. **Verify configuration:**
   - Check `.env` file for correct credentials
   - Check `ecosystem.config.js` for correct passwords
   - Verify PostgreSQL is running: `systemctl status postgresql`

3. **Review documentation:**
   - [TRAE_SOLO_CODER_MERGE_GUIDE.md](devops/TRAE_SOLO_CODER_MERGE_GUIDE.md)
   - [DATABASE_PWA_FIX_GUIDE.md](devops/DATABASE_PWA_FIX_GUIDE.md)
   - [QUICK_REFERENCE.md](devops/QUICK_REFERENCE.md)

4. **Common commands:**
   ```bash
   # Restart everything
   pm2 restart all
   
   # Check database connection
   psql -U nexus_user -d nexus_cos -c "SELECT 1;"
   
   # View service status
   pm2 status
   
   # Test endpoints
   curl http://localhost:9503/health
   ```

---

## ✅ Final Notes

- **All scripts are idempotent**: Can run multiple times safely
- **Logs are comprehensive**: Check logs if anything fails
- **Rollback available**: Git history preserved for rollback
- **Production ready**: Remember to change passwords for production!

**Estimated Time:**
- Merge PRs: 5-10 minutes
- Fix Database & PWA: 5-10 minutes  
- Manual Steps: 5 minutes
- Testing: 10-15 minutes
- **Total: ~30-40 minutes**

---

**Created:** 2025-12-24  
**Version:** 1.0.0  
**For:** TRAE SOLO CODER  
**Status:** Ready for Execution ✅
