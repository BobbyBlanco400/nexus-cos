/**
 * Presale Manager
 * Manages limited edition presales and exclusive experiences
 * Part of monetization infrastructure
 */

class PresaleManager {
  constructor(config = {}) {
    this.config = {
      minPresalePrice: config.minPresalePrice || 50.00,
      maxPresalePrice: config.maxPresalePrice || 10000.00,
      platformFee: config.platformFee || 0.10, // 10% platform fee
      ...config
    };
    this.presales = new Map();
    this.purchases = [];
  }

  /**
   * Initialize presale manager
   */
  async initialize() {
    console.log('🎟️  Presale Manager initializing...');
    console.log(`  💵 Price range: $${this.config.minPresalePrice} - $${this.config.maxPresalePrice}`);
    console.log(`  🏦 Platform fee: ${(this.config.platformFee * 100).toFixed(1)}%`);
    console.log('✅ Presale Manager ready');
    return true;
  }

  /**
   * Create presale
   * @param {string} creatorId - Creator offering presale
   * @param {Object} presaleDetails - Presale configuration
   */
  async createPresale(creatorId, presaleDetails) {
    console.log(`🎟️  Creating presale: ${presaleDetails.name}`);

    // Validate price
    this.validatePrice(presaleDetails.price);

    const presaleId = this.generatePresaleId();

    const presale = {
      presaleId,
      creatorId,
      name: presaleDetails.name,
      description: presaleDetails.description,
      type: presaleDetails.type || 'experience', // experience, asset, bundle, etc.
      price: presaleDetails.price,
      totalSlots: presaleDetails.totalSlots || 100,
      availableSlots: presaleDetails.totalSlots || 100,
      creatorEarning: this.calculateCreatorEarning(presaleDetails.price),
      platformFee: this.calculatePlatformFee(presaleDetails.price),
      benefits: presaleDetails.benefits || [],
      exclusiveAccess: presaleDetails.exclusiveAccess || [],
      startTime: presaleDetails.startTime || Date.now(),
      endTime: presaleDetails.endTime,
      deliveryDate: presaleDetails.deliveryDate,
      createdAt: Date.now(),
      status: 'active',
      purchases: 0,
      revenue: 0
    };

    this.presales.set(presaleId, presale);

    console.log(`  ✅ Presale created: ${presaleId}`);
    console.log(`     Price: $${presale.price}`);
    console.log(`     Slots: ${presale.totalSlots}`);
    console.log(`     Creator earns: $${presale.creatorEarning.toFixed(2)} per slot`);

    return presale;
  }

  /**
   * Purchase presale slot
   * @param {string} presaleId - Presale ID
   * @param {string} buyerId - Buyer ID
   */
  async purchaseSlot(presaleId, buyerId) {
    const presale = this.presales.get(presaleId);

    if (!presale) {
      throw new Error('Presale not found');
    }

    if (presale.status !== 'active') {
      throw new Error('Presale is not active');
    }

    if (presale.availableSlots <= 0) {
      throw new Error('Presale is sold out');
    }

    // Check if already purchased
    const existingPurchase = this.purchases.find(
      p => p.presaleId === presaleId && p.buyerId === buyerId
    );

    if (existingPurchase) {
      throw new Error('Already purchased this presale');
    }

    const purchaseId = this.generatePurchaseId();

    const purchase = {
      purchaseId,
      presaleId,
      buyerId,
      sellerId: presale.creatorId,
      name: presale.name,
      price: presale.price,
      creatorEarning: presale.creatorEarning,
      platformFee: presale.platformFee,
      slotNumber: presale.totalSlots - presale.availableSlots + 1,
      benefits: presale.benefits,
      exclusiveAccess: presale.exclusiveAccess,
      deliveryDate: presale.deliveryDate,
      purchasedAt: Date.now(),
      status: 'confirmed'
    };

    // Update presale
    presale.availableSlots--;
    presale.purchases++;
    presale.revenue += presale.price;

    // Check if sold out
    if (presale.availableSlots === 0) {
      presale.status = 'sold-out';
      console.log(`  🎉 Presale sold out: ${presaleId}`);
    }

    // Record purchase
    this.purchases.push(purchase);

    console.log(`  🎟️  Slot purchased: #${purchase.slotNumber}`);
    console.log(`     Buyer: ${buyerId}`);
    console.log(`     Price: $${purchase.price}`);
    console.log(`     Remaining slots: ${presale.availableSlots}`);

    return purchase;
  }

