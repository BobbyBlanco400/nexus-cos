# Nexus COS Unified Deployment Scaffold

## Overview

The **Nexus COS Unified Deployment Scaffold** is a centralized deployment script that creates a modular framework for the entire Nexus COS ecosystem with unified branding.

**Author:** Robert "Bobby Blanco" White  
**Version:** 1.0.0  
**Compatible:** TRAE Solo + GitHub Code Agent

## Purpose

This script scaffolds the complete Nexus COS infrastructure including:

- Directory structure for core services, modules, assets, and dashboard
- Centralized dashboard UI for accessing all modules
- Gateway configuration for routing
- Deployment hooks for all PUABO modules

## Features

### 🎨 Unified Branding
- **Brand Name:** Nexus Creative Operating System
- **Primary Color:** #0C63E7 (Blue)
- **Accent Color:** #1E1E1E (Dark Gray)
- **Dashboard Port:** 8080

### 📦 Module Integration
The script integrates the following PUABO modules:

1. **PUABO Nexus** - Box Truck Logistics + Fleet Operations
2. **PUABO BLAC** - Alternative Lending + Smart Finance
3. **PUABO DSP** - Music & Media Distribution
4. **PUABO NUKI** - Fashion + Lifestyle Commerce
5. **PUABO TV** - Broadcast + Streaming Hub

### 🏗️ Architecture

```
┌───────────────────────────────┐
│        NEXUS COS CORE         │
│  Auth • Payments • Analytics  │
│  Notifications • API Gateway  │
└────────────┬──────────────────┘
             │
             ▼
┌───────────────────────────────┐
│     CENTRALIZED DASHBOARD     │
│  (Access Point for Modules)   │
│       Port: 8080              │
└────────────┬──────────────────┘
             │
 ┌──────────────────────────────────────────────────────┐
 │                     MODULES                          │
 │──────────────────────────────────────────────────────│
 │ PUABO Nexus   → Logistics / Fleet / Dispatch          │
 │ PUABO BLAC    → Alternative Lending / Smart Finance   │
 │ PUABO DSP     → Music + Media Distribution            │
 │ PUABO NUKI    → Fashion + Lifestyle Commerce          │
 │ PUABO TV      → Broadcast + Streaming Hub             │
 └──────────────────────────────────────────────────────┘
             │
             ▼
      ┌───────────────────────┐
      │    Shared Services    │
      │ PostgreSQL • Redis    │
      │  Logging • Monitoring │
      └───────────────────────┘
```

## Usage

### Basic Deployment

```bash
sudo ./nexus-cos-unified-deployment-scaffold.sh
```

**Note:** Requires root/sudo access to create directories in `/opt/nexus-cos/`

### What It Does

1. **Creates Directory Structure:**
   - `/opt/nexus-cos/core` - Core services
   - `/opt/nexus-cos/modules` - Business modules
   - `/opt/nexus-cos/assets` - Static assets (logos, images)
   - `/opt/nexus-cos/services` - Shared services
   - `/opt/nexus-cos/dashboard` - Web dashboard
   - `/opt/nexus-cos/branding` - Branding assets

2. **Displays System Architecture:**
   - Shows ASCII diagram of the complete system

3. **Deploys Core Services:**
   - Runs `docker compose` if `/opt/nexus-cos/core/docker-compose.yml` exists

4. **Deploys Modules:**
   - Iterates through all PUABO modules
   - Executes deployment scripts if they exist

5. **Creates Dashboard:**
   - Generates a responsive HTML dashboard at `/opt/nexus-cos/dashboard/index.html`
   - Provides navigation to all modules

6. **Configures Gateway:**
   - Creates nginx configuration at `/opt/nexus-cos/core/gateway.conf`
   - Routes requests to appropriate services

## Testing

Run the comprehensive test suite to verify the script:

```bash
./test-unified-scaffold.sh
```

The test validates:
- ✅ Script syntax
- ✅ File permissions
- ✅ Required components
- ✅ Environment variables
- ✅ Module declarations
- ✅ Dashboard HTML generation
- ✅ Gateway configuration
- ✅ Dry-run execution

## Prerequisites

To fully utilize this script, you need:

1. **Docker & Docker Compose** - For containerized deployments
2. **Nginx** - For gateway/reverse proxy
3. **Root Access** - To create directories in `/opt/`

## Post-Deployment Steps

After running the scaffold script:

1. **Add Core Services:**
   ```bash
   # Place your docker-compose.yml in /opt/nexus-cos/core/
   cp your-docker-compose.yml /opt/nexus-cos/core/docker-compose.yml
   ```

2. **Add Module Deployment Scripts:**
   ```bash
   # Create deployment scripts for each module
   mkdir -p /opt/nexus-cos/modules/puabo-{nexus,blac,dsp,nuki,tv}/scripts
   # Add deploy.sh to each module's scripts directory
   ```

3. **Add Logo:**
   ```bash
   # Copy your Nexus COS logo
   cp Nexus_COS_Logo.svg /opt/nexus-cos/assets/
   ```

4. **Configure Nginx:**
   ```bash
   # Link the gateway configuration
   sudo ln -s /opt/nexus-cos/core/gateway.conf /etc/nginx/sites-enabled/nexus-cos
   sudo nginx -t
   sudo systemctl reload nginx
   ```

5. **Start Dashboard Server:**
   ```bash
   # Serve the dashboard on port 8080
   cd /opt/nexus-cos/dashboard
   python3 -m http.server 8080
   ```

## Environment Variables

The script exports the following environment variables:

```bash
NEXUS_COS_NAME="Nexus COS"
NEXUS_COS_BRAND_NAME="Nexus Creative Operating System"
NEXUS_COS_BRAND_COLOR_PRIMARY="#0C63E7"
NEXUS_COS_BRAND_COLOR_ACCENT="#1E1E1E"
NEXUS_COS_LOGO_PATH="/opt/nexus-cos/assets/Nexus_COS_Logo.svg"
NEXUS_COS_DASHBOARD_PORT=8080
```

## Integration with Existing Infrastructure

This script is designed to **coexist** with existing Nexus COS deployments:

- ✅ Does not modify existing files
- ✅ Creates new directory structure in `/opt/nexus-cos/`
- ✅ Can run alongside current PM2/Docker deployments
- ✅ Provides additional unified layer on top of existing services

## Troubleshooting

### Permission Denied
```bash
# Run with sudo
sudo ./nexus-cos-unified-deployment-scaffold.sh
```

### Docker Not Found
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Port 8080 Already in Use
```bash
# Change the port in the script
export NEXUS_COS_DASHBOARD_PORT=8081
```

## Files Generated

After execution, the following files are created:

- `/opt/nexus-cos/dashboard/index.html` - Main dashboard UI
- `/opt/nexus-cos/core/gateway.conf` - Nginx gateway configuration

## Related Scripts

- `deploy-pf-v1.2.sh` - PF v1.2 deployment with dependency mapping
- `copilot-master-scaffold.js` - JavaScript scaffolder for services
- `setup-nexus-cos.sh` - One-command setup and deployment

## Support

For issues or questions:
- Check existing deployment documentation in the repository
- Review test output from `test-unified-scaffold.sh`
- Ensure all prerequisites are met

## License

Part of the Nexus COS project.
