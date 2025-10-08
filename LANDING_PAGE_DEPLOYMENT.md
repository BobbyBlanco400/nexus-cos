# Nexus COS Beta Launch Landing Pages - Deployment Guide

## Overview

This deployment guide provides instructions for TRAE to deploy the Nexus COS Beta Launch landing pages with strict adherence to PF Standards and Global Branding Policy.

## Files Created

### Landing Pages
1. **`apex/index.html`** - Main Apex landing page (815 lines)
2. **`web/beta/index.html`** - Beta environment landing page (826 lines)

### Documentation
3. **`apex/README.md`** - Apex page documentation
4. **`web/beta/README.md`** - Beta page documentation

## Quick Deployment

### Option 1: Deploy to Apex Domain

```bash
# Copy apex landing page to root domain
cp apex/index.html /var/www/nexuscos.online/index.html

# Or symlink
ln -sf /path/to/repo/apex/index.html /var/www/nexuscos.online/index.html
```

### Option 2: Deploy to Beta Domain

```bash
# Copy beta landing page to beta subdomain
cp web/beta/index.html /var/www/beta.nexuscos.online/index.html

# Or symlink
ln -sf /path/to/repo/web/beta/index.html /var/www/beta.nexuscos.online/index.html
```

### Option 3: Deploy Both (Recommended)

```bash
# Deploy apex
cp apex/index.html /var/www/nexuscos.online/index.html

# Deploy beta
cp web/beta/index.html /var/www/beta.nexuscos.online/index.html
```

## Nginx Configuration

Ensure your Nginx configuration serves the landing pages correctly:

```nginx
# Apex domain configuration
server {
    listen 443 ssl http2;
    server_name nexuscos.online www.nexuscos.online;
    
    root /var/www/nexuscos.online;
    index index.html;
    
    # SSL configuration (existing)
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    # Serve apex landing page
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Health check endpoint
    location /health/gateway {
        proxy_pass http://localhost:4000/health;
    }
    
    # API routes (existing configuration)
    location /api/ {
        proxy_pass http://localhost:4000;
    }
}

# Beta subdomain configuration
server {
    listen 443 ssl http2;
    server_name beta.nexuscos.online;
    
    root /var/www/beta.nexuscos.online;
    index index.html;
    
    # SSL configuration
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    # Serve beta landing page
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # V-Suite Prompter health check
    location /v-suite/prompter/health {
        proxy_pass http://localhost:3002/health;
        # Return 204 No Content on success
    }
    
    # API routes (existing configuration)
    location /api/ {
        proxy_pass http://localhost:4000;
    }
}
```

## Health Check Endpoints

The landing pages expect these endpoints to be available:

### Gateway Health Check
- **Endpoint**: `/health/gateway`
- **Expected Response**: HTTP 200 OK
- **Maps to**: Backend gateway service (port 4000)

### Prompter Health Check
- **Endpoint**: `/v-suite/prompter/health`
- **Expected Response**: HTTP 204 No Content
- **Maps to**: AI SDK/Prompter service (port 3002)

## Verification Steps

After deployment, verify the landing pages are working:

### 1. Access the Pages
```bash
# Test apex
curl -I https://nexuscos.online

# Test beta
curl -I https://beta.nexuscos.online
```

### 2. Test Health Checks
```bash
# Test gateway health
curl https://nexuscos.online/health/gateway

# Test prompter health
curl https://beta.nexuscos.online/v-suite/prompter/health
```

### 3. Browser Testing
- Open https://nexuscos.online in a browser
- Verify dark mode is default
- Click "Light" button to test theme toggle
- Click each module tab (V-Suite, PUABO Fleet, Gateway, etc.)
- Verify status indicators show appropriate state
- Check animated counters (should reach 128, 100%, 42ms)
- Test responsive design (resize browser to ≤820px)

## Features Verification Checklist

- [ ] Navigation bar visible with logo and links
- [ ] Theme toggle works (Dark ↔ Light)
- [ ] Hero section displays correctly
- [ ] Live Status Card shows status indicators
- [ ] All 6 module tabs switch correctly
- [ ] Kie AI shows "Paid" badge
- [ ] Stats animate on page load
- [ ] FAQ section displays all 3 questions
- [ ] Footer appears at bottom
- [ ] "Explore the Beta" CTA links to beta.nexuscos.online with UTM params
- [ ] Login/Start Free buttons link to /api/auth routes
- [ ] Responsive design works on mobile view
- [ ] Beta page shows green "BETA" badge

## Branding Compliance

✅ **Logo**: Inline SVG, no external dependencies
✅ **Colors**: 
   - Primary: #2563eb
   - Gradient: #667eea → #764ba2
   - Dark BG: #0c0f14
✅ **Typography**: Inter font family
✅ **Theme Color**: #0c0f14
✅ **Favicon**: Data URI encoded SVG

## SEO & Meta Tags

All pages include:
- Title tags (unique per page)
- Meta descriptions
- Open Graph tags for social sharing
- Twitter Card tags
- Viewport meta for mobile
- Theme color meta

## Performance

- **No external dependencies** for critical rendering
- **Inline styles** for first paint optimization
- **Inline JavaScript** (no external JS files)
- **Minimal HTTP requests**
- **Smooth animations** using requestAnimationFrame

## Accessibility

- Semantic HTML5 elements
- ARIA labels on navigation
- Keyboard-accessible tabs and buttons
- Screen reader friendly
- Contrast-compliant colors (WCAG AA)

## Troubleshooting

### Issue: Status indicators show "ERR"
**Solution**: Verify health check endpoints are responding correctly
```bash
# Check gateway
curl -I http://localhost:4000/health

# Check prompter
curl -I http://localhost:3002/health
```

### Issue: Theme toggle doesn't work
**Solution**: Check browser console for JavaScript errors. Ensure Content Security Policy allows inline scripts.

### Issue: Tabs don't switch
**Solution**: Verify JavaScript is not blocked. Check that all tab IDs match button data-tab attributes.

### Issue: Counters don't animate
**Solution**: Ensure requestAnimationFrame is supported. Check for JavaScript errors in console.

## Local Testing

For local testing before deployment:

```bash
# Test apex locally
cd /path/to/repo/apex
python3 -m http.server 8000
# Open http://localhost:8000

# Test beta locally
cd /path/to/repo/web/beta
python3 -m http.server 8001
# Open http://localhost:8001
```

In local environment, status indicators will show "—" (neutral) to avoid CORS errors.

## Maintenance

### Updating Content

1. **Module descriptions**: Edit HTML in the `.module-item` sections
2. **Statistics**: Update `animateCounter` function calls
3. **FAQ items**: Add/edit `.faq-item` elements
4. **Colors**: Modify CSS `:root` variables

### Version Control

After making changes:
```bash
git add apex/index.html web/beta/index.html
git commit -m "Update landing page content"
git push
```

## Support

For issues or questions:
1. Check this deployment guide
2. Review README files in apex/ and web/beta/
3. Verify all prerequisites are met
4. Check service logs for errors

## Summary

The Nexus COS Beta Launch landing pages are production-ready and fully compliant with PF Standards and Global Branding Policy. They feature:

- ✅ Professional design with dark/light themes
- ✅ Environment-aware health monitoring
- ✅ Comprehensive module documentation
- ✅ Animated statistics and smooth interactions
- ✅ Full responsive design
- ✅ SEO optimized with social meta tags
- ✅ Accessible and keyboard-friendly
- ✅ Zero external dependencies for logo

Deploy with confidence! 🚀

---

**Ready to hand off to TRAE for production deployment.**
