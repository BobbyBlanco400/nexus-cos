/**
 * Input Layer Orchestrator
 * Manages multi-modal inputs and routes to SuperCore
 * ADD-ON MODULE - Integrates with existing SuperCore via adapter
 */

class InputLayerOrchestrator {
  constructor(config = {}) {
    this.config = {
      supportedInputs: ['touch', 'voice', 'spatial', 'naya-flow'],
      enableNormalization: config.enableNormalization !== false,
      ...config
    };
    this.inputHandlers = new Map();
    this.supercoreAdapter = null;
  }

  /**
   * Initialize input orchestrator
   */
  async initialize(supercoreAdapter) {
    console.log('🎮 Input Layer Orchestrator initializing...');
    
    this.supercoreAdapter = supercoreAdapter;
    
    // Register input handlers
    this.registerDefaultHandlers();
    
    console.log('✅ Input Layer Orchestrator ready');
    return true;
  }

  /**
   * Process input from any modality
   * @param {Object} input - Raw input from any source
   */
  async processInput(input) {
    console.log(`🎮 Processing ${input.type || 'unknown'} input`);

    try {
      // Detect input type
      const inputType = input.type || this.detectInputType(input);
      
      // Get appropriate handler
      const handler = this.inputHandlers.get(inputType);
      
      if (!handler) {
        throw new Error(`No handler registered for input type: ${inputType}`);
      }

      // Process with handler
      const processed = await handler(input);
      
      // Normalize if enabled
      const normalized = this.config.enableNormalization 
        ? this.normalizeInput(processed)
        : processed;

      // Forward to SuperCore if adapter available
      if (this.supercoreAdapter) {
        const result = await this.supercoreAdapter.processIntent(normalized);
        return result;
      }

      return normalized;
    } catch (error) {
      console.error('❌ Input processing failed:', error.message);
      throw error;
    }
  }

  /**
   * Detect input type from structure
   */
  detectInputType(input) {
    if (input.touch || input.coordinates) return 'touch';
    if (input.voice || input.transcript) return 'voice';
    if (input.spatial || input.position) return 'spatial';
    if (input.flow || input.gesture) return 'naya-flow';
    return 'generic';
  }

  /**
   * Normalize input to standard format
   */
  normalizeInput(input) {
    return {
      type: input.type || 'generic',
      intent: input.intent || 'unknown',
      action: input.action || 'none',
      parameters: input.parameters || {},
      context: input.context || {},
      metadata: {
        timestamp: Date.now(),
        normalized: true
      }
    };
  }

  /**
   * Register default input handlers
   */
  registerDefaultHandlers() {
    // Touch handler
    this.registerHandler('touch', async (input) => {
      return {
        type: 'touch',
        intent: 'interaction',
        action: input.action || 'tap',
        parameters: {
          x: input.x || 0,
          y: input.y || 0,
          pressure: input.pressure || 1.0
        },
        context: { touch: true }
      };
    });

    // Voice handler
    this.registerHandler('voice', async (input) => {
      return {
        type: 'voice',
        intent: this.extractVoiceIntent(input.transcript || input.voice || ''),
        action: 'voice-command',
        parameters: {
          transcript: input.transcript || input.voice || '',
          confidence: input.confidence || 1.0
        },
        context: { voice: true }
      };
    });

    // Spatial handler
    this.registerHandler('spatial', async (input) => {
      return {
        type: 'spatial',
        intent: 'spatial-interaction',
        action: input.action || 'move',
        parameters: {
          position: input.position || { x: 0, y: 0, z: 0 },
          rotation: input.rotation || { x: 0, y: 0, z: 0 }
        },
        context: { spatial: true }
      };
    });

    // NAYA Flow handler
    this.registerHandler('naya-flow', async (input) => {
      return {
        type: 'naya-flow',
        intent: input.intent || 'gesture',
        action: input.gesture || input.action || 'flow',
        parameters: {
          flow: input.flow || {},
          intensity: input.intensity || 1.0
        },
        context: { nayaFlow: true }
      };
    });

    console.log('  📝 Registered default input handlers');
  }

  /**
   * Extract intent from voice transcript
   */
  extractVoiceIntent(transcript) {
    const lower = transcript.toLowerCase();
    
    if (lower.includes('create')) return 'create';
    if (lower.includes('open')) return 'open';
    if (lower.includes('close')) return 'close';
    if (lower.includes('save')) return 'save';
    
    return 'unknown';
  }

  /**
   * Register custom input handler
   */
  registerHandler(inputType, handler) {
    this.inputHandlers.set(inputType, handler);
    console.log(`  📝 Registered handler: ${inputType}`);
  }

  /**
   * Get statistics
   */
  getStatistics() {
    return {
      registeredHandlers: this.inputHandlers.size,
      supportedInputs: this.config.supportedInputs,
      normalizationEnabled: this.config.enableNormalization,
      supercoreConnected: !!this.supercoreAdapter
    };
  }
}

module.exports = InputLayerOrchestrator;
