# Nexus COS - Python Backend Service Setup

This directory contains the Docker Compose configuration for running the Python backend (FastAPI) and Nginx gateway services.

## Services

### 1. Python Backend (FastAPI)
- **Container Name**: `nexus-python-backend`
- **Port**: 3001
- **Technology**: FastAPI with Uvicorn
- **Health Check**: Available at `/health`

### 2. Nginx Gateway
- **Container Name**: `nexus-nginx-gateway`
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **Technology**: Nginx Alpine
- **Features**:
  - Self-signed SSL certificate (for local testing)
  - Proxies `/py/*` routes to Python backend
  - Automatic health checks

## Quick Start

### Start Services

Start the Python backend:
```bash
docker compose -f nexus-cos/docker-compose.yml up -d python-backend
```

Start the Nginx gateway:
```bash
docker compose -f nexus-cos/docker-compose.yml up -d nginx
```

Start both services:
```bash
docker compose -f nexus-cos/docker-compose.yml up -d
```

### Check Service Status

```bash
docker compose -f nexus-cos/docker-compose.yml ps
```

### View Logs

Python backend logs:
```bash
docker compose -f nexus-cos/docker-compose.yml logs python-backend --tail=80
```

Nginx logs:
```bash
docker compose -f nexus-cos/docker-compose.yml logs nginx --tail=80
```

Follow logs in real-time:
```bash
docker compose -f nexus-cos/docker-compose.yml logs -f
```

## Available Endpoints

### Health Check Endpoints

1. **Direct Container Port** (HTTP):
   ```bash
   curl http://localhost:3001/health
   ```
   Response: `{"status":"ok"}`

2. **Via Nginx** (HTTP):
   ```bash
   curl http://localhost/py/health
   ```
   Response: `{"status":"ok"}`

3. **Via Nginx** (HTTPS with self-signed cert):
   ```bash
   curl -k https://localhost/py/health
   ```
   Response: `{"status":"ok"}`

### API Documentation Endpoints

The FastAPI documentation is enabled by default and accessible at:

1. **Swagger UI**:
   - Local: http://localhost/py/docs
   - Production: https://nexuscos.online/py/docs

2. **ReDoc**:
   - Local: http://localhost/py/redoc
   - Production: https://nexuscos.online/py/redoc

3. **OpenAPI JSON**:
   - Local: http://localhost/py/openapi.json
   - Production: https://nexuscos.online/py/openapi.json

## Service Management

### Stop Services

Stop all services:
```bash
docker compose -f nexus-cos/docker-compose.yml down
```

Stop specific service:
```bash
docker compose -f nexus-cos/docker-compose.yml stop python-backend
docker compose -f nexus-cos/docker-compose.yml stop nginx
```

### Restart Services

```bash
docker compose -f nexus-cos/docker-compose.yml restart
```

### Rebuild Services

If you make changes to the code or Dockerfile:
```bash
docker compose -f nexus-cos/docker-compose.yml up -d --build
```

## Network Configuration

Both services run on the `nexus-net` bridge network, allowing them to communicate with each other using their service names:
- `python-backend` (accessible at `python-backend:3001` within the network)
- `nginx` (accessible at `nginx:80` and `nginx:443` within the network)

## SSL Configuration

### Development (Current Setup)
The current setup uses self-signed SSL certificates generated automatically when the nginx container starts. This is suitable for:
- Local development
- Testing HTTPS functionality
- Internal staging environments

### Production
For production deployment on `nexuscos.online`, you should:
1. Mount actual SSL certificates (e.g., from IONOS, Let's Encrypt)
2. Update the nginx configuration to use the production certificates
3. Remove the self-signed certificate generation from the entrypoint

Example production volume mount:
```yaml
volumes:
  - ./nginx.conf:/etc/nginx/nginx.conf:ro
  - /path/to/ssl:/etc/ssl/ionos:ro
```

## Health Checks

Both services have health checks configured:

### Python Backend
- **Check**: `curl -f http://localhost:3001/health`
- **Interval**: 30 seconds
- **Timeout**: 10 seconds
- **Retries**: 3
- **Start Period**: 40 seconds

### Nginx
- **Check**: `wget -q --spider http://localhost/health`
- **Interval**: 30 seconds
- **Timeout**: 10 seconds
- **Retries**: 3

## Troubleshooting

### Service Won't Start

Check logs:
```bash
docker compose -f nexus-cos/docker-compose.yml logs
```

### Port Already in Use

If ports 80, 443, or 3001 are already in use, you can either:
1. Stop the conflicting service
2. Modify the port mappings in `docker-compose.yml`

### SSL Certificate Issues

For development, the self-signed certificate warnings are expected. Use `-k` flag with curl or accept the browser warning.

### Network Issues

Check if the network exists:
```bash
docker network ls | grep nexus-net
```

Recreate the network if needed:
```bash
docker compose -f nexus-cos/docker-compose.yml down
docker compose -f nexus-cos/docker-compose.yml up -d
```

## Development Notes

- The FastAPI application auto-reloads when code changes are detected (in development mode)
- Swagger UI and ReDoc are enabled by default
- The backend uses port 3001 (not the default 8000) to avoid conflicts
- Nginx strips the `/py` prefix when proxying to the backend

## Related Files

- `docker-compose.yml` - Service definitions
- `nginx.conf` - Nginx configuration
- `../backend/Dockerfile` - Python backend Docker configuration
- `../backend/app/main.py` - FastAPI application code
