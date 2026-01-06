# World State Continuity

**Version:** 1.0.0  
**Status:** Canonical  
**Handshake:** 55-45-17  
**Last Updated:** January 2026

---

## Overview

World State Continuity defines the rules, mechanisms, and protocols for maintaining consistent, coherent state across all V-COS entities, spaces, and temporal boundaries. This specification ensures that the "world" of N3XUS COS evolves predictably, preserves causality, and supports modular and distributed implementation while maintaining a unified experience.

---

## Core Principles

### 1. Causal Consistency

Every state change must have a clear causal relationship to prior events. The system maintains **happened-before** relationships to prevent paradoxes and ensure logical coherence.

### 2. Eventual Consistency

Given sufficient time and no new updates, all replicas of state will converge to the same value. This enables distributed implementation while maintaining world coherence.

### 3. Partition Tolerance

The system continues to operate even when network partitions occur, with defined reconciliation strategies for when partitions heal.

### 4. Observable Determinism

From any observer's perspective, the world behaves deterministically based on observable events, even if underlying implementation is distributed and asynchronous.

---

## State Model

### State Components

```
World State = {
  EntityStates,      // State of all entities (Creators, IMVUs, Artifacts)
  SpaceStates,       // State of all spaces
  RelationshipGraph, // Connections between entities
  EventHistory,      // Immutable log of all events
  DerivedState       // Computed views and aggregations
}
```

### State Types

#### 1. Persistent State
- Survives system restarts
- Stored in canon memory layer
- Examples: Creator profiles, artifacts, space configurations

#### 2. Session State
- Exists for duration of a session
- Cleared on session end
- Examples: Active websocket connections, temporary workspaces

#### 3. Cache State
- Derived from persistent state
- Can be regenerated if lost
- Examples: Computed metrics, search indices

#### 4. Transient State
- Very short-lived (seconds to minutes)
- Not persisted
- Examples: In-flight requests, UI state

---

## State Transitions

### Transition Rules

**Rule ST-1: Atomic Updates**
- State changes are atomic within an entity
- Multi-entity updates use distributed transactions or eventual consistency

**Rule ST-2: Idempotency**
- Repeated application of the same update produces the same result
- Enables safe retries and replay

**Rule ST-3: Versioning**
- Every state change increments a version number
- Enables conflict detection and resolution

**Rule ST-4: Audit Trail**
- Every state change is recorded in event history
- Enables time-travel debugging and replay

### State Transition Protocol

```
function transitionState(entity, update):
  // 1. Verify handshake
  if not verifyHandshake(update):
    return Error("Invalid handshake")
  
  // 2. Acquire lock (optimistic or pessimistic)
  lock = acquireLock(entity.id)
  
  // 3. Validate transition
  currentVersion = entity.version
  if update.expectedVersion != currentVersion:
    releaseLock(lock)
    return Error("Version conflict")
  
  // 4. Apply update
  newState = applyUpdate(entity, update)
  
  // 5. Validate constraints
  if not validateConstraints(newState):
    releaseLock(lock)
    return Error("Constraint violation")
  
  // 6. Persist to canon memory layer
  event = createEvent(entity, currentVersion, newState)
  persistEvent(event)
  
  // 7. Update entity
  entity.state = newState
  entity.version = currentVersion + 1
  
  // 8. Release lock
  releaseLock(lock)
  
  // 9. Broadcast update
  broadcastUpdate(entity.id, event)
  
  return Success(newState)
```

---

## Distributed State Management

### Architecture

```
┌─────────────────────────────────────┐
│     Canon Memory Layer (Source)    │
│  (PostgreSQL + Event Store)        │
└─────────────┬───────────────────────┘
              │
              ├──────────────┬──────────────┐
              │              │              │
        ┌─────▼────┐   ┌────▼─────┐  ┌────▼─────┐
        │ Service  │   │ Service  │  │ Service  │
        │  Node 1  │   │  Node 2  │  │  Node 3  │
        │          │   │          │  │          │
        │ (Cache)  │   │ (Cache)  │  │ (Cache)  │
        └──────────┘   └──────────┘  └──────────┘
```

### Consistency Guarantees

#### Strong Consistency (Synchronous)
- Used for: Creator authentication, permissions, financial transactions
- Protocol: Two-phase commit or Raft consensus
- Latency: Higher (100-500ms)

#### Eventual Consistency (Asynchronous)
- Used for: Social feeds, analytics, non-critical metadata
- Protocol: Event propagation with conflict resolution
- Latency: Lower (1-10ms local, seconds for propagation)

#### Causal Consistency (Hybrid)
- Used for: Creator collaborations, content versioning
- Protocol: Vector clocks or hybrid logical clocks
- Latency: Medium (10-100ms)

---

## Conflict Resolution

### Conflict Types

#### Type 1: Concurrent Updates
Two entities update the same state simultaneously

**Resolution Strategy:**
- Last-Write-Wins (LWW) with timestamp
- Application-specific merge (e.g., CRDT)
- Manual resolution for critical conflicts

