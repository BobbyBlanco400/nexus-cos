# SSL Configuration Guide for n3xuscos.online

## Overview

This guide provides comprehensive instructions for setting up and managing SSL certificates for the Nexus COS platform at n3xuscos.online. The SSL implementation includes automation scripts, security hardening, and validation tools for production deployment.

## 🔧 Quick Setup

### Prerequisites
- Ubuntu/Debian server with root/sudo access
- Nginx web server installed
- SSL certificates (from IONOS or other CA)
- Domain pointing to your server

### Installation Commands
```bash
# 1. Install and configure SSL
sudo ./puabo_fix_nginx_ssl.sh

# 2. Validate configuration
sudo ./test_ssl_config.sh
```

## 📁 File Structure

The SSL configuration uses the following directory structure:

```
/etc/ssl/ionos/
├── fullchain.pem      # SSL certificate chain (644 permissions)
└── privkey.pem        # Private key (600 permissions)

/var/www/n3xuscos.online/
└── html/              # Web root directory

/var/log/nginx/
├── n3xuscos.online_access.log
└── n3xuscos.online_error.log

/etc/nginx/sites-available/
└── n3xuscos.online.conf    # Nginx SSL configuration
```

## 🛠️ Automation Scripts

### puabo_fix_nginx_ssl.sh
**Purpose**: Automates SSL certificate installation and Nginx configuration

**Features**:
- Creates SSL directory structure
- Copies certificates from /tmp to secure location
- Sets proper file permissions (600 for private key, 644 for certificate)
- Generates Nginx configuration with modern SSL settings
- Enables HTTP to HTTPS redirect
- Configures domain-specific logging
- Tests and reloads Nginx

**Usage**:
```bash
# Place certificates in /tmp/
sudo cp your-certificate.crt /tmp/n3xuscos.online.crt
sudo cp your-private-key.key /tmp/n3xuscos.online.key

# Run installation script
sudo ./puabo_fix_nginx_ssl.sh
```

### test_ssl_config.sh
**Purpose**: Comprehensive SSL configuration validation

**Validation Points**:
- ✅ Certificate presence and validity
- ✅ Private key security and permissions
- ✅ Nginx configuration syntax
- ✅ HTTPS accessibility
- ✅ HTTP to HTTPS redirect
- ✅ Security headers implementation
- ✅ Domain-specific logging
- ✅ Certificate chain verification

**Usage**:
```bash
sudo ./test_ssl_config.sh
```

## 🔒 Security Features

### TLS Configuration
- **Protocols**: TLS 1.2 and TLS 1.3 only
- **Cipher Suites**: Modern, secure ciphers with Perfect Forward Secrecy
- **Session Management**: Optimized caching and timeout settings

```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-GCM-SHA256';
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
```

### Security Headers
- **HSTS**: Strict-Transport-Security for HTTPS enforcement
- **X-Frame-Options**: Clickjacking protection
- **X-Content-Type-Options**: MIME-type sniffing protection
- **X-XSS-Protection**: Cross-site scripting protection
- **CSP**: Content Security Policy for additional protection

### File Security
- Private keys stored with 600 permissions (owner read/write only)
- Certificates with 644 permissions (world-readable)
- Web root owned by www-data:www-data
- SSL directory protected with appropriate permissions

## 🌐 Nginx Configuration

### HTTP to HTTPS Redirect
```nginx
server {
    listen 80;
    server_name n3xuscos.online www.n3xuscos.online;
    return 301 https://$host$request_uri;
}
```

