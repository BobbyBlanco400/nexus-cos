/**
 * VR Lounge Card - Virtual Reality Access System
 * 
 * Manages access to premium VR experiences in Casino Nexus.
 * Requires NexCoin for entry and provides immersive casino experience.
 * 
 * @module casino/vr-lounge.card
 * @compliance VR-ENABLED
 */

export interface VRLoungeCard {
  userId: string;
  cardId: string;
  tier: 'standard' | 'premium' | 'founder';
  issueDate: number;
  expiresAt: number;
  sessionsRemaining: number;
  features: string[];
}

export interface VRLoungeSession {
  sessionId: string;
  userId: string;
  cardId: string;
  startTime: number;
  endTime?: number;
  duration: number;
  location: string;
}

export interface VRLoungeLocation {
  id: string;
  name: string;
  capacity: number;
  currentOccupancy: number;
  features: string[];
  minTier: 'standard' | 'premium' | 'founder';
}

/**
 * VR Lounge Access Costs
 */
export const VR_LOUNGE_COSTS = {
  ENTRY: 100,
  SESSION_HOUR: 50,
  PREMIUM_UPGRADE: 200,
  FOUNDER_ACCESS: 0 // Included in founder tier
};

/**
 * VR Lounge Locations
 */
export const VR_LOCATIONS: Record<string, VRLoungeLocation> = {
  'main-floor': {
    id: 'main-floor',
    name: 'Main VR Casino Floor',
    capacity: 100,
    currentOccupancy: 0,
    features: ['Slots', 'Roulette', 'Social Hub'],
    minTier: 'standard'
  },
  'premium-lounge': {
    id: 'premium-lounge',
    name: 'Premium VR Lounge',
    capacity: 50,
    currentOccupancy: 0,
    features: ['Private Tables', 'VIP Slots', 'Concierge'],
    minTier: 'premium'
  },
  'founders-sanctuary': {
    id: 'founders-sanctuary',
    name: 'Founders Sanctuary',
    capacity: 25,
    currentOccupancy: 0,
    features: ['Exclusive Games', 'Beta Features', 'Founder Events'],
    minTier: 'founder'
  },
  'high-roller-suite': {
    id: 'high-roller-suite',
    name: 'High Roller VR Suite',
    capacity: 20,
    currentOccupancy: 0,
    features: ['High Stakes Tables', 'Private Dealers', 'Luxury Experience'],
    minTier: 'premium'
  }
};

/**
 * VR Lounge Card Manager
 */
export class VRLoungeCardManager {
  private cards: Map<string, VRLoungeCard>;
  private sessions: Map<string, VRLoungeSession>;
  private locations: Map<string, VRLoungeLocation>;

  constructor() {
    this.cards = new Map();
    this.sessions = new Map();
    this.locations = new Map(Object.entries(VR_LOCATIONS));
  }

  /**
   * Issue VR Lounge access card
   */
  issueCard(
    userId: string,
    tier: 'standard' | 'premium' | 'founder',
    sessions: number = 10
  ): VRLoungeCard {
    const cardId = this.generateCardId();
    const now = Date.now();
    
    const card: VRLoungeCard = {
      userId,
      cardId,
      tier,
      issueDate: now,
      expiresAt: now + (30 * 24 * 60 * 60 * 1000), // 30 days
      sessionsRemaining: sessions,
      features: this.getFeaturesByTier(tier)
    };

    this.cards.set(cardId, card);
    return card;
  }

  /**
   * Get features by tier
   */
  private getFeaturesByTier(tier: string): string[] {
    const features = {
      standard: ['Basic VR Access', 'Social Interaction', 'Standard Games'],
      premium: ['Basic VR Access', 'Social Interaction', 'All Games', 'Private Tables', 'Priority Entry'],
      founder: ['Full VR Access', 'All Games', 'Exclusive Content', 'Beta Features', 'No Session Limits']
    };

    return features[tier as keyof typeof features] || features.standard;
  }

  /**
   * Generate unique card ID
   */
  private generateCardId(): string {
    return `VRL-${Date.now()}-${Math.random().toString(36).substring(2, 11).toUpperCase()}`;
  }

  /**
   * Generate unique session ID
   */
  private generateSessionId(): string {
    return `VRS-${Date.now()}-${Math.random().toString(36).substring(2, 11).toUpperCase()}`;
  }

