# NEXUS COS - Unified TRAE Solo Integration

This is the unified project structure combining all NEXUS COS repositories for TRAE Solo deployment.

## Project Structure

```
trae-solo-unified/
├── frontend/          # React/Vite frontend (puabo-os-2025)
├── admin/             # Admin panel (PUABO-OS-V200/admin)
├── backend-node/      # Node.js API backend (node-auth-api)
├── backend-python/    # Python FastAPI backend (PUABO-OS-V200/backend)
├── tv-radio/          # PUABO TV RADIO (puabo20.github.io)
├── cos-modules/       # COS modules (puabo-cos)
├── nginx/             # Nginx reverse proxy configuration
├── docker-compose.yml # Docker Compose configuration
├── trae-solo.yaml     # TRAE Solo configuration
└── deploy.ps1         # Deployment script
```

## Services

- **Frontend** (Port 3000): Main React/Vite application
- **Admin** (Port 3001): Administrative interface
- **Backend Node** (Port 5000): Node.js API server
- **Backend Python** (Port 8000): Python FastAPI server
- **TV Radio** (Port 8080): PUABO TV RADIO streaming service
- **COS Modules** (Port 9000): Core operating system modules
- **Nginx** (Port 80/443): Reverse proxy and load balancer

## Quick Start

1. **Prerequisites**:
   - Docker and Docker Compose installed
   - PowerShell (for Windows deployment)

2. **Deploy locally**:
   ```powershell
   .\deploy.ps1
   ```

3. **Access the application**:
   - Main site: http://localhost
   - Admin panel: http://localhost/admin
   - TV/Radio: http://localhost/tv
   - API endpoints: http://localhost/api/v1 and http://localhost/api/v2

## Manual Deployment

```bash
# Build and start all services
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Production Deployment

For production deployment to nexuscos.online:

1. Update domain configuration in `nginx/nginx.conf`
2. Configure SSL certificates
3. Update environment variables for production
4. Deploy using TRAE Solo configuration

## Health Checks

All services include health check endpoints:
- Frontend: `/health`
- Admin: `/health`
- Backend Node: `/health`
- Backend Python: `/health`
- TV Radio: `/health`
- COS Modules: `/health`

## TRAE Solo Integration

The `trae-solo.yaml` file contains the configuration for TRAE Solo deployment with:
- Service definitions
- Health check configurations
- Routing rules
- SSL configuration

## Development

For development, you can run individual services:

```bash
# Frontend development
cd frontend && npm run dev

# Backend Node development
cd backend-node && npm run dev

# Backend Python development
cd backend-python && uvicorn main:app --reload
```

## Support

For issues and support, please refer to the individual repository documentation or contact the NEXUS COS development team.