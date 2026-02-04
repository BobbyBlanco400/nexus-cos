class CryptoSpinEngine {
  constructor() {
    this.games = new Map();
    this.multipliers = [0, 0.5, 1.5, 2, 5, 10]; // Possible outcomes
    this.segments = [
      { id: 1, label: '0x (Loss)', value: 0, weight: 40 },
      { id: 2, label: '0.5x (Recover)', value: 0.5, weight: 30 },
      { id: 3, label: '1.5x (Win)', value: 1.5, weight: 15 },
      { id: 4, label: '2x (Double)', value: 2, weight: 10 },
      { id: 5, label: '5x (Big Win)', value: 5, weight: 4 },
      { id: 6, label: '10x (Jackpot)', value: 10, weight: 1 }
    ];
  }

  generateId() {
    return Math.random().toString(36).substr(2, 9);
  }

  spin() {
    const totalWeight = this.segments.reduce((acc, seg) => acc + seg.weight, 0);
    let random = Math.random() * totalWeight;
    
    for (const segment of this.segments) {
      if (random < segment.weight) {
        return segment;
      }
      random -= segment.weight;
    }
    return this.segments[0];
  }

  play(playerId, betAmount) {
    const result = this.spin();
    const winnings = betAmount * result.value;
    
    return {
      gameId: this.generateId(),
      playerId,
      bet: betAmount,
      multiplier: result.value,
      label: result.label,
      winnings,
      timestamp: new Date().toISOString()
    };
  }
}

module.exports = new CryptoSpinEngine();