  /**
   * Fulfill presale (deliver to all buyers)
   * @param {string} presaleId - Presale ID
   * @param {Object} delivery - Delivery details
   */
  async fulfillPresale(presaleId, delivery) {
    const presale = this.presales.get(presaleId);

    if (!presale) {
      throw new Error('Presale not found');
    }

    presale.status = 'fulfilled';
    presale.fulfilledAt = Date.now();
    presale.delivery = delivery;

    // Update all purchases for this presale
    this.purchases
      .filter(p => p.presaleId === presaleId)
      .forEach(p => {
        p.status = 'delivered';
        p.deliveredAt = Date.now();
        p.delivery = delivery;
      });

    console.log(`  ✅ Presale fulfilled: ${presaleId}`);
    console.log(`     Delivered to ${presale.purchases} buyers`);

    return presale;
  }

  /**
   * Validate price
   */
  validatePrice(price) {
    const numPrice = parseFloat(price);

    if (isNaN(numPrice) || numPrice < this.config.minPresalePrice || numPrice > this.config.maxPresalePrice) {
      throw new Error(
        `Price must be between $${this.config.minPresalePrice} and $${this.config.maxPresalePrice}`
      );
    }
  }

  /**
   * Calculate creator earning
   */
  calculateCreatorEarning(price) {
    return price * (1 - this.config.platformFee);
  }

  /**
   * Calculate platform fee
   */
  calculatePlatformFee(price) {
    return price * this.config.platformFee;
  }

  /**
   * Get presale
   */
  getPresale(presaleId) {
    return this.presales.get(presaleId);
  }

  /**
   * Get active presales
   */
  getActivePresales() {
    return Array.from(this.presales.values())
      .filter(presale => presale.status === 'active' && presale.availableSlots > 0);
  }

  /**
   * Get creator presales
   */
  getCreatorPresales(creatorId) {
    return Array.from(this.presales.values())
      .filter(presale => presale.creatorId === creatorId);
  }

  /**
   * Get buyer purchases
   */
  getBuyerPurchases(buyerId) {
    return this.purchases.filter(purchase => purchase.buyerId === buyerId);
  }

  /**
   * Generate presale ID
   */
  generatePresaleId() {
    return `PRESALE_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Generate purchase ID
   */
  generatePurchaseId() {
    return `PURCHASE_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Get statistics
   */
  getStatistics() {
    const presales = Array.from(this.presales.values());
    const activePresales = presales.filter(p => p.status === 'active');
    const soldOutPresales = presales.filter(p => p.status === 'sold-out');
    const fulfilledPresales = presales.filter(p => p.status === 'fulfilled');
    
    const totalPurchases = this.purchases.length;
    const totalRevenue = this.purchases.reduce((sum, p) => sum + p.price, 0);
    const totalCreatorEarnings = this.purchases.reduce((sum, p) => sum + p.creatorEarning, 0);
    const totalPlatformFees = this.purchases.reduce((sum, p) => sum + p.platformFee, 0);

    const totalSlots = presales.reduce((sum, p) => sum + p.totalSlots, 0);
    const soldSlots = presales.reduce((sum, p) => sum + p.purchases, 0);

    return {
      totalPresales: presales.length,
      activePresales: activePresales.length,
      soldOutPresales: soldOutPresales.length,
      fulfilledPresales: fulfilledPresales.length,
      totalSlots,
      soldSlots,
      availableSlots: totalSlots - soldSlots,
      sellThroughRate: totalSlots > 0 ? ((soldSlots / totalSlots) * 100).toFixed(2) : 0,
      totalPurchases,
      totalRevenue: totalRevenue.toFixed(2),
      totalCreatorEarnings: totalCreatorEarnings.toFixed(2),
      totalPlatformFees: totalPlatformFees.toFixed(2),
      averagePresalePrice: totalPurchases > 0 ? (totalRevenue / totalPurchases).toFixed(2) : 0
    };
  }
}

module.exports = PresaleManager;
