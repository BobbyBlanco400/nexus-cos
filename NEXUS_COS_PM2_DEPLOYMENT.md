# Nexus COS Automated Deployment Guide

This document provides comprehensive instructions for deploying Nexus COS backend services using PM2 process management and Nginx with dynamic API routing.

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Deployment](#deployment)
5. [Health Checks](#health-checks)
6. [Monitoring](#monitoring)
7. [Troubleshooting](#troubleshooting)

## System Requirements

- Ubuntu 20.04 LTS or higher
- Node.js 18.x or higher
- Python 3.8 or higher
- MongoDB 6.0 or higher
- Redis 6.x or higher
- Nginx 1.18 or higher

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/nexus-cos.git
   cd nexus-cos
   ```

2. Make the deployment scripts executable:
   ```bash
   chmod +x nexus-cos-setup.sh
   chmod +x test-api-endpoints.sh
   chmod +x generate-nginx-config.py
   ```

## Configuration

### Service Configuration (nexus-cos-services.yml)

The `nexus-cos-services.yml` file defines all backend services and their deployment settings. Example configuration:

```yaml
services:
  nexus-backend:
    name: nexus-backend-node
    script: ./backend/server.js
    port: 3001
    interpreter: node
    env:
      PORT: 3001
      DATABASE_URL: mongodb://127.0.0.1:27017/nexus-cos

  # Additional service configurations...

nginx:
  ssl:
    enabled: true
    cert_path: /etc/ssl/certs/nexus-cos.crt
    key_path: /etc/ssl/private/nexus-cos.key
```

### Environment Variables

Create appropriate `.env` files for different environments:

- `.env.production`: Production environment variables
- `.env.staging`: Staging environment variables
- `.env.development`: Development environment variables

## Deployment

### Automated Deployment

1. Run the deployment script:
   ```bash
   sudo ./nexus-cos-setup.sh
   ```

   This script will:
   - Install all required dependencies
   - Set up directory structure
   - Create backups of existing deployment
   - Configure PM2 processes
   - Generate and apply Nginx configuration
   - Perform health checks

2. Verify deployment:
   ```bash
   ./test-api-endpoints.sh
   ```

### Manual Steps (if needed)

1. Generate Nginx configuration:
   ```bash
   python3 generate-nginx-config.py nexus-cos-services.yml > /etc/nginx/sites-available/nexus-cos.conf
   ln -s /etc/nginx/sites-available/nexus-cos.conf /etc/nginx/sites-enabled/
   nginx -t && systemctl reload nginx
   ```

2. Start services individually:
   ```bash
   pm2 start nexus-cos-services.yml
   pm2 save
   pm2 startup
   ```

## Health Checks

The `test-api-endpoints.sh` script performs comprehensive health checks:

- PM2 process status
- Service health endpoints
- API endpoint functionality
- Database connectivity
- Redis connectivity

Run health checks:
```bash
./test-api-endpoints.sh
```

## Monitoring

### PM2 Monitoring

1. View process status:
   ```bash
   pm2 list
   ```

2. Monitor logs:
   ```bash
   pm2 logs
   ```

3. Monitor metrics:
   ```bash
   pm2 monit
   ```

### Nginx Monitoring

1. Access logs:
   ```bash
   tail -f /var/log/nginx/access.log
   ```

2. Error logs:
   ```bash
   tail -f /var/log/nginx/error.log
   ```

## Troubleshooting

### Common Issues

1. **Service Won't Start**
   - Check PM2 logs: `pm2 logs [service-name]`
   - Verify environment variables
   - Check port availability: `netstat -tulpn | grep [port]`

2. **Nginx Configuration Errors**
   - Validate configuration: `nginx -t`
   - Check SSL certificate paths
   - Verify port configurations

3. **Database Connection Issues**
   - Check MongoDB status: `systemctl status mongod`
   - Verify connection string in environment variables
   - Check database logs: `tail -f /var/log/mongodb/mongod.log`

4. **Health Check Failures**
   - Review service logs: `pm2 logs`
   - Check endpoint accessibility: `curl -v http://localhost:[port]/health`
   - Verify service dependencies are running

### Recovery Procedures

1. **Rollback Deployment**
   ```bash
   # Stop current services
   pm2 delete all
   
   # Restore backup
   cd /var/backups/nexus-cos
   tar -xzf nexus-cos-[timestamp].tar.gz -C /var/www/nexus-cos
   
   # Restart services
   cd /var/www/nexus-cos
   ./nexus-cos-setup.sh
   ```

2. **Reset PM2 Configuration**
   ```bash
   pm2 delete all
   pm2 kill
   pm2 cleardump
   pm2 resurrect
   ```

3. **Regenerate Nginx Configuration**
   ```bash
   python3 generate-nginx-config.py nexus-cos-services.yml > /etc/nginx/sites-available/nexus-cos.conf
   nginx -t && systemctl reload nginx
   ```

## Security Considerations

1. **SSL/TLS Configuration**
   - Keep certificates up to date
   - Use strong cipher suites
   - Enable HSTS if applicable

2. **Access Control**
   - Implement rate limiting
   - Use secure headers
   - Configure firewall rules

3. **Monitoring and Logging**
   - Set up log rotation
   - Monitor resource usage
   - Configure alerts for critical events

## Support

For additional support or to report issues:

1. Check the [GitHub Issues](https://github.com/your-org/nexus-cos/issues)
2. Contact the development team
3. Review system logs and monitoring dashboards

## License

This deployment system is proprietary and confidential.
Copyright (c) 2025 Your Organization. All rights reserved.