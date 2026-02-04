
class ProgressiveJackpotManager {
    constructor(config = {}) {
        this.config = {
            contributionRate: config.contributionRate || 0.01, // 1%
            mustHitBy: config.mustHitBy || 100000,
            seedAmount: config.seedAmount || 10000,
            resetAmount: config.resetAmount || 10000,
            id: config.id || 'global_nexus_jackpot'
        };

        // In a real distributed system, this would be in Redis/DB
        this.currentAmount = this.config.seedAmount;
        this.winningThreshold = this.generateWinningThreshold();
        this.lastWin = null;
    }

    generateWinningThreshold() {
        // Randomly pick a value between current amount and must-hit-by
        // biased slightly towards the upper end to build excitement
        const min = Math.max(this.currentAmount, this.config.seedAmount);
        const max = this.config.mustHitBy;
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    contribute(betAmount) {
        const contribution = betAmount * this.config.contributionRate;
        this.currentAmount += contribution;

        // Check for win
        if (this.currentAmount >= this.winningThreshold) {
            return this.triggerWin();
        }

        return {
            won: false,
            currentAmount: this.currentAmount,
            contribution: contribution
        };
    }

    triggerWin() {
        const winAmount = this.currentAmount;
        this.lastWin = {
            amount: winAmount,
            timestamp: new Date().toISOString()
        };

        // Reset
        this.currentAmount = this.config.resetAmount;
        this.winningThreshold = this.generateWinningThreshold();

        return {
            won: true,
            amount: winAmount,
            resetTo: this.config.resetAmount
        };
    }

    getStatus() {
        return {
            id: this.config.id,
            currentAmount: this.currentAmount,
            mustHitBy: this.config.mustHitBy,
            lastWin: this.lastWin
        };
    }
}

module.exports = ProgressiveJackpotManager;
