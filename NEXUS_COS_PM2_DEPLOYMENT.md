# Nexus COS PM2/Nginx Automated Deployment

This directory contains a fully automated deployment system for Nexus COS backend services using PM2 process management and dynamic Nginx configuration.

## 📋 Files Overview

- **`nexus-cos-services.yml`** - Service configuration file defining all backend services
- **`nexus-cos-setup.sh`** - Main deployment script that automates the entire setup
- **`test-api-endpoints.sh`** - Health check and API testing script

## 🚀 Quick Start

1. **Deploy all services:**
   ```bash
   sudo ./nexus-cos-setup.sh
   ```

2. **Test all endpoints:**
   ```bash
   ./test-api-endpoints.sh
   ```

3. **View PM2 processes:**
   ```bash
   pm2 list
   pm2 logs
   ```

## ⚙️ Configuration

### Service Configuration (`nexus-cos-services.yml`)

The YAML file defines all backend services with their ports and configuration:

```yaml
services:
  - name: nexus-backend          # Service name for API routing
    script: backend/src/server.ts # Entry point script
    interpreter: ts-node          # Runtime interpreter
    port: 3001                   # Service port (avoid conflicts)
    pm2_name: nexus-backend      # PM2 process name
    # ... additional configuration
```

### Nginx Routing

The deployment script automatically generates Nginx configuration with:

- **Frontend serving:** Static files from `/var/www/nexus-cos`
- **API routing:** `/api/<service-name>/` → `http://localhost:<port>/`
- **SSL support:** HTTPS redirect and certificate configuration
- **Security headers:** XSS protection, frame options, etc.

## 📊 Service Architecture

| Service Name | Port | API Route | Description |
|-------------|------|-----------|-------------|
| nexus-backend | 3001 | `/api/nexus-backend/` | Main Node.js backend |
| nexus-cos-api | 3002 | `/api/nexus-cos-api/` | Python FastAPI backend |
| boomroom-backend | 3003 | `/api/boomroom-backend/` | V-Suite module |
| creator-hub | 3020 | `/api/creator-hub/` | Content creation platform |
| puaboverse | 3030 | `/api/puaboverse/` | Virtual environment module |

## 🔧 Advanced Usage

### Custom Configuration

Modify `nexus-cos-services.yml` to:
- Add new services
- Change port assignments
- Update environment variables
- Modify PM2 settings

### Manual Service Management

```bash
# Start individual service
pm2 start nexus-backend

# Stop all services
pm2 stop all

# Restart specific service
pm2 restart nexus-cos-api

# View logs for specific service
pm2 logs nexus-backend --lines 50

# Monitor real-time
pm2 monit
```

### Nginx Management

```bash
# Test nginx configuration
sudo nginx -t

# Reload nginx (after config changes)
sudo systemctl reload nginx

# View nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## 🔍 Health Checks

### Automated Testing

The `test-api-endpoints.sh` script provides comprehensive health checking:

```bash
# Run all health checks
./test-api-endpoints.sh

# Quick check only
./test-api-endpoints.sh --quick

# Verbose output
./test-api-endpoints.sh --verbose
```

### Manual Health Checks

```bash
# Direct service check
curl http://localhost:3001/health

# Via nginx proxy
curl http://localhost/api/nexus-backend/health

# Check all services
for port in 3001 3002 3003 3020 3030; do
  echo "Testing port $port:"
  curl -s "http://localhost:$port/health" | jq .
done
```

## 🛠️ Troubleshooting

### Port Conflicts

If ports are already in use:
```bash
# Find process using port
sudo lsof -i :3001

# Kill process
sudo kill -9 <PID>

# Or let the script handle it automatically
sudo ./nexus-cos-setup.sh
```

### PM2 Issues

```bash
# Check PM2 status
pm2 status

# Clear PM2 logs
pm2 flush

# Resurrect saved processes
pm2 resurrect

# Reset PM2
pm2 kill
pm2 resurrect
```

### Nginx Issues

```bash
# Check nginx status
sudo systemctl status nginx

# Test configuration
sudo nginx -t

# View error logs
sudo tail -f /var/log/nginx/error.log
```

## 🔒 Security Features

- **SSL/TLS:** Automatic HTTPS redirect and certificate support
- **Security Headers:** XSS protection, frame options, content type validation
- **Process Isolation:** Each service runs in its own PM2 process
- **Access Control:** Nginx-level request filtering and rate limiting

## 📈 Monitoring

### PM2 Monitoring

```bash
# Real-time monitoring
pm2 monit

# Process metrics
pm2 show nexus-backend

# Memory usage
pm2 list --sort memory
```

### Log Management

```bash
# View all logs
pm2 logs

# Follow specific service
pm2 logs nexus-backend --follow

# Log rotation (automatically handled)
pm2 install pm2-logrotate
```

## 🚀 Production Deployment

### Boot Persistence

The deployment script automatically configures:
- PM2 startup on system boot
- Process resurrection after restart
- Automatic service recovery

### SSL Certificate Setup

For production with SSL:
```bash
# Install certbot (if not already installed)
sudo apt install certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d nexuscos.online -d www.nexuscos.online

# Test auto-renewal
sudo certbot renew --dry-run
```

### Environment Variables

Set production environment variables:
```bash
export NODE_ENV=production
export DATABASE_URL=postgresql://user:pass@localhost:5432/nexus_cos
export JWT_SECRET=your-secret-key
```

## 📋 Deployment Checklist

- [ ] Configure `nexus-cos-services.yml` for your environment
- [ ] Ensure all service scripts exist and are executable
- [ ] Install required dependencies (Node.js, Python, nginx)
- [ ] Run `sudo ./nexus-cos-setup.sh`
- [ ] Test endpoints with `./test-api-endpoints.sh`
- [ ] Configure SSL certificates for production
- [ ] Set up monitoring and log rotation
- [ ] Configure firewall rules if needed

## 🤝 Contributing

To add a new service:

1. Add service configuration to `nexus-cos-services.yml`
2. Ensure the service has a `/health` endpoint returning `{"status": "ok"}`
3. Run the deployment script to update configuration
4. Test the new service with the health check script

---

**🎯 Ready for Copilot:** This deployment system is designed to be Copilot-friendly with clear configuration, automated setup, and comprehensive testing.