/**
 * AI Dealer Router - Intelligent Dealer Assignment System
 * 
 * Routes players to appropriate AI dealers based on:
 * - Jurisdiction compliance requirements
 * - AI persona preferences
 * - Compliance profile matching
 * - Table availability
 * 
 * @module casino/dealer.ai.router
 * @compliance AI-ETHICAL
 */

export type AIPersona = 
  | 'professional'
  | 'friendly'
  | 'luxury'
  | 'expert'
  | 'entertaining';

export type AIComplianceProfile = 
  | 'conservative'
  | 'standard'
  | 'progressive';

export interface AIDealer {
  id: string;
  name: string;
  persona: AIPersona;
  complianceProfile: AIComplianceProfile;
  allowedJurisdictions: string[];
  languages: string[];
  specialties: string[];
  rating: number;
  activeGames: number;
  maxGames: number;
}

export interface DealerAssignment {
  dealerId: string;
  playerId: string;
  gameId: string;
  jurisdiction: string;
  assignedAt: number;
  complianceChecks: {
    jurisdictionValid: boolean;
    personaAllowed: boolean;
    languageSupported: boolean;
  };
}

/**
 * Pre-configured AI Dealer profiles
 */
export const AI_DEALER_PROFILES: Record<string, AIDealer> = {
  'sophia-pro': {
    id: 'sophia-pro',
    name: 'Sophia',
    persona: 'professional',
    complianceProfile: 'conservative',
    allowedJurisdictions: ['US_CA', 'EU', 'LATAM', 'ASIA', 'GLOBAL'],
    languages: ['en', 'es', 'fr'],
    specialties: ['blackjack', 'baccarat'],
    rating: 4.8,
    activeGames: 0,
    maxGames: 10
  },
  'marco-friendly': {
    id: 'marco-friendly',
    name: 'Marco',
    persona: 'friendly',
    complianceProfile: 'standard',
    allowedJurisdictions: ['EU', 'LATAM', 'GLOBAL'],
    languages: ['en', 'es', 'it'],
    specialties: ['poker', 'roulette'],
    rating: 4.7,
    activeGames: 0,
    maxGames: 8
  },
  'victoria-luxury': {
    id: 'victoria-luxury',
    name: 'Victoria',
    persona: 'luxury',
    complianceProfile: 'progressive',
    allowedJurisdictions: ['EU', 'ASIA', 'GLOBAL'],
    languages: ['en', 'zh', 'ja'],
    specialties: ['baccarat', 'high-roller'],
    rating: 4.9,
    activeGames: 0,
    maxGames: 5
  },
  'alex-expert': {
    id: 'alex-expert',
    name: 'Alex',
    persona: 'expert',
    complianceProfile: 'standard',
    allowedJurisdictions: ['US_CA', 'EU', 'LATAM', 'ASIA', 'GLOBAL'],
    languages: ['en', 'de', 'fr'],
    specialties: ['poker', 'blackjack', 'skill-games'],
    rating: 4.9,
    activeGames: 0,
    maxGames: 12
  },
  'luna-entertaining': {
    id: 'luna-entertaining',
    name: 'Luna',
    persona: 'entertaining',
    complianceProfile: 'progressive',
    allowedJurisdictions: ['EU', 'LATAM', 'GLOBAL'],
    languages: ['en', 'es', 'pt'],
    specialties: ['roulette', 'slots', 'entertainment'],
    rating: 4.6,
    activeGames: 0,
    maxGames: 15
  }
};

/**
 * AI Dealer Router
 */
export class AIDealerRouter {
  private dealers: Map<string, AIDealer>;
  private assignments: Map<string, DealerAssignment>;

  constructor() {
    this.dealers = new Map(Object.entries(AI_DEALER_PROFILES));
    this.assignments = new Map();
  }

  /**
   * Assign dealer to player based on requirements
   */
  assign(options: {
    playerId: string;
    gameId: string;
    gameType: string;
    jurisdiction: string;
    preferredPersona?: AIPersona;
    language?: string;
  }): DealerAssignment {
    const { playerId, gameId, gameType, jurisdiction, preferredPersona, language } = options;

    // Find suitable dealers
    const candidates = this.findCandidates(
      jurisdiction,
      gameType,
      preferredPersona,
      language
    );

    if (candidates.length === 0) {
      throw new Error('No suitable AI dealers available for this request');
    }

    // Select best candidate (lowest active games, highest rating)
    const dealer = this.selectBestCandidate(candidates);

    // Create assignment
    const assignment: DealerAssignment = {
      dealerId: dealer.id,
      playerId,
      gameId,
      jurisdiction,
      assignedAt: Date.now(),
      complianceChecks: {
        jurisdictionValid: dealer.allowedJurisdictions.includes(jurisdiction),
        personaAllowed: this.isPersonaAllowed(dealer.persona, jurisdiction),
        languageSupported: language ? dealer.languages.includes(language) : true
      }
    };

    // Update dealer availability
    dealer.activeGames++;

    this.assignments.set(gameId, assignment);
    return assignment;
  }

