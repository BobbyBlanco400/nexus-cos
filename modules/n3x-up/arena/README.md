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

### API Specifications

**GET /arena/status**
```yaml
description: Get current arena status and queue
authentication: Bearer token (optional for public view)
parameters: none
response:
  200:
    body:
      status: "available" | "in_use" | "maintenance"
      current_battle: battle_id | null
      queue_length: integer
      next_available: ISO8601_timestamp
  500:
    body:
      error: "Internal server error"
      message: string
```

**POST /arena/initiate**
```yaml
description: Initiate a new battle
authentication: Bearer token (required)
authorization: Battler tier >= Contender
request:
  body:
    challenger_id: uuid (required)
    opponent_id: uuid (required)
    battle_type: "standard" | "championship" (required)
    scheduled_time: ISO8601_timestamp (optional)
validation:
  - Both battlers must exist and be verified
  - Both battlers must meet tier requirements
  - No active sanctions on either battler
  - Scheduled time must be future (if provided)
  - Opponent must accept challenge (if not auto-match)
response:
  201:
    body:
      battle_id: uuid
      status: "scheduled"
      scheduled_time: ISO8601_timestamp
      wagering_pool_status: "open"
  400:
    body:
      error: "Bad request"
      message: "Invalid battler ID" | "Tier requirement not met"
      details: object
  401:
    body:
      error: "Unauthorized"
      message: "Authentication required"
  403:
    body:
      error: "Forbidden"
      message: "Battler has active sanction" | "Insufficient permissions"
  409:
    body:
      error: "Conflict"
      message: "Battler already has scheduled battle"
```

**GET /arena/state**
```yaml
description: Get real-time arena state during battle
authentication: Bearer token (optional for spectators)
parameters:
  battle_id: uuid (required)
response:
  200:
    body:
      battle_id: uuid
      status: "waiting" | "in_progress" | "concluded"
      round: integer
      battlers: array[battler_state]
      crowd: crowd_state
      judges: array[judge_state]
      momentum_graph: array[momentum_point]
  404:
    body:
      error: "Not found"
      message: "Battle not found"
```

**GET /arena/recording**
```yaml
description: Get battle recording and metadata
authentication: Bearer token (required for premium recordings)
parameters:
  battle_id: uuid (required)
response:
  200:
    body:
      battle_id: uuid
      recording_url: string (CDN URL)
      duration_seconds: integer
      resolution: "4k" | "1080p" | "720p"
      neon_vault_hash: string
      echo_clips: array[echo_reference]
  402:
    body:
      error: "Payment required"
      message: "Premium recording requires purchase"
      cost_nexcoin: integer
  404:
    body:
      error: "Not found"
      message: "Recording not available"
```

### Error Handling

**Standard Error Response Format**
```json
{
  "error": "Error category",
  "message": "Human-readable error message",
  "code": "ERROR_CODE",
  "details": {
    "field": "Additional context"
  },
  "timestamp": "ISO8601_timestamp"
}
```

**Common Error Codes**
- `AUTH_REQUIRED`: Authentication token missing or invalid
- `INSUFFICIENT_PERMISSIONS`: User lacks required permissions
- `RESOURCE_NOT_FOUND`: Requested resource does not exist
- `VALIDATION_ERROR`: Request data failed validation
- `RATE_LIMIT_EXCEEDED`: Too many requests
- `SERVICE_UNAVAILABLE`: Arena service temporarily unavailable
- `BATTLE_IN_PROGRESS`: Cannot modify battle in progress

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
