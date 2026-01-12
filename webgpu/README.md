# N3XUS v-COS WebGPU Holographic Demo

## Overview

Modern GPU-accelerated holographic shader demo using WebGPU and Vite.

## Features

- Native WebGPU compute and rendering
- WGSL shader language
- Real-time holographic effects:
  - Gradient coloring
  - Pulsing animation
  - Noise flicker
  - Rim lighting
- 60+ FPS performance

## Requirements

- Node.js 18+
- WebGPU-compatible browser:
  - Chrome 113+ (enable `chrome://flags/#enable-unsafe-webgpu`)
  - Edge 113+
  - Chrome Canary/Dev with WebGPU enabled

**Note**: WebGPU is currently experimental. Not all browsers support it.

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

Open browser to `http://localhost:5173` (Vite default).

## Browser Compatibility Check

The demo automatically checks for WebGPU support and displays an error if unavailable:

```javascript
if (!navigator.gpu) {
  console.error('WebGPU not supported');
  return;
}
```

## Shader Customization

Edit `main.js` WGSL shader code:

```wgsl
// Change gradient colors
let left = vec3<f32>(0.0, 0.94, 1.0);   // Cyan
let right = vec3<f32>(0.48, 0.0, 1.0);  // Violet

// Adjust pulse speed
let pulse = 0.5 + 0.5 * sin(uTime * 0.8);  // Modify 0.8
```

## Performance

- Targets 60+ FPS
- Uses compute shaders for optimal GPU utilization
- Triangle strip primitive for efficiency
- Uniform buffer for time parameter

## Architecture

```
main.js
├── WebGPU initialization
├── Vertex buffer (full-screen quad)
├── Shader module (WGSL)
├── Render pipeline
└── Animation loop
```

## Deployment

Build for production:

```bash
npm run build
```

Serve the `dist/` directory with any static file server.

**Important**: Ensure your server sends correct MIME types and uses HTTPS (WebGPU requires secure context).

## Fallback Strategy

For production, provide a WebGL fallback:

```javascript
if (!navigator.gpu) {
  // Load WebGL version instead
  import('./fallback-webgl.js');
}
```

See the `../webgl/` demo for a compatible fallback implementation.

## Browser Support

- ✅ Chrome 113+ (flag required)
- ✅ Edge 113+ (flag required)
- ✅ Chrome Canary/Dev
- ⚠️ Firefox (in development)
- ❌ Safari (planned)

## Development

Hot module replacement (HMR) is enabled via Vite. Changes to `main.js` reload automatically.

## Troubleshooting

**WebGPU not available:**
- Check browser version (Chrome 113+)
- Enable `chrome://flags/#enable-unsafe-webgpu`
- Ensure HTTPS or localhost

**Black screen:**
- Check browser console for errors
- Verify shader compilation
- Confirm GPU adapter/device creation

**Poor performance:**
- Update GPU drivers
- Check GPU hardware compatibility
- Reduce render resolution

## License

Part of N3XUS v-COS branding system.
