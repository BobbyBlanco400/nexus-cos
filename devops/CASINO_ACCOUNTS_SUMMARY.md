# 🎰 Nexus COS - Casino Accounts Summary

## 📊 Account Overview

This fix applies to **11 pre-loaded casino accounts** in the Nexus COS system:

### 1 Admin Account (Unlimited Balance)
- **`admin_nexus`** - YOUR account with UNLIMITED NexCoin

### 10 Pre-loaded Casino Accounts (Fixed Balances)
1. **`casino_vip_01`** - 100,000 NC (VIP High Roller)
2. **`casino_vip_02`** - 75,000 NC (VIP High Roller)
3. **`casino_vip_03`** - 50,000 NC (VIP High Roller)
4. **`casino_pro_01`** - 25,000 NC (Professional Player)
5. **`casino_pro_02`** - 20,000 NC (Professional Player)
6. **`casino_player_01`** - 10,000 NC (Regular Player)
7. **`casino_player_02`** - 10,000 NC (Regular Player)
8. **`casino_player_03`** - 5,000 NC (Regular Player)
9. **`casino_test_01`** - 5,000 NC (Test Account)
10. **`casino_demo`** - 1,000 NC (Demo Account)

---

## 🔑 Admin Account Details

### admin_nexus (YOUR ACCOUNT)
- **Balance**: UNLIMITED (999,999,999.99 NC displayed)
- **Special Feature**: Balance never decreases
- **Account Type**: Admin
- **Use Case**: Testing, demonstrations, unlimited gameplay

**How It Works:**
- When you place bets, the transaction is logged but your balance stays unlimited
- You can play all games without worrying about balance
- Database trigger automatically resets balance to max if it ever drops

---

## 💰 Pre-loaded Account Balances

| Account | Balance | Type | Purpose |
|---------|---------|------|---------|
| admin_nexus | ♾️ UNLIMITED | Admin | Your unlimited account |
| casino_vip_01 | 100,000 NC | VIP | High roller testing |
| casino_vip_02 | 75,000 NC | VIP | High roller testing |
| casino_vip_03 | 50,000 NC | VIP | High roller testing |
| casino_pro_01 | 25,000 NC | Professional | Pro player testing |
| casino_pro_02 | 20,000 NC | Professional | Pro player testing |
| casino_player_01 | 10,000 NC | Regular | Standard player testing |
| casino_player_02 | 10,000 NC | Regular | Standard player testing |
| casino_player_03 | 5,000 NC | Regular | New player testing |
| casino_test_01 | 5,000 NC | Test | QA/testing purposes |
| casino_demo | 1,000 NC | Demo | Demo/trial purposes |

**Total Pre-loaded Value**: 315,000 NC + UNLIMITED (admin_nexus)

---

## 🎮 Account Usage by Game

### Nexus Poker (100 NC per hand)
- ✅ **admin_nexus**: Unlimited play
- ✅ **VIP accounts**: 500-1000 hands each
- ✅ **Pro accounts**: 200-250 hands each
- ✅ **Regular accounts**: 50-100 hands each
- ✅ **Test/Demo**: 10-50 hands each

### 21X Blackjack (100 NC per hand)
- ✅ **admin_nexus**: Unlimited play
- ✅ **VIP accounts**: 500-1000 hands each
- ✅ **Pro accounts**: 200-250 hands each
- ✅ **Regular accounts**: 50-100 hands each
- ✅ **Test/Demo**: 10-50 hands each

### Nexus Slots (50 NC per spin)
- ✅ **admin_nexus**: Unlimited spins
- ✅ **VIP accounts**: 1000-2000 spins each
- ✅ **Pro accounts**: 400-500 spins each
- ✅ **Regular accounts**: 100-200 spins each
- ✅ **Test/Demo**: 20-100 spins each

### Crypto Spin (50 NC per spin)
- ✅ **admin_nexus**: Unlimited spins
- ✅ **VIP accounts**: 1000-2000 spins each
- ✅ **Pro accounts**: 400-500 spins each
- ✅ **Regular accounts**: 100-200 spins each
- ✅ **Test/Demo**: 20-100 spins each

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

