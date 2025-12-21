# Casino Nexus V5 Assets

This directory contains all 3D assets, textures, sounds, and models for the Casino Nexus V5 engine.

## Directory Structure

```
assets/
├── textures/          # 3D texture files
│   ├── casino-floor/
│   ├── tables/
│   ├── cards/
│   └── chips/
├── models/            # 3D model files
│   ├── environments/
│   ├── furniture/
│   └── props/
├── sounds/            # Audio files
│   ├── ambient/
│   ├── effects/
│   └── music/
└── shaders/           # Shader programs
    ├── lighting/
    └── materials/
```

## Asset Loading

The Casino V5 engine automatically loads assets from this directory when the application starts.

### Texture Formats Supported
- PNG (recommended for UI)
- JPG (recommended for photos)
- WebP (recommended for optimized web delivery)
- DDS (for 3D textures)

### Model Formats Supported
- GLTF/GLB (recommended)
- FBX
- OBJ

### Sound Formats Supported
- MP3
- OGG
- WAV

## Usage in Production

When deploying to production, ensure all assets are copied to the casino frontend directory:

```bash
cp -r assets/ /var/www/nexus-cos/modules/casino-nexus/frontend/public/
```

## Asset Guidelines

1. **Optimization**: All assets should be optimized for web delivery
2. **Naming**: Use descriptive, lowercase names with hyphens (e.g., `poker-table-felt.png`)
3. **Size**: Keep individual files under 10MB
4. **Compression**: Use appropriate compression for each asset type
5. **Licensing**: Ensure all assets are properly licensed

## Development

During development, assets are served from this directory. The V5 engine will hot-reload assets when changes are detected.

## Production Notes

- Assets are cached by the browser for performance
- CDN integration available for global distribution
- Asset versioning handled by build system
