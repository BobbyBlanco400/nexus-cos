# PUABO Service Architecture

## Active Services and Port Mappings

### Core Services
1. **Driver App Backend**
   - Service Name: `puabo-nexus-driver-app-backend`
   - Port: 3000
   - Status: Online
   - Memory Usage: 59.5MB
   - Process Type: Node.js

2. **Fleet Manager**
   - Service Name: `puabo-nexus-fleet-manager`
   - Port: 3240
   - Status: Online
   - Memory Usage: 59.2MB
   - Process Type: Node.js

3. **Route Optimizer**
   - Service Name: `puabo-nexus-route-optimizer`
   - Port: 3220
   - Status: Online
   - Memory Usage: 58.8MB
   - Process Type: Node.js

### NUKI Services
1. **Inventory Manager**
   - Service Name: `puabo-nuki-inventory-mgr`
   - Port: 3230
   - Status: Online
   - Memory Usage: 59.5MB
   - Process Type: Node.js

2. **Order Processor**
   - Service Name: `puabo-nuki-order-processor`
   - Status: Online
   - Memory Usage: 59.3MB
   - Process Type: Node.js

3. **Product Catalog**
   - Service Name: `puabo-nuki-product-catalog`
   - Status: Online
   - Memory Usage: 59.7MB
   - Process Type: Node.js

4. **Shipping Service**
   - Service Name: `puabo-nuki-shipping-service`
   - Status: Online
   - Memory Usage: 58.9MB
   - Process Type: Node.js

### Docker Services
- Port 3002: Docker proxy service (both IPv4 and IPv6)

## Service Health Status
All services are currently running and healthy, with:
- CPU Usage: ~0% (idle)
- Memory Usage: Stable (~59MB per service)
- Process Management: PM2
- Process Type: Fork mode with 8 instances each

## Port Bindings
- **IPv4 (0.0.0.0)**
  - 3002: Docker proxy service

- **IPv6 (:::)**
  - 3000: Driver App Backend
  - 3220: Route Optimizer
  - 3230: Inventory Manager
  - 3240: Fleet Manager
  - 3002: Docker proxy service

## Verification Status
The verification script confirms:
1. PM2 services are running properly
2. Database tables are accessible
3. Owner account exists and is properly configured
4. System resources are healthy
5. TCP connectivity is established for port 3000

## Notes
- All Node.js services are managed by PM2 in fork mode
- Each service runs with 8 instances for load balancing
- Services have been running for approximately 4 hours
- Memory usage is consistent across services (~59MB)
- All services are configured with disabled auto-restart

## Docker Container Health Status

### Infrastructure Containers
- **MongoDB (nexus-cos-mongodb)**
  - Status: Running
  - Health: Healthy
  - Role: Primary database

- **Redis (nexus-cos-redis)**
  - Status: Running
  - Health: Healthy
  - Role: Caching and session management

### Service Containers
1. **AI SDK (nexus-cos-puaboai-sdk)**
   - Port: 3002
   - Status: Running
   - Health: Unhealthy
   - Notes: Port binding verified, but health check failing

2. **Music Chain (nexus-cos-puabomusicchain)**
   - Port: 3003
   - Status: Running
   - Health: Unhealthy
   - Notes: Port binding verified, but health check failing

3. **Frontend (nexus-frontend)**
   - Port: 3030
   - Status: Running
   - Health: Healthy
   - Notes: Port binding verified

4. **Backend (nexus-cos-backend)**
   - Port: 8000
   - Status: Running
   - Health: Unhealthy
   - Notes: Port binding verified, but health check failing

5. **V-Stage (nexus-cos-v-stage)**
   - Port: 5100
   - Status: Running
   - Health: Unhealthy
   - Notes: Port binding verified, but health check failing

6. **V-Screen (nexus-cos-v-screen)**
   - Port: 3045
   - Status: Running
   - Health: Unhealthy
   - Notes: Port binding verified, but health check failing

7. **V-Caster (nexus-cos-v-caster)**
   - Port: 3040
   - Status: Running
   - Health: Unhealthy
   - Notes: Port binding verified, but health check failing

8. **Stream Core (nexus-cos-streamcore)**
   - Port: 3060
   - Status: Running
   - Health: Unhealthy
   - Notes: Port binding verified, but health check failing

9. **PV Keys (nexus-cos-pv-keys)**
   - Port: 3050
   - Status: Running
   - Health: Unhealthy
   - Notes: Port binding verified, but health check failing

### Health Check Summary
- Infrastructure containers (MongoDB, Redis) are healthy and functioning properly
- All service containers are running and have correct port bindings
- 8 out of 9 service containers are reporting as unhealthy
- Frontend container is the only service container reporting as healthy

### Recommendations
1. Review Docker health check configurations for each unhealthy container
2. Check container logs for error messages or startup issues
3. Verify that all required dependencies and services are available
4. Consider implementing more detailed health checks to identify specific issues
5. Monitor resource usage to ensure containers have adequate resources