# Battle Belt NFT System

## Overview

The Battle Belt system represents championship status through dynamic, evolving NFTs that track defense history, legendary moments, and champion economics. Belts are non-transferable while active and become collectible upon retirement.

**NEW**: Belt mechanics now integrate with the **Layered Progression System**, reading from Rank, Momentum, and Monetization layers to determine eligibility and economics.

## Belt Types

### Regional Belts
- **West Coast Championship**
- **Midwest Championship**
- **South Championship**
- **East Coast Championship**
- **Global Wildcard Championship**

Each regional belt represents dominance in that circuit's style and culture.

### Style Belts
- **Punchline Master**
- **Scheme Wizard**
- **Performance King**
- **Angle Assassin**
- **Freestyle Legend**

Specialty belts for dominant style mastery.

### Era Belts
- **Pen Era Champion**: Written, prepared bars
- **Performance Era Champion**: Live, performance-focused
- **Hybrid Era Champion**: Masters both styles

## Belt Structure

### NFT Metadata
```json
{
  "belt_id": "west_coast_championship_001",
  "type": "regional",
  "region": "west",
  "current_champion": {
    "battler_id": "battler_045",
    "name": "placeholder",
    "won_date": "2026-03-15T20:45:00Z",
    "defenses": 3
  },
  "history": [
    {
      "champion": "battler_023",
      "reign_start": "2026-01-10",
      "reign_end": "2026-03-15",
      "defenses": 2,
      "lost_to": "battler_045"
    }
  ],
  "legendary_moments": [
    {
      "battle_id": "battle_098",
      "timestamp": "2026-03-15T20:32:15Z",
      "moment": "Title-winning killshot",
      "echo_id": "echo_098_killshot_final"
    }
  ],
  "visual": {
    "base_design": "west_coast_aesthetic",
    "evolution_level": 3,
    "nameplate": "current_champion_name",
    "defense_gems": 3
  },
  "economics": {
    "defense_bonus_nexcoin": 5000,
    "echo_royalty_boost": 0.05,
    "sponsorship_active": true
  },
  "status": "active",
  "nft_token_id": null,
  "transferable": false
}
```

## Belt Mechanics

### Winning a Belt

**Eligibility**
- Tier: Challenger or higher
- Record: Win rate > 60%
- Region/Style alignment (for specific belts)
- No active sanctions

**Challenge Process**
1. Challenger qualifies through contender matches
2. Challenge issued to current champion
3. Championship battle scheduled
4. 5-round format
5. Winner determined by hybrid judging
6. Belt ceremonially transferred
7. NFT metadata updated immutably

### Defending a Belt

**Requirements**
- Must defend within 90 days
- Minimum 1 defense per quarter
- Can choose challengers from qualified pool

**Defense Incentives**
- **1st Defense**: +5,000 NexCoin bonus
- **2nd Defense**: +7,500 NexCoin bonus
- **3rd Defense**: +10,000 NexCoin bonus
- **Each Additional**: +10,000 NexCoin bonus
- **Echo Royalty**: +1% per defense (cap at +10%)

**Failed Defense**
- Belt transferred to challenger
- Former champion retires belt to Legacy tier
- NFT becomes collectible
- Lifetime royalties activated

### Belt Evolution

Belts evolve visually based on defenses:

**Level 1** (0-2 defenses)
- Basic championship design
- Champion nameplate
- Regional/style iconography

**Level 2** (3-5 defenses)
- Enhanced visual effects
- Defense gem indicators
- Animated elements

**Level 3** (6-9 defenses)
- Premium materials (holographic)
- Legendary moment highlights
- Special arena entrance

**Level 4** (10+ defenses)
- Mythic tier appearance
- Custom champion signature
- Hall of Fame designation
- Permanent legacy status

## Champion Economics

### While Active

**Revenue Streams**
1. **Defense Bonuses**: 5,000-10,000 NexCoin per defense
2. **Echo Royalties**: Base 85% + defense bonus (up to 95%)
3. **Sponsorships**: Platform-approved brand deals
4. **Premium Arena Access**: Priority time slots
5. **Merchandise**: Official champion merchandise revenue share

**Responsibilities**
- Regular defenses (quarterly minimum)
- Public appearances
- Community engagement
- Uphold champion conduct standards

### Layer Integration

**Belt mechanics read from Progression Layers:**

