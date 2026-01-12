# Compliance & Wagering System

## Overview

The Compliance System ensures N3X-UP: The Cypher Dome™ operates within legal frameworks for skill-based competition and wagering. It implements geo-fencing, age verification, auditable transactions, and skill-based deterministic mechanics.

## Core Compliance Principles

### Skill-Based Competition
- **Deterministic Outcome**: Battle results based solely on performance
- **No Random Elements**: No dice, cards, or luck-based factors
- **Transparent Judging**: Published scoring criteria
- **Player Skill Dominant**: Better battler wins

### Not Gambling
N3X-UP wagering is **skill-based competition**, not gambling:
- Outcome determined by battler skill
- No house edge
- No chance-based mechanics
- Transparent and auditable

## Wagering Mechanics

### Pool Structure

**Pre-Battle Pool**
```json
{
  "battle_id": "battle_123",
  "pool": {
    "total_nexcoin": 50000,
    "battler_a_backing": 28000,
    "battler_b_backing": 22000,
    "pool_status": "closed",
    "close_time": "2026-03-15T19:45:00Z"
  },
  "payout_structure": {
    "winner_backers": 0.95,
    "platform_fee": 0.05
  }
}
```

**Key Rules**
- Pool opens when battle scheduled
- Pool closes 15 minutes before battle
- No wagering during battle
- Payouts based on pool distribution
- Platform takes 5% fee

### Skill-Based Determination

**Why It's Skill-Based**
1. **Human Judges**: 40% weight, expert evaluation
2. **Crowd AI**: 35% weight, democratic consensus
3. **Bar Intelligence Engine**: 25% weight, objective metrics
4. **No Randomness**: All factors performance-based
5. **Historical Performance**: Past record influences expectations

### Payout Calculation

```javascript
// Winner's backers get proportional share
totalPool = poolTotalNexCoin;
platformFee = totalPool * 0.05;
payoutPool = totalPool - platformFee;

userStake = userNexCoinBacked;
winnerBackingTotal = battlerWinnerBackingNexCoin;

userPayout = (userStake / winnerBackingTotal) * payoutPool;
userProfit = userPayout - userStake;
```

**Example**
- Total pool: 50,000 NexCoin
- User backed: 1,000 NexCoin on winner
- Winner backing total: 22,000 NexCoin
- Platform fee: 2,500 NexCoin (5%)
- Payout pool: 47,500 NexCoin
- User share: (1,000/22,000) * 47,500 = 2,159 NexCoin
- User profit: 1,159 NexCoin (115.9% return)

## Age Verification

### Required Verification
- **Minimum Age**: 18+ (adjustable by jurisdiction)
- **Identity Verification**: Government ID or equivalent
- **One-Time Process**: Verified once, permanent status
- **Privacy Protected**: Verification data encrypted

### Verification Flow
```
User Account Creation
  ↓
Age Verification Prompt
  ↓
Upload ID / Third-Party Verification
  ↓
Automated + Manual Review
  ↓
Verification Status: Approved / Denied
  ↓
Access Granted / Restricted
```

### Restricted Access (Unverified)
- Can watch battles
- Cannot participate in wagering
- Cannot create battler profile
- Cannot earn NexCoin from battles

## Geo-Fencing

### Jurisdiction Compliance

**Allowed Regions**
System maintains whitelist of jurisdictions where skill-based competitions are permitted.

**Blocked Regions**
Auto-blocks access from jurisdictions with:
- Gambling prohibition laws
- Unclear skill-based competition laws
- Active legal uncertainty

**Detection Methods**
- IP address geolocation
- User-provided location
- Payment method location
- VPN/Proxy detection

### Geo-Block Enforcement
```json
{
  "user_id": "user_123",
  "location": {
    "ip_country": "US",
    "ip_region": "CA",
    "user_declared": "US-CA",
    "payment_location": "US-CA",
    "vpn_detected": false
  },
  "access": {
    "allowed": true,
    "wagering_allowed": true,
    "restricted_features": []
  }
}
```

## Auditable Transactions

### Blockchain Storage

All transactions on Neon Vault:
- Wagering pool deposits
- Battle outcomes
- Payout distributions
- Platform fees
- Historical records

