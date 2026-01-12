# N3X-UP: The Cypher Dome™

**Phase 3 - Complete Competitive Battle Arena System**

## Overview

N3X-UP: The Cypher Dome™ is a persistent virtual battle arena featuring rap battles with hybrid AI + human + crowd judging, serialized IMVU-L league system, regional and style-based war maps, Belt NFT mechanics, and compliance-ready skill-based wagering.

## System Vision

**"You don't step in… you level up."**

N3X-UP represents a revolutionary battle system where:
- Battles are recorded permanently on the Neon Vault ledger
- Performance is judged by a hybrid AI + Crowd + Human system
- **Progression follows a 5-layer multi-dimensional evolution system**
- **All layers update simultaneously with each battle**
- Belts are earned as dynamic NFTs with real value and history
- Every bar, killshot, and moment is preserved as monetizable Echoes™
- Compliance-ready wagering allows skill-based competition

## NEW: Layered Progression System

**"You don't just rank up… you level up across 5 layers."**

N3X-UP Phase 3 introduces a revolutionary **multi-dimensional progression system** where battlers evolve across 5 interconnected layers simultaneously:

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

### How It Works

**Simultaneous Updates**: Every battle updates all 5 layers at once
- **Skill Layer** (35% weight): Technical mastery, bars quality, style proficiency
- **Momentum Layer** (20% weight): Win streaks, rivalries, cross-region success
- **Narrative Layer** (15% weight): Story arcs, era conflicts, legacy building
- **Rank Layer** (100% composite): Visible tier progression, battle privileges
- **Monetization Layer** (10% weight): Echoes™ royalties, belt economics, sponsorships

**Cross-Layer Synergies**: Layers amplify each other
- High skill + win streak = faster tier acceleration
- Active rivalry + echoes sales = increased royalty rates  
- Narrative impact + momentum = belt economics boost

**Persistent Evolution**: All layer data stored immutably in Neon Vault

See [battlers/progression-layers.json](./battlers/progression-layers.json) for complete specification.

## Module Structure

```
n3x-up/
├─ arena/          # Battle environment, IMVU-L engine
├─ battlers/       # Profiles, stats, tier progression
├─ judging/        # AI + Crowd + Human hybrid system
├─ belts/          # NFT mechanics, defense tracking
├─ echoes/         # Replay royalties, monetization
├─ narrative/      # War map, rivalries, season structure
├─ ui/             # HUD, interfaces, wireframes
├─ compliance/     # Wagering logic, geo-fencing
├─ trailer/        # Marketing assets
└─ PR_documentation/ # Full system documentation
```

## Core Features

### 1. Layered Progression System (NEW)
- **5 Interconnected Layers**: Skill, Momentum, Narrative, Rank, Monetization
- **Simultaneous Updates**: All layers evolve with each battle
- **Cross-Layer Synergies**: Layers amplify each other for accelerated growth
- **Persistent Tracking**: Immutable storage in Neon Vault
- **Dynamic Calculation**: Real-time layer metrics inform all systems

### 2. Level-Up System (Tier Progression)
- **Tiers**: Initiate → Contender → Challenger → Ascendant → Champion → Legacy
- **Layer Requirements**: Each tier requires minimum scores across all layers
- **Progression**: Driven by Bar Intelligence Engine, Crowd AI, and Human Judges
- **Unlocks**: Narrative arcs, rivalries, monetization, UI badges, belt eligibility

### 3. Season 1 War Map
- **Regional Circuits**: West, Midwest, South, East, Global Wildcard
- **Styles**: Punchline, Scheme, Performance, Angle, Freestyle
- **Era Conflicts**: Pen vs Performance, Freestyle vs Written, Underground vs Algorithm, Legacy vs New Blood
- **Serialized Content**: Cyclic arcs, persistent storylines via IMVU-L
- **Layer Integration**: Narrative Layer auto-generates story arcs from battle outcomes

