# Judging System

## Overview

The Judging System employs a hybrid AI + Crowd + Human judging model to evaluate battles with fairness, transparency, and immutability. All verdicts are permanently stored on the Neon Vault.

## Hybrid Judging Model

### Weight Distribution
```
Human Judges:          40%
Crowd AI:              35%
Bar Intelligence Engine: 25%
```

This distribution balances:
- Expert human judgment and context understanding
- Democratic crowd sentiment and reactions
- Objective technical analysis

**NEW**: Judging outputs now feed into the **Layered Progression System**, updating Skill and Momentum layers simultaneously.

## Human Judges (40% Weight)

### Judge Panel
- **Standard Battles**: 3 judges minimum
- **Championship Battles**: 5 judges (includes legends)
- **Qualification**: Verified battle history or industry credentials

### Scoring Criteria
Judges score on a 10-point scale for:
1. **Lyrical Content** (30%) - Wordplay, metaphors, complexity
2. **Delivery** (25%) - Flow, timing, confidence
3. **Impact** (25%) - Killshots, memorable moments
4. **Stage Presence** (20%) - Performance, crowd engagement

### Judge Card Format
```json
{
  "judge_id": "judge_001",
  "battle_id": "battle_123",
  "round": 1,
  "battler_a_score": {
    "lyrical": 8.5,
    "delivery": 7.0,
    "impact": 9.0,
    "presence": 8.0,
    "total": 8.125
  },
  "battler_b_score": {
    "lyrical": 7.5,
    "delivery": 8.5,
    "impact": 7.0,
    "presence": 7.5,
    "total": 7.625
  },
  "notes": "Battler A landed decisive killshot in round 1"
}
```

### Judge Accountability
- All scores are public and permanent
- Judge performance tracked over time
- Outlier detection for bias
- Community can flag questionable judging

## Crowd AI (35% Weight)

### Real-Time Crowd Reactions
The Crowd AI aggregates and analyzes:
- Emote activation patterns
- Reaction timing (immediate vs delayed)
- Intensity voting
- Live chat sentiment
- Momentum shifts

### Crowd Metrics
```javascript
{
  "battle_id": "battle_123",
  "round": 1,
  "battler_a": {
    "emote_count": 1247,
    "dominant_emote": "fire",
    "intensity_avg": 8.7,
    "sentiment_score": 0.82,
    "momentum_contribution": 68
  },
  "battler_b": {
    "emote_count": 943,
    "dominant_emote": "crown",
    "intensity_avg": 7.3,
    "sentiment_score": 0.71,
    "momentum_contribution": 58
  }
}
```

### Anti-Gaming Measures
- Bot detection and filtering
- Weighted by account age and history
- Outlier reaction filtering
- Regional normalization

## Bar Intelligence Engine (25% Weight)

### Technical Analysis
AI-powered analysis of battle performance:

**Killshot Detection**
- Identifies decisive impactful bars
- Measures crowd reaction spike correlation
- Scores impact on momentum

**Multisyllabic Density**
- Counts syllables per rhyme scheme
- Evaluates technical complexity
- Rewards intricate patterns

**Originality Delta**
- Compares against database of previous bars
- Penalizes recycled material
- Rewards unique metaphors and wordplay

**Momentum Tracking**
- Real-time momentum calculation
- Round-by-round swing analysis
- Visual graph generation

### Engine Output
```json
{
  "battle_id": "battle_123",
  "round": 1,
  "analysis": {
    "battler_a": {
      "killshots_detected": 2,
      "multisyllabic_avg": 5.2,
      "originality_score": 87,
      "technical_score": 8.3
    },
    "battler_b": {
      "killshots_detected": 1,
      "multisyllabic_avg": 4.1,
      "originality_score": 79,
      "technical_score": 7.1
    }
  },
  "momentum_graph": [
    { "timestamp": 0, "a": 50, "b": 50 },
    { "timestamp": 15, "a": 62, "b": 48 },
    { "timestamp": 30, "a": 68, "b": 45 }
  ]
}
```

## Verdict Calculation

### Round Scoring
Each round aggregates all three components:
```
Round Score = (Human × 0.40) + (Crowd AI × 0.35) + (Bar Intelligence × 0.25)
```

### Battle Winner
- Best of 3 rounds (standard)
- Best of 5 rounds (championship)
- Ties broken by:
  1. Crowd AI favorite
  2. Human judge majority
  3. Bar Intelligence score

### Verdict Structure
```json
{
  "battle_id": "battle_123",
  "verdict": {
    "winner": "battler_a",
    "method": "rounds",
    "score": "2-1",
    "breakdown": {
      "round_1": {
        "winner": "battler_a",
        "human_score": 8.2,
        "crowd_ai_score": 8.5,
        "bar_intelligence_score": 8.1,
        "final_score": 8.27
      },
      "round_2": {
        "winner": "battler_b",
        "human_score": 7.5,
        "crowd_ai_score": 7.8,
        "bar_intelligence_score": 7.9,
        "final_score": 7.72
      },
      "round_3": {
        "winner": "battler_a",
        "human_score": 8.8,
        "crowd_ai_score": 9.1,
        "bar_intelligence_score": 8.7,
        "final_score": 8.87
      }
    },
    "timestamp": "2026-03-15T20:45:00Z",
    "immutable": true,
    "neon_vault_hash": "0xabc123..."
  }
}
```

