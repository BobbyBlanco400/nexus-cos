# 🎰 Nexus COS - Database & PWA Fix Guide

## 🚨 Problem Summary

**Issues Fixed:**
1. ❌ **Database Authentication Failures**: "password authentication failed for user 'nexus_user'"
2. ❌ **Casino Services Not Working**: Poker, Slots, Blackjack, Crypto Spin showing "Error NC" balance
3. ❌ **Game Actions Failing**: All "Sit Down", "SPIN", "Deal Cards" buttons failing with DB errors
4. ❌ **NFT Marketplace Not Working**: Database authentication errors
5. ❌ **$NEXCOIN Service Not Working**: Database authentication errors
6. ❌ **PWA Deactivated**: Progressive Web App functionality disabled

## ✅ Solution Overview

This fix addresses all issues by:
- Creating/updating correct database users (`nexus_user` and `nexuscos`)
- Setting secure passwords for all database connections
- Integrating database connectivity into casino services
- Adding balance tracking and game transaction logic
- Reactivating PWA with service worker and manifest
- Ensuring all services can access wallet data

## 🚀 Quick Fix (One Command)

```bash
cd /home/runner/work/nexus-cos/nexus-cos
./devops/fix_database_and_pwa.sh
```

Then follow the manual steps displayed at the end.

## 📋 What The Script Does

### 1. Database User Setup
Creates SQL script to:
- Create `nexus_user` with password `nexus_secure_password_2025`
- Create `nexuscos` user with same password
- Create databases: `nexus_cos` and `nexuscos_db`
- Grant all necessary privileges
- Make users superusers (development only)

### 2. Environment Configuration
Updates `.env` file with:
```bash
DATABASE_USER=nexus_user
DATABASE_PASSWORD=nexus_secure_password_2025
DB_USER=nexuscos
DB_PASSWORD=nexus_secure_password_2025
```

### 3. PM2 Ecosystem Update
Updates `ecosystem.config.js`:
- Changes all `DB_PASSWORD: 'password'` to `DB_PASSWORD: 'nexus_secure_password_2025'`
- Ensures consistent credentials across all services

### 4. Casino Services Database Integration
Creates:
- **`modules/casino-nexus/services/shared/database.js`**: Shared database module
  - PostgreSQL connection pool
  - `getUserBalance(username)` - Fetch user's NexCoin balance
  - `updateUserBalance(username, amount, type)` - Update balance and log transaction
  - `initializeTables()` - Create necessary database tables
  
- **Database Tables Created:**
  - `user_wallets` - Stores user balances
  - `wallet_transactions` - Transaction history
  - `game_sessions` - Game play records

### 5. Updated Skill Games Service
Completely rewrites `skill-games-ms/index.js`:
- ✅ Database integration
- ✅ `/api/balance/:username` - Get user balance
- ✅ `/api/games/:gameId/play` - Play any game
- ✅ `/api/poker/join` - Join poker table
- ✅ `/api/blackjack/deal` - Deal blackjack cards
- ✅ `/api/slots/spin` - Spin slots
- ✅ Balance checking before bets
- ✅ Automatic balance updates
- ✅ Transaction logging

### 6. PWA Reactivation
Creates/Updates:
- **`frontend/public/manifest.json`**: PWA manifest
  - App name, icons, theme colors
  - Shortcuts to Casino and Wallet
  - Standalone display mode
  
- **`frontend/public/service-worker.js`**: Service worker
  - Offline caching
  - Background sync
  - Push notifications
  - Update management
  
- **`frontend/public/pwa-register.js`**: Registration script
  - Auto-registers service worker
  - Handles install prompts
  - Update notifications

## 🔧 Manual Steps Required

After running the script, execute these commands:

### Step 1: Create Database Users
```bash
sudo -u postgres psql -f /tmp/create_nexus_db_user.sql
```

**Expected Output:**
```
NOTICE: Created user: nexus_user
NOTICE: Created user: nexuscos
CREATE DATABASE
CREATE DATABASE
GRANT
GRANT
GRANT
GRANT
ALTER ROLE
ALTER ROLE
```

