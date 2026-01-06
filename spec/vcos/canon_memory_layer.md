# N3XUS v-COS Canon Memory Layer

**Version:** 1.0.0  
**Status:** Canonical  
**Handshake:** 55-45-17  
**Date:** January 2026

---

## Overview

The Canon Memory Layer serves as the authoritative, persistent storage system for N3XUS v-COS. It maintains the canonical state of all entities, handles contradiction resolution in emergent canon, and provides the foundation for world state continuity across the distributed ecosystem.

---

## Core Concepts

### Canon Definition

**Canon** refers to the authoritative, accepted state and history of the v-COS ecosystem.

**Definition:**
> Canon is the immutable, versioned record of all verified state changes, entity relationships, and system events within N3XUS v-COS, serving as the single source of truth.

**Properties:**
- **Immutability:** Once recorded, canonical entries cannot be modified
- **Versioning:** All entries are versioned with monotonically increasing version numbers
- **Auditability:** Complete history preserved with cryptographic verification
- **Authority:** Canon supersedes all other data sources in case of conflict
- **Accessibility:** Available to all authorized components via standardized API

### Emergent Canon

**Emergent Canon** represents state and relationships that arise from system interactions but may contain contradictions requiring resolution.

**Sources:**
- User-generated content and interactions
- System-generated events and metrics
- Cross-module state synchronization
- External integrations and imports
- Distributed consensus protocols

---

## Architecture

### Storage Layers

#### Primary Layer: Canonical Database

**Technology:** PostgreSQL 15+ with JSONB support

**Schema Structure:**
```sql
-- Core canonical state table
CREATE TABLE canon_state (
  id BIGSERIAL PRIMARY KEY,
  entity_id VARCHAR(255) UNIQUE NOT NULL,
  entity_type VARCHAR(100) NOT NULL,
  state_version BIGINT NOT NULL DEFAULT 1,
  state_data JSONB NOT NULL,
  state_schema_version VARCHAR(20) NOT NULL,
  handshake VARCHAR(20) DEFAULT '55-45-17',
  checksum VARCHAR(64) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  created_by VARCHAR(255),
  updated_at TIMESTAMP DEFAULT NOW(),
  updated_by VARCHAR(255),
  metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_canon_entity_type ON canon_state(entity_type);
CREATE INDEX idx_canon_updated_at ON canon_state(updated_at DESC);
CREATE INDEX idx_canon_handshake ON canon_state(handshake);

-- State change history
CREATE TABLE canon_history (
  id BIGSERIAL PRIMARY KEY,
  entity_id VARCHAR(255) NOT NULL,
  state_version BIGINT NOT NULL,
  previous_state JSONB,
  new_state JSONB NOT NULL,
  change_type VARCHAR(50) NOT NULL, -- 'create', 'update', 'delete'
  change_timestamp TIMESTAMP DEFAULT NOW(),
  change_actor VARCHAR(255),
  change_reason TEXT,
  change_metadata JSONB DEFAULT '{}'::jsonb,
  handshake VARCHAR(20) DEFAULT '55-45-17',
  FOREIGN KEY (entity_id) REFERENCES canon_state(entity_id)
);

CREATE INDEX idx_history_entity_id ON canon_history(entity_id);
CREATE INDEX idx_history_timestamp ON canon_history(change_timestamp DESC);

-- Contradiction tracking
CREATE TABLE canon_contradictions (
  id BIGSERIAL PRIMARY KEY,
  entity_id VARCHAR(255) NOT NULL,
  contradiction_type VARCHAR(100) NOT NULL,
  conflicting_states JSONB NOT NULL,
  detected_at TIMESTAMP DEFAULT NOW(),
  detected_by VARCHAR(255),
  resolution_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'resolved', 'escalated'
  resolution_strategy VARCHAR(100),
  resolved_at TIMESTAMP,
  resolved_by VARCHAR(255),
  resolution_data JSONB,
  metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_contradictions_status ON canon_contradictions(resolution_status);
CREATE INDEX idx_contradictions_type ON canon_contradictions(contradiction_type);
```

#### Secondary Layer: Event Store

**Technology:** PostgreSQL with append-only event log

