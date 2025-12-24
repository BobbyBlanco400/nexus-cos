# 🎰 Nexus COS - Founder Access Keys

## 📊 Account Overview

This system provides **11 pre-loaded Founder Access Keys** for the Nexus COS Beta Launch:

### 👑 Super Admin (You)
- **Username**: `admin_nexus`
- **Password**: *(Your System Default)*
- **Balance**: ∞ Unlimited NC
- **Account Type**: Super Admin

### 🐋 VIP Whales (High Stakes)
- **Balance**: 1,000,000 NC each
- **Password**: `WelcomeToVegas_25` (all accounts)

1. **Username**: `vip_whale_01` | **Password**: `WelcomeToVegas_25`
2. **Username**: `vip_whale_02` | **Password**: `WelcomeToVegas_25`

### 🧪 Beta Founders (Standard)
- **Balance**: 50,000 NC each
- **Password**: `WelcomeToVegas_25` (all accounts)

3. **Username**: `beta_tester_01` | **Password**: `WelcomeToVegas_25`
4. **Username**: `beta_tester_02` | **Password**: `WelcomeToVegas_25`
5. **Username**: `beta_tester_03` | **Password**: `WelcomeToVegas_25`
6. **Username**: `beta_tester_04` | **Password**: `WelcomeToVegas_25`
7. **Username**: `beta_tester_05` | **Password**: `WelcomeToVegas_25`
8. **Username**: `beta_tester_06` | **Password**: `WelcomeToVegas_25`
9. **Username**: `beta_tester_07` | **Password**: `WelcomeToVegas_25`
10. **Username**: `beta_tester_08` | **Password**: `WelcomeToVegas_25`

---

## 🔑 Admin Account Details

### admin_nexus (YOUR ACCOUNT)
- **Balance**: UNLIMITED (999,999,999.99 NC displayed)
- **Password**: *(Your System Default - NOT WelcomeToVegas_25)*
- **Special Feature**: Balance never decreases
- **Account Type**: Super Admin
- **Use Case**: Testing, demonstrations, unlimited gameplay

**How It Works:**
- When you place bets, the transaction is logged but your balance stays unlimited
- You can play all games without worrying about balance
- Database trigger automatically resets balance to max if it ever drops

---

## 🐋 VIP Whale Accounts (High Stakes)

### vip_whale_01 & vip_whale_02
- **Balance**: 1,000,000 NC each
- **Password**: `WelcomeToVegas_25`
- **Account Type**: VIP
- **Use Case**: High-stakes testing, whale player simulation

**Gameplay Capacity:**
- **Nexus Poker** (100 NC/hand): 10,000 hands each
- **21X Blackjack** (100 NC/hand): 10,000 hands each
- **Nexus Slots** (50 NC/spin): 20,000 spins each
- **Crypto Spin** (50 NC/spin): 20,000 spins each

---

## 🧪 Beta Founder Accounts (Standard)

### beta_tester_01 through beta_tester_08
- **Balance**: 50,000 NC each (8 accounts)
- **Password**: `WelcomeToVegas_25` (same for all)
- **Account Type**: Beta Founder
- **Use Case**: Standard beta testing, normal player simulation

**Gameplay Capacity:**
- **Nexus Poker** (100 NC/hand): 500 hands each
- **21X Blackjack** (100 NC/hand): 500 hands each
- **Nexus Slots** (50 NC/spin): 1,000 spins each
- **Crypto Spin** (50 NC/spin): 1,000 spins each

---

## 💰 Pre-loaded Account Balances

| Account | Balance | Password | Type | Purpose |
|---------|---------|----------|------|---------|
| admin_nexus | ♾️ UNLIMITED | *(System Default)* | Super Admin | Your unlimited account |
| vip_whale_01 | 1,000,000 NC | WelcomeToVegas_25 | VIP | High stakes testing |
| vip_whale_02 | 1,000,000 NC | WelcomeToVegas_25 | VIP | High stakes testing |
| beta_tester_01 | 50,000 NC | WelcomeToVegas_25 | Beta Founder | Standard testing |
| beta_tester_02 | 50,000 NC | WelcomeToVegas_25 | Beta Founder | Standard testing |
| beta_tester_03 | 50,000 NC | WelcomeToVegas_25 | Beta Founder | Standard testing |
| beta_tester_04 | 50,000 NC | WelcomeToVegas_25 | Beta Founder | Standard testing |
| beta_tester_05 | 50,000 NC | WelcomeToVegas_25 | Beta Founder | Standard testing |
| beta_tester_06 | 50,000 NC | WelcomeToVegas_25 | Beta Founder | Standard testing |
| beta_tester_07 | 50,000 NC | WelcomeToVegas_25 | Beta Founder | Standard testing |
| beta_tester_08 | 50,000 NC | WelcomeToVegas_25 | Beta Founder | Standard testing |

