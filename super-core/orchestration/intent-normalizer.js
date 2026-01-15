/**
 * Intent Normalizer
 * Converts multi-modal inputs into normalized JSON payloads
 * Part of Super-Core orchestration layer
 */

class IntentNormalizer {
  constructor(config = {}) {
    this.config = {
      supportedInputTypes: ['naya-flow', 'touch', 'voice', 'spatial'],
      validationEnabled: config.validationEnabled !== false,
      ...config
    };
  }

  /**
   * Normalize input from any source into standard JSON payload
   * @param {Object} input - Raw input from any modality
   * @returns {Object} Normalized JSON payload
   */
  normalize(input) {
    if (!input || typeof input !== 'object') {
      throw new Error('Invalid input: must be an object');
    }

    const inputType = this.detectInputType(input);
    
    console.log(`📥 Normalizing ${inputType} input`);

    let normalized;
    
    switch (inputType) {
      case 'naya-flow':
        normalized = this.normalizeNayaFlow(input);
        break;
      case 'touch':
        normalized = this.normalizeTouch(input);
        break;
      case 'voice':
        normalized = this.normalizeVoice(input);
        break;
      case 'spatial':
        normalized = this.normalizeSpatial(input);
        break;
      default:
        normalized = this.normalizeGeneric(input);
    }

    // Add metadata
    normalized.metadata = {
      inputType,
      timestamp: Date.now(),
      normalizedBy: 'IntentNormalizer',
      version: '1.0.0'
    };

    // Validate if enabled
    if (this.config.validationEnabled) {
      this.validatePayload(normalized);
    }

    return normalized;
  }

  /**
   * Detect input type from input structure
   */
  detectInputType(input) {
    if (input.type) {
      return input.type;
    }

    // Auto-detect based on structure
    if (input.gesture || input.flow) return 'naya-flow';
    if (input.transcript || input.voice) return 'voice';
    if (input.coordinates || input.touch) return 'touch';
    if (input.spatial || input.position) return 'spatial';
    
    return 'generic';
  }

  /**
   * Normalize NAYA Flow input
   */
  normalizeNayaFlow(input) {
    return {
      intent: input.intent || 'unknown',
      action: input.action || input.gesture || 'none',
      parameters: input.parameters || input.flow || {},
      context: {
        flow: input.flow || {},
        gesture: input.gesture || null
      }
    };
  }

  /**
   * Normalize touch input
   */
  normalizeTouch(input) {
    return {
      intent: 'interaction',
      action: input.action || input.touchType || 'tap',
      parameters: {
        x: input.x || input.coordinates?.x || 0,
        y: input.y || input.coordinates?.y || 0,
        pressure: input.pressure || 1.0,
        duration: input.duration || 0
      },
      context: {
        element: input.element || null,
        touchType: input.touchType || 'tap'
      }
    };
  }

  /**
   * Normalize voice input
   */
  normalizeVoice(input) {
    return {
      intent: this.extractIntent(input.transcript || input.voice || ''),
      action: input.action || 'voice-command',
      parameters: {
        transcript: input.transcript || input.voice || '',
        confidence: input.confidence || 1.0,
        language: input.language || 'en-US'
      },
      context: {
        voice: true,
        raw: input.transcript || input.voice || ''
      }
    };
  }

  /**
   * Normalize spatial gesture input
   */
  normalizeSpatial(input) {
    return {
      intent: 'spatial-interaction',
      action: input.action || input.gestureType || 'move',
      parameters: {
        position: input.position || input.spatial || { x: 0, y: 0, z: 0 },
        velocity: input.velocity || { x: 0, y: 0, z: 0 },
        rotation: input.rotation || { x: 0, y: 0, z: 0 }
      },
      context: {
        spatial: true,
        gestureType: input.gestureType || 'move'
      }
    };
  }

  /**
   * Normalize generic input
   */
  normalizeGeneric(input) {
    return {
      intent: input.intent || 'generic',
      action: input.action || 'unknown',
      parameters: input.parameters || input.data || {},
      context: {
        generic: true,
        raw: input
      }
    };
  }

  /**
   * Extract intent from voice transcript (simplified NLU)
   */
  extractIntent(transcript) {
    const lower = transcript.toLowerCase();
    
    if (lower.includes('create') || lower.includes('make')) return 'create';
    if (lower.includes('open') || lower.includes('launch')) return 'open';
    if (lower.includes('close') || lower.includes('exit')) return 'close';
    if (lower.includes('save')) return 'save';
    if (lower.includes('delete') || lower.includes('remove')) return 'delete';
    
    return 'unknown';
  }

  /**
   * Validate normalized payload
   */
  validatePayload(payload) {
    if (!payload.intent) {
      throw new Error('Normalized payload missing intent');
    }
    if (!payload.action) {
      throw new Error('Normalized payload missing action');
    }
    if (!payload.parameters || typeof payload.parameters !== 'object') {
      throw new Error('Normalized payload missing or invalid parameters');
    }
    
    return true;
  }

  /**
   * Batch normalize multiple inputs
   */
  normalizeBatch(inputs) {
    if (!Array.isArray(inputs)) {
      throw new Error('Batch input must be an array');
    }

    return inputs.map(input => {
      try {
        return this.normalize(input);
      } catch (error) {
        console.error('Failed to normalize input:', error);
        return null;
      }
    }).filter(Boolean);
  }
}

module.exports = IntentNormalizer;
