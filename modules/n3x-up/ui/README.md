# UI/UX System

## Overview

The UI/UX System provides comprehensive interface designs for N3X-UP: The Cypher Dome™, including arena HUD, battler profiles, crowd interface, belt displays, and spectator views. All interfaces designed for both desktop and immersive N3XUSVISION modes.

## Arena HUD

### Main Battle Display

**Layout**
```
┌─────────────────────────────────────────────────────────┐
│  [BATTLER A]              ⏱ 1:45              [BATTLER B] │
│   Tier Badge             Round 2/3             Tier Badge │
│   Region Icon                                 Region Icon │
├─────────────────────────────────────────────────────────┤
│                                                           │
│         [═══════ MOMENTUM GRAPH ═══════]                │
│          A ████████████████░░░░░░░░ B                   │
│               68              58                         │
│                                                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │                                                   │   │
│  │            [BATTLE ARENA VIEW]                   │   │
│  │                                                   │   │
│  │         Battler A    vs    Battler B            │   │
│  │                                                   │   │
│  └─────────────────────────────────────────────────┘   │
│                                                           │
├─────────────────────────────────────────────────────────┤
│  JUDGES:  [Judge 1] 8-7  [Judge 2] 7-8  [Judge 3] 8-8   │
│  CROWD:   🔥🔥🔥🔥🔥 Intensity: 87%                     │
└─────────────────────────────────────────────────────────┘
```

**Elements**
- **Battler Names & Tiers**: Top corners with badges
- **Round Timer**: Countdown clock
- **Momentum Graph**: Real-time visual momentum
- **Battle Arena View**: Main video/3D viewport
- **Judge Scores**: Live scoring display
- **Crowd Intensity**: Aggregate crowd reaction meter

### Mobile/Compact View
```
┌──────────────────────┐
│ [A]  ⏱ 1:45  [B]    │
│  68 ══════╗░░░ 58   │
├──────────────────────┤
│                      │
│   [BATTLE VIEW]     │
│                      │
├──────────────────────┤
│ Judges: 8-7, 7-8, 8-8│
│ Crowd: 🔥🔥🔥🔥 87%  │
└──────────────────────┘
```

## Crowd Interface

### Emote Wheel
```
         🔥 Fire
    💀      |      👑
  Skull    YOU    Crown
    ⚰️      |      💥
       Coffin  Explosion
```

**Interactions**
- Tap/click emote to react
- Hold for intensity boost
- Cooldown: 3 seconds between emotes

### Crowd Participation Panel
```
┌──────────────────────────────────┐
│  YOUR INTENSITY VOTE              │
│  ╞══════════◉═══╡ 8/10          │
│                                   │
│  DOMINANT REACTION                │
│  🔥 Fire (45%)  💀 Skull (28%)   │
│                                   │
│  MOMENTUM INFLUENCE               │
│  Your votes: +2.3 to Battler A   │
└──────────────────────────────────┘
```

### Live Chat (Optional)
- Side panel for text chat
- Emote-only mode available
- Moderated for toxicity
- Verified users only

## Battler Profile

### Public Profile View
```
┌────────────────────────────────────────────────┐
│  [AVATAR]     BATTLER NAME                     │
│  Genesis      Tier: Challenger                 │
│  Badge        Region: West Coast               │
│                                                 │
│  RECORD: 15-7  (68% win rate)                 │
│  Styles: Punchline, Performance               │
│                                                 │
│  ┌──────────────────────────────────────────┐ │
│  │  STATS                                    │ │
│  │  ▓▓▓▓▓▓▓▓░░ Killshots: 8                 │ │
│  │  ▓▓▓▓▓▓▓░░░ Multisyllabic: 4.2          │ │
│  │  ▓▓▓▓▓▓▓▓▓░ Originality: 87             │ │
│  │  ▓▓▓▓▓▓▓▓░░ Crowd Favorite: 4.5         │ │
│  └──────────────────────────────────────────┘ │
│                                                 │
│  BELT HISTORY                                  │
│  🏆 West Regional (3 defenses) - Active       │
│                                                 │
│  RIVALRIES                                     │
│  vs Battler 087  (2-1 head-to-head)          │
│  Intensity: ████████░░ High                   │
│                                                 │
│  FEATURED ECHOES™                              │
│  [Killshot 1] [Killshot 2] [Round Highlight] │
│                                                 │
│  TOTAL EARNINGS: 12,500 NexCoin               │
└────────────────────────────────────────────────┘
```

### Private Dashboard
```
┌────────────────────────────────────────────────┐
│  BATTLER DASHBOARD                             │
│  ├─ Profile Management                        │
│  ├─ Battle History (detailed)                 │
│  ├─ Upcoming Battles                          │
│  ├─ Tier Progress: Challenger → Ascendant    │
│  │   Progress: ████████░░ 78%               │
│  ├─ Echoes™ Analytics                         │
│  │   This Week: 3,421 views / +450 NexCoin  │
│  ├─ Rivalry Management                        │
│  ├─ Training Mode Access                      │
│  ├─ Strategy Notes (private)                  │
│  └─ Earnings Breakdown                        │
└────────────────────────────────────────────────┘
```

## Belt Display

### In-Arena Belt Showcase
```
┌──────────────────────────────────────┐
│      WEST COAST CHAMPIONSHIP         │
│   ╔════════════════════════════════╗ │
│   ║  [HOLOGRAPHIC BELT VISUAL]     ║ │
│   ║                                 ║ │
│   ║    Current Champion:            ║ │
│   ║    BATTLER NAME                 ║ │
│   ║                                 ║ │
│   ║    Defenses: ⭐⭐⭐ (3)        ║ │
│   ║                                 ║ │
│   ║    Won: 2026-03-15              ║ │
│   ╚════════════════════════════════╝ │
│                                       │
│  LEGENDARY MOMENTS:                  │
│  • Title-winning killshot            │
│  • Defense #2 comeback victory       │
│  • Defense #3 dominant performance   │
└──────────────────────────────────────┘
```