**Schema:**
```sql
CREATE TABLE canon_events (
  event_id BIGSERIAL PRIMARY KEY,
  aggregate_id VARCHAR(255) NOT NULL,
  aggregate_type VARCHAR(100) NOT NULL,
  event_type VARCHAR(100) NOT NULL,
  event_version INT NOT NULL,
  event_data JSONB NOT NULL,
  event_metadata JSONB DEFAULT '{}'::jsonb,
  handshake VARCHAR(20) DEFAULT '55-45-17',
  occurred_at TIMESTAMP DEFAULT NOW(),
  recorded_at TIMESTAMP DEFAULT NOW(),
  causation_id VARCHAR(255),
  correlation_id VARCHAR(255)
);

CREATE INDEX idx_events_aggregate ON canon_events(aggregate_id);
CREATE INDEX idx_events_type ON canon_events(event_type);
CREATE INDEX idx_events_occurred ON canon_events(occurred_at DESC);
```

#### Tertiary Layer: Snapshot Store

**Technology:** PostgreSQL with periodic state snapshots

**Purpose:** Optimize state reconstruction by storing periodic snapshots

**Schema:**
```sql
CREATE TABLE canon_snapshots (
  snapshot_id BIGSERIAL PRIMARY KEY,
  aggregate_id VARCHAR(255) NOT NULL,
  aggregate_version BIGINT NOT NULL,
  snapshot_data JSONB NOT NULL,
  snapshot_timestamp TIMESTAMP DEFAULT NOW(),
  snapshot_checksum VARCHAR(64) NOT NULL,
  handshake VARCHAR(20) DEFAULT '55-45-17'
);

CREATE INDEX idx_snapshots_aggregate ON canon_snapshots(aggregate_id, aggregate_version DESC);
```

---

## Contradiction Handling

### Contradiction Types

#### Type 1: Temporal Contradictions

**Definition:** State changes occur out of chronological order due to network delays or clock skew.

**Example:**
- Event A (timestamp: 10:00:05) arrives after Event B (timestamp: 10:00:10)
- Both attempt to modify the same entity

**Detection:**
```javascript
function detectTemporalContradiction(existingState, newState) {
  if (newState.timestamp < existingState.timestamp && 
      existingState.state_version > newState.state_version) {
    return {
      type: 'temporal',
      severity: 'medium',
      conflictingStates: { existing: existingState, incoming: newState }
    };
  }
  return null;
}
```

**Resolution Strategy:**
1. **Lamport Timestamp:** Use logical clocks instead of wall-clock time
2. **Version Ordering:** Prioritize state version over timestamp
3. **Causal Ordering:** Maintain causality chains to determine true order

#### Type 2: Concurrent Modifications

**Definition:** Multiple actors modify the same entity simultaneously.

**Example:**
- User A updates profile name at 10:00:00
- User B updates profile name at 10:00:00
- Both reach canon layer with version 5

**Detection:**
```javascript
function detectConcurrentModification(entity_id, version) {
  const existingVersion = await canonLayer.getStateVersion(entity_id);
  if (existingVersion === version) {
    // Another update is already being processed
    return {
      type: 'concurrent',
      severity: 'high',
      entity_id,
      version
    };
  }
  return null;
}
```

**Resolution Strategy:**
1. **Optimistic Locking:** Reject update, require client to retry with new version
2. **Last-Write-Wins:** Use timestamp to determine winner (simple but lossy)
3. **Merge:** Attempt automatic merge of non-conflicting fields
4. **User Prompt:** Escalate to user for manual resolution

#### Type 3: Semantic Contradictions

**Definition:** State changes violate business rules or logical constraints.

**Example:**
- User account marked as both 'active' and 'deleted'
- Service endpoint registered on multiple ports simultaneously
- Entity references non-existent parent

**Detection:**
```javascript
function detectSemanticContradiction(state) {
  const contradictions = [];
  
  // Check for logical impossibilities
  if (state.status === 'active' && state.deleted_at !== null) {
    contradictions.push({
      type: 'semantic',
      severity: 'critical',
      rule: 'active_deleted_mutual_exclusion',
      message: 'Entity cannot be both active and deleted'
    });
  }
  
  // Check referential integrity
  if (state.parent_id && !entityExists(state.parent_id)) {
    contradictions.push({
      type: 'semantic',
      severity: 'critical',
      rule: 'referential_integrity',
      message: 'Parent entity does not exist'
    });
  }
  
  return contradictions;
}
```

**Resolution Strategy:**
1. **Validation Rules:** Enforce strict validation before accepting state changes
2. **Constraint Checking:** Verify constraints at write time
3. **Repair Logic:** Attempt automatic repair (e.g., null invalid references)
4. **Rejection:** Reject contradictory state changes with clear error messages

#### Type 4: Cross-Domain Contradictions

