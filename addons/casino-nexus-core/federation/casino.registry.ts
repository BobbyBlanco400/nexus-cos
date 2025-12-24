/**
 * Casino Registry - Multi-Casino Federation Management
 * 
 * Central registry for all casinos in the Nexus federation.
 * Manages casino registration, revenue splits, and compliance profiles.
 * 
 * @module federation/casino.registry
 * @compliance FEDERATION-CORE
 */

export interface CasinoRegistration {
  casinoId: string;
  name: string;
  theme: string;
  owner: string;
  complianceProfile: string;
  revenueSplit: RevenueSplit;
  registeredAt: number;
  status: 'pending' | 'active' | 'suspended' | 'terminated';
  metadata: CasinoMetadata;
}

export interface RevenueSplit {
  operator: number;   // Percentage for casino operator
  platform: number;   // Percentage for Nexus COS platform
  creator: number;    // Percentage for content creators (if applicable)
}

export interface CasinoMetadata {
  url?: string;
  logo?: string;
  description: string;
  features: string[];
  supportedJurisdictions: string[];
  targetAudience?: string;
  maxCapacity?: number;
  tier?: string;
}

export interface RevenueTransaction {
  transactionId: string;
  casinoId: string;
  amount: number;
  timestamp: number;
  splits: {
    operator: number;
    platform: number;
    creator: number;
  };
}

/**
 * Default revenue split configuration
 */
export const DEFAULT_REVENUE_SPLIT: RevenueSplit = {
  operator: 70,  // 70% to casino operator
  platform: 25,  // 25% to platform
  creator: 5     // 5% to creators
};

/**
 * Premium casino revenue split
 */
export const PREMIUM_REVENUE_SPLIT: RevenueSplit = {
  operator: 75,  // 75% to premium casino operator
  platform: 20,  // 20% to platform
  creator: 5     // 5% to creators
};

/**
 * Community casino revenue split
 */
export const COMMUNITY_REVENUE_SPLIT: RevenueSplit = {
  operator: 60,  // 60% to community operator
  platform: 20,  // 20% to platform
  creator: 20    // 20% to community creators
};

/**
 * Casino Registry Manager
 */
export class CasinoRegistry {
  private casinos: Map<string, CasinoRegistration>;
  private transactions: RevenueTransaction[];

  constructor() {
    this.casinos = new Map();
    this.transactions = [];
    
    // Initialize with default casinos
    this.initializeDefaultCasinos();
  }

  /**
   * Initialize default platform casinos
   */
  private initializeDefaultCasinos(): void {
    this.register({
      casinoId: 'casino-nexus',
      name: 'Casino Nexus',
      theme: 'main',
      owner: 'PUABO Holdings',
      complianceProfile: 'global-standard',
      revenueSplit: DEFAULT_REVENUE_SPLIT,
      metadata: {
        description: 'The flagship casino of the Nexus federation',
        features: ['slots', 'tables', 'vr-lounge', 'high-roller', 'ai-dealers'],
        supportedJurisdictions: ['US_CA', 'EU', 'LATAM', 'ASIA', 'GLOBAL']
      }
    });

    this.register({
      casinoId: 'neon-vault',
      name: 'Neon Vault',
      theme: 'cyberpunk',
      owner: 'PUABO Holdings',
      complianceProfile: 'global-standard',
      revenueSplit: DEFAULT_REVENUE_SPLIT,
      metadata: {
        description: 'Futuristic cyberpunk casino experience',
        features: ['slots', 'progressive', 'vr-lounge'],
        supportedJurisdictions: ['EU', 'LATAM', 'ASIA', 'GLOBAL']
      }
    });

    this.register({
      casinoId: 'high-roller-palace',
      name: 'High Roller Palace',
      theme: 'luxury',
      owner: 'PUABO Holdings',
      complianceProfile: 'premium',
      revenueSplit: PREMIUM_REVENUE_SPLIT,
      metadata: {
        description: 'Exclusive high-stakes casino',
        features: ['tables', 'high-roller', 'ai-dealers', 'vip-only'],
        supportedJurisdictions: ['EU', 'ASIA', 'GLOBAL'],
        tier: 'premium'
      }
    });

    this.register({
      casinoId: 'club-saditty',
      name: 'Club Saditty',
      theme: 'tenant-platform',
      owner: 'Community',
      complianceProfile: 'community',
      revenueSplit: COMMUNITY_REVENUE_SPLIT,
      metadata: {
        description: 'Community-run casino platform',
        features: ['slots', 'tables', 'creator-games'],
        supportedJurisdictions: ['GLOBAL']
      }
    });
  }

  /**
   * Register new casino to the federation
   */
  register(options: {
    casinoId: string;
    name: string;
    theme: string;
    owner: string;
    complianceProfile: string;
    revenueSplit: RevenueSplit;
    metadata: CasinoMetadata;
  }): CasinoRegistration {
    const { casinoId, name, theme, owner, complianceProfile, revenueSplit, metadata } = options;

    if (this.casinos.has(casinoId)) {
      throw new Error(`Casino already registered: ${casinoId}`);
    }

    // Validate revenue split
    this.validateRevenueSplit(revenueSplit);

    const registration: CasinoRegistration = {
      casinoId,
      name,
      theme,
      owner,
      complianceProfile,
      revenueSplit,
      registeredAt: Date.now(),
      status: 'pending',
      metadata
    };

    this.casinos.set(casinoId, registration);
    return registration;
  }

  /**
   * Validate revenue split percentages
   */
  private validateRevenueSplit(split: RevenueSplit): void {
    const total = split.operator + split.platform + split.creator;
    
    if (Math.abs(total - 100) > 0.01) {
      throw new Error(`Revenue split must total 100%, got ${total}%`);
    }

    if (split.operator < 0 || split.platform < 0 || split.creator < 0) {
      throw new Error('Revenue split percentages cannot be negative');
    }
  }