  /**
   * Start VR session
   */
  startSession(cardId: string, locationId: string): VRLoungeSession {
    const card = this.cards.get(cardId);
    
    if (!card) {
      throw new Error('Invalid VR Lounge card');
    }

    if (card.expiresAt < Date.now()) {
      throw new Error('VR Lounge card has expired');
    }

    if (card.tier !== 'founder' && card.sessionsRemaining <= 0) {
      throw new Error('No sessions remaining on card');
    }

    const location = this.locations.get(locationId);
    
    if (!location) {
      throw new Error('Invalid VR Lounge location');
    }

    if (location.currentOccupancy >= location.capacity) {
      throw new Error('VR Lounge location is at capacity');
    }

    if (!this.canAccessLocation(card.tier, location.minTier)) {
      throw new Error(`Insufficient tier for location. Required: ${location.minTier}`);
    }

    const session: VRLoungeSession = {
      sessionId: this.generateSessionId(),
      userId: card.userId,
      cardId,
      startTime: Date.now(),
      duration: 0,
      location: locationId
    };

    // Deduct session (founders have unlimited)
    if (card.tier !== 'founder') {
      card.sessionsRemaining--;
    }

    // Update location occupancy
    location.currentOccupancy++;

    this.sessions.set(session.sessionId, session);
    return session;
  }

  /**
   * End VR session
   */
  endSession(sessionId: string): VRLoungeSession {
    const session = this.sessions.get(sessionId);
    
    if (!session) {
      throw new Error('Session not found');
    }

    if (session.endTime) {
      throw new Error('Session already ended');
    }

    session.endTime = Date.now();
    session.duration = session.endTime - session.startTime;

    // Update location occupancy
    const location = this.locations.get(session.location);
    if (location && location.currentOccupancy > 0) {
      location.currentOccupancy--;
    }

    return session;
  }

  /**
   * Check if tier can access location
   */
  private canAccessLocation(userTier: string, requiredTier: string): boolean {
    const tierHierarchy = ['standard', 'premium', 'founder'];
    const userLevel = tierHierarchy.indexOf(userTier);
    const requiredLevel = tierHierarchy.indexOf(requiredTier);
    
    return userLevel >= requiredLevel;
  }

  /**
   * Get card information
   */
  getCard(cardId: string): VRLoungeCard | undefined {
    return this.cards.get(cardId);
  }

  /**
   * Get active session for user
   */
  getActiveSession(userId: string): VRLoungeSession | undefined {
    for (const session of this.sessions.values()) {
      if (session.userId === userId && !session.endTime) {
        return session;
      }
    }
    return undefined;
  }

  /**
   * Renew card sessions
   */
  renewCard(cardId: string, additionalSessions: number): VRLoungeCard {
    const card = this.cards.get(cardId);
    
    if (!card) {
      throw new Error('Card not found');
    }

    card.sessionsRemaining += additionalSessions;
    card.expiresAt = Math.max(card.expiresAt, Date.now() + (30 * 24 * 60 * 60 * 1000));

    return card;
  }

  /**
   * Upgrade card tier
   */
  upgradeCard(cardId: string, newTier: 'premium' | 'founder'): VRLoungeCard {
    const card = this.cards.get(cardId);
    
    if (!card) {
      throw new Error('Card not found');
    }

    card.tier = newTier;
    card.features = this.getFeaturesByTier(newTier);

    return card;
  }

  /**
   * Get location information
   */
  getLocation(locationId: string): VRLoungeLocation | undefined {
    return this.locations.get(locationId);
  }

  /**
   * Get all available locations for tier
   */
  getAvailableLocations(tier: string): VRLoungeLocation[] {
    const available: VRLoungeLocation[] = [];
    
    for (const location of this.locations.values()) {
      if (this.canAccessLocation(tier, location.minTier)) {
        available.push(location);
      }
    }

    return available;
  }

  /**
   * Get location statistics
   */
  getLocationStats(): Record<string, { occupancy: number; capacity: number; available: number }> {
    const stats: Record<string, any> = {};
    
    for (const [id, location] of this.locations.entries()) {
      stats[id] = {
        occupancy: location.currentOccupancy,
        capacity: location.capacity,
        available: location.capacity - location.currentOccupancy
      };
    }

    return stats;
  }
}

export default VRLoungeCardManager;