**Total Pre-loaded Value**: 2,400,000 NC + UNLIMITED (admin_nexus)

**Note**: All accounts except `admin_nexus` use password `WelcomeToVegas_25`

---

## 🎮 Account Usage by Game

### Nexus Poker (100 NC per hand)
- ✅ **admin_nexus**: Unlimited play
- ✅ **VIP Whales** (vip_whale_01, vip_whale_02): 10,000 hands each
- ✅ **Beta Founders** (beta_tester_01-08): 500 hands each

### 21X Blackjack (100 NC per hand)
- ✅ **admin_nexus**: Unlimited play
- ✅ **VIP Whales** (vip_whale_01, vip_whale_02): 10,000 hands each
- ✅ **Beta Founders** (beta_tester_01-08): 500 hands each

### Nexus Slots (50 NC per spin)
- ✅ **admin_nexus**: Unlimited spins
- ✅ **VIP Whales** (vip_whale_01, vip_whale_02): 20,000 spins each
- ✅ **Beta Founders** (beta_tester_01-08): 1,000 spins each

### Crypto Spin (50 NC per spin)
- ✅ **admin_nexus**: Unlimited spins
- ✅ **VIP Whales** (vip_whale_01, vip_whale_02): 20,000 spins each
- ✅ **Beta Founders** (beta_tester_01-08): 1,000 spins each

---

## 🔧 Database Implementation

### Table Structure
All 11 accounts are stored in the `user_wallets` table:

```sql
CREATE TABLE user_wallets (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    balance DECIMAL(20, 2),
    is_unlimited BOOLEAN DEFAULT false,
    account_type VARCHAR(50),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

### Special Trigger for admin_nexus
A database trigger ensures `admin_nexus` always maintains unlimited balance:

```sql
CREATE TRIGGER unlimited_balance_trigger
    BEFORE UPDATE ON user_wallets
    FOR EACH ROW
    EXECUTE FUNCTION check_unlimited_balance();
```

---

## ✅ What The Fix Does

### For admin_nexus (Your Account)
1. ✅ Creates account with `is_unlimited = true`
2. ✅ Sets balance to 999,999,999.99 NC
3. ✅ Database trigger prevents balance from dropping
4. ✅ All transactions logged but balance stays unlimited
5. ✅ No restrictions on gameplay

### For 10 Founder Access Accounts
1. ✅ Creates each account with specified balance (1M NC for VIPs, 50K NC for Beta Founders)
2. ✅ Sets appropriate `account_type` (VIP for whales, Beta Founder for testers)
3. ✅ Stores bcrypt-hashed password `WelcomeToVegas_25` in users table
4. ✅ Logs initial balance transaction
5. ✅ Normal balance deduction applies during gameplay
6. ✅ Can be topped up manually if needed

---

## 🎯 After Running The Fix

### Check All Accounts
```bash
# Connect to database
psql -U nexus_user -d nexus_cos

# View all 11 accounts
SELECT 
    username,
    CASE 
        WHEN is_unlimited THEN 'UNLIMITED' 
        ELSE TO_CHAR(balance, '999,999,999.99') || ' NC'
    END as display_balance,
    account_type
FROM user_wallets
ORDER BY 
    CASE account_type
        WHEN 'admin' THEN 1
        WHEN 'vip' THEN 2
        WHEN 'beta_founder' THEN 3
    END;
```

**Expected Output:**
```
    username     | display_balance   | account_type  
-----------------+-------------------+---------------
 admin_nexus     | UNLIMITED         | admin
 vip_whale_01    | 1,000,000.00 NC   | vip
 vip_whale_02    | 1,000,000.00 NC   | vip
 beta_tester_01  |    50,000.00 NC   | beta_founder
 beta_tester_02  |    50,000.00 NC   | beta_founder
 beta_tester_03  |    50,000.00 NC   | beta_founder
 beta_tester_04  |    50,000.00 NC   | beta_founder
 beta_tester_05  |    50,000.00 NC   | beta_founder
 beta_tester_06  |    50,000.00 NC   | beta_founder
 beta_tester_07  |    50,000.00 NC   | beta_founder
 beta_tester_08  |    50,000.00 NC   | beta_founder
(11 rows)
```

---

## 🧪 Testing Each Account

### Test admin_nexus (Unlimited)
```bash
# Get balance
curl http://localhost:9503/api/balance/admin_nexus
# Expected: {"username":"admin_nexus","balance":999999999.99,"currency":"NC"}

# Play game
curl -X POST http://localhost:9503/api/games/nexus-poker/play \
  -H "Content-Type: application/json" \
  -d '{"username":"admin_nexus","betAmount":100}'
# Expected: Win or loss, but balance stays at 999999999.99

