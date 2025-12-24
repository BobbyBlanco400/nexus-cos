/**
 * Access Expiry - Time-Boxed Access Management
 * 
 * Manages time-limited access for founder features.
 * "Nothing here is permanent except your influence."
 * 
 * @module founders/access.expiry
 * @compliance TIME-GATED
 * @visibility NON-PUBLIC
 */

export interface AccessGrant {
  userId: string;
  feature: string;
  grantedAt: number;
  expiresAt: number;
  renewable: boolean;
  autoRenew: boolean;
  tier?: string;
}

export interface ExpiryPolicy {
  feature: string;
  defaultDuration: number; // milliseconds
  maxDuration: number;
  gracePeriod: number;
  warningThreshold: number; // days before expiry to warn
  renewable: boolean;
}

/**
 * Default expiry policies for features
 */
export const EXPIRY_POLICIES: Record<string, ExpiryPolicy> = {
  'founder-beta-access': {
    feature: 'founder-beta-access',
    defaultDuration: 90 * 24 * 60 * 60 * 1000, // 90 days
    maxDuration: 365 * 24 * 60 * 60 * 1000, // 1 year
    gracePeriod: 7 * 24 * 60 * 60 * 1000, // 7 days
    warningThreshold: 14, // days
    renewable: true
  },
  'vr-lounge': {
    feature: 'vr-lounge',
    defaultDuration: 90 * 24 * 60 * 60 * 1000,
    maxDuration: 365 * 24 * 60 * 60 * 1000,
    gracePeriod: 7 * 24 * 60 * 60 * 1000,
    warningThreshold: 7,
    renewable: true
  },
  'high-roller-suite': {
    feature: 'high-roller-suite',
    defaultDuration: 90 * 24 * 60 * 60 * 1000,
    maxDuration: 365 * 24 * 60 * 60 * 1000,
    gracePeriod: 7 * 24 * 60 * 60 * 1000,
    warningThreshold: 7,
    renewable: true
  },
  'ai-dealers': {
    feature: 'ai-dealers',
    defaultDuration: 90 * 24 * 60 * 60 * 1000,
    maxDuration: 365 * 24 * 60 * 60 * 1000,
    gracePeriod: 7 * 24 * 60 * 60 * 1000,
    warningThreshold: 7,
    renewable: true
  },
  'enhanced-multipliers': {
    feature: 'enhanced-multipliers',
    defaultDuration: 90 * 24 * 60 * 60 * 1000,
    maxDuration: 365 * 24 * 60 * 60 * 1000,
    gracePeriod: 0,
    warningThreshold: 14,
    renewable: true
  },
  'marketplace-priority': {
    feature: 'marketplace-priority',
    defaultDuration: 180 * 24 * 60 * 60 * 1000, // 180 days
    maxDuration: 365 * 24 * 60 * 60 * 1000,
    gracePeriod: 0,
    warningThreshold: 30,
    renewable: true
  }
};

/**
 * Access Expiry Manager
 */
export class AccessExpiryManager {
  private grants: Map<string, Map<string, AccessGrant>>;
  private policies: Map<string, ExpiryPolicy>;

  constructor() {
    this.grants = new Map();
    this.policies = new Map(Object.entries(EXPIRY_POLICIES));
  }

  /**
   * Grant access to feature
   */
  grantAccess(
    userId: string,
    feature: string,
    duration?: number,
    tier?: string,
    autoRenew: boolean = false
  ): AccessGrant {
    const policy = this.policies.get(feature);
    
    if (!policy) {
      throw new Error(`No expiry policy found for feature: ${feature}`);
    }

    const grantDuration = duration || policy.defaultDuration;
    
    if (grantDuration > policy.maxDuration) {
      throw new Error(`Duration exceeds maximum for feature: ${feature}`);
    }

    const grant: AccessGrant = {
      userId,
      feature,
      grantedAt: Date.now(),
      expiresAt: Date.now() + grantDuration,
      renewable: policy.renewable,
      autoRenew,
      tier
    };

    if (!this.grants.has(userId)) {
      this.grants.set(userId, new Map());
    }

    this.grants.get(userId)!.set(feature, grant);
    return grant;
  }

  /**
   * Check if user has active access to feature
   */
  hasAccess(userId: string, feature: string): boolean {
    const userGrants = this.grants.get(userId);
    
    if (!userGrants) {
      return false;
    }

    const grant = userGrants.get(feature);
    
    if (!grant) {
      return false;
    }

    const now = Date.now();
    
    // Check if expired
    if (now > grant.expiresAt) {
      const policy = this.policies.get(feature);
      
      // Check if within grace period
      if (policy && policy.gracePeriod > 0) {
        if (now <= grant.expiresAt + policy.gracePeriod) {
          return true; // Still in grace period
        }
      }
      
      return false;
    }

    return true;
  }

  /**
   * Get access grant
   */
  getGrant(userId: string, feature: string): AccessGrant | undefined {
    const userGrants = this.grants.get(userId);
    return userGrants?.get(feature);
  }

  /**
   * Get all grants for user
   */
  getUserGrants(userId: string): AccessGrant[] {
    const userGrants = this.grants.get(userId);
    return userGrants ? Array.from(userGrants.values()) : [];
  }

