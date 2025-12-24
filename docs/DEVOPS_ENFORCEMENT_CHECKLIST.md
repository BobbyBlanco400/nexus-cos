# DevOps Enforcement Checklist - NexCoin & Casino Nexus

**Version:** 1.0.0  
**Date:** December 24, 2024  
**For:** TRAE SOLO CODER  
**Status:** Non-Negotiable Requirements

---

## ⚠️ CRITICAL: This is Not Optional

Every item on this checklist **must pass** before Casino Nexus launch. This enforces the closed-loop NexCoin utility model and ensures legal compliance.

---

## 🔐 Access Control

### Requirements

- [ ] **Block all game endpoints unless `wallet.nexcoin_balance >= min_required`**
  - Implement middleware check on all casino game routes
  - Return 403 Forbidden with "Insufficient NexCoin" message
  - Redirect to NexCoin purchase page

- [ ] **Enforce NexCoin purchase modal before casino entry**
  - Display purchase modal if balance < minimum threshold
  - Block casino navigation until purchase completed
  - Implement session-based purchase verification

- [ ] **Disable all fiat references inside game services**
  - Remove any $, USD, EUR, or currency symbols from game UI
  - Replace with NexCoin terminology only
  - Audit all API responses for fiat language

### Verification Commands

```bash
# Check for fiat references in game services
grep -r '\$\|USD\|EUR\|GBP\|cash\|money' modules/casino-nexus/services/ --exclude-dir=node_modules

# Verify access control middleware
grep -r 'nexcoin_balance.*>=.*min_required' modules/casino-nexus/services/casino-nexus-api/

# Test endpoint protection
curl -X POST http://localhost:9500/api/game/start -H "Authorization: Bearer <token>" -d '{"game":"blackjack"}'
# Should return 403 if insufficient balance
```

---

## 💼 Wallet Service

### Requirements

- [ ] **Wallet accepts only NexCoin**
  - No fiat balance fields in wallet schema
  - No cryptocurrency balance fields
  - Only `nexcoin_balance` field present

- [ ] **No withdraw endpoints enabled**
  - Ensure `/wallet/withdraw`, `/wallet/cashout` endpoints do not exist
  - Remove any withdrawal functionality from codebase
  - API should only support: purchase, spend, view_balance, history

- [ ] **Ledger is append-only**
  - Database transactions table has no UPDATE or DELETE operations
  - Implement immutable transaction log
  - All changes tracked with timestamps and signatures

- [ ] **All transactions tagged: `UTILITY_CREDIT`**
  - Every transaction has `type: 'UTILITY_CREDIT'` field
  - Transaction metadata includes utility purpose
  - No transaction types referencing gambling/betting

### Verification Commands

```bash
# Check wallet schema
psql -h localhost -U nexuscos -d nexuscos_db -c "\d wallet"
# Should show only nexcoin_balance, no fiat fields

# Verify no withdraw endpoints
grep -r 'withdraw\|cashout' modules/casino-nexus/services/nexcoin-ms/

# Check transaction tagging
psql -h localhost -U nexuscos -d nexuscos_db -c "SELECT DISTINCT type FROM transactions;"
# Should only show UTILITY_CREDIT related types

# Test ledger immutability
psql -h localhost -U nexuscos -d nexuscos_db -c "SELECT * FROM pg_trigger WHERE tgname LIKE '%transactions%';"
# Should show triggers preventing updates/deletes
```

---

## 🪙 NexCoin Service

### Requirements

- [ ] **Fixed issuance via purchase only**
  - NexCoin can only be created via purchase endpoint
  - No gameplay-based minting
  - No admin mint functions (except for promotions, clearly tagged)

- [ ] **No mint via gameplay**
  - Game rewards do not create new NexCoin
  - Rewards pull from platform reserve pool
  - No player actions can mint NexCoin

- [ ] **No random distribution**
  - No lottery-style NexCoin grants
  - No chance-based NexCoin rewards
  - All rewards are skill-based or promotional

- [ ] **No ROI language in API responses**
  - API responses do not mention "return on investment"
  - No "profit", "earnings", "interest" terminology
  - Use "rewards", "bonuses", "unlocks" instead

### Verification Commands

```bash
# Check for mint endpoints
grep -r 'mint\|create.*nexcoin' modules/casino-nexus/services/nexcoin-ms/ | grep -v purchase

# Verify no ROI language
grep -ri 'ROI\|return on investment\|profit\|earnings\|interest' modules/casino-nexus/services/

# Test purchase-only issuance
curl -X POST http://localhost:9501/api/nexcoin/purchase -d '{"amount":100,"user_id":"test"}'
# Should work

curl -X POST http://localhost:9501/api/nexcoin/mint -d '{"amount":100,"user_id":"test"}'
# Should return 404 or 403
```

---

## 🎰 Game Services

### Requirements

- [ ] **Skill verification enabled (server-side)**
  - Game outcomes validated by skill algorithm
  - Server calculates skill score for each action
  - Outcomes deterministically linked to player decisions

- [ ] **No RNG cash logic**
  - Random number generation used only for initial state (card shuffle, etc.)
  - Outcomes are not purely random
  - Player skill influences all results

- [ ] **Progressive rewards = platform grants**
  - Progressive pools are platform-managed, not player-pooled
  - Rewards issued from platform reserve
  - Clear distinction from gambling jackpots

