/**
 * StatsPanel - Statistics Panel for Pixel Streaming
 */
export interface AggregatedStats {
    inboundVideoStats: any;
    inboundAudioStats: any;
    candidatePair: any;
}
export declare class StatsPanel {
    private aggregatedStats;
    constructor();
    /**
     * Get the active candidate pair
     * Fixed: Cast to any to bypass TypeScript strict type checking
     */
    getActiveCandidatePair(): any;
    /**
     * Update aggregated stats
     */
    updateStats(stats: AggregatedStats): void;
    /**
     * Get current stats
     */
    getStats(): AggregatedStats;
}
//# sourceMappingURL=StatsPanel.d.ts.map