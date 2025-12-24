/**
 * Beta Feature Flags
 * 
 * Controls beta feature access for founders.
 * Time-boxed and configurable per feature.
 * 
 * @module founders/beta.flags
 * @compliance FEATURE-GATED
 * @visibility NON-PUBLIC
 */

export type FeatureStatus = 'disabled' | 'founders-only' | 'beta' | 'public';

export interface BetaFeature {
  key: string;
  name: string;
  description: string;
  status: FeatureStatus;
  minFounderTier?: 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond';
  enabledAt?: number;
  publicReleaseDate?: number;
  dependencies?: string[];
}

export interface FeatureFlagConfig {
  features: Record<string, BetaFeature>;
  betaEndDate: number;
}

/**
 * Beta Feature Configuration
 */
export const BETA_FEATURES: Record<string, BetaFeature> = {
  'vr-lounge': {
    key: 'vr-lounge',
    name: 'VR Lounge Access',
    description: 'Full VR casino experience with immersive environments',
    status: 'founders-only',
    minFounderTier: 'bronze',
    enabledAt: Date.now()
  },
  'high-roller-suite': {
    key: 'high-roller-suite',
    name: 'High Roller Suite',
    description: 'Premium high-stakes gaming area',
    status: 'founders-only',
    minFounderTier: 'silver',
    enabledAt: Date.now()
  },
  'ai-dealers': {
    key: 'ai-dealers',
    name: 'AI Dealers',
    description: 'Intelligent AI dealer interactions',
    status: 'founders-only',
    minFounderTier: 'gold',
    enabledAt: Date.now()
  },
  'progressive-jackpots': {
    key: 'progressive-jackpots',
    name: 'Progressive Jackpots',
    description: 'Vegas-style progressive jackpot pools',
    status: 'beta',
    enabledAt: Date.now()
  },
  'founders-wheel': {
    key: 'founders-wheel',
    name: 'Founders Wheel',
    description: 'Exclusive game for founder tier',
    status: 'founders-only',
    minFounderTier: 'platinum',
    enabledAt: Date.now()
  },
  'marketplace-v3': {
    key: 'marketplace-v3',
    name: 'Marketplace V3',
    description: 'Enhanced NFT marketplace with resale',
    status: 'founders-only',
    minFounderTier: 'gold',
    enabledAt: Date.now()
  },
  'custom-avatars': {
    key: 'custom-avatars',
    name: 'Custom Avatars',
    description: 'Personalized avatar customization',
    status: 'founders-only',
    minFounderTier: 'platinum',
    enabledAt: Date.now()
  },
  'social-tables': {
    key: 'social-tables',
    name: 'Social Tables',
    description: 'Private tables for groups and friends',
    status: 'beta',
    enabledAt: Date.now()
  },
  'tournament-mode': {
    key: 'tournament-mode',
    name: 'Tournament Mode',
    description: 'Competitive tournament system',
    status: 'beta',
    enabledAt: Date.now()
  },
  'live-streaming': {
    key: 'live-streaming',
    name: 'Live Streaming',
    description: 'Stream gameplay to audience',
    status: 'founders-only',
    minFounderTier: 'silver',
    enabledAt: Date.now()
  }
};

/**
 * Beta Feature Flag Manager
 */
export class BetaFlagManager {
  private features: Map<string, BetaFeature>;
  private betaEndDate: number;

  constructor(betaEndDate?: number) {
    this.features = new Map(Object.entries(BETA_FEATURES));
    // Default beta period: 90 days
    this.betaEndDate = betaEndDate || Date.now() + (90 * 24 * 60 * 60 * 1000);
  }

  /**
   * Check if feature is enabled for user
   */
  isEnabled(
    featureKey: string,
    userFounderTier?: 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond'
  ): boolean {
    const feature = this.features.get(featureKey);
    
    if (!feature) {
      return false;
    }

    // Check if feature is enabled
    if (!feature.enabledAt || feature.enabledAt > Date.now()) {
      return false;
    }

    // Check status
    switch (feature.status) {
      case 'disabled':
        return false;
      
      case 'public':
        return true;
      
      case 'beta':
        // Beta features available during beta period
        return Date.now() < this.betaEndDate;
      
      case 'founders-only':
        // Check if user is founder
        if (!userFounderTier) {
          return false;
        }
        
        // Check if user meets minimum tier
        if (feature.minFounderTier) {
          return this.meetsMinimumTier(userFounderTier, feature.minFounderTier);
        }
        
        return true;
      
      default:
        return false;
    }
  }