#### Type 2: Causal Violations
An update references a state that hasn't occurred yet

**Resolution Strategy:**
- Buffer update until prerequisite state exists
- Reject update if prerequisite never arrives (timeout)
- Alert guardian IMVU for investigation

#### Type 3: Constraint Violations
An update would violate system constraints

**Resolution Strategy:**
- Reject update immediately
- Log violation for audit
- Notify originating entity of rejection

#### Type 4: Network Partitions
Disconnected nodes operate independently

**Resolution Strategy:**
- Each partition operates with local state
- On partition heal, use reconciliation protocol
- Preserve all divergent histories

### Reconciliation Protocol

```
function reconcileAfterPartition(partition1, partition2):
  // 1. Identify divergent events
  events1 = partition1.getEventsSince(splitTime)
  events2 = partition2.getEventsSince(splitTime)
  
  // 2. Merge event streams
  mergedEvents = []
  i1 = 0, i2 = 0
  
  while i1 < events1.length or i2 < events2.length:
    if i1 >= events1.length:
      mergedEvents.append(events2[i2])
      i2++
    else if i2 >= events2.length:
      mergedEvents.append(events1[i1])
      i1++
    else:
      // Both have events - order by timestamp
      if events1[i1].timestamp < events2[i2].timestamp:
        mergedEvents.append(events1[i1])
        i1++
      else:
        mergedEvents.append(events2[i2])
        i2++
  
  // 3. Detect conflicts
  conflicts = detectConflicts(mergedEvents)
  
  // 4. Resolve conflicts
  for conflict in conflicts:
    resolution = resolveConflict(conflict)
    mergedEvents = applyResolution(mergedEvents, resolution)
  
  // 5. Replay merged events
  canonicalState = replayEvents(initialState, mergedEvents)
  
  // 6. Update both partitions
  partition1.updateState(canonicalState)
  partition2.updateState(canonicalState)
  
  return canonicalState
```

---

## Modular Implementation Support

### Module Boundaries

V-COS supports modular implementation where different subsystems can be developed and deployed independently:

```
Modules:
├── Core (auth, spaces, entities)
├── V-Suite (creative tools)
├── PUABO (fleet, DSP, BLAC, NUKI)
├── Casino-Nexus (gaming)
├── Social (community, collaboration)
└── Analytics (metrics, insights)
```

### Inter-Module Communication

**Rule M-1: Loose Coupling**
- Modules communicate via events, not direct calls
- No module has compile-time dependency on another

**Rule M-2: API Contracts**
- Modules expose versioned APIs
- Breaking changes require new API version
- Old versions supported for grace period

**Rule M-3: Shared State**
- Shared state goes through canon memory layer
- No direct database sharing between modules

**Rule M-4: Event Bus**
- All cross-module communication via event bus
- Events include handshake header
- Event schemas versioned and validated

### Module State Isolation

Each module maintains its own state, but coordinates through the canon memory layer:

```
┌────────────────┐    ┌────────────────┐
│   V-Suite      │    │   PUABO        │
│   Module       │    │   Module       │
│                │    │                │
│ ┌────────────┐ │    │ ┌────────────┐ │
│ │Local State │ │    │ │Local State │ │
│ └─────┬──────┘ │    │ └─────┬──────┘ │
└───────┼────────┘    └───────┼────────┘
        │                     │
        └──────────┬──────────┘
                   │
         ┌─────────▼──────────┐
         │ Canon Memory Layer │
         │  (Shared Events)   │
         └────────────────────┘
```

---

## Temporal Consistency

### Time Model

**Timestamp Types:**
1. **Wall Clock Time**: Real-world UTC time
2. **Logical Clock**: Monotonically increasing counter
3. **Hybrid Clock**: Combination of wall clock and logical clock
4. **Vector Clock**: Per-node logical clocks (for distributed causality)

**Primary Timestamp:** Hybrid Logical Clock (HLC)

### Hybrid Logical Clock

```
HLC = {
  wallTime: UTC timestamp (microseconds),
  logicalCounter: Monotonic counter
}

function generateHLC(previousHLC, wallClock):
  newWallTime = max(wallClock, previousHLC.wallTime)
  
  if newWallTime == previousHLC.wallTime:
    newCounter = previousHLC.logicalCounter + 1
  else:
    newCounter = 0
  
  return HLC(newWallTime, newCounter)
```

**Properties:**
- Preserves causality (if event A caused event B, HLC(A) < HLC(B))
- Tolerates clock skew (uses logical counter when clocks equal)
- Globally orderable (can sort events across nodes)

### Event Ordering

**Total Order:** All events have a unique position in history

**Partial Order:** Some events are concurrent (no causal relationship)

**Ordering Rules:**
1. Events from same entity are totally ordered
2. Events with causal relationship are ordered by causality
3. Concurrent events are ordered by HLC, then by entity ID (tie-breaker)

---

## State Snapshots

### Snapshot Strategy

