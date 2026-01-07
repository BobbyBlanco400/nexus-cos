# N3XUS COS Stack-Wide Architecture Implementation Guide

**Version:** 1.1.0  
**Status:** Canonical  
**Handshake:** 55-45-17  
**Date:** January 2026

---

## 📋 Overview

This guide provides step-by-step instructions for implementing the N3XUS COS stack-wide multi-layer architecture in any module. All 38 modules must follow this canonical template to ensure consistency, integration, and creator fluency across the platform.

**Prerequisites:**
- Read [STACK_ARCHITECTURE_INDEX.md](./STACK_ARCHITECTURE_INDEX.md)
- Review [spec/stack/module_template.md](./spec/stack/module_template.md)
- Understand [spec/stack/architecture_overview.md](./spec/stack/architecture_overview.md)

---

## 🎯 Module Implementation Checklist

Use this checklist when implementing or upgrading a module to follow the stack-wide architecture:

### Foundation
- [ ] Module directory created in `/modules/{module-name}/`
- [ ] README.md with module description and architecture adherence statement
- [ ] package.json with standard dependencies (if applicable)
- [ ] Feature flags configured for Hybrid and Immersive modes
- [ ] Handshake protocol (55-45-17) enforcement in all API endpoints

### Layer 1: IMVU Observation
- [ ] `IMVUObserver` class or equivalent behavioral capture system
- [ ] Behavioral atom capture on all user interactions
- [ ] Seed library storage (local or shared Canon)
- [ ] Integration with Canon Memory Layer for persistence
- [ ] Pattern recognition and seed generation pipeline

### Layer 2: IMCU Creation
- [ ] `IMCUCreator` class or equivalent content generation system
- [ ] Seed selection and composition logic
- [ ] MetaTwin integration for predictive scaffolding
- [ ] Canon validation before IMCU persistence
- [ ] Overlay Constellation connection for emotional/behavioral mapping

### Layer 3: IMCU-L Assembly
- [ ] `IMCULAssembler` class or equivalent long-form assembly system
- [ ] Timeline management for multiple IMCUs
- [ ] Storyboard visualization (if applicable)
- [ ] Narrative coherence validation via MetaTwin
- [ ] Live event preparation capabilities

### Cross-Cutting: MetaTwin / HoloCore Integration
- [ ] API client for MetaTwin predictions
- [ ] Real-time feedback loop for suggestions
- [ ] Module-specific prediction models (if needed)
- [ ] Learning from user acceptance/rejection of suggestions

### Cross-Cutting: Overlay Constellation Integration
- [ ] Emotional/behavioral context analysis
- [ ] 2D visualization for Hybrid mode
- [ ] 3D visualization for Immersive mode (if applicable)
- [ ] Cross-module correlation support

### Cross-Cutting: Live Event Feedback Loop
- [ ] Real-time canon validation
- [ ] Live seed generation from events
- [ ] Audience interaction support (if applicable)
- [ ] Event recording and archival

### Layer 4: Distribution & Export
- [ ] `DistributionManager` class or equivalent
- [ ] Internal registry registration
- [ ] OTT format preparation (HLS/DASH)
- [ ] Live broadcasting support (if applicable)
- [ ] Canonical metadata locking

### Access Layer
- [ ] Hybrid mode implementation (desktop/browser)
- [ ] Immersive mode implementation (VR - if applicable)
- [ ] Mode switching support
- [ ] Authentication and authorization
- [ ] Module selection integration

### Documentation
- [ ] Module-specific documentation
- [ ] API documentation
- [ ] Creator guide for module usage
- [ ] Developer guide for module extension
- [ ] Architecture compliance statement

---

## 🏗️ Step-by-Step Implementation

### Step 1: Create Module Structure

```bash
# Create module directory
mkdir -p modules/{module-name}
cd modules/{module-name}

# Create standard subdirectories
mkdir -p src/{imvu,imcu,imcu-l,distribution}
mkdir -p src/{services,components,utils}
mkdir -p docs
mkdir -p tests

# Initialize package.json (if applicable)
npm init -y
```

### Step 2: Implement IMVU Observation Layer

