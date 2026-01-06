# Nexus COS Beta Landing Page

## Overview

This is the production-ready landing page for Nexus COS Beta environment, aligned with the Apex landing page design but with Beta-specific branding.

## Differences from Apex

### Beta Badge
- Green "BETA" badge displayed next to the Nexus COS logo in navigation
- Indicates this is the beta environment

### URL
- Intended for deployment at: https://beta.n3xuscos.online

## Features

Same as Apex landing page:
- Navigation with brand logo and Beta badge
- Hero section with CTAs
- Live Status Card (environment-aware health checks)
- Tabbed Modules interface
- Animated statistics counters
- FAQ section
- Theme toggle (Dark/Light)
- Responsive design

## Beta Badge Styling

```css
.beta-badge {
  background: linear-gradient(135deg, #10b981, #059669);
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
}
```

## Local Testing

```bash
cd web/beta
python3 -m http.server 8001
# Open http://localhost:8001
```

## Production Deployment

Deploy to beta subdomain:
- Primary URL: https://beta.n3xuscos.online
- Ensure health check endpoints are configured
- Status checks will query both current origin and beta domain

## Health Check Behavior

### Local Environment
- Shows neutral status (—) for both Gateway and Prompter
- Avoids CORS errors during development

### Production Environment
- Gateway: Checks current domain at /health/gateway
- Prompter: Checks https://beta.n3xuscos.online/v-suite/prompter/health
- Displays OK (green), ERR (red), or checking (yellow)

## Content Alignment

The Beta landing page maintains identical content structure to Apex:
- Same modules and descriptions
- Same FAQ items
- Same statistics (128 nodes, 100% uptime, 42ms)
- Same color scheme and theming
- Same responsive breakpoints

## Beta-Specific Considerations

1. **Beta Badge**: Clearly identifies this as the beta environment
2. **Health Monitoring**: May have different endpoints than production
3. **UTM Tracking**: All beta CTAs include campaign tracking
4. **User Messaging**: FAQ emphasizes production-grade quality

## Branding Consistency

Follows PF Standards and Global Branding Policy:
- Logo: Inline SVG (no external dependencies)
- Colors: Consistent with brand palette
- Typography: Inter font family
- Theme: Dark mode default, light mode option

## Documentation

For detailed feature documentation, see the Apex README:
- `../apex/README.md`

## Support

For issues or questions about the beta landing page:
1. Check health endpoints are responding correctly
2. Verify CORS configuration for production
3. Review browser console for JavaScript errors
4. Confirm DNS routing to beta subdomain

## License

© 2025 Nexus COS. All rights reserved.
