# N3XUS COS Feature Flags & Rollout

**Version:** 1.1.0  
**Status:** Canonical  
**Handshake:** 55-45-17  
**Date:** January 2026

---

## Overview

This document defines the feature flag system and gradual rollout strategy for N3XUS COS. Feature flags enable module-by-module activation, A/B testing, and safe deployment without disrupting the core platform or existing modules.

---

## Feature Flag System

### Flag Structure

```javascript
interface FeatureFlag {
  flag_id: string;              // Unique flag identifier
  module_id: string;            // Associated module
  name: string;                 // Human-readable name
  description: string;          // Flag purpose
  status: FlagStatus;           // alpha | beta | stable | deprecated
  enabled_modes: AccessMode[];  // hybrid | immersive | both
  rollout_percentage: number;   // 0-100
  targeting_rules: Rule[];      // User targeting rules
  dependencies: string[];       // Required flags
  created_at: Date;
  updated_at: Date;
  handshake: '55-45-17';
}

type FlagStatus = 'alpha' | 'beta' | 'stable' | 'deprecated';
type AccessMode = 'hybrid' | 'immersive';
```

### Flag Registry

All feature flags are registered in the central flag registry:

```javascript
const featureFlagRegistry = {
  // Creator's Hub (Canonical Template)
  'module.creators-hub.hybrid': {
    flag_id: 'module.creators-hub.hybrid',
    module_id: 'creators-hub',
    name: 'Creator\'s Hub - Hybrid Mode',
    status: 'stable',
    enabled_modes: ['hybrid'],
    rollout_percentage: 100,
    dependencies: []
  },
  
  'module.creators-hub.immersive': {
    flag_id: 'module.creators-hub.immersive',
    module_id: 'creators-hub',
    name: 'Creator\'s Hub - Immersive Mode',
    status: 'beta',
    enabled_modes: ['immersive'],
    rollout_percentage: 50,
    targeting_rules: [{ type: 'beta_tester', value: true }],
    dependencies: ['module.creators-hub.hybrid']
  },
  
  // Example: New module in alpha
  'module.puabo-ott-tv.hybrid': {
    flag_id: 'module.puabo-ott-tv.hybrid',
    module_id: 'puabo-ott-tv',
    name: 'PUABO OTT TV - Hybrid Mode',
    status: 'alpha',
    enabled_modes: ['hybrid'],
    rollout_percentage: 10,
    targeting_rules: [
      { type: 'user_id', value: ['user-123', 'user-456'] },
      { type: 'internal_team', value: true }
    ],
    dependencies: ['module.content-hub.hybrid']
  }
  
  // ... all 38 modules with hybrid and immersive flags
};
```

---

## Rollout Stages

### Stage 1: Alpha (Internal Testing)

**Target Audience:** Internal team only

**Rollout Percentage:** 0-10%

**Characteristics:**
- Feature may be incomplete
- Breaking changes expected
- Limited documentation
- Direct feedback loops
- Rapid iteration

**Activation Criteria:**
- Must be internal team member
- Explicit opt-in required
- Access revocable at any time

**Example:**
```javascript
{
  status: 'alpha',
  rollout_percentage: 10,
  targeting_rules: [
    { type: 'internal_team', value: true },
    { type: 'explicit_opt_in', value: true }
  ]
}
```

### Stage 2: Beta (Early Adopters)

**Target Audience:** Beta testers and early adopters

**Rollout Percentage:** 10-50%

**Characteristics:**
- Feature mostly complete
- Some changes still expected
- Basic documentation available
- Community feedback active
- Stability improvements ongoing

**Activation Criteria:**
- Beta tester status
- OR explicit opt-in
- OR gradual percentage rollout

**Example:**
```javascript
{
  status: 'beta',
  rollout_percentage: 30,
  targeting_rules: [
    { type: 'beta_tester', value: true },
    { type: 'random_percentage', value: 30 }
  ]
}
```

### Stage 3: Stable (General Availability)

**Target Audience:** All users

**Rollout Percentage:** 50-100%

**Characteristics:**
- Feature complete and tested
- No breaking changes expected
- Full documentation available
- Monitoring and alerting active
- Support team trained

**Activation Criteria:**
- Available to all users
- No restrictions

**Example:**
```javascript
{
  status: 'stable',
  rollout_percentage: 100,
  targeting_rules: []
}
```

### Stage 4: Deprecated

**Target Audience:** Existing users (no new users)

