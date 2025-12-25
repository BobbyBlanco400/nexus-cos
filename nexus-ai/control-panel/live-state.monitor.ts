/**
 * N.E.X.U.S AI Control Panel - Live State Monitor
 * 
 * Real-time monitoring of casino ecosystem state
 * 
 * @module control-panel/live-state.monitor
 */

export interface CasinoState {
  casinoId: string;
  name: string;
  status: 'online' | 'offline' | 'maintenance';
  playersOnline: number;
  betsPerMinute: number;
  activeGames: number;
  compliance: {
    handshake: boolean;
    nexcoin: boolean;
    jurisdiction: boolean;
  };
  lastUpdate: number;
}

export interface FederationState {
  federationId: string;
  name: string;
  casinos: string[];
  sharedPots: number;
  totalPlayers: number;
  status: 'active' | 'inactive';
}

export interface SystemState {
  handshakeValid: boolean;
  handshakeVersion: string;
  nexcoinEnforced: boolean;
  casinoGridStatus: string;
  complianceDrift: boolean;
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH';
  totalPlayersOnline: number;
  totalBetsPerMinute: number;
  activeJackpotPools: number;
}

export interface NexCoinTreasury {
  totalSupply: number;
  inCirculation: number;
  locked: number;
  burnedTotal: number;
  mintingRate: number;
}

export class LiveStateMonitor {
  private casinos: Map<string, CasinoState>;
  private federations: Map<string, FederationState>;
  private systemState: SystemState;
  private treasury: NexCoinTreasury;
  private updateCallbacks: Set<(state: any) => void>;

  constructor() {
    this.casinos = new Map();
    this.federations = new Map();
    this.updateCallbacks = new Set();
    
    // Initialize with default state
    this.systemState = {
      handshakeValid: true,
      handshakeVersion: '55-45-17',
      nexcoinEnforced: true,
      casinoGridStatus: '9/9',
      complianceDrift: false,
      riskLevel: 'LOW',
      totalPlayersOnline: 14223,
      totalBetsPerMinute: 9401,
      activeJackpotPools: 6
    };

    this.treasury = {
      totalSupply: 1000000000,
      inCirculation: 850000000,
      locked: 150000000,
      burnedTotal: 0,
      mintingRate: 0
    };

    this.initializeDefaultCasinos();
    this.initializeDefaultFederations();
  }

  /**
   * Initialize default casino states
   */
  private initializeDefaultCasinos(): void {
    const defaultCasinos: CasinoState[] = [
      {
        casinoId: 'casino-nexus-vegas',
        name: 'Casino Nexus Vegas',
        status: 'online',
        playersOnline: 5432,
        betsPerMinute: 3200,
        activeGames: 234,
        compliance: { handshake: true, nexcoin: true, jurisdiction: true },
        lastUpdate: Date.now()
      },
      {
        casinoId: 'casino-nexus-bay',
        name: 'Casino Nexus Bay',
        status: 'online',
        playersOnline: 4123,
        betsPerMinute: 2850,
        activeGames: 189,
        compliance: { handshake: true, nexcoin: true, jurisdiction: true },
        lastUpdate: Date.now()
      },
      {
        casinoId: 'casino-nexus-miami',
        name: 'Casino Nexus Miami',
        status: 'offline',
        playersOnline: 0,
        betsPerMinute: 0,
        activeGames: 0,
        compliance: { handshake: true, nexcoin: true, jurisdiction: true },
        lastUpdate: Date.now()
      }
    ];

    for (const casino of defaultCasinos) {
      this.casinos.set(casino.casinoId, casino);
    }
  }

  /**
   * Initialize default federation states
   */
  private initializeDefaultFederations(): void {
    const defaultFederations: FederationState[] = [
      {
        federationId: 'FED-001',
        name: 'North American Network',
        casinos: ['casino-nexus-vegas', 'casino-nexus-bay'],
        sharedPots: 2,
        totalPlayers: 9555,
        status: 'active'
      },
      {
        federationId: 'FED-002',
        name: 'European Alliance',
        casinos: ['casino-nexus-london', 'casino-nexus-berlin'],
        sharedPots: 1,
        totalPlayers: 3210,
        status: 'active'
      },
      {
        federationId: 'FED-003',
        name: 'Asian Pacific',
        casinos: ['casino-nexus-tokyo', 'casino-nexus-singapore'],
        sharedPots: 3,
        totalPlayers: 1458,
        status: 'inactive'
      }
    ];

    for (const federation of defaultFederations) {
      this.federations.set(federation.federationId, federation);
    }
  }

  /**
   * Get current system state
   */
  getSystemState(): SystemState {
    return { ...this.systemState };
  }

  /**
   * Get all casino states
   */
  getCasinoStates(): CasinoState[] {
    return Array.from(this.casinos.values());
  }

  /**
   * Get specific casino state
   */
  getCasinoState(casinoId: string): CasinoState | undefined {
    return this.casinos.get(casinoId);
  }

  /**
   * Get all federation states
   */
  getFederationStates(): FederationState[] {
    return Array.from(this.federations.values());
  }

  /**
   * Get NexCoin treasury state
   */
  getTreasuryState(): NexCoinTreasury {
    return { ...this.treasury };
  }

  /**
   * Update casino state
   */
  updateCasinoState(casinoId: string, updates: Partial<CasinoState>): void {
    const casino = this.casinos.get(casinoId);
    if (casino) {
      Object.assign(casino, updates);
      casino.lastUpdate = Date.now();
      this.notifyUpdate({ type: 'casino', casinoId, state: casino });
    }
  }

  /**
   * Update system state
   */
  updateSystemState(updates: Partial<SystemState>): void {
    Object.assign(this.systemState, updates);
    this.notifyUpdate({ type: 'system', state: this.systemState });
  }

  /**
   * Subscribe to state updates
   */
  subscribe(callback: (state: any) => void): () => void {
    this.updateCallbacks.add(callback);
    
    // Return unsubscribe function
    return () => {
      this.updateCallbacks.delete(callback);
    };
  }

  /**
   * Notify subscribers of state change
   */
  private notifyUpdate(update: any): void {
    const callbacks = Array.from(this.updateCallbacks);
    for (const callback of callbacks) {
      try {
        callback(update);
      } catch (error) {
        console.error('Error in state update callback:', error);
      }
    }
  }

  /**
   * Calculate aggregated metrics
   */
  getAggregatedMetrics() {
    const casinos = Array.from(this.casinos.values());
    
    return {
      totalCasinos: casinos.length,
      onlineCasinos: casinos.filter(c => c.status === 'online').length,
      totalPlayers: casinos.reduce((sum, c) => sum + c.playersOnline, 0),
      totalBetsPerMinute: casinos.reduce((sum, c) => sum + c.betsPerMinute, 0),
      totalActiveGames: casinos.reduce((sum, c) => sum + c.activeGames, 0),
      complianceRate: (casinos.filter(c => 
        c.compliance.handshake && c.compliance.nexcoin && c.compliance.jurisdiction
      ).length / casinos.length) * 100
    };
  }
}

export default new LiveStateMonitor();
