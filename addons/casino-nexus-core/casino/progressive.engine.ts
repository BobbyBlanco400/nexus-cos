/**
 * Progressive Engine - Vegas-Style Progressive System
 * 
 * Mimics Vegas progressive feel without pooled cash prizes.
 * All rewards are utility-based (NexCoin, access, features).
 * 
 * @module casino/progressive.engine
 * @compliance LEGAL-SAFE
 */

export interface ProgressivePool {
  id: string;
  name: string;
  currentValue: number;
  contributionRate: number;
  minimumValue: number;
  maximumValue: number;
  lastWinner?: {
    userId: string;
    timestamp: number;
    amount: number;
  };
}

export interface ProgressiveContribution {
  poolId: string;
  amount: number;
  source: string;
  timestamp: number;
}

export interface ProgressiveWin {
  poolId: string;
  userId: string;
  amount: number;
  timestamp: number;
  validated: boolean;
}

/**
 * In-memory progressive pools (production should use persistent storage)
 */
const pools: Map<string, ProgressivePool> = new Map();

/**
 * Progressive Engine
 */
export class ProgressiveEngine {
  /**
   * Standard contribution rate (1.5% of spin cost)
   */
  static readonly DEFAULT_CONTRIBUTION_RATE = 0.015;

  /**
   * Initialize a progressive pool
   */
  initPool(
    id: string,
    name: string,
    minimumValue: number = 1000,
    maximumValue: number = 100000
  ): ProgressivePool {
    const pool: ProgressivePool = {
      id,
      name,
      currentValue: minimumValue,
      contributionRate: ProgressiveEngine.DEFAULT_CONTRIBUTION_RATE,
      minimumValue,
      maximumValue
    };

    pools.set(id, pool);
    return pool;
  }

  /**
   * Contribute to progressive pool from spin cost
   */
  contribute(poolId: string, spinCost: number): ProgressiveContribution {
    const pool = pools.get(poolId);
    
    if (!pool) {
      throw new Error(`Progressive pool not found: ${poolId}`);
    }

    const contribution = spinCost * pool.contributionRate;

    // Increment pool, capped at maximum
    if (pool.currentValue < pool.maximumValue) {
      pool.currentValue = Math.min(
        pool.currentValue + contribution,
        pool.maximumValue
      );
    }

    return {
      poolId,
      amount: contribution,
      source: 'spin',
      timestamp: Date.now()
    };
  }

  /**
   * Award progressive to player (skill-validated)
   */
  award(poolId: string, playerId: string): ProgressiveWin {
    const pool = pools.get(poolId);
    
    if (!pool) {
      throw new Error(`Progressive pool not found: ${poolId}`);
    }

    // Validate skill requirement (placeholder - implement actual validation)
    const validated = this.skillValidated(playerId);
    
    if (!validated) {
      throw new Error('Player does not meet skill validation requirements');
    }

    const winAmount = pool.currentValue;

    // Reset pool to minimum
    pool.currentValue = pool.minimumValue;
    pool.lastWinner = {
      userId: playerId,
      timestamp: Date.now(),
      amount: winAmount
    };

    return {
      poolId,
      userId: playerId,
      amount: winAmount,
      timestamp: Date.now(),
      validated: true
    };
  }

  /**
   * Skill validation (placeholder - implement actual logic)
   */
  private skillValidated(playerId: string): boolean {
    // Production should implement actual skill validation:
    // - Minimum play count
    // - Skill assessment
    // - Fair play verification
    // - Anti-cheat checks
    return true; // Placeholder
  }

  /**
   * Grant utility reward to player
   */
  grantUtilityReward(playerId: string, amount: number): {
    type: 'nexcoin';
    playerId: string;
    amount: number;
    granted: boolean;
  } {
    // Production should integrate with actual wallet system
    return {
      type: 'nexcoin',
      playerId,
      amount,
      granted: true
    };
  }

  /**
   * Get pool information
   */
  getPool(poolId: string): ProgressivePool | undefined {
    return pools.get(poolId);
  }

  /**
   * Get all pools
   */
  getAllPools(): ProgressivePool[] {
    return Array.from(pools.values());
  }

  /**
   * Get pool current value
   */
  getPoolValue(poolId: string): number {
    const pool = pools.get(poolId);
    return pool ? pool.currentValue : 0;
  }

  /**
   * Get pool statistics
   */
  getPoolStats(poolId: string): {
    currentValue: number;
    minimumValue: number;
    maximumValue: number;
    percentFull: number;
    lastWinner?: ProgressivePool['lastWinner'];
  } | null {
    const pool = pools.get(poolId);
    
    if (!pool) {
      return null;
    }

    const range = pool.maximumValue - pool.minimumValue;
    const current = pool.currentValue - pool.minimumValue;
    const percentFull = (current / range) * 100;

    return {
      currentValue: pool.currentValue,
      minimumValue: pool.minimumValue,
      maximumValue: pool.maximumValue,
      percentFull: Math.round(percentFull),
      lastWinner: pool.lastWinner
    };
  }

  /**
   * Set custom contribution rate for pool
   */
  setContributionRate(poolId: string, rate: number): void {
    const pool = pools.get(poolId);
    
    if (!pool) {
      throw new Error(`Progressive pool not found: ${poolId}`);
    }

    if (rate < 0 || rate > 0.1) {
      throw new Error('Contribution rate must be between 0 and 0.1 (10%)');
    }

    pool.contributionRate = rate;
  }
}

/**
 * Pre-configured progressive pools
 */
export const PROGRESSIVE_POOLS = {
  DIAMOND: 'diamond-progressive',
  INFINITY: 'infinity-vault',
  FOUNDERS: 'founders-wheel',
  MEGA: 'mega-jackpot'
};

/**
 * Initialize default progressive pools
 */
export function initDefaultPools(engine: ProgressiveEngine): void {
  engine.initPool(PROGRESSIVE_POOLS.DIAMOND, 'Diamond Progressive', 5000, 50000);
  engine.initPool(PROGRESSIVE_POOLS.INFINITY, 'Infinity Vault', 10000, 100000);
  engine.initPool(PROGRESSIVE_POOLS.FOUNDERS, 'Founders Wheel', 25000, 250000);
  engine.initPool(PROGRESSIVE_POOLS.MEGA, 'Mega Jackpot', 50000, 500000);
}

export default ProgressiveEngine;
