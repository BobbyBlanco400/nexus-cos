# N3XUS COS IMCU Creation Layer

**Version:** 1.1.0  
**Status:** Canonical  
**Handshake:** 55-45-17  
**Date:** January 2026

---

## Overview

The IMCU (Interactive Multi-Component Unit) Creation Layer transforms behavioral seeds into structured, short-form canon units. This layer bridges raw behavioral data and finished content, applying module-specific logic, MetaTwin predictions, and overlay mappings to generate cohesive, reusable content units.

---

## Purpose

1. Transform seeds into structured canon units
2. Apply MetaTwin predictive scaffolding
3. Validate canon consistency
4. Connect to overlay constellation
5. Enable content reuse and remixing

---

## IMCU Structure

```javascript
interface IMCU {
  imcu_id: string;
  module_id: string;
  seeds: string[];  // seed_ids used
  content: {
    type: string;  // video, audio, interactive, etc.
    data: any;     // module-specific content
    duration_ms?: number;
    metadata: ContentMetadata;
  };
  scaffold: {
    metatwin_predictions: Prediction[];
    applied_suggestions: string[];
    confidence: number;
  };
  overlay_refs: string[];  // overlay_ids
  validation: {
    canon_compliant: boolean;
    issues: Issue[];
    score: number;
  };
  usage: {
    views: number;
    remixes: number;
    rating: number;
  };
  lineage: {
    parent_imcus: string[];
    seed_lineage: SeedLineage[];
    version: number;
  };
  created_at: Date;
  creator_id: string;
  handshake: '55-45-17';
}
```

---

## Creation Process

### Step 1: Seed Selection

```javascript
class IMCUCreator {
  async selectSeeds(intent, context) {
    // Search seed library
    const candidates = await seedLibrary.search(intent.query, {
      tags: intent.tags,
      min_success_rate: 0.7
    });
    
    // Get MetaTwin recommendations
    const recommendations = await metaTwin.recommendSeeds(intent, context);
    
    // Merge and rank
    return this.mergeAndRank(candidates, recommendations);
  }
}
```

### Step 2: MetaTwin Scaffolding

```javascript
async function applyMetaTwinScaffolding(seeds, moduleId) {
  // Request predictions
  const predictions = await metaTwin.predictIMCU(seeds, moduleId);
  
  return {
    structure: predictions.suggested_structure,
    transitions: predictions.recommended_transitions,
    enhancements: predictions.content_enhancements,
    confidence: predictions.confidence
  };
}
```

### Step 3: Content Composition

```javascript
async function composeContent(seeds, scaffold, moduleContext) {
  // Apply module-specific composition logic
  const composer = getModuleComposer(moduleContext.module_id);
  
  // Compose using seeds and scaffold
  const content = await composer.compose({
    seeds,
    structure: scaffold.structure,
    transitions: scaffold.transitions,
    context: moduleContext
  });
  
  // Validate composition
  await validateComposition(content);
  
  return content;
}
```

### Step 4: Overlay Connection

```javascript
async function connectOverlays(imcu) {
  // Analyze emotional/behavioral context
  const context = await overlayConstellation.analyzeIMCU(imcu);
  
  // Find or create relevant overlays
  const overlays = await overlayConstellation.connectOrCreate(context);
  
  // Link IMCU to overlays
  imcu.overlay_refs = overlays.map(o => o.overlay_id);
  
  return overlays;
}
```

### Step 5: Canon Validation

```javascript
async function validateCanon(imcu) {
  // Check canon consistency
  const validation = await canonValidator.validate(imcu);
  
  if (!validation.canon_compliant) {
    // Attempt automatic fixes
    const fixed = await canonValidator.attemptFix(imcu, validation.issues);
    
    if (!fixed.canon_compliant) {
      throw new CanonValidationError(fixed.issues);
    }
    
    return fixed;
  }
  
  return validation;
}
```

---

## References

- [Module Template](./module_template.md)
- [IMVU Observation](./imvu_observation.md)
- [MetaTwin / HoloCore](./metatwin_holocore.md)
- [Canon Memory Layer](../vcos/canon_memory_layer.md)

---

**Maintained By:** N3XUS Architecture Team  
**Last Updated:** January 2026  
**Status:** Canonical Reference
