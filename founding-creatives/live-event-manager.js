/**
 * Live Event Manager
 * Manages live events and sessions for founding creatives
 * Part of Founding Creatives launch infrastructure
 */

class LiveEventManager {
  constructor(config = {}) {
    this.config = {
      maxConcurrentEvents: config.maxConcurrentEvents || 5,
      defaultDuration: config.defaultDuration || 60 * 60 * 1000, // 1 hour
      enableRecording: config.enableRecording !== false,
      ...config
    };
    this.activeEvents = new Map();
    this.eventHistory = [];
  }

  /**
   * Initialize live event manager
   */
  async initialize() {
    console.log('🎥 Live Event Manager initializing...');
    console.log(`  📊 Max concurrent events: ${this.config.maxConcurrentEvents}`);
    console.log(`  🎬 Recording: ${this.config.enableRecording ? 'Enabled' : 'Disabled'}`);
    console.log('✅ Live Event Manager ready');
    return true;
  }

  /**
   * Launch live event
   * @param {Object} eventDetails - Event configuration
   */
  async launchEvent(eventDetails) {
    console.log(`🎥 Launching live event: ${eventDetails.name}`);

    // Check capacity
    if (this.activeEvents.size >= this.config.maxConcurrentEvents) {
      throw new Error('Maximum concurrent events reached');
    }

    const eventId = this.generateEventId();

    const event = {
      eventId,
      name: eventDetails.name,
      type: eventDetails.type || 'live-session',
      tenant: eventDetails.tenant || 'FoundingTenant1',
      host: eventDetails.host,
      startTime: Date.now(),
      scheduledDuration: eventDetails.duration || this.config.defaultDuration,
      status: 'live',
      participants: new Set(),
      recording: this.config.enableRecording ? {
        enabled: true,
        recordingId: this.generateRecordingId()
      } : null,
      interactions: [],
      features: this.setupEventFeatures(eventDetails)
    };

    // Start event
    this.activeEvents.set(eventId, event);

    console.log(`  ✅ Event launched: ${eventId}`);
    console.log(`     Tenant: ${event.tenant}`);
    console.log(`     Duration: ${event.scheduledDuration / 1000}s`);

    return event;
  }

  /**
   * Setup event features
   */
  setupEventFeatures(eventDetails) {
    const features = {
      chat: eventDetails.enableChat !== false,
      qna: eventDetails.enableQnA !== false,
      polls: eventDetails.enablePolls !== false,
      showcase: eventDetails.enableShowcase !== false,
      arvr: eventDetails.enableARVR || false,
      multiModal: eventDetails.enableMultiModal || false
    };

    return features;
  }

  /**
   * Add participant to event
   */
  async addParticipant(eventId, userId) {
    const event = this.activeEvents.get(eventId);

    if (!event) {
      throw new Error('Event not found');
    }

    if (event.status !== 'live') {
      throw new Error('Event is not live');
    }

    event.participants.add(userId);
    
    console.log(`  👤 Participant joined: ${userId} (total: ${event.participants.size})`);

    // Log interaction
    this.logInteraction(eventId, {
      type: 'join',
      userId,
      timestamp: Date.now()
    });

    return event;
  }

  /**
   * Remove participant from event
   */
  async removeParticipant(eventId, userId) {
    const event = this.activeEvents.get(eventId);

    if (!event) {
      throw new Error('Event not found');
    }

    event.participants.delete(userId);
    
    console.log(`  👤 Participant left: ${userId} (remaining: ${event.participants.size})`);

    // Log interaction
    this.logInteraction(eventId, {
      type: 'leave',
      userId,
      timestamp: Date.now()
    });

    return event;
  }

  /**
   * Log event interaction
   */
  logInteraction(eventId, interaction) {
    const event = this.activeEvents.get(eventId);

    if (event) {
      event.interactions.push(interaction);
    }
  }

  /**
   * Handle Q&A question
   */
  async submitQuestion(eventId, userId, question) {
    const event = this.activeEvents.get(eventId);

    if (!event) {
      throw new Error('Event not found');
    }

    if (!event.features.qna) {
      throw new Error('Q&A not enabled for this event');
    }

    const questionId = this.generateQuestionId();

    const qnaEntry = {
      questionId,
      userId,
      question,
      timestamp: Date.now(),
      answered: false,
      answer: null
    };

    this.logInteraction(eventId, {
      type: 'qna-question',
      ...qnaEntry
    });

    console.log(`  ❓ Q&A question submitted by ${userId}`);

    return qnaEntry;
  }