### 4. Founding Battlers Invite
- Genesis Season Badge for early participants
- Ledger recognition in Neon Vault
- Echoes™ royalty activation from day one
- +5% royalty bonus across all tiers
- Permanent record: "You are invited not to compete — but to be recorded."

### 5. Hybrid Judging System
- **Human Judges**: 40% weight - Expert panel scoring
- **Crowd AI**: 35% weight - Aggregated crowd reactions
- **Bar Intelligence Engine**: 25% weight - Technical analysis
- **Metrics**: Killshot detection, multisyllabic density, originality delta, momentum swings
- **Immutability**: All verdicts recorded on Neon Vault
- **Layer Outputs**: Feeds Skill and Momentum layers with each verdict

### 6. Battle Belt NFT Mechanics
- Dynamic visual evolution based on defenses
- Non-transferable while active; collectible on retirement
- Champion economics: defense bonuses, replay royalties, sponsorships
- Permanent belt history and legendary moments
- **Layer Integration**: Reads from Rank, Momentum, Monetization layers for eligibility

### 7. Battle Echoes™ Monetization
- Monetized replay clips from battles
- Royalty distribution to battlers (65%-90% tier-based)
- Killshot highlights and legendary moments
- Permanent archive of all performances
- **Dynamic Royalties**: Calculated using Monetization, Narrative, and Skill layers

### 8. Compliance-Ready Wagering
- Skill-based, deterministic system
- Pre-battle pool closure
- Geo-fenced, age-verified, auditable
- Integrated with ranking, belts, and Echoes™ monetization

## Integration with v-COS

N3X-UP is registered natively under v-COS core:
- Uses IMVU (Interactive Multi-Verse Unit) architecture
- Follows Handshake protocol (55-45-17)
- Integrates with Neon Vault for permanent storage
- Connects to NexCoin economy for wagering and rewards
- Leverages Canon Memory Layer for state persistence

## Data Flow

```
[Battle Initiation] 
     │
     ▼
[IMVU-L Arena Engine] 
     │
     ▼
[Hybrid Judging System] <--- [Crowd AI] & [Human Judges] & [Bar Intelligence Engine]
     │
     ▼
[Layered Progression System] 
     ├─ Skill Layer        ← Technical analysis, bars quality
     ├─ Momentum Layer     ← Win streaks, rivalries
     ├─ Narrative Layer    ← Story arcs, era conflicts
     ├─ Rank Layer         ← Tier progression
     └─ Monetization Layer ← Echoes™, belt economics
     │
     ├─> [Belt Mechanics]       ← Defense Tracking + Champion Economics
     │
     └─> [Battle Echoes™ Monetization] ← Replay Royalties
     │
     ▼
[Ledger Storage] --- Immutable Neon Vault
```

## Season 1 Structure

Season 1 features a placeholder battle structure ready for content insertion:
- 5 initial battles outlined
- Cross-region matchups
- Style wars (Punchline vs Scheme, etc.)
- Era conflicts (Pen Era vs Performance Era)
- Serialized IMVU-L arcs
- Rivalry threads auto-generated
- Momentum tracking across battles

**Note**: No guest names included; structure is content-ready.

## Status

- ✅ Phase 3 complete and merge-ready
- ✅ All subsystems documented
- ✅ Compliance-ready wagering logic
- ✅ Serialized IMVU-L battle structure
- ✅ No breaking changes to v-COS core
- ⏳ Content population (battler names, specific matchups)
- ⏳ Live IMVU-L Season 1 deployment

## Quick Start

See individual module READMEs for detailed implementation:
- [Arena System](./arena/README.md)
- [Battlers System](./battlers/README.md)
- [Judging System](./judging/README.md)
- [Belt Mechanics](./belts/README.md)
- [Echoes System](./echoes/README.md)
- [Narrative System](./narrative/README.md)
- [UI/UX](./ui/README.md)
- [Compliance](./compliance/README.md)

## Tagline

**"Bars don't drop. They echo."**

---

**Version**: Phase 3.0  
**Status**: Merge-Ready  
**Integration**: Native v-COS Module  
**Last Updated**: 2026-01-12
