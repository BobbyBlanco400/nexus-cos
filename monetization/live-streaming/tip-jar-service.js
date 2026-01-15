/**
 * Tip Jar Service
 * Enables live tipping during streaming events
 * Part of monetization infrastructure
 */

class TipJarService {
  constructor(config = {}) {
    this.config = {
      minTip: config.minTip || 1.00,
      maxTip: config.maxTip || 1000.00,
      platformFee: config.platformFee || 0.05, // 5% platform fee
      ...config
    };
    this.tips = [];
    this.activeTipJars = new Map();
  }

  /**
   * Initialize tip jar service
   */
  async initialize() {
    console.log('💰 Tip Jar Service initializing...');
    console.log(`  💵 Tip range: $${this.config.minTip} - $${this.config.maxTip}`);
    console.log(`  🏦 Platform fee: ${(this.config.platformFee * 100).toFixed(1)}%`);
    console.log('✅ Tip Jar Service ready');
    return true;
  }

  /**
   * Create tip jar for event
   * @param {string} eventId - Event ID
   * @param {string} creatorId - Creator receiving tips
   */
  async createTipJar(eventId, creatorId) {
    console.log(`💰 Creating tip jar for event: ${eventId}`);

    const tipJarId = this.generateTipJarId();

    const tipJar = {
      tipJarId,
      eventId,
      creatorId,
      createdAt: Date.now(),
      status: 'active',
      tips: [],
      totalAmount: 0,
      creatorEarnings: 0,
      platformFees: 0
    };

    this.activeTipJars.set(tipJarId, tipJar);

    console.log(`  ✅ Tip jar created: ${tipJarId}`);

    return tipJar;
  }

  /**
   * Send tip
   * @param {string} tipJarId - Tip jar ID
   * @param {string} tipperId - User sending tip
   * @param {number} amount - Tip amount
   * @param {string} message - Optional message
   */
  async sendTip(tipJarId, tipperId, amount, message = '') {
    const tipJar = this.activeTipJars.get(tipJarId);

    if (!tipJar) {
      throw new Error('Tip jar not found');
    }

    if (tipJar.status !== 'active') {
      throw new Error('Tip jar is not active');
    }

    // Validate amount
    this.validateTipAmount(amount);

    const tipId = this.generateTipId();

    const tip = {
      tipId,
      tipJarId,
      tipperId,
      creatorId: tipJar.creatorId,
      amount,
      creatorEarning: this.calculateCreatorEarning(amount),
      platformFee: this.calculatePlatformFee(amount),
      message,
      timestamp: Date.now(),
      status: 'completed'
    };

    // Update tip jar
    tipJar.tips.push(tip);
    tipJar.totalAmount += amount;
    tipJar.creatorEarnings += tip.creatorEarning;
    tipJar.platformFees += tip.platformFee;

    // Record globally
    this.tips.push(tip);

    console.log(`  💸 Tip received: $${amount} from ${tipperId}`);
    if (message) {
      console.log(`     Message: "${message}"`);
    }

    return tip;
  }

  /**
   * Validate tip amount
   */
  validateTipAmount(amount) {
    const numAmount = parseFloat(amount);

    if (isNaN(numAmount) || numAmount < this.config.minTip || numAmount > this.config.maxTip) {
      throw new Error(
        `Tip amount must be between $${this.config.minTip} and $${this.config.maxTip}`
      );
    }
  }

  /**
   * Calculate creator earning
   */
  calculateCreatorEarning(amount) {
    return amount * (1 - this.config.platformFee);
  }

  /**
   * Calculate platform fee
   */
  calculatePlatformFee(amount) {
    return amount * this.config.platformFee;
  }

  /**
   * Close tip jar
   */
  async closeTipJar(tipJarId) {
    const tipJar = this.activeTipJars.get(tipJarId);

    if (!tipJar) {
      throw new Error('Tip jar not found');
    }

    tipJar.status = 'closed';
    tipJar.closedAt = Date.now();

    console.log(`💰 Tip jar closed: ${tipJarId}`);
    console.log(`   Total tips: ${tipJar.tips.length}`);
    console.log(`   Total amount: $${tipJar.totalAmount.toFixed(2)}`);
    console.log(`   Creator earnings: $${tipJar.creatorEarnings.toFixed(2)}`);

    return tipJar;
  }

  /**
   * Get tip jar
   */
  getTipJar(tipJarId) {
    return this.activeTipJars.get(tipJarId);
  }

  /**
   * Get creator tip jars
   */
  getCreatorTipJars(creatorId) {
    return Array.from(this.activeTipJars.values())
      .filter(jar => jar.creatorId === creatorId);
  }

  /**
   * Get top tippers for tip jar
   */
  getTopTippers(tipJarId, limit = 10) {
    const tipJar = this.activeTipJars.get(tipJarId);

    if (!tipJar) {
      return [];
    }

    // Aggregate tips by tipper
    const tipperTotals = new Map();
    
    tipJar.tips.forEach(tip => {
      const current = tipperTotals.get(tip.tipperId) || 0;
      tipperTotals.set(tip.tipperId, current + tip.amount);
    });

    // Convert to array and sort
    const topTippers = Array.from(tipperTotals.entries())
      .map(([tipperId, amount]) => ({ tipperId, amount }))
      .sort((a, b) => b.amount - a.amount)
      .slice(0, limit);

    return topTippers;
  }

  /**
   * Generate tip jar ID
   */
  generateTipJarId() {
    return `TIPJAR_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Generate tip ID
   */
  generateTipId() {
    return `TIP_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Get statistics
   */
  getStatistics() {
    const totalTips = this.tips.length;
    const totalAmount = this.tips.reduce((sum, t) => sum + t.amount, 0);
    const totalCreatorEarnings = this.tips.reduce((sum, t) => sum + t.creatorEarning, 0);
    const totalPlatformFees = this.tips.reduce((sum, t) => sum + t.platformFee, 0);

    const activeTipJars = Array.from(this.activeTipJars.values())
      .filter(jar => jar.status === 'active');

    return {
      totalTips,
      activeTipJars: activeTipJars.length,
      totalTipJars: this.activeTipJars.size,
      totalAmount: totalAmount.toFixed(2),
      totalCreatorEarnings: totalCreatorEarnings.toFixed(2),
      totalPlatformFees: totalPlatformFees.toFixed(2),
      averageTip: totalTips > 0 ? (totalAmount / totalTips).toFixed(2) : 0
    };
  }
}

module.exports = TipJarService;
