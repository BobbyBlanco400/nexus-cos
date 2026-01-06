# N3XUS v-COS Behavioral Primitives

**Version:** 1.0.0  
**Status:** Canonical  
**Handshake:** 55-45-17  
**Date:** January 2026

---

## Overview

Behavioral Primitives define the fundamental operational units and interaction patterns within N3XUS v-COS. This document specifies the lifecycle rules for Interactive Multi-Verse Units (IMVUs) and Interactive Multi-Component Units (IMCUs), along with their coordination, state management, and behavioral protocols.

---

## Core Concepts

### Interactive Multi-Verse Unit (IMVU)

An **IMVU** is a runtime entity that encapsulates a complete operational context within v-COS. IMVUs are the primary execution units that host services, manage state, and coordinate interactions.

**Definition:**
> An IMVU is a sovereign runtime container that provides an isolated execution environment with persistent identity, managed lifecycle, and handshake-verified interactions.

**Characteristics:**
- **Sovereignty:** Independent execution context
- **Persistence:** Maintains state across restarts
- **Identity:** Unique identifier and registration
- **Isolation:** Resource and security boundaries
- **Coordination:** Communicates via handshake protocol

### Interactive Multi-Component Unit (IMCU)

An **IMCU** is a logical grouping of related components that work together to provide cohesive functionality within an IMVU.

**Definition:**
> An IMCU is a composite unit that aggregates multiple components into a functional module, managing their collective behavior and state consistency.

**Characteristics:**
- **Composition:** Multiple components working as a unit
- **Cohesion:** Shared purpose and tight coupling
- **Encapsulation:** Internal complexity hidden from external consumers
- **Coordination:** Internal state synchronization
- **Interface:** Well-defined external API

---

## IMVU Lifecycle

### Phase 1: Genesis

**Trigger:** IMVU creation request with valid handshake

**Actions:**
1. Validate handshake credentials (`55-45-17`)
2. Generate unique IMVU identifier
3. Allocate computational resources
4. Initialize isolated runtime environment
5. Register IMVU in Canon Memory Layer
6. Set initial state to `GENESIS`

**Success Criteria:**
- IMVU ID assigned and registered
- Resources allocated successfully
- Initial state persisted to canon

**Failure Handling:**
- Rollback resource allocation
- Log genesis failure with diagnostic data
- Return error with failure reason

### Phase 2: Configuration

**Trigger:** IMVU state = `GENESIS` and configuration payload provided

**Actions:**
1. Validate configuration schema
2. Load environment variables and secrets
3. Initialize network interfaces on n3xus-net
4. Configure service dependencies
5. Set up monitoring and logging
6. Transition state to `CONFIGURED`

**Success Criteria:**
- Configuration schema validated
- Dependencies resolved and accessible
- Network connectivity established
- Monitoring active

**Failure Handling:**
- Log configuration errors
- Attempt auto-recovery with default values
- Escalate if critical configuration missing
- Maintain `GENESIS` state until resolved

### Phase 3: Activation

**Trigger:** IMVU state = `CONFIGURED` and activation signal received

**Actions:**
1. Verify all dependencies are operational
2. Execute startup routines
3. Initialize internal components (IMCUs)
4. Establish communication channels
5. Register service endpoints
6. Perform health check
7. Transition state to `ACTIVE`

**Success Criteria:**
- All health checks pass
- Service endpoints responding
- Dependencies confirmed accessible
- Handshake verification successful

**Failure Handling:**
- Retry activation up to 3 times
- Log activation failures
- Enter `DEGRADED` state if partial activation
- Enter `FAILED` state if complete failure

### Phase 4: Operation

**Trigger:** IMVU state = `ACTIVE`

**Actions:**
1. Process incoming requests
2. Execute business logic
3. Manage internal state
4. Coordinate with other IMVUs
5. Emit telemetry and logs
6. Respond to health checks
7. Handle state transitions

**Operational Rules:**
- Every request must include handshake header
- All state changes persisted to canon
- Errors logged with full context
- Graceful degradation on dependency failures
- Circuit breaker pattern for external calls