Create `src/imvu/IMVUObserver.ts`:

```typescript
import { BehavioralAtom, Seed } from '@nexus/types';
import { canonLayer } from '@nexus/canon';
import { metaTwin } from '@nexus/metatwin';
import { overlayConstellation } from '@nexus/overlay';

/**
 * IMVU Observer - Captures behavioral atoms and manages seed library
 * 
 * This class implements Layer 1 of the canonical module flow.
 * All user interactions within the module should be captured here.
 */
export class IMVUObserver {
  private moduleId: string;
  private seedLibrary: Map<string, Seed>;

  constructor(moduleId: string) {
    this.moduleId = moduleId;
    this.seedLibrary = new Map();
  }

  /**
   * Capture a behavioral atom from user interaction
   */
  async captureBehavior(
    action: string,
    context: {
      userId: string;
      location: string;
      sessionId: string;
      device: string;
      mode: 'hybrid' | 'immersive';
    }
  ): Promise<BehavioralAtom> {
    // Create behavioral atom
    const atom: BehavioralAtom = {
      atom_id: this.generateId('atom'),
      module_id: this.moduleId,
      actor_id: context.userId,
      action,
      context: {
        location: context.location,
        timestamp: new Date(),
        session_id: context.sessionId,
        device: context.device,
        mode: context.mode
      },
      intent: await this.inferIntent(action, context),
      outcome: {
        success: true,
        state_changes: [],
        generated_content: null
      },
      metadata: {
        duration_ms: 0,
        interactions: 1,
        tags: this.generateTags(action)
      },
      handshake: '55-45-17'
    };

    // Persist to Canon Memory Layer
    await canonLayer.recordAtom(atom);

    // Notify MetaTwin for pattern learning
    await metaTwin.processBehavior(atom);

    // Update overlay constellation
    await overlayConstellation.updateEmotionalMap({
      atom_id: atom.atom_id,
      emotion: this.inferEmotion(action),
      intensity: 0.8
    });

    return atom;
  }

  /**
   * Generate seed from behavioral pattern
   */
  async generateSeed(atoms: BehavioralAtom[]): Promise<Seed> {
    // Analyze pattern
    const pattern = await metaTwin.analyzePattern(atoms);

    // Create seed
    const seed: Seed = {
      seed_id: this.generateId('seed'),
      module_id: this.moduleId,
      name: pattern.name,
      description: pattern.description,
      atoms: atoms.map(a => a.atom_id),
      pattern: {
        sequence: pattern.sequence,
        conditions: pattern.conditions,
        expected_outcome: pattern.expectedOutcome
      },
      usage: {
        created_count: 0,
        remixed_count: 0,
        success_rate: 0
      },
      lineage: {
        parent_seeds: [],
        derived_seeds: [],
        version: 1
      },
      metadata: {
        created_at: new Date(),
        creator_id: atoms[0].actor_id,
        tags: pattern.tags,
        visibility: 'module'
      },
      handshake: '55-45-17'
    };

    // Store in seed library
    this.seedLibrary.set(seed.seed_id, seed);

    // Persist to Canon
    await canonLayer.createSeed(seed);

    return seed;
  }

  /**
   * Search seed library
   */
  async searchSeeds(
    query: string,
    filters: {
      tags?: string[];
      min_success_rate?: number;
    }
  ): Promise<Seed[]> {
    // Search in Canon Memory Layer
    const results = await canonLayer.searchSeeds({
      module_id: this.moduleId,
      query,
      tags: filters.tags,
      min_success_rate: filters.min_success_rate || 0.7
    });

    return results;
  }

  // Helper methods
  private generateId(prefix: string): string {
    return `${prefix}-${Date.now()}-${Math.random().toString(36).substring(2, 11)}`;
  }

  private async inferIntent(action: string, context: any) {
    // Use MetaTwin to infer intent
    const inference = await metaTwin.inferIntent(action, context);
    return {
      inferred: inference.intents,
      confidence: inference.confidence
    };
  }

  private inferEmotion(action: string): string {
    // Simple emotion inference - enhance with MetaTwin
    const emotionMap: Record<string, string> = {
      'create': 'excited',
      'edit': 'focused',
      'delete': 'decisive',
      'view': 'curious'
    };
    return emotionMap[action] || 'neutral';
  }

  private generateTags(action: string): string[] {
    return [action, this.moduleId, 'behavioral-atom'];
  }
}
```

