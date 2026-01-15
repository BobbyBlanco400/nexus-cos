/**
 * Registration Service
 * Handles founding creatives registration and onboarding
 * Part of Founding Creatives launch infrastructure
 */

class RegistrationService {
  constructor(config = {}) {
    this.config = {
      maxFoundingSlots: config.maxFoundingSlots || 100,
      entryFeeMin: config.entryFeeMin || 20,
      entryFeeMax: config.entryFeeMax || 50,
      windowDuration: config.windowDuration || 48 * 60 * 60 * 1000, // 48 hours
      ...config
    };
    this.registrations = new Map();
    this.foundingSlots = 0;
    this.launchWindowStart = null;
  }

  /**
   * Initialize registration service
   */
  async initialize() {
    console.log('🚀 Registration Service initializing...');
    console.log(`  📊 Founding slots available: ${this.config.maxFoundingSlots}`);
    console.log(`  💰 Entry fee range: $${this.config.entryFeeMin}-$${this.config.entryFeeMax}`);
    console.log('✅ Registration Service ready');
    return true;
  }

  /**
   * Open launch window
   */
  async openLaunchWindow() {
    if (this.launchWindowStart) {
      throw new Error('Launch window already open');
    }

    this.launchWindowStart = Date.now();
    console.log('🚀 Founding Creatives Launch Window OPENED');
    console.log(`  ⏱️  Window duration: ${this.config.windowDuration / (60 * 60 * 1000)} hours`);
    
    return {
      startTime: this.launchWindowStart,
      endTime: this.launchWindowStart + this.config.windowDuration,
      slotsAvailable: this.config.maxFoundingSlots - this.foundingSlots
    };
  }

  /**
   * Register founding creative
   * @param {Object} userData - User registration data
   */
  async register(userData) {
    // Validate launch window
    if (!this.launchWindowStart) {
      throw new Error('Launch window not open');
    }

    if (!this.isLaunchWindowActive()) {
      throw new Error('Launch window has closed');
    }

    // Check slot availability
    if (this.foundingSlots >= this.config.maxFoundingSlots) {
      throw new Error('All founding slots are filled');
    }

    // Validate user data
    this.validateUserData(userData);

    // Validate entry fee
    this.validateEntryFee(userData.entryFee);

    // Generate registration
    const registrationId = this.generateRegistrationId();
    const userId = userData.userId || this.generateUserId();
    const tenantId = this.generateTenantId(this.foundingSlots + 1);

    const registration = {
      registrationId,
      userId,
      tenantId,
      username: userData.username,
      email: userData.email,
      entryFee: userData.entryFee,
      premiumBundle: userData.premiumBundle || null,
      registeredAt: Date.now(),
      status: 'pending',
      foundingSlot: this.foundingSlots + 1,
      role: 'FoundingCreative',
      privileges: this.getFoundingPrivileges()
    };

    // Store registration
    this.registrations.set(registrationId, registration);
    this.foundingSlots++;

    console.log(`✅ Registered Founding Creative #${registration.foundingSlot}`);
    console.log(`   User: ${userData.username}`);
    console.log(`   Tenant: ${tenantId}`);
    console.log(`   Entry Fee: $${userData.entryFee}`);

    return registration;
  }

  /**
   * Validate user data
   */
  validateUserData(userData) {
    const required = ['username', 'email', 'entryFee'];
    
    for (const field of required) {
      if (!userData[field]) {
        throw new Error(`Missing required field: ${field}`);
      }
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(userData.email)) {
      throw new Error('Invalid email format');
    }

    // Check for duplicate username
    for (const reg of this.registrations.values()) {
      if (reg.username === userData.username) {
        throw new Error('Username already taken');
      }
    }
  }

  /**
   * Validate entry fee
   */
  validateEntryFee(entryFee) {
    const fee = parseFloat(entryFee);
    
    if (isNaN(fee) || fee < this.config.entryFeeMin || fee > this.config.entryFeeMax) {
      throw new Error(
        `Entry fee must be between $${this.config.entryFeeMin} and $${this.config.entryFeeMax}`
      );
    }
  }

  /**
   * Check if launch window is active
   */
  isLaunchWindowActive() {
    if (!this.launchWindowStart) return false;
    
    const elapsed = Date.now() - this.launchWindowStart;
    return elapsed < this.config.windowDuration;
  }

  /**
   * Get founding privileges
   */
  getFoundingPrivileges() {
    return {
      fullStackAccess: true,
      exclusiveAssets: true,
      prioritySupport: true,
      lifetimeLicense: true,
      revenueShare: '80/20', // 80% creator, 20% platform
      badge: 'FoundingCreative',
      early: 'access benefits to all future features'
    };
  }

  /**
   * Activate registration
   */
  async activateRegistration(registrationId, paymentProof) {
    const registration = this.registrations.get(registrationId);
    
    if (!registration) {
      throw new Error('Registration not found');
    }

    if (registration.status === 'active') {
      throw new Error('Registration already active');
    }

    // Verify payment (simplified - would integrate with payment processor)
    if (!paymentProof || !paymentProof.confirmed) {
      throw new Error('Payment not confirmed');
    }

    registration.status = 'active';
    registration.activatedAt = Date.now();
    registration.paymentProof = paymentProof;

    console.log(`🎉 Activated Founding Creative: ${registration.username}`);

    return registration;
  }

  /**
   * Get registration
   */
  getRegistration(registrationId) {
    return this.registrations.get(registrationId);
  }

  /**
   * Get all registrations
   */
  getAllRegistrations() {
    return Array.from(this.registrations.values());
  }

  /**
   * Get active registrations
   */
  getActiveRegistrations() {
    return Array.from(this.registrations.values())
      .filter(reg => reg.status === 'active');
  }

  /**
   * Generate registration ID
   */
  generateRegistrationId() {
    return `REG_FC_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Generate user ID
   */
  generateUserId() {
    return `USER_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Generate tenant ID
   */
  generateTenantId(slotNumber) {
    return `FoundingTenant${slotNumber}`;
  }

  /**
   * Get statistics
   */
  getStatistics() {
    const registrations = Array.from(this.registrations.values());
    const active = registrations.filter(r => r.status === 'active');
    const totalRevenue = registrations.reduce((sum, r) => sum + parseFloat(r.entryFee), 0);
    const premiumBundles = registrations.filter(r => r.premiumBundle).length;

    return {
      totalRegistrations: registrations.length,
      activeRegistrations: active.length,
      slotsRemaining: this.config.maxFoundingSlots - this.foundingSlots,
      totalRevenue: totalRevenue.toFixed(2),
      averageEntryFee: (totalRevenue / Math.max(registrations.length, 1)).toFixed(2),
      premiumBundles,
      windowActive: this.isLaunchWindowActive(),
      windowStart: this.launchWindowStart,
      windowEnd: this.launchWindowStart ? this.launchWindowStart + this.config.windowDuration : null
    };
  }

  /**
   * Close launch window
   */
  async closeLaunchWindow() {
    if (!this.launchWindowStart) {
      throw new Error('Launch window not open');
    }

    const stats = this.getStatistics();
    
    console.log('🏁 Closing Founding Creatives Launch Window');
    console.log(`  📊 Total Registrations: ${stats.totalRegistrations}`);
    console.log(`  ✅ Active Registrations: ${stats.activeRegistrations}`);
    console.log(`  💰 Total Revenue: $${stats.totalRevenue}`);

    return stats;
  }
}

module.exports = RegistrationService;