### Step 2: Apply Database Schema
```bash
psql -U nexus_user -d nexus_cos -f database/schema.sql
```

### Step 3: Restart Services
```bash
# Restart all services
pm2 restart all

# OR restart specific services
pm2 restart backend-api
pm2 restart skill-games-ms

# Check status
pm2 status
pm2 logs skill-games-ms --lines 50
```

### Step 4: Verify Database Connection
```bash
# Test database login
psql -U nexus_user -d nexus_cos -c "SELECT current_database(), current_user;"

# Should output:
#  current_database | current_user
# ------------------+--------------
#  nexus_cos        | nexus_user
```

### Step 5: Test API Endpoints
```bash
# Health check
curl http://localhost:9503/health

# Get user balance
curl http://localhost:9503/api/balance/admin_nexus

# List games
curl http://localhost:9503/api/games

# Test play (requires body)
curl -X POST http://localhost:9503/api/games/nexus-poker/play \
  -H "Content-Type: application/json" \
  -d '{"username":"admin_nexus","betAmount":100}'
```

### Step 6: Test Frontend

1. **Test Casino Games:**
   - Open browser to your Nexus COS URL
   - Navigate to Nexus Poker
   - Should see: `Balance: 1000 NC` (or current balance)
   - Click "Sit Down & Post Blind (100 NC)"
   - Should work without password errors

2. **Test PWA:**
   - Open browser dev tools (F12)
   - Go to Console tab
   - Look for: `✅ PWA: Service Worker registered successfully`
   - Go to Application tab → Service Workers
   - Should see service worker active
   - Try "Add to Home Screen" in browser menu

## 🐛 Troubleshooting

### Issue: Database user already exists
```
ERROR: role "nexus_user" already exists
```

**Fix:** Update password instead of creating:
```bash
sudo -u postgres psql -c "ALTER USER nexus_user WITH PASSWORD 'nexus_secure_password_2025';"
sudo -u postgres psql -c "ALTER USER nexuscos WITH PASSWORD 'nexus_secure_password_2025';"
```

### Issue: Permission denied for database
```
ERROR: permission denied for database nexus_cos
```

**Fix:**
```bash
sudo -u postgres psql << EOF
GRANT ALL PRIVILEGES ON DATABASE nexus_cos TO nexus_user;
GRANT ALL PRIVILEGES ON DATABASE nexuscos_db TO nexuscos;
ALTER USER nexus_user WITH SUPERUSER;
ALTER USER nexuscos WITH SUPERUSER;
EOF
```

### Issue: Table already exists
```
ERROR: relation "user_wallets" already exists
```

**Solution:** This is OK - the `CREATE TABLE IF NOT EXISTS` will skip it. If you need to reset:
```bash
psql -U nexus_user -d nexus_cos -c "DROP TABLE IF EXISTS wallet_transactions CASCADE;"
psql -U nexus_user -d nexus_cos -c "DROP TABLE IF EXISTS user_wallets CASCADE;"
```

Then restart the skill-games-ms service to recreate tables.

### Issue: Balance shows "Error NC"
**Causes:**
1. Database not accessible
2. User not in `user_wallets` table
3. Service not restarted

**Fix:**
```bash
# Check if tables exist
psql -U nexus_user -d nexus_cos -c "\dt"

# Manually insert user if needed
psql -U nexus_user -d nexus_cos -c "INSERT INTO user_wallets (username, balance) VALUES ('admin_nexus', 1000) ON CONFLICT (username) DO NOTHING;"

# Restart service
pm2 restart skill-games-ms
```

### Issue: PWA not registering
**Causes:**
1. Service worker file not found
2. Not served over HTTPS (required for production)
3. Browser cache

**Fix:**
```bash
# Check if files exist
ls -la frontend/public/service-worker.js
ls -la frontend/public/manifest.json

# Clear browser cache
# Open Dev Tools → Application → Clear Storage → Clear site data

# For production, ensure HTTPS is configured
```

### Issue: PM2 service not starting
```bash
# Check logs
pm2 logs skill-games-ms --lines 100

# Common issues:
# 1. Missing dependencies
cd modules/casino-nexus/services/skill-games-ms
npm install

# 2. Port already in use
lsof -i :9503
# Kill the process or change port in service
```