### Step 3: Implement IMCU Creation Layer

Create `src/imcu/IMCUCreator.ts`:

```typescript
import { IMCU, Seed } from '@nexus/types';
import { IMVUObserver } from '../imvu/IMVUObserver';
import { canonLayer } from '@nexus/canon';
import { metaTwin } from '@nexus/metatwin';
import { overlayConstellation } from '@nexus/overlay';

/**
 * IMCU Creator - Transforms seeds into short-form canon units
 * 
 * This class implements Layer 2 of the canonical module flow.
 */
export class IMCUCreator {
  private moduleId: string;
  private observer: IMVUObserver;

  constructor(moduleId: string) {
    this.moduleId = moduleId;
    this.observer = new IMVUObserver(moduleId);
  }

  /**
   * Create IMCU from seeds
   */
  async createIMCU(
    seedIds: string[],
    metadata: {
      title: string;
      description: string;
      creator_id: string;
    }
  ): Promise<IMCU> {
    // Fetch seeds
    const seeds = await Promise.all(
      seedIds.map(id => canonLayer.getSeed(id))
    );

    // Request MetaTwin predictions
    const predictions = await metaTwin.predictIMCU(seeds, this.moduleId);

    // Compose content using module-specific logic
    const content = await this.composeContent(seeds, predictions);

    // Create IMCU
    const imcu: IMCU = {
      imcu_id: this.generateId('imcu'),
      module_id: this.moduleId,
      seeds: seedIds,
      content: {
        type: this.getContentType(),
        data: content,
        duration_ms: content.duration,
        metadata: {
          title: metadata.title,
          description: metadata.description
        }
      },
      scaffold: {
        metatwin_predictions: predictions,
        applied_suggestions: predictions.suggestions.filter(s => s.applied),
        confidence: predictions.confidence
      },
      overlay_refs: [],
      validation: {
        canon_compliant: true,
        issues: [],
        score: 1.0
      },
      usage: {
        views: 0,
        remixes: 0,
        rating: 0
      },
      lineage: {
        parent_imcus: [],
        seed_lineage: seeds.map(s => ({
          seed_id: s.seed_id,
          version: s.lineage.version
        })),
        version: 1
      },
      created_at: new Date(),
      creator_id: metadata.creator_id,
      handshake: '55-45-17'
    };

    // Validate against canon
    const validation = await canonLayer.validateIMCU(imcu);
    if (!validation.canon_compliant) {
      throw new Error(`Canon validation failed: ${validation.issues.join(', ')}`);
    }

    // Connect to overlay constellation
    const overlays = await overlayConstellation.connectIMCU(imcu);
    imcu.overlay_refs = overlays.map(o => o.overlay_id);

    // Persist to Canon
    await canonLayer.createIMCU(imcu);

    return imcu;
  }

  /**
   * Module-specific content composition
   * Override this in module implementations
   */
  protected async composeContent(seeds: Seed[], predictions: any): Promise<any> {
    // Default implementation - modules should override
    return {
      duration: 0,
      data: seeds.map(s => s.pattern),
      predictions: predictions
    };
  }

  /**
   * Get module-specific content type
   * Override this in module implementations
   */
  protected getContentType(): string {
    return 'generic';
  }

  private generateId(prefix: string): string {
    return `${prefix}-${Date.now()}-${Math.random().toString(36).substring(2, 11)}`;
  }
}
```

### Step 4: Implement IMCU-L Assembly Layer

Create `src/imcu-l/IMCULAssembler.ts`:

