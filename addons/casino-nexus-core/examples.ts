/**
 * Casino Nexus Core Add-In - Integration Example
 * 
 * This example demonstrates how to integrate the Casino Nexus Core add-in
 * into an existing Nexus COS / Casino Nexus application.
 * 
 * @example
 */

// Import enforcement modules
import {
  requireNexCoin,
  canAfford,
  FEATURE_COSTS,
  User
} from './enforcement/nexcoin.guard';

import {
  withLock
} from './enforcement/wallet.lock';

import {
  JurisdictionToggle,
  JurisdictionCode
} from './enforcement/jurisdiction.toggle';

import {
  ComplianceStringManager
} from './enforcement/compliance.strings';

// Import casino modules
import {
  ProgressiveEngine,
  initDefaultPools
} from './casino/progressive.engine';

import {
  HighRollerSuite
} from './casino/highroller.suite';

import {
  VRLoungeCardManager
} from './casino/vr-lounge.card';

import {
  AIDealerRouter
} from './casino/dealer.ai.router';

// Import founder modules
import {
  FounderTierManager
} from './founders/tiers.config';

import {
  BetaFlagManager
} from './founders/beta.flags';

import {
  AccessExpiryManager
} from './founders/access.expiry';

// Import federation modules
import {
  StripRouter
} from './federation/strip.router';

import {
  CasinoRegistry
} from './federation/casino.registry';

/**
 * Example 1: Initialize the system
 */
export function initializeCasinoNexusCore() {
  // Initialize jurisdiction toggle
  const jurisdictionToggle = new JurisdictionToggle('GLOBAL');
  
  // Initialize progressive engine
  const progressiveEngine = new ProgressiveEngine();
  initDefaultPools(progressiveEngine);
  
  // Initialize high roller suite
  const highRollerSuite = new HighRollerSuite();
  
  // Initialize VR lounge manager
  const vrLoungeManager = new VRLoungeCardManager();
  
  // Initialize AI dealer router
  const aiDealerRouter = new AIDealerRouter();
  
  // Initialize founder tier manager
  const founderTierManager = new FounderTierManager();
  
  // Initialize beta flag manager
  const betaFlagManager = new BetaFlagManager();
  
  // Initialize access expiry manager
  const accessExpiryManager = new AccessExpiryManager();
  
  // Initialize strip router
  const stripRouter = new StripRouter();
  
  // Initialize casino registry
  const casinoRegistry = new CasinoRegistry();
  
  return {
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
  };
}

/**
 * Example 2: User plays a slot with NexCoin enforcement
 */
export async function playSlotWithEnforcement(user: User, slotCost: number) {
  // Check if user can afford
  if (!canAfford(user, slotCost)) {
    throw new Error('Insufficient NexCoin balance');
  }
  
  // Use wallet lock to prevent concurrent modifications
  const result = await withLock(user.id, 'slot-spin', async () => {
    // Enforce NexCoin requirement
    requireNexCoin(user, slotCost);
    
    // Deduct cost from user wallet (caller should persist)
    user.wallet.nexcoin -= slotCost;
    
    // Contribute to progressive pool
    const progressiveEngine = new ProgressiveEngine();
    progressiveEngine.contribute('diamond-progressive', slotCost);
    
    // Return spin result
    return {
      success: true,
      balanceAfter: user.wallet.nexcoin
    };
  });
  
  return result;
}

/**
 * Example 3: Jurisdiction-based feature access
 */
export function checkFeatureAccessByJurisdiction(
  jurisdiction: JurisdictionCode,
  feature: string
) {
  const jurisdictionToggle = new JurisdictionToggle(jurisdiction);
  
  // Get compliance strings
  const stringManager = new ComplianceStringManager(jurisdiction);
  
  return {
    allowed: jurisdictionToggle.isFeatureEnabled(feature as any),
    currencyLabel: stringManager.getString('currency.name'),
    disclaimer: stringManager.getString('disclaimer.general')
  };
}

/**
 * Example 4: High Roller Suite access
 */
