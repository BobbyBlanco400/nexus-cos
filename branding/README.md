# N3XUS v-COS Branding Assets

## 🎨 Overview

Official branding directory for N3XUS v-COS, containing the holographic logo system and brand identity assets.

## 📁 Directory Structure

```
branding/
├── logo.png            # Holographic N3XUS v-COS logo (PRIMARY)
├── colors.env          # Brand color definitions
├── theme.css           # Brand theme and styling
├── favicon.ico         # Browser favicon
└── official/           # Canonical official assets for VPS deployment
    ├── N3XUS-vCOS.png  # Official deployment logo
    └── README.md       # Deployment verification documentation
```

## 🌟 Primary Logo

**File**: `logo.png`

The new holographic logo features:
- **Gradient**: Neon cyan (#00F0FF) to violet plasma (#7A00FF)
- **Effects**: Built-in glow filter for holographic appearance
- **Format**: Portable Network Graphics (PNG)

### Usage

```html
<!-- Standard usage -->
<img src="/assets/branding/logo.png" alt="N3XUS v-COS">

<!-- Responsive sizing -->
<img src="/assets/branding/logo.png" alt="N3XUS v-COS" style="width: 200px; height: auto;">
```

## 🎨 Brand Colors

Defined in `colors.env`:

### Holographic Gradient
- **Cyan**: `#00F0FF` - Primary brand color (left)
- **Violet**: `#7A00FF` - Secondary brand color (right)

### Additional Colors
See `colors.env` for complete color palette including backgrounds, accents, and UI elements.

## 🔗 Related Assets

### Full Holographic System
For complete holographic logo implementation including Unity, WebGL, and WebGPU:

```
/assets/
├── branding/logo.png  # Source holographic PNG
├── 3d/                # Unity shaders and 3D assets
├── README.md          # Complete documentation
/webgl/                # Three.js WebGL demo
/webgpu/               # WebGPU implementation
```

See [/assets/README.md](../assets/README.md) for detailed documentation.

## 🚀 Deployment

### Stack-Wide Deployment

The holographic logo is automatically deployed to:
- `branding/logo.svg`
- `admin/public/assets/branding/logo.svg`
- `creator-hub/public/assets/branding/logo.svg`
- `frontend/public/assets/branding/logo.svg`

### Manual Sync

To manually sync the logo across all locations:

```bash
./deploy-holographic-logo.sh
```

## 📐 Logo Variants

| Variant | Use Case | Location |
|---------|----------|----------|
| **Holographic PNG** | Web, UI, responsive | `branding/logo.png` |
| **3D GLTF/GLB** | Unity, WebGL, 3D viewers | `assets/3d/logo.glb` |
| **Official Deployment** | VPS canonical verification | `branding/official/N3XUS-vCOS.png` |

## 🎬 Interactive Demos

- **Showcase Page**: `/logo-showcase.html` - Visual examples and integration guide
- **WebGL Demo**: `/webgl/index.html` - Interactive 3D logo with Three.js
- **WebGPU Demo**: `/webgpu/index.html` - Modern GPU-accelerated rendering

## 🛠️ Customization

### Adjusting Colors

Edit `logo.svg` to change the gradient:

```xml
<linearGradient id="holoGradient" x1="0%" y1="0%" x2="100%" y2="0%">
  <stop offset="0%" style="stop-color:#YOUR_COLOR_1;stop-opacity:1" />
  <stop offset="100%" style="stop-color:#YOUR_COLOR_2;stop-opacity:1" />
</linearGradient>
```

### CSS Animations

Add holographic effects with CSS:

```css
.logo-pulse {
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 0.9;
    filter: drop-shadow(0 0 10px rgba(0, 240, 255, 0.5));
  }
  50% {
    opacity: 1;
    filter: drop-shadow(0 0 25px rgba(0, 240, 255, 0.9));
  }
}
```

## 📋 Verification

The official logo is verified during VPS deployment by:
1. Canon-verifier checks (`canon-verifier/trae_go_nogo.py`)
2. File existence validation
3. Format and size verification
4. Configuration validation in `canon-verifier/config/canon_assets.json`

See `branding/official/README.md` for deployment workflow details.

## 🔄 Version History

- **v1.1.0** (Jan 2026): Official PNG Logo Update
  - Replaced SVG with official PNG (`6f65c21d-8980-4b14-ac6c-893cc6d7598b.png`)
  - Stack-wide deployment per N3XUS LAW
  - Removed SVG XML editing instructions

- **v1.0.0** (Jan 2026): Initial holographic logo implementation
  - Cyan-to-violet gradient
  - SVG with glow effects
  - Unity shader system
  - WebGL/WebGPU demos
  - Stack-wide deployment

## 📚 Documentation

- **Main Documentation**: [/assets/README.md](../assets/README.md)
- **WebGL Guide**: [/webgl/README.md](../webgl/README.md)
- **WebGPU Guide**: [/webgpu/README.md](../webgpu/README.md)
- **Deployment Workflow**: [/branding/official/README.md](./official/README.md)

## 📄 License

Part of the N3XUS v-COS brand identity. All rights reserved.

---

**Last Updated**: January 2026  
**Logo Version**: 1.0.0 Holographic  
**Status**: Production Ready
