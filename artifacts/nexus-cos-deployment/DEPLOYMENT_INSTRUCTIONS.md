# Nexus COS Deployment Instructions

## Prerequisites

- Ubuntu 22.04 VPS with root access
- Domain name pointing to VPS IP
- SSH access to VPS
- Git installed on VPS

## Deployment Options

### Option 1: Automated Production Setup (Recommended)

**For fresh Ubuntu 22.04 VPS with complete infrastructure setup:**

1. **Upload production setup script**
   ```bash
   scp scripts/production-auto-setup.sh root@your-vps:/tmp/
   ```

2. **SSH into VPS and run automated setup**
   ```bash
   ssh root@your-vps
   chmod +x /tmp/production-auto-setup.sh
   /tmp/production-auto-setup.sh
   ```

   This script will:
   - Install all dependencies (Python, Node.js, PostgreSQL, Nginx, Docker)
   - Configure database and firewall
   - Clone and setup the application
   - Create systemd services
   - Configure Nginx with SSL
   - Generate deployment summary

### Option 2: Manual Deployment

**For existing servers or custom configurations:**

1. **Upload this package to your VPS**
   ```bash
   scp -r nexus-cos-deployment root@your-vps:/tmp/
   ```

2. **SSH into your VPS**
   ```bash
   ssh root@your-vps
   cd /tmp/nexus-cos-deployment
   ```

3. **Set environment variables**
   ```bash
   export DOMAIN="nexuscos.online"
   export EMAIL="puaboverse@gmail.com"
   export VPS_HOST="your-vps-ip"
   ```

4. **Run deployment script**
   ```bash
   chmod +x scripts/vps-deploy.sh
   ./scripts/vps-deploy.sh
   ```

5. **Setup monitoring (optional)**
   ```bash
   ./scripts/setup-monitoring.sh
   ```

## Access Points
- Frontend: https://your-domain.com
- API (Node.js): https://your-domain.com/api/node
- API (Python): https://your-domain.com/api/python
- Monitoring: https://your-domain.com/grafana

## Support
Refer to FINAL_DEPLOYMENT_REPORT.md for detailed information.