**Rollout Percentage:** Decreasing (100 → 0)

**Characteristics:**
- Feature being phased out
- Migration path available
- Sunset date announced
- Alternative recommended
- Support ending

**Activation Criteria:**
- Only users who already have access
- No new activations

---

## Flag Evaluation

### Evaluation Algorithm

```javascript
class FeatureFlagEvaluator {
  async evaluateFlag(flagId, userId, context) {
    // Fetch flag configuration
    const flag = await this.getFlag(flagId);
    
    if (!flag) {
      return { enabled: false, reason: 'flag_not_found' };
    }
    
    // Check status
    if (flag.status === 'deprecated') {
      const hasAccess = await this.hasDeprecatedAccess(userId, flagId);
      return { enabled: hasAccess, reason: 'deprecated' };
    }
    
    // Check dependencies
    for (const depId of flag.dependencies) {
      const depResult = await this.evaluateFlag(depId, userId, context);
      if (!depResult.enabled) {
        return { enabled: false, reason: 'dependency_not_met', dependency: depId };
      }
    }
    
    // Check targeting rules
    for (const rule of flag.targeting_rules) {
      const matches = await this.evaluateRule(rule, userId, context);
      if (matches) {
        return { enabled: true, reason: 'targeting_rule_match', rule: rule.type };
      }
    }
    
    // Check rollout percentage
    const userHash = this.hashUserId(userId, flagId);
    const inRollout = userHash < flag.rollout_percentage;
    
    return {
      enabled: inRollout,
      reason: inRollout ? 'rollout_percentage' : 'not_in_rollout',
      percentage: flag.rollout_percentage
    };
  }
  
  async evaluateRule(rule, userId, context) {
    switch (rule.type) {
      case 'user_id':
        return rule.value.includes(userId);
      
      case 'internal_team':
        return await this.isInternalTeam(userId);
      
      case 'beta_tester':
        return await this.isBetaTester(userId);
      
      case 'explicit_opt_in':
        return await this.hasOptedIn(userId, rule.flag_id);
      
      case 'random_percentage':
        return this.hashUserId(userId, rule.flag_id) < rule.value;
      
      case 'user_attribute':
        return await this.checkUserAttribute(userId, rule.attribute, rule.value);
      
      default:
        return false;
    }
  }
  
  hashUserId(userId, salt) {
    // Deterministic hash: same user + flag always gets same result
    // Returns number 0-100
    const hash = crypto.createHash('sha256');
    hash.update(`${userId}:${salt}`);
    const hex = hash.digest('hex');
    return parseInt(hex.substr(0, 8), 16) % 100;
  }
}
```

---

## Gradual Rollout Strategy

### Phase 1: Internal Validation (Week 1)

**Goal:** Validate module works in production environment

**Actions:**
1. Deploy module with feature flag disabled
2. Enable flag for internal team (alpha status)
3. Test all functionality in production
4. Monitor metrics and errors
5. Gather internal feedback
6. Fix critical issues

**Success Criteria:**
- Zero critical bugs
- All acceptance tests pass
- Performance within targets
- Internal team approval

### Phase 2: Early Adopters (Week 2-3)

**Goal:** Validate with real users, gather feedback

**Actions:**
1. Promote flag to beta status
2. Enable for beta testers (10% rollout)
3. Gradually increase to 30% over 2 weeks
4. Monitor adoption and engagement
5. Gather user feedback
6. Iterate on UX and features

**Success Criteria:**
- User satisfaction >70%
- Error rate <1%
- Performance acceptable
- Positive feedback from beta testers

### Phase 3: General Rollout (Week 4-6)

**Goal:** Roll out to all users

**Actions:**
1. Increase rollout to 50%
2. Monitor metrics closely
3. Address any issues quickly
4. Increase to 75%
5. Final push to 100%
6. Promote flag to stable status

**Success Criteria:**
- Error rate <0.1%
- Performance targets met
- User satisfaction >80%
- No critical incidents

### Phase 4: Optimization (Ongoing)

**Goal:** Optimize and enhance based on usage data

**Actions:**
1. Analyze usage patterns
2. Identify optimization opportunities
3. Implement improvements
4. A/B test enhancements
5. Roll out optimizations

---

## A/B Testing

### Test Configuration

