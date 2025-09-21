# Nexus COS - Complete Operating System

![TRAE Solo Compatible](https://img.shields.io/badge/TRAE%20Solo-Compatible-green)
![Node.js](https://img.shields.io/badge/Node.js-20.x-blue)
![Python](https://img.shields.io/badge/Python-3.12-blue)
![React](https://img.shields.io/badge/React-18.x-blue)

A complete operating system implementation with multi-platform support, now fully migrated to **TRAE Solo** orchestration.

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