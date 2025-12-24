/**
 * Vegas Strip Router - Multi-Casino Navigation System
 * 
 * Manages navigation between multiple casinos in the federation.
 * Single wallet, single identity, multiple casino instances.
 * 
 * @module federation/strip.router
 * @compliance FEDERATION-ENABLED
 */

export interface CasinoInstance {
  id: string;
  name: string;
  theme: string;
  description: string;
  owner: string;
  status: 'active' | 'maintenance' | 'coming-soon';
  url: string;
  features: string[];
  minNexCoin?: number;
  tier?: string;
}

export interface NavigationRoute {
  from: string;
  to: string;
  userId: string;
  timestamp: number;
  walletBalance: number;
}

/**
 * Vegas Strip Casino Registry
 */
export const STRIP_CASINOS: Record<string, CasinoInstance> = {
  'casino-nexus': {
    id: 'casino-nexus',
    name: 'Casino Nexus',
    theme: 'main',
    description: 'The flagship casino - where it all begins',
    owner: 'PUABO Holdings',
    status: 'active',
    url: '/casino-nexus',
    features: ['slots', 'tables', 'vr-lounge', 'high-roller', 'ai-dealers']
  },
  'neon-vault': {
    id: 'neon-vault',
    name: 'Neon Vault',
    theme: 'cyberpunk',
    description: 'Futuristic cyberpunk-themed casino with cutting-edge games',
    owner: 'PUABO Holdings',
    status: 'active',
    url: '/neon-vault',
    features: ['slots', 'progressive', 'vr-lounge']
  },
  'high-roller-palace': {
    id: 'high-roller-palace',
    name: 'High Roller Palace',
    theme: 'luxury',
    description: 'Exclusive high-stakes casino for premium players',
    owner: 'PUABO Holdings',
    status: 'active',
    url: '/high-roller-palace',
    features: ['tables', 'high-roller', 'ai-dealers', 'vip-only'],
    minNexCoin: 5000,
    tier: 'premium'
  },
  'club-saditty': {
    id: 'club-saditty',
    name: 'Club Saditty',
    theme: 'tenant-platform',
    description: 'Community-run casino platform for creators',
    owner: 'Community',
    status: 'active',
    url: '/club-saditty',
    features: ['slots', 'tables', 'creator-games']
  },
  'founders-lounge': {
    id: 'founders-lounge',
    name: 'Founders Lounge',
    theme: 'exclusive',
    description: 'Private casino for founder tier members only',
    owner: 'PUABO Holdings',
    status: 'active',
    url: '/founders-lounge',
    features: ['founders-wheel', 'vr-lounge', 'exclusive-games'],
    tier: 'founder'
  }
};

/**
 * Vegas Strip Router
 */
export class StripRouter {
  private casinos: Map<string, CasinoInstance>;
  private navigationHistory: NavigationRoute[];
  private currentLocation: Map<string, string>; // userId -> casinoId

  constructor() {
    this.casinos = new Map(Object.entries(STRIP_CASINOS));
    this.navigationHistory = [];
    this.currentLocation = new Map();
  }

  /**
   * Get casino information
   */
  getCasino(casinoId: string): CasinoInstance | undefined {
    return this.casinos.get(casinoId);
  }

  /**
   * Get all active casinos
   */
  getActiveCasinos(): CasinoInstance[] {
    return Array.from(this.casinos.values()).filter(c => c.status === 'active');
  }

  /**
   * Get casinos available to user
   */
  getAvailableCasinos(
    userId: string,
    nexCoinBalance: number,
    tier?: string
  ): CasinoInstance[] {
    const available: CasinoInstance[] = [];

    for (const casino of this.casinos.values()) {
      // Skip inactive casinos
      if (casino.status !== 'active') {
        continue;
      }

      // Check minimum NexCoin requirement
      if (casino.minNexCoin && nexCoinBalance < casino.minNexCoin) {
        continue;
      }

      // Check tier requirement
      if (casino.tier === 'founder' && tier !== 'founder') {
        continue;
      }

      if (casino.tier === 'premium' && !tier) {
        continue;
      }

      available.push(casino);
    }

    return available;
  }

  /**
   * Navigate to casino
   */
  navigateTo(
    userId: string,
    casinoId: string,
    walletBalance: number
  ): NavigationRoute {
    const casino = this.casinos.get(casinoId);
    
    if (!casino) {
      throw new Error(`Casino not found: ${casinoId}`);
    }

    if (casino.status !== 'active') {
      throw new Error(`Casino is not active: ${casino.name}`);
    }

    const currentCasino = this.currentLocation.get(userId) || 'casino-nexus';

    const route: NavigationRoute = {
      from: currentCasino,
      to: casinoId,
      userId,
      timestamp: Date.now(),
      walletBalance
    };

    this.currentLocation.set(userId, casinoId);
    this.navigationHistory.push(route);

    return route;
  }

