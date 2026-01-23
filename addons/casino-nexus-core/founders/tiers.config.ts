/**
 * Founder Tiers Configuration
 * 
 * Manages founder tier system with exclusive benefits and access.
 * Time-boxed, feature-flagged, and non-permanent (except influence).
 * 
 * @module founders/tiers.config
 * @compliance FOUNDER-EXCLUSIVE
 * @visibility NON-PUBLIC
 */

export type FounderTier = 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond';

export interface FounderPackage {
  tier: FounderTier;
  name: string;
  nexCoinAmount: number;
  price: number;
  multiplier: number;
  benefits: string[];
  exclusiveFeatures: string[];
}

export interface FounderMember {
  userId: string;
  tier: FounderTier;
  purchaseDate: number;
  expiresAt: number;
  nexCoinPurchased: number;
  lifetimeValue: number;
  privileges: string[];
  influenceScore: number;
}

/**
 * Founder Tier Packages
 */
export const FOUNDER_TIERS: Record<FounderTier, FounderPackage> = {
  bronze: {
    tier: 'bronze',
    name: 'Bronze Founder',
    nexCoinAmount: 10000,
    price: 99,
    multiplier: 1.1,
    benefits: [
      'Early Access to VR-Lounge',
      '10% NexCoin Bonus',
      'Founder Badge',
      'Beta Access',
      'Community Feedback Input'
    ],
    exclusiveFeatures: [
      'founder-badge',
      'beta-access'
    ]
  },
  silver: {
    tier: 'silver',
    name: 'Silver Founder',
    nexCoinAmount: 25000,
    price: 249,
    multiplier: 1.2,
    benefits: [
      'Early Access to VR-Lounge',
      'Early Access to High Roller Suite',
      '20% NexCoin Bonus',
      'Founder Badge',
      'Beta Access',
      'Priority Support',
      'Community Feedback Input'
    ],
    exclusiveFeatures: [
      'founder-badge',
      'beta-access',
      'high-roller-early',
      'priority-support'
    ]
  },
  gold: {
    tier: 'gold',
    name: 'Gold Founder',
    nexCoinAmount: 50000,
    price: 499,
    multiplier: 1.3,
    benefits: [
      'Full VR-Lounge Access',
      'Full High Roller Suite Access',
      'Early AI Dealer Access',
      '30% NexCoin Bonus',
      'Founder Badge',
      'Beta Access',
      'Priority Support',
      'Enhanced Multipliers',
      'Community Feedback Priority'
    ],
    exclusiveFeatures: [
      'founder-badge',
      'beta-access',
      'high-roller-full',
      'ai-dealer-early',
      'priority-support',
      'enhanced-multipliers'
    ]
  },
  platinum: {
    tier: 'platinum',
    name: 'Platinum Founder',
    nexCoinAmount: 100000,
    price: 999,
    multiplier: 1.5,
    benefits: [
      'Full VR-Lounge Access',
      'Full High Roller Suite Access',
      'Full AI Dealer Access',
      'Priority Marketplace Placement',
      '50% NexCoin Bonus',
      'Founder Badge',
      'Beta Access',
      'Priority Support',
      'Enhanced Multipliers',
      'Custom Avatar Options',
      'Community Feedback Priority',
      'Exclusive Events'
    ],
    exclusiveFeatures: [
      'founder-badge',
      'beta-access',
      'high-roller-full',
      'ai-dealer-full',
      'priority-support',
      'enhanced-multipliers',
      'marketplace-priority',
      'custom-avatar',
      'exclusive-events'
    ]
  },
  diamond: {
    tier: 'diamond',
    name: 'Diamond Founder',
    nexCoinAmount: 250000,
    price: 2499,
    multiplier: 2.0,
    benefits: [
      'Full VR-Lounge Access',
      'Full High Roller Suite Access',
      'Full AI Dealer Access',
      'Priority Marketplace Placement',
      '100% NexCoin Bonus',
      'Founder Badge',
      'Beta Access',
      'Priority Support',
      'Enhanced Multipliers',
      'Custom Avatar Options',
      'Community Feedback Priority',
      'Exclusive Events',
      'Personal Account Manager',
      'Influence on Roadmap',
      'Lifetime Founder Status'
    ],
    exclusiveFeatures: [
      'founder-badge',
      'beta-access',
      'high-roller-full',
      'ai-dealer-full',
      'priority-support',
      'enhanced-multipliers',
      'marketplace-priority',
      'custom-avatar',
      'exclusive-events',
      'account-manager',
      'roadmap-influence',
      'lifetime-status'
    ]
  }
};

/**
 * Founder Tier Manager
 */
export class FounderTierManager {
  private members: Map<string, FounderMember>;
  private betaEndDate: number;

