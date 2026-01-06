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

### Automated Deployment (Recommended)

Use the deployment script for automated, validated deployment:

```bash
cd /home/runner/work/nexus-cos/nexus-cos
sudo bash scripts/deploy-pr87-landing-pages.sh
```

This script will:
- Create necessary directories
- Backup existing files
- Deploy both landing pages
- Set correct permissions
- Validate nginx configuration
- Generate deployment report

### Manual Deployment

#### Option 1: Deploy to Apex Domain

```bash
# Create directory if it doesn't exist
sudo mkdir -p /var/www/n3xuscos.online

# Copy apex landing page to root domain
sudo cp apex/index.html /var/www/n3xuscos.online/index.html

# Set permissions
sudo chown www-data:www-data /var/www/n3xuscos.online/index.html
sudo chmod 644 /var/www/n3xuscos.online/index.html
```

#### Option 2: Deploy to Beta Domain

```bash
# Create directory if it doesn't exist
sudo mkdir -p /var/www/beta.n3xuscos.online

# Copy beta landing page to beta subdomain
sudo cp web/beta/index.html /var/www/beta.n3xuscos.online/index.html

# Set permissions
sudo chown www-data:www-data /var/www/beta.n3xuscos.online/index.html
sudo chmod 644 /var/www/beta.n3xuscos.online/index.html
```

#### Option 3: Deploy Both (Recommended)

```bash
# Create directories
sudo mkdir -p /var/www/n3xuscos.online
sudo mkdir -p /var/www/beta.n3xuscos.online

# Deploy apex
sudo cp apex/index.html /var/www/n3xuscos.online/index.html

# Deploy beta
sudo cp web/beta/index.html /var/www/beta.n3xuscos.online/index.html

# Set permissions
sudo chown -R www-data:www-data /var/www/n3xuscos.online /var/www/beta.n3xuscos.online
sudo chmod 644 /var/www/n3xuscos.online/index.html /var/www/beta.n3xuscos.online/index.html
```

## Nginx Configuration

The updated nginx configuration is in `deployment/nginx/nexuscos-unified.conf`. Key changes:

1. **Root directory changed** from `/var/www/nexus-cos` to `/var/www/n3xuscos.online`
2. **Root path now serves landing page** instead of redirecting to `/admin/`
3. **Beta subdomain configured** with separate server block at `/var/www/beta.n3xuscos.online`

### Deploy the Configuration

```bash
# Copy unified configuration to nginx sites-available
sudo cp deployment/nginx/nexuscos-unified.conf /etc/nginx/sites-available/nexuscos

# Create symlink in sites-enabled (if not already exists)
sudo ln -sf /etc/nginx/sites-available/nexuscos /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### Key Configuration Highlights

**Apex Domain (n3xuscos.online):**
- Root: `/var/www/n3xuscos.online`
- Landing page served at `/`
- Admin panel at `/admin/`
- API endpoints at `/api/`

**Beta Subdomain (beta.n3xuscos.online):**
- Root: `/var/www/beta.n3xuscos.online`
- Landing page served at `/`
- Health checks at `/health/gateway` and `/v-suite/prompter/health`
- API endpoints at `/api/`

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
curl -I https://n3xuscos.online

# Test beta
curl -I https://beta.n3xuscos.online
```

### 2. Test Health Checks
```bash
# Test gateway health
curl https://n3xuscos.online/health/gateway

# Test prompter health
curl https://beta.n3xuscos.online/v-suite/prompter/health
```

### 3. Browser Testing
- Open https://n3xuscos.online in a browser
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
- [ ] "Explore the Beta" CTA links to beta.n3xuscos.online with UTM params
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
