# Battlers System

## Overview

The Battlers System manages battler profiles, statistics, tier progression, and identity within The Cypher Dome™. It tracks performance history, style preferences, rivalry threads, and progression through the ranking tiers.

**NEW in Phase 3**: Multi-dimensional **Layered Progression System** - Battlers evolve across 5 interconnected layers that update simultaneously with each battle.

## Layered Progression System

### Overview: Multi-Dimensional Evolution

**"You don't just rank up… you level up across 5 layers."**

N3X-UP battlers progress through a comprehensive **5-layer system** where each battle updates all dimensions simultaneously:

```
┌─────────────────────────────────────┐
│   MONETIZATION LAYER (Top)          │ ← Echoes™, Sponsorships, Belt Rewards
├─────────────────────────────────────┤
│   RANK LAYER                         │ ← Tier Progression, Champion Status
├─────────────────────────────────────┤
│   NARRATIVE LAYER                    │ ← Rivalries, Era Conflicts, Story Arcs
├─────────────────────────────────────┤
│   MOMENTUM LAYER                     │ ← Streaks, Style Wins, Crowd Reaction
├─────────────────────────────────────┤
│   SKILL LAYER (Base)                 │ ← Punchlines, Schemes, Cadence, Freestyle
└─────────────────────────────────────┘
```

### How Layers Work

**Simultaneous Updates**: Every battle outcome updates all 5 layers at once
- **Skill Layer** tracks technical mastery
- **Momentum Layer** tracks win streaks and rivalries
- **Narrative Layer** tracks story arcs and era conflicts
- **Rank Layer** tracks visible tier progression
- **Monetization Layer** tracks economic benefits

**Cross-Layer Synergies**: Layers amplify each other
- High skill + win streak = faster tier acceleration
- Active rivalry + echoes sales = increased royalty rates
- Narrative impact + momentum = belt economics boost

**Persistent Evolution**: All layer data stored immutably in Neon Vault

See [progression-layers.json](./progression-layers.json) for complete configuration.

---

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

---

## Layer Details

### Layer 1: Skill Layer (Base)
**Purpose**: Technical mastery of battle rap fundamentals  
**Weight in Rank**: 35%

**Components**:
- **Bars Quality**: Punchline impact, wordplay, metaphor density
- **Style Mastery**: Proficiency across punchline, scheme, performance, angle, freestyle
- **Multisyllabics**: Rhyme pattern complexity, flow variation
- **Freestyle Precision**: Improvisation quality, rebuttal speed
- **Scheme Complexity**: Internal rhymes, multi-layered wordplay

**Feeds Into**: Judging scores, Rank Layer progression

### Layer 2: Momentum Layer
**Purpose**: Win streaks, rivalry outcomes, cross-region success  
**Weight in Rank**: 20%

**Components**:
- **Win Streaks**: Current and longest streaks with bonus multipliers
- **Rivalry Outcomes**: Head-to-head records, rivalry intensity
- **Cross-Region Success**: Regional win rates, global ranking
- **Crowd Reaction Trend**: Recent crowd scores and trend direction
- **Comeback Factor**: Clutch performance, rounds won when behind

**Feeds Into**: Tier acceleration, Narrative Layer triggers

**Note**: Momentum decays 5% per 30 days of inactivity

### Layer 3: Narrative Layer
**Purpose**: Era conflicts, rivalries, storylines, serialized arcs  
**Weight in Rank**: 15%

**Components**:
- **Era Conflict Participation**: Pen vs Performance, Freestyle vs Written, Underground vs Algorithm, Legacy vs New Blood
- **Rivalries**: Active rivalries with tier classification (emerging/heated/legendary)
- **Storyline Threads**: Current arcs, completion rates, narrative milestones
- **Serialized IMVU-L Arcs**: Season participation, protagonist/antagonist roles
- **Legacy Building**: Memorable moments, killshot highlights, signature events

**Feeds Into**: Echoes™ value, Belt privileges, Content priority

**Special**: Auto-generates story arcs based on battle outcomes

### Layer 4: Rank Layer
**Purpose**: Visible tier badges, battle privileges, progression gates  
**Weight in Rank**: 100% (fed by other layers)

**Components**:
- **Tier Progression**: Current tier, level, progression percentage
- **Visible Badges**: Tier badge, Genesis badge, achievement badges
- **Battle Privileges**: Regional, cross-region, championship, belt challenges
- **Tier Acceleration**: Multipliers from Momentum, Skill, and Narrative bonuses

**Fed By**: Skill Layer (35%), Momentum Layer (20%), Narrative Layer (15%), Monetization Layer (10%)

**Protection**: 30-day grace period prevents demotion

### Layer 5: Monetization Layer (Top)
**Purpose**: Echoes™ royalties, belt defenses, sponsorship points  
**Weight in Rank**: 10%

**Components**:
- **Echoes™ Royalties**: Tier-based rates (65%-90%), Genesis bonus (+5%)
- **Belt Defense Economics**: 5,000+ NexCoin per defense, passive income
- **Sponsorship Points**: Eligibility at Ascendant+, tier-based opportunities
- **Battle Pool Earnings**: Wagering participation, win bonuses
- **Premium Content Sales**: Echoes sold, killshot highlights, revenue share

**Feeds Into**: Rank Layer, Champion status qualification

**Unlocks by Tier**:
- Initiate: Basic Echoes™
- Contender: Standard Echoes™
- Challenger: Belt contention economics
- Ascendant: Limited sponsorships
- Champion: Full monetization suite
- Legacy: Lifetime royalties

---

## Battler Profile Structure (Enhanced with Layers)

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
  "layers": {
    "skill": {
      "overall_score": 78,
      "bars_quality": 82,
      "style_mastery": 75,
      "multisyllabics": 80,
      "freestyle_precision": 72,
      "scheme_complexity": 81
    },
    "momentum": {
      "current_streak": 3,
      "longest_streak": 5,
      "rivalry_win_rate": 0.67,
      "cross_region_success": 2,
      "crowd_reaction_trend": "up",
      "comeback_factor": 68
    },
    "narrative": {
      "era_alignment": "pen_era",
      "active_rivalries": 2,
      "storyline_participation": ["regional_champion_arc"],
      "arc_completion": 0.65,
      "narrative_impact_score": 72
    },
    "rank": {
      "current_tier": "contender",
      "tier_level": 2,
      "progression_percentage": 68,
      "tier_acceleration_multiplier": 1.25
    },
    "monetization": {
      "echoes_royalty_rate": 0.75,
      "lifetime_earnings": 12500,
      "sponsorship_eligible": false,
      "belt_economics_active": false
    }
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
