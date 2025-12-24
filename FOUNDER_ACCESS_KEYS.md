# 👑 Nexus COS - Founder Access Keys

## Complete List of 11 Pre-loaded Accounts

---

### 👑 Super Admin (You)

- **Username**: `admin_nexus`
- **Password**: *(Your System Default)*
- **Balance**: ∞ Unlimited NC
- **Account Type**: Super Admin
- **Special Feature**: Balance never decreases

---

### 🐋 VIP Whales (High Stakes)
**Balance**: 1,000,000 NC each

1. **Username**: `vip_whale_01` | **Password**: `WelcomeToVegas_25`
2. **Username**: `vip_whale_02` | **Password**: `WelcomeToVegas_25`

---

### 🧪 Beta Founders (Standard)
**Balance**: 50,000 NC each

3. **Username**: `beta_tester_01` | **Password**: `WelcomeToVegas_25`
4. **Username**: `beta_tester_02` | **Password**: `WelcomeToVegas_25`
5. **Username**: `beta_tester_03` | **Password**: `WelcomeToVegas_25`
6. **Username**: `beta_tester_04` | **Password**: `WelcomeToVegas_25`
7. **Username**: `beta_tester_05` | **Password**: `WelcomeToVegas_25`
8. **Username**: `beta_tester_06` | **Password**: `WelcomeToVegas_25`
9. **Username**: `beta_tester_07` | **Password**: `WelcomeToVegas_25`
10. **Username**: `beta_tester_08` | **Password**: `WelcomeToVegas_25`

---

## Summary

- **Total Accounts**: 11
- **Admin Account**: 1 (Unlimited NC)
- **VIP Whale Accounts**: 2 (1,000,000 NC each = 2,000,000 NC total)
- **Beta Founder Accounts**: 8 (50,000 NC each = 400,000 NC total)
- **Total Pre-loaded NC**: 2,400,000 NC + UNLIMITED

---

## Password Information

- **All VIP and Beta Founder accounts** use the same password: `WelcomeToVegas_25`
- **admin_nexus** uses your system default password (NOT `WelcomeToVegas_25`)

---

## Database Implementation

These accounts are created by running:

```bash
psql -U nexus_user -d nexus_cos -f database/preload_casino_accounts.sql
```

Or via the automated fix script:

```bash
./devops/fix_database_and_pwa.sh
```

---

## Security Notice

⚠️ **For Production Deployment:**
- Change `WelcomeToVegas_25` to unique passwords per account
- Consider removing or limiting admin_nexus unlimited balance
- Restrict access to Founder Access Keys
- Monitor transaction activity on all accounts

---

**Version**: 2.0.0 - Founder Access Keys Edition  
**Date**: 2025-12-24  
**Status**: Ready for Beta Launch ✅
