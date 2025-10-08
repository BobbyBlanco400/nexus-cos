# 🔧 NEXUS COS URL Verification & Monitoring Tools

This directory contains automated tools for verifying and monitoring all URLs documented in `docs/NEXUS_COS_URLS.md`.

## 📋 Available Scripts

### 1. Final Complete System Check (NEW) 🚀
**File:** `nexus-cos-final-system-check.sh`  
**Purpose:** Comprehensive validation of the entire Nexus COS Platform

```bash
./scripts/nexus-cos-final-system-check.sh
```

**Validation Categories:**
- ✅ System requirements & versions (Docker, Nginx, etc.)
- ✅ Deployment artifacts (scripts, compose files, configs)
- ✅ Docker stack validation (syntax & running services)
- ✅ Nginx configuration validation (nginx -t)
- ✅ SSL certificate validation & expiry check
- ✅ Internal health endpoints (127.0.0.1:9001-9004)
- ✅ Preview URLs (Home, Admin, Hub, Studio)
- ✅ Service health endpoints (60+ endpoints)

**Features:**
- 🎯 60+ individual checks across 8 categories
- 📊 Detailed summary with success rate percentage
- 🎨 Color-coded output (pass/fail/warning)
- 📝 Useful commands reference
- 💡 Next steps recommendations
- 🔍 SSL certificate expiry tracking

**Exit Codes:**
- `0` - All checks passed (system fully operational)
- `1` - Some checks failed (review needed)

**Documentation:**
- Complete guide: [`FINAL_SYSTEM_CHECK_COMPLETE.md`](../FINAL_SYSTEM_CHECK_COMPLETE.md)
- Health checks reference: [`PF_v2025.10.01_HEALTH_CHECKS.md`](../PF_v2025.10.01_HEALTH_CHECKS.md)

### 2. PF Final Deployment ✨
**File:** `pf-final-deploy.sh`  
**Purpose:** Complete system check and re-deployment for Nexus COS Pre-Flight

```bash
./scripts/pf-final-deploy.sh
```

**Features:**
- ✅ Complete system requirements validation
- ✅ Repository and file structure verification
- ✅ Automated SSL certificate management
- ✅ Environment configuration validation
- ✅ Full Docker service deployment
- ✅ Nginx configuration and reload
- ✅ Post-deployment health checks
- ✅ Comprehensive deployment summary

**Requirements:**
- Docker and Docker Compose installed
- Nginx installed (optional, but recommended)
- Valid SSL certificates
- `.env.pf` file configured

**Documentation:**
- Complete guide: [`PF_SYSTEM_CHECK_AND_REDEPLOY_GUIDE.md`](../PF_SYSTEM_CHECK_AND_REDEPLOY_GUIDE.md)
- Assets manifest: [`docs/PF_ASSETS_LOCKED_2025-10-03T14-46Z.md`](../docs/PF_ASSETS_LOCKED_2025-10-03T14-46Z.md)

### 3. Production URL Verification
**File:** `verify-production-urls.sh`
**Purpose:** Comprehensive verification of all production URLs and SSL certificates

```bash
./scripts/verify-production-urls.sh
```

**Checks:**
- Primary domain (nexuscos.online, www.nexuscos.online)
- Internal service URLs (Node.js, Python backends)
- Health check endpoints
- SSL certificates
- Performance metrics

### 4. Beta URL Verification
**File:** `verify-beta-urls.sh`  
**Purpose:** Beta environment verification for 10/01/2025 launch

```bash
./scripts/verify-beta-urls.sh
```

**Features:**
- Beta domain verification (beta.nexuscos.online)
- Launch readiness assessment
- Local development endpoint checks
- Beta-specific performance validation

### 5. Continuous URL Monitoring
**File:** `monitor-urls.sh`
**Purpose:** Continuous monitoring with alerting and reporting

```bash
# Single check
./scripts/monitor-urls.sh --single-check

# Continuous monitoring
./scripts/monitor-urls.sh --daemon

# Generate health report
./scripts/monitor-urls.sh --report

# Setup as system service
sudo ./scripts/monitor-urls.sh --setup-service
```

## 🚀 Quick Start Guide

### For Complete System Check (Recommended)
```bash
# Run comprehensive system check
./scripts/nexus-cos-final-system-check.sh

# Check specific domain
DOMAIN=beta.nexuscos.online ./scripts/nexus-cos-final-system-check.sh

# On VPS (production)
ssh user@nexuscos.online
cd /opt/nexus-cos
bash scripts/nexus-cos-final-system-check.sh
```