  /**
   * Check if user tier meets minimum requirement
   */
  private meetsMinimumTier(
    userTier: string,
    minTier: string
  ): boolean {
    const tierOrder = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
    const userLevel = tierOrder.indexOf(userTier);
    const minLevel = tierOrder.indexOf(minTier);
    
    return userLevel >= minLevel;
  }

  /**
   * Get feature information
   */
  getFeature(featureKey: string): BetaFeature | undefined {
    return this.features.get(featureKey);
  }

  /**
   * Get all features
   */
  getAllFeatures(): BetaFeature[] {
    return Array.from(this.features.values());
  }

  /**
   * Get features available to user
   */
  getAvailableFeatures(
    userFounderTier?: 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond'
  ): BetaFeature[] {
    const available: BetaFeature[] = [];
    
    for (const feature of this.features.values()) {
      if (this.isEnabled(feature.key, userFounderTier)) {
        available.push(feature);
      }
    }
    
    return available;
  }

  /**
   * Enable feature
   */
  enableFeature(featureKey: string, status: FeatureStatus = 'beta'): void {
    const feature = this.features.get(featureKey);
    
    if (!feature) {
      throw new Error(`Feature not found: ${featureKey}`);
    }

    feature.status = status;
    feature.enabledAt = Date.now();
  }

  /**
   * Disable feature
   */
  disableFeature(featureKey: string): void {
    const feature = this.features.get(featureKey);
    
    if (!feature) {
      throw new Error(`Feature not found: ${featureKey}`);
    }

    feature.status = 'disabled';
  }

  /**
   * Make feature public
   */
  makePublic(featureKey: string): void {
    const feature = this.features.get(featureKey);
    
    if (!feature) {
      throw new Error(`Feature not found: ${featureKey}`);
    }

    feature.status = 'public';
    feature.publicReleaseDate = Date.now();
  }

  /**
   * Set feature release date
   */
  scheduleRelease(featureKey: string, releaseDate: number): void {
    const feature = this.features.get(featureKey);
    
    if (!feature) {
      throw new Error(`Feature not found: ${featureKey}`);
    }

    feature.publicReleaseDate = releaseDate;
  }

  /**
   * Get features by status
   */
  getFeaturesByStatus(status: FeatureStatus): BetaFeature[] {
    return Array.from(this.features.values()).filter(f => f.status === status);
  }

  /**
   * Get feature statistics
   */
  getStats(): {
    total: number;
    byStatus: Record<FeatureStatus, number>;
    foundersOnly: number;
    publicReady: number;
  } {
    const stats = {
      total: this.features.size,
      byStatus: {
        disabled: 0,
        'founders-only': 0,
        beta: 0,
        public: 0
      } as Record<FeatureStatus, number>,
      foundersOnly: 0,
      publicReady: 0
    };

    for (const feature of this.features.values()) {
      stats.byStatus[feature.status]++;
      
      if (feature.status === 'founders-only') {
        stats.foundersOnly++;
      }
      
      if (feature.publicReleaseDate && feature.publicReleaseDate <= Date.now()) {
        stats.publicReady++;
      }
    }

    return stats;
  }

  /**
   * Add custom feature
   */
  addFeature(feature: BetaFeature): void {
    this.features.set(feature.key, feature);
  }

  /**
   * Remove feature
   */
  removeFeature(featureKey: string): boolean {
    return this.features.delete(featureKey);
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
   * Check feature dependencies
   */
  checkDependencies(featureKey: string): {
    satisfied: boolean;
    missing: string[];
  } {
    const feature = this.features.get(featureKey);
    
    if (!feature || !feature.dependencies) {
      return { satisfied: true, missing: [] };
    }

    const missing: string[] = [];
    
    for (const depKey of feature.dependencies) {
      const dep = this.features.get(depKey);
      if (!dep || dep.status === 'disabled') {
        missing.push(depKey);
      }
    }

    return {
      satisfied: missing.length === 0,
      missing
    };
  }
}

export default BetaFlagManager;
