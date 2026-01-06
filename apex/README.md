# Nexus COS Apex Landing Page

## Overview

This is the production-ready landing page for Nexus COS Apex, designed for the Beta Launch with strict adherence to PF Standards and Global Branding Policy.

## Features

### Navigation
- **Brand Logo**: Inline SVG (no external dependencies)
- **Links**: Anchor navigation to #modules, #docs, #faq
- **Actions**: Login, Start Free CTAs, Theme toggle

### Hero Section
- **Title**: "The COS for Creative Ecosystems."
- **Tagline**: "Build AI‑powered workflows across apps, services, and devices."
- **CTAs**: 
  - Explore the Beta (with UTM tracking)
  - Explore Docs

### Live Status Card
- **Environment-Aware**: 
  - Local preview shows neutral status (—)
  - Production checks actual endpoints
- **Indicators**:
  - Gateway: GET /health/gateway (200 = OK)
  - Prompter: GET /v-suite/prompter/health (204 = OK)

### Module Tabs
1. **V‑Suite**: Prompter, Stage, Core, Glitch
2. **PUABO Fleet**: Dispatch, Driver, Fleet, Routes
3. **Gateway**: Ingress, Routing, Observability
4. **Creator Hub**: Workspace, Assets, Deploy
5. **Services**: V‑Stage, Kie AI (Paid), Gateway Services
6. **Micro‑services**: Core API, Subscription, Auth, Observability

### Animated Stats
- **Nodes Integrated**: 128 (animated with cubic easing)
- **Uptime**: 100% (animated)
- **Median Gateway**: 42ms (animated)

### FAQ Section
- What is Nexus COS?
- Is the Beta production‑grade?
- How do I start?

## Theming

### Dark Mode (Default)
- Background: #0c0f14
- Text: #ffffff
- Accent: #2563eb

### Light Mode
- Background: #ffffff
- Text: #1a202c
- Toggle button switches between modes

## Responsive Design
- **Desktop**: Two-column hero layout
- **Mobile** (≤820px): Single-column layout, hidden nav links

## Usage

### Local Testing
```bash
cd apex
python3 -m http.server 8000
# Open http://localhost:8000
```

### Production Deployment
- Deploy to root of apex domain
- Ensure health check endpoints are available:
  - /health/gateway
  - /v-suite/prompter/health

## Branding Assets

### Colors
- Primary: #2563eb
- Secondary: #1e40af
- Accent: #3b82f6
- Gradient: #667eea → #764ba2

### Theme Color
- Meta theme-color: #0c0f14

### Logo
- Inline SVG in navigation
- No external asset dependencies

## Links & CTAs

### External
- Beta: https://beta.n3xuscos.online/?utm_source=apex&utm_medium=hero&utm_campaign=beta_launch_2025_11

### Internal
- Login: /api/auth/login
- Sign Up: /api/auth/signup
- Docs: #docs (anchor)
- Modules: #modules (anchor)
- FAQ: #faq (anchor)

## Accessibility

- Semantic HTML5 elements
- ARIA labels on navigation
- Keyboard-accessible tabs and buttons
- Contrast-compliant color schemes
- Screen reader friendly status indicators

## Browser Support

- Modern browsers with ES6+ support
- CSS Grid and Flexbox
- CSS Variables (custom properties)
- requestAnimationFrame for animations

## Maintenance

To update content:
1. Module descriptions: Edit the `.module-item` sections
2. Stats: Update the `animateCounter` calls in the script
3. FAQ: Add/edit `.faq-item` elements
4. Colors: Modify `:root` CSS variables

## License

© 2025 Nexus COS. All rights reserved.
