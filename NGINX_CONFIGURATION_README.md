# Nexus COS - Nginx Configuration Guide

Complete guide for deploying Nexus COS with Nginx in Docker or Host mode.

> 📖 **For comprehensive beta launch readiness report with VPS deployment, recovery procedures, and troubleshooting, see [BETA_LAUNCH_READINESS_COMPREHENSIVE.md](./BETA_LAUNCH_READINESS_COMPREHENSIVE.md)**

## 📋 Table of Contents

- [Overview](#overview)
- [Configuration Files](#configuration-files)
- [Deployment Modes](#deployment-modes)
- [Quick Start](#quick-start)
- [Interactive One-Liner](#interactive-one-liner)
- [Manual Deployment](#manual-deployment)
- [Validation](#validation)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

Nexus COS supports two Nginx deployment modes:

1. **Docker Mode** - Nginx runs as a container (recommended for production)
2. **Host Mode** - Nginx runs directly on the host OS

The key difference is how services are accessed:
- **Docker Mode**: Uses Docker service names (`puabo-api:4000`)
- **Host Mode**: Uses localhost with exposed ports (`localhost:4000`)

## 📁 Configuration Files

### Core Configurations

- **`nginx.conf.docker`** - Configuration for Nginx running in Docker container
  - Upstreams use Docker service names
  - Requires all services on the same Docker network (`cos-net`)
  
- **`nginx.conf.host`** - Configuration for Nginx running on host OS
  - Upstreams use localhost with exposed container ports
  - Nginx accesses containers via published ports

- **`nginx/nginx.conf`** - Main Nginx configuration template
- **`nginx/conf.d/nexus-proxy.conf`** - Route mappings for all PF services

### Service Configuration

- **`docker-compose.yml`** - Main service orchestration
- **`docker-compose.pf.yml`** - PF (Platform Framework) services

## 🚀 Deployment Modes

### Docker Mode (Recommended)

**When to use:**
- Production deployments
- All services containerized
- Need container-to-container communication
- Easier scaling and management

**Requirements:**
- Docker and Docker Compose installed
- All services on the same Docker network
- Nginx container configured in docker-compose

**Configuration:**
```bash
# Upstreams use Docker service names
upstream pf_gateway {
    server puabo-api:4000;
}
```

### Host Mode

**When to use:**
- Development environments
- Existing Nginx installation on host
- Need to access other host services
- Custom Nginx modules required

**Requirements:**
- Nginx installed on host OS
- Container ports exposed to host
- Services accessible via localhost

**Configuration:**
```bash
# Upstreams use localhost with ports
upstream pf_gateway {
    server localhost:4000;
}
```

## ⚡ Quick Start

### Interactive One-Liner (Recommended)

This interactive deployment script handles everything automatically:

```bash
echo "Choose Nginx mode: [1] Docker [2] Host"; read mode; if [ "$mode" = "1" ]; then sudo cp nginx.conf.docker /etc/nginx/nginx.conf; else sudo cp nginx.conf.host /etc/nginx/nginx.conf; fi && git stash && git pull origin main && sudo cp nginx/conf.d/nexus-proxy.conf /etc/nginx/conf.d/ && sudo nginx -t && sudo nginx -s reload && [ -f test-pf-configuration.sh ] && chmod +x test-pf-configuration.sh && ./test-pf-configuration.sh && for url in /api /admin /v-suite/prompter /health /health/gateway /health/puaboai-sdk /health/pv-keys; do curl -I https://n3xuscos.online$url; done
```

**What it does:**
1. Prompts for deployment mode (Docker or Host)
2. Copies appropriate nginx configuration
3. Updates repository from git
4. Installs proxy configuration
5. Tests nginx configuration
6. Reloads nginx
7. Runs PF validation tests
8. Tests all critical endpoints

### Docker Mode Deployment

```bash
# 1. Start all services
docker-compose -f docker-compose.pf.yml up -d

# 2. Copy Docker configuration
sudo cp nginx.conf.docker /etc/nginx/nginx.conf
sudo cp nginx/conf.d/nexus-proxy.conf /etc/nginx/conf.d/

# 3. Test configuration
sudo nginx -t

# 4. Reload Nginx
sudo nginx -s reload

# 5. Validate deployment
./test-pf-configuration.sh
```

### Host Mode Deployment

```bash
# 1. Start backend services (containers)
docker-compose -f docker-compose.pf.yml up -d

# 2. Copy Host configuration
sudo cp nginx.conf.host /etc/nginx/nginx.conf
sudo cp nginx/conf.d/nexus-proxy.conf /etc/nginx/conf.d/

# 3. Test configuration
sudo nginx -t

# 4. Reload Nginx
sudo nginx -s reload

# 5. Validate deployment
./test-pf-configuration.sh
```

## 🔍 Manual Deployment

### Step 1: Choose Deployment Mode

Decide whether to run Nginx in Docker or on the host:

**Docker Mode:**
```bash
NGINX_MODE="docker"
```

**Host Mode:**
```bash
NGINX_MODE="host"
```

### Step 2: Start Backend Services

All backend services must be running before configuring Nginx:

```bash
# Start PF services
docker-compose -f docker-compose.pf.yml up -d

# Verify services are running
docker ps

# Expected output:
# - puabo-api (port 4000)
# - nexus-cos-puaboai-sdk (port 3002)
# - nexus-cos-pv-keys (port 3041)
# - nexus-cos-postgres (port 5432)
# - nexus-cos-redis (port 6379)
```

### Step 3: Install Nginx Configuration

```bash
# Copy main configuration based on mode
if [ "$NGINX_MODE" = "docker" ]; then
    sudo cp nginx.conf.docker /etc/nginx/nginx.conf
else
    sudo cp nginx.conf.host /etc/nginx/nginx.conf
fi

# Copy route configuration
sudo cp nginx/conf.d/nexus-proxy.conf /etc/nginx/conf.d/

# Create SSL directory if it doesn't exist
sudo mkdir -p /etc/ssl/ionos
```

### Step 4: Configure SSL/TLS

```bash
# Copy SSL certificates (replace with your actual certificates)
sudo cp ssl/fullchain.pem /etc/ssl/ionos/
sudo cp ssl/privkey.pem /etc/ssl/ionos/
sudo cp ssl/chain.pem /etc/ssl/ionos/

# Set proper permissions
sudo chmod 644 /etc/ssl/ionos/fullchain.pem
sudo chmod 600 /etc/ssl/ionos/privkey.pem
sudo chmod 644 /etc/ssl/ionos/chain.pem
```

### Step 5: Test Configuration

```bash
# Test Nginx configuration syntax
sudo nginx -t

# Expected output:
# nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Step 6: Apply Configuration

```bash
# Reload Nginx (no downtime)
sudo nginx -s reload

# Or restart Nginx (brief downtime)
sudo systemctl restart nginx
```

### Step 7: Validate Deployment

```bash
# Run validation script
./test-pf-configuration.sh

# Test individual endpoints
curl -I https://n3xuscos.online/health
curl -I https://n3xuscos.online/api
curl -I https://n3xuscos.online/admin
```

## ✅ Validation

### Automated Validation

Run the comprehensive validation script:

```bash
./test-pf-configuration.sh
```

**This script checks:**
- Configuration file existence
- Docker service status
- Health endpoint responses
- Nginx configuration syntax
- Route configuration
- Frontend environment
- Architecture diagram

### Manual Validation

#### Check Docker Services

```bash
# List running containers
docker ps

# Check service logs
docker logs puabo-api
docker logs nexus-cos-puaboai-sdk
docker logs nexus-cos-pv-keys
```

#### Test Health Endpoints

```bash
# Gateway health
curl http://localhost:4000/health

# AI SDK health
curl http://localhost:3002/health

# Keys service health
curl http://localhost:3041/health
```

#### Test Production Endpoints

```bash
# All critical endpoints
for url in /api /admin /v-suite/prompter /health /health/gateway /health/puaboai-sdk /health/pv-keys; do
    echo "Testing: https://n3xuscos.online$url"
    curl -I https://n3xuscos.online$url
    echo ""
done
```

### Validation Checklist

- [ ] All Docker services running (`docker ps`)
- [ ] Health endpoints respond 200 OK
- [ ] Nginx config test passes (`nginx -t`)
- [ ] SSL certificates valid
- [ ] All routes return 200/301/302
- [ ] No 502 Bad Gateway errors
- [ ] Logs show no errors

## 🔧 Troubleshooting

### Common Issues

#### 1. 502 Bad Gateway

**Cause:** Backend service not running or not accessible

**Docker Mode Solution:**
```bash
# Check if services are on the same network
docker network inspect cos-net

# Verify service names match configuration
docker ps --format "{{.Names}}"
```

**Host Mode Solution:**
```bash
# Check if ports are accessible from host
curl http://localhost:4000/health
curl http://localhost:3002/health
curl http://localhost:3041/health
```

#### 2. Nginx Configuration Test Fails

**Cause:** Syntax error or missing files

**Solution:**
```bash
# View detailed error
sudo nginx -t

# Common fixes:
# - Ensure conf.d directory exists
sudo mkdir -p /etc/nginx/conf.d/

# - Check file permissions
sudo chmod 644 /etc/nginx/nginx.conf
sudo chmod 644 /etc/nginx/conf.d/*.conf
```

#### 3. SSL Certificate Errors

**Cause:** Missing or invalid SSL certificates

**Solution:**
```bash
# Check certificate files exist
ls -l /etc/ssl/ionos/

# Test certificate validity
openssl x509 -in /etc/ssl/ionos/fullchain.pem -text -noout

# Verify certificate chain
openssl verify -CAfile /etc/ssl/ionos/chain.pem /etc/ssl/ionos/fullchain.pem
```

#### 4. Services Not Starting

**Cause:** Port conflicts or resource issues

**Solution:**
```bash
# Check for port conflicts
sudo netstat -tlnp | grep -E ':(4000|3002|3041|5432|6379)'

# Check Docker resources
docker system df

# View service logs
docker-compose -f docker-compose.pf.yml logs
```

#### 5. Network Connectivity Issues

**Docker Mode:**
```bash
# Verify network exists
docker network ls | grep cos-net

# Check which containers are on the network
docker network inspect cos-net

# Test connectivity between containers
docker exec puabo-api ping nexus-cos-puaboai-sdk
```

**Host Mode:**
```bash
# Test port accessibility
telnet localhost 4000
telnet localhost 3002
telnet localhost 3041

# Check firewall rules
sudo ufw status
```

### Debug Commands

```bash
# View Nginx error log
sudo tail -f /var/log/nginx/error.log

# View Nginx access log
sudo tail -f /var/log/nginx/access.log

# Test specific upstream
curl -v http://puabo-api:4000/health  # Docker mode
curl -v http://localhost:4000/health   # Host mode

# Reload Nginx with error output
sudo nginx -s reload 2>&1

# Check Nginx process
ps aux | grep nginx
```

## 🌐 Network Configuration

### Docker Network (cos-net)

All services must be on the same Docker network for container-to-container communication:

```yaml
networks:
  cos-net:
    driver: bridge
```

**Verify network:**
```bash
docker network inspect cos-net
```

### Service Names vs Localhost

**Docker Mode** - Use service names:
- `puabo-api:4000`
- `nexus-cos-puaboai-sdk:3002`
- `nexus-cos-pv-keys:3041`

**Host Mode** - Use localhost with ports:
- `localhost:4000`
- `localhost:3002`
- `localhost:3041`

## 📊 Health Checks

All services provide health endpoints:

### Gateway (puabo-api)
- **URL:** `http://puabo-api:4000/health` or `http://localhost:4000/health`
- **Response:** `{"status":"ok","service":"puabo-api"}`

### AI SDK (nexus-cos-puaboai-sdk)
- **URL:** `http://nexus-cos-puaboai-sdk:3002/health` or `http://localhost:3002/health`
- **Response:** `{"status":"ok","service":"puaboai-sdk"}`

### Keys Service (nexus-cos-pv-keys)
- **URL:** `http://nexus-cos-pv-keys:3041/health` or `http://localhost:3041/health`
- **Response:** `{"status":"ok","service":"pv-keys"}`

## 🔐 Security

### SSL/TLS Configuration

- **Protocol:** TLS 1.2, TLS 1.3
- **Certificates:** IONOS SSL certificates
- **HSTS:** Enabled with 1-year max-age
- **OCSP Stapling:** Enabled

### Security Headers

- `X-Frame-Options: SAMEORIGIN`
- `X-XSS-Protection: 1; mode=block`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: no-referrer-when-downgrade`
- `Content-Security-Policy: default-src 'self' ...`
- `Strict-Transport-Security: max-age=31536000; includeSubDomains`

## 📝 Additional Resources

- **PF Configuration Summary:** `PF_CONFIGURATION_SUMMARY.md`
- **PF Deployment Checklist:** `PF_DEPLOYMENT_CHECKLIST.md`
- **Beta Launch Validation:** `PF_TRAE_Beta_Launch_Validation.md`
- **Main README:** `README.md`

## 🆘 Support

For additional help:

1. Check service logs: `docker-compose -f docker-compose.pf.yml logs -f`
2. Run validation: `./validate-pf-nginx.sh`
3. Test endpoints: `./test-pf-configuration.sh`
4. Review documentation in `PF_*.md` files

---

**Last Updated:** 2025-10-03  
**Status:** ✅ Production Ready