  /**
   * Get user's current location
   */
  getCurrentCasino(userId: string): string {
    return this.currentLocation.get(userId) || 'casino-nexus';
  }

  /**
   * Get user's navigation history
   */
  getNavigationHistory(userId: string, limit: number = 10): NavigationRoute[] {
    return this.navigationHistory
      .filter(r => r.userId === userId)
      .slice(-limit)
      .reverse();
  }

  /**
   * Return to main casino
   */
  returnToMain(userId: string, walletBalance: number): NavigationRoute {
    return this.navigateTo(userId, 'casino-nexus', walletBalance);
  }

  /**
   * Register new casino to the strip
   */
  registerCasino(casino: CasinoInstance): void {
    if (this.casinos.has(casino.id)) {
      throw new Error(`Casino already registered: ${casino.id}`);
    }

    this.casinos.set(casino.id, casino);
  }

  /**
   * Update casino status
   */
  updateCasinoStatus(casinoId: string, status: CasinoInstance['status']): void {
    const casino = this.casinos.get(casinoId);
    
    if (!casino) {
      throw new Error(`Casino not found: ${casinoId}`);
    }

    casino.status = status;
  }

  /**
   * Get casinos by theme
   */
  getCasinosByTheme(theme: string): CasinoInstance[] {
    return Array.from(this.casinos.values()).filter(c => c.theme === theme);
  }

  /**
   * Get casinos by owner
   */
  getCasinosByOwner(owner: string): CasinoInstance[] {
    return Array.from(this.casinos.values()).filter(c => c.owner === owner);
  }

  /**
   * Search casinos
   */
  searchCasinos(query: string): CasinoInstance[] {
    const lowerQuery = query.toLowerCase();
    
    return Array.from(this.casinos.values()).filter(casino => 
      casino.name.toLowerCase().includes(lowerQuery) ||
      casino.description.toLowerCase().includes(lowerQuery) ||
      casino.theme.toLowerCase().includes(lowerQuery)
    );
  }

  /**
   * Get strip statistics
   */
  getStripStats(): {
    totalCasinos: number;
    activeCasinos: number;
    comingSoon: number;
    maintenance: number;
    totalNavigations: number;
    activeUsers: number;
  } {
    const stats = {
      totalCasinos: this.casinos.size,
      activeCasinos: 0,
      comingSoon: 0,
      maintenance: 0,
      totalNavigations: this.navigationHistory.length,
      activeUsers: this.currentLocation.size
    };

    for (const casino of this.casinos.values()) {
      switch (casino.status) {
        case 'active':
          stats.activeCasinos++;
          break;
        case 'coming-soon':
          stats.comingSoon++;
          break;
        case 'maintenance':
          stats.maintenance++;
          break;
      }
    }

    return stats;
  }

  /**
   * Get popular casinos
   */
  getPopularCasinos(limit: number = 5): Array<{ casino: CasinoInstance; visits: number }> {
    const visitCounts = new Map<string, number>();

    // Count visits
    for (const route of this.navigationHistory) {
      visitCounts.set(route.to, (visitCounts.get(route.to) || 0) + 1);
    }

    // Sort by visit count
    const popular = Array.from(visitCounts.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, limit)
      .map(([casinoId, visits]) => ({
        casino: this.casinos.get(casinoId)!,
        visits
      }))
      .filter(item => item.casino);

    return popular;
  }

  /**
   * Get casino occupancy
   */
  getCasinoOccupancy(): Record<string, number> {
    const occupancy: Record<string, number> = {};

    for (const casino of this.casinos.values()) {
      occupancy[casino.id] = 0;
    }

    for (const casinoId of this.currentLocation.values()) {
      occupancy[casinoId] = (occupancy[casinoId] || 0) + 1;
    }

    return occupancy;
  }

  /**
   * Check if user can access casino
   */
  canAccess(
    userId: string,
    casinoId: string,
    nexCoinBalance: number,
    tier?: string
  ): { allowed: boolean; reason?: string } {
    const casino = this.casinos.get(casinoId);
    
    if (!casino) {
      return { allowed: false, reason: 'Casino not found' };
    }

    if (casino.status !== 'active') {
      return { allowed: false, reason: `Casino is ${casino.status}` };
    }

    if (casino.minNexCoin && nexCoinBalance < casino.minNexCoin) {
      return { 
        allowed: false, 
        reason: `Requires minimum ${casino.minNexCoin} NexCoin` 
      };
    }

    if (casino.tier === 'founder' && tier !== 'founder') {
      return { allowed: false, reason: 'Founder tier required' };
    }

    if (casino.tier === 'premium' && !tier) {
      return { allowed: false, reason: 'Premium tier required' };
    }

    return { allowed: true };
  }
}

export default StripRouter;
