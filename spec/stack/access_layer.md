# N3XUS COS Access Layer

**Version:** 1.1.0  
**Status:** Canonical  
**Handshake:** 55-45-17  
**Date:** January 2026

---

## Overview

The Access Layer defines how creators and users enter N3XUS COS and navigate between modules. It provides two primary access modes—**Hybrid** (desktop/browser) and **Immersive** (N3XUSVISION headset)—with seamless mode switching and consistent authentication across all 38 modules.

---

## Access Modes

### Hybrid Mode

**Description:** Desktop/browser-based access providing full 2D/hybrid functionality across all modules.

**Characteristics:**
- Zero installation required
- Browser-native operation
- Cross-platform compatibility (Windows, macOS, Linux)
- Touch and keyboard/mouse input
- Responsive design (desktop to tablet)
- Progressive Web App (PWA) support

**Use Cases:**
- Day-to-day creative work
- Quick access from any device
- Multi-window workflows
- Traditional desktop productivity
- Mobile access via tablet/phone

**Technical Requirements:**
- Modern browser (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)
- Stable internet connection (min 10 Mbps)
- 4GB RAM minimum, 8GB recommended
- WebGL 2.0 support
- WebSocket support

### Immersive Mode

**Description:** N3XUSVISION headset access providing full presence, 3D overlays, and spatial interactions.

**Characteristics:**
- Full VR presence and spatial audio
- 3D visualization of overlays and constellations
- Hand tracking and gesture controls
- Room-scale or seated experiences
- Collaborative spatial workspaces
- Mixed reality passthrough support

**Use Cases:**
- Immersive creative sessions
- Spatial content review
- VR collaboration
- Live event participation
- Casino-Nexus VR worlds
- 3D overlay visualization

**Technical Requirements:**
- N3XUSVISION headset or compatible VR device
- High-bandwidth connection (min 50 Mbps)
- Dedicated GPU (NVIDIA RTX 3060 or equivalent)
- VR-ready PC or standalone device
- 6DOF tracking support

---

## Access Flow

### Entry Point

```
[Landing Page: n3xuscos.online]
        │
        ▼
[Authentication: Single Sign-On]
        │
        ▼
[Mode Selection: Hybrid / Immersive]
        │
        ▼
[Module Selection: 38 Modules Available]
        │
        ▼
[Module Entry: IMVU Observation / Live Interaction]
```

### Authentication

**Single Sign-On (SSO):**
- One account across all modules
- OAuth 2.0 / OpenID Connect
- Multi-factor authentication (MFA) optional
- Biometric authentication (fingerprint, face ID)
- Social login options (Google, GitHub, Apple)

**Session Management:**
- Persistent sessions across modules
- Cross-device session sync
- Automatic session refresh
- Secure token storage
- Session timeout: 24 hours default (configurable)

**Security:**
- TLS 1.3 encryption
- Handshake header verification (55-45-17)
- Rate limiting and DDoS protection
- Anomaly detection and alerting
- Audit logging of all access

---

## Mode Selection

### Hybrid Mode Selection

**Selection Screen:**
```
┌─────────────────────────────────────────┐
│   Welcome to N3XUS COS                 │
│                                         │
│   Select Access Mode:                  │
│                                         │
│   [🖥️  Hybrid Mode]                    │
│   Desktop / Browser Experience          │
│   Full functionality in 2D/hybrid       │
│                                         │
│   [🥽  Immersive Mode]                 │
│   N3XUSVISION Headset Required          │
│   Full presence with 3D overlays        │
│                                         │
│   [⚙️  Settings] [📚 Help] [👤 Profile] │
└─────────────────────────────────────────┘
```

**Selection Logic:**
```javascript
async function selectMode(userId, mode) {
  // Validate mode selection
  if (mode === 'immersive' && !await isVRAvailable()) {
    throw new Error('VR device not detected. Please use Hybrid mode or connect your N3XUSVISION headset.');
  }
  
  // Store user preference
  await userPreferences.set(userId, { accessMode: mode });
  
  // Initialize appropriate renderer
  const renderer = mode === 'immersive' 
    ? await initVRRenderer() 
    : await initHybridRenderer();
  
  // Proceed to module selection
  return { mode, renderer, status: 'ready' };
}
```

---

## Module Selection

### Module Dashboard

**Hybrid Mode Dashboard:**
```
┌───────────────────────────────────────────────────────┐
│  N3XUS COS - Module Dashboard                         │
│  Creator: @username            Mode: Hybrid 🖥️         │
├───────────────────────────────────────────────────────┤
│                                                       │
│  🎨 Creative Production                               │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐                │
│  │ Hub  │ │Screen│ │Caster│ │Stage │ ...             │
│  └──────┘ └──────┘ └──────┘ └──────┘                │
│                                                       │
│  📦 Content Management                                │
│  ┌──────┐ ┌──────┐ ┌──────┐                         │
│  │Assets│ │Chain │ │Collab│ ...                      │
│  └──────┘ └──────┘ └──────┘                         │
│                                                       │
│  🚀 PUABO Universe                                    │
│  ┌──────┐ ┌──────┐ ┌──────┐                         │
│  │Nexus │ │ DSP  │ │NUKI  │ ...                      │
│  └──────┘ └──────┘ └──────┘                         │
│                                                       │
│  🎰 Casino & Entertainment                            │
│  ┌──────┐ ┌──────┐ ┌──────┐                         │
│  │Casino│ │Wallet│ │ NFT  │ ...                      │
│  └──────┘ └──────┘ └──────┘                         │
│                                                       │
│  ⚙️  Platform Core | 🌐 Community & Social           │
│                                                       │
│  [🔍 Search] [⭐ Favorites] [📊 Analytics] [⚙️ Settings]│
└───────────────────────────────────────────────────────┘
```

