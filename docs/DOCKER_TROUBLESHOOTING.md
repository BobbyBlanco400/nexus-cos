# Docker Build Troubleshooting Guide

This document helps diagnose and fix common Docker build issues for the Nexus COS project.

## Quick Validation

Run the validation script to check your Docker setup:

```bash
./scripts/validate-docker-build.sh
```

## Common Issues and Solutions

### Issue 1: `ENOENT: no such file or directory, open '/app/package.json'`

**Cause**: The `package.json` file is not being copied into the Docker image during the build process.

**Solutions**:

1. **Verify Build Context**: Ensure you're building from the repository root:
   ```bash
   # Wrong - building from a subdirectory
   cd subdirectory
   docker build -t nexus-cos .
   
   # Correct - building from repository root
   cd /path/to/nexus-cos
   docker build -t nexus-cos .
   ```

2. **Check .dockerignore**: Ensure `package.json` is not excluded:
   ```bash
   # Check if package.json is in .dockerignore
   grep "package.json" .dockerignore
   
   # If it is, remove that line from .dockerignore
   ```

3. **Verify File Exists**: Confirm `package.json` exists in the repository root:
   ```bash
   ls -la package.json
   ```

4. **Clean Build**: Remove cached layers and rebuild:
   ```bash
   docker build --no-cache -t nexus-cos .
   ```

### Issue 2: npm install Failures

**Symptoms**: `npm ci` or `npm install` fails during Docker build

**Solutions**:

1. **Check npm Registry Access**:
   ```bash
   # Test npm registry connectivity
   npm ping --registry https://registry.npmjs.org
   ```

2. **Verify package-lock.json**:
   ```bash
   # Regenerate package-lock.json if corrupt
   rm package-lock.json
   npm install
   git add package-lock.json
   git commit -m "Regenerate package-lock.json"
   ```

3. **Use npm install instead of npm ci** (in Dockerfile, if lock file is problematic):
   ```dockerfile
   RUN npm install --omit=dev
   ```

### Issue 3: Docker Build Context Too Large

**Symptoms**: Build takes a long time, large context size warnings

**Solution**: Update `.dockerignore` to exclude unnecessary files:

```
node_modules
npm-debug.log
.git
.gitignore
dist
coverage
*.log
.DS_Store
.vscode
.idea
*.swp
*.swo
*~
# Add other build artifacts and development files
frontend/node_modules
backend/node_modules
services/*/node_modules
```

### Issue 4: Server Fails to Start in Container

**Symptoms**: Container starts but exits immediately, or health checks fail

**Solutions**:

1. **Check Container Logs**:
   ```bash
   docker-compose logs api
   # or
   docker logs <container-id>
   ```

2. **Verify Environment Variables**:
   ```bash
   docker-compose config
   ```

3. **Test Manually**:
   ```bash
   docker run -it --entrypoint /bin/bash nexus-cos-api
   # Inside container:
   node server.js
   ```

### Issue 5: Database Connection Failures

**Symptoms**: API starts but cannot connect to PostgreSQL

**Solutions**:

1. **Verify Database Service**:
   ```bash
   docker-compose ps postgres
   docker-compose logs postgres
   ```

2. **Check Network Connectivity**:
   ```bash
   docker-compose exec api ping postgres
   ```

3. **Verify Environment Variables**:
   ```yaml
   # In docker-compose.yml, ensure these match:
   api:
     environment:
       DB_HOST: postgres  # Should match postgres service name
       DB_PORT: 5432
   ```

## Docker Commands Reference

### Building

```bash
# Build from repository root
docker build -t nexus-cos .

# Build without cache
docker build --no-cache -t nexus-cos .

# Build with specific Dockerfile
docker build -f Dockerfile -t nexus-cos .
```

### Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f
docker-compose logs -f api

# Restart a specific service
docker-compose restart api

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Rebuild and start
docker-compose up -d --build
```

### Debugging

```bash
# Check running containers
docker-compose ps

# Enter a running container
docker-compose exec api /bin/bash

# Check container resource usage
docker stats

# Inspect a container
docker inspect <container-id>

# View container filesystem
docker-compose exec api ls -la /app
```

### Cleanup

```bash
# Remove unused images
docker image prune

# Remove unused containers
docker container prune

# Remove unused volumes
docker volume prune

# Remove everything unused
docker system prune -a
```

## Testing the Setup

### 1. Test Docker Build

```bash
./scripts/validate-docker-build.sh
```

### 2. Test docker-compose

```bash
# Start services
docker-compose up -d

# Wait for services to be ready
sleep 30

# Test health endpoint
curl http://localhost:3000/health

# Check service status
docker-compose ps

# View logs
docker-compose logs
```

### 3. Test Database Connectivity

```bash
# From your host
docker-compose exec postgres psql -U nexus_user -d nexus_db -c "SELECT 1"

# From API container
docker-compose exec api curl -f http://localhost:3000/health
```

## Port Configuration

| Service | Internal Port | External Port | Purpose |
|---------|---------------|---------------|---------|
| API     | 3000          | 3000          | Backend REST API |
| Nginx   | 80            | 80            | Web server / proxy |
| PostgreSQL | 5432       | 5432          | Database |

## Health Check Endpoints

- **API Health**: `http://localhost:3000/health`
  - Returns: `{"status":"ok","timestamp":"...","uptime":...,"db":"up"}`

## Environment Variables

Required environment variables for the API service:

```bash
NODE_ENV=production
PORT=3000
DB_HOST=postgres
DB_PORT=5432
DB_NAME=nexus_db
DB_USER=nexus_user
DB_PASSWORD=nexus_pass
```

## Best Practices

1. **Always build from repository root**
2. **Use `docker-compose` for local development**
3. **Check logs when things fail**: `docker-compose logs -f`
4. **Clean up regularly**: `docker system prune`
5. **Use the validation script before deploying**
6. **Keep .dockerignore updated**
7. **Use health checks to ensure services are ready**

## Getting Help

If you're still experiencing issues after trying these solutions:

1. Run the validation script and save the output
2. Collect logs: `docker-compose logs > docker-logs.txt`
3. Check service status: `docker-compose ps`
4. Include Docker version: `docker --version`
5. Include Docker Compose version: `docker-compose --version`

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Node.js Docker Best Practices](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md)
