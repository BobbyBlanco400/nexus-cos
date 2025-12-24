/**
 * High Roller Suite - Premium VIP Experience
 * 
 * Exclusive high-stakes area with premium games and features.
 * Requires minimum NexCoin balance for entry.
 * 
 * @module casino/highroller.suite
 * @compliance VIP-TIER
 */

export interface HighRollerConfig {
  minNexCoin: number;
  tables: string[];
  slots: string[];
  exclusiveGame: string;
  perks: string[];
}

export interface HighRollerMember {
  userId: string;
  tier: 'highroller' | 'founder-highroller';
  entryTime: number;
  nexCoinBalance: number;
  lifetimeSpent: number;
  privileges: string[];
}

/**
 * High Roller Suite Configuration
 */
export const HIGH_ROLLER_SUITE: HighRollerConfig = {
  minNexCoin: 5000,
  tables: [
    'VIP Blackjack',
    'VIP Baccarat',
    'High Stakes Poker',
    'Premium Roulette'
  ],
  slots: [
    'Diamond Progressive',
    'Infinity Vault',
    'Platinum Spins',
    'Elite Jackpot'
  ],
  exclusiveGame: 'Founders Wheel',
  perks: [
    'Priority AI Dealer',
    'Enhanced Progressive Contribution',
    'VIP Lounge Access',
    'Exclusive Tournaments',
    'Personal Account Manager',
    'Custom Table Limits'
  ]
};

/**
 * High Roller Suite Manager
 */
export class HighRollerSuite {
  private config: HighRollerConfig;
  private members: Map<string, HighRollerMember>;

  constructor(customConfig?: Partial<HighRollerConfig>) {
    this.config = { ...HIGH_ROLLER_SUITE, ...customConfig };
    this.members = new Map();
  }

  /**
   * Check if user qualifies for High Roller Suite
   */
  qualifies(userId: string, nexCoinBalance: number, tier?: string): boolean {
    // Founder tier gets 20% discount on minimum
    const requiredBalance = tier === 'founder'
      ? Math.floor(this.config.minNexCoin * 0.8)
      : this.config.minNexCoin;

    return nexCoinBalance >= requiredBalance;
  }

  /**
   * Grant access to High Roller Suite
   */
  grantAccess(
    userId: string,
    nexCoinBalance: number,
    tier: 'highroller' | 'founder-highroller' = 'highroller'
  ): HighRollerMember {
    const member: HighRollerMember = {
      userId,
      tier,
      entryTime: Date.now(),
      nexCoinBalance,
      lifetimeSpent: 0,
      privileges: this.getPrivileges(tier)
    };

    this.members.set(userId, member);
    return member;
  }

  /**
   * Get privileges based on tier
   */
  private getPrivileges(tier: string): string[] {
    const basePrivileges = [...this.config.perks];
    
    if (tier === 'founder-highroller') {
      basePrivileges.push(
        'Founder Exclusive Games',
        'Beta Feature Access',
        'Enhanced Multipliers',
        'Priority Support'
      );
    }

    return basePrivileges;
  }

  /**
   * Check if user has active access
   */
  hasAccess(userId: string): boolean {
    return this.members.has(userId);
  }

  /**
   * Get member information
   */
  getMember(userId: string): HighRollerMember | undefined {
    return this.members.get(userId);
  }

  /**
   * Update member balance
   */
  updateBalance(userId: string, newBalance: number): void {
    const member = this.members.get(userId);
    
    if (!member) {
      throw new Error('User is not a High Roller Suite member');
    }

    member.nexCoinBalance = newBalance;

    // Remove access if balance drops below minimum
    if (newBalance < this.config.minNexCoin) {
      this.revokeAccess(userId);
    }
  }

  /**
   * Track spending
   */
  trackSpending(userId: string, amount: number): void {
    const member = this.members.get(userId);
    
    if (member) {
      member.lifetimeSpent += amount;
    }
  }

  /**
   * Revoke access
   */
  revokeAccess(userId: string): boolean {
    return this.members.delete(userId);
  }

  /**
   * Get all active members
   */
  getActiveMembers(): HighRollerMember[] {
    return Array.from(this.members.values());
  }

  /**
   * Get member count by tier
   */
  getMemberStats(): {
    total: number;
    highroller: number;
    founderHighroller: number;
    avgLifetimeSpent: number;
  } {
    const members = this.getActiveMembers();
    
    const stats = {
      total: members.length,
      highroller: members.filter(m => m.tier === 'highroller').length,
      founderHighroller: members.filter(m => m.tier === 'founder-highroller').length,
      avgLifetimeSpent: 0
    };

    if (members.length > 0) {
      const totalSpent = members.reduce((sum, m) => sum + m.lifetimeSpent, 0);
      stats.avgLifetimeSpent = Math.round(totalSpent / members.length);
    }

    return stats;
  }

  /**
   * Get available games for user
   */
  getAvailableGames(userId: string): {
    tables: string[];
    slots: string[];
    exclusive: string | null;
  } {
    const member = this.members.get(userId);
    
    if (!member) {
      return {
        tables: [],
        slots: [],
        exclusive: null
      };
    }

    return {
      tables: [...this.config.tables],
      slots: [...this.config.slots],
      exclusive: member.tier === 'founder-highroller' 
        ? this.config.exclusiveGame 
        : null
    };
  }

  /**
   * Check if user can play specific game
   */
  canPlayGame(userId: string, gameName: string): boolean {
    const member = this.members.get(userId);
    
    if (!member) {
      return false;
    }

    const games = this.getAvailableGames(userId);
    
    return games.tables.includes(gameName) ||
           games.slots.includes(gameName) ||
           games.exclusive === gameName;
  }

  /**
   * Get minimum balance requirement
   */
  getMinimumBalance(tier?: string): number {
    if (tier === 'founder') {
      return Math.floor(this.config.minNexCoin * 0.8);
    }
    return this.config.minNexCoin;
  }

  /**
   * Get configuration
   */
  getConfig(): HighRollerConfig {
    return { ...this.config };
  }
}

/**
 * Table configuration for High Roller games
 */
export const HIGH_ROLLER_TABLES = {
  'VIP Blackjack': {
    minBet: 500,
    maxBet: 10000,
    seats: 7,
    dealer: 'ai-premium'
  },
  'VIP Baccarat': {
    minBet: 1000,
    maxBet: 25000,
    seats: 14,
    dealer: 'ai-premium'
  },
  'High Stakes Poker': {
    minBet: 500,
    maxBet: 15000,
    seats: 9,
    dealer: 'ai-expert'
  },
  'Premium Roulette': {
    minBet: 250,
    maxBet: 20000,
    seats: 8,
    dealer: 'ai-premium'
  }
};

/**
 * Slot configuration for High Roller games
 */
export const HIGH_ROLLER_SLOTS = {
  'Diamond Progressive': {
    minSpin: 150,
    maxSpin: 5000,
    progressivePool: 'diamond-progressive'
  },
  'Infinity Vault': {
    minSpin: 175,
    maxSpin: 7500,
    progressivePool: 'infinity-vault'
  },
  'Platinum Spins': {
    minSpin: 100,
    maxSpin: 3000,
    progressivePool: null
  },
  'Elite Jackpot': {
    minSpin: 200,
    maxSpin: 10000,
    progressivePool: 'mega-jackpot'
  }
};

export default HighRollerSuite;
