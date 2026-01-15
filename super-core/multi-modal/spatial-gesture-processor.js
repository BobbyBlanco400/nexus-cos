/**
 * Spatial Gesture Processor
 * Handles AR/VR spatial gestures and 3D interactions
 * Part of Super-Core multi-modal layer
 */

class SpatialGestureProcessor {
  constructor(config = {}) {
    this.config = {
      coordinateSystem: config.coordinateSystem || 'right-handed',
      gestureThreshold: config.gestureThreshold || 0.6,
      trackingRate: config.trackingRate || 60, // Hz
      ...config
    };
    this.activeGestures = new Map();
    this.gestureRecognizers = new Map();
  }

  /**
   * Initialize spatial gesture processor
   */
  async initialize() {
    console.log('🥽 Spatial Gesture Processor initializing...');
    
    // Load gesture recognizers
    this.loadGestureRecognizers();
    
    console.log('✅ Spatial Gesture Processor ready');
    return true;
  }

  /**
   * Process spatial input
   * @param {Object} spatialData - Spatial tracking data
   */
  async process(spatialData) {
    console.log('🥽 Processing spatial gesture...');

    try {
      // Validate spatial data
      this.validateSpatialData(spatialData);

      // Extract position and orientation
      const position = this.extractPosition(spatialData);
      const orientation = this.extractOrientation(spatialData);
      const velocity = this.calculateVelocity(spatialData);

      // Recognize gesture
      const gesture = await this.recognizeGesture(spatialData);

      // Determine interaction zone
      const zone = this.determineInteractionZone(position);

      // Generate output
      const output = {
        type: 'spatial',
        gesture: gesture.name,
        confidence: gesture.confidence,
        position,
        orientation,
        velocity,
        zone,
        intent: this.interpretSpatialIntent(gesture, position, velocity),
        parameters: this.extractSpatialParameters(spatialData, gesture),
        timestamp: Date.now()
      };

      return output;
    } catch (error) {
      console.error('❌ Spatial processing failed:', error.message);
      throw error;
    }
  }

  /**
   * Validate spatial data
   */
  validateSpatialData(spatialData) {
    if (!spatialData || typeof spatialData !== 'object') {
      throw new Error('Invalid spatial data');
    }

    // Check for position data
    if (!spatialData.position && !spatialData.x) {
      console.warn('⚠️  Missing position data');
    }
  }

  /**
   * Extract position from spatial data
   */
  extractPosition(spatialData) {
    if (spatialData.position) {
      return spatialData.position;
    }

    return {
      x: spatialData.x || 0,
      y: spatialData.y || 0,
      z: spatialData.z || 0
    };
  }

  /**
   * Extract orientation from spatial data
   */
  extractOrientation(spatialData) {
    if (spatialData.orientation) {
      return spatialData.orientation;
    }

    if (spatialData.rotation) {
      return spatialData.rotation;
    }

    return {
      pitch: spatialData.pitch || 0,
      yaw: spatialData.yaw || 0,
      roll: spatialData.roll || 0
    };
  }

  /**
   * Calculate velocity from spatial data
   */
  calculateVelocity(spatialData) {
    if (spatialData.velocity) {
      return spatialData.velocity;
    }

    // Would calculate from position history in production
    return {
      x: 0,
      y: 0,
      z: 0,
      magnitude: 0
    };
  }

  /**
   * Recognize gesture from spatial data
   */
  async recognizeGesture(spatialData) {
    let bestMatch = {
      name: 'none',
      confidence: 0
    };

    // Check each recognizer
    for (const [gestureName, recognizer] of this.gestureRecognizers.entries()) {
      const confidence = await recognizer(spatialData);
      
      if (confidence > bestMatch.confidence && confidence >= this.config.gestureThreshold) {
        bestMatch = {
          name: gestureName,
          confidence
        };
      }
    }

    return bestMatch;
  }