**Immersive Mode Dashboard:**
- Spatial module constellation floating in 3D space
- Hand gestures to navigate between module categories
- Voice commands for quick module access
- Haptic feedback for module selection
- Ambient spatial audio per module category

### Module Access Control

**Feature Flags:**
```javascript
// Per-module feature flag configuration
const moduleFlags = {
  'creators-hub': { hybrid: true, immersive: true, status: 'stable' },
  'v-screen-hollywood': { hybrid: true, immersive: true, status: 'stable' },
  'casino-nexus': { hybrid: true, immersive: true, status: 'beta' },
  'puabo-ott-tv': { hybrid: true, immersive: false, status: 'alpha' },
  // ... all 38 modules
};

async function canAccessModule(userId, moduleId, mode) {
  const module = moduleFlags[moduleId];
  
  if (!module) {
    return { access: false, reason: 'Module not found' };
  }
  
  if (!module[mode]) {
    return { access: false, reason: `Module not available in ${mode} mode` };
  }
  
  if (module.status === 'alpha' && !await isAlphaTester(userId)) {
    return { access: false, reason: 'Alpha access required' };
  }
  
  return { access: true, module };
}
```

---

## Module Entry

### IMVU Seed Observation

Upon module entry, creators can:

1. **Observe Existing Seeds:**
   - Browse behavioral atom library
   - Review resident interactions
   - Explore seed relationships
   - Analyze seed patterns

2. **Live Interaction:**
   - Interact with active IMVUs
   - Capture new behavioral atoms
   - Generate emergent behaviors
   - Feed MetaTwin predictions

3. **Create New Content:**
   - Launch IMCU creation workflow
   - Start IMCU-L assembly
   - Initiate live events
   - Access distribution tools

### Context Preservation

**Cross-Module Navigation:**
```javascript
class ModuleNavigator {
  async switchModule(fromModule, toModule, context) {
    // Save current module context
    await this.saveContext(fromModule, {
      scroll_position: context.scrollPos,
      active_items: context.activeItems,
      unsaved_changes: context.unsavedChanges,
      timestamp: Date.now()
    });
    
    // Load target module
    await this.loadModule(toModule);
    
    // Restore context if available
    const savedContext = await this.getContext(toModule);
    if (savedContext) {
      await this.restoreContext(toModule, savedContext);
    }
    
    // Track navigation
    await analytics.trackNavigation(fromModule, toModule);
  }
}
```

---

## Mode Switching

### Hybrid ↔ Immersive Switching

**Seamless Transition:**
```javascript
async function switchAccessMode(currentMode, targetMode, moduleId) {
  // Save current state
  const state = await captureModuleState(moduleId);
  
  // Validate target mode availability
  if (targetMode === 'immersive' && !await isVRAvailable()) {
    throw new Error('VR device required for immersive mode');
  }
  
  // Transition renderer
  await transitionRenderer(currentMode, targetMode);
  
  // Restore state in new mode
  await restoreModuleState(moduleId, state, targetMode);
  
  // Update user preference
  await updateAccessModePreference(targetMode);
  
  return { previousMode: currentMode, currentMode: targetMode, status: 'transitioned' };
}
```

**State Preservation:**
- Active documents/projects remain open
- Tool configurations maintained
- Collaboration sessions continue
- Playback positions preserved
- UI preferences adapted to mode

---

## Performance Optimization

### Hybrid Mode
- Lazy loading of modules
- Code splitting per module
- Service Worker caching
- Progressive image loading
- Debounced API calls

### Immersive Mode
- Foveated rendering
- Level-of-detail (LOD) optimization
- Occlusion culling
- Predictive asset loading
- Frame rate prioritization (90 FPS target)

---

## Accessibility

### Hybrid Mode
- Full keyboard navigation
- Screen reader support (WCAG 2.1 AA)
- High contrast themes
- Font scaling
- Reduced motion options

### Immersive Mode
- Seated experience option
- Comfort settings (vignette, snap turning)
- Adjustable UI scale
- Voice commands
- Haptic alternatives to audio cues

---

## References

- [Architecture Overview](./architecture_overview.md) - Stack-wide blueprint
- [Module Template](./module_template.md) - Canonical module flow
- [Feature Flags & Rollout](./feature_flags_and_rollout.md) - Deployment strategy
- [v-COS Ontology](../vcos/ontology.md) - Entity model
- [Creator Interaction Model](../vcos/creator_interaction_model.md) - Interaction patterns

---

**Maintained By:** N3XUS Platform Team  
**Last Updated:** January 2026  
**Status:** Canonical Reference

---

*"Two modes, infinite access."*
