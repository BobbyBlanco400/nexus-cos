# Nexus COS - Complete Operating System

![TRAE Solo Compatible](https://img.shields.io/badge/TRAE%20Solo-Compatible-green)
![Node.js](https://img.shields.io/badge/Node.js-20.x-blue)
![Python](https://img.shields.io/badge/Python-3.12-blue)
![React](https://img.shields.io/badge/React-18.x-blue)

A complete operating system implementation with multi-platform support, now fully migrated to **TRAE Solo** orchestration.

## 🎨 Project Assets

### SVG Logo File

The project includes a custom SVG logo file located at `./file (1).svg` in the root directory. This scalable vector graphic represents the Nexus COS brand and system architecture.

**File Details:**
- **Filename**: `file (1).svg`
- **Path**: `./file (1).svg`
- **Format**: Scalable Vector Graphics (SVG)
- **Dimensions**: 200x200 pixels (scalable)

#### Usage Instructions

You can use this SVG file in your projects in several ways:

**In HTML:**
```html
<!-- Direct embedding -->
<img src="./file (1).svg" alt="Nexus COS Logo" width="100" height="100">

<!-- Inline SVG (copy content from file) -->
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 200 200">
  <!-- SVG content here -->
</svg>

<!-- As background image in CSS -->
<div style="background-image: url('./file (1).svg'); width: 100px; height: 100px;"></div>
```

**In Markdown:**
```markdown
![Nexus COS Logo](./file%20(1).svg)

<!-- With custom size using HTML in Markdown -->
<img src="./file (1).svg" alt="Nexus COS Logo" width="150">
```

**In React/JSX:**
```jsx
// As an image
<img src="./file (1).svg" alt="Nexus COS Logo" className="logo" />

// Import as component (with proper SVG loader)
import NexusLogo from './file (1).svg';
<NexusLogo width={100} height={100} />
```

## 🚀 TRAE Solo Migration Complete

Nexus COS has been successfully migrated to TRAE Solo for enhanced deployment orchestration, service management, and scalability.

### What is TRAE Solo?

TRAE Solo is an advanced deployment orchestrator that provides:
- 🔄 **Service Orchestration**: Automated service lifecycle management
- 🏥 **Health Monitoring**: Real-time health checks and auto-recovery
- 🔧 **Configuration Management**: Centralized environment and service configuration
- 📊 **Load Balancing**: Intelligent traffic distribution and SSL termination
- 🐳 **Container-Ready**: Docker-compatible deployment pipeline

## 📋 Architecture Overview

### Services
- **Node.js Backend** (TypeScript) - Port 3000
- **Python Backend** (FastAPI) - Port 3001
- **React Frontend** (Vite) - Nginx served
- **PostgreSQL Database** - Port 5432
- **Mobile Apps** (React Native/Expo)

### TRAE Solo Configuration Files
- `trae-solo.yaml` - Main orchestration configuration
- `.trae/environment.env` - Environment variables
- `.trae/services.yaml` - Service definitions
- `deploy-trae-solo.sh` - Deployment automation

## 🛠️ Setup and Installation

### Prerequisites
- Node.js 20.x or higher
- Python 3.12 or higher
- Docker (for TRAE Solo deployment)
- pnpm (recommended) or npm

### Quick Start with TRAE Solo

1. **Clone the repository**
   ```bash
   git clone https://github.com/BobbyBlanco400/nexus-cos.git
   cd nexus-cos
   ```

2. **Install dependencies**
   ```bash
   # Install all workspace dependencies
   npm install

   # Or use TRAE Solo deployment script
   ./deploy-trae-solo.sh
   ```

3. **Configure environment**
   ```bash
   # Copy and edit environment configuration
   cp .trae/environment.env .env
   # Edit .env with your specific values
   ```

4. **Deploy with TRAE Solo**
   ```bash
   # Option 1: Use the deployment script
   ./deploy-trae-solo.sh

   # Option 2: Use npm scripts
   npm run trae:deploy

   # Option 3: Manual TRAE Solo commands
   npm run trae:init
   npm run trae:start
   ```

## 🚀 Pre-Flight (PF) Production Deployment

> ✨ **NEW: Enhanced Production One-Liner Deployment Available!**

### ⚡ Fastest Deployment: One-Liner Command

Deploy from anywhere with a single command (~2 minutes):

```bash
./scripts/deploy-one-liner.sh
```

Or use the direct one-liner:

```bash
ssh -o StrictHostKeyChecking=no root@74.208.155.161 "cd /opt/nexus-cos && git pull origin main && cp .env.pf .env && docker compose -f docker-compose.pf.yml down && docker compose -f docker-compose.pf.yml up -d --build --remove-orphans && sleep 15 && for p in 4000 3002 3041; do echo \"Testing port \${p}...\" && curl -fsS http://localhost:\${p}/health || { echo \"PORT_\${p}_FAILED\"; exit 1; }; done && echo \"Local health checks passed\" && curl -fsS https://nexuscos.online/v-suite/prompter/health && echo \"✅ PF_DEPLOY_SUCCESS - All systems operational\" || { echo \"❌ DEPLOYMENT_FAILED - Collecting diagnostics...\"; docker compose -f docker-compose.pf.yml ps; echo \"--- Gateway API Logs ---\"; docker logs --tail 200 puabo-api; echo \"--- PV Keys Logs ---\"; docker logs --tail 200 nexus-cos-pv-keys; echo \"--- AI SDK Logs ---\"; docker logs --tail 200 nexus-cos-puaboai-sdk; exit 1; }"
```

**What it does:**
- ✅ Updates code from repository
- ✅ Configures environment
- ✅ Builds and deploys all services
- ✅ Validates health endpoints (ports 4000, 3002, 3041)
- ✅ Tests production URL
- ✅ Auto-diagnostics on failure

**See:** [QUICK_DEPLOY_ONE_LINER.md](./QUICK_DEPLOY_ONE_LINER.md) | [Full Documentation](./DEPLOYMENT_ONE_LINER.md)

### 🔧 Alternative: Comprehensive Deployment Script

For step-by-step deployment with detailed reporting:

```bash
# SSH to your VPS
ssh root@74.208.155.161

# Navigate to repository
cd /opt/nexus-cos

# Run the comprehensive deployment script
./scripts/pf-final-deploy.sh
```

**What it does:**
1. ✅ Complete system requirements validation (Docker, Nginx, ports)
2. ✅ Repository and file structure verification
3. ✅ Automated SSL certificate management and validation
4. ✅ Environment configuration from `.env.pf`
5. ✅ Full Docker service stack deployment
6. ✅ Nginx configuration and reload
7. ✅ Post-deployment health checks
8. ✅ Detailed deployment summary and next steps

### PF Assets Documentation

**📚 Essential PF Resources:**

1. **PF Assets Locked Manifest** - `docs/PF_ASSETS_LOCKED_2025-10-03T14-46Z.md`
   - Single source of truth for all PF assets, paths, and configurations
   - V-Prompter Pro routing details (locked configuration)
   - SSL canonical paths and validation procedures
   - Complete deployment sequence

2. **System Check & Re-deployment Guide** - `PF_SYSTEM_CHECK_AND_REDEPLOY_GUIDE.md`
   - Step-by-step deployment instructions
   - Troubleshooting for 10+ common issues
   - Validation procedures and success criteria
   - Quick reference commands

3. **PF Final Deployment Script** - `scripts/pf-final-deploy.sh`
   - Automated deployment with validation
   - Interactive prompts for configuration
   - Comprehensive error checking and reporting

**Key V-Prompter Pro Configuration:**
- **Public Route:** `/v-suite/prompter/`
- **Health Endpoint:** `https://nexuscos.online/v-suite/prompter/health`
- **Backend:** nexus-cos-puaboai-sdk (port 3002)
- **Expected Response:** 200 OK

**SSL Certificate Paths (Canonical):**
```
Certificate: /opt/nexus-cos/ssl/nexus-cos.crt (644)
Private Key: /opt/nexus-cos/ssl/nexus-cos.key (600)
```

## 🐳 Docker-Based Production Launch

> 📖 **For comprehensive VPS deployment guide with troubleshooting and recovery procedures, see [BETA_LAUNCH_READINESS_COMPREHENSIVE.md](./BETA_LAUNCH_READINESS_COMPREHENSIVE.md)**

### Interactive One-Liner Deployment

The fastest way to deploy Nexus COS with automated validation:

```bash
echo "Choose Nginx mode: [1] Docker [2] Host"; read mode; if [ "$mode" = "1" ]; then sudo cp nginx.conf.docker /etc/nginx/nginx.conf; else sudo cp nginx.conf.host /etc/nginx/nginx.conf; fi && git stash && git pull origin main && sudo cp nginx/conf.d/nexus-proxy.conf /etc/nginx/conf.d/ && sudo nginx -t && sudo nginx -s reload && [ -f test-pf-configuration.sh ] && chmod +x test-pf-configuration.sh && ./test-pf-configuration.sh && for url in /api /admin /v-suite/prompter /health /health/gateway /health/puaboai-sdk /health/pv-keys; do curl -I https://nexuscos.online$url; done
```

**What it does:**
1. Prompts for Nginx deployment mode (Docker container or Host)
2. Copies appropriate nginx configuration
3. Updates from git repository
4. Installs proxy configuration
5. Validates nginx configuration
6. Reloads nginx with zero downtime
7. Runs comprehensive validation tests
8. Tests all critical endpoints

### Docker Mode Deployment (Recommended)

**Prerequisites:**
- Docker and Docker Compose installed
- `.env.pf` file configured (copy from `.env.pf.example`)
- SSL certificates in `./ssl/` directory

**Step-by-step deployment:**

```bash
# 1. Configure environment
cp .env.pf.example .env.pf
# Edit .env.pf with your secure credentials

# 2. Start all backend services
docker compose -f docker-compose.pf.yml up -d

# 3. Optionally start Nginx as a container
docker compose -f docker-compose.pf.yml --profile docker-nginx up -d

# 4. Verify services are running
docker ps

# 5. Check service health
curl http://localhost:4000/health  # Gateway
curl http://localhost:3002/health  # AI SDK
curl http://localhost:3041/health  # Keys Service

# 6. Run validation
./test-pf-configuration.sh

# 7. Test production endpoints
curl -I https://nexuscos.online/health
```

### Network Architecture

All services communicate via the `cos-net` Docker network:

```
┌─────────────────────────────────────────────┐
│           cos-net (Docker Network)          │
│                                             │
│  ┌─────────┐    ┌──────────────────────┐  │
│  │  Nginx  │───▶│   puabo-api:4000     │  │
│  │ Gateway │    │   (Main API)         │  │
│  └─────────┘    └──────────────────────┘  │
│       │                                     │
│       ├────────▶┌──────────────────────┐  │
│       │         │ nexus-cos-puaboai-sdk│  │
│       │         │      :3002           │  │
│       │         └──────────────────────┘  │
│       │                                     │
│       └────────▶┌──────────────────────┐  │
│                 │ nexus-cos-pv-keys    │  │
│                 │      :3041           │  │
│                 └──────────────────────┘  │
│                                             │
│  ┌──────────────────────────────────────┐ │
│  │  nexus-cos-postgres:5432             │ │
│  │  nexus-cos-redis:6379                │ │
│  └──────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

### Configuration Files

**Nginx Configurations:**
- `nginx.conf.docker` - For Nginx running in Docker container (uses service names)
- `nginx.conf.host` - For Nginx running on host OS (uses localhost:port)
- `nginx/nginx.conf` - Main gateway configuration template
- `nginx/conf.d/nexus-proxy.conf` - Route mappings

**Service Orchestration:**
- `docker-compose.yml` - Main service composition
- `docker-compose.pf.yml` - PF (Platform Framework) services with full stack
- `docker-compose.nginx.yml` - Standalone Nginx deployment

**Environment Configuration:**
- `.env.pf.example` - Template for PF environment variables
- `.env.example` - Template for general environment variables
- Create `.env.pf` from example with your secure credentials

### Deployment Modes

#### 1. Docker Mode (Container Nginx)
**Best for:** Production, containerized environments, cloud deployments

```bash
# Start with Nginx in container
docker compose -f docker-compose.pf.yml --profile docker-nginx up -d

# Nginx uses Docker service names internally:
# - puabo-api:4000
# - nexus-cos-puaboai-sdk:3002
# - nexus-cos-pv-keys:3041
```

#### 2. Host Mode (Host Nginx)
**Best for:** Existing Nginx installations, custom modules, development

```bash
# Start backend services only
docker compose -f docker-compose.pf.yml up -d

# Configure host Nginx
sudo cp nginx.conf.host /etc/nginx/nginx.conf
sudo cp nginx/conf.d/nexus-proxy.conf /etc/nginx/conf.d/
sudo nginx -t && sudo nginx -s reload

# Nginx uses localhost with exposed ports:
# - localhost:4000
# - localhost:3002
# - localhost:3041
```

### Validation & Health Checks

**Automated Validation:**
```bash
# Comprehensive configuration tests
./test-pf-configuration.sh

# Nginx configuration validation
./validate-pf-nginx.sh

# Launch readiness check
./nexus-cos-launch-validator.sh
```

**Manual Health Checks:**
```bash
# Check Docker services
docker ps
docker compose -f docker-compose.pf.yml logs -f

# Test backend health endpoints
curl http://localhost:4000/health
curl http://localhost:3002/health
curl http://localhost:3041/health

# Test production endpoints
curl -I https://nexuscos.online/api
curl -I https://nexuscos.online/health
curl -I https://nexuscos.online/admin
```

### Troubleshooting

**502 Bad Gateway:**
```bash
# Check if services are running
docker ps

# Check service logs
docker logs puabo-api
docker logs nexus-cos-puaboai-sdk

# Verify network connectivity
docker network inspect cos-net

# Test direct service access
docker exec puabo-api curl localhost:4000/health
```

**Configuration Issues:**
```bash
# Test Nginx configuration
sudo nginx -t

# View Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Check file permissions
ls -la nginx.conf.docker nginx.conf.host
```

**Environment Variables:**
```bash
# Verify .env.pf exists and has correct values
cat .env.pf

# Check if environment is loaded in container
docker exec puabo-api env | grep DB_
```

### Security Best Practices

✅ **Implemented:**
- Environment variables for all secrets (no hardcoded credentials)
- `.env` files in `.gitignore`
- SSL/TLS with modern ciphers (TLS 1.2, 1.3)
- Security headers (HSTS, CSP, X-Frame-Options, etc.)
- OCSP stapling enabled
- Health check endpoints protected

📋 **Checklist before launch:**
- [ ] `.env.pf` configured with secure credentials
- [ ] SSL certificates installed in `./ssl/` directory
- [ ] All services pass health checks
- [ ] Nginx configuration validated (`nginx -t`)
- [ ] No secrets in git repository
- [ ] Firewall configured (ports 80, 443, 22)
- [ ] Database backups configured
- [ ] Monitoring and logging active

### Documentation

For detailed deployment instructions, see:
- **[NGINX_CONFIGURATION_README.md](./NGINX_CONFIGURATION_README.md)** - Complete Nginx deployment guide
- **[PF_TRAE_Beta_Launch_Validation.md](./PF_TRAE_Beta_Launch_Validation.md)** - Beta launch checklist
- **[PF_CONFIGURATION_SUMMARY.md](./PF_CONFIGURATION_SUMMARY.md)** - PF architecture summary
- **[PF_DEPLOYMENT_CHECKLIST.md](./PF_DEPLOYMENT_CHECKLIST.md)** - Deployment verification

## 🔧 Development Setup

### Backend Development

#### Node.js Backend
```bash
cd backend
npm install
npm run dev
# Health check: http://localhost:3000/health
```

#### Python Backend
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 3001 --reload
# Health check: http://localhost:3001/health
```

### Frontend Development
```bash
cd frontend
npm install
npm run dev
# Development server: http://localhost:5173
```

### Mobile Development
```bash
cd mobile
npm install
# Android: npm run android
# iOS: npm run ios
```

## 🌐 TRAE Solo Deployment

### Production Deployment

1. **Configure SSL/Domain**
   ```bash
   # Edit .trae/environment.env
   SSL_EMAIL=your-email@domain.com
   # Update domain in trae-solo.yaml
   ```

2. **Deploy to production**
   ```bash
   # Full deployment with SSL
   npm run trae:deploy

   # Check deployment status
   npm run trae:status
   ```

3. **Monitor services**
   ```bash
   # View logs
   npm run trae:logs

   # Check health
   npm run trae:health
   ```

### Service Management

```bash
# Start all services
npm run trae:start

# Stop all services
npm run trae:stop

# Restart specific service
trae solo restart backend-node

# Scale service
trae solo scale backend-node 3
```

## 📊 Health Checks and Monitoring

TRAE Solo provides built-in monitoring:

### Health Endpoints
- **Node.js Backend**: `/health` → `{"status":"ok"}`
- **Python Backend**: `/health` → `{"status":"ok"}`
- **Database**: PostgreSQL connection check
- **Frontend**: Static file serving verification

### Monitoring Features
- **Prometheus Metrics**: Available at `/metrics`
- **Health Check Interval**: 30 seconds
- **Auto-Recovery**: Failed services automatically restart
- **Log Aggregation**: Centralized logging with JSON format

## 🔗 API Endpoints

### Node.js Backend (Port 3000)
- `GET /health` - Health check
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/forgot-password` - Password reset request
- `POST /api/auth/reset-password` - Password reset

### Python Backend (Port 3001)
- `GET /health` - Health check
- `GET /api/` - API root
- Additional FastAPI endpoints as needed

### Production URLs (via TRAE Solo)
- **Frontend**: `https://nexuscos.online`
- **Node.js API**: `https://nexuscos.online/api/node/`
- **Python API**: `https://nexuscos.online/api/python/`

## 🏗️ Build and Deployment

### Frontend Build
```bash
cd frontend
npm run build
# Output: frontend/dist/
```

### Mobile Builds
```bash
cd mobile
./build-mobile.sh
# Android APK: mobile/builds/android/app.apk
# iOS IPA: mobile/builds/ios/app.ipa
```

### Docker Deployment (TRAE Solo)
```bash
# Build and deploy all services
docker-compose -f .trae/services.yaml up -d

# Or use TRAE Solo orchestration
npm run trae:deploy
```

## 🔐 Security Configuration

### SSL/TLS with TRAE Solo
- **Automatic SSL**: Let's Encrypt integration
- **Security Headers**: HSTS, CSP, X-Frame-Options
- **Rate Limiting**: Built-in DDoS protection
- **Health Checks**: Secure endpoint monitoring

### Environment Variables
```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/nexus_cos

# Security
JWT_SECRET=your-secure-jwt-secret
BCRYPT_ROUNDS=12

# SSL
SSL_EMAIL=admin@nexuscos.online
```

## 🧪 Testing

```bash
# Run all tests
npm test

# Backend Node.js tests
cd backend && npm test

# Frontend tests
cd frontend && npm test

# Health check tests
curl -f http://localhost:3000/health
curl -f http://localhost:3001/health
```

## 📱 Mobile Apps

### Android
- **Build**: `cd mobile && npm run build:android`
- **Output**: `mobile/builds/android/app.apk`

### iOS
- **Build**: `cd mobile && npm run build:ios`
- **Output**: `mobile/builds/ios/app.ipa`

## 🚀 Deployment Scripts

### Available Scripts
- `deploy-trae-solo.sh` - Complete TRAE Solo deployment
- `deployment/deploy-complete.sh` - Legacy deployment (backup)
- `production-deploy-firewall.sh` - Production with firewall

### Migration from Legacy
```bash
# Backup current deployment
cp -r deployment backup/

# Deploy with TRAE Solo
./deploy-trae-solo.sh

# Verify services
npm run trae:health
```

## 🛠️ Troubleshooting

### Common Issues

1. **Service won't start**
   ```bash
   npm run trae:logs
   # Check health endpoints
   curl http://localhost:3000/health
   ```

2. **Database connection issues**
   ```bash
   # Check PostgreSQL status
   npm run trae:status
   # Restart database service
   trae solo restart database
   ```

3. **SSL certificate issues**
   ```bash
   # Regenerate certificates
   trae solo ssl:renew
   ```

### Support
- **Configuration**: Check `trae-solo.yaml` and `.trae/environment.env`
- **Logs**: `npm run trae:logs`
- **Health**: `npm run trae:health`
- **Status**: `npm run trae:status`

## 🔧 Troubleshooting

### Backend Service Logs

The system uses systemd services for backend management. To check logs:

```bash
# Check logs using the helper script
./check-backend-logs.sh                    # Both backends
./check-backend-logs.sh --node             # Node.js only
./check-backend-logs.sh --python           # Python only

# Direct systemd commands
ssh root@75.208.155.161 'journalctl -u nexus-backend-node -n 20 --no-pager'
ssh root@75.208.155.161 'journalctl -u nexus-backend-python -n 20 --no-pager'

# Follow logs in real-time
ssh root@75.208.155.161 'journalctl -u nexus-backend-node -f'
```

### Service Management

```bash
# Check service status
ssh root@75.208.155.161 'systemctl status nexus-backend-node'
ssh root@75.208.155.161 'systemctl status nexus-backend-python'

# Restart services
ssh root@75.208.155.161 'systemctl restart nexus-backend-node'
ssh root@75.208.155.161 'systemctl restart nexus-backend-python'
```

### Common Issues

1. **"boomroom-backend not found"**: This service name was incorrect. Use `nexus-backend-node` or `nexus-backend-python` instead.
2. **PM2 not found**: The system uses systemd services, not PM2. Use `journalctl` commands instead.
3. **Wrong IP address**: Use `75.208.155.161` (not `74.208.155.161`) based on deployment configuration.

See `BACKEND_LOGS_FIX.md` for detailed troubleshooting information.

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/trae-solo-enhancement`
3. Make your changes
4. Test with TRAE Solo: `npm run trae:deploy`
5. Submit a pull request

---

**🎉 Nexus COS is now fully operational with TRAE Solo!**

For more information about TRAE Solo configuration and advanced features, see the configuration files in the `.trae/` directory.