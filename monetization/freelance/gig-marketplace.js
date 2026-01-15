/**
 * Gig Marketplace
 * Platform for AI-assisted creative freelance services
 * Part of monetization infrastructure
 */

class GigMarketplace {
  constructor(config = {}) {
    this.config = {
      commissionRate: config.commissionRate || 0.15, // 15% platform fee
      minGigPrice: config.minGigPrice || 10.00,
      maxGigPrice: config.maxGigPrice || 5000.00,
      ...config
    };
    this.gigs = new Map();
    this.orders = [];
  }

  /**
   * Initialize gig marketplace
   */
  async initialize() {
    console.log('💼 Gig Marketplace initializing...');
    console.log(`  💰 Commission rate: ${(this.config.commissionRate * 100).toFixed(0)}%`);
    console.log(`  💵 Price range: $${this.config.minGigPrice} - $${this.config.maxGigPrice}`);
    console.log('✅ Gig Marketplace ready');
    return true;
  }

  /**
   * Create gig listing
   * @param {string} sellerId - Creator selling service
   * @param {Object} gigDetails - Gig configuration
   */
  async createGig(sellerId, gigDetails) {
    console.log(`💼 Creating gig: ${gigDetails.title}`);

    // Validate price
    this.validatePrice(gigDetails.price);

    const gigId = this.generateGigId();

    const gig = {
      gigId,
      sellerId,
      title: gigDetails.title,
      description: gigDetails.description,
      category: gigDetails.category || 'creative',
      price: gigDetails.price,
      deliveryTime: gigDetails.deliveryTime || '3 days',
      aiAssisted: gigDetails.aiAssisted !== false,
      skills: gigDetails.skills || [],
      portfolio: gigDetails.portfolio || [],
      sellerEarning: this.calculateSellerEarning(gigDetails.price),
      platformFee: this.calculatePlatformFee(gigDetails.price),
      createdAt: Date.now(),
      status: 'active',
      orders: 0,
      revenue: 0,
      rating: 0,
      reviews: []
    };

    this.gigs.set(gigId, gig);

    console.log(`  ✅ Gig created: ${gigId}`);
    console.log(`     Price: $${gig.price}`);
    console.log(`     Seller earns: $${gig.sellerEarning.toFixed(2)} per order`);
    console.log(`     AI-assisted: ${gig.aiAssisted ? 'Yes' : 'No'}`);

    return gig;
  }

  /**
   * Place order
   * @param {string} gigId - Gig ID
   * @param {string} buyerId - Buyer ID
   * @param {Object} requirements - Order requirements
   */
  async placeOrder(gigId, buyerId, requirements) {
    const gig = this.gigs.get(gigId);

    if (!gig) {
      throw new Error('Gig not found');
    }

    if (gig.status !== 'active') {
      throw new Error('Gig is not active');
    }

    const orderId = this.generateOrderId();

    const order = {
      orderId,
      gigId,
      sellerId: gig.sellerId,
      buyerId,
      title: gig.title,
      price: gig.price,
      sellerEarning: gig.sellerEarning,
      platformFee: gig.platformFee,
      requirements,
      deliveryTime: gig.deliveryTime,
      aiAssisted: gig.aiAssisted,
      orderedAt: Date.now(),
      status: 'in-progress',
      deliveryDate: Date.now() + this.parseDeliveryTime(gig.deliveryTime)
    };

    // Update gig stats
    gig.orders++;
    gig.revenue += gig.price;

    // Record order
    this.orders.push(order);

    console.log(`  💼 Order placed: ${orderId}`);
    console.log(`     Gig: ${gig.title}`);
    console.log(`     Price: $${order.price}`);
    console.log(`     Expected delivery: ${this.formatDate(order.deliveryDate)}`);

    return order;
  }

  /**
   * Complete order
   * @param {string} orderId - Order ID
   * @param {Object} delivery - Delivered work
   */
  async completeOrder(orderId, delivery) {
    const order = this.orders.find(o => o.orderId === orderId);

    if (!order) {
      throw new Error('Order not found');
    }

    if (order.status !== 'in-progress') {
      throw new Error('Order is not in progress');
    }

    order.status = 'completed';
    order.completedAt = Date.now();
    order.delivery = delivery;

    console.log(`  ✅ Order completed: ${orderId}`);
    console.log(`     Seller earns: $${order.sellerEarning.toFixed(2)}`);

    return order;
  }

