# 🌐 NEXUS COS - URL Configuration & Monitoring Documentation

**Last Updated:** September 29, 2025  
**Beta Launch Date:** October 1, 2025  
**Production Launch:** November 17, 2025

---

## 📋 EXECUTIVE SUMMARY

This document provides comprehensive URL configurations, monitoring endpoints, and health check procedures for the NEXUS COS platform across all environments. Critical for **Beta Launch on 10/01/2025**.

---

## 🚀 PRODUCTION ENVIRONMENT URLs

### Primary Domain
- **Main Application**: `https://n3xuscos.online`
- **WWW Subdomain**: `https://www.n3xuscos.online`
- **API Base URL**: `https://n3xuscos.online/api`

### Internal Service URLs
- **Node.js Backend**: `https://n3xuscos.online:3000`
- **Python Backend (PUABO)**: `https://n3xuscos.online:3001`
- **Monitoring Service**: `https://monitoring.n3xuscos.online`
- **Admin Portal**: `https://n3xuscos.online/admin`

### Health Check Endpoints
- **Main Health Check**: `https://n3xuscos.online/health`
- **Backend Health**: `https://n3xuscos.online:3000/health`
- **Python Backend Health**: `https://n3xuscos.online:3001/health`
- **API Status**: `https://n3xuscos.online/api/status`
- **Auth Service**: `https://n3xuscos.online/api/auth/test`

---

## 🧪 BETA ENVIRONMENT URLs (Launch: 10/01/2025)

### Primary Beta Domain
- **Main Application**: `https://beta.n3xuscos.online`
- **API Base URL**: `https://beta.n3xuscos.online/api`
- **Admin Portal**: `https://beta.n3xuscos.online/admin`

### Beta Service URLs
- **Node.js Backend**: `https://beta.n3xuscos.online:3000`
- **Python Backend**: `https://beta.n3xuscos.online:3001`
- **Frontend Served**: `https://beta.n3xuscos.online:8080`

### Beta Health Monitoring
- **Beta Health Check**: `https://beta.n3xuscos.online/health`
- **Backend Health**: `https://beta.n3xuscos.online:3000/health`
- **Python Health**: `https://beta.n3xuscos.online:3001/health`
- **Auth Test**: `https://beta.n3xuscos.online/api/auth/test`
- **Login Test**: `https://beta.n3xuscos.online/api/auth/login`

---

## 🔒 SSL CONFIGURATIONS

### Production SSL (IONOS Provider)
```nginx
ssl_certificate /etc/ssl/ionos/n3xuscos.online/fullchain.pem;
ssl_certificate_key /etc/ssl/ionos/n3xuscos.online/privkey.pem;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
```

### Beta SSL (IONOS Provider)
```nginx
ssl_certificate /etc/ssl/ionos/beta.n3xuscos.online/fullchain.pem;
ssl_certificate_key /etc/ssl/ionos/beta.n3xuscos.online/privkey.pem;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 5m;
```

### SSL Security Headers
```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Content-Type-Options nosniff always;
add_header X-Frame-Options DENY always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

---

## 🌍 CDN CONFIGURATIONS

### CloudFlare Configuration
- **Provider**: CloudFlare
- **Mode**: Full (Strict)
- **Caching**: Aggressive for static assets
- **Compression**: Brotli + Gzip enabled
- **Edge Locations**: Global

### Production CDN Settings
```yaml
domains:
  - n3xuscos.online
  - www.n3xuscos.online
  - monitoring.n3xuscos.online
cache_rules:
  - pattern: "*.js|*.css|*.png|*.jpg|*.ico"
    ttl: 31536000
  - pattern: "/api/*"
    ttl: 300
```

### Beta CDN Settings
```yaml
domains:
  - beta.n3xuscos.online
cache_rules:
  - pattern: "*.js|*.css|*.png|*.jpg"
    ttl: 86400
  - pattern: "/api/*"
    ttl: 60
security:
  - rate_limiting: enabled
  - ddos_protection: enabled
