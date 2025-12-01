# Nexus COS - Deployment Fixes & Troubleshooting Index

This document provides a quick index to common deployment issues and their fixes.

## Quick Navigation

### Apache/Web Server Issues

#### Pixel Streaming Signalling Server
- **Problem**: Apache error "ProxyRequests must be On or Off"
- **Quick Fix**: [PIXEL_STREAMING_QUICK_FIX.md](PIXEL_STREAMING_QUICK_FIX.md)
- **Full Guide**: [PIXEL_STREAMING_DEPLOYMENT.md](PIXEL_STREAMING_DEPLOYMENT.md)
- **Script**: `./scripts/deploy-pixel-signalling.sh`

**One-liner fix:**
```bash
cd /opt/nexus-cos && ./scripts/deploy-pixel-signalling.sh nexuscos.online 8888
```

### V-Suite Services

#### V-Screen Hollywood
- **Service**: vscreen-hollywood
- **Port**: 8088
- **Documentation**: [VSCREEN_HOLLYWOOD_DEPLOYMENT.md](VSCREEN_HOLLYWOOD_DEPLOYMENT.md)
- **Quick Start**: [QUICK_START_VSCREEN_HOLLYWOOD.md](QUICK_START_VSCREEN_HOLLYWOOD.md)

### Database Issues

#### PostgreSQL Connection
- **Guide**: [DATABASE_SETUP_GUIDE.md](DATABASE_SETUP_GUIDE.md)
- **Fix**: [DB_FIX_README.md](DB_FIX_README.md)

### SSL/TLS Issues

#### Certificate Problems
- **Guide**: [README_SSL.md](README_SSL.md)
- **Implementation**: [SSL_IMPLEMENTATION.md](SSL_IMPLEMENTATION.md)

### General Deployment

#### Beta Launch
- **Quick Start**: [START_HERE_BETA_LAUNCH.md](START_HERE_BETA_LAUNCH.md)
- **Full Guide**: [BETA_LAUNCH_READY_V2025.md](BETA_LAUNCH_READY_V2025.md)

#### VPS Deployment
- **Guide**: [VPS_DEPLOYMENT_GUIDE.md](VPS_DEPLOYMENT_GUIDE.md)
- **Quick Commands**: [VPS_QUICK_COMMANDS.md](VPS_QUICK_COMMANDS.md)

## Common Error Messages

### Apache Errors

| Error | Fix |
|-------|-----|
| `ProxyRequests must be On or Off` | [PIXEL_STREAMING_QUICK_FIX.md](PIXEL_STREAMING_QUICK_FIX.md) |
| `Syntax error... Expected </IfModule>` | Check Apache config syntax, ensure balanced tags |
| `Module proxy not found` | Run `a2enmod proxy proxy_http` |

### Docker Errors

| Error | Fix |
|-------|-----|
| `Container already exists` | `docker rm -f <container-name>` |
| `Port already in use` | Change port or stop conflicting service |
| `GHCR unauthorized` | Authenticate with GitHub or use fallback image |

### Service Errors

| Error | Fix |
|-------|-----|
| `Health check fails` | Check service logs: `docker logs -f <service>` |
| `Connection refused` | Verify service is running: `docker ps` |
| `502 Bad Gateway` | Check backend service and proxy config |

## Test Scripts

### Deployment Testing
```bash
# Test pixel streaming deployment
./scripts/test-pixel-signalling-deployment.sh

# Test overall PF configuration
./scripts/test-pf-configuration.sh

# Test health endpoints
./scripts/health-check.sh
```

### Health Checks
```bash
# Check PF v2025 health
./scripts/check-pf-v2025-health.sh

# Validate deployment readiness
./scripts/validate-deployment-readiness.sh
```

## Automated Deployment Scripts

### Production Deployment
```bash
# Full beta launch
./EXECUTE_BETA_LAUNCH.sh

# VPS deployment
./nexus-cos-vps-deployment.sh

# PF master deployment
./pf-master-deployment.sh
```

### Service-Specific Deployment
```bash
# Pixel streaming signalling
./scripts/deploy-pixel-signalling.sh

# V-Suite services
./deploy-v-suite-pro.sh

# 29 services
./deploy-29-services.sh
```

## Documentation Index

### Essential Reading
1. [START_HERE.md](START_HERE.md) - Main entry point
2. [README.md](README.md) - Repository overview
3. [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) - System architecture

### Service Documentation
- [services/README.md](services/README.md) - All services overview
- [services/vscreen-hollywood/README.md](services/vscreen-hollywood/README.md) - V-Screen Hollywood
- [V_SUITE_PRO_SERVICES.md](V_SUITE_PRO_SERVICES.md) - V-Suite Pro services

### Deployment Guides
- [DEPLOYMENT_COMPLETE.md](DEPLOYMENT_COMPLETE.md) - Deployment summary
- [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Pre-deployment checklist
- [VPS_DEPLOYMENT_COMPLETE_GUIDE.md](VPS_DEPLOYMENT_COMPLETE_GUIDE.md) - VPS deployment

## Quick Reference

### Container Management
```bash
# View all containers
docker ps -a

# View logs
docker logs -f <container-name>

# Restart service
docker restart <container-name>

# Stop/remove service
docker stop <container-name>
docker rm <container-name>
```

### Apache Management
```bash
# Test configuration
apache2ctl -t

# Reload configuration
systemctl reload apache2

# View error log
tail -f /var/log/apache2/error.log
```

### Health Checks
```bash
# Test endpoint
curl -I https://nexuscos.online/v-suite/hollywood/

# WebSocket test
wscat -c wss://nexuscos.online/v-suite/hollywood/ws
```

## Need More Help?

If you can't find what you're looking for:

1. Check the [issues](https://github.com/BobbyBlanco400/nexus-cos/issues) on GitHub
2. Review service logs: `docker logs -f <service-name>`
3. Run diagnostic scripts in `scripts/` directory
4. Consult the comprehensive documentation files

---

**Last Updated**: 2025-01-04  
**Maintained By**: Nexus COS Team
