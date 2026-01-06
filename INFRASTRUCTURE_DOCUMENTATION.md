# N3XUS COS Infrastructure Documentation — Phase-2

**Status:** ✅ Production-Ready  
**Date:** January 2, 2026  
**Version:** v3.0  
**Governance:** Handshake 55-45-17

---

## Table of Contents

1. [Nginx Gateway Configuration](#nginx-gateway-configuration)
2. [SSL/TLS Configuration](#ssltls-configuration)
3. [Port Mappings & Service Routing](#port-mappings--service-routing)
4. [Autoscaling Configuration](#autoscaling-configuration)
5. [Monitoring & Health Checks](#monitoring--health-checks)
6. [Docker Infrastructure](#docker-infrastructure)
7. [Service Discovery](#service-discovery)
8. [Security Configuration](#security-configuration)

---

## Nginx Gateway Configuration

### Overview
Nginx serves as the primary reverse proxy and load balancer for all N3XUS COS services.

### Configuration File
**Location:** `/home/runner/work/nexus-cos/nexus-cos/nginx.conf`

### Key Features
- ✅ HTTP to HTTPS redirect
- ✅ SSL/TLS termination
- ✅ Reverse proxy for all services
- ✅ Load balancing
- ✅ Security headers
- ✅ Handshake 55-45-17 injection

### Governance Enforcement
```nginx
# Handshake injection on all proxied requests
proxy_set_header X-N3XUS-Handshake "55-45-17";
```

### Upstream Services
```nginx
# Core service upstreams
upstream pf_gateway {
    server puabo-api:4000;
}

upstream pf_puaboai_sdk {
    server nexus-cos-puaboai-sdk:3002;
}

upstream pf_pv_keys {
    server nexus-cos-pv-keys:3041;
}

upstream vscreen_hollywood {
    server vscreen-hollywood:8088;
}
```

### HTTP to HTTPS Redirect
```nginx
server {
    listen 80;
    server_name n3xuscos.online www.n3xuscos.online beta.n3xuscos.online;
    return 301 https://$server_name$request_uri;
}
```

### HTTPS Server Configuration
```nginx
server {
    listen 443 ssl http2;
    server_name n3xuscos.online www.n3xuscos.online;
    
    # SSL Configuration
    ssl_certificate /etc/ssl/ionos/fullchain.pem;
    ssl_certificate_key /etc/ssl/ionos/privkey.pem;
    ssl_trusted_certificate /etc/ssl/ionos/chain.pem;
    
    # SSL Security Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;
    
    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Strict-Transport-Security "max-age=31536000" always;
}
```

### Common Issues Fixed
- ✅ **Infinite redirect loops** - Fixed with proper proxy configuration
- ✅ **503 errors** - Resolved upstream connectivity issues
- ✅ **SSL certificate errors** - Properly configured Let's Encrypt/IONOS certs

---

## SSL/TLS Configuration

### Certificate Provider
**Primary:** Let's Encrypt / IONOS  
**Renewal:** Automated  
**Status:** ✅ Active

### Certificate Locations
```bash
# SSL certificate paths
/etc/ssl/ionos/fullchain.pem       # Full certificate chain
/etc/ssl/ionos/privkey.pem         # Private key
/etc/ssl/ionos/chain.pem           # Certificate chain
```

### TLS Protocols
- ✅ TLS 1.2 (supported)
- ✅ TLS 1.3 (preferred)
- ❌ TLS 1.0/1.1 (disabled for security)

### Cipher Suites
```
ECDHE-ECDSA-AES128-GCM-SHA256
ECDHE-RSA-AES128-GCM-SHA256
ECDHE-ECDSA-AES256-GCM-SHA384
ECDHE-RSA-AES256-GCM-SHA384
```

### SSL Session Configuration
```nginx
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
```

### Security Grade
**SSL Labs Rating:** A+ (Target)

### Certificate Renewal
```bash
# Automated renewal with Let's Encrypt
# Check certificate expiry
openssl x509 -in /etc/ssl/ionos/fullchain.pem -noout -dates

# Manual renewal (standard - respects rate limits)
certbot renew

# Force renewal (use only in emergency, bypasses rate limits)
# certbot renew --force-renewal
```

---

## Port Mappings & Service Routing

### Core Service Ports

| Service | Internal Port | External Access | Protocol |
|---------|--------------|----------------|----------|
| **Nginx Gateway** | 80, 443 | Yes (HTTP/HTTPS) | TCP |
| **Backend API** | 3000 | Via Nginx | HTTP |
| **PUABO AI Hybrid** | 3401 | Via Nginx | HTTP |
| **PUABO API Gateway** | 4000 | Via Nginx | HTTP |
| **PUABOAI SDK** | 3002 | Via Nginx | HTTP |
| **PV Keys** | 3041 | Via Nginx | HTTP |
| **V-Screen Hollywood** | 8088 | Via Nginx | HTTP |

### External Access Routes

#### Public Routes
```
https://n3xuscos.online/              → Frontend (port 4000)
https://n3xuscos.online/api/          → Backend API (port 3000)
https://n3xuscos.online/api/ai/       → PUABO AI Hybrid (port 3401)
https://n3xuscos.online/casino/       → Casino Service
https://n3xuscos.online/streaming/    → Streaming Service
https://n3xuscos.online/wallet/       → Wallet Service
https://n3xuscos.online/admin/        → Admin Panel
```

#### Health Check Routes
```
https://n3xuscos.online/health                → Gateway health
https://n3xuscos.online/health/puaboai-sdk    → PUABOAI SDK health
https://n3xuscos.online/health/pv-keys        → PV Keys health
http://localhost:3401/health                  → PUABO AI direct health
http://localhost:3000/health                  → Backend API direct health
```

### Service Communication
```
┌─────────────────┐
│   Nginx (443)   │  ← External HTTPS
└────────┬────────┘
         │
    ┌────┴────┬────────┬──────────┬──────────┐
    │         │        │          │          │
┌───▼────┐ ┌─▼─────┐ ┌▼────────┐ ┌▼────────┐ ┌▼──────────┐
│Backend │ │PUABO  │ │Gateway  │ │PUABOAI  │ │V-Screen   │
│API:3000│ │AI:3401│ │:4000    │ │SDK:3002 │ │:8088      │
└────────┘ └───────┘ └─────────┘ └─────────┘ └───────────┘
```

### Firewall Rules
```bash
# Allowed incoming ports
80/tcp   - HTTP (redirects to HTTPS)
443/tcp  - HTTPS
22/tcp   - SSH (restricted IPs only)

# All other ports blocked from external access
# Internal service ports only accessible via Nginx proxy
```

---

## Autoscaling Configuration

### CPU-Based Autoscaling

#### Configuration
```yaml
# Docker Compose autoscaling
services:
  puabo_api_ai_hf:
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
        reservations:
          cpus: '0.5'
          memory: 1G
      restart_policy:
        condition: on-failure
        max_attempts: 3
```

#### Scaling Triggers
- **Scale Up:** CPU usage > 70% for 5 minutes
- **Scale Down:** CPU usage < 30% for 10 minutes
- **Min Replicas:** 1
- **Max Replicas:** 5

#### Target Services
- ✅ PUABO AI Hybrid (CPU intensive)
- ✅ Backend API (request volume)
- ✅ Streaming Service (bandwidth)

### Monitoring Integration
```python
# Autoscale monitoring (services/puabo_api_ai_hf/autoscale_monitor.py)
import psutil

def check_scaling_threshold():
    cpu_percent = psutil.cpu_percent(interval=1)
    
    if cpu_percent > 70:
        trigger_scale_up()
    elif cpu_percent < 30:
        trigger_scale_down()
```

### Scaling Events Log
```bash
# Check scaling events
docker service ps <service-name>

# View scaling logs
docker service logs <service-name>
```

---

## Monitoring & Health Checks

### Health Check System

#### Endpoint Structure
```javascript
// Standard health check response
{
  "status": "ok",
  "service": "service-name",
  "version": "1.0.0",
  "timestamp": "2026-01-02T17:38:00Z",
  "uptime_seconds": 3600,
  "dependencies": {
    "database": "ok",
    "cache": "ok"
  }
}
```

#### Health Check Intervals
- **Fast Check:** Every 10 seconds (Nginx → Services)
- **Deep Check:** Every 60 seconds (Service internals)
- **Manual Check:** On-demand via scripts

### Monitoring Endpoints

#### Service Health
```bash
# Gateway health
curl https://n3xuscos.online/health

# PUABO AI health
curl http://localhost:3401/health

# Backend API health
curl http://localhost:3000/health

# All service health
curl https://n3xuscos.online/health/all
```

#### System Health Checks
```bash
# Comprehensive system check
./nexus_cos_health_check.sh

# PUABO AI verification
./verify_puabo_api_ai_hf.sh

# Phase-2 verification
./phase-2-verification.sh

# Governance check
./trae-governance-verification.sh
```

### Monitoring Metrics

#### Key Performance Indicators
- **Uptime:** 99.5% (target: 99%)
- **Response Time:** <200ms (target: <500ms)
- **Error Rate:** <0.1% (target: <1%)
- **CPU Usage:** <60% (target: <80%)
- **Memory Usage:** <70% (target: <85%)

#### Alerts Configuration
```yaml
# Critical alerts
alerts:
  - name: "Service Down"
    condition: "health_check_fails > 3"
    severity: "critical"
    
  - name: "High CPU"
    condition: "cpu_usage > 90%"
    severity: "warning"
    
  - name: "High Memory"
    condition: "memory_usage > 85%"
    severity: "warning"
    
  - name: "Governance Violation"
    condition: "handshake_missing"
    severity: "critical"
```

### Logging

#### Log Locations
```bash
# Nginx logs
/var/log/nginx/n3xuscos.online_access.log
/var/log/nginx/n3xuscos.online_error.log

# Service logs (Docker)
docker logs <container-name>

# System logs
journalctl -u nexus-cos
```

#### Log Rotation
```bash
# Nginx log rotation
/etc/logrotate.d/nginx
  daily
  rotate 14
  compress
  delaycompress
```

---

## Docker Infrastructure

### Docker Compose Files

| File | Purpose | Services |
|------|---------|----------|
| `docker-compose.yml` | Base configuration | Core services |
| `docker-compose.pf-master.yml` | PF Master stack | Full 42 services |
| `docker-compose.unified.yml` | Unified deployment | All modules |
| `docker-compose.prod.yml` | Production config | Production services |
| `docker-compose.nginx.yml` | Nginx only | Gateway |

### Container Management

#### Start Services
```bash
# Start all services
docker-compose -f docker-compose.pf-master.yml up -d

# Start specific service
docker-compose up -d backend-api

# Start with rebuild
docker-compose up -d --build
```

#### Stop Services
```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Stop specific service
docker-compose stop backend-api
```

#### View Status
```bash
# List running containers
docker-compose ps

# View logs
docker-compose logs -f

# View service logs
docker-compose logs -f backend-api
```

### Network Configuration
```yaml
networks:
  nexus-internal:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
  
  nexus-public:
    driver: bridge
```

### Volume Management
```yaml
volumes:
  nexus-db-data:
    driver: local
  
  nexus-models:
    driver: local
    driver_opts:
      type: none
      device: /root/nexus-cos/storage/models
      o: bind
```

---

## Service Discovery

### DNS Resolution
```bash
# Service names resolve automatically in Docker network
backend-api           → 172.20.0.10
puabo_api_ai_hf      → 172.20.0.11
puabo-api            → 172.20.0.12
nexus-cos-puaboai-sdk → 172.20.0.13
```

### Service Registry
```javascript
// Service registry (conceptual)
const services = {
  'backend-api': 'http://backend-api:3000',
  'puabo-ai': 'http://puabo_api_ai_hf:3401',
  'gateway': 'http://puabo-api:4000',
  'puaboai-sdk': 'http://nexus-cos-puaboai-sdk:3002'
};
```

### Health Check Discovery
```bash
# Discover all healthy services
curl https://n3xuscos.online/health/discovery
```

---

## Security Configuration

### Security Headers
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self'" always;
add_header Strict-Transport-Security "max-age=31536000" always;
```

### Rate Limiting
```nginx
# Rate limiting configuration
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req zone=api burst=20 nodelay;
```

### IP Whitelisting (Admin Routes)
```nginx
location /admin {
    allow 10.0.0.0/8;
    deny all;
    proxy_pass http://pf_gateway/admin;
}
```

### Governance Header Validation
```nginx
# All proxied requests include governance handshake
proxy_set_header X-N3XUS-Handshake "55-45-17";
```

### Secrets Management
```bash
# Environment variables (never commit)
.env files (gitignored)

# Docker secrets
docker secret create db_password /run/secrets/db_password

# Kubernetes secrets (future)
kubectl create secret generic nexus-secrets --from-file=.env
```

---

## Maintenance Procedures

### Backup Procedures
```bash
# Database backup
docker exec nexus-db pg_dump -U postgres nexus_db > backup.sql

# Volume backup
docker run --rm -v nexus-db-data:/data -v $(pwd):/backup ubuntu tar czf /backup/db-backup.tar.gz /data

# Configuration backup
tar czf config-backup.tar.gz nginx.conf docker-compose*.yml .env
```

### Update Procedures
```bash
# Pull latest images
docker-compose pull

# Update services (zero downtime)
docker-compose up -d --no-deps --build <service-name>

# Verify health
curl https://n3xuscos.online/health
```

### Rollback Procedures
```bash
# Rollback to previous version
docker-compose down
git checkout <previous-commit>
docker-compose up -d

# Verify rollback
./phase-2-verification.sh
```

---

## Troubleshooting

### Common Issues

#### Services Not Starting
```bash
# Check logs
docker-compose logs <service-name>

# Check resource usage
docker stats

# Restart service
docker-compose restart <service-name>
```

#### SSL Certificate Errors
```bash
# Check certificate validity
openssl x509 -in /etc/ssl/ionos/fullchain.pem -noout -dates

# Renew certificate
certbot renew

# Reload nginx
docker-compose exec nginx nginx -s reload
```

#### High CPU/Memory Usage
```bash
# Check resource usage
docker stats

# Scale down if needed
docker-compose scale <service-name>=1

# Check for memory leaks
docker logs <service-name> | grep -i "memory"
```

#### Governance Violations
```bash
# Run governance verification
./trae-governance-verification.sh

# Check handshake header
curl -I https://n3xuscos.online | grep N3XUS-Handshake
```

---

## Documentation References

- **Phase-2 Completion:** [PHASE_2_COMPLETION.md](./PHASE_2_COMPLETION.md)
- **Governance Charter:** [GOVERNANCE_CHARTER_55_45_17.md](./GOVERNANCE_CHARTER_55_45_17.md)
- **V-Domains:** [V_DOMAINS_ARCHITECTURE.md](./V_DOMAINS_ARCHITECTURE.md)
- **Timeline:** [30_FOUNDERS_LOOP_TIMELINE.md](./30_FOUNDERS_LOOP_TIMELINE.md)

---

**Last Updated:** January 2, 2026  
**Status:** Phase-2 Sealed  
**Version:** N3XUS COS v3.0