## 📊 Database Schema

### user_wallets Table
```sql
CREATE TABLE user_wallets (
  id SERIAL PRIMARY KEY,
  username VARCHAR(255) UNIQUE NOT NULL,
  balance DECIMAL(20, 2) DEFAULT 1000.00,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### wallet_transactions Table
```sql
CREATE TABLE wallet_transactions (
  id SERIAL PRIMARY KEY,
  username VARCHAR(255) NOT NULL,
  amount DECIMAL(20, 2) NOT NULL,
  transaction_type VARCHAR(50) NOT NULL,
  balance_after DECIMAL(20, 2),
  created_at TIMESTAMP DEFAULT NOW()
);
```

### game_sessions Table
```sql
CREATE TABLE game_sessions (
  id SERIAL PRIMARY KEY,
  username VARCHAR(255) NOT NULL,
  game_type VARCHAR(100) NOT NULL,
  bet_amount DECIMAL(20, 2),
  win_amount DECIMAL(20, 2),
  result VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW()
);
```

## 🎮 Testing Checklist

- [ ] Database users created successfully
- [ ] Can connect to database with new credentials
- [ ] Casino service health check returns OK
- [ ] Balance API returns valid balance (not "Error NC")
- [ ] Poker "Sit Down" button works
- [ ] Blackjack "Deal Cards" button works
- [ ] Slots "SPIN" button works
- [ ] Crypto Spin works
- [ ] NFT Marketplace loads
- [ ] $NEXCOIN service responds
- [ ] PWA service worker registers
- [ ] PWA manifest loads in browser
- [ ] "Add to Home Screen" option appears
- [ ] Offline functionality works

## 🔒 Security Notes

**IMPORTANT for Production:**

1. **Change Database Passwords:**
   ```bash
   # Use strong, unique passwords
   ALTER USER nexus_user WITH PASSWORD 'your-strong-password-here';
   ALTER USER nexuscos WITH PASSWORD 'your-strong-password-here';
   ```

2. **Update .env file** with production passwords

3. **Remove SUPERUSER** privileges:
   ```bash
   ALTER USER nexus_user WITH NOSUPERUSER;
   ALTER USER nexuscos WITH NOSUPERUSER;
   ```

4. **Use SSL for database connections** in production

5. **Enable HTTPS** for PWA to work properly

## 📝 Files Modified/Created

### Modified:
- `.env` - Database credentials
- `ecosystem.config.js` - PM2 database passwords
- `modules/casino-nexus/services/skill-games-ms/index.js` - Complete rewrite
- `modules/casino-nexus/services/skill-games-ms/package.json` - Added pg dependency

### Created:
- `modules/casino-nexus/services/shared/database.js` - Shared DB module
- `modules/casino-nexus/services/shared/package.json` - Shared module config
- `frontend/public/manifest.json` - PWA manifest
- `frontend/public/service-worker.js` - Service worker
- `frontend/public/pwa-register.js` - PWA registration
- `/tmp/create_nexus_db_user.sql` - DB user creation script
- `devops/fix_database_and_pwa.sh` - This fix script
- `devops/DATABASE_PWA_FIX_GUIDE.md` - This guide

## 📞 Support

If issues persist:

1. Check logs: `tail -f logs/db_pwa_fix_*.log`
2. Check PM2 logs: `pm2 logs skill-games-ms`
3. Check database: `psql -U nexus_user -d nexus_cos`
4. Verify .env file has correct credentials
5. Ensure PostgreSQL is running: `systemctl status postgresql`

## ✅ Success Indicators

When everything is working:

- ✅ No "password authentication failed" errors
- ✅ Balance shows as "1000 NC" or actual balance
- ✅ All game buttons work without errors
- ✅ PWA installs on mobile devices
- ✅ Service worker active in browser
- ✅ Database transactions logged properly
- ✅ NFT Marketplace loads
- ✅ $NEXCOIN service responds

---

**Last Updated:** 2025-12-24  
**Version:** 1.0.0  
**Author:** GitHub Copilot for Nexus COS