### For 10 Pre-loaded Accounts
1. ✅ Creates each account with specified balance
2. ✅ Sets appropriate `account_type` (VIP, Professional, Regular, Test, Demo)
3. ✅ Logs initial balance transaction
4. ✅ Normal balance deduction applies during gameplay
5. ✅ Can be topped up manually if needed

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
        WHEN 'professional' THEN 3
        WHEN 'regular' THEN 4
        WHEN 'test' THEN 5
        WHEN 'demo' THEN 6
    END;
```

**Expected Output:**
```
    username     | display_balance | account_type  
-----------------+-----------------+---------------
 admin_nexus     | UNLIMITED       | admin
 casino_vip_01   | 100,000.00 NC   | vip
 casino_vip_02   |  75,000.00 NC   | vip
 casino_vip_03   |  50,000.00 NC   | vip
 casino_pro_01   |  25,000.00 NC   | professional
 casino_pro_02   |  20,000.00 NC   | professional
 casino_player_01|  10,000.00 NC   | regular
 casino_player_02|  10,000.00 NC   | regular
 casino_player_03|   5,000.00 NC   | regular
 casino_test_01  |   5,000.00 NC   | test
 casino_demo     |   1,000.00 NC   | demo
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

### Test casino_vip_01 (100,000 NC)
```bash
# Get balance
curl http://localhost:9503/api/balance/casino_vip_01
# Expected: {"username":"casino_vip_01","balance":100000,"currency":"NC"}

# Play game
curl -X POST http://localhost:9503/api/games/nexus-poker/play \
  -H "Content-Type: application/json" \
  -d '{"username":"casino_vip_01","betAmount":100}'
# Expected: Balance changes based on win/loss

# Check balance again
curl http://localhost:9503/api/balance/casino_vip_01
# Expected: 99900 (if lost) or 100180 (if won with 1.8x payout)
```

### Test All Other Accounts
Same pattern for:
- casino_vip_02, casino_vip_03
- casino_pro_01, casino_pro_02
- casino_player_01, casino_player_02, casino_player_03
- casino_test_01, casino_demo

---

## 📝 Manual Account Top-Up

If you need to add more NC to any pre-loaded account:

```sql
-- Top up casino_vip_01 by 50,000 NC
UPDATE user_wallets 
SET balance = balance + 50000, 
    updated_at = NOW() 
WHERE username = 'casino_vip_01';

-- Log the transaction
INSERT INTO wallet_transactions 
  (username, amount, transaction_type, balance_after, description) 
VALUES 
  ('casino_vip_01', 50000, 'manual_topup', 
   (SELECT balance FROM user_wallets WHERE username = 'casino_vip_01'),
   'Manual top-up by admin');
```

---

## 🔒 Security Notes

### For Production:
1. **Change admin_nexus behavior**: Consider removing unlimited balance in production
2. **Protect test accounts**: Ensure pre-loaded accounts are not accessible to end users
3. **Monitor transactions**: Set up alerts for unusual activity on pre-loaded accounts
4. **Rate limiting**: Apply rate limits even to admin accounts

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
        WHEN 'professional' THEN 3
        WHEN 'regular' THEN 4
        WHEN 'test' THEN 5
        WHEN 'demo' THEN 6
    END;
```

---

## ✅ Summary

**This fix creates and manages 11 pre-loaded casino accounts:**

1. **1 Admin Account** (`admin_nexus`) with UNLIMITED balance - THIS IS YOUR ACCOUNT
2. **10 Casino Accounts** with pre-set balances for testing and gameplay

**Key Features:**
- ✅ admin_nexus has truly unlimited balance (never decreases)
- ✅ All 10 casino accounts pre-loaded with specified NC amounts
- ✅ Full transaction logging for all accounts
- ✅ Database triggers ensure admin account stays unlimited
- ✅ Ready for immediate testing and gameplay
- ✅ All accounts work with Poker, Blackjack, Slots, Crypto Spin

**Total Accounts**: 11 (1 admin + 10 casino accounts)
**Total Pre-loaded NC**: 315,000 NC + UNLIMITED (admin)

---

**Created**: 2025-12-24  
**Version**: 1.0.0  
**Status**: Ready for Implementation ✅