### HTTPS Server Block
```nginx
server {
    listen 443 ssl http2;
    server_name n3xuscos.online www.n3xuscos.online;
    
    ssl_certificate     /etc/ssl/ionos/fullchain.pem;
    ssl_certificate_key /etc/ssl/ionos/privkey.pem;
    
    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    # ... additional SSL settings
    
    root /var/www/n3xuscos.online/html;
    index index.html index.htm;
    
    # Domain-specific logging
    access_log /var/log/nginx/n3xuscos.online_access.log;
    error_log /var/log/nginx/n3xuscos.online_error.log;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Certificate Files Not Found
**Symptoms**: SSL test fails, HTTPS not accessible
**Solution**:
```bash
# Check if certificates exist
ls -la /etc/ssl/ionos/
# If missing, place certificates in /tmp and run setup
sudo ./puabo_fix_nginx_ssl.sh
```

#### 2. Permission Denied Errors
**Symptoms**: Nginx fails to start, SSL errors in logs
**Solution**:
```bash
# Fix permissions
sudo chmod 600 /etc/ssl/ionos/privkey.pem
sudo chmod 644 /etc/ssl/ionos/fullchain.pem
sudo chown -R www-data:www-data /var/www/n3xuscos.online/
```

#### 3. Nginx Configuration Errors
**Symptoms**: nginx -t fails, service won't start
**Solution**:
```bash
# Test configuration
sudo nginx -t
# Check syntax errors and fix manually or re-run setup
sudo ./puabo_fix_nginx_ssl.sh
```

#### 4. HTTPS Not Accessible
**Symptoms**: Browser shows connection errors
**Solution**:
```bash
# Check Nginx status
sudo systemctl status nginx
# Check if port 443 is open
sudo netstat -tlnp | grep :443
# Check firewall
sudo ufw status
```

#### 5. Certificate Expired or Invalid
**Symptoms**: Browser warnings, validation failures
**Solution**:
```bash
# Check certificate validity
openssl x509 -in /etc/ssl/ionos/fullchain.pem -noout -dates
# Replace with new certificate and re-run setup
```

### Log Analysis

#### Check SSL-specific logs:
```bash
# Nginx error log
sudo tail -f /var/log/nginx/error.log

# Domain-specific logs
sudo tail -f /var/log/nginx/n3xuscos.online_error.log
sudo tail -f /var/log/nginx/n3xuscos.online_access.log

# System SSL logs
sudo journalctl -u nginx -f
```

#### Common log entries:
- `SSL_do_handshake() failed`: Usually certificate or configuration issue
- `no "ssl_certificate" is defined`: Missing certificate path in config
- `cannot load certificate`: Permission or file path issue

## 📋 Maintenance Checklist

### Regular Tasks
- [ ] Monitor certificate expiration (30-day warning)
- [ ] Review SSL logs for errors
- [ ] Update cipher suites as needed
- [ ] Test HTTPS accessibility
- [ ] Verify security headers
- [ ] Check file permissions
- [ ] Update documentation

### Certificate Renewal Process
1. Obtain new certificate from provider
2. Place new files in /tmp/
3. Run: `sudo ./puabo_fix_nginx_ssl.sh`
4. Validate: `sudo ./test_ssl_config.sh`
5. Monitor logs for issues

## 🚀 Production Deployment

### Pre-deployment Checklist
- [ ] SSL certificates obtained and validated
- [ ] DNS pointing to server
- [ ] Firewall configured (ports 80, 443 open)
- [ ] Nginx installed and running
- [ ] Scripts tested in staging environment

### Deployment Steps
1. Upload certificates to server
2. Run SSL setup: `sudo ./puabo_fix_nginx_ssl.sh`
3. Validate configuration: `sudo ./test_ssl_config.sh`
4. Test from external browser
5. Monitor logs for 24 hours

### Post-deployment Verification
- [ ] HTTPS accessible from multiple locations
- [ ] HTTP properly redirects to HTTPS
- [ ] Security headers present
- [ ] No SSL errors in logs
- [ ] Certificate chain validates
- [ ] Performance acceptable

## 🔗 Best Practices

### Security
- Use strong certificates from reputable CAs
- Keep private keys secure (600 permissions)
- Regularly update cipher suites
- Monitor for security vulnerabilities
- Use HSTS for additional security
- Implement proper CSP headers

### Performance
- Enable HTTP/2 for better performance
- Use session caching for SSL
- Implement proper gzip compression
- Optimize cipher suite order
- Monitor SSL handshake performance

### Monitoring
- Set up certificate expiration alerts
- Monitor SSL-related errors
- Track HTTPS adoption metrics
- Monitor security header compliance
- Regular security scans

## 📞 Support

For issues with SSL configuration:
1. Run the validation script: `sudo ./test_ssl_config.sh`
2. Check the troubleshooting section above
3. Review nginx logs for specific errors
4. Ensure all prerequisites are met

## 📚 References

- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
- [SSL Labs Server Test](https://www.ssllabs.com/ssltest/)
- [Nginx SSL Module Documentation](https://nginx.org/en/docs/http/ngx_http_ssl_module.html)
- [OWASP Transport Layer Protection](https://owasp.org/www-project-cheat-sheets/cheatsheets/Transport_Layer_Protection_Cheat_Sheet.html)

---

*This documentation is part of the Nexus COS SSL configuration for n3xuscos.online*