# Nexus COS Extended - Production Deployment Guide

## 🚀 Overview

This guide provides comprehensive instructions for deploying the Nexus COS Extended system, including all microservices, V-Suite modules, PUABO integrations, and monitoring infrastructure.

## 📋 Prerequisites

### System Requirements
- **OS**: Ubuntu 20.04+ or CentOS 8+
- **RAM**: Minimum 16GB (32GB recommended)
- **CPU**: 8+ cores
- **Storage**: 500GB+ SSD
- **Network**: Static IP with domain pointing to server

### Software Dependencies
- Docker 24.0+
- Docker Compose 2.20+
- Node.js 18+
- Git
- Nginx (for reverse proxy)
- Certbot (for SSL certificates)

### Domain Configuration
- Primary domain: `nexuscos.online`
- Staging domain: `staging.nexuscos.online`
- Subdomains configured for services

## 🔧 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/your-org/nexus-cos-extended.git
cd nexus-cos-extended
```

### 2. Environment Setup
```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

### 3. One-Command Deployment
```bash
# Make deployment script executable
chmod +x deploy-nexus-cos.sh

# Deploy complete system
./deploy-nexus-cos.sh
```

## 🌐 Environment Variables

### Core Configuration
```bash
# Domain Configuration
DOMAIN=nexuscos.online
ENVIRONMENT=production

# Database Configuration
POSTGRES_DB=nexus_cos_db
POSTGRES_USER=nexus_admin
POSTGRES_PASSWORD=your_secure_password
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password

# JWT Configuration
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=24h

# API Keys
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key
GOOGLE_CLOUD_API_KEY=your_google_key

# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password

# SSL Configuration
SSL_EMAIL=admin@nexuscos.online
CERTBOT_EMAIL=admin@nexuscos.online

# Mobile App Configuration
EXPO_TOKEN=your_expo_token
EXPO_PROJECT_ID=your_project_id
```

### Service-Specific Variables
```bash
# V-Suite Configuration
V_SUITE_API_KEY=your_v_suite_key
V_SUITE_WEBHOOK_SECRET=your_webhook_secret

# PUABO Configuration
PUABO_API_KEY=your_puabo_key
PUABO_WEBHOOK_URL=https://nexuscos.online/webhooks/puabo

# Boom Boom Room Live
BBR_STREAM_KEY=your_stream_key
BBR_RTMP_URL=rtmp://nexuscos.online/live

# Creator Hub
CREATOR_HUB_API_KEY=your_creator_hub_key
CREATOR_HUB_WEBHOOK_SECRET=your_webhook_secret

# Monitoring
GRAFANA_ADMIN_PASSWORD=your_grafana_password
PROMETHEUS_RETENTION=30d
```

## 🐳 Docker Infrastructure

### Production Services
The system includes 15+ microservices:

1. **Core Services**
   - PostgreSQL Database
   - Redis Cache
   - Nginx Reverse Proxy

2. **V-Suite Modules**
   - V-Screen (Virtual Screens)
   - V-Stage (Virtual Staging)
   - V-Caster Pro (Broadcasting)
   - V-Prompter Pro (Teleprompter)

3. **PUABO Integrations**
   - PUABO OS 2025
   - Creator Hub
   - PuaboVerse

4. **Entertainment**
   - Boom Boom Room Live
   - Da Boom Boom Room

5. **Applications**
   - Frontend (React)
   - Admin Panel
   - TV/Radio Service

6. **Monitoring**
   - Prometheus
   - Grafana

### Resource Allocation
```yaml
# Production resource limits
services:
  postgres:
    memory: 4GB
    cpus: 2
  
  redis:
    memory: 2GB
    cpus: 1
  
  frontend:
    memory: 1GB
    cpus: 1
  
  # Each microservice: 512MB-1GB
```

## 🔒 SSL/TLS Configuration

### Automatic SSL Setup
```bash
# Run SSL setup script
chmod +x scripts/setup-ssl.sh
./scripts/setup-ssl.sh
```

### Manual SSL Configuration
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificates
sudo certbot --nginx -d nexuscos.online -d *.nexuscos.online

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 📱 Mobile App Deployment

### EAS CLI Setup
```bash
# Install EAS CLI
npm install -g @expo/cli eas-cli

# Login to Expo
expo login

# Configure EAS
cd mobile
eas build:configure
```

### Build and Deploy
```bash
# Development build
eas build --platform all --profile preview

# Production build
eas build --platform all --profile production

# Submit to app stores
eas submit --platform all --profile production
```

## 🔍 Monitoring & Health Checks

### Automated Health Checks
```bash
# Run comprehensive health check
chmod +x scripts/health-check.sh
./scripts/health-check.sh -d nexuscos.online
```

### Monitoring Dashboard
- **Grafana**: https://nexuscos.online/grafana
- **Prometheus**: https://nexuscos.online/prometheus
- **Default Login**: admin/admin (change on first login)