  /**
   * Activate casino registration
   */
  activate(casinoId: string): CasinoRegistration {
    const casino = this.casinos.get(casinoId);
    
    if (!casino) {
      throw new Error(`Casino not found: ${casinoId}`);
    }

    casino.status = 'active';
    return casino;
  }

  /**
   * Suspend casino
   */
  suspend(casinoId: string, reason?: string): CasinoRegistration {
    const casino = this.casinos.get(casinoId);
    
    if (!casino) {
      throw new Error(`Casino not found: ${casinoId}`);
    }

    casino.status = 'suspended';
    return casino;
  }

  /**
   * Get casino registration
   */
  getCasino(casinoId: string): CasinoRegistration | undefined {
    return this.casinos.get(casinoId);
  }

  /**
   * Get all registered casinos
   */
  getAllCasinos(): CasinoRegistration[] {
    return Array.from(this.casinos.values());
  }

  /**
   * Get active casinos
   */
  getActiveCasinos(): CasinoRegistration[] {
    return Array.from(this.casinos.values()).filter(c => c.status === 'active');
  }

  /**
   * Process revenue transaction
   */
  processRevenue(casinoId: string, amount: number): RevenueTransaction {
    const casino = this.casinos.get(casinoId);
    
    if (!casino) {
      throw new Error(`Casino not found: ${casinoId}`);
    }

    if (casino.status !== 'active') {
      throw new Error(`Casino is not active: ${casinoId}`);
    }

    const splits = {
      operator: (amount * casino.revenueSplit.operator) / 100,
      platform: (amount * casino.revenueSplit.platform) / 100,
      creator: (amount * casino.revenueSplit.creator) / 100
    };

    const transaction: RevenueTransaction = {
      transactionId: this.generateTransactionId(),
      casinoId,
      amount,
      timestamp: Date.now(),
      splits
    };

    this.transactions.push(transaction);
    return transaction;
  }

  /**
   * Generate unique transaction ID
   */
  private generateTransactionId(): string {
    return `REV-${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`;
  }

  /**
   * Get revenue statistics for casino
   */
  getCasinoRevenue(casinoId: string): {
    totalRevenue: number;
    operatorShare: number;
    platformShare: number;
    creatorShare: number;
    transactionCount: number;
  } {
    const casinoTransactions = this.transactions.filter(t => t.casinoId === casinoId);

    const stats = {
      totalRevenue: 0,
      operatorShare: 0,
      platformShare: 0,
      creatorShare: 0,
      transactionCount: casinoTransactions.length
    };

    for (const tx of casinoTransactions) {
      stats.totalRevenue += tx.amount;
      stats.operatorShare += tx.splits.operator;
      stats.platformShare += tx.splits.platform;
      stats.creatorShare += tx.splits.creator;
    }

    return stats;
  }

  /**
   * Get platform-wide revenue statistics
   */
  getPlatformRevenue(): {
    totalRevenue: number;
    platformShare: number;
    operatorShare: number;
    creatorShare: number;
    transactionCount: number;
    byCasino: Record<string, number>;
  } {
    const stats = {
      totalRevenue: 0,
      platformShare: 0,
      operatorShare: 0,
      creatorShare: 0,
      transactionCount: this.transactions.length,
      byCasino: {} as Record<string, number>
    };

    for (const tx of this.transactions) {
      stats.totalRevenue += tx.amount;
      stats.platformShare += tx.splits.platform;
      stats.operatorShare += tx.splits.operator;
      stats.creatorShare += tx.splits.creator;
      
      stats.byCasino[tx.casinoId] = (stats.byCasino[tx.casinoId] || 0) + tx.amount;
    }

    return stats;
  }

  /**
   * Update casino metadata
   */
  updateMetadata(casinoId: string, metadata: Partial<CasinoMetadata>): CasinoRegistration {
    const casino = this.casinos.get(casinoId);
    
    if (!casino) {
      throw new Error(`Casino not found: ${casinoId}`);
    }

    casino.metadata = {
      ...casino.metadata,
      ...metadata
    };

    return casino;
  }

  /**
   * Update revenue split
   */
  updateRevenueSplit(casinoId: string, newSplit: RevenueSplit): CasinoRegistration {
    const casino = this.casinos.get(casinoId);
    
    if (!casino) {
      throw new Error(`Casino not found: ${casinoId}`);
    }

    this.validateRevenueSplit(newSplit);
    casino.revenueSplit = newSplit;

    return casino;
  }

  /**
   * Get registry statistics
   */
  getRegistryStats(): {
    totalCasinos: number;
    activeCasinos: number;
    pendingCasinos: number;
    suspendedCasinos: number;
    totalRevenue: number;
  } {
    const stats = {
      totalCasinos: this.casinos.size,
      activeCasinos: 0,
      pendingCasinos: 0,
      suspendedCasinos: 0,
      totalRevenue: 0
    };

    for (const casino of this.casinos.values()) {
      switch (casino.status) {
        case 'active':
          stats.activeCasinos++;
          break;
        case 'pending':
          stats.pendingCasinos++;
          break;
        case 'suspended':
          stats.suspendedCasinos++;
          break;
      }
    }

    stats.totalRevenue = this.transactions.reduce((sum, tx) => sum + tx.amount, 0);

    return stats;
  }

  /**
   * Get casinos by owner
   */
  getCasinosByOwner(owner: string): CasinoRegistration[] {
    return Array.from(this.casinos.values()).filter(c => c.owner === owner);
  }

  /**
   * Check if casino ID is available
   */
  isIdAvailable(casinoId: string): boolean {
    return !this.casinos.has(casinoId);
  }
}

export default CasinoRegistry;