### For Beta Launch (10/01/2025)
```bash
# 1. Run final system check
./scripts/nexus-cos-final-system-check.sh

# 2. Verify beta readiness
./scripts/verify-beta-urls.sh

# 3. Start monitoring before launch
./scripts/monitor-urls.sh --daemon

# 4. Generate pre-launch report
./scripts/monitor-urls.sh --report
```

### For Production Deployment
```bash
# 1. Run complete system check
./scripts/nexus-cos-final-system-check.sh

# 2. Verify production environment
./scripts/verify-production-urls.sh

# 3. Setup continuous monitoring
sudo ./scripts/monitor-urls.sh --setup-service
sudo systemctl start nexus-cos-monitor
```

## 📊 Monitoring Features

### Health Checks
- **Response Time Monitoring**: Alerts if > 2 seconds
- **HTTP Status Validation**: Ensures 2xx responses
- **Content Verification**: Validates expected response content
- **SSL Certificate Monitoring**: Tracks expiry dates

### Alerting
- **Log Files**: 
  - `logs/url-health-monitor.log` - General health status
  - `logs/url-alerts.log` - Critical alerts only
  - `logs/url-performance.log` - Performance metrics

### Reporting
- **Automated Reports**: Generated hourly when running in daemon mode
- **Performance Analytics**: Response time trends and statistics
- **SSL Expiry Tracking**: Alerts 30 days before expiration

## 🔍 Troubleshooting

### Common Issues

**SSL Certificate Errors:**
```bash
# Check certificate manually
openssl s_client -connect nexuscos.online:443 -servername nexuscos.online
```

**Network Connectivity:**
```bash
# Test basic connectivity
curl -I https://nexuscos.online
```

**Service Not Responding:**
```bash
# Check specific service health
curl -s https://nexuscos.online:3000/health | jq '.'
```

### Script Dependencies
- `curl` - HTTP client for URL testing
- `openssl` - SSL certificate verification
- `jq` - JSON parsing (optional, for better output)
- `bc` - Calculation support

Install dependencies:
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install curl openssl jq bc

# CentOS/RHEL
sudo yum install curl openssl jq bc
```

## 📅 Beta Launch Schedule

### Pre-Launch (September 30, 2025)
- [ ] Run final beta verification: `./scripts/verify-beta-urls.sh`
- [ ] Start monitoring daemon: `./scripts/monitor-urls.sh --daemon`
- [ ] Generate pre-launch report: `./scripts/monitor-urls.sh --report`

### Launch Day (October 1, 2025)
- [ ] **06:00 UTC**: Final health check sweep
- [ ] **08:00 UTC**: DNS switch verification
- [ ] **08:30 UTC**: Verify all services responding
- [ ] **09:00 UTC**: Monitor alerts for first hour
- [ ] **12:00 UTC**: Performance validation
- [ ] **18:00 UTC**: End-of-day health summary

### Post-Launch
- [ ] **First 24 hours**: Monitor every 15 minutes
- [ ] **First week**: Monitor every hour  
- [ ] **Ongoing**: Standard monitoring (every 30 minutes)

## 🎯 Success Criteria

### Beta Launch Ready ✅
- All beta URLs responding with 2xx status codes
- SSL certificates valid for beta.nexuscos.online
- Response times < 2 seconds
- Health endpoints returning expected "ok" status
- All authentication endpoints functional

### Production Ready ✅  
- All production URLs responding correctly
- SSL certificates valid for all domains
- CDN properly configured and caching
- Monitoring service operational
- Alert thresholds configured

## 📞 Emergency Procedures

### Service Down Response
1. **Immediate**: Check health endpoints
2. **Review**: Recent deployment logs  
3. **Verify**: SSL certificate status
4. **Check**: CloudFlare status page
5. **Escalate**: To infrastructure team

### Performance Issues
1. **Monitor**: Response time trends
2. **Check**: CDN cache hit rates
3. **Review**: Application logs
4. **Scale**: Backend services if needed
5. **Enable**: Emergency cache extensions

## 🔗 Related Documentation

- [`docs/NEXUS_COS_URLS.md`](../docs/NEXUS_COS_URLS.md) - Complete URL documentation
- [`LAUNCH_READINESS_REPORT.md`](../LAUNCH_READINESS_REPORT.md) - Overall system readiness
- [`beta-environment-report.md`](../beta-environment-report.md) - Beta environment status

---

**🎉 Ready for Beta Launch on October 1, 2025!**

*All verification and monitoring tools are operational and ready to ensure a successful beta launch.*