**State Transitions:**
- `ACTIVE` → `DEGRADED`: Partial functionality available
- `ACTIVE` → `MAINTENANCE`: Scheduled maintenance mode
- `ACTIVE` → `SUSPENDED`: Temporary suspension requested
- `ACTIVE` → `TERMINATING`: Shutdown initiated

### Phase 5: Evolution

**Trigger:** Configuration update or version upgrade requested

**Actions:**
1. Validate new configuration/version
2. Create checkpoint of current state
3. Transition to `EVOLVING` state
4. Apply changes incrementally
5. Verify changes through health checks
6. Transition to `ACTIVE` if successful
7. Rollback to checkpoint if failed

**Evolution Types:**
- **Configuration Update:** Runtime config changes
- **Version Upgrade:** Service version update
- **Dependency Change:** Dependency version or endpoint change
- **Resource Scaling:** Resource allocation adjustment

**Success Criteria:**
- Changes applied without service disruption
- Health checks pass post-evolution
- State consistency maintained
- No data loss or corruption

**Failure Handling:**
- Automatic rollback to checkpoint
- Log evolution failure details
- Notify operators of failed evolution
- Remain in previous stable state

### Phase 6: Suspension

**Trigger:** IMVU suspension requested or resource constraints detected

**Actions:**
1. Reject new incoming requests
2. Complete in-flight requests
3. Persist current state to canon
4. Release non-essential resources
5. Maintain minimal monitoring
6. Transition state to `SUSPENDED`

**Resume Process:**
1. Validate resume conditions
2. Restore state from canon
3. Re-acquire resources
4. Re-establish connections
5. Transition to `ACTIVE`

### Phase 7: Termination

**Trigger:** IMVU termination requested or critical failure detected

**Actions:**
1. Transition state to `TERMINATING`
2. Reject new incoming requests
3. Complete or abort in-flight requests
4. Persist final state to canon
5. Close all connections
6. Release all resources
7. Deregister service endpoints
8. Transition state to `TERMINATED`

**Graceful Shutdown Time:** 30 seconds default (configurable)

**Force Termination:** After grace period expires

**Post-Termination:**
- Final state archived in canon
- Logs and metrics preserved
- IMVU marked as terminated in registry

---

## IMCU Lifecycle

### Phase 1: Initialization

**Trigger:** Parent IMVU enters `CONFIGURED` state

**Actions:**
1. Load IMCU definition from configuration
2. Instantiate component instances
3. Establish inter-component communication
4. Register IMCU within IMVU context
5. Transition state to `INITIALIZED`

### Phase 2: Synchronization

**Trigger:** IMCU state = `INITIALIZED` and parent IMVU activating

**Actions:**
1. Synchronize component states
2. Establish data consistency
3. Configure component interactions
4. Validate collective health
5. Transition state to `SYNCED`

### Phase 3: Operational

**Trigger:** IMCU state = `SYNCED` and parent IMVU = `ACTIVE`

**Actions:**
1. Process requests as a coordinated unit
2. Maintain state consistency across components
3. Handle component-level failures gracefully
4. Propagate events to interested components
5. Report collective health status

**Coordination Patterns:**
- **Leader-Follower:** One component coordinates others
- **Peer-to-Peer:** Components coordinate as equals
- **Pipeline:** Sequential processing across components
- **Parallel:** Concurrent processing with aggregation

### Phase 4: Degradation

**Trigger:** One or more components fail or become unavailable

**Actions:**
1. Identify failed components
2. Assess impact on IMCU functionality
3. Attempt component recovery
4. Reconfigure remaining components
5. Operate with reduced functionality
6. Notify parent IMVU of degradation

**Degradation Levels:**
- **Minimal:** 95%+ functionality available
- **Moderate:** 75-95% functionality available
- **Severe:** 50-75% functionality available
- **Critical:** <50% functionality available

### Phase 5: Recovery

**Trigger:** Failed components restored or replacements available

**Actions:**
1. Verify component restoration
2. Re-synchronize component states
3. Re-establish inter-component communication
4. Validate collective health
5. Transition to `OPERATIONAL` state
6. Notify parent IMVU of recovery

### Phase 6: Termination

**Trigger:** Parent IMVU terminating or IMCU obsolete

