/**
 * Entry Fee Processor
 * Manages contest entry fees and prize distribution
 * Part of monetization infrastructure
 */

class EntryFeeProcessor {
  constructor(config = {}) {
    this.config = {
      minEntryFee: config.minEntryFee || 5.00,
      maxEntryFee: config.maxEntryFee || 100.00,
      platformFee: config.platformFee || 0.10, // 10% platform fee
      ...config
    };
    this.contests = new Map();
    this.entries = [];
  }

  /**
   * Initialize entry fee processor
   */
  async initialize() {
    console.log('🎯 Entry Fee Processor initializing...');
    console.log(`  💵 Entry fee range: $${this.config.minEntryFee} - $${this.config.maxEntryFee}`);
    console.log(`  🏦 Platform fee: ${(this.config.platformFee * 100).toFixed(1)}%`);
    console.log('✅ Entry Fee Processor ready');
    return true;
  }

  /**
   * Create contest
   * @param {Object} contestDetails - Contest configuration
   */
  async createContest(contestDetails) {
    console.log(`🎯 Creating contest: ${contestDetails.name}`);

    // Validate entry fee
    this.validateEntryFee(contestDetails.entryFee);

    const contestId = this.generateContestId();

    const contest = {
      contestId,
      name: contestDetails.name,
      description: contestDetails.description || '',
      entryFee: contestDetails.entryFee,
      prizePool: contestDetails.prizePool || 0,
      maxEntrants: contestDetails.maxEntrants || 100,
      startTime: contestDetails.startTime || Date.now(),
      endTime: contestDetails.endTime,
      createdAt: Date.now(),
      status: 'open',
      entries: [],
      totalFees: 0,
      platformFees: 0,
      prizeDistribution: contestDetails.prizeDistribution || {
        '1st': 0.50,  // 50% to 1st place
        '2nd': 0.30,  // 30% to 2nd place
        '3rd': 0.20   // 20% to 3rd place
      }
    };

    this.contests.set(contestId, contest);

    console.log(`  ✅ Contest created: ${contestId}`);
    console.log(`     Entry fee: $${contest.entryFee}`);
    console.log(`     Max entrants: ${contest.maxEntrants}`);

    return contest;
  }

  /**
   * Process entry
   * @param {string} contestId - Contest ID
   * @param {string} userId - User entering contest
   * @param {Object} submission - Contest submission
   */
  async processEntry(contestId, userId, submission) {
    const contest = this.contests.get(contestId);

    if (!contest) {
      throw new Error('Contest not found');
    }

    if (contest.status !== 'open') {
      throw new Error('Contest is not open for entries');
    }

    if (contest.entries.length >= contest.maxEntrants) {
      throw new Error('Contest is full');
    }

    // Check if user already entered
    if (contest.entries.some(e => e.userId === userId)) {
      throw new Error('User has already entered this contest');
    }

    const entryId = this.generateEntryId();

    const entry = {
      entryId,
      contestId,
      userId,
      submission,
      entryFee: contest.entryFee,
      platformFee: this.calculatePlatformFee(contest.entryFee),
      enteredAt: Date.now(),
      status: 'entered'
    };

    // Update contest
    contest.entries.push(entry);
    contest.totalFees += contest.entryFee;
    contest.platformFees += entry.platformFee;
    contest.prizePool = contest.totalFees - contest.platformFees;

    // Record entry
    this.entries.push(entry);

    console.log(`  🎯 Entry processed: ${userId}`);
    console.log(`     Entry fee: $${entry.entryFee}`);
    console.log(`     Prize pool now: $${contest.prizePool.toFixed(2)}`);

    return entry;
  }

  /**
   * Close contest and determine winners
   */
  async closeContest(contestId, winners) {
    const contest = this.contests.get(contestId);

    if (!contest) {
      throw new Error('Contest not found');
    }

    if (contest.status !== 'open') {
      throw new Error('Contest is not open');
    }

    contest.status = 'closed';
    contest.closedAt = Date.now();
    contest.winners = winners;

    // Calculate prize distribution
    const prizes = this.calculatePrizes(contest);
    contest.prizes = prizes;

    console.log(`🏆 Contest closed: ${contestId}`);
    console.log(`   Total entries: ${contest.entries.length}`);
    console.log(`   Prize pool: $${contest.prizePool.toFixed(2)}`);
    console.log(`   Winners:`);
    
    Object.entries(prizes).forEach(([place, amount]) => {
      const winner = winners[place];
      console.log(`     ${place}: ${winner} - $${amount.toFixed(2)}`);
    });

    return contest;
  }

  /**
   * Calculate prizes based on distribution
   */
  calculatePrizes(contest) {
    const prizes = {};
    const prizePool = contest.prizePool;

    for (const [place, percentage] of Object.entries(contest.prizeDistribution)) {
      prizes[place] = prizePool * percentage;
    }

    return prizes;
  }

  /**
   * Validate entry fee
   */
  validateEntryFee(entryFee) {
    const fee = parseFloat(entryFee);

    if (isNaN(fee) || fee < this.config.minEntryFee || fee > this.config.maxEntryFee) {
      throw new Error(
        `Entry fee must be between $${this.config.minEntryFee} and $${this.config.maxEntryFee}`
      );
    }
  }

  /**
   * Calculate platform fee
   */
  calculatePlatformFee(entryFee) {
    return entryFee * this.config.platformFee;
  }

  /**
   * Get contest
   */
  getContest(contestId) {
    return this.contests.get(contestId);
  }

  /**
   * Get open contests
   */
  getOpenContests() {
    return Array.from(this.contests.values())
      .filter(contest => contest.status === 'open');
  }

  /**
   * Get user entries
   */
  getUserEntries(userId) {
    return this.entries.filter(entry => entry.userId === userId);
  }

  /**
   * Generate contest ID
   */
  generateContestId() {
    return `CONTEST_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Generate entry ID
   */
  generateEntryId() {
    return `ENTRY_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Get statistics
   */
  getStatistics() {
    const contests = Array.from(this.contests.values());
    const openContests = contests.filter(c => c.status === 'open');
    const closedContests = contests.filter(c => c.status === 'closed');
    
    const totalEntries = this.entries.length;
    const totalFees = this.entries.reduce((sum, e) => sum + e.entryFee, 0);
    const totalPlatformFees = this.entries.reduce((sum, e) => sum + e.platformFee, 0);
    const totalPrizePool = contests.reduce((sum, c) => sum + (c.prizePool || 0), 0);

    return {
      totalContests: contests.length,
      openContests: openContests.length,
      closedContests: closedContests.length,
      totalEntries,
      totalFees: totalFees.toFixed(2),
      totalPlatformFees: totalPlatformFees.toFixed(2),
      totalPrizePool: totalPrizePool.toFixed(2),
      averageEntryFee: totalEntries > 0 ? (totalFees / totalEntries).toFixed(2) : 0
    };
  }
}

module.exports = EntryFeeProcessor;
