# NEXUS COS Modular OS - Deployment Guide

## Overview

NEXUS COS is now organized as a complete modular, dockerized operating system that integrates all components of the creative ecosystem. This deployment guide covers the setup and management of the entire system.

## System Architecture

### Core Components

1. **PUABO OS V200 Core Modules** (9 modules)
   - PUABO AI SDK
   - V-Caster
   - StreamCore
   - V-Screen (with V-Prompter Pro & Hollywood Edition)
   - V-Stage
   - PV-Keys
   - PUABO MusicChain
   - Glitch: Code of Chaos
   - PUABO OS Core

2. **Frontend Applications** (11 apps)
   - Admin Panel
   - Creator Dashboard
   - Creator Hub
   - Dev Center
   - Lending (BLAC ALT)
   - Music Manager
   - Payments
   - Publishing
   - Streaming (PUABO TV & Radio)
   - Studio
   - Terminal

3. **Backend Microservices** (9 services)
   - API Gateway
   - User Management
   - Content Management
   - Streaming Service
   - TV & Radio Service
   - Music & Media Service
   - Monetization Service
   - BLAC Service
   - Analytics Service
   - Admin Service

## Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- 16GB RAM minimum (32GB recommended)
- 100GB free disk space
- Network ports 80, 443, 3000-3110, 5432, 6379, 27017, 8500, 9090

### Initial Setup

1. **Clone and Navigate**
   ```bash
   cd c:\Users\wecon\Downloads\nexus-cos-main
   ```

2. **Create Required Networks**
   ```bash
   docker network create nexus-cos-network --driver bridge --subnet=172.20.0.0/16
   ```

3. **Start Core Infrastructure**
   ```bash
   docker-compose -f nexus-cos-modular-os.yml up -d
   ```

4. **Start Backend Services**
   ```bash
   docker-compose -f backend-services-compose.yml up -d
   ```

5. **Start Frontend Applications**
   ```bash
   docker-compose -f frontend-apps-compose.yml up -d
   ```

6. **Start Nginx Proxy**
   ```bash
   docker run -d --name nexus-proxy \
     --network nexus-cos-network \
     -p 80:80 -p 443:443 \
     -v $(pwd)/nginx/nexus-proxy.conf:/etc/nginx/nginx.conf \
     nginx:alpine
   ```

## Service Access Points

### Frontend Applications
- **Main Dashboard**: http://localhost/
- **Admin Panel**: http://localhost/admin
- **Creator Hub**: http://localhost/hub
- **Studio (V-Screen/V-Stage)**: http://localhost/studio
- **Streaming**: http://localhost/streaming
- **Music Manager**: http://localhost/music
- **Dev Center**: http://localhost/dev
- **Terminal**: http://localhost/terminal
- **Payments**: http://localhost/payments
- **Publishing**: http://localhost/publishing
- **Lending**: http://localhost/lending

### API Endpoints
- **Main API Gateway**: http://localhost/api
- **PUABO AI SDK**: http://localhost/api/ai
- **V-Screen API**: http://localhost/api/vscreen
- **V-Stage API**: http://localhost/api/vstage
- **StreamCore API**: http://localhost/api/streamcore
- **V-Caster API**: http://localhost/api/vcaster
- **PV-Keys API**: http://localhost/api/pvkeys
- **MusicChain API**: http://localhost/api/musicchain

### Monitoring & Management
- **Service Registry**: http://localhost/consul
- **Frontend Registry**: http://localhost/frontend-consul
- **Metrics**: http://localhost/metrics
- **Monitoring Dashboard**: http://localhost/monitoring
- **System Health**: http://localhost/health

## Environment Configuration

### Database Credentials
```env
POSTGRES_USER=nexus_admin
POSTGRES_PASSWORD=nexus_secure_2025
POSTGRES_DB=nexus_cos

MONGO_USER=nexus_admin
MONGO_PASSWORD=nexus_secure_2025
MONGO_DB=nexus_content

JWT_SECRET=nexus_jwt_secret_2025
```

### V-Screen Features
```env
V_PROMPTER_PRO_ENABLED=true
HOLLYWOOD_EDITION_ENABLED=true
TELEPROMPTER_FEATURES=advanced
VIRTUAL_SETS_ENABLED=true
```

### Blockchain Configuration
```env
BLOCKCHAIN_ENABLED=true
NFT_MINTING_ENABLED=true
WEB3_PROVIDER_URL=http://localhost:8545
```

## Scaling and Load Balancing

### Horizontal Scaling
```bash
# Scale frontend applications
docker-compose -f frontend-apps-compose.yml up -d --scale creator-dashboard-app=3

# Scale backend services
docker-compose -f backend-services-compose.yml up -d --scale nexus-streaming-service=2
```

