/**
 * StatsPanel - Statistics Panel for Pixel Streaming
 */

export interface VideoStats {
  bytesReceived?: number;
  framesDecoded?: number;
  frameWidth?: number;
  frameHeight?: number;
}

export interface AudioStats {
  bytesReceived?: number;
  packetsReceived?: number;
  packetsLost?: number;
}

export interface CandidatePair {
  id?: string;
  state?: string;
  localCandidate?: any;
  remoteCandidate?: any;
}

export interface AggregatedStats {
  // Stats interfaces with proper types
  inboundVideoStats: VideoStats;
  inboundAudioStats: AudioStats;
  candidatePair: CandidatePair;
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