  /**
   * Answer Q&A question
   */
  async answerQuestion(eventId, questionId, answer) {
    const event = this.activeEvents.get(eventId);

    if (!event) {
      throw new Error('Event not found');
    }

    const question = event.interactions.find(
      i => i.type === 'qna-question' && i.questionId === questionId
    );

    if (!question) {
      throw new Error('Question not found');
    }

    question.answered = true;
    question.answer = answer;
    question.answeredAt = Date.now();

    console.log(`  ✅ Q&A question answered: ${questionId}`);

    return question;
  }

  /**
   * Showcase asset during event
   */
  async showcaseAsset(eventId, assetId, showcaseDetails) {
    const event = this.activeEvents.get(eventId);

    if (!event) {
      throw new Error('Event not found');
    }

    if (!event.features.showcase) {
      throw new Error('Asset showcase not enabled for this event');
    }

    this.logInteraction(eventId, {
      type: 'asset-showcase',
      assetId,
      showcaseDetails,
      timestamp: Date.now()
    });

    console.log(`  🎨 Asset showcased: ${assetId}`);

    return { assetId, eventId, showcased: true };
  }

  /**
   * End event
   */
  async endEvent(eventId) {
    const event = this.activeEvents.get(eventId);

    if (!event) {
      throw new Error('Event not found');
    }

    event.endTime = Date.now();
    event.actualDuration = event.endTime - event.startTime;
    event.status = 'ended';

    // Finalize recording
    if (event.recording) {
      event.recording.endTime = event.endTime;
      event.recording.duration = event.actualDuration;
      event.recording.status = 'completed';
    }

    // Generate event summary
    event.summary = this.generateEventSummary(event);

    // Move to history
    this.eventHistory.push(event);
    this.activeEvents.delete(eventId);

    console.log(`🏁 Event ended: ${eventId}`);
    console.log(`   Duration: ${(event.actualDuration / 1000).toFixed(0)}s`);
    console.log(`   Participants: ${event.participants.size}`);
    console.log(`   Interactions: ${event.interactions.length}`);

    return event;
  }

  /**
   * Generate event summary
   */
  generateEventSummary(event) {
    const participantCount = event.participants.size;
    const interactionCount = event.interactions.length;
    
    const interactionTypes = {};
    event.interactions.forEach(i => {
      interactionTypes[i.type] = (interactionTypes[i.type] || 0) + 1;
    });

    return {
      totalParticipants: participantCount,
      totalInteractions: interactionCount,
      interactionBreakdown: interactionTypes,
      duration: event.actualDuration,
      recordingAvailable: event.recording?.status === 'completed'
    };
  }

  /**
   * Get active event
   */
  getEvent(eventId) {
    return this.activeEvents.get(eventId) || 
           this.eventHistory.find(e => e.eventId === eventId);
  }

  /**
   * Get all active events
   */
  getActiveEvents() {
    return Array.from(this.activeEvents.values());
  }

  /**
   * Get event history
   */
  getEventHistory(options = {}) {
    let history = [...this.eventHistory];

    // Apply filters
    if (options.tenant) {
      history = history.filter(e => e.tenant === options.tenant);
    }

    if (options.type) {
      history = history.filter(e => e.type === options.type);
    }

    // Sort by date (newest first)
    history.sort((a, b) => b.startTime - a.startTime);

    // Limit results
    if (options.limit) {
      history = history.slice(0, options.limit);
    }

    return history;
  }

  /**
   * Generate event ID
   */
  generateEventId() {
    return `EVENT_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Generate recording ID
   */
  generateRecordingId() {
    return `REC_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Generate question ID
   */
  generateQuestionId() {
    return `Q_${Date.now()}_${Math.random().toString(36).substr(2, 6)}`;
  }

  /**
   * Get statistics
   */
  getStatistics() {
    const allEvents = [...this.activeEvents.values(), ...this.eventHistory];
    const totalParticipants = allEvents.reduce(
      (sum, e) => sum + e.participants.size, 0
    );
    const totalInteractions = allEvents.reduce(
      (sum, e) => sum + e.interactions.length, 0
    );

    return {
      activeEvents: this.activeEvents.size,
      totalEventsCompleted: this.eventHistory.length,
      totalEvents: allEvents.length,
      totalParticipants,
      totalInteractions,
      averageParticipantsPerEvent: allEvents.length > 0 
        ? (totalParticipants / allEvents.length).toFixed(1) 
        : 0,
      recordingsAvailable: this.eventHistory.filter(
        e => e.recording?.status === 'completed'
      ).length
    };
  }
}

module.exports = LiveEventManager;