### Load Balancer Configuration
The nginx proxy automatically load balances between scaled instances. Update `nginx/nexus-proxy.conf` for custom load balancing strategies.

## Monitoring and Health Checks

### Health Check Endpoints
- All services expose `/health` endpoints
- Automatic health checks every 30 seconds
- Failed services automatically restart

### Monitoring Stack
- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **Consul**: Service discovery and health monitoring

### Log Management
```bash
# View all logs
docker-compose -f nexus-cos-modular-os.yml logs -f

# View specific service logs
docker logs nexus-api-gateway
docker logs v-screen-service
```

## Backup and Recovery

### Database Backups
```bash
# PostgreSQL backup
docker exec nexus-postgres pg_dump -U nexus_admin nexus_cos > backup_postgres.sql

# MongoDB backup
docker exec nexus-mongodb mongodump --username nexus_admin --password nexus_secure_2025 --out /backup
```

### Volume Backups
```bash
# Backup all volumes
docker run --rm -v nexus-cos-main_postgres-data:/data -v $(pwd):/backup alpine tar czf /backup/postgres-data.tar.gz /data
```

## Security Configuration

### SSL/TLS Setup
1. Generate certificates:
   ```bash
   mkdir -p nginx/ssl
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout nginx/ssl/nexus-cos.key \
     -out nginx/ssl/nexus-cos.crt
   ```

2. Uncomment HTTPS section in `nginx/nexus-proxy.conf`

### Firewall Configuration
```bash
# Allow only necessary ports
ufw allow 80/tcp
ufw allow 443/tcp
ufw deny 3000:3110/tcp
```

## Troubleshooting

### Common Issues

1. **Port Conflicts**
   ```bash
   # Check port usage
   netstat -tulpn | grep :80
   
   # Stop conflicting services
   sudo systemctl stop apache2
   ```

2. **Memory Issues**
   ```bash
   # Increase Docker memory limit
   # Edit Docker Desktop settings or /etc/docker/daemon.json
   ```

3. **Network Issues**
   ```bash
   # Recreate network
   docker network rm nexus-cos-network
   docker network create nexus-cos-network --driver bridge --subnet=172.20.0.0/16
   ```

### Service Dependencies
- Frontend apps depend on backend services
- Backend services depend on databases
- All services depend on the network

### Recovery Procedures
```bash
# Full system restart
docker-compose -f nexus-cos-modular-os.yml down
docker-compose -f backend-services-compose.yml down
docker-compose -f frontend-apps-compose.yml down

# Clean restart
docker system prune -f
docker volume prune -f

# Restart in order
docker-compose -f nexus-cos-modular-os.yml up -d
docker-compose -f backend-services-compose.yml up -d
docker-compose -f frontend-apps-compose.yml up -d
```

## Development Mode

### Hot Reload Setup
```bash
# Mount source code for development
docker-compose -f nexus-cos-modular-os.yml -f docker-compose.dev.yml up -d
```

### Debug Mode
```bash
# Enable debug logging
export DEBUG=nexus:*
docker-compose up -d
```

## Production Deployment

### Performance Optimization
1. Use production Docker images
2. Enable gzip compression
3. Configure CDN for static assets
4. Implement Redis caching
5. Use read replicas for databases

### High Availability
1. Deploy across multiple nodes
2. Use external load balancers
3. Implement database clustering
4. Set up automated failover

## API Documentation

### Core APIs
- **Authentication**: `/api/auth`
- **Users**: `/api/users`
- **Content**: `/api/content`
- **Streaming**: `/api/streaming`
- **Analytics**: `/api/analytics`

### V-Screen APIs
- **Teleprompter**: `/api/vscreen/prompter`
- **Hollywood Effects**: `/api/vscreen/hollywood`
- **Virtual Sets**: `/api/vstage/sets`
- **Live Streaming**: `/api/vstage/live`

### Blockchain APIs
- **NFT Minting**: `/api/musicchain/nft`
- **Smart Contracts**: `/api/musicchain/contracts`
- **Wallet Integration**: `/api/musicchain/wallet`

## Support and Maintenance

### Regular Maintenance
1. Update Docker images monthly
2. Backup databases weekly
3. Monitor disk usage daily
4. Review logs weekly
5. Update SSL certificates annually

### Performance Monitoring
- CPU usage < 80%
- Memory usage < 85%
- Disk usage < 90%
- Response time < 2s

### Contact Information
- **System Admin**: admin@nexus-cos.local
- **Developer Support**: dev@nexus-cos.local
- **Emergency**: emergency@nexus-cos.local

---

**NEXUS COS Modular OS v2025.1**  
*Complete Creative Operating System*  
*Dockerized • Scalable • Production-Ready*