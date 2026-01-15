/**
 * IMVU-L Asset Store
 * Marketplace for IMVU-L assets created by founding creatives
 * Part of monetization infrastructure
 */

class IMVULAssetStore {
  constructor(config = {}) {
    this.config = {
      commissionRate: config.commissionRate || 0.20, // 20% platform, 80% creator
      minPrice: config.minPrice || 1.00,
      maxPrice: config.maxPrice || 500.00,
      ...config
    };
    this.listings = new Map();
    this.sales = [];
  }

  /**
   * Initialize asset store
   */
  async initialize() {
    console.log('🏪 IMVU-L Asset Store initializing...');
    console.log(`  💰 Commission rate: ${(this.config.commissionRate * 100).toFixed(0)}%`);
    console.log(`  💵 Price range: $${this.config.minPrice} - $${this.config.maxPrice}`);
    console.log('✅ IMVU-L Asset Store ready');
    return true;
  }

  /**
   * List asset for sale
   * @param {string} creatorId - Creator ID
   * @param {Object} asset - Asset details
   * @param {number} price - Sale price
   */
  async listAsset(creatorId, asset, price) {
    console.log(`🏪 Listing IMVU-L asset: ${asset.name}`);

    // Validate price
    this.validatePrice(price);

    const listingId = this.generateListingId();

    const listing = {
      listingId,
      creatorId,
      assetId: asset.assetId,
      assetType: 'IMVU-L',
      name: asset.name,
      description: asset.description || '',
      price,
      creatorEarning: this.calculateCreatorEarning(price),
      platformFee: this.calculatePlatformFee(price),
      listedAt: Date.now(),
      status: 'active',
      sales: 0,
      revenue: 0,
      metadata: asset.metadata || {}
    };

    this.listings.set(listingId, listing);

    console.log(`  ✅ Listed: ${listing.name} at $${price}`);
    console.log(`     Creator earns: $${listing.creatorEarning.toFixed(2)} per sale`);

    return listing;
  }

  /**
   * Purchase asset
   * @param {string} listingId - Listing ID
   * @param {string} buyerId - Buyer ID
   */
  async purchaseAsset(listingId, buyerId) {
    const listing = this.listings.get(listingId);

    if (!listing) {
      throw new Error('Listing not found');
    }

    if (listing.status !== 'active') {
      throw new Error('Listing is not active');
    }

    const saleId = this.generateSaleId();

    const sale = {
      saleId,
      listingId,
      assetId: listing.assetId,
      buyerId,
      sellerId: listing.creatorId,
      price: listing.price,
      creatorEarning: listing.creatorEarning,
      platformFee: listing.platformFee,
      purchasedAt: Date.now(),
      status: 'completed'
    };

    // Update listing stats
    listing.sales++;
    listing.revenue += listing.price;

    // Record sale
    this.sales.push(sale);

    console.log(`💰 Sale completed: ${listing.name}`);
    console.log(`   Buyer: ${buyerId}`);
    console.log(`   Price: $${sale.price}`);
    console.log(`   Creator earns: $${sale.creatorEarning.toFixed(2)}`);

    return sale;
  }

  /**
   * Validate price
   */
  validatePrice(price) {
    const numPrice = parseFloat(price);

    if (isNaN(numPrice) || numPrice < this.config.minPrice || numPrice > this.config.maxPrice) {
      throw new Error(
        `Price must be between $${this.config.minPrice} and $${this.config.maxPrice}`
      );
    }
  }

  /**
   * Calculate creator earning
   */
  calculateCreatorEarning(price) {
    return price * (1 - this.config.commissionRate);
  }

  /**
   * Calculate platform fee
   */
  calculatePlatformFee(price) {
    return price * this.config.commissionRate;
  }

  /**
   * Get listing
   */
  getListing(listingId) {
    return this.listings.get(listingId);
  }

  /**
   * Get creator listings
   */
  getCreatorListings(creatorId) {
    return Array.from(this.listings.values())
      .filter(listing => listing.creatorId === creatorId);
  }

  /**
   * Search listings
   */
  searchListings(query = {}) {
    let results = Array.from(this.listings.values());

    if (query.status) {
      results = results.filter(l => l.status === query.status);
    }

    if (query.minPrice) {
      results = results.filter(l => l.price >= query.minPrice);
    }

    if (query.maxPrice) {
      results = results.filter(l => l.price <= query.maxPrice);
    }

    // Sort by relevance (most sales, recent)
    results.sort((a, b) => {
      if (b.sales !== a.sales) return b.sales - a.sales;
      return b.listedAt - a.listedAt;
    });

    return results;
  }

  /**
   * Generate listing ID
   */
  generateListingId() {
    return `IMVUL_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Generate sale ID
   */
  generateSaleId() {
    return `SALE_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Get statistics
   */
  getStatistics() {
    const listings = Array.from(this.listings.values());
    const activeListings = listings.filter(l => l.status === 'active');
    const totalSales = this.sales.length;
    const totalRevenue = this.sales.reduce((sum, s) => sum + s.price, 0);
    const totalCreatorEarnings = this.sales.reduce((sum, s) => sum + s.creatorEarning, 0);
    const totalPlatformFees = this.sales.reduce((sum, s) => sum + s.platformFee, 0);

    return {
      totalListings: listings.length,
      activeListings: activeListings.length,
      totalSales,
      totalRevenue: totalRevenue.toFixed(2),
      totalCreatorEarnings: totalCreatorEarnings.toFixed(2),
      totalPlatformFees: totalPlatformFees.toFixed(2),
      averageSalePrice: totalSales > 0 ? (totalRevenue / totalSales).toFixed(2) : 0
    };
  }
}

module.exports = IMVULAssetStore;