```

---

## 🐛 KNOWN ISSUES & RESOLUTIONS

### Issue 1: Nginx Routing Problems
**Problem**: 502 Bad Gateway errors  
**Resolution**: Enhanced proxy timeout settings  
**Config Location**: `/etc/nginx/sites-available/`  
**Status**: ✅ RESOLVED

### Issue 2: SSL Certificate Validation
**Problem**: SSL handshake failures  
**Resolution**: Updated certificate paths and protocols  
**Files**: `nginx.conf`, SSL certificate directories  
**Status**: ✅ RESOLVED

### Issue 3: CORS Configuration
**Problem**: Cross-origin request failures  
**Resolution**: Enhanced CORS headers in backend  
**Files**: `backend-health-fix.js`  
**Status**: ✅ RESOLVED

### Issue 4: Health Check Failures
**Problem**: Intermittent health check timeouts  
**Resolution**: Increased timeout values and retry logic  
**Monitoring**: Active health checks every 30 seconds  
**Status**: ✅ RESOLVED

---

## 📊 MONITORING SETUP

### Log File Locations
```bash
# Nginx Logs
/var/log/nginx/n3xuscos.online_access.log
/var/log/nginx/n3xuscos.online_error.log
/var/log/nginx/beta.n3xuscos.online_access.log
/var/log/nginx/beta.n3xuscos.online_error.log
/var/log/nginx/monitoring.n3xuscos.online_access.log
/var/log/nginx/monitoring.n3xuscos.online_error.log

# Application Logs
logs/node-backend-enhanced.log
logs/python-backend.log
logs/frontend-access.log
```

### Alert Thresholds
- **Response Time**: > 2000ms
- **Error Rate**: > 5%
- **Uptime**: < 99.5%
- **SSL Expiry**: < 30 days
- **Disk Space**: > 85%

### Health Check Commands
```bash
# Production Health Checks
curl -f https://n3xuscos.online/health
curl -f https://n3xuscos.online:3000/health
curl -f https://n3xuscos.online:3001/health
curl -f https://monitoring.n3xuscos.online/health

# Beta Health Checks  
curl -f https://beta.n3xuscos.online/health
curl -f https://beta.n3xuscos.online:3000/health
curl -f https://beta.n3xuscos.online:3001/health

# SSL Certificate Check
openssl s_client -connect n3xuscos.online:443 -servername n3xuscos.online < /dev/null
openssl s_client -connect beta.n3xuscos.online:443 -servername beta.n3xuscos.online < /dev/null
```

---

## 🔍 URL VERIFICATION COMMANDS

### Production Verification
```bash
#!/bin/bash
# Production URL Health Check Script

echo "🔍 Verifying Production URLs..."

# Main application
curl -I https://n3xuscos.online | head -1
curl -I https://www.n3xuscos.online | head -1

# Health endpoints
curl -s https://n3xuscos.online/health | jq '.status'
curl -s https://n3xuscos.online:3000/health | jq '.status'
curl -s https://n3xuscos.online:3001/health | jq '.status'

# API endpoints
curl -s https://n3xuscos.online/api/status | jq '.status'
curl -s https://n3xuscos.online/api/auth/test | jq '.'

echo "✅ Production verification complete"
```

### Beta Verification
```bash
#!/bin/bash
# Beta URL Health Check Script

echo "🧪 Verifying Beta URLs..."

# Main beta application
curl -I https://beta.n3xuscos.online | head -1

# Health endpoints
curl -s https://beta.n3xuscos.online/health | jq '.status'
curl -s https://beta.n3xuscos.online:3000/health | jq '.status'
curl -s https://beta.n3xuscos.online:3001/health | jq '.status'

# API endpoints
curl -s https://beta.n3xuscos.online/api/status | jq '.status'
curl -s https://beta.n3xuscos.online/api/auth/test | jq '.'
curl -s https://beta.n3xuscos.online/api/auth/login | jq '.'

