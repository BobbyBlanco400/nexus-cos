# TRAE Solo Master Fix - Nexus COS Deployment Guide

## 🚀 Quick Start

This Master Fix Script provides a complete deployment solution for Nexus COS with TRAE Solo orchestration, including an interactive module map generation system.

### Prerequisites

- Ubuntu/Debian-based VPS
- Root access
- Internet connection
- Domain pointing to your server

### One-Command Deployment

```bash
# Download and run the quick launch script
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/quick-launch.sh | sudo bash
```

### Manual Deployment

1. **Clone the repository:**
   ```bash
   mkdir -p /opt
   cd /opt
   git clone https://github.com/BobbyBlanco400/nexus-cos.git nexus-cos
   cd nexus-cos
   ```

2. **Run the master fix script:**
   ```bash
   chmod +x master-fix-trae-solo.sh
   ./master-fix-trae-solo.sh
   ```

## 🔧 Configuration

### Environment Variables

Set these environment variables before running the script for custom configuration:

```bash
export DOMAIN="n3xuscos.online"              # Your domain
export EMAIL="admin@n3xuscos.online"         # SSL certificate email
export DEPLOY_PATH="/opt/nexus-cos"          # Deployment directory

# Optional: Notification settings
export SLACK_WEBHOOK_URL="your_slack_webhook_url"
export EMAIL_USER="your_email@domain.com"
export EMAIL_PASSWORD="your_email_password"
export EMAIL_SMTP_SERVER="smtp.gmail.com"
export EMAIL_SMTP_PORT="587"
export EMAIL_TO="notifications@domain.com"
```

### Infrastructure Settings

The script is configured for the infrastructure specified in the requirements:

- **Host:** 75.208.155.161
- **Domain:** n3xuscos.online
- **Deploy Path:** /opt/nexus-cos
- **Email:** puaboverse@gmail.com

## 📋 What the Script Does

### 1. System Dependencies Installation
- Node.js and npm
- Python 3 and pip
- PostgreSQL database
- Nginx web server
- Certbot for SSL certificates
- Mermaid CLI for diagram generation
- Essential build tools

### 2. Database Setup
- Installs and configures PostgreSQL
- Creates `nexus_cos` database
- Sets up `nexus_user` with proper permissions

### 3. Interactive Module Map Generation
- Creates comprehensive Mermaid diagram of all system modules
- Generates interactive HTML with clickable elements
- Includes real-time status indicators
- Provides direct links to each module interface

### 4. Backend Services Deployment
- **Node.js Backend:** Express API server on port 3000
- **Python Backend:** FastAPI server on port 3001
- Creates systemd services for auto-restart
- Configures health check endpoints

### 5. Frontend Deployment
- Builds React frontend application
- Deploys to `/var/www/nexuscos`
- Includes interactive module map in `/diagram/` path

### 6. Nginx Configuration
- Reverse proxy setup for backend services
- SSL termination with Let's Encrypt
- Static file serving for frontend
- API routing configuration

### 7. SSL Certificate Setup
- Automatic Let's Encrypt certificate installation
- HTTPS redirect configuration
- Secure headers implementation

### 8. Health Monitoring
- Comprehensive service health checks
- Database connectivity verification
- HTTP endpoint testing
- System status reporting

## 🔗 Live Endpoints

After successful deployment, these endpoints will be available:

- **🌐 Main Site:** https://n3xuscos.online
- **📊 Interactive Module Map:** https://n3xuscos.online/diagram/NexusCOS.html
- **🔧 Node.js API Health:** https://n3xuscos.online/api/node/health
- **🐍 Python API Health:** https://n3xuscos.online/api/python/health
- **📈 Creator Hub Status:** https://n3xuscos.online/api/creator-hub/status
- **💼 V-Suite Status:** https://n3xuscos.online/api/v-suite/status
- **🌐 PuaboVerse Status:** https://n3xuscos.online/api/puaboverse/status

## 🎯 Interactive Module Map Features

The generated interactive module map includes:

### Core Modules
- **Nexus Core:** System orchestrator and main controller
- **Node.js Backend:** API gateway and business logic
- **Python Backend:** FastAPI services and data processing
- **React Frontend:** User interface and client application
- **PostgreSQL Database:** Data storage and management

### Extended Modules
- **Creator Hub:** Content management and publishing tools
- **V-Suite:** Business tools and workflow management
- **PuaboVerse:** Virtual worlds and 3D environments
- **Admin Panel:** System administration interface
- **Creator Dashboard:** Analytics and insights
- **Mobile App:** Cross-platform mobile application

### Infrastructure Components
- **Nginx Load Balancer:** Request routing and SSL termination
- **SSL/TLS Security:** Let's Encrypt certificate management
- **Health Monitor:** System status and performance tracking
- **Notifications:** Slack and email integration

### Interactive Features
- **Clickable Modules:** Direct access to module interfaces
- **Real-time Status:** Live health indicators for each service
- **Responsive Design:** Mobile-friendly interface
- **Modern UI:** Professional styling with animations

## 🔍 Troubleshooting

### Service Status Check
```bash
# Check all services
systemctl status nexus-backend-node
systemctl status nexus-backend-python
systemctl status postgresql
systemctl status nginx

# Check logs
journalctl -u nexus-backend-node -f
journalctl -u nexus-backend-python -f
```

### Health Endpoints
```bash
# Test local endpoints
curl http://localhost:3000/health
curl http://localhost:3001/health

# Test external endpoints
curl https://n3xuscos.online/api/node/health
curl https://n3xuscos.online/api/python/health
```

### Database Connection
```bash
# Test database
sudo -u postgres psql -d nexus_cos -c "SELECT 1;"
```

### SSL Certificate
```bash
# Check certificate status
certbot certificates
```

## 📦 File Structure

After deployment, the system will have this structure:

```
/opt/nexus-cos/
├── backend/                 # Backend services
│   ├── src/                # Node.js TypeScript source
│   ├── app/                # Python FastAPI application
│   ├── server.js           # Node.js fallback server
│   └── .venv/              # Python virtual environment
├── frontend/               # React frontend
│   └── dist/               # Built frontend files
├── diagram/                # Interactive module map
│   ├── NexusCOS.mmd       # Mermaid diagram source
│   └── NexusCOS.html      # Interactive HTML map
├── master-fix-trae-solo.sh # Main deployment script
└── quick-launch.sh         # Quick deployment wrapper
```

## 🔄 Updating the System

To update the deployed system:

```bash
cd /opt/nexus-cos
git pull origin main
./master-fix-trae-solo.sh
```

## 💡 Advanced Configuration

### Custom Domain Setup
1. Update DNS records to point to your server IP
2. Set the `DOMAIN` environment variable
3. Re-run the master fix script

### Notification Setup
1. Configure Slack webhook URL in environment variables
2. Set up SMTP credentials for email notifications
3. The script will automatically send deployment status updates

### Database Customization
Edit the script to modify database credentials and configuration as needed.

## 🎉 Success Indicators

The deployment is successful when you see:

1. ✅ All systemd services running
2. ✅ Health endpoints responding
3. ✅ Interactive module map accessible
4. ✅ SSL certificates installed
5. ✅ Nginx serving the application
6. ✅ Database connections working

The interactive module map at `https://n3xuscos.online/diagram/NexusCOS.html` should display all modules with green status indicators and clickable links to each service interface.