### Transaction Record
```json
{
  "transaction_id": "tx_abc123",
  "type": "wager_placement",
  "user_id": "user_123",
  "battle_id": "battle_045",
  "amount_nexcoin": 1000,
  "backed_battler": "battler_a",
  "timestamp": "2026-03-15T19:30:00Z",
  "pool_status": "open",
  "neon_vault_hash": "0xdef456...",
  "immutable": true
}
```

### Audit Trail
Complete transparency:
- All wagers publicly visible
- Pool totals real-time
- Payout calculations verifiable
- Platform fees transparent
- Historical data preserved

## Responsible Gaming

### User Protections

**Deposit Limits**
- Daily: 10,000 NexCoin
- Weekly: 50,000 NexCoin
- Monthly: 150,000 NexCoin
- Custom limits available

**Self-Exclusion**
- Temporary (1-12 months)
- Permanent option
- Immediate effect
- Cannot be reversed early

**Reality Checks**
- Session time warnings (2 hours)
- Loss warnings (25% of balance)
- Suggested breaks
- Educational resources

### Problem Gaming Support
- Help resources linked
- Contact information for support
- Anonymous assistance available
- No judgment policy

## Anti-Fraud Measures

### Multi-Account Prevention
- Email verification
- Phone verification
- Device fingerprinting
- IP tracking
- Behavioral analysis

### Suspicious Activity Detection
- Unusual wagering patterns
- Coordinated multi-account betting
- VPN abuse
- Rapid deposit/withdraw cycles
- Collusion indicators

### Investigation & Sanctions
- Automated flagging
- Manual review
- Account suspension
- Funds frozen (if fraud confirmed)
- Permanent ban for severe violations

## Regulatory Documentation

### Terms of Service

**Key Clauses**
- Skill-based competition definition
- Age and location requirements
- Wagering rules and payout structure
- Platform fee disclosure
- Dispute resolution process
- Responsible gaming commitments

### Privacy Policy
- What data is collected
- How data is used
- Data retention policies
- Third-party sharing (minimal)
- User rights (access, deletion)

### Fair Play Policy
- Judge conduct standards
- Battler conduct standards
- Anti-cheating measures
- Dispute resolution
- Sanctions and appeals

## Jurisdictional Compliance

### United States
- State-by-state analysis
- Skill game definitions
- Fantasy sports precedents
- Payment processing compliance
- Tax reporting (1099 for large winnings)

### European Union
- GDPR compliance
- Age verification standards
- Responsible gaming requirements
- Payment Service Directive (PSD2)
- National gambling authority coordination

### Other Regions
- Country-specific legal analysis
- Local payment method integration
- Cultural sensitivity
- Language localization
- Regional customer support

## Technical Implementation

### Compliance Service
```yaml
compliance-service:
  type: regulatory
  components:
    - age-verification
    - geo-fencing
    - transaction-auditing
    - responsible-gaming
    - fraud-detection
  endpoints:
    - /compliance/verify-age
    - /compliance/check-geo
    - /compliance/audit-trail
    - /compliance/self-exclude
    - /compliance/report-suspicious
  integrations:
    - identity-verification-provider
    - geolocation-service
    - neon-vault
    - nexcoin-wallet
```

### Age Verification Integration
Third-party providers:
- Onfido
- Jumio
- Veriff
- ID.me

### Geolocation Services
- MaxMind GeoIP2
- IP2Location
- Custom VPN detection

## Monitoring & Reporting

### Real-Time Monitoring
- Wagering volume
- Payout ratios
- Geographic distribution
- Age demographic
- Fraud flags

### Regulatory Reporting
- Transaction summaries
- User statistics
- Compliance metrics
- Incident reports
- Audit logs

### Transparency Reports
Public quarterly reports:
- Total wagering volume
- Platform fee collection
- Payout percentages
- Dispute resolutions
- Compliance incidents

## Future Enhancements

- **Multi-Jurisdiction Auto-Compliance**: AI-driven regulatory updates
- **Advanced Fraud Detection**: ML-based pattern recognition
- **Biometric Verification**: Facial recognition for high-stakes
- **Smart Contract Automation**: Fully decentralized payouts
- **Real-Time Regulator API**: Direct reporting to authorities

---

**Status**: Phase 3 Implementation Ready  
**Dependencies**: Neon Vault, NexCoin Wallet, Identity Verification APIs  
**Integration**: Native v-COS Module  
**Legal Review**: Recommended before launch