  /**
   * Add review
   * @param {string} orderId - Order ID
   * @param {number} rating - Rating (1-5)
   * @param {string} comment - Review comment
   */
  async addReview(orderId, rating, comment) {
    const order = this.orders.find(o => o.orderId === orderId);

    if (!order) {
      throw new Error('Order not found');
    }

    if (order.status !== 'completed') {
      throw new Error('Order must be completed to review');
    }

    const gig = this.gigs.get(order.gigId);

    if (!gig) {
      throw new Error('Gig not found');
    }

    const review = {
      orderId,
      buyerId: order.buyerId,
      rating,
      comment,
      timestamp: Date.now()
    };

    gig.reviews.push(review);

    // Update gig rating
    const avgRating = gig.reviews.reduce((sum, r) => sum + r.rating, 0) / gig.reviews.length;
    gig.rating = avgRating;

    console.log(`  ⭐ Review added: ${rating}/5`);
    console.log(`     New gig rating: ${avgRating.toFixed(1)}/5`);

    return review;
  }

  /**
   * Parse delivery time to milliseconds
   */
  parseDeliveryTime(deliveryTime) {
    const days = parseInt(deliveryTime) || 3;
    return days * 24 * 60 * 60 * 1000;
  }

  /**
   * Format date
   */
  formatDate(timestamp) {
    return new Date(timestamp).toLocaleDateString();
  }

  /**
   * Validate price
   */
  validatePrice(price) {
    const numPrice = parseFloat(price);

    if (isNaN(numPrice) || numPrice < this.config.minGigPrice || numPrice > this.config.maxGigPrice) {
      throw new Error(
        `Price must be between $${this.config.minGigPrice} and $${this.config.maxGigPrice}`
      );
    }
  }

  /**
   * Calculate seller earning
   */
  calculateSellerEarning(price) {
    return price * (1 - this.config.commissionRate);
  }

  /**
   * Calculate platform fee
   */
  calculatePlatformFee(price) {
    return price * this.config.commissionRate;
  }

  /**
   * Search gigs
   */
  searchGigs(query = {}) {
    let results = Array.from(this.gigs.values());

    if (query.category) {
      results = results.filter(g => g.category === query.category);
    }

    if (query.minPrice) {
      results = results.filter(g => g.price >= query.minPrice);
    }

    if (query.maxPrice) {
      results = results.filter(g => g.price <= query.maxPrice);
    }

    if (query.aiAssisted !== undefined) {
      results = results.filter(g => g.aiAssisted === query.aiAssisted);
    }

    // Sort by rating and orders
    results.sort((a, b) => {
      if (b.rating !== a.rating) return b.rating - a.rating;
      return b.orders - a.orders;
    });

    return results;
  }

  /**
   * Get seller gigs
   */
  getSellerGigs(sellerId) {
    return Array.from(this.gigs.values())
      .filter(gig => gig.sellerId === sellerId);
  }

  /**
   * Generate gig ID
   */
  generateGigId() {
    return `GIG_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Generate order ID
   */
  generateOrderId() {
    return `ORDER_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Get statistics
   */
  getStatistics() {
    const gigs = Array.from(this.gigs.values());
    const activeGigs = gigs.filter(g => g.status === 'active');
    const totalOrders = this.orders.length;
    const completedOrders = this.orders.filter(o => o.status === 'completed').length;
    const totalRevenue = this.orders
      .filter(o => o.status === 'completed')
      .reduce((sum, o) => sum + o.price, 0);
    const totalSellerEarnings = this.orders
      .filter(o => o.status === 'completed')
      .reduce((sum, o) => sum + o.sellerEarning, 0);
    const totalPlatformFees = this.orders
      .filter(o => o.status === 'completed')
      .reduce((sum, o) => sum + o.platformFee, 0);

    return {
      totalGigs: gigs.length,
      activeGigs: activeGigs.length,
      totalOrders,
      completedOrders,
      completionRate: totalOrders > 0 ? ((completedOrders / totalOrders) * 100).toFixed(2) : 0,
      totalRevenue: totalRevenue.toFixed(2),
      totalSellerEarnings: totalSellerEarnings.toFixed(2),
      totalPlatformFees: totalPlatformFees.toFixed(2),
      averageOrderValue: completedOrders > 0 ? (totalRevenue / completedOrders).toFixed(2) : 0
    };
  }
}

module.exports = GigMarketplace;
