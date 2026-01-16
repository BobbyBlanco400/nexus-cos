# N3XUS v-COS Launch Page

## Overview

This is a special launch/teaser page for the N3XUS v-COS Founders Program featuring a futuristic glitch effect design.

## Features

### Visual Effects
- **Glitch Effect**: Dynamic glitch animation on the main title with RGB color separation
- **Animated Grid Background**: Moving cyberpunk-style grid pattern
- **Scanlines Overlay**: CRT monitor-style scanline effect
- **Floating Particles**: Animated particles that float upward across the screen
- **ASCII Art Logo**: N3XUS logo rendered in ASCII art

### Interactive Elements
- **Countdown Timer**: Shows days until launch (animates every 15 seconds for demo)
- **System Stats Display**: 
  - Deployment status
  - Active services count (13/13)
  - Memory usage (1.5GB/3.8GB)
  - Server load (< 2.0)
  - VPS IP address (72.62.86.217)
  - *Note: Stats are currently hardcoded for demo purposes. In production, these should be dynamically fetched from server APIs.*
- **CTA Button**: "Join the Founders Program" with pulsing glow effect

### Animations
1. **Fade In** (0-1s): Initial scene fade-in
2. **ASCII Logo** (1s): Logo appears from bottom
3. **Main Title** (on load): Glitch effect continuously animates
4. **Subtitle** (2s): "For Creatives Old and New" slides up
5. **Countdown** (3s): Launch countdown appears (top-right)
6. **Stats Panel** (3.5s): System stats appear (top-left)
7. **Badge** (4s): VPS info badge appears
8. **CTA Button** (5s): Call-to-action button slides up and starts pulsing

## Color Palette

- **Primary Background**: #000000 (black)
- **Cyan Accent**: #00fffc
- **Magenta Accent**: #fc00ff
- **Yellow Accent**: #fffc00
- **Success Green**: #00ff00
- **Gradient Purple**: #667eea → #764ba2

## Technical Implementation

### Glitch Effect
The glitch effect is achieved through:
- Multiple layered text elements with `clip-path`
- RGB color separation using `text-shadow`
- Randomized animation timing (725ms, 500ms, 375ms)
- Transform translations for horizontal displacement

### Grid Animation
- 200% sized container to allow for infinite scrolling effect
- CSS gradients creating the grid pattern
- 20-second animation loop moving the grid diagonally

### Particles
- Dynamically generated via JavaScript (30 particles)
- Random positioning and animation delays
- 6-second float animation with opacity transitions

### Countdown
- Updates every 15 seconds (for demo purposes)
- In production, this would update daily
- Changes to "LIVE" with green color when countdown reaches 0

## Usage

### Configuration

The page includes a `CONFIG` object at the top of the JavaScript section for easy customization:

```javascript
const CONFIG = {
    COUNTDOWN_INTERVAL: 15000,  // Milliseconds between countdown updates (15s for demo, 86400000 for daily)
    PARTICLE_COUNT: 30,          // Number of floating particles
    FOUNDERS_URL: 'https://github.com/BobbyBlanco400/N3XUS-vCOS'  // CTA button destination
};
```

### Local Testing
```bash
cd web/launch
python3 -m http.server 8080
# Open http://localhost:8080
```

### Production Deployment
Deploy to your web server at a path like:
- `/launch`
- `/founders`
- `/coming-soon`

## Browser Compatibility

- Modern browsers with CSS Grid support
- CSS Animations support required
- ES6 JavaScript support
- No external dependencies

## Responsive Design

The page is optimized for desktop viewing. For mobile devices:
- Font sizes scale with viewport
- Stats and countdown panels remain visible
- All animations are hardware-accelerated for smooth performance

## Future Enhancements

- Real-time countdown to actual launch date
- Integration with GitHub API to show live repository stats
- Audio effects on page load (currently commented out)
- WebGL background effects
- Video recording capability for creating promotional content

## Notes

This page serves as both:
1. A standalone landing page for the Founders Program
2. A template that can be captured/recorded for video promotional content

The design intentionally evokes a cyberpunk/futuristic aesthetic aligned with the N3XUS v-COS brand identity.

## License

© 2025 N3XUS v-COS. All rights reserved.