### Belt Collection View
```
┌────────────────────────────────────────────────┐
│  CHAMPIONSHIP BELTS                            │
│                                                 │
│  ACTIVE BELTS                                  │
│  ┌─────────────┐  ┌─────────────┐            │
│  │ West Coast  │  │             │            │
│  │ [3D Model]  │  │   [Empty]   │            │
│  │ 3 defenses  │  │             │            │
│  └─────────────┘  └─────────────┘            │
│                                                 │
│  RETIRED BELTS (Collectible NFTs)             │
│  ┌─────────────┐  ┌─────────────┐            │
│  │ Punchline   │  │ Midwest     │            │
│  │ Master      │  │ Regional    │            │
│  │ [NFT Badge] │  │ [NFT Badge] │            │
│  └─────────────┘  └─────────────┘            │
│                                                 │
│  [View on Marketplace]                         │
└────────────────────────────────────────────────┘
```

## Battle Browser

### Battle Selection
```
┌────────────────────────────────────────────────┐
│  UPCOMING BATTLES    │ LIVE NOW │ REPLAYS      │
│                                                 │
│  🔴 LIVE: Championship Battle                  │
│  Battler A vs Battler B - Round 2/5           │
│  👥 15,234 watching    [JOIN BATTLE]          │
│  ────────────────────────────────────────────  │
│                                                 │
│  UPCOMING (2 hours)                            │
│  Rivalry Showdown - West vs East              │
│  Battler C vs Battler D                        │
│  🔔 Notify Me    [Schedule]                   │
│  ────────────────────────────────────────────  │
│                                                 │
│  FEATURED REPLAY                               │
│  Historic Battle: Era-Defining Clash          │
│  ⭐ 4.9/5    👁 125k views                   │
│  [Watch Replay - 500 NexCoin]                 │
└────────────────────────────────────────────────┘
```

## Rankings & Leaderboards

### Tier Rankings
```
┌────────────────────────────────────────────────┐
│  CHALLENGER TIER RANKINGS                      │
│                                                 │
│  #1  Battler Name A     22-5  (81%)  ⬆       │
│      West │ Punchline   Streak: W5            │
│                                                 │
│  #2  Battler Name B     18-4  (82%)  ━       │
│      East │ Scheme      Streak: W3            │
│                                                 │
│  #3  Battler Name C     20-7  (74%)  ⬇       │
│      South │ Performance Streak: L1           │
│                                                 │
│  [View Full Rankings]                          │
└────────────────────────────────────────────────┘
```

### Regional Power Rankings
```
┌────────────────────────────────────────────────┐
│  REGIONAL CIRCUIT POWER RANKINGS               │
│                                                 │
│  1. WEST COAST      ████████░░ 82             │
│     Top: Battler A  │  Battles: 47            │
│                                                 │
│  2. EAST COAST      ███████░░░ 78             │
│     Top: Battler B  │  Battles: 52            │
│                                                 │
│  3. MIDWEST         ██████░░░░ 71             │
│     Top: Battler C  │  Battles: 38            │
│                                                 │
│  [See All Regions]                             │
└────────────────────────────────────────────────┘
```

## Echo Marketplace

### Echo Browser
```
┌────────────────────────────────────────────────┐
│  ECHO MARKETPLACE                              │
│  [Search] [Filter by Type] [Sort: Trending ▼] │
│                                                 │
│  TRENDING ECHOES™                              │
│  ┌──────────────┐  ┌──────────────┐          │
│  │ [Thumbnail]  │  │ [Thumbnail]  │          │
│  │ Championship │  │ Killshot of  │          │
│  │ Killshot     │  │ the Week     │          │
│  │ 🔥 125k      │  │ 🔥 89k       │          │
│  │ 100 NexCoin  │  │ 100 NexCoin  │          │
│  └──────────────┘  └──────────────┘          │
│                                                 │
│  [Load More]                                   │
└────────────────────────────────────────────────┘
```

## Wireframe Specifications

### Color Palette
```
Primary:    #00ff9d (Neon Green)
Secondary:  #9d00ff (Purple)
Accent:     #ff00ff (Magenta)
Background: #0a0a0a (Near Black)
Text:       #ffffff (White)
Muted:      #808080 (Gray)
```

### Typography
```
Headings:   Montserrat Bold
Body:       Inter Regular
Monospace:  Fira Code (stats, timers)
```

### Responsive Breakpoints
```
Mobile:     < 768px
Tablet:     768px - 1024px
Desktop:    1024px - 1920px
XL Desktop: > 1920px
Immersive:  N3XUSVISION (custom)
```

## Immersive Mode (N3XUSVISION)

### Spatial UI
- 3D floating HUD elements
- Spatial audio for crowd reactions
- Volumetric battler viewing
- Gesture-based controls
- Full arena presence

### Enhanced Features
- 360° arena view
- Multi-angle camera switching
- Holographic belt displays
- Immersive emote reactions
- Spatial chat with crowd

## Accessibility

### Features
- High contrast mode
- Screen reader support
- Keyboard navigation
- Closed captions (all battles)
- Audio descriptions
- Adjustable text sizes

---

**Status**: Phase 3 Implementation Ready  
**Dependencies**: React, Three.js (3D), WebGL, N3XUSVISION SDK  
**Integration**: Native v-COS Module
