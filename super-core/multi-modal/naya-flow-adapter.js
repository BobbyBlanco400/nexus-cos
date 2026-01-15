/**
 * NAYA Flow Adapter
 * Handles NAYA Flow multi-modal input processing
 * Part of Super-Core multi-modal layer
 */

class NAYAFlowAdapter {
  constructor(config = {}) {
    this.config = {
      flowSensitivity: config.flowSensitivity || 0.8,
      gestureThreshold: config.gestureThreshold || 0.7,
      enablePrediction: config.enablePrediction !== false,
      ...config
    };
    this.activeFlows = new Map();
    this.gestureLibrary = new Map();
  }

  /**
   * Initialize NAYA Flow adapter
   */
  async initialize() {
    console.log('🌊 NAYA Flow Adapter initializing...');
    
    // Load gesture library
    this.loadGestureLibrary();
    
    console.log('✅ NAYA Flow Adapter ready');
    return true;
  }

  /**
   * Process NAYA Flow input
   * @param {Object} flowData - Raw flow data from NAYA
   */
  async process(flowData) {
    const flowId = this.generateFlowId();
    
    console.log(`🌊 Processing NAYA Flow: ${flowId}`);

    try {
      // Validate flow data
      this.validateFlowData(flowData);

      // Detect gesture
      const gesture = await this.detectGesture(flowData);

      // Analyze flow pattern
      const pattern = this.analyzeFlowPattern(flowData);

      // Generate normalized output
      const output = {
        flowId,
        type: 'naya-flow',
        gesture: gesture.name,
        confidence: gesture.confidence,
        pattern,
        intent: this.interpretIntent(gesture, pattern),
        parameters: this.extractParameters(flowData, gesture),
        timestamp: Date.now()
      };

      // Track active flow
      this.activeFlows.set(flowId, {
        flowData,
        output,
        startTime: Date.now()
      });

      return output;
    } catch (error) {
      console.error(`❌ NAYA Flow processing failed:`, error.message);
      throw error;
    }
  }

  /**
   * Validate flow data
   */
  validateFlowData(flowData) {
    if (!flowData || typeof flowData !== 'object') {
      throw new Error('Invalid flow data');
    }

    // Check required fields
    const requiredFields = ['sequence', 'intensity'];
    for (const field of requiredFields) {
      if (!(field in flowData)) {
        console.warn(`⚠️  Missing field: ${field}`);
      }
    }
  }

  /**
   * Detect gesture from flow data
   */
  async detectGesture(flowData) {
    const sequence = flowData.sequence || [];
    const intensity = flowData.intensity || 1.0;

    // Match against known gestures
    let bestMatch = {
      name: 'unknown',
      confidence: 0
    };

    for (const [gestureName, gesturePattern] of this.gestureLibrary.entries()) {
      const confidence = this.calculateGestureConfidence(sequence, gesturePattern);
      
      if (confidence > bestMatch.confidence && confidence >= this.config.gestureThreshold) {
        bestMatch = {
          name: gestureName,
          confidence,
          pattern: gesturePattern
        };
      }
    }

    return bestMatch;
  }

  /**
   * Calculate gesture matching confidence
   */
  calculateGestureConfidence(sequence, pattern) {
    if (!sequence || !pattern || sequence.length === 0) {
      return 0;
    }

    // Simple pattern matching (would use ML in production)
    let matches = 0;
    const maxLength = Math.max(sequence.length, pattern.length);

    for (let i = 0; i < Math.min(sequence.length, pattern.length); i++) {
      if (this.compareFlowPoints(sequence[i], pattern[i])) {
        matches++;
      }
    }

    return matches / maxLength;
  }

  /**
   * Compare flow points
   */
  compareFlowPoints(point1, point2) {
    if (!point1 || !point2) return false;
    
    // Simple comparison (would use more sophisticated matching in production)
    const threshold = 0.1;
    
    return Math.abs(point1.x - point2.x) < threshold &&
           Math.abs(point1.y - point2.y) < threshold;
  }

  /**
   * Analyze flow pattern
   */
  analyzeFlowPattern(flowData) {
    const sequence = flowData.sequence || [];
    
    if (sequence.length === 0) {
      return { type: 'static', complexity: 0 };
    }

    // Calculate pattern metrics
    const velocity = this.calculateVelocity(sequence);
    const direction = this.calculateDirection(sequence);
    const complexity = this.calculateComplexity(sequence);

    return {
      type: this.classifyPattern(velocity, complexity),
      velocity,
      direction,
      complexity,
      pointCount: sequence.length
    };
  }