  /**
   * Find candidate dealers
   */
  private findCandidates(
    jurisdiction: string,
    gameType: string,
    preferredPersona?: AIPersona,
    language?: string
  ): AIDealer[] {
    const candidates: AIDealer[] = [];

    for (const dealer of this.dealers.values()) {
      // Check jurisdiction
      if (!dealer.allowedJurisdictions.includes(jurisdiction)) {
        continue;
      }

      // Check availability
      if (dealer.activeGames >= dealer.maxGames) {
        continue;
      }

      // Check specialty
      if (!dealer.specialties.includes(gameType) && !dealer.specialties.includes('all-games')) {
        continue;
      }

      // Check language
      if (language && !dealer.languages.includes(language)) {
        continue;
      }

      // Check persona preference
      if (preferredPersona && dealer.persona !== preferredPersona) {
        continue;
      }

      // Check persona is allowed in jurisdiction
      if (!this.isPersonaAllowed(dealer.persona, jurisdiction)) {
        continue;
      }

      candidates.push(dealer);
    }

    return candidates;
  }

  /**
   * Select best candidate from available dealers
   */
  private selectBestCandidate(candidates: AIDealer[]): AIDealer {
    return candidates.reduce((best, current) => {
      // Prefer less busy dealers
      if (current.activeGames < best.activeGames) {
        return current;
      }
      if (current.activeGames > best.activeGames) {
        return best;
      }

      // If equally busy, prefer higher rating
      return current.rating > best.rating ? current : best;
    });
  }

  /**
   * Check if AI persona is allowed in jurisdiction
   */
  private isPersonaAllowed(persona: AIPersona, jurisdiction: string): boolean {
    // US_CA is conservative - only professional and expert
    if (jurisdiction === 'US_CA') {
      return persona === 'professional' || persona === 'expert';
    }

    // Asia prefers formal personas
    if (jurisdiction === 'ASIA') {
      return persona !== 'entertaining';
    }

    // All personas allowed in other jurisdictions
    return true;
  }

  /**
   * Release dealer assignment
   */
  release(gameId: string): boolean {
    const assignment = this.assignments.get(gameId);
    
    if (!assignment) {
      return false;
    }

    const dealer = this.dealers.get(assignment.dealerId);
    if (dealer && dealer.activeGames > 0) {
      dealer.activeGames--;
    }

    this.assignments.delete(gameId);
    return true;
  }

  /**
   * Get dealer information
   */
  getDealer(dealerId: string): AIDealer | undefined {
    return this.dealers.get(dealerId);
  }

  /**
   * Get assignment information
   */
  getAssignment(gameId: string): DealerAssignment | undefined {
    return this.assignments.get(gameId);
  }

  /**
   * Get available dealers for jurisdiction
   */
  getAvailableDealers(jurisdiction: string, gameType?: string): AIDealer[] {
    const available: AIDealer[] = [];

    for (const dealer of this.dealers.values()) {
      if (!dealer.allowedJurisdictions.includes(jurisdiction)) {
        continue;
      }

      if (dealer.activeGames >= dealer.maxGames) {
        continue;
      }

      if (gameType && !dealer.specialties.includes(gameType) && !dealer.specialties.includes('all-games')) {
        continue;
      }

      if (!this.isPersonaAllowed(dealer.persona, jurisdiction)) {
        continue;
      }

      available.push(dealer);
    }

    return available;
  }

  /**
   * Get dealer statistics
   */
  getDealerStats(): {
    total: number;
    active: number;
    available: number;
    utilization: number;
  } {
    let totalCapacity = 0;
    let activeGames = 0;

    for (const dealer of this.dealers.values()) {
      totalCapacity += dealer.maxGames;
      activeGames += dealer.activeGames;
    }

    return {
      total: this.dealers.size,
      active: activeGames,
      available: totalCapacity - activeGames,
      utilization: totalCapacity > 0 ? Math.round((activeGames / totalCapacity) * 100) : 0
    };
  }

  /**
   * Add custom dealer
   */
  addDealer(dealer: AIDealer): void {
    this.dealers.set(dealer.id, dealer);
  }

  /**
   * Remove dealer
   */
  removeDealer(dealerId: string): boolean {
    const dealer = this.dealers.get(dealerId);
    
    if (!dealer || dealer.activeGames > 0) {
      return false;
    }

    return this.dealers.delete(dealerId);
  }

  /**
   * Update dealer configuration
   */
  updateDealer(dealerId: string, updates: Partial<AIDealer>): AIDealer | null {
    const dealer = this.dealers.get(dealerId);
    
    if (!dealer) {
      return null;
    }

    Object.assign(dealer, updates);
    return dealer;
  }
}

export default AIDealerRouter;