- [ ] **Minimum NexCoin enforced per table**
  - Each game/table has `min_nexcoin_balance` requirement
  - Enforced before game start
  - Displayed prominently in UI

### Verification Commands

```bash
# Check for skill verification
grep -r 'skill.*score\|validate.*skill' modules/casino-nexus/services/skill-games-ms/

# Verify progressive pool implementation
grep -r 'progressive\|jackpot' modules/casino-nexus/services/rewards-ms/

# Test minimum balance enforcement
curl -X POST http://localhost:9503/api/game/blackjack/start -H "Authorization: Bearer <token_low_balance>"
# Should return error if balance too low
```

---

## 🏛 Compliance Flags

### Requirements

- [ ] **No "gambling", "bet", "wager", "cash out" strings in UI**
  - Search all frontend code for prohibited terms
  - Replace with compliant alternatives:
    - "gambling" → "skill gaming"
    - "bet" → "stake" or "entry"
    - "wager" → "play amount"
    - "cash out" → not applicable (remove feature)

- [ ] **Jurisdiction toggle active**
  - Feature flag system operational
  - Jurisdiction engine enabled (see `pfs/jurisdiction-engine.yaml`)
  - Regional features correctly filtered

- [ ] **Audit logging enabled for wallet + games**
  - All wallet transactions logged
  - All game actions logged
  - Logs include timestamps, user_id, action, amount
  - Logs retained for compliance period (7 years recommended)

### Verification Commands

```bash
# Search for prohibited terms in frontend
grep -ri 'gambling\|bet\|wager\|cash out' modules/casino-nexus/frontend/src/ --exclude-dir=node_modules

# Check jurisdiction toggle
curl http://localhost:8080/api/feature-flags | grep JURISDICTION_ENGINE_ENABLED

# Verify audit logging
tail -f logs/wallet-audit.log
tail -f logs/game-audit.log

# Check log retention policy
grep -r 'LOG_RETENTION' .env* config/
```

---

## 🧪 Beta / Founder Controls

### Requirements

- [ ] **Founder NexCoin packs flagged `NON_PUBLIC`**
  - Founder-exclusive packs have `visibility: 'FOUNDER_ONLY'`
  - Not shown to public users
  - Gated by user role check

- [ ] **Time-boxed access enforced**
  - Founder beta has expiration date
  - System automatically transitions to public mode
  - No manual intervention required for cutover

- [ ] **Feature flags revert to public tiers post-beta**
  - `FOUNDER_BETA_MODE` flag has scheduled deactivation
  - Public feature set is clearly defined
  - Transition plan documented (see `pfs/founder-public-transition.yaml`)

### Verification Commands

```bash
# Check founder pack visibility
psql -h localhost -U nexuscos -d nexuscos_db -c "SELECT * FROM nexcoin_packs WHERE visibility = 'FOUNDER_ONLY';"

# Verify time-box configuration
grep -r 'FOUNDER_BETA_END_DATE\|BETA_EXPIRATION' .env* config/

# Check feature flag transition
cat config/feature-flags.json | grep -A5 FOUNDER_BETA_MODE
```

---

## 📋 Pre-Launch Verification Script

Run this comprehensive check before launching:

```bash
#!/bin/bash
# pre-launch-verification.sh

echo "🔍 Running Pre-Launch Verification..."

# Access Control
echo "✅ Checking access control..."
grep -q "nexcoin_balance.*>=.*min_required" modules/casino-nexus/services/casino-nexus-api/index.js || echo "❌ Missing balance check"

# Wallet Service
echo "✅ Checking wallet service..."
psql -h localhost -U nexuscos -d nexuscos_db -c "\d wallet" | grep -q "nexcoin_balance" || echo "❌ Wallet schema issue"

# NexCoin Service
echo "✅ Checking NexCoin service..."
grep -rq "UTILITY_CREDIT" modules/casino-nexus/services/nexcoin-ms/ || echo "❌ Missing utility credit tagging"

# Game Services
echo "✅ Checking game services..."
grep -rq "skill.*score" modules/casino-nexus/services/skill-games-ms/ || echo "❌ Missing skill verification"

# Compliance
echo "✅ Checking compliance..."
! grep -riq "gambling\|bet\|wager\|cash out" modules/casino-nexus/frontend/src/ --exclude-dir=node_modules || echo "⚠️ Prohibited terms found"

# Founder Controls
echo "✅ Checking founder controls..."
grep -q "FOUNDER_BETA_MODE" config/feature-flags.json || echo "❌ Founder beta flag missing"

echo "✅ Pre-Launch Verification Complete"
```

---

## 🎯 Deployment Gates

**DO NOT DEPLOY TO PRODUCTION UNTIL:**

1. ✅ All checklist items marked complete
2. ✅ Pre-launch verification script passes 100%
3. ✅ Legal review completed
4. ✅ Security audit completed
5. ✅ Load testing passed
6. ✅ Compliance documentation finalized

---

## 📞 Support

For questions or clarifications on this checklist:
- Technical: TRAE SOLO CODER
- Legal: Legal & Compliance Team
- Reference: `docs/COMPLIANCE_POSITIONING.md`

---

**This checklist is mandatory. No exceptions.**

**Version:** 1.0.0  
**Last Updated:** December 24, 2024  
**Next Review:** Before each major release