**Definition:** Contradictory information across different domains or modules.

**Example:**
- v-auth shows user as 'suspended'
- v-platform shows same user as 'active'
- v-content allows user to upload files

**Detection:**
```javascript
async function detectCrossDomainContradiction(entity_id) {
  const states = await Promise.all([
    vAuth.getState(entity_id),
    vPlatform.getState(entity_id),
    vContent.getState(entity_id)
  ]);
  
  const statuses = states.map(s => s.status);
  const uniqueStatuses = new Set(statuses);
  
  if (uniqueStatuses.size > 1) {
    return {
      type: 'cross_domain',
      severity: 'high',
      conflictingStates: states
    };
  }
  
  return null;
}
```

**Resolution Strategy:**
1. **Authoritative Domain:** Designate one domain as authoritative for specific attributes
2. **Synchronization Protocol:** Force sync from authoritative to dependent domains
3. **Event Propagation:** Ensure state change events propagate to all domains
4. **Reconciliation Job:** Periodic job to detect and fix cross-domain contradictions

---

## Contradiction Resolution Protocols

### Protocol 1: Automatic Resolution

**Applicability:** Low-severity, deterministic contradictions

**Process:**
1. Detect contradiction
2. Apply resolution strategy based on contradiction type
3. Record resolution in contradiction log
4. Update canonical state
5. Notify affected services

**Example Implementation:**
```javascript
async function autoResolveContradiction(contradiction) {
  const strategy = resolutionStrategies[contradiction.type];
  
  if (!strategy || strategy.requiresManual) {
    return false; // Cannot auto-resolve
  }
  
  const resolvedState = await strategy.resolve(contradiction);
  
  await canonLayer.updateState(
    contradiction.entity_id,
    resolvedState,
    { resolution: contradiction.id }
  );
  
  await contradictionLog.markResolved(contradiction.id, {
    strategy: strategy.name,
    resolved_at: new Date(),
    resolved_by: 'auto-resolver'
  });
  
  return true;
}
```

### Protocol 2: Manual Resolution

**Applicability:** High-severity or complex contradictions

**Process:**
1. Detect contradiction
2. Create resolution task
3. Assign to qualified operator
4. Present conflicting states with context
5. Accept operator's resolution
6. Apply resolution to canonical state
7. Propagate resolution to affected components

**Resolution Interface:**
```javascript
{
  contradiction_id: "123456",
  entity_id: "user-abc-123",
  type: "concurrent_modification",
  severity: "high",
  detected_at: "2026-01-06T21:00:00Z",
  states: [
    { version: 5, data: { name: "John Doe", email: "john@example.com" }},
    { version: 5, data: { name: "Johnny Doe", email: "johnny@example.com" }}
  ],
  resolution_options: [
    { id: "accept_first", label: "Accept first update" },
    { id: "accept_second", label: "Accept second update" },
    { id: "merge", label: "Merge both updates" },
    { id: "custom", label: "Provide custom resolution" }
  ]
}
```

### Protocol 3: Escalation

**Applicability:** Critical contradictions requiring expert review

**Process:**
1. Detect critical contradiction
2. Mark as 'escalated' in contradiction log
3. Notify on-call engineer
4. Provide full context and diagnostic data
5. Engineer investigates root cause
6. Engineer provides resolution or mitigation
7. Resolution applied and verified
8. Incident report generated

**Escalation Criteria:**
- Affects critical system functionality
- Impacts multiple entities or domains
- Repeated occurrence of same contradiction type
- Security implications detected
- Data loss risk identified

---

## Canon API

### Write Operations

#### Create Entity State

```javascript
POST /canon/state
Headers:
  X-N3XUS-Handshake: 55-45-17
  Authorization: Bearer {token}

Body:
{
  "entity_id": "user-abc-123",
  "entity_type": "user",
  "state_data": {
    "name": "John Doe",
    "email": "john@example.com",
    "status": "active"
  },
  "metadata": {
    "source": "v-auth",
    "created_via": "api"
  }
}

Response:
{
  "success": true,
  "entity_id": "user-abc-123",
  "state_version": 1,
  "checksum": "sha256:abc123...",
  "created_at": "2026-01-06T21:00:00Z"
}
```

#### Update Entity State

```javascript
PUT /canon/state/{entity_id}
Headers:
  X-N3XUS-Handshake: 55-45-17
  Authorization: Bearer {token}

Body:
{
  "expected_version": 5, // Optimistic locking
  "state_data": {
    "name": "John Doe",
    "email": "newemail@example.com",
    "status": "active"
  },
  "change_reason": "User updated email address"
}

Response:
{
  "success": true,
  "entity_id": "user-abc-123",
  "state_version": 6,
  "previous_version": 5,
  "checksum": "sha256:def456...",
  "updated_at": "2026-01-06T21:05:00Z"
}
```

### Read Operations

#### Get Current State

```javascript
GET /canon/state/{entity_id}
Headers:
  X-N3XUS-Handshake: 55-45-17
  Authorization: Bearer {token}

Response:
{
  "entity_id": "user-abc-123",
  "entity_type": "user",
  "state_version": 6,
  "state_data": {
    "name": "John Doe",
    "email": "newemail@example.com",
    "status": "active"
  },
  "checksum": "sha256:def456...",
  "updated_at": "2026-01-06T21:05:00Z"
}
```

#### Get State History

```javascript
GET /canon/state/{entity_id}/history?from_version=1&to_version=6
Headers:
  X-N3XUS-Handshake: 55-45-17
  Authorization: Bearer {token}

Response:
{
  "entity_id": "user-abc-123",
  "history": [
    {
      "version": 1,
      "state_data": {...},
      "change_type": "create",
      "changed_at": "2026-01-06T20:00:00Z",
      "changed_by": "system"
    },
    // ... more history entries
    {
      "version": 6,
      "state_data": {...},
      "change_type": "update",
      "changed_at": "2026-01-06T21:05:00Z",
      "changed_by": "user-abc-123"
    }
  ]
}
```

### Contradiction Operations

#### Get Pending Contradictions

```javascript
GET /canon/contradictions?status=pending&severity=high
Headers:
  X-N3XUS-Handshake: 55-45-17
  Authorization: Bearer {token}

Response:
{
  "contradictions": [
    {
      "id": "123456",
      "entity_id": "user-xyz-789",
      "type": "concurrent_modification",
      "severity": "high",
      "detected_at": "2026-01-06T21:10:00Z",
      "conflicting_states": [...]
    }
  ],
  "total": 1,
  "page": 1
}
```

#### Resolve Contradiction

```javascript
POST /canon/contradictions/{id}/resolve
Headers:
  X-N3XUS-Handshake: 55-45-17
  Authorization: Bearer {token}

Body:
{
  "resolution_strategy": "accept_first",
  "resolution_data": {...},
  "resolution_reason": "First update is more recent"
}

Response:
{
  "success": true,
  "contradiction_id": "123456",
  "resolved_at": "2026-01-06T21:15:00Z",
  "new_state_version": 7
}
```

---

## Performance and Scalability

### Optimization Strategies

1. **Read Replicas:** Deploy read replicas for query load distribution
2. **Partitioning:** Partition tables by entity_type or time range
3. **Indexing:** Comprehensive indexing on frequently queried fields
4. **Caching:** Cache frequently accessed canonical states in Redis
5. **Batch Operations:** Support bulk write operations for efficiency

### Monitoring

**Key Metrics:**
- Write latency (p50, p95, p99)
- Read latency (p50, p95, p99)
- Contradiction detection rate
- Contradiction resolution rate
- Replication lag
- Database connection pool utilization

**Alerting:**
- Write latency p95 >100ms: Warning
- Contradiction resolution backlog >100: Warning
- Replication lag >10 seconds: Critical
- Database connection pool >80%: Warning

---

## Backup and Recovery

### Backup Strategy

**Full Backup:** Daily at 2 AM UTC
**Incremental Backup:** Hourly
**Transaction Log Backup:** Continuous (WAL archiving)

**Retention Policy:**
- Daily backups: 30 days
- Weekly backups: 12 weeks
- Monthly backups: 12 months

### Recovery Procedures

**Point-in-Time Recovery:**
1. Restore most recent full backup
2. Apply incremental backups
3. Replay transaction logs to target time
4. Verify data integrity
5. Bring system online

**Disaster Recovery:**
- RTO (Recovery Time Objective): 1 hour
- RPO (Recovery Point Objective): 5 minutes
- Automated failover to standby region
- Regular DR drills quarterly

---

## References

- [v-COS Ontology](./ontology.md)
- [Behavioral Primitives](./behavioral_primitives.md)
- [World State Continuity](./world_state_continuity.md)
- [Governance Charter](../../GOVERNANCE_CHARTER_55_45_17.md)

---

**Maintained By:** N3XUS Data Team  
**Last Updated:** January 2026  
**Status:** Canonical Reference