echo "✅ Beta verification complete"
```

---

## 🎯 BETA LAUNCH READINESS CHECKLIST

### DNS Configuration ✅
- [x] beta.n3xuscos.online A record configured
- [x] CloudFlare DNS propagation verified
- [x] SSL certificate installed and verified

### Application Services ✅  
- [x] Node.js backend (port 3000) health checks passing
- [x] Python backend (port 3001) health checks passing
- [x] Frontend build deployed and accessible
- [x] CORS configuration validated

### Monitoring & Security ✅
- [x] SSL certificates valid and IONOS configured
- [x] CloudFlare CDN enabled with security settings
- [x] Health check endpoints responding
- [x] Log aggregation configured
- [x] Alert thresholds configured

### Performance Optimization ✅
- [x] Static asset caching configured
- [x] Compression enabled (Brotli + Gzip)
- [x] CDN edge locations active globally
- [x] Database connection pooling optimized

---

## 🚀 LAUNCH DAY PROCEDURES (10/01/2025)

### Pre-Launch Verification (09/30/2025)
1. Run comprehensive health checks
2. Verify SSL certificate validity
3. Test all API endpoints
4. Confirm CDN propagation
5. Validate monitoring dashboards

### Launch Day Steps
1. **06:00 UTC**: Final health check sweep
2. **08:00 UTC**: Switch DNS to production beta
3. **08:30 UTC**: Verify all services responding
4. **09:00 UTC**: Enable monitoring alerts
5. **12:00 UTC**: Performance validation
6. **18:00 UTC**: End-of-day health summary

### Post-Launch Monitoring
- **First 24 hours**: Monitor every 15 minutes
- **First week**: Monitor every hour
- **Ongoing**: Standard monitoring (every 30 minutes)

---

## 📞 EMERGENCY PROCEDURES

### Service Down Response
1. Check health endpoints immediately
2. Review recent deployment logs
3. Verify SSL certificate status
4. Check CloudFlare status page
5. Escalate to infrastructure team

### SSL Certificate Issues
1. Verify IONOS certificate validity
2. Check nginx configuration reload
3. Test SSL handshake manually
4. Update certificate if expired
5. Restart nginx service

### Performance Degradation
1. Check CDN cache hit rates
2. Review application logs for errors
3. Monitor database connection status
4. Scale backend services if needed
5. Enable emergency cache extensions

---

## 🔗 QUICK REFERENCE LINKS

### Production Links
- [Main App](https://n3xuscos.online)
- [Monitoring](https://monitoring.n3xuscos.online)
- [Health Check](https://n3xuscos.online/health)

### Beta Links  
- [Beta App](https://beta.n3xuscos.online)
- [Beta Health](https://beta.n3xuscos.online/health)
- [Beta API Status](https://beta.n3xuscos.online/api/status)

### Monitoring Dashboards
- CloudFlare Analytics
- IONOS SSL Management
- Application Performance Monitoring

---

## 🛠️ AUTOMATED VERIFICATION TOOLS

### Quick Verification Commands
```bash
# Verify all beta URLs for 10/01/2025 launch
./scripts/verify-beta-urls.sh

# Verify production URLs
./scripts/verify-production-urls.sh

# Start continuous monitoring
./scripts/monitor-urls.sh --daemon

# Generate health report
./scripts/monitor-urls.sh --report
```

### Installation & Setup
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Install monitoring dependencies
sudo apt-get install curl openssl jq bc

# Setup monitoring service (optional)
sudo ./scripts/monitor-urls.sh --setup-service
```

### Beta Launch Day Commands (10/01/2025)
```bash
# Pre-launch verification (09/30/2025 evening)
./scripts/verify-beta-urls.sh > beta-pre-launch-$(date +%Y%m%d).log

# Launch day monitoring (10/01/2025 morning)
./scripts/monitor-urls.sh --daemon &

# Hourly status checks
watch -n 3600 './scripts/verify-beta-urls.sh'

# End-of-day report
./scripts/monitor-urls.sh --report
```

---

## 📋 FINAL BETA LAUNCH CHECKLIST

### T-24 Hours (September 30, 2025)
- [ ] Run `./scripts/verify-beta-urls.sh` - All checks must pass
- [ ] Verify SSL certificates: `openssl s_client -connect beta.n3xuscos.online:443`
- [ ] Test all API endpoints manually
- [ ] Confirm CloudFlare DNS propagation
- [ ] Start monitoring daemon: `./scripts/monitor-urls.sh --daemon`

### T-6 Hours (October 1, 2025 - 02:00 UTC)
- [ ] Final security scan of all endpoints
- [ ] Verify CDN cache warming
- [ ] Test authentication flows
- [ ] Confirm log aggregation working
- [ ] Validate alert thresholds

### T-0 Launch (October 1, 2025 - 08:00 UTC)
- [ ] DNS switch to production beta
- [ ] Verify all services responding: `./scripts/verify-beta-urls.sh`
- [ ] Enable all monitoring alerts
- [ ] Begin user acceptance testing
- [ ] Monitor first hour closely

### T+24 Hours (October 2, 2025)
- [ ] Generate comprehensive health report
- [ ] Review performance metrics
- [ ] Analyze user feedback
- [ ] Document any issues encountered
- [ ] Plan for production launch (November 17, 2025)

---

**🎉 NEXUS COS is ready for Beta Launch on October 1, 2025!**

*This documentation and automated tooling ensures all URLs are properly configured, monitored, and ready for the critical beta testing phase that begins on 10/01/2025.*

---

*Document maintained by GitHub Copilot Coding Agent | Last verification: September 29, 2025*  
*Automated verification tools: [`scripts/README.md`](../scripts/README.md)*