# Nexus COS - Complete Deployment Package for IONOS VPS

This repository contains the complete Nexus COS application ready for deployment on your new IONOS VPS with updated server and domain configuration.

## 🚀 Quick Start

For immediate deployment on your VPS, see [DEPLOYMENT.md](./DEPLOYMENT.md) for complete instructions.

### Automated Deployment

```bash
# On your VPS:
git clone https://github.com/BobbyBlanco400/nexus-cos.git
cd nexus-cos

# Update domain in the script
nano deploy_nexus_cos_vps.sh

# Run deployment
sudo ./deploy_nexus_cos_vps.sh
```

## 📋 What's Included

### ✅ Ready for Production
- **Frontend**: React 19.1.1 with Vite 7.1.5 build system
- **Backend**: FastAPI with Python 3.12 and Poetry dependency management
- **Database**: PostgreSQL with Alembic migrations
- **Web Server**: Nginx with SSL/TLS (Let's Encrypt)
- **Process Management**: systemd services
- **CI/CD**: GitHub Actions with Node.js 22 support

### ✅ Deployment Assets
- `deploy_nexus_cos_vps.sh` - Complete VPS deployment script
- `config/` - systemd and Nginx configuration templates
- `backend/.env.example` - Environment configuration template
- `DEPLOYMENT.md` - Comprehensive deployment guide

### ✅ Development Ready
- Poetry for Python dependency management
- Node.js 22 support in CI/CD
- Hot reload for development
- Production-optimized builds

## 🛠 Local Development

### Prerequisites
- Node.js 22
- Python 3.12
- PostgreSQL

### Setup

```bash
# Install root dependencies
npm install

# Frontend development
cd frontend
npm install
npm run dev

# Backend development  
cd backend
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install poetry
poetry install --no-root
uvicorn app.main:app --reload
```

## 🌐 Production Deployment

### Environment Requirements
- Ubuntu 22.04 LTS VPS
- Domain name configured
- Root/sudo access

### Quick Deployment

1. **Update Configuration**
   ```bash
   # Edit deployment script with your domain
   nano deploy_nexus_cos_vps.sh
   ```

2. **Run Deployment**
   ```bash
   sudo ./deploy_nexus_cos_vps.sh
   ```

3. **Verify Deployment**
   ```bash
   curl https://your-domain.com/api/
   # Should return: {"message":"PUABO Backend API Phase 3 is live"}
   ```

### Manual Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for step-by-step manual deployment instructions.

## 📁 Project Structure

```
nexus-cos/
├── frontend/              # React frontend application
│   ├── src/              # Source code
│   ├── public/           # Static assets
│   ├── dist/             # Production build (after npm run build)
│   └── package.json      # Frontend dependencies
├── backend/              # FastAPI backend application
│   ├── app/              # Application code
│   ├── migrations/       # Database migrations
│   ├── venv/             # Python virtual environment
│   ├── pyproject.toml    # Python dependencies
│   └── .env.example      # Environment template
├── config/               # Server configuration templates
│   ├── nexus-cos-backend.service  # systemd service
│   └── nginx-nexus-cos.conf       # Nginx configuration
├── .github/workflows/    # CI/CD configuration
├── deploy_nexus_cos_vps.sh  # VPS deployment script
├── DEPLOYMENT.md         # Deployment guide
└── README.md            # This file
```

## 🔧 Configuration

### Environment Variables

Copy `backend/.env.example` to `backend/.env` and update:

```env
DATABASE_URL=postgresql://nexus_user:your_password@localhost/nexus_cos_db
ENVIRONMENT=production
DEBUG=false
SECRET_KEY=your_secure_secret_key
ALLOWED_HOSTS=your-domain.com,www.your-domain.com
```

### Domain Configuration

Update your domain in:
- `deploy_nexus_cos_vps.sh`
- `config/nginx-nexus-cos.conf`
- `backend/.env`

## 🚀 GitHub Actions

The CI/CD pipeline automatically:
- ✅ Builds frontend with Node.js 22
- ✅ Installs backend dependencies with Poetry
- ✅ Tests API functionality
- ✅ Prepares deployment artifacts
- ✅ Triggers on push to main or manual dispatch

## 🛡 Security Features

- ✅ HTTPS with Let's Encrypt SSL
- ✅ Security headers configured
- ✅ Firewall configuration
- ✅ Process isolation with systemd
- ✅ Secure file permissions

## 📊 Monitoring & Maintenance

### Check Services
```bash
sudo systemctl status nexus-cos-backend nginx postgresql
```

### View Logs
```bash
sudo journalctl -u nexus-cos-backend -f
sudo tail -f /var/log/nginx/error.log
```

### Updates
```bash
cd /var/www/nexus-cos
sudo git pull origin main
# Follow update procedures in DEPLOYMENT.md
```

## 🆘 Troubleshooting

Common solutions:

1. **503 Service Unavailable**: Check backend service status
2. **Database Connection**: Verify PostgreSQL and credentials
3. **SSL Issues**: Check Certbot and certificate renewal
4. **Build Issues**: Ensure Node.js 22 and Python 3.12

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed troubleshooting.

## 📞 Support

- Check [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed instructions
- Review GitHub Issues for known problems
- Check service logs for error details

## ✅ Deployment Checklist

- [ ] VPS provisioned with Ubuntu 22.04
- [ ] Domain DNS pointing to VPS
- [ ] Repository cloned on VPS
- [ ] Domain updated in deployment script
- [ ] Deployment script executed
- [ ] SSL certificate installed
- [ ] Services running correctly
- [ ] Application accessible via HTTPS

Your Nexus COS application will be available at `https://your-domain.com` after successful deployment.

---

**Ready for Global Launch! 🌍**