export function grantHighRollerAccess(
  user: User,
  tier: 'highroller' | 'founder-highroller' = 'highroller'
) {
  const highRollerSuite = new HighRollerSuite();
  
  // Check if user qualifies
  if (!highRollerSuite.qualifies(user.id, user.wallet.nexcoin, user.tier)) {
    throw new Error('User does not qualify for High Roller Suite');
  }
  
  // Enforce minimum NexCoin
  requireNexCoin(user, FEATURE_COSTS.HIGH_ROLLER_MINIMUM);
  
  // Grant access
  const member = highRollerSuite.grantAccess(user.id, user.wallet.nexcoin, tier);
  
  return member;
}

/**
 * Example 5: AI Dealer assignment
 */
export function assignAIDealer(
  userId: string,
  gameType: string,
  jurisdiction: JurisdictionCode
) {
  const aiDealerRouter = new AIDealerRouter();
  
  const assignment = aiDealerRouter.assign({
    playerId: userId,
    gameId: `game-${Date.now()}`,
    gameType,
    jurisdiction,
    preferredPersona: 'professional'
  });
  
  return assignment;
}

/**
 * Example 6: Founder tier registration
 */
export function registerFounder(
  userId: string,
  tier: 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond'
) {
  const founderTierManager = new FounderTierManager();
  const betaFlagManager = new BetaFlagManager();
  const accessExpiryManager = new AccessExpiryManager();
  
  // Register founder
  const member = founderTierManager.registerFounder(userId, tier);
  
  // Grant feature access based on tier
  const features = ['vr-lounge', 'high-roller-suite', 'ai-dealers'];
  
  for (const feature of features) {
    if (betaFlagManager.isEnabled(feature, tier)) {
      accessExpiryManager.grantAccess(userId, feature, undefined, tier);
    }
  }
  
  return member;
}

/**
 * Example 7: Casino federation navigation
 */
export function navigateBetweenCasinos(
  userId: string,
  targetCasinoId: string,
  walletBalance: number
) {
  const stripRouter = new StripRouter();
  
  // Check if user can access casino
  const accessCheck = stripRouter.canAccess(userId, targetCasinoId, walletBalance);
  
  if (!accessCheck.allowed) {
    throw new Error(accessCheck.reason || 'Access denied');
  }
  
  // Navigate to casino
  const route = stripRouter.navigateTo(userId, targetCasinoId, walletBalance);
  
  return route;
}

/**
 * Example 8: Revenue processing
 */
export function processRevenueTransaction(
  casinoId: string,
  amount: number
) {
  const casinoRegistry = new CasinoRegistry();
  
  // Process revenue with splits
  const transaction = casinoRegistry.processRevenue(casinoId, amount);
  
  return {
    transactionId: transaction.transactionId,
    operatorShare: transaction.splits.operator,
    platformShare: transaction.splits.platform,
    creatorShare: transaction.splits.creator
  };
}

/**
 * Example 9: Complete user flow - from purchase to play
 */
export async function completeUserFlow(
  user: User,
  jurisdiction: JurisdictionCode
) {
  // Step 1: Set jurisdiction
  const jurisdictionToggle = new JurisdictionToggle(jurisdiction);
  const complianceStrings = new ComplianceStringManager(jurisdiction);
  
  // Step 2: Check if user is founder
  const founderTierManager = new FounderTierManager();
  const isFounder = founderTierManager.isFounder(user.id);
  
  // Step 3: Check feature access
  const betaFlagManager = new BetaFlagManager();
  const availableFeatures = betaFlagManager.getAvailableFeatures(
    isFounder ? (user.tier as any) : undefined
  );
  
  // Step 4: Play game with enforcement
  const result = await playSlotWithEnforcement(user, 100);
  
  // Step 5: Process revenue
  const casinoRegistry = new CasinoRegistry();
  const revenue = casinoRegistry.processRevenue('casino-nexus', 100);
  
  return {
    jurisdiction: jurisdiction,
    currencyLabel: complianceStrings.getString('currency.name'),
    disclaimer: complianceStrings.getString('disclaimer.general'),
    isFounder,
    availableFeatures: availableFeatures.map(f => f.name),
    gameResult: result,
    revenueProcessed: revenue
  };
}

// Export all examples
export default {
  initializeCasinoNexusCore,
  playSlotWithEnforcement,
  checkFeatureAccessByJurisdiction,
  grantHighRollerAccess,
  assignAIDealer,
  registerFounder,
  navigateBetweenCasinos,
  processRevenueTransaction,
  completeUserFlow
};