  constructor(betaEndDate?: number) {
    this.members = new Map();
    // Default beta period: 72 hours (Codespaces Launch)
    this.betaEndDate = betaEndDate || Date.now() + (72 * 60 * 60 * 1000);
  }

  /**
   * Register founder member
   */
  registerFounder(userId: string, tier: FounderTier): FounderMember {
    const tierConfig = FOUNDER_TIERS[tier];
    
    if (!tierConfig) {
      throw new Error(`Invalid founder tier: ${tier}`);
    }

    const member: FounderMember = {
      userId,
      tier,
      purchaseDate: Date.now(),
      expiresAt: tier === 'diamond' ? Infinity : this.betaEndDate,
      nexCoinPurchased: tierConfig.nexCoinAmount,
      lifetimeValue: tierConfig.price,
      privileges: [...tierConfig.exclusiveFeatures],
      influenceScore: this.calculateInfluenceScore(tier)
    };

    this.members.set(userId, member);
    return member;
  }

  /**
   * Calculate influence score based on tier
   */
  private calculateInfluenceScore(tier: FounderTier): number {
    const scores: Record<FounderTier, number> = {
      bronze: 1,
      silver: 3,
      gold: 5,
      platinum: 10,
      diamond: 20
    };
    return scores[tier];
  }

  /**
   * Get founder member
   */
  getMember(userId: string): FounderMember | undefined {
    return this.members.get(userId);
  }

  /**
   * Check if user is founder
   */
  isFounder(userId: string): boolean {
    const member = this.members.get(userId);
    
    if (!member) {
      return false;
    }

    return Date.now() < member.expiresAt;
  }

  /**
   * Check if user has specific privilege
   */
  hasPrivilege(userId: string, privilege: string): boolean {
    const member = this.members.get(userId);
    
    if (!member || Date.now() >= member.expiresAt) {
      return false;
    }

    return member.privileges.includes(privilege);
  }

  /**
   * Get tier benefits
   */
  getTierBenefits(tier: FounderTier): string[] {
    return FOUNDER_TIERS[tier]?.benefits || [];
  }

  /**
   * Get NexCoin multiplier for tier
   */
  getMultiplier(tier: FounderTier): number {
    return FOUNDER_TIERS[tier]?.multiplier || 1.0;
  }

  /**
   * Upgrade founder tier
   */
  upgradeTier(userId: string, newTier: FounderTier): FounderMember {
    const member = this.members.get(userId);
    
    if (!member) {
      throw new Error('User is not a founder member');
    }

    const tierConfig = FOUNDER_TIERS[newTier];
    const currentTierConfig = FOUNDER_TIERS[member.tier];

    // Ensure upgrade, not downgrade
    const tierOrder: FounderTier[] = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
    const currentIndex = tierOrder.indexOf(member.tier);
    const newIndex = tierOrder.indexOf(newTier);

    if (newIndex <= currentIndex) {
      throw new Error('Can only upgrade to higher tier');
    }

    member.tier = newTier;
    member.privileges = [...tierConfig.exclusiveFeatures];
    member.nexCoinPurchased += tierConfig.nexCoinAmount;
    member.lifetimeValue += tierConfig.price;
    member.influenceScore = this.calculateInfluenceScore(newTier);

    // Diamond tier gets lifetime status
    if (newTier === 'diamond') {
      member.expiresAt = Infinity;
    }

    return member;
  }

  /**
   * Get all founders
   */
  getAllFounders(): FounderMember[] {
    return Array.from(this.members.values());
  }

  /**
   * Get founder statistics
   */
  getStats(): {
    total: number;
    byTier: Record<FounderTier, number>;
    totalLifetimeValue: number;
    avgInfluenceScore: number;
  } {
    const stats = {
      total: this.members.size,
      byTier: {
        bronze: 0,
        silver: 0,
        gold: 0,
        platinum: 0,
        diamond: 0
      } as Record<FounderTier, number>,
      totalLifetimeValue: 0,
      avgInfluenceScore: 0
    };

    let totalInfluence = 0;

    for (const member of this.members.values()) {
      stats.byTier[member.tier]++;
      stats.totalLifetimeValue += member.lifetimeValue;
      totalInfluence += member.influenceScore;
    }

    stats.avgInfluenceScore = this.members.size > 0
      ? Math.round(totalInfluence / this.members.size)
      : 0;

    return stats;
  }

  /**
   * Get beta end date
   */
  getBetaEndDate(): number {
    return this.betaEndDate;
  }

  /**
   * Set beta end date
   */
  setBetaEndDate(timestamp: number): void {
    this.betaEndDate = timestamp;
  }

  /**
   * Get hours remaining in beta
   */
  getHoursRemaining(): number {
    const diff = this.betaEndDate - Date.now();
    return Math.max(0, Math.ceil(diff / (60 * 60 * 1000)));
  }
}

export default FounderTierManager;
