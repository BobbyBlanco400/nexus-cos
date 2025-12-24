# 🎰 Casino Accounts - Quick Reference

## 📊 11 Pre-loaded Accounts

### 1️⃣ Your Admin Account
- **admin_nexus** → ♾️ UNLIMITED NC

### 1️⃣0️⃣ Pre-loaded Casino Accounts
1. **casino_vip_01** → 100,000 NC
2. **casino_vip_02** → 75,000 NC  
3. **casino_vip_03** → 50,000 NC
4. **casino_pro_01** → 25,000 NC
5. **casino_pro_02** → 20,000 NC
6. **casino_player_01** → 10,000 NC
7. **casino_player_02** → 10,000 NC
8. **casino_player_03** → 5,000 NC
9. **casino_test_01** → 5,000 NC
10. **casino_demo** → 1,000 NC

---

## ⚡ Quick Test Commands

```bash
# Test YOUR unlimited account
curl http://localhost:9503/api/balance/admin_nexus

# Test VIP account
curl http://localhost:9503/api/balance/casino_vip_01

# Test all accounts
for user in admin_nexus casino_vip_01 casino_vip_02 casino_vip_03 casino_pro_01 casino_pro_02 casino_player_01 casino_player_02 casino_player_03 casino_test_01 casino_demo; do
  echo "=== $user ==="
  curl -s http://localhost:9503/api/balance/$user | jq
done
```

---

## 🎮 Game Costs

- **Nexus Poker**: 100 NC per hand
- **21X Blackjack**: 100 NC per hand
- **Nexus Slots**: 50 NC per spin
- **Crypto Spin**: 50 NC per spin

---

## 📊 View All Accounts in Database

```bash
psql -U nexus_user -d nexus_cos -c "SELECT username, CASE WHEN is_unlimited THEN 'UNLIMITED' ELSE balance::text || ' NC' END as balance, account_type FROM user_wallets ORDER BY CASE account_type WHEN 'admin' THEN 1 WHEN 'vip' THEN 2 WHEN 'professional' THEN 3 WHEN 'regular' THEN 4 WHEN 'test' THEN 5 WHEN 'demo' THEN 6 END;"
```

**Total**: 1 admin (unlimited) + 10 casino accounts = **11 accounts**