# Check balance again
curl http://localhost:9503/api/balance/admin_nexus
# Expected: Still 999999999.99 (unchanged)
```

### Test vip_whale_01 (1,000,000 NC)
```bash
# Get balance
curl http://localhost:9503/api/balance/vip_whale_01
# Expected: {"username":"vip_whale_01","balance":1000000,"currency":"NC"}

# Play game
curl -X POST http://localhost:9503/api/games/nexus-poker/play \
  -H "Content-Type: application/json" \
  -d '{"username":"vip_whale_01","betAmount":100}'
# Expected: Balance changes based on win/loss

# Check balance again
curl http://localhost:9503/api/balance/vip_whale_01
# Expected: 999900 (if lost) or 1000180 (if won with 1.8x payout)
```

### Test beta_tester_01 (50,000 NC)
```bash
# Get balance
curl http://localhost:9503/api/balance/beta_tester_01
# Expected: {"username":"beta_tester_01","balance":50000,"currency":"NC"}

# Play game
curl -X POST http://localhost:9503/api/games/nexus-poker/play \
  -H "Content-Type: application/json" \
  -d '{"username":"beta_tester_01","betAmount":100}'
# Expected: Balance changes based on win/loss

# Check balance again
curl http://localhost:9503/api/balance/beta_tester_01
# Expected: 49900 (if lost) or 50180 (if won with 1.8x payout)
```

### Test All Other Accounts
Same pattern for:
- vip_whale_02
- beta_tester_02 through beta_tester_08

---

## 📝 Manual Account Top-Up

If you need to add more NC to any Founder Access account:

```sql
-- Top up vip_whale_01 by 500,000 NC
UPDATE user_wallets 
SET balance = balance + 500000, 
    updated_at = NOW() 
WHERE username = 'vip_whale_01';

-- Log the transaction
INSERT INTO wallet_transactions 
  (username, amount, transaction_type, balance_after, description) 
VALUES 
  ('vip_whale_01', 500000, 'manual_topup', 
   (SELECT balance FROM user_wallets WHERE username = 'vip_whale_01'),
   'Manual top-up by admin');
```

---

## 🔒 Security Notes

### For Production:
1. **Change admin_nexus behavior**: Consider removing unlimited balance in production
2. **Protect Founder accounts**: Ensure Founder Access Keys are not accessible to end users
3. **Monitor transactions**: Set up alerts for unusual activity on Founder Access accounts
4. **Rate limiting**: Apply rate limits even to VIP accounts
5. **Password security**: Change `WelcomeToVegas_25` to unique passwords per account in production

---

## 📊 Transaction History

View all transactions for any account:

```sql
-- View admin_nexus transactions
SELECT 
    transaction_type,
    amount,
    balance_after,
    description,
    created_at
FROM wallet_transactions
WHERE username = 'admin_nexus'
ORDER BY created_at DESC
LIMIT 20;

-- View all account balances and transaction counts
SELECT 
    w.username,
    w.balance,
    w.is_unlimited,
    w.account_type,
    COUNT(t.id) as transaction_count,
    SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END) as total_deposits,
    SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END) as total_withdrawals
FROM user_wallets w
LEFT JOIN wallet_transactions t ON w.username = t.username
GROUP BY w.username, w.balance, w.is_unlimited, w.account_type
ORDER BY 
    CASE w.account_type
        WHEN 'admin' THEN 1
        WHEN 'vip' THEN 2
        WHEN 'beta_founder' THEN 3
    END;
```

---

## ✅ Summary

**This fix creates and manages 11 Founder Access Keys:**

1. **1 Super Admin Account** (`admin_nexus`) with UNLIMITED balance - THIS IS YOUR ACCOUNT
2. **2 VIP Whale Accounts** (`vip_whale_01`, `vip_whale_02`) with 1,000,000 NC each
3. **8 Beta Founder Accounts** (`beta_tester_01` through `beta_tester_08`) with 50,000 NC each

**Key Features:**
- ✅ admin_nexus has truly unlimited balance (never decreases)
- ✅ All 10 Founder Access accounts pre-loaded with specified NC amounts
- ✅ All accounts use password `WelcomeToVegas_25` (except admin_nexus)
- ✅ Full transaction logging for all accounts
- ✅ Database triggers ensure admin account stays unlimited
- ✅ Ready for immediate testing and gameplay
- ✅ All accounts work with Poker, Blackjack, Slots, Crypto Spin

**Total Accounts**: 11 (1 admin + 2 VIP + 8 Beta Founders)
**Total Pre-loaded NC**: 2,400,000 NC + UNLIMITED (admin)

---

**Created**: 2025-12-24  
**Version**: 2.0.0 - Founder Access Keys Edition  
**Status**: Ready for Implementation ✅