  /**
   * Calculate flow velocity
   */
  calculateVelocity(sequence) {
    if (sequence.length < 2) return 0;

    let totalDistance = 0;
    for (let i = 1; i < sequence.length; i++) {
      const dx = sequence[i].x - sequence[i-1].x;
      const dy = sequence[i].y - sequence[i-1].y;
      totalDistance += Math.sqrt(dx * dx + dy * dy);
    }

    return totalDistance / sequence.length;
  }

  /**
   * Calculate flow direction
   */
  calculateDirection(sequence) {
    if (sequence.length < 2) return { x: 0, y: 0 };

    const start = sequence[0];
    const end = sequence[sequence.length - 1];

    return {
      x: end.x - start.x,
      y: end.y - start.y,
      angle: Math.atan2(end.y - start.y, end.x - start.x)
    };
  }

  /**
   * Calculate pattern complexity
   */
  calculateComplexity(sequence) {
    if (sequence.length < 3) return 0;

    let directionChanges = 0;
    let prevAngle = null;

    for (let i = 1; i < sequence.length; i++) {
      const dx = sequence[i].x - sequence[i-1].x;
      const dy = sequence[i].y - sequence[i-1].y;
      const angle = Math.atan2(dy, dx);

      if (prevAngle !== null) {
        const angleDiff = Math.abs(angle - prevAngle);
        if (angleDiff > Math.PI / 4) { // 45 degrees
          directionChanges++;
        }
      }

      prevAngle = angle;
    }

    return Math.min(directionChanges / sequence.length, 1.0);
  }

  /**
   * Classify pattern type
   */
  classifyPattern(velocity, complexity) {
    if (velocity < 0.1) return 'static';
    if (complexity < 0.2) return 'linear';
    if (complexity < 0.5) return 'curved';
    return 'complex';
  }

  /**
   * Interpret intent from gesture and pattern
   */
  interpretIntent(gesture, pattern) {
    // Map gestures to intents
    const intentMap = {
      'swipe-right': 'navigate-forward',
      'swipe-left': 'navigate-back',
      'tap': 'select',
      'double-tap': 'activate',
      'hold': 'context-menu',
      'pinch': 'zoom',
      'rotate': 'rotate'
    };

    return intentMap[gesture.name] || 'unknown';
  }

  /**
   * Extract parameters from flow data
   */
  extractParameters(flowData, gesture) {
    return {
      intensity: flowData.intensity || 1.0,
      duration: flowData.duration || 0,
      pressure: flowData.pressure || 1.0,
      gestureSpecific: gesture.pattern?.parameters || {}
    };
  }

  /**
   * Load gesture library
   */
  loadGestureLibrary() {
    // Register common gestures
    this.registerGesture('tap', [
      { x: 0, y: 0 }
    ]);

    this.registerGesture('swipe-right', [
      { x: 0, y: 0 },
      { x: 0.5, y: 0 },
      { x: 1, y: 0 }
    ]);

    this.registerGesture('swipe-left', [
      { x: 1, y: 0 },
      { x: 0.5, y: 0 },
      { x: 0, y: 0 }
    ]);

    this.registerGesture('double-tap', [
      { x: 0, y: 0 },
      { x: 0, y: 0 }
    ]);

    console.log('  📚 Loaded gesture library');
  }

  /**
   * Register custom gesture
   */
  registerGesture(name, pattern, metadata = {}) {
    this.gestureLibrary.set(name, {
      pattern,
      metadata
    });
    
    console.log(`  ✋ Registered gesture: ${name}`);
  }

  /**
   * Generate flow ID
   */
  generateFlowId() {
    return `flow_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Get active flows
   */
  getActiveFlows() {
    return Array.from(this.activeFlows.entries()).map(([id, flow]) => ({
      id,
      gesture: flow.output.gesture,
      confidence: flow.output.confidence,
      startTime: flow.startTime
    }));
  }

  /**
   * Get statistics
   */
  getStatistics() {
    const gestures = Array.from(this.activeFlows.values())
      .map(flow => flow.output.gesture);
    
    const gestureCount = {};
    gestures.forEach(g => {
      gestureCount[g] = (gestureCount[g] || 0) + 1;
    });

    return {
      totalFlows: this.activeFlows.size,
      registeredGestures: this.gestureLibrary.size,
      gestureDistribution: gestureCount
    };
  }
}

module.exports = NAYAFlowAdapter;