## Immutable Ledger

### Neon Vault Storage
All verdicts stored permanently:
- Full scoring breakdown
- Judge cards
- Crowd AI data
- Bar Intelligence analysis
- Battle recording reference
- Timestamp and hash

### Dispute Resolution
While verdicts are immutable, disputes can be filed:
- Review by governance council
- Can result in sanctions (not verdict changes)
- Protects against provable judge corruption
- Does not alter historical record

---

## Layer Integration

### Judging Outputs to Progression Layers

Each battle verdict updates multiple progression layers simultaneously:

#### Skill Layer Updates
Judging system outputs feed directly into Skill Layer components:
- **Bar Intelligence Engine** → Bars Quality, Scheme Complexity, Multisyllabics
- **Human Judges** → Style Mastery, Freestyle Precision
- **Technical Analysis** → Overall Skill Score (0-100)

#### Momentum Layer Updates
Battle outcomes and reactions update Momentum Layer:
- **Win/Loss** → Win Streaks, Comeback Factor
- **Crowd AI Scores** → Crowd Reaction Trend
- **Round-by-Round Performance** → Momentum Average

#### Data Flow
```
[Battle Verdict] 
     │
     ├─> [Skill Layer]
     │      ├─ bars_quality
     │      ├─ style_mastery
     │      ├─ multisyllabics
     │      ├─ freestyle_precision
     │      └─ scheme_complexity
     │
     └─> [Momentum Layer]
            ├─ win_streaks
            ├─ crowd_reaction_trend
            ├─ comeback_factor
            └─ momentum_avg
```

### Verdict Format (Enhanced with Layers)
```json
{
  "verdict": {
    "battle_id": "battle_123",
    "winner": "battler_a",
    "scores": {
      "human_judges": 0.40,
      "crowd_ai": 0.35,
      "bar_intelligence": 0.25
    },
    "layer_updates": {
      "battler_a": {
        "skill": {
          "bars_quality": 85,
          "style_mastery": 78,
          "multisyllabics": 82,
          "freestyle_precision": 74,
          "scheme_complexity": 88
        },
        "momentum": {
          "win_streak_updated": 4,
          "crowd_reaction_trend": "up",
          "comeback_factor": 0,
          "momentum_avg": 76
        }
      },
      "battler_b": {
        "skill": {
          "bars_quality": 72,
          "style_mastery": 80,
          "multisyllabics": 75,
          "freestyle_precision": 78,
          "scheme_complexity": 70
        },
        "momentum": {
          "win_streak_updated": 0,
          "crowd_reaction_trend": "stable",
          "comeback_factor": 45,
          "momentum_avg": 68
        }
      }
    },
    "neon_vault_hash": "0xabc123...",
    "immutable": true
  }
}
```

---

## Transparency Features

### Public Scoring Dashboard
After each battle, public can view:
- Complete scoring breakdown
- Individual judge cards
- Crowd reaction heatmap
- Bar Intelligence metrics
- Momentum graph visualization

### Judge Performance Tracking
- Historical scoring patterns
- Agreement rate with other judges
- Community rating
- Promotion/demotion system

## Technical Implementation

### Judging Service
```yaml
judging-service:
  type: microservice
  components:
    - human-judge-aggregator
    - crowd-ai-engine
    - bar-intelligence-engine
    - verdict-calculator
    - neon-vault-connector
  endpoints:
    - /judging/submit-score
    - /judging/calculate-verdict
    - /judging/get-breakdown
    - /judging/dispute
  real_time: true
  storage: neon_vault
```

### Real-Time Processing
During battle:
1. Human judges submit scores via interface
2. Crowd AI continuously aggregates reactions
3. Bar Intelligence Engine analyzes bars in real-time
4. System calculates running momentum
5. Round ends, verdict calculated
6. Verdict stored to Neon Vault
7. Results broadcast to arena

## Judge Recruitment

### Becoming a Judge
Qualified candidates:
- Legacy or retired champion battlers
- Industry professionals (verified)
- High-reputation community members
- Must pass judge training
- Minimum 50 battles spectated

### Judge Compensation
- NexCoin per battle judged
- Reputation score bonuses
- Access to exclusive events
- Potential promotion to Senior Judge

## Quality Assurance

### Calibration
- Regular judge calibration sessions
- Comparison against consensus
- Training on edge cases
- Feedback from community

### Crowd AI Tuning
- Regular model updates
- Regional preference learning
- Bot detection improvements
- Sentiment accuracy tracking

### Bar Intelligence Updates
- Database expansion with new battles
- Pattern recognition improvements
- Killshot detection refinement
- Originality scoring enhancements

## Future Enhancements

- **Celebrity Guest Judges**: Special events
- **AI Commentary**: Real-time analysis narration
- **Predictive Modeling**: Pre-battle projections
- **Historical Comparisons**: Cross-era analysis
- **Judging Academy**: Training program for new judges

---

**Status**: Phase 3 Implementation Ready  
**Dependencies**: Neon Vault, Crowd AI Service, Bar Intelligence Engine  
**Integration**: Native v-COS Module
