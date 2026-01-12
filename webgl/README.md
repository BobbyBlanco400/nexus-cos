# N3XUS v-COS WebGL Holographic Logo Demo

## Overview

Interactive 3D holographic logo viewer using Three.js and GLTF model loading.

## Features

- Real-time holographic shader with:
  - Cyan-to-violet gradient
  - Pulsing emission effect
  - Noise-based flicker
  - Rim lighting
- GLTF model support
- Smooth rotation animation
- Responsive canvas

## Requirements

- Node.js 18+ or Bun
- Modern browser with WebGL 2.0 support

## Quick Start

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## 3D Model Setup

The demo loads the logo from `../assets/3d/logo.glb`. Generate this file using:

1. Open Blender (version 3.0+)
2. Create a new `.blend` file in the `assets/3d/` directory
3. Open the Blender Scripting workspace
4. Load `assets/3d/blender_extrude_logo.py`
5. Run the script (Alt+P or click Run Script button)
6. The script will generate `logo.glb` in the same directory

**Note**: If the logo.glb file is not found, the demo will display a fallback placeholder box with the holographic material applied and log instructions to the console.

## Customization

Edit `demo.js` to customize:

```javascript
// Change colors
const left = vec3(0.0, 0.94, 1.0);   // Cyan
const right = vec3(0.48, 0.0, 1.0);  // Violet

// Adjust pulse speed
float pulse = 0.5 + 0.5 * sin(time * 0.8);  // Change 0.8

// Modify rotation speed
logo.rotation.y += 0.005;  // Change 0.005
```

## Performance

- Targets 60 FPS on mid-range GPUs
- Uses WebGL 2.0 with antialiasing
- Optimized shader for real-time rendering

## Deployment

Build the static site:

```bash
npm run build
```

The `dist/` folder contains deployable assets. Serve with any static host:

```bash
# Example with Python
cd dist
python -m http.server 8080
```

## Browser Support

- Chrome 60+
- Firefox 60+
- Safari 14+
- Edge 79+

All with WebGL 2.0 support required.

## License

Part of N3XUS v-COS branding system.