**Periodic Snapshots:**
- Full state snapshot every 1 hour (configurable)
- Enables fast recovery without replaying entire history
- Snapshots stored in canon memory layer

**On-Demand Snapshots:**
- Triggered for backup or migration
- Consistent across all modules
- Coordinated via snapshot coordinator

### Snapshot Protocol

```
function createSnapshot():
  // 1. Announce snapshot intent
  snapshotId = generateSnapshotId()
  broadcastMessage("snapshot_start", snapshotId)
  
  // 2. Wait for all modules to prepare
  waitForAcknowledgments(timeout=30s)
  
  // 3. Capture current HLC
  snapshotHLC = getCurrentHLC()
  
  // 4. Each module captures its state at HLC
  moduleStates = []
  for module in modules:
    state = module.captureStateAtHLC(snapshotHLC)
    moduleStates.append(state)
  
  // 5. Persist snapshot
  snapshot = {
    id: snapshotId,
    hlc: snapshotHLC,
    timestamp: wallClock(),
    moduleStates: moduleStates
  }
  persistSnapshot(snapshot)
  
  // 6. Announce completion
  broadcastMessage("snapshot_complete", snapshotId)
  
  return snapshot
```

### Snapshot Recovery

```
function recoverFromSnapshot(snapshotId):
  // 1. Load snapshot
  snapshot = loadSnapshot(snapshotId)
  
  // 2. Restore module states
  for moduleState in snapshot.moduleStates:
    module = getModule(moduleState.moduleName)
    module.restoreState(moduleState)
  
  // 3. Replay events since snapshot
  events = loadEventsSince(snapshot.hlc)
  for event in events:
    applyEvent(event)
  
  // 4. Verify consistency
  if not verifyConsistency():
    return Error("Consistency check failed")
  
  return Success()
```

---

## State Query Interface

### Query Types

#### Point Query
Retrieve state of a specific entity at current or past time

```
query getEntityState(entityId, hlc?):
  if hlc is null:
    return currentState[entityId]
  else:
    return replayToHLC(entityId, hlc)
```

#### Range Query
Retrieve all entities matching criteria

```
query findEntities(predicate, limit, offset):
  matches = []
  for entity in allEntities:
    if predicate(entity):
      matches.append(entity)
  
  return matches[offset:offset+limit]
```

#### Historical Query
Retrieve event history for an entity

```
query getHistory(entityId, startHLC, endHLC):
  events = []
  for event in eventStore:
    if event.entityId == entityId:
      if startHLC <= event.hlc <= endHLC:
        events.append(event)
  
  return events
```

#### Aggregate Query
Compute aggregation across entities

```
query aggregate(entities, aggregateFunction):
  result = aggregateFunction.init()
  for entity in entities:
    result = aggregateFunction.accumulate(result, entity)
  
  return aggregateFunction.finalize(result)
```

---

## State Persistence

### Persistence Layers

#### Layer 1: Event Store
- **Technology:** Append-only log (e.g., Kafka, PostgreSQL WAL)
- **Contains:** All state-changing events
- **Retention:** Indefinite (with archival)

#### Layer 2: State Database
- **Technology:** PostgreSQL (primary), Redis (cache)
- **Contains:** Current state of all entities
- **Retention:** Active data + configurable history

#### Layer 3: Snapshot Store
- **Technology:** Object storage (e.g., S3, MinIO)
- **Contains:** Periodic full-state snapshots
- **Retention:** Last 30 snapshots (30-90 days typically)

#### Layer 4: Archive
- **Technology:** Cold storage (e.g., Glacier, tape)
- **Contains:** Old events and snapshots
- **Retention:** Indefinite (compliance-dependent)

### Persistence Guarantees

**Durability:** Once acknowledged, writes survive single-node failures

**Consistency:** Reads reflect all acknowledged writes (with consistency level)

**Atomicity:** Multi-entity transactions are all-or-nothing

**Isolation:** Concurrent transactions don't interfere

---

## Implementation Guidelines

### For Distributed Systems Architects

1. Choose appropriate consistency level for each operation
2. Design event schemas for forward compatibility
3. Implement conflict resolution strategies
4. Plan for partition scenarios
5. Monitor clock skew across nodes

### For Module Developers

1. Emit events for all state changes
2. Subscribe to relevant events from other modules
3. Handle event replay correctly (idempotency)
4. Implement local caching for performance
5. Test with simulated network partitions

### For System Operators

1. Monitor event lag across modules
2. Watch for clock skew issues
3. Regularly test snapshot/restore procedures
4. Set appropriate consistency levels per workload
5. Maintain event retention policies

---

## References

- [V-COS Ontology](./ontology.md) - Entity definitions
- [Behavioral Primitives](./behavioral_primitives.md) - IMVU lifecycle and behaviors
- [Canon Memory Layer](./canon_memory_layer.md) - Historical truth and persistence

---

**State Status:** Canonical  
**Governance:** 55-45-17 Handshake Protocol  
**Maintained By:** N3XUS Platform Team  
**Last Review:** January 2026
