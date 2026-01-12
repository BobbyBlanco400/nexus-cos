# Arena System

## Overview

The Arena System provides the persistent virtual battle environment powered by IMVU-L (Interactive Multi-Verse Unit - League) architecture. It manages battle initiation, environment state, crowd simulation, and real-time event processing.

## Architecture

### IMVU-L Arena Engine

The core engine runs as an isolated IMVU instance with league-specific extensions:
- **Persistent State**: Arena maintains state across battles
- **Crowd Simulation**: Dynamic crowd reactions and emotes
- **Event Processing**: Real-time capture of bars, reactions, momentum
- **Recording System**: All battles permanently archived

### Arena Components

```javascript
{
  "arena": {
    "id": "cypher_dome_main",
    "type": "persistent_virtual_space",
    "capacity": {
      "battlers": 2,
      "crowd": "unlimited_virtual",
      "judges": 3
    },
    "environment": {
      "visual_theme": "neon_vault_aesthetic",
      "lighting": "dynamic_mood_responsive",
      "audio": "spatial_3d_enabled"
    },
    "recording": {
      "enabled": true,
      "storage": "neon_vault",
      "resolution": "4k",
      "capture_angles": "multiple"
    }
  }
}
```

## Battle Flow

### 1. Battle Initiation
```
Battler A challenges Battler B
  ↓
System validates eligibility (tier, record, belt status)
  ↓
Wagering pool opens (if enabled)
  ↓
Battle scheduled in arena queue
  ↓
Pre-battle setup (judges assigned, crowd invited)
  ↓
Wagering pool closes
  ↓
Battle begins
```

### 2. Round Structure
- **Format**: 3 rounds standard (Championship: 5 rounds)
- **Time per Round**: 2 minutes per battler
- **Preparation**: 30 seconds between rounds
- **Rebuttals**: Allowed in Championship battles

### 3. Environment State
The arena maintains real-time state:
- Battler positions and animations
- Crowd intensity and emote patterns
- Momentum graph visualization
- Judge reactions
- Killshot highlights
- Bar text overlay (optional)

## Technical Implementation

### Arena Service

```yaml
arena-service:
  type: imvu-l
  endpoints:
    - /arena/status
    - /arena/initiate
    - /arena/state
    - /arena/recording
  integrations:
    - judging-service
    - crowd-ai-service
    - neon-vault
    - echoes-service
```

### State Management
```javascript
arenaState: {
  battleId: "uuid",
  status: "in_progress", // waiting | in_progress | concluded
  round: 2,
  battlers: [
    {
      id: "battler_001",
      position: "left",
      momentum: 65,
      lastBar: "timestamp"
    },
    {
      id: "battler_002", 
      position: "right",
      momentum: 58,
      lastBar: "timestamp"
    }
  ],
  crowd: {
    intensity: 87,
    dominantReaction: "fire_emoji",
    volume: "loud"
  },
  judges: [
    { id: "judge_001", currentScore: [8, 7] },
    { id: "judge_002", currentScore: [7, 8] },
    { id: "judge_003", currentScore: [8, 8] }
  ]
}
```

## In-Arena Features

### 1. Arena HUD
Displayed to all viewers:
- Battler names and tier badges
- Round timer
- Real-time momentum graph
- Crowd intensity meter
- Judge reactions (live)

### 2. Crowd Interface
Virtual crowd participants can:
- Activate emote wheel (fire, skull, crown, etc.)
- Influence crowd AI scoring
- See live momentum shifts
- Access instant replay highlights

### 3. Recording System
Every battle is captured with:
- Multiple camera angles
- Crowd audio layer
- Judge commentary (if enabled)
- Bar text overlay option
- Killshot isolation for Echoes™

## Arena Modes

### Standard Battle
- 3 rounds
- 2 battlers
- 3 judges minimum
- Crowd AI enabled

### Championship Battle
- 5 rounds
- Belt on the line
- 5 judges (includes legends)
- Extended crowd participation
- Rebuttal rounds enabled

### Exhibition Match
- Custom rules
- No ranking impact
- Belt not at stake
- Testing ground for new formats

## Integration Points

### Neon Vault
- Battle metadata stored
- Full recording archived
- Verdict logged immutably
- Echoes™ clips generated

### Judging System
- Real-time judge feed
- Bar analysis stream
- Momentum calculation input
- Final verdict compilation

### Belt System
- Defense count tracking
- Champion presence verification
- Belt handoff ceremony
- Legacy moment capture

### Echoes™ System
- Killshot timestamp capture
- Highlight reel generation
- Monetizable clip extraction
- Royalty tracking initiation

## Configuration

### Arena Settings
```json
{
  "arena_config": {
    "battle_duration_minutes": 20,
    "round_count_standard": 3,
    "round_count_championship": 5,
    "time_per_round_seconds": 120,
    "break_between_rounds_seconds": 30,
    "crowd_ai_enabled": true,
    "recording_enabled": true,
    "killshot_detection_enabled": true,
    "momentum_visualization": true
  }
}
```

## Monitoring

Arena health metrics:
- Battle queue length
- Active battles count
- Recording storage rate
- Crowd participation rate
- System latency
- IMVU-L instance health

## Future Enhancements

- **Multi-Arena Support**: Regional arenas (West Coast Cypher, East Coast Cypher)
- **AR/VR Integration**: Full immersive battle experience
- **Celebrity Crowd**: Special guest reactions
- **Custom Arenas**: Battler-owned personal arenas
- **Arena Modifiers**: Environmental effects (rain, spotlight, etc.)

---

**Status**: Phase 3 Implementation Ready  
**Dependencies**: IMVU-L Runtime, Neon Vault, Judging Service  
**Integration**: Native v-COS Module
