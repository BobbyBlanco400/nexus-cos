/**
 * StatsPanel - Statistics Panel for Pixel Streaming
 */

export interface AggregatedStats {
  // Basic stats interface
  inboundVideoStats: any;
  inboundAudioStats: any;
  candidatePair: any;
}

export class StatsPanel {
  private aggregatedStats: AggregatedStats;

  constructor() {
    this.aggregatedStats = {
      inboundVideoStats: {},
      inboundAudioStats: {},
      candidatePair: {}
    };
  }

  /**
   * Get the active candidate pair
   * Fixed: Cast to any to bypass TypeScript strict type checking
   */
  public getActiveCandidatePair(): any {
    // Fix: Cast aggregatedStats to any to access getActiveCandidatePair method
    const activePair = (this.aggregatedStats as any).getActiveCandidatePair();
    return activePair;
  }

  /**
   * Update aggregated stats
   */
  public updateStats(stats: AggregatedStats): void {
    this.aggregatedStats = stats;
  }

  /**
   * Get current stats
   */
  public getStats(): AggregatedStats {
    return this.aggregatedStats;
  }
}