```javascript
interface ABTest {
  test_id: string;
  name: string;
  variants: Variant[];
  allocation: AllocationStrategy;
  metrics: Metric[];
  start_date: Date;
  end_date: Date;
  status: 'draft' | 'running' | 'completed' | 'cancelled';
}

interface Variant {
  variant_id: string;
  name: string;
  description: string;
  percentage: number;
  feature_flags: { [flagId: string]: boolean };
  config_overrides: { [key: string]: any };
}
```

### Example A/B Test

```javascript
const imcuCreationUITest = {
  test_id: 'ab-test-001',
  name: 'IMCU Creation UI Variants',
  variants: [
    {
      variant_id: 'control',
      name: 'Current UI',
      percentage: 50,
      feature_flags: {},
      config_overrides: {}
    },
    {
      variant_id: 'variant-a',
      name: 'Simplified UI',
      percentage: 25,
      feature_flags: { 'ui.imcu-creation.simplified': true },
      config_overrides: { 'ui.panels': 2 }
    },
    {
      variant_id: 'variant-b',
      name: 'AI-Assisted UI',
      percentage: 25,
      feature_flags: { 'ui.imcu-creation.ai-assist': true },
      config_overrides: { 'ai.suggestions': 'aggressive' }
    }
  ],
  metrics: [
    { name: 'imcu_creation_time', target: 'minimize' },
    { name: 'user_satisfaction', target: 'maximize' },
    { name: 'completion_rate', target: 'maximize' }
  ],
  start_date: new Date('2026-02-01'),
  end_date: new Date('2026-02-14'),
  status: 'running'
};
```

---

## Monitoring & Analytics

### Key Metrics

**Per Flag:**
- Evaluation count
- Enabled count
- Disabled count
- Error rate
- Performance impact
- User adoption rate

**Per Module:**
- Active users (hybrid/immersive)
- Session duration
- Feature usage
- Error rates
- Performance metrics
- User satisfaction (NPS)

### Alerting

```javascript
const flagAlerts = {
  'high_error_rate': {
    condition: 'error_rate > 1%',
    severity: 'critical',
    action: 'auto_disable_flag'
  },
  
  'low_adoption': {
    condition: 'adoption_rate < 5% after 7 days',
    severity: 'warning',
    action: 'notify_team'
  },
  
  'performance_degradation': {
    condition: 'p95_latency > baseline * 1.5',
    severity: 'warning',
    action: 'notify_team'
  }
};
```

---

## Flag Management

### Creating New Flags

```bash
# Create flag for new module
npm run flag:create -- \
  --module-id "new-module" \
  --name "New Module - Hybrid Mode" \
  --status "alpha" \
  --modes "hybrid" \
  --rollout 0

# Output:
# ✓ Flag created: module.new-module.hybrid
# ✓ Status: alpha (0% rollout)
# ✓ Ready for internal testing
```

### Updating Flags

```bash
# Promote flag to beta and increase rollout
npm run flag:update module.new-module.hybrid \
  --status beta \
  --rollout 20

# Output:
# ✓ Flag updated: module.new-module.hybrid
# ✓ Status: alpha → beta
# ✓ Rollout: 0% → 20%
# ✓ Estimated reach: 2,000 users
```

### Disabling Flags

```bash
# Emergency disable
npm run flag:disable module.new-module.hybrid \
  --reason "Critical bug detected"

# Output:
# ✓ Flag disabled: module.new-module.hybrid
# ✓ Reason: Critical bug detected
# ✓ Affected users: 2,000
# ✓ Notification sent to team
```

---

## Best Practices

### DO

- ✅ Start with alpha (internal) testing
- ✅ Gradually increase rollout percentage
- ✅ Monitor metrics at each stage
- ✅ Document flag purpose and dependencies
- ✅ Clean up deprecated flags
- ✅ Use targeting rules for specific users
- ✅ Test both enabled and disabled states

### DON'T

- ❌ Skip alpha or beta stages
- ❌ Increase rollout >25% in one step
- ❌ Ignore monitoring and alerts
- ❌ Leave deprecated flags indefinitely
- ❌ Create circular dependencies
- ❌ Forget to update documentation

---

## References

- [Architecture Overview](./architecture_overview.md) - Stack-wide blueprint
- [Module Template](./module_template.md) - Canonical module flow
- [Access Layer](./access_layer.md) - Mode selection and entry
- [v-COS Ontology](../vcos/ontology.md) - Entity model

---

**Maintained By:** N3XUS Platform Team  
**Last Updated:** January 2026  
**Status:** Canonical Reference

---

*"Flags enable fearless deployment."*
