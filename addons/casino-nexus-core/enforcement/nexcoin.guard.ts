/**
 * NexCoin Guard - Enforcement Module
 * 
 * MANDATORY enforcement for all premium Casino Nexus features.
 * Ensures users have sufficient NexCoin balance before accessing:
 * - All slots
 * - All tables
 * - VR-Lounge
 * - High Roller Suite
 * - AI Dealer tables
 * 
 * @module enforcement/nexcoin.guard
 * @compliance MANDATORY
 */

export interface User {
  id: string;
  wallet: {
    nexcoin: number;
  };
  tier?: 'founder' | 'standard';
}

export interface NexCoinRequirement {
  feature: string;
  cost: number;
  tier?: string;
}

export class NexCoinError extends Error {
  code: string;
  required: number;
  available: number;

  constructor(message: string, required: number, available: number) {
    super(message);
    this.name = 'NexCoinError';
    this.code = 'NEXCOIN_REQUIRED';
    this.required = required;
    this.available = available;
  }
}

/**
 * Require NexCoin balance for feature access
 * 
 * @param user - User with wallet information
 * @param cost - Required NexCoin amount
 * @throws {NexCoinError} When insufficient balance
 */
export function requireNexCoin(user: User, cost: number): void {
  if (!user || !user.wallet) {
    throw new NexCoinError(
      'Invalid user or wallet',
      cost,
      0
    );
  }

  if (user.wallet.nexcoin < cost) {
    throw new NexCoinError(
      `Insufficient NexCoin. Required: ${cost}, Available: ${user.wallet.nexcoin}`,
      cost,
      user.wallet.nexcoin
    );
  }
}

/**
 * Check if user can afford feature without throwing
 * 
 * @param user - User with wallet information
 * @param cost - Required NexCoin amount
 * @returns true if user has sufficient balance
 */
export function canAfford(user: User, cost: number): boolean {
  try {
    requireNexCoin(user, cost);
    return true;
  } catch {
    return false;
  }
}

/**
 * Deduct NexCoin from user wallet (does not persist - caller must save)
 * 
 * @param user - User with wallet information
 * @param cost - NexCoin amount to deduct
 * @returns Updated user object
 * @throws {NexCoinError} When insufficient balance
 */
export function deductNexCoin(user: User, cost: number): User {
  requireNexCoin(user, cost);
  
  return {
    ...user,
    wallet: {
      ...user.wallet,
      nexcoin: user.wallet.nexcoin - cost
    }
  };
}

/**
 * Feature cost configuration
 */
export const FEATURE_COSTS = Object.freeze({
  SLOT_SPIN: 10,
  TABLE_SEAT: 50,
  VR_LOUNGE_ENTRY: 100,
  HIGH_ROLLER_MINIMUM: 5000,
  AI_DEALER_TABLE: 75,
  PROGRESSIVE_SLOT: 25,
  VIP_BLACKJACK: 200,
  VIP_BACCARAT: 200,
  DIAMOND_PROGRESSIVE: 150,
  INFINITY_VAULT: 175,
  FOUNDERS_WHEEL: 500
});

/**
 * Enforce feature access with predefined cost
 * 
 * @param user - User with wallet information
 * @param feature - Feature key from FEATURE_COSTS
 */
export function enforceFeatureAccess(user: User, feature: keyof typeof FEATURE_COSTS): void {
  const cost = FEATURE_COSTS[feature];
  requireNexCoin(user, cost);
}

/**
 * Get feature cost with optional tier discount
 * 
 * @param feature - Feature key from FEATURE_COSTS
 * @param tier - User tier (founder gets 10% discount)
 * @returns Final cost after discounts
 */
export function getFeatureCost(feature: keyof typeof FEATURE_COSTS, tier?: string): number {
  const baseCost = FEATURE_COSTS[feature];
  
  // Founder tier gets 10% discount (non-public benefit)
  if (tier === 'founder') {
    return Math.floor(baseCost * 0.9);
  }
  
  return baseCost;
}

/**
 * Batch check multiple features
 * 
 * @param user - User with wallet information
 * @param features - Array of feature keys
 * @returns Object with feature keys and boolean access values
 */
export function checkFeatureAccess(
  user: User,
  features: Array<keyof typeof FEATURE_COSTS>
): Record<string, boolean> {
  const access: Record<string, boolean> = {};
  
  for (const feature of features) {
    const cost = getFeatureCost(feature, user.tier);
    access[feature] = canAfford(user, cost);
  }
  
  return access;
}

export default {
  requireNexCoin,
  canAfford,
  deductNexCoin,
  enforceFeatureAccess,
  getFeatureCost,
  checkFeatureAccess,
  FEATURE_COSTS
};
