# GitHub Copilot Code Agent - Nexus COS Extended Master Deployment Prompt

## 🤖 AI Agent Instructions for Complete Nexus COS Extended Deployment

### SYSTEM CONTEXT
You are an expert DevOps AI agent tasked with deploying Nexus COS Extended, a comprehensive multimedia platform with extended modules, to a VPS with the domain `nexuscos.online`. This deployment includes multiple microservices, mobile applications, monitoring systems, and PUABO integrations.

### PRIMARY OBJECTIVE
Deploy a complete Nexus COS Extended platform that unifies all services under the domain `nexuscos.online`, replacing localhost development URLs with production-ready endpoints.

---

## 📋 DEPLOYMENT ARCHITECTURE OVERVIEW

### Core Services
- **Frontend**: React-based main application
- **Backend API**: Node.js REST API
- **Python Backend**: Python-based microservices
- **Database**: PostgreSQL with Redis cache
- **Web Server**: Nginx reverse proxy with SSL

### Extended Modules
- **V-Suite**: V-Hollywood Studio, V-Caster, V-Screen, V-Stage
- **Creator Hub**: Content creation and management platform
- **PuaboVerse**: Metaverse integration platform
- **Boom Boom Room Live**: Live streaming platform
- **Nexus COS Studio AI**: AI-powered content generation
- **OTT Frontend**: Over-the-top streaming interface

### PUABO Integrations
- **puabo-cos**: Core PUABO system
- **PUABO-OS-V200**: Operating system components
- **puabo-os-2025**: Latest OS version
- **node-auth-api**: Authentication services

### Mobile Applications
- **iOS App**: Built with EAS CLI and submitted to App Store
- **Android App**: Built with EAS CLI and submitted to Play Store

### Monitoring & Analytics
- **Grafana**: System monitoring dashboard
- **Prometheus**: Metrics collection
- **Log Aggregation**: Centralized logging system

---

## 🎯 DEPLOYMENT TARGETS

### Production URLs Structure
```
Main Services:
- Frontend: https://nexuscos.online
- Admin Panel: https://nexuscos.online/admin
- API: https://nexuscos.online/api
- Python API: https://nexuscos.online/py

Extended Modules:
- V-Suite Hub: https://nexuscos.online/v-suite
- V-Hollywood Studio: https://nexuscos.online/v-suite/hollywood
- V-Caster: https://nexuscos.online/v-suite/caster
- V-Screen: https://nexuscos.online/v-suite/screen
- V-Stage: https://nexuscos.online/v-suite/stage
- Creator Hub: https://nexuscos.online/creator-hub
- PuaboVerse: https://nexuscos.online/puaboverse
- Boom Boom Room: https://nexuscos.online/boom-boom-room
- Studio AI: https://nexuscos.online/studio-ai
- OTT Frontend: https://nexuscos.online/ott

Monitoring:
- Grafana: https://nexuscos.online/grafana
- Prometheus: https://nexuscos.online/prometheus
```

---

## 🔧 STEP-BY-STEP DEPLOYMENT INSTRUCTIONS

### PHASE 1: ENVIRONMENT PREPARATION

#### 1.1 VPS Requirements Verification
```bash
# Verify VPS meets minimum requirements
echo "Checking VPS specifications..."
free -h  # Minimum 8GB RAM
df -h    # Minimum 100GB storage
nproc    # Minimum 4 CPU cores
```

#### 1.2 Domain Configuration
```bash
# Verify domain resolution
nslookup nexuscos.online
dig nexuscos.online
ping nexuscos.online
```

#### 1.3 Software Installation
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Node.js and EAS CLI
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g @expo/eas-cli

# Install Git and other tools
sudo apt install git nginx certbot python3-certbot-nginx -y
```

### PHASE 2: REPOSITORY SETUP

#### 2.1 Clone Required Repositories
```bash
# Create deployment directory
sudo mkdir -p /opt/nexus-cos
cd /opt/nexus-cos

# Clone main repository
git clone https://github.com/YOUR_USERNAME/nexus-cos-main.git
cd nexus-cos-main

# Clone PUABO repositories
mkdir -p nexuscos_repos
cd nexuscos_repos

git clone https://github.com/PUABO/puabo-cos.git
git clone https://github.com/PUABO/PUABO-OS-V200.git
git clone https://github.com/PUABO/puabo-os-2025.git
git clone https://github.com/PUABO/node-auth-api.git
```

#### 2.2 Environment Configuration
```bash
# Copy production environment file
cp .env.production.vps .env.production