```typescript
import { IMCUL, IMCU, Timeline } from '@nexus/types';
import { canonLayer } from '@nexus/canon';
import { metaTwin } from '@nexus/metatwin';
import { liveEventFeedback } from '@nexus/live-events';

/**
 * IMCU-L Assembler - Assembles IMCUs into long-form content
 * 
 * This class implements Layer 3 of the canonical module flow.
 */
export class IMCULAssembler {
  private moduleId: string;
  private timeline: Timeline;

  constructor(moduleId: string) {
    this.moduleId = moduleId;
    this.timeline = {
      tracks: [],
      markers: [],
      total_duration_ms: 0
    };
  }

  /**
   * Assemble IMCU-L from multiple IMCUs
   */
  async assembleIMCUL(
    imcuIds: string[],
    config: {
      title: string;
      description: string;
      type: 'film' | 'series' | 'live_event' | 'interactive';
      creator_id: string;
    }
  ): Promise<IMCUL> {
    // Fetch IMCUs
    const imcus = await Promise.all(
      imcuIds.map(id => canonLayer.getIMCU(id))
    );

    // Arrange on timeline
    this.arrangeIMCUsOnTimeline(imcus);

    // Request MetaTwin narrative validation
    const validation = await metaTwin.validateNarrative(this.timeline);
    
    if (!validation.coherent) {
      throw new Error(`Narrative coherence validation failed: ${validation.issues.join(', ')}`);
    }

    // Create IMCU-L
    const imcuL: IMCUL = {
      imcu_l_id: this.generateId('imcu-l'),
      module_id: this.moduleId,
      title: config.title,
      description: config.description,
      imcus: imcuIds,
      timeline: this.timeline,
      type: config.type,
      validation: {
        narrative_coherent: validation.coherent,
        canon_compliant: true,
        technical_ready: true,
        issues: []
      },
      metadata: {
        duration_ms: this.timeline.total_duration_ms,
        created_at: new Date(),
        creator_id: config.creator_id,
        collaborators: []
      },
      handshake: '55-45-17'
    };

    // Validate technical requirements
    await this.validateTechnicalRequirements(imcuL);

    // Persist to Canon
    await canonLayer.createIMCUL(imcuL);

    return imcuL;
  }

  /**
   * Prepare for live event
   */
  async prepareLiveEvent(imcuLId: string) {
    const imcuL = await canonLayer.getIMCUL(imcuLId);

    // Initialize live event module
    const liveEvent = await liveEventFeedback.initialize({
      imcu_l_id: imcuL.imcu_l_id,
      timeline: imcuL.timeline,
      validation_rules: imcuL.validation
    });

    // Enable real-time canon validation
    await liveEvent.enableRealtimeValidation();

    return liveEvent;
  }

  private arrangeIMCUsOnTimeline(imcus: IMCU[]) {
    let currentTime = 0;
    
    for (const imcu of imcus) {
      this.timeline.tracks.push({
        track_id: this.generateId('track'),
        imcu_id: imcu.imcu_id,
        start_time_ms: currentTime,
        duration_ms: imcu.content.duration_ms || 0
      });
      
      currentTime += imcu.content.duration_ms || 0;
    }

    this.timeline.total_duration_ms = currentTime;
  }

  private async validateTechnicalRequirements(imcuL: IMCUL): Promise<void> {
    // Check timeline validity
    if (this.timeline.total_duration_ms === 0) {
      throw new Error('Timeline has zero duration');
    }

    // Check all IMCUs are valid
    for (const imcuId of imcuL.imcus) {
      const imcu = await canonLayer.getIMCU(imcuId);
      if (!imcu) {
        throw new Error(`IMCU not found: ${imcuId}`);
      }
    }
  }

  private generateId(prefix: string): string {
    return `${prefix}-${Date.now()}-${Math.random().toString(36).substring(2, 11)}`;
  }
}
```

### Step 5: Implement Distribution & Export Layer

Create `src/distribution/DistributionManager.ts`:

