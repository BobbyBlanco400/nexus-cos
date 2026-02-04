
const ProgressiveJackpotManager = require('./progressive-jackpot');

class SlotEngine {
    constructor() {
        this.gameId = 'nexus_mega_fortune_777';
        this.rtp = 0.9605;
        this.jackpotManager = new ProgressiveJackpotManager();
        
        // Symbols
        this.symbols = ['WILD', 'SEVEN', 'BAR', 'BELL', 'CHERRY', 'LEMON', 'PLUM', 'ORANGE'];
        
        // Simple Paytable
        this.paytable = {
            'WILD': { 5: 10000, 4: 1000, 3: 100 },
            'SEVEN': { 5: 5000, 4: 500, 3: 50 },
            'BAR': { 5: 1000, 4: 100, 3: 10 },
            'BELL': { 5: 500, 4: 50, 3: 5 },
            'CHERRY': { 5: 200, 4: 20, 3: 2 },
            'LEMON': { 5: 100, 4: 10, 3: 2 },
            'PLUM': { 5: 50, 4: 5, 3: 1 },
            'ORANGE': { 5: 20, 4: 4, 3: 1 }
        };

        // Reel Strips (Simplified for prototype)
        // 5 Reels, 3 Rows
        this.reels = [
            this.generateReelStrip(),
            this.generateReelStrip(),
            this.generateReelStrip(),
            this.generateReelStrip(),
            this.generateReelStrip()
        ];
    }

    generateReelStrip() {
        // Weighted random generation to simulate real strip
        const strip = [];
        for (let i = 0; i < 50; i++) {
            const rand = Math.random();
            if (rand < 0.02) strip.push('WILD');
            else if (rand < 0.05) strip.push('SEVEN');
            else if (rand < 0.10) strip.push('BAR');
            else if (rand < 0.20) strip.push('BELL');
            else strip.push(this.symbols[Math.floor(Math.random() * (this.symbols.length - 4)) + 4]);
        }
        return strip;
    }

    spin(betAmount) {
        // 1. Process Jackpot Contribution
        const jackpotResult = this.jackpotManager.contribute(betAmount);
        
        // 2. Generate Grid (5x3)
        const grid = [];
        for (let reelIdx = 0; reelIdx < 5; reelIdx++) {
            const strip = this.reels[reelIdx];
            const stopIndex = Math.floor(Math.random() * strip.length);
            const column = [];
            for (let row = 0; row < 3; row++) {
                column.push(strip[(stopIndex + row) % strip.length]);
            }
            grid.push(column);
        }

        // 3. Calculate Wins (Simplified: Center Line Only for MVP)
        // In full prod, would check all paylines
        const centerLine = grid.map(col => col[1]);
        const winResult = this.evaluateLine(centerLine, betAmount);

        // 4. Combine Results
        let totalWin = winResult.payout;
        let isJackpot = false;

        if (jackpotResult.won) {
            totalWin += jackpotResult.amount;
            isJackpot = true;
        }

        // Return standardized 'reels' array for frontend
        return {
            reels: centerLine, // Standardize property name for frontend
            grid: grid, // 5x3 array
            centerLine: centerLine,
            win: totalWin > 0,
            winAmount: totalWin,
            isJackpot: isJackpot,
            jackpotData: jackpotResult,
            payoutDetails: winResult
        };
    }

    evaluateLine(symbols, bet) {
        // Check first symbol
        const first = symbols[0];
        let count = 1;
        
        // Count consecutive matching symbols (handling Wilds could be added here)
        for (let i = 1; i < symbols.length; i++) {
            if (symbols[i] === first || symbols[i] === 'WILD' || first === 'WILD') {
                count++;
            } else {
                break;
            }
        }

        // Lookup paytable
        // If first is WILD, we treat the win as WILD unless it matches another symbol later? 
        // Simple logic: Use the first symbol or the one it matched with
        const matchSymbol = first === 'WILD' ? symbols.find(s => s !== 'WILD') || 'WILD' : first;
        
        const pay = this.paytable[matchSymbol];
        let multiplier = 0;
        
        if (pay && pay[count]) {
            multiplier = pay[count];
        }

        return {
            symbol: matchSymbol,
            count: count,
            multiplier: multiplier,
            payout: bet * multiplier
        };
    }

    getJackpotStatus() {
        return this.jackpotManager.getStatus();
    }
}

module.exports = SlotEngine;