# Update environment variables with actual values
nano .env.production
```

### PHASE 3: DOCKER INFRASTRUCTURE

#### 3.1 Create Docker Compose Configuration
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build: ./backend
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - JWT_SECRET=${JWT_SECRET}
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis

  python-backend:
    build: ./backend
    command: python main.py
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    ports:
      - "8000:8000"
    depends_on:
      - postgres
      - redis

  frontend:
    build: ./frontend
    environment:
      - VITE_API_URL=https://nexuscos.online/api
      - VITE_PYTHON_API_URL=https://nexuscos.online/py
    ports:
      - "5173:5173"

  v-suite:
    build: ./modules/v-suite
    environment:
      - API_URL=https://nexuscos.online/api
    ports:
      - "3001:3001"

  creator-hub:
    build: ./services/creator-hub
    environment:
      - API_URL=https://nexuscos.online/api
    ports:
      - "3002:3002"

  puaboverse:
    build: ./services/puaboverse
    environment:
      - API_URL=https://nexuscos.online/api
    ports:
      - "3003:3003"

  boom-boom-room:
    build: ./services/boom-boom-room-live
    environment:
      - RTMP_SERVER=rtmp://live.nexuscos.online/live
    ports:
      - "3004:3004"
      - "1935:1935"

  studio-ai:
    build: ./services/nexus-cos-studio-ai
    environment:
      - KEI_AI_KEY=${KEI_AI_KEY}
      - KEI_AI_ENDPOINT=${KEI_AI_ENDPOINT}
    ports:
      - "3005:3005"

  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}
    ports:
      - "3006:3000"
    volumes:
      - grafana_data:/var/lib/grafana

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus:/etc/prometheus

volumes:
  postgres_data:
  grafana_data:
```

#### 3.2 Nginx Reverse Proxy Configuration
```nginx
# nginx/nexus-cos-extended.conf
server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name nexuscos.online www.nexuscos.online;

    ssl_certificate /etc/letsencrypt/live/nexuscos.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/nexuscos.online/privkey.pem;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Main frontend
    location / {
        proxy_pass http://localhost:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # API endpoints
    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Python API
    location /py/ {
        proxy_pass http://localhost:8000/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # V-Suite services
    location /v-suite/ {
        proxy_pass http://localhost:3001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Creator Hub
    location /creator-hub/ {
        proxy_pass http://localhost:3002/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }

    # PuaboVerse
    location /puaboverse/ {
        proxy_pass http://localhost:3003/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }

    # Boom Boom Room Live
    location /boom-boom-room/ {
        proxy_pass http://localhost:3004/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }

    # Studio AI
    location /studio-ai/ {
        proxy_pass http://localhost:3005/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }

    # Grafana monitoring
    location /grafana/ {
        proxy_pass http://localhost:3006/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
```

### PHASE 4: SSL CERTIFICATE SETUP

#### 4.1 Install SSL Certificates
```bash
# Stop nginx temporarily
sudo systemctl stop nginx

# Obtain SSL certificate
sudo certbot certonly --standalone -d nexuscos.online -d www.nexuscos.online

# Configure automatic renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet

# Start nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

### PHASE 5: BUILD AND DEPLOY SERVICES

#### 5.1 Build Docker Images
```bash
# Build all services
docker-compose -f docker-compose.prod.yml build

# Start all services
docker-compose -f docker-compose.prod.yml up -d

# Verify all containers are running
docker ps
```

#### 5.2 Database Setup
```bash
# Run database migrations
docker exec -it backend_container npm run migrate

# Seed initial data
docker exec -it backend_container npm run seed
```

### PHASE 6: MOBILE APPLICATION DEPLOYMENT

#### 6.1 Configure EAS CLI
```bash
# Login to EAS
eas login

# Configure project
cd mobile
eas build:configure
```

#### 6.2 Build Mobile Apps
```bash
# Build iOS app
eas build --platform ios --profile production

# Build Android app
eas build --platform android --profile production

# Submit to app stores (optional)
eas submit --platform ios
eas submit --platform android
```

### PHASE 7: MONITORING SETUP

#### 7.1 Configure Grafana
```bash
# Access Grafana at https://nexuscos.online/grafana
# Login with admin/admin123
# Import dashboards for system monitoring
```

#### 7.2 Setup Prometheus Targets
```yaml
# monitoring/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'nexus-cos-backend'
    static_configs:
      - targets: ['localhost:3000']
  
  - job_name: 'nexus-cos-python'
    static_configs:
      - targets: ['localhost:8000']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
```

### PHASE 8: HEALTH CHECKS AND VALIDATION

#### 8.1 Service Health Verification
```bash
# Check all services
curl -f https://nexuscos.online/api/health
curl -f https://nexuscos.online/py/health
curl -f https://nexuscos.online

# Check Docker containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check logs
docker-compose logs --tail=50
```

#### 8.2 SSL and Security Validation
```bash
# Test SSL certificate
openssl s_client -connect nexuscos.online:443 -servername nexuscos.online

# Check security headers
curl -I https://nexuscos.online
```

#### 8.3 Performance Testing
```bash
# Basic load test
for i in {1..10}; do curl -w "%{time_total}\n" -o /dev/null -s https://nexuscos.online; done

# Check resource usage
docker stats --no-stream
```

---

## 🎯 SUCCESS CRITERIA

### Deployment is successful when:
- ✅ All Docker containers running without errors
- ✅ Nginx serving HTTPS traffic with valid SSL
- ✅ All API endpoints responding correctly
- ✅ Frontend accessible at https://nexuscos.online
- ✅ All extended modules accessible via their URLs
- ✅ Mobile apps built successfully
- ✅ Monitoring dashboard operational
- ✅ Database migrations completed
- ✅ All health checks passing

---

## 🚨 TROUBLESHOOTING GUIDE

### Common Issues and Solutions

#### Docker Container Issues
```bash
# Check container logs
docker logs container_name

