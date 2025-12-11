# Failover Plan

## Overview

Procedures for handling service failures and ensuring high availability.

## Automatic Failover

### Kubernetes Self-Healing

Kubernetes automatically:
- Restarts crashed containers
- Replaces unhealthy pods
- Reschedules pods on healthy nodes
- Manages load balancing

### Health Checks Configuration
```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 3000
  initialDelaySeconds: 30
  periodSeconds: 10
  
readinessProbe:
  httpGet:
    path: /health/ready
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Database Failover

### PostgreSQL High Availability

#### Primary Failure Detection
```bash
# Check primary status
kubectl exec -n database postgresql-0 -- \
  psql -U postgres -c "SELECT pg_is_in_recovery();"
```

#### Promote Replica
```bash
# Promote standby to primary
kubectl exec -n database postgresql-1 -- \
  pg_ctl promote -D /var/lib/postgresql/data
```

#### Update Connection Strings
```bash
# Update service endpoints
kubectl patch service postgresql -p \
  '{"spec":{"selector":{"role":"primary","statefulset.kubernetes.io/pod-name":"postgresql-1"}}}'
```

## Redis Failover

### Redis Sentinel
- Automatic master detection
- Automatic failover
- Configuration provider

```bash
# Check sentinel status
redis-cli -h sentinel -p 26379 SENTINEL get-master-addr-by-name mymaster
```

## Load Balancer Failover

### Multiple Load Balancer Instances
- Active-active configuration
- Health check-based routing
- DNS failover

### Traffic Shifting
```bash
# Update DNS to backup LB
aws route53 change-resource-record-sets \
  --hosted-zone-id <zone-id> \
  --change-batch file://failover-dns.json
```

## Multi-Region Failover

### Cross-Region Setup
- Primary region: us-east-1
- Secondary region: us-west-2
- Tertiary region: eu-central-1

### Regional Failover Procedure

1. **Detect Regional Failure**
```bash
# Check regional health
./scripts/check-region-health.sh us-east-1
```

2. **Activate Secondary Region**
```bash
# Scale up secondary region
kubectl scale deployment <service> --replicas=10 -n <namespace> --context=us-west-2

# Update DNS
./scripts/update-dns.sh us-west-2
```

3. **Verify Traffic Shift**
```bash
# Monitor traffic
./scripts/monitor-traffic.sh
```

4. **Data Replication**
```bash
# Verify data sync
./scripts/verify-replication.sh
```

## Service Dependencies

### Circuit Breaker Pattern
```javascript
const breaker = new CircuitBreaker(asyncFunction, {
  timeout: 3000,
  errorThresholdPercentage: 50,
  resetTimeout: 30000
});

breaker.fallback(() => {
  return cachedData;
});
```

### Graceful Degradation
- Return cached data
- Disable non-critical features
- Show user-friendly errors

## Communication Plan

### During Failover

1. **Immediate** (0-5 min)
   - Alert on-call team
   - Start incident log
   - Begin failover procedure

2. **Short-term** (5-15 min)
   - Notify stakeholders
   - Post status update
   - Continue failover

3. **Ongoing** (15+ min)
   - Regular status updates (every 15 min)
   - Monitor system health
   - Prepare recovery plan

### After Failover

1. Verify system stability
2. Conduct post-mortem
3. Update documentation
4. Implement preventive measures

## Testing Failover

### Monthly Failover Drill
```bash
# Schedule failover test
./scripts/failover-drill.sh

# Test steps:
# 1. Simulate primary failure
# 2. Verify automatic failover
# 3. Check data consistency
# 4. Measure recovery time
# 5. Restore primary
# 6. Document results
```

## Recovery Procedures

### Restore Primary Service
```bash
# 1. Fix primary issue
# 2. Sync data from secondary
# 3. Verify health
kubectl get pods -n <namespace>

# 4. Gradually shift traffic back
# 5. Monitor for issues
```

## Best Practices

1. Regular failover testing
2. Automate failover procedures
3. Monitor continuously
4. Keep runbooks updated
5. Clear communication
6. Document everything
7. Post-mortem analysis
8. Continuous improvement
