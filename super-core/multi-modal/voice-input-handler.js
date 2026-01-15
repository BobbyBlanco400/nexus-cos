/**
 * Voice Input Handler
 * Processes voice commands and natural language
 * Part of Super-Core multi-modal layer
 */

class VoiceInputHandler {
  constructor(config = {}) {
    this.config = {
      language: config.language || 'en-US',
      confidenceThreshold: config.confidenceThreshold || 0.7,
      enableNLU: config.enableNLU !== false,
      ...config
    };
    this.commandRegistry = new Map();
    this.activeListening = false;
  }

  /**
   * Initialize voice input handler
   */
  async initialize() {
    console.log('🎤 Voice Input Handler initializing...');
    
    // Load command registry
    this.loadCommandRegistry();
    
    console.log('✅ Voice Input Handler ready');
    return true;
  }

  /**
   * Process voice input
   * @param {Object} voiceData - Voice data (transcript, confidence, etc.)
   */
  async process(voiceData) {
    console.log('🎤 Processing voice input...');

    try {
      // Validate voice data
      this.validateVoiceData(voiceData);

      const transcript = voiceData.transcript || voiceData.text || '';
      const confidence = voiceData.confidence || 1.0;

      // Check confidence threshold
      if (confidence < this.config.confidenceThreshold) {
        console.warn(`⚠️  Low confidence: ${(confidence * 100).toFixed(1)}%`);
      }

      // Match command
      const command = this.matchCommand(transcript);

      // Extract entities if NLU enabled
      const entities = this.config.enableNLU ? this.extractEntities(transcript) : {};

      // Generate output
      const output = {
        type: 'voice',
        transcript,
        confidence,
        language: voiceData.language || this.config.language,
        command: command.name,
        commandConfidence: command.confidence,
        entities,
        intent: this.extractIntent(transcript, command),
        parameters: this.extractParameters(transcript, command, entities),
        timestamp: Date.now()
      };

      return output;
    } catch (error) {
      console.error('❌ Voice processing failed:', error.message);
      throw error;
    }
  }

  /**
   * Validate voice data
   */
  validateVoiceData(voiceData) {
    if (!voiceData || typeof voiceData !== 'object') {
      throw new Error('Invalid voice data');
    }

    if (!voiceData.transcript && !voiceData.text) {
      throw new Error('Voice data missing transcript');
    }
  }

  /**
   * Match command from transcript
   */
  matchCommand(transcript) {
    const lower = transcript.toLowerCase().trim();

    let bestMatch = {
      name: 'unknown',
      confidence: 0
    };

    // Check exact matches first
    for (const [commandName, commandData] of this.commandRegistry.entries()) {
      for (const pattern of commandData.patterns) {
        const confidence = this.calculateMatchConfidence(lower, pattern);
        
        if (confidence > bestMatch.confidence) {
          bestMatch = {
            name: commandName,
            confidence,
            pattern
          };
        }
      }
    }

    return bestMatch;
  }

  /**
   * Calculate match confidence
   */
  calculateMatchConfidence(transcript, pattern) {
    // Exact match
    if (transcript === pattern.toLowerCase()) {
      return 1.0;
    }

    // Contains pattern
    if (transcript.includes(pattern.toLowerCase())) {
      return 0.8;
    }

    // Word overlap
    const transcriptWords = transcript.split(/\s+/);
    const patternWords = pattern.toLowerCase().split(/\s+/);
    
    let matches = 0;
    for (const word of patternWords) {
      if (transcriptWords.includes(word)) {
        matches++;
      }
    }

    if (patternWords.length > 0) {
      return matches / patternWords.length * 0.6;
    }

    return 0;
  }

  /**
   * Extract intent from transcript
   */
  extractIntent(transcript, command) {
    if (command.name !== 'unknown') {
      return command.name;
    }

    // Fallback intent extraction
    const lower = transcript.toLowerCase();
    
    if (lower.match(/create|make|build|generate/)) return 'create';
    if (lower.match(/open|start|launch|begin/)) return 'open';
    if (lower.match(/close|stop|end|exit/)) return 'close';
    if (lower.match(/save|store|keep/)) return 'save';
    if (lower.match(/delete|remove|clear/)) return 'delete';
    if (lower.match(/show|display|view/)) return 'show';
    if (lower.match(/help|assist|support/)) return 'help';
    
    return 'unknown';
  }

  /**
   * Extract entities using NLU
   */
  extractEntities(transcript) {
    const entities = {
      numbers: [],
      names: [],
      locations: [],
      dates: []
    };

    // Extract numbers
    const numberMatches = transcript.match(/\d+/g);
    if (numberMatches) {
      entities.numbers = numberMatches.map(n => parseInt(n));
    }

    // Extract capitalized words (potential names)
    const nameMatches = transcript.match(/\b[A-Z][a-z]+\b/g);
    if (nameMatches) {
      entities.names = nameMatches;
    }

    return entities;
  }

  /**
   * Extract parameters from transcript
   */
  extractParameters(transcript, command, entities) {
    const parameters = {
      raw: transcript,
      entities
    };

    // Add command-specific parameters
    if (command.name !== 'unknown') {
      const commandData = this.commandRegistry.get(command.name);
      if (commandData?.extractParams) {
        Object.assign(parameters, commandData.extractParams(transcript, entities));
      }
    }

    return parameters;
  }

  /**
   * Load command registry
   */
  loadCommandRegistry() {
    // Register common commands
    this.registerCommand('create-asset', {
      patterns: [
        'create asset',
        'make asset',
        'generate asset',
        'new asset'
      ],
      extractParams: (transcript, entities) => ({
        assetType: this.extractAssetType(transcript)
      })
    });

    this.registerCommand('open-dashboard', {
      patterns: [
        'open dashboard',
        'show dashboard',
        'display dashboard'
      ]
    });

    this.registerCommand('start-stream', {
      patterns: [
        'start stream',
        'begin streaming',
        'go live'
      ]
    });

    this.registerCommand('save-work', {
      patterns: [
        'save',
        'save work',
        'save progress'
      ]
    });

    console.log('  📝 Loaded command registry');
  }

  /**
   * Extract asset type from transcript
   */
  extractAssetType(transcript) {
    const lower = transcript.toLowerCase();
    
    if (lower.includes('music')) return 'music';
    if (lower.includes('video')) return 'video';
    if (lower.includes('image')) return 'image';
    if (lower.includes('3d') || lower.includes('model')) return '3d-model';
    
    return 'generic';
  }

  /**
   * Register command
   */
  registerCommand(name, commandData) {
    this.commandRegistry.set(name, commandData);
    console.log(`  🎙️  Registered command: ${name}`);
  }

  /**
   * Start listening (for continuous mode)
   */
  startListening() {
    this.activeListening = true;
    console.log('🎤 Started listening...');
  }

  /**
   * Stop listening
   */
  stopListening() {
    this.activeListening = false;
    console.log('🔇 Stopped listening');
  }

  /**
   * Get statistics
   */
  getStatistics() {
    return {
      registeredCommands: this.commandRegistry.size,
      listening: this.activeListening,
      language: this.config.language,
      nluEnabled: this.config.enableNLU
    };
  }
}

module.exports = VoiceInputHandler;