  /**
   * Determine interaction zone
   */
  determineInteractionZone(position) {
    const { x, y, z } = position;

    // Define interaction zones
    if (Math.abs(x) < 0.3 && Math.abs(y) < 0.3 && z < 0.5) {
      return 'near';
    }

    if (Math.abs(x) < 0.6 && Math.abs(y) < 0.6 && z < 1.0) {
      return 'mid';
    }

    return 'far';
  }

  /**
   * Interpret spatial intent
   */
  interpretSpatialIntent(gesture, position, velocity) {
    // Map gestures to intents
    const intentMap = {
      'point': 'select',
      'grab': 'manipulate',
      'pinch': 'precise-control',
      'swipe': 'navigate',
      'wave': 'dismiss',
      'push': 'activate',
      'pull': 'retrieve'
    };

    let intent = intentMap[gesture.name] || 'unknown';

    // Modify intent based on velocity
    if (velocity.magnitude > 1.0) {
      intent = `fast-${intent}`;
    }

    return intent;
  }

  /**
   * Extract spatial parameters
   */
  extractSpatialParameters(spatialData, gesture) {
    return {
      handedness: spatialData.handedness || 'right',
      fingers: spatialData.fingers || [],
      pressure: spatialData.pressure || 0,
      trackingQuality: spatialData.trackingQuality || 1.0,
      gestureSpecific: gesture.parameters || {}
    };
  }

  /**
   * Load gesture recognizers
   */
  loadGestureRecognizers() {
    // Register point gesture
    this.registerGestureRecognizer('point', (data) => {
      const position = this.extractPosition(data);
      // Simplified recognition - would use ML in production
      return position.z < 0.5 && Math.abs(position.x) < 0.2 ? 0.8 : 0.3;
    });

    // Register grab gesture
    this.registerGestureRecognizer('grab', (data) => {
      return data.fingers?.every(f => f.curled) ? 0.9 : 0.2;
    });

    // Register pinch gesture
    this.registerGestureRecognizer('pinch', (data) => {
      return data.pinchStrength > 0.7 ? 0.85 : 0.1;
    });

    // Register swipe gesture
    this.registerGestureRecognizer('swipe', (data) => {
      const velocity = this.calculateVelocity(data);
      return velocity.magnitude > 0.8 ? 0.75 : 0.1;
    });

    console.log('  👋 Loaded gesture recognizers');
  }

  /**
   * Register gesture recognizer
   */
  registerGestureRecognizer(name, recognizerFn) {
    this.gestureRecognizers.set(name, recognizerFn);
    console.log(`  ✋ Registered recognizer: ${name}`);
  }

  /**
   * Calculate distance between two positions
   */
  calculateDistance(pos1, pos2) {
    const dx = pos2.x - pos1.x;
    const dy = pos2.y - pos1.y;
    const dz = pos2.z - pos1.z;
    
    return Math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  /**
   * Track gesture over time
   */
  trackGesture(gestureId, gestureData) {
    this.activeGestures.set(gestureId, {
      ...gestureData,
      startTime: Date.now()
    });
  }

  /**
   * End gesture tracking
   */
  endGestureTracking(gestureId) {
    const gesture = this.activeGestures.get(gestureId);
    
    if (gesture) {
      gesture.endTime = Date.now();
      gesture.duration = gesture.endTime - gesture.startTime;
      this.activeGestures.delete(gestureId);
    }

    return gesture;
  }

  /**
   * Get active gestures
   */
  getActiveGestures() {
    return Array.from(this.activeGestures.entries()).map(([id, gesture]) => ({
      id,
      name: gesture.gesture,
      confidence: gesture.confidence,
      duration: Date.now() - gesture.startTime
    }));
  }

  /**
   * Get statistics
   */
  getStatistics() {
    return {
      activeGestures: this.activeGestures.size,
      registeredRecognizers: this.gestureRecognizers.size,
      coordinateSystem: this.config.coordinateSystem,
      trackingRate: this.config.trackingRate
    };
  }
}

module.exports = SpatialGestureProcessor;