### Key Metrics
- Service uptime and response times
- Database performance
- Memory and CPU usage
- SSL certificate expiration
- Container health status

## 🚀 Deployment Modes

### Full Deployment
```bash
./deploy-nexus-cos.sh
```

### Services Only
```bash
DEPLOY_MODE=services ./deploy-nexus-cos.sh
```

### Infrastructure Only
```bash
DEPLOY_MODE=infrastructure ./deploy-nexus-cos.sh
```

### Skip Mobile
```bash
SKIP_MOBILE=true ./deploy-nexus-cos.sh
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow
The repository includes automated CI/CD with:

- **Testing**: Unit tests, integration tests, security scans
- **Building**: Docker images, mobile apps
- **Deployment**: Staging and production environments
- **Monitoring**: Performance tests, health checks

### Required Secrets
```bash
# Server Access
PRODUCTION_HOST=your.server.ip
PRODUCTION_USER=deploy
PRODUCTION_SSH_KEY=your_private_key

# Docker Registry
DOCKER_USERNAME=your_docker_username
DOCKER_PASSWORD=your_docker_password

# SSL Configuration
SSL_EMAIL=admin@nexuscos.online

# Mobile App
EXPO_TOKEN=your_expo_token
EXPO_APPLE_ID=your_apple_id
EXPO_ASC_APP_ID=your_app_store_connect_id

# Notifications
SLACK_WEBHOOK=your_slack_webhook_url
```

## 🛠️ Troubleshooting

### Common Issues

#### Service Won't Start
```bash
# Check service logs
docker-compose logs service_name

# Restart specific service
docker-compose restart service_name

# Rebuild service
docker-compose up --build service_name
```

#### Database Connection Issues
```bash
# Check database status
docker-compose exec postgres pg_isready

# Reset database
docker-compose down -v
docker-compose up postgres
```

#### SSL Certificate Issues
```bash
# Check certificate status
sudo certbot certificates

# Renew certificates
sudo certbot renew --force-renewal

# Restart Nginx
docker-compose restart nginx
```

#### Mobile Build Failures
```bash
# Clear Expo cache
expo r -c

# Check EAS build status
eas build:list

# View build logs
eas build:view BUILD_ID
```

### Performance Optimization

#### Database Tuning
```sql
-- PostgreSQL optimization
ALTER SYSTEM SET shared_buffers = '1GB';
ALTER SYSTEM SET effective_cache_size = '3GB';
ALTER SYSTEM SET maintenance_work_mem = '256MB';
SELECT pg_reload_conf();
```

#### Redis Optimization
```bash
# Redis configuration
echo "maxmemory 2gb" >> /etc/redis/redis.conf
echo "maxmemory-policy allkeys-lru" >> /etc/redis/redis.conf
```

## 📊 Backup & Recovery

### Automated Backups
```bash
# Database backup
docker-compose exec postgres pg_dump -U $POSTGRES_USER $POSTGRES_DB > backup.sql

# Full system backup
tar -czf nexus-cos-backup-$(date +%Y%m%d).tar.gz \
  --exclude="logs" --exclude="node_modules" .
```

### Recovery Process
```bash
# Restore database
docker-compose exec -T postgres psql -U $POSTGRES_USER $POSTGRES_DB < backup.sql

# Restore system
tar -xzf nexus-cos-backup-YYYYMMDD.tar.gz
./deploy-nexus-cos.sh
```

## 🔐 Security Considerations

### Network Security
- All services run on internal Docker network
- Only Nginx exposed to public internet
- Database and Redis bound to localhost
- SSL/TLS encryption for all external traffic

### Application Security
- JWT token authentication
- Rate limiting on API endpoints
- Input validation and sanitization
- Regular security updates

### Monitoring Security
- Failed login attempt tracking
- Unusual traffic pattern detection
- SSL certificate monitoring
- Vulnerability scanning

## 📞 Support

### Documentation
- [API Documentation](https://nexuscos.online/docs)
- [User Guide](https://nexuscos.online/guide)
- [Developer Documentation](https://nexuscos.online/dev-docs)

### Contact
- **Email**: support@nexuscos.online
- **Discord**: [Nexus COS Community](https://discord.gg/nexuscos)
- **GitHub Issues**: [Report Issues](https://github.com/your-org/nexus-cos-extended/issues)

### Emergency Contacts
- **Production Issues**: emergency@nexuscos.online
- **Security Issues**: security@nexuscos.online
- **On-Call**: +1-XXX-XXX-XXXX

---

## 📝 Changelog

### v2.0.0 - Extended Release
- Added V-Suite integration
- Implemented PUABO OS 2025
- Enhanced mobile application
- Added comprehensive monitoring
- Improved security features

### v1.5.0 - Production Ready
- SSL/TLS implementation
- Docker production optimization
- CI/CD pipeline
- Health monitoring

### v1.0.0 - Initial Release
- Core Nexus COS functionality
- Basic Docker setup
- Frontend and backend services

---

*Last updated: $(date)*
*Version: 2.0.0*