  /**
   * Renew access
   */
  renewAccess(
    userId: string,
    feature: string,
    additionalDuration?: number
  ): AccessGrant {
    const userGrants = this.grants.get(userId);
    const grant = userGrants?.get(feature);
    
    if (!grant) {
      throw new Error('No existing grant to renew');
    }

    if (!grant.renewable) {
      throw new Error('Feature access is not renewable');
    }

    const policy = this.policies.get(feature);
    
    if (!policy) {
      throw new Error(`No expiry policy found for feature: ${feature}`);
    }

    const duration = additionalDuration || policy.defaultDuration;
    const now = Date.now();
    
    // If already expired, start from now, otherwise extend from current expiry
    const baseTime = grant.expiresAt > now ? grant.expiresAt : now;
    const newExpiresAt = baseTime + duration;

    grant.expiresAt = newExpiresAt;
    grant.grantedAt = now;

    return grant;
  }

  /**
   * Revoke access
   */
  revokeAccess(userId: string, feature: string): boolean {
    const userGrants = this.grants.get(userId);
    
    if (!userGrants) {
      return false;
    }

    return userGrants.delete(feature);
  }

  /**
   * Get time remaining for access
   */
  getTimeRemaining(userId: string, feature: string): number {
    const grant = this.getGrant(userId, feature);
    
    if (!grant) {
      return 0;
    }

    return Math.max(0, grant.expiresAt - Date.now());
  }

  /**
   * Get days remaining for access
   */
  getDaysRemaining(userId: string, feature: string): number {
    const ms = this.getTimeRemaining(userId, feature);
    return Math.ceil(ms / (24 * 60 * 60 * 1000));
  }

  /**
   * Check if access needs warning
   */
  needsWarning(userId: string, feature: string): boolean {
    const grant = this.getGrant(userId, feature);
    const policy = this.policies.get(feature);
    
    if (!grant || !policy) {
      return false;
    }

    const daysRemaining = this.getDaysRemaining(userId, feature);
    return daysRemaining > 0 && daysRemaining <= policy.warningThreshold;
  }

  /**
   * Get all users needing warnings
   */
  getUsersNeedingWarnings(): Array<{ userId: string; feature: string; daysRemaining: number }> {
    const warnings: Array<{ userId: string; feature: string; daysRemaining: number }> = [];
    
    for (const [userId, userGrants] of this.grants.entries()) {
      for (const [feature, grant] of userGrants.entries()) {
        if (this.needsWarning(userId, feature)) {
          warnings.push({
            userId,
            feature,
            daysRemaining: this.getDaysRemaining(userId, feature)
          });
        }
      }
    }

    return warnings;
  }

  /**
   * Process auto-renewals
   */
  processAutoRenewals(): Array<{ userId: string; feature: string; renewed: boolean }> {
    const results: Array<{ userId: string; feature: string; renewed: boolean }> = [];
    
    for (const [userId, userGrants] of this.grants.entries()) {
      for (const [feature, grant] of userGrants.entries()) {
        if (grant.autoRenew && this.needsWarning(userId, feature)) {
          try {
            this.renewAccess(userId, feature);
            results.push({ userId, feature, renewed: true });
          } catch (error) {
            results.push({ userId, feature, renewed: false });
          }
        }
      }
    }

    return results;
  }

  /**
   * Clean up expired grants
   */
  cleanupExpired(): number {
    let cleaned = 0;
    const now = Date.now();
    
    for (const [userId, userGrants] of this.grants.entries()) {
      for (const [feature, grant] of userGrants.entries()) {
        const policy = this.policies.get(feature);
        const gracePeriodEnd = grant.expiresAt + (policy?.gracePeriod || 0);
        
        if (now > gracePeriodEnd) {
          userGrants.delete(feature);
          cleaned++;
        }
      }
      
      // Remove user entry if no grants left
      if (userGrants.size === 0) {
        this.grants.delete(userId);
      }
    }

    return cleaned;
  }

  /**
   * Get expiry statistics
   */
  getStats(): {
    totalGrants: number;
    activeGrants: number;
    expiredGrants: number;
    inGracePeriod: number;
    needingWarning: number;
  } {
    const now = Date.now();
    const stats = {
      totalGrants: 0,
      activeGrants: 0,
      expiredGrants: 0,
      inGracePeriod: 0,
      needingWarning: 0
    };

    for (const [userId, userGrants] of this.grants.entries()) {
      for (const [feature, grant] of userGrants.entries()) {
        stats.totalGrants++;
        
        if (now <= grant.expiresAt) {
          stats.activeGrants++;
          
          if (this.needsWarning(userId, feature)) {
            stats.needingWarning++;
          }
        } else {
          const policy = this.policies.get(feature);
          const gracePeriodEnd = grant.expiresAt + (policy?.gracePeriod || 0);
          
          if (now <= gracePeriodEnd) {
            stats.inGracePeriod++;
          } else {
            stats.expiredGrants++;
          }
        }
      }
    }

    return stats;
  }

  /**
   * Add or update expiry policy
   */
  setPolicy(policy: ExpiryPolicy): void {
    this.policies.set(policy.feature, policy);
  }

  /**
   * Get expiry policy
   */
  getPolicy(feature: string): ExpiryPolicy | undefined {
    return this.policies.get(feature);
  }

  /**
   * Grant lifetime access (for Diamond founders)
   */
  grantLifetimeAccess(userId: string, feature: string, tier: string = 'diamond'): AccessGrant {
    const grant: AccessGrant = {
      userId,
      feature,
      grantedAt: Date.now(),
      expiresAt: Infinity,
      renewable: false,
      autoRenew: false,
      tier
    };

    if (!this.grants.has(userId)) {
      this.grants.set(userId, new Map());
    }

    this.grants.get(userId)!.set(feature, grant);
    return grant;
  }
}

export default AccessExpiryManager;
