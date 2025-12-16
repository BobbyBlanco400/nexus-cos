"use strict";
/**
 * StatsPanel - Statistics Panel for Pixel Streaming
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.StatsPanel = void 0;
class StatsPanel {
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
    getActiveCandidatePair() {
        // Fix: Cast aggregatedStats to any to access getActiveCandidatePair method
        const activePair = this.aggregatedStats.getActiveCandidatePair();
        return activePair;
    }
    /**
     * Update aggregated stats
     */
    updateStats(stats) {
        this.aggregatedStats = stats;
    }
    /**
     * Get current stats
     */
    getStats() {
        return this.aggregatedStats;
    }
}
exports.StatsPanel = StatsPanel;