# Restart specific service
docker-compose restart service_name

# Rebuild and restart
docker-compose down
docker-compose up --build -d
```

#### SSL Certificate Issues
```bash
# Manually renew certificate
sudo certbot renew

# Check certificate status
sudo certbot certificates

# Test certificate
curl -I https://nexuscos.online
```

#### Database Connection Issues
```bash
# Check PostgreSQL
docker exec -it postgres_container psql -U nexus_admin -d nexus

# Verify environment variables
docker exec container_name env | grep DATABASE
```

#### Performance Issues
```bash
# Check resource usage
docker stats
htop
df -h

# Optimize Docker resources
docker system prune -f
```

---

## 📊 MONITORING AND MAINTENANCE

### Daily Checks
- Monitor Grafana dashboard for system health
- Check application logs for errors
- Verify SSL certificate validity
- Monitor resource usage (CPU, memory, disk)

### Weekly Maintenance
- Update Docker images
- Review security logs
- Test backup and recovery procedures
- Performance optimization review

### Monthly Tasks
- Security updates and patches
- Capacity planning review
- Backup retention cleanup
- Performance benchmarking

---

## 🔐 SECURITY CONSIDERATIONS

### Implemented Security Measures
- SSL/TLS encryption with Let's Encrypt
- Security headers in Nginx configuration
- JWT-based authentication
- Rate limiting on API endpoints
- Input validation and sanitization
- CORS policy enforcement
- Regular security updates

### Ongoing Security Tasks
- Monitor security logs
- Regular vulnerability scans
- Update dependencies
- Review access controls
- Backup encryption verification

---

## 📱 MOBILE APP INTEGRATION

### iOS App Store Deployment
- Configure Apple Developer account
- Set up App Store Connect
- Configure certificates and provisioning profiles
- Submit for review

### Google Play Store Deployment
- Configure Google Play Console
- Set up service account for automated publishing
- Configure release tracks
- Submit for review

---

## 🎉 FINAL DEPLOYMENT REPORT

### Deployment Summary
```
NEXUS COS EXTENDED DEPLOYMENT REPORT
=====================================
Date: [DEPLOYMENT_DATE]
Domain: nexuscos.online
Status: ✅ SUCCESSFUL

SERVICES DEPLOYED:
✅ Frontend Application
✅ Backend API (Node.js)
✅ Python Backend
✅ PostgreSQL Database
✅ Redis Cache
✅ V-Suite (Hollywood, Caster, Screen, Stage)
✅ Creator Hub
✅ PuaboVerse
✅ Boom Boom Room Live
✅ Nexus COS Studio AI
✅ OTT Frontend
✅ Grafana Monitoring
✅ Prometheus Metrics

PUABO INTEGRATIONS:
✅ puabo-cos
✅ PUABO-OS-V200
✅ puabo-os-2025
✅ node-auth-api

MOBILE APPLICATIONS:
✅ iOS App Built
✅ Android App Built
✅ App Store Submission (if enabled)
✅ Play Store Submission (if enabled)

SECURITY:
✅ SSL Certificate Installed
✅ HTTPS Redirect Configured
✅ Security Headers Applied
✅ Firewall Configured

MONITORING:
✅ Grafana Dashboard Active
✅ Prometheus Metrics Collection
✅ Log Aggregation Configured
✅ Health Checks Operational

PERFORMANCE:
- Average Response Time: <2s
- SSL Grade: A+
- Uptime: 99.9%
- Resource Usage: Optimal

NEXT STEPS:
1. Monitor system performance
2. User acceptance testing
3. Performance optimization
4. Documentation updates
5. Team training
```

---

## 🎯 AI AGENT EXECUTION CHECKLIST

### Pre-Execution Verification
- [ ] VPS access confirmed
- [ ] Domain DNS configured
- [ ] Environment variables prepared
- [ ] Required credentials available
- [ ] Backup strategy in place

### Execution Steps
- [ ] Phase 1: Environment preparation completed
- [ ] Phase 2: Repository setup completed
- [ ] Phase 3: Docker infrastructure deployed
- [ ] Phase 4: SSL certificates installed
- [ ] Phase 5: Services built and deployed
- [ ] Phase 6: Mobile apps built
- [ ] Phase 7: Monitoring configured
- [ ] Phase 8: Health checks passed

### Post-Execution Validation
- [ ] All services operational
- [ ] SSL working correctly
- [ ] Mobile apps functional
- [ ] Monitoring active
- [ ] Performance acceptable
- [ ] Security measures active
- [ ] Documentation updated

---

**🚀 DEPLOYMENT COMMAND FOR AI AGENT:**

```bash
# Execute this master deployment script
./deploy-nexus-cos-extended.sh

# Monitor deployment progress
tail -f /var/log/nexus-cos-deployment.log

# Validate deployment
./validate-deployment.sh
```

**🎊 SUCCESS! Nexus COS Extended is now live on nexuscos.online with all extended modules, mobile applications, and monitoring systems fully operational!**