```typescript
import { IMCU, IMCUL } from '@nexus/types';
import { canonLayer } from '@nexus/canon';

/**
 * Distribution Manager - Handles content distribution and export
 * 
 * This class implements Layer 4 of the canonical module flow.
 */
export class DistributionManager {
  private moduleId: string;

  constructor(moduleId: string) {
    this.moduleId = moduleId;
  }

  /**
   * Distribute content across channels
   */
  async distribute(
    contentId: string,
    contentType: 'imcu' | 'imcu_l',
    channels: Array<{
      type: 'ott' | 'live' | 'download' | 'registry';
      config: any;
    }>
  ) {
    // Fetch content
    const content = contentType === 'imcu'
      ? await canonLayer.getIMCU(contentId)
      : await canonLayer.getIMCUL(contentId);

    // Register in internal registry
    await this.registerInRegistry(content);

    // Prepare for each channel
    const distributions = await Promise.all(
      channels.map(async (channel) => {
        switch (channel.type) {
          case 'ott':
            return await this.prepareOTT(content, channel.config);
          case 'live':
            return await this.prepareLive(content, channel.config);
          case 'download':
            return await this.prepareDownload(content, channel.config);
          default:
            throw new Error(`Unknown channel type: ${channel.type}`);
        }
      })
    );

    // Lock canonical metadata
    await this.lockMetadata(content);

    return {
      content_id: contentId,
      distributions,
      status: 'distributed'
    };
  }

  private async registerInRegistry(content: any) {
    await canonLayer.registerContent({
      content_id: content.imcu_id || content.imcu_l_id,
      type: content.imcu_id ? 'imcu' : 'imcu_l',
      module_id: this.moduleId,
      metadata: content.metadata || content.content?.metadata,
      status: 'published',
      handshake: '55-45-17'
    });
  }

  private async prepareOTT(content: any, config: any) {
    // Transcode to HLS/DASH
    // Generate adaptive bitrates
    // Add DRM protection
    // Return streaming URLs
    return {
      format: 'hls',
      url: `https://cdn.n3xuscos.online/stream/${content.imcu_id || content.imcu_l_id}/playlist.m3u8`,
      bitrates: ['360p', '720p', '1080p'],
      drm: 'widevine'
    };
  }

  private async prepareLive(content: any, config: any) {
    // Set up RTMP streaming
    // Configure CDN edge delivery
    // Return stream URL
    return {
      stream_url: `rtmps://live.n3xuscos.online/stream/${content.imcu_id || content.imcu_l_id}`,
      stream_key: this.generateStreamKey(),
      status: 'ready'
    };
  }

  private async prepareDownload(content: any, config: any) {
    // Generate downloadable formats
    return {
      formats: ['mp4', 'webm', 'mp3'],
      urls: {
        mp4: `https://downloads.n3xuscos.online/${content.imcu_id || content.imcu_l_id}.mp4`,
        webm: `https://downloads.n3xuscos.online/${content.imcu_id || content.imcu_l_id}.webm`,
        mp3: `https://downloads.n3xuscos.online/${content.imcu_id || content.imcu_l_id}.mp3`
      }
    };
  }

  private async lockMetadata(content: any) {
    await canonLayer.lockContentMetadata({
      content_id: content.imcu_id || content.imcu_l_id,
      locked: true,
      locked_at: new Date()
    });
  }

  private generateStreamKey(): string {
    return `sk-${Date.now()}-${Math.random().toString(36).substring(2, 18)}`;
  }
}
```

### Step 6: Configure Feature Flags

Create `feature-flags.json`:

```json
{
  "module.{module-name}.hybrid": {
    "flag_id": "module.{module-name}.hybrid",
    "module_id": "{module-name}",
    "name": "{Module Name} - Hybrid Mode",
    "description": "Desktop/browser access to {module-name}",
    "status": "alpha",
    "enabled_modes": ["hybrid"],
    "rollout_percentage": 10,
    "targeting_rules": [
      {
        "type": "internal_team",
        "value": true
      }
    ],
    "dependencies": [],
    "handshake": "55-45-17"
  },
  "module.{module-name}.immersive": {
    "flag_id": "module.{module-name}.immersive",
    "module_id": "{module-name}",
    "name": "{Module Name} - Immersive Mode",
    "description": "N3XUSVISION headset access to {module-name}",
    "status": "planned",
    "enabled_modes": ["immersive"],
    "rollout_percentage": 0,
    "targeting_rules": [],
    "dependencies": ["module.{module-name}.hybrid"],
    "handshake": "55-45-17"
  }
}
```

### Step 7: Create Module Documentation

Create `README.md`:

```markdown
# {Module Name}

**Module ID:** `{module-name}`  
**Status:** {alpha | beta | stable}  
**Handshake:** 55-45-17

## Overview

{Brief description of what this module does}

## Stack Architecture Compliance

This module follows the N3XUS COS canonical stack-wide architecture:

✅ **Layer 1: IMVU Observation** - Behavioral atom capture implemented  
✅ **Layer 2: IMCU Creation** - Short-form canon unit generation implemented  
✅ **Layer 3: IMCU-L Assembly** - Long-form assembly implemented  
✅ **Layer 4: Distribution & Export** - Multi-channel distribution implemented  
✅ **Cross-Cutting: MetaTwin/HoloCore** - Predictive scaffolding integrated  
✅ **Cross-Cutting: Overlay Constellation** - Emotional/behavioral mapping integrated  
✅ **Cross-Cutting: Live Event Feedback Loop** - Real-time validation supported  

## Access Modes

- **Hybrid Mode:** ✅ Fully supported (desktop/browser)
- **Immersive Mode:** {✅ Supported | 🔄 Planned | ❌ Not applicable}

## Quick Start

\`\`\`typescript
import { {ModuleName} } from './{module-name}';

// Initialize module
const module = new {ModuleName}();

// Capture behavioral atom
await module.observer.captureBehavior('action-name', context);

// Create IMCU from seeds
const imcu = await module.creator.createIMCU(seedIds, metadata);

// Assemble IMCU-L
const imcuL = await module.assembler.assembleIMCUL(imcuIds, config);

// Distribute content
await module.distributor.distribute(imcuL.imcu_l_id, 'imcu_l', channels);
\`\`\`

## Architecture References

- [Stack Architecture Index](../../STACK_ARCHITECTURE_INDEX.md)
- [Module Template](../../spec/stack/module_template.md)
- [Architecture Overview](../../spec/stack/architecture_overview.md)
```

---

## 🔍 Validation

After implementing all layers, validate your module:

### Checklist Validation

Run through the module implementation checklist at the top of this document.

### Integration Testing

Test integration with:
- Canon Memory Layer
- MetaTwin / HoloCore
- Overlay Constellation
- Live Event Feedback Loop
- Distribution channels

### Feature Flag Testing

Test both:
- Flag enabled (module accessible)
- Flag disabled (module gracefully unavailable)

### Mode Testing

Test both access modes:
- Hybrid mode (desktop/browser)
- Immersive mode (if applicable)

---

## 📚 Additional Resources

### Required Reading
- [STACK_ARCHITECTURE_INDEX.md](./STACK_ARCHITECTURE_INDEX.md)
- [spec/stack/module_template.md](./spec/stack/module_template.md)
- [spec/stack/architecture_overview.md](./spec/stack/architecture_overview.md)

### Layer-Specific Documentation
- [IMVU Observation](./spec/stack/imvu_observation.md)
- [IMCU Creation](./spec/stack/imcu_creation.md)
- [IMCU-L Assembly](./spec/stack/imcu_l_assembly.md)
- [MetaTwin / HoloCore](./spec/stack/metatwin_holocore.md)
- [Overlay Constellation](./spec/stack/overlay_constellation.md)
- [Live Event Feedback Loop](./spec/stack/live_event_feedback_loop.md)
- [Distribution & Export](./spec/stack/distribution_and_export.md)

### Deployment
- [Feature Flags & Rollout](./spec/stack/feature_flags_and_rollout.md)
- [Access Layer](./spec/stack/access_layer.md)

---

## 🆘 Support

### Questions?
- Review [STACK_ARCHITECTURE_INDEX.md](./STACK_ARCHITECTURE_INDEX.md)
- Check [Module Template](./spec/stack/module_template.md)
- See existing module implementations in `/modules/`

### Issues?
- Create issue with `[stack-implementation]` tag
- Include module name and layer
- Reference this guide

---

**Maintained By:** N3XUS Architecture Team  
**Last Updated:** January 2026  
**Status:** Canonical Implementation Guide

---

*"Follow the template. Build with confidence."*
