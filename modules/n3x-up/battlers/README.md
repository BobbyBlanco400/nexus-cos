# Battlers System

## Overview

The Battlers System manages battler profiles, statistics, tier progression, and identity within The Cypher Dome™. It tracks performance history, style preferences, rivalry threads, and progression through the ranking tiers.

## Tier System

### Progression Path
**"You don't step in… you level up."**

```
Initiate (Entry Level)
  ↓
Contender (Proven Record)
  ↓
Challenger (Elite Status)
  ↓
Ascendant (Championship Ready)
  ↓
Champion (Belt Holder)
  ↓
Legacy (Retired Champion)
```

### Tier Requirements

**Initiate**
- Entry tier for all new battlers
- Genesis Season Badge for founding battlers
- No prerequisites

**Contender**
- Minimum 5 battles
- Win rate > 40%
- No disqualifications

**Challenger**
- Minimum 15 battles
- Win rate > 55%
- At least 3 wins vs Contenders
- Killshot recognition (3+)

**Ascendant**
- Minimum 30 battles
- Win rate > 65%
- At least 5 wins vs Challengers
- Belt contention eligibility
- Verified by human judges

**Champion**
- Belt holder (active)
- Must defend belt regularly
- Special privileges and economics

**Legacy**
- Retired Champion
- Permanent hall of fame status
- Belt becomes collectible NFT
- Lifetime royalties on Echoes™

## Battler Profile Structure

```json
{
  "battler_id": "uuid",
  "name": "placeholder",
  "tier": "contender",
  "genesis_badge": true,
  "record": {
    "total_battles": 12,
    "wins": 8,
    "losses": 4,
    "win_rate": 0.667
  },
  "style_tags": ["punchline", "performance"],
  "region": "west",
  "stats": {
    "killshots": 5,
    "multisyllabic_avg": 4.2,
    "originality_score": 87,
    "crowd_favorite_rating": 4.5,
    "momentum_avg": 68
  },
  "belt_history": [
    {
      "belt_id": "west_regional",
      "won_date": "2026-03-15",
      "defenses": 3,
      "lost_date": null,
      "status": "active"
    }
  ],
  "echoes_earnings": {
    "total_nexcoin": 12500,
    "royalty_percentage": 0.80,
    "most_viewed_echo": "battle_045_killshot_3"
  },
  "rivalries": [
    {
      "opponent_id": "battler_087",
      "head_to_head": "2-1",
      "intensity": "high",
      "narrative_arc": "pen_era_vs_performance"
    }
  ],
  "progression_history": [
    {
      "tier": "initiate",
      "achieved_date": "2026-01-15"
    },
    {
      "tier": "contender",
      "achieved_date": "2026-02-20"
    }
  ]
}
```

## Style Tags

Battlers are classified by dominant styles:

### Primary Styles
- **Punchline**: Focus on impactful one-liners and wordplay
- **Scheme**: Complex rhyme patterns and multi-syllabic flows
- **Performance**: Delivery, presence, crowd engagement
- **Angle**: Personal attacks, character work, psychological warfare
- **Freestyle**: Off-the-top improvisation

### Style Combinations
Battlers can have multiple style tags (primary + secondary)
- Example: "Punchline + Performance"
- Example: "Scheme + Freestyle"

## Regional Circuits

### Regions
- **West**: West Coast style, performance-heavy
- **Midwest**: Scheme-focused, technical excellence
- **South**: Punchline-driven, call-and-response
- **East**: Lyricism, multi-layered wordplay
- **Global**: International wildcard circuit

Regional identity affects:
- Battle matchmaking
- Crowd preferences
- Narrative storylines
- Regional belt opportunities

## Statistics Tracking

### Performance Metrics

**Killshots**
- Decisive bars that swing momentum
- Detected by Bar Intelligence Engine
- Validated by crowd and judge reaction
- Preserved as premium Echoes™

**Multisyllabic Density**
- Average syllables per rhyme scheme
- Technical complexity indicator
- Tracked across all battles

**Originality Score**
- AI-detected uniqueness of bars
- Penalizes recycled material
- Rewards creative metaphors and wordplay

**Crowd Favorite Rating**
- Aggregate crowd reactions (1-5 scale)
- Influences Crowd AI scoring weight
- Can unlock special battle opportunities

**Momentum Average**
- Average momentum score across battles
- Indicates consistency and dominance
- Affects tier progression

## Battler Unlocks by Tier

### Contender
- Regional circuit access
- Standard battle scheduling
- Echoes™ royalty at 70%
- Basic rivalry tracking

### Challenger
- Cross-region battles
- Belt contention matches
- Echoes™ royalty at 75%
- Enhanced profile visibility
- Narrative arc participation

### Ascendant
- Championship battles
- Belt challenges
- Echoes™ royalty at 80%
- Premium arena time slots
- Mentor opportunities

### Champion
- Belt holder privileges
- Defense bonuses (NexCoin)
- Echoes™ royalty at 85%
- Sponsorship eligibility
- Hall of fame track

### Legacy
- Retired champion status
- Belt as collectible NFT
- Lifetime Echoes™ royalties at 90%
- Judge/mentor role
- Permanent ledger recognition

## Founding Battlers

### Genesis Season Badge
Early participants receive:
- Permanent Genesis Season Badge
- Priority battle scheduling
- Enhanced Echoes™ base royalty (+5%)
- Ledger recognition in Neon Vault
- "Founding Battler" title

### Invitation
> "You are invited not to compete — but to be recorded. Step into N3X-UP: The Cypher Dome™, or remain unrecorded."

## Profile Management

### Battler Dashboard
Accessible features:
- View full battle history
- Track tier progression
- Monitor Echoes™ earnings
- Review rivalries and head-to-head records
- Schedule battles
- Customize profile (within limits)
- View belt history

### Public Profile
Visible to all users:
- Name and tier badge
- Record (W-L)
- Style tags
- Region
- Top stats
- Belt history
- Featured Echoes™
- Notable rivalries

### Private Profile
Visible only to battler:
- Detailed analytics
- Earnings breakdown
- Battle invitations
- Training mode access
- Strategy notes

## Integration Points

### Judging System
- Performance data feeds judging algorithms
- Historical stats influence expectations
- Tier affects judging criteria

### Belt System
- Belt eligibility verification
- Defense tracking
- Champion economics distribution

### Echoes™ System
- Royalty percentage by tier
- Automatic clip generation
- Earnings distribution

### Narrative System
- Rivalry thread generation
- War map positioning
- Storyline participation

## Technical Implementation

### Battler Service
```yaml
battlers-service:
  type: rest-api
  endpoints:
    - /battlers/:id
    - /battlers/:id/stats
    - /battlers/:id/history
    - /battlers/:id/rivalries
    - /battlers/rankings
  storage: neon_vault
  cache: redis
```

### Tier Progression Engine
Automated system that:
- Monitors battle outcomes
- Calculates progression eligibility
- Triggers tier advancement
- Unlocks features automatically
- Notifies battler of advancement

## Compliance

### Identity Verification
- Age verification required (18+)
- Unique identity per battler
- Anti-smurf protections
- Account security measures

### Fair Play
- Performance monitoring
- Anti-cheat systems
- Dispute resolution
- Sanctions for violations

---

**Status**: Phase 3 Implementation Ready  
**Dependencies**: Neon Vault, Judging System, Belt System, Echoes™  
**Integration**: Native v-COS Module