**Actions:**
1. Gracefully stop component operations
2. Persist final component states
3. Close inter-component connections
4. Deregister from IMVU context
5. Transition state to `TERMINATED`

---

## Behavioral Protocols

### Handshake Protocol

**Header:** `X-N3XUS-Handshake: 55-45-17`

**Validation Rules:**
1. Header must be present on all inter-IMVU requests
2. Value must exactly match `55-45-17`
3. Missing or invalid handshake results in `401 Unauthorized`
4. Handshake verification occurs at gateway and service boundaries

**Implementation:**
```javascript
function verifyHandshake(request) {
  const handshake = request.headers['x-n3xus-handshake'];
  if (!handshake) {
    throw new UnauthorizedError('Handshake header missing');
  }
  if (handshake !== '55-45-17') {
    throw new UnauthorizedError('Invalid handshake value');
  }
  return true;
}
```

### State Transition Protocol

**Rules:**
1. All state transitions must be atomic
2. State changes must be persisted before acknowledgment
3. Invalid transitions must be rejected with clear error
4. State history must be maintained for audit

**Valid State Transitions:**
```
GENESIS → CONFIGURED → ACTIVE
ACTIVE ↔ DEGRADED
ACTIVE ↔ SUSPENDED
ACTIVE → EVOLVING → ACTIVE
ACTIVE → TERMINATING → TERMINATED
* → FAILED → TERMINATED
```

### Health Check Protocol

**Endpoint:** `/health`

**Response Format:**
```json
{
  "status": "healthy|degraded|unhealthy",
  "imvu_id": "v-prompter-api-001",
  "state": "ACTIVE",
  "handshake": "55-45-17",
  "timestamp": "2026-01-06T21:00:00Z",
  "checks": {
    "database": "healthy",
    "dependencies": "healthy",
    "resources": "healthy"
  }
}
```

**Health Check Frequency:** Every 30 seconds

**Timeout:** 5 seconds

**Failure Threshold:** 3 consecutive failures trigger state change

---

## Coordination Rules

### IMVU-to-IMVU Coordination

1. **Discovery:** IMVUs discover each other via service registry
2. **Connection:** Establish connection with handshake verification
3. **Communication:** Exchange messages with request/response pattern
4. **State Sharing:** Share relevant state updates via event bus
5. **Fault Tolerance:** Implement retry and circuit breaker patterns

### IMCU-to-IMCU Coordination (within IMVU)

1. **Direct Communication:** Components communicate directly within IMVU
2. **Shared State:** Access shared state store for consistency
3. **Event Broadcasting:** Broadcast events to interested components
4. **Synchronization:** Use locks or transactions for critical sections
5. **Failure Isolation:** Component failures don't cascade to others

---

## Advanced Specifications

### Resource Management

**Allocation:**
- CPU: Soft limit with burst capability
- Memory: Hard limit with OOM protection
- Storage: Quota-based with monitoring
- Network: Rate limiting per IMVU

**Monitoring:**
- Resource usage tracked per IMVU
- Alerts triggered on threshold violations
- Auto-scaling triggered based on metrics
- Resource reclamation on termination

### Error Handling

**Error Categories:**
1. **Transient Errors:** Retry with exponential backoff
2. **Permanent Errors:** Fail fast with clear messaging
3. **Dependency Errors:** Circuit breaker activation
4. **Resource Errors:** Trigger scaling or degradation

**Error Propagation:**
- Errors logged with full context
- Critical errors escalated to operators
- Error metrics tracked and alerted
- Root cause analysis performed

### Security

**Isolation:**
- Network isolation via n3xus-net
- Process isolation via containers
- Data isolation via tenancy
- Secret isolation via vault

**Authentication:**
- Handshake verification required
- Service identity via certificates
- Request authentication via tokens
- Audit logging enabled

---

## References

- [v-COS Ontology](./ontology.md)
- [World State Continuity](./world_state_continuity.md)
- [Canon Memory Layer](./canon_memory_layer.md)
- [Governance Charter](../../GOVERNANCE_CHARTER_55_45_17.md)

---

**Maintained By:** N3XUS Architecture Team  
**Last Updated:** January 2026  
**Status:** Canonical Reference
