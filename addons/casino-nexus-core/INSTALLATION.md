# Casino Nexus Core Add-In - Installation Guide

**Version:** 1.0.0  
**Target:** Nexus COS / Casino Nexus  
**Executor:** TRAE SOLO CODER  
**Status:** Production Ready

---

## Prerequisites

- Node.js 18+ or Node.js 20+
- TypeScript 5.3+
- Nexus COS installed and running
- Access to repository: `BobbyBlanco400/nexus-cos`

---

## Installation Methods

### Method 1: Direct Integration (Recommended)

The add-in is already included in the repository at:
```
/addons/casino-nexus-core/
```

Simply import and use the modules in your Nexus COS application.

### Method 2: Build from Source

```bash
cd /path/to/nexus-cos/addons/casino-nexus-core

# Install dependencies
npm install

# Build TypeScript files
npm run build

# Verify compilation
npm run typecheck
```

---

## Quick Start

### 1. Import the Add-In

```typescript
// Import specific modules
import {
  requireNexCoin,
  JurisdictionToggle,
  ProgressiveEngine,
  HighRollerSuite,
  FounderTierManager,
  CasinoRegistry
} from './addons/casino-nexus-core';

// OR import all at once
import * as CasinoNexusCore from './addons/casino-nexus-core';
```

### 2. Initialize Core Systems

```typescript
import { initializeCasinoNexusCore } from './addons/casino-nexus-core/examples';

// Initialize all systems
const systems = initializeCasinoNexusCore();

// Access individual systems
const {
  jurisdictionToggle,
  progressiveEngine,
  highRollerSuite,
  vrLoungeManager,
  aiDealerRouter,
  founderTierManager,
  betaFlagManager,
  accessExpiryManager,
  stripRouter,
  casinoRegistry
} = systems;
```

### 3. Configure Jurisdiction

```typescript
import { JurisdictionToggle } from './addons/casino-nexus-core';

const jurisdictionToggle = new JurisdictionToggle('GLOBAL');

// Detect user's jurisdiction
const userJurisdiction = JurisdictionToggle.detectJurisdiction(
  userIp,
  userLocale
);

// Set jurisdiction
jurisdictionToggle.setJurisdiction(userJurisdiction);

// Get compliance strings
const profile = jurisdictionToggle.getProfile();
console.log(profile.strings.disclaimer);
```

### 4. Enforce NexCoin Requirements

```typescript
import { requireNexCoin, FEATURE_COSTS } from './addons/casino-nexus-core';

function playSlot(user) {
  try {
    // Enforce NexCoin requirement
    requireNexCoin(user, FEATURE_COSTS.SLOT_SPIN);
    
    // Proceed with game
    console.log('Access granted');
  } catch (error) {
    console.error('Insufficient NexCoin:', error.message);
  }
}
```

### 5. Use Wallet Locking

```typescript
import { withLock } from './addons/casino-nexus-core';

async function transferNexCoin(userId, amount, recipientId) {
  return await withLock(userId, 'transfer', async () => {
    // Atomic operation - wallet is locked
    // Deduct from sender
    // Add to recipient
    return { success: true };
  });
}
```

---

## Integration Examples

### Example 1: Complete User Flow

```typescript
import {
  requireNexCoin,
  JurisdictionToggle,
  ComplianceStringManager,
  ProgressiveEngine,
  withLock
} from './addons/casino-nexus-core';

async function userPlaysGame(user, jurisdiction) {
  // Step 1: Set jurisdiction
  const jurisdictionToggle = new JurisdictionToggle(jurisdiction);
  const strings = new ComplianceStringManager(jurisdiction);
  
  // Step 2: Check feature availability
  const progressiveAllowed = jurisdictionToggle.isFeatureEnabled('progressiveJackpots');
  
  // Step 3: Enforce NexCoin with wallet lock
  const result = await withLock(user.id, 'game-play', async () => {
    requireNexCoin(user, 100);
    
    // Deduct cost
    user.wallet.nexcoin -= 100;
    
    // Contribute to progressive
    if (progressiveAllowed) {
      const engine = new ProgressiveEngine();
      engine.contribute('diamond-progressive', 100);
    }
    
    return { success: true };
  });
  
  return {
    result,
    disclaimer: strings.getString('disclaimer.general')
  };
}
```

