/**
 * Jurisdiction Toggle - Runtime Compliance Module
 * 
 * Enables runtime jurisdiction switching for multi-region compliance.
 * Auto-adjusts features, language, and behavior based on user location.
 * 
 * @module enforcement/jurisdiction.toggle
 * @compliance REGULATOR-CRITICAL
 */

export type JurisdictionCode = 'US_CA' | 'EU' | 'LATAM' | 'ASIA' | 'GLOBAL';

export type ComplianceMode = 
  | 'skill-entertainment'
  | 'digital-credits'
  | 'virtual-experience'
  | 'access-based';

export interface JurisdictionProfile {
  code: JurisdictionCode;
  mode: ComplianceMode;
  language: string;
  features: {
    timedJackpots: boolean;
    marketplaceResale: boolean;
    aiDealerPersonalities: boolean;
    progressiveJackpots: boolean;
    vipSuites: boolean;
  };
  strings: {
    currency: string;
    playAction: string;
    winningTerm: string;
    disclaimer: string;
  };
}

/**
 * Jurisdiction profile configurations
 */
export const JURISDICTION_PROFILES: Record<JurisdictionCode, JurisdictionProfile> = {
  US_CA: {
    code: 'US_CA',
    mode: 'skill-entertainment',
    language: 'Play using NexCoin credits',
    features: {
      timedJackpots: false,
      marketplaceResale: false,
      aiDealerPersonalities: true,
      progressiveJackpots: true,
      vipSuites: true
    },
    strings: {
      currency: 'NexCoin Credits',
      playAction: 'Play for Entertainment',
      winningTerm: 'Reward Points',
      disclaimer: 'Entertainment only. No cash prizes. NexCoin has no cash value.'
    }
  },
  EU: {
    code: 'EU',
    mode: 'digital-credits',
    language: 'Digital access tokens',
    features: {
      timedJackpots: true,
      marketplaceResale: true,
      aiDealerPersonalities: true,
      progressiveJackpots: true,
      vipSuites: true
    },
    strings: {
      currency: 'Digital Access Tokens',
      playAction: 'Access Premium Content',
      winningTerm: 'Utility Rewards',
      disclaimer: 'Virtual platform. Tokens are digital access credits only.'
    }
  },
  LATAM: {
    code: 'LATAM',
    mode: 'virtual-experience',
    language: 'Virtual experience platform',
    features: {
      timedJackpots: true,
      marketplaceResale: false,
      aiDealerPersonalities: true,
      progressiveJackpots: true,
      vipSuites: true
    },
    strings: {
      currency: 'Experience Credits',
      playAction: 'Enter Virtual Experience',
      winningTerm: 'Experience Rewards',
      disclaimer: 'Virtual entertainment platform. No monetary prizes.'
    }
  },
  ASIA: {
    code: 'ASIA',
    mode: 'access-based',
    language: 'Access-based entertainment',
    features: {
      timedJackpots: false,
      marketplaceResale: true,
      aiDealerPersonalities: true,
      progressiveJackpots: false,
      vipSuites: true
    },
    strings: {
      currency: 'Access Credits',
      playAction: 'Access Content',
      winningTerm: 'Access Rewards',
      disclaimer: 'Access-based entertainment. Credits for platform access only.'
    }
  },
  GLOBAL: {
    code: 'GLOBAL',
    mode: 'virtual-experience',
    language: 'No cash prizes',
    features: {
      timedJackpots: true,
      marketplaceResale: true,
      aiDealerPersonalities: true,
      progressiveJackpots: true,
      vipSuites: true
    },
    strings: {
      currency: 'NexCoin',
      playAction: 'Play',
      winningTerm: 'Rewards',
      disclaimer: 'Virtual platform. No cash prizes. NexCoin is a utility token.'
    }
  }
};

/**
 * Jurisdiction Toggle Manager
 */
export class JurisdictionToggle {
  private currentJurisdiction: JurisdictionCode;
  private profile: JurisdictionProfile;
  private listeners: Array<(profile: JurisdictionProfile) => void>;

  constructor(initialJurisdiction: JurisdictionCode = 'GLOBAL') {
    this.currentJurisdiction = initialJurisdiction;
    this.profile = JURISDICTION_PROFILES[initialJurisdiction];
    this.listeners = [];
  }

  /**
   * Set jurisdiction based on user location or preference
   */
  setJurisdiction(code: JurisdictionCode): void {
    if (!JURISDICTION_PROFILES[code]) {
      throw new Error(`Invalid jurisdiction code: ${code}`);
    }

    this.currentJurisdiction = code;
    this.profile = JURISDICTION_PROFILES[code];

    // Notify all listeners of jurisdiction change
    this.notifyListeners();
  }

  /**
   * Get current jurisdiction profile
   */
  getProfile(): JurisdictionProfile {
    return { ...this.profile };
  }

  /**
   * Check if feature is enabled in current jurisdiction
   */
  isFeatureEnabled(feature: keyof JurisdictionProfile['features']): boolean {
    return this.profile.features[feature];
  }

  /**
   * Get compliance string for current jurisdiction
   */
  getString(key: keyof JurisdictionProfile['strings']): string {
    return this.profile.strings[key];
  }

  /**
   * Get current jurisdiction code
   */
  getJurisdiction(): JurisdictionCode {
    return this.currentJurisdiction;
  }

  /**
   * Get compliance mode
   */
  getComplianceMode(): ComplianceMode {
    return this.profile.mode;
  }

  /**
   * Register listener for jurisdiction changes
   */
  onChange(callback: (profile: JurisdictionProfile) => void): void {
    this.listeners.push(callback);
  }

  /**
   * Notify all listeners of profile change
   */
  private notifyListeners(): void {
    for (const listener of this.listeners) {
      try {
        listener(this.getProfile());
      } catch (error) {
        console.error('Jurisdiction listener error:', error);
      }
    }
  }

  /**
   * Detect jurisdiction from IP or locale (placeholder)
   */
  static detectJurisdiction(ip?: string, locale?: string): JurisdictionCode {
    // Placeholder logic - production should use proper GeoIP
    if (locale) {
      if (locale.startsWith('en-US') || locale.startsWith('en-CA')) {
        return 'US_CA';
      }
      if (locale.startsWith('en-GB') || locale.startsWith('de') || locale.startsWith('fr')) {
        return 'EU';
      }
      if (locale.startsWith('es') || locale.startsWith('pt')) {
        return 'LATAM';
      }
      if (locale.startsWith('zh') || locale.startsWith('ja') || locale.startsWith('ko')) {
        return 'ASIA';
      }
    }
    
    return 'GLOBAL';
  }

  /**
   * Get all available jurisdictions
   */
  static getAvailableJurisdictions(): JurisdictionCode[] {
    return Object.keys(JURISDICTION_PROFILES) as JurisdictionCode[];
  }

  /**
   * Validate jurisdiction compatibility
   */
  static isCompatible(code: JurisdictionCode, requiredFeatures: string[]): boolean {
    const profile = JURISDICTION_PROFILES[code];
    return requiredFeatures.every(
      feature => profile.features[feature as keyof typeof profile.features]
    );
  }
}

export default JurisdictionToggle;