#### Rank Layer → Belt Eligibility
- Must be Champion tier (Level 5)
- Tier requirements include layer minimums:
  - Skill Layer: 80+
  - Momentum Layer: 75+
  - Narrative Layer: 70+
  - Monetization Layer: 70+

#### Momentum Layer → Defense Tracking
- Win streaks affect defense bonuses
- Comeback factor influences championship economics
- Rivalry outcomes feed narrative arcs

#### Monetization Layer → Belt Economics
- Defense bonuses update Monetization Layer
- Echo royalty rates reflect belt holder status
- Sponsorship eligibility driven by Monetization Layer score

**Belt Impact on Layers:**
```
[Belt Won] 
     │
     ├─> Rank Layer: Tier = Champion
     ├─> Momentum Layer: +10 momentum boost
     ├─> Narrative Layer: New championship arc
     └─> Monetization Layer: Activates belt economics
```

### Upon Retirement

**Belt NFT Transformation**
- Belt becomes collectible NFT
- Minted with full history
- Transferable on marketplace
- Retains legendary moment references

**Lifetime Benefits**
- **Echo Royalties**: 90% permanent on all past battles
- **Hall of Fame**: Permanent profile feature
- **Legacy Badge**: Special visual indicator
- **Judge Role**: Eligible for championship judging
- **Mentor Status**: Can train new battlers

## Belt Ownership Rules

### Non-Transferability (Active)
While belt is active:
- Cannot be sold
- Cannot be gifted
- Cannot be traded
- Bound to current champion

Purpose: Maintains championship integrity

### Transferability (Retired)
Upon retirement to Legacy:
- NFT becomes fully transferable
- Can be sold on marketplace
- Retains full history and metadata
- Legendary moments preserved

## Belt Valuation

### Active Belt Value
Determined by:
- Defense count
- Champion tier and record
- Historic significance
- Legendary moments captured
- Regional/style prestige

### Retired Belt Value
Market-driven, influenced by:
- Former champion's legacy
- Defenses during reign
- Memorable moments
- Rarity (first champion, longest reign, etc.)
- Community sentiment

## Technical Implementation

### Belt Service
```yaml
belt-service:
  type: nft-contract
  blockchain: neon_vault
  endpoints:
    - /belts/:id
    - /belts/:id/challenge
    - /belts/:id/defend
    - /belts/:id/transfer
    - /belts/marketplace
  integrations:
    - neon-vault-nft
    - judging-service
    - battlers-service
    - echoes-service
```

### Smart Contract Functions
```solidity
// Pseudo-code representation
function awardBelt(battlerId, beltId)
function recordDefense(beltId, battleId)
function transferBelt(fromBattler, toBattler, beltId)
function retireBelt(beltId) returns (nftTokenId)
function updateBeltMetadata(beltId, metadata)
```

## Belt Ceremonies

### Championship Win
1. Battle concludes with challenger victory
2. Arena crowd erupts
3. Belt presentation ceremony
4. Champion speech (optional)
5. Belt metadata updated on Neon Vault
6. Echo clips generated for permanent record

### Successful Defense
1. Battle concludes with champion victory
2. Defense count incremented
3. Belt evolution check (visual upgrade if applicable)
4. Bonus NexCoin distributed
5. Defense recorded on Neon Vault

### Belt Retirement
1. Champion announces retirement or loses belt
2. Belt ceremony for final reign
3. NFT minted with full history
4. Hall of Fame induction
5. Belt available on marketplace
6. Legacy status activated

## Compliance

### Gambling Regulations
- Belts themselves are not wagered
- Belt status affects skill-based pool sizing
- No pay-to-win mechanics
- Pure competition-based ownership

### Intellectual Property
- Belt designs are platform-owned
- Champion likenesses used with consent
- Echo clips follow standard royalty splits
- NFT ownership respects all IP rights

## Future Enhancements

- **Custom Belt Designs**: Champions customize their belt appearance
- **Belt Unification**: Hold multiple belts simultaneously
- **Team Battles**: Tag-team championship belts
- **All-Time Rankings**: Cross-era belt holder comparisons
- **Physical Belts**: Real-world championship belt replicas

## Belt Ledger

All belt history permanently stored on Neon Vault:
- Every champion
- Every defense
- Every transfer
- Every legendary moment
- Complete lineage

This creates an immutable championship record spanning the entire history of N3X-UP: The Cypher Dome™.

---

**Status**: Phase 3 Implementation Ready  
**Dependencies**: Neon Vault NFT, Judging Service, Battlers Service  
**Integration**: Native v-COS Module