### Example 2: High Roller Suite Access

```typescript
import { HighRollerSuite, requireNexCoin } from './addons/casino-nexus-core';

function grantHighRollerAccess(user) {
  const suite = new HighRollerSuite();
  
  // Check qualification
  if (!suite.qualifies(user.id, user.wallet.nexcoin, user.tier)) {
    throw new Error('Does not qualify for High Roller Suite');
  }
  
  // Enforce minimum
  requireNexCoin(user, 5000);
  
  // Grant access
  const member = suite.grantAccess(user.id, user.wallet.nexcoin, 'highroller');
  
  // Get available games
  const games = suite.getAvailableGames(user.id);
  
  return { member, games };
}
```

### Example 3: Founder Registration

```typescript
import {
  FounderTierManager,
  BetaFlagManager,
  AccessExpiryManager
} from './addons/casino-nexus-core';

function registerFounder(userId, tier) {
  const founderManager = new FounderTierManager();
  const betaManager = new BetaFlagManager();
  const expiryManager = new AccessExpiryManager();
  
  // Register founder
  const member = founderManager.registerFounder(userId, tier);
  
  // Grant beta access
  expiryManager.grantAccess(
    userId,
    'founder-beta-access',
    undefined,
    tier
  );
  
  // Check available features
  const features = betaManager.getAvailableFeatures(tier);
  
  return { member, features };
}
```

### Example 4: AI Dealer Assignment

```typescript
import { AIDealerRouter } from './addons/casino-nexus-core';

function assignDealer(userId, gameType, jurisdiction) {
  const router = new AIDealerRouter();
  
  const assignment = router.assign({
    playerId: userId,
    gameId: `game-${Date.now()}`,
    gameType,
    jurisdiction,
    preferredPersona: 'professional'
  });
  
  return assignment;
}
```

### Example 5: Casino Federation

```typescript
import { StripRouter, CasinoRegistry } from './addons/casino-nexus-core';

function navigateCasino(userId, casinoId, walletBalance) {
  const router = new StripRouter();
  const registry = new CasinoRegistry();
  
  // Check access
  const access = router.canAccess(userId, casinoId, walletBalance);
  
  if (!access.allowed) {
    throw new Error(access.reason);
  }
  
  // Navigate
  const route = router.navigateTo(userId, casinoId, walletBalance);
  
  // Process revenue if needed
  const revenue = registry.processRevenue(casinoId, 100);
  
  return { route, revenue };
}
```

---

## Configuration

### Environment Variables (Optional)

```env
# Jurisdiction Settings
DEFAULT_JURISDICTION=GLOBAL

# Founder Beta End Date (timestamp)
FOUNDER_BETA_END_DATE=1735689600000

# Progressive Settings
PROGRESSIVE_CONTRIBUTION_RATE=0.015

# High Roller Minimum
HIGH_ROLLER_MIN_NEXCOIN=5000

# VR Lounge Entry Cost
VR_LOUNGE_ENTRY_COST=100
```

### Custom Configuration

```typescript
import {
  HighRollerSuite,
  ProgressiveEngine,
  AccessExpiryManager
} from './addons/casino-nexus-core';

// Custom High Roller Suite config
const suite = new HighRollerSuite({
  minNexCoin: 10000,  // Custom minimum
  tables: ['Custom Table 1', 'Custom Table 2'],
  exclusiveGame: 'My Special Game'
});

// Custom progressive pool
const engine = new ProgressiveEngine();
engine.initPool('custom-pool', 'Custom Progressive', 5000, 50000);
engine.setContributionRate('custom-pool', 0.02); // 2%

// Custom expiry policy
const expiryManager = new AccessExpiryManager();
expiryManager.setPolicy({
  feature: 'custom-feature',
  defaultDuration: 30 * 24 * 60 * 60 * 1000, // 30 days
  maxDuration: 90 * 24 * 60 * 60 * 1000,
  gracePeriod: 3 * 24 * 60 * 60 * 1000,
  warningThreshold: 7,
  renewable: true
});
```

---

## Testing

### Run Type Checking

```bash
cd addons/casino-nexus-core
npm run typecheck
```

### Manual Testing

```typescript
import { initializeCasinoNexusCore } from './addons/casino-nexus-core/examples';

// Initialize systems
const systems = initializeCasinoNexusCore();

// Test NexCoin enforcement
const testUser = {
  id: 'test-user-1',
  wallet: { nexcoin: 1000 },
  tier: 'founder'
};

try {
  systems.progressiveEngine.initPool('test-pool', 'Test Pool', 100, 1000);
  systems.progressiveEngine.contribute('test-pool', 50);
  console.log('✅ Progressive engine working');
} catch (error) {
  console.error('❌ Progressive engine failed:', error);
}
```

---

## Troubleshooting

### Issue: TypeScript compilation errors

**Solution:**
```bash
# Ensure TypeScript 5.3+ is installed
npm install -g typescript@latest

# Check tsconfig.json has proper lib configuration
# lib: ["ES2020", "DOM"]
```

### Issue: Module not found

**Solution:**
```bash
# Ensure you're importing from correct path
import { ... } from './addons/casino-nexus-core';

# Or use absolute path
import { ... } from '@nexus-cos/casino-nexus-core';
```

### Issue: Console errors in production

**Solution:**
- Replace `console.error` calls with proper logging system
- Or set up error handlers for jurisdiction toggle listeners

---

## Security Considerations

### 1. NexCoin Enforcement
- Always use `requireNexCoin` before feature access
- Never skip wallet locks for concurrent operations
- Log all NexCoin transactions for audit

### 2. Jurisdiction Compliance
- Always detect and set jurisdiction on user connection
- Never allow feature access without jurisdiction check
- Keep compliance strings updated per region

### 3. Founder Access
- Validate founder tier before granting privileges
- Respect time-boxed access expiry
- Never grant permanent access except for Diamond tier

### 4. Revenue Tracking
- Always process revenue through `CasinoRegistry`
- Verify revenue splits match configured values
- Maintain audit trail for all transactions

---

## Production Deployment

### Step 1: Build the Add-In

```bash
cd addons/casino-nexus-core
npm run build
```

### Step 2: Integrate with Main App

```typescript
// In your main Nexus COS application
import {
  JurisdictionToggle,
  ProgressiveEngine,
  HighRollerSuite,
  CasinoRegistry
} from './addons/casino-nexus-core';

// Initialize on app start
const systems = {
  jurisdiction: new JurisdictionToggle('GLOBAL'),
  progressive: new ProgressiveEngine(),
  highRoller: new HighRollerSuite(),
  registry: new CasinoRegistry()
};

// Make available globally
app.set('casinoNexusCore', systems);
```

### Step 3: Add Middleware

```typescript
// Express middleware for jurisdiction detection
app.use((req, res, next) => {
  const jurisdiction = JurisdictionToggle.detectJurisdiction(
    req.ip,
    req.headers['accept-language']
  );
  
  req.jurisdiction = jurisdiction;
  next();
});
```

### Step 4: Monitor and Maintain

```typescript
// Periodic cleanup tasks
setInterval(() => {
  const expiryManager = systems.accessExpiry;
  const cleaned = expiryManager.cleanupExpired();
  console.log(`Cleaned ${cleaned} expired access grants`);
}, 3600000); // Every hour
```

---

## Support & Documentation

**Full Documentation:** `/addons/casino-nexus-core/README.addin.md`  
**Regulatory Flows:** `/addons/casino-nexus-core/diagrams/regulator-flows.md`  
**Examples:** `/addons/casino-nexus-core/examples.ts`

**Contact:**  
- Technical: dev@puaboholdings.com  
- Compliance: compliance@puaboholdings.com

**Alignment:** PUABO Holdings  
**Executable By:** TRAE SOLO CODER  
**Status:** Regulator-Defensible, Investor-Ready

---

**Version:** 1.0.0  
**Last Updated:** 2025-12-24
