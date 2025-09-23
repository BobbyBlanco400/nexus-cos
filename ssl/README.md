# SSL Configuration for Nexus COS

## Current Status
- SSL directory structure created
- Basic SSL configuration file created
- Environment variables configured for SSL support

## SSL Certificate Setup

### For Development (Self-Signed)
To create self-signed certificates for local development:

1. **Using OpenSSL (Recommended)**:
   ```bash
   # Generate private key
   openssl genrsa -out ssl/localhost.key 2048
   
   # Generate certificate
   openssl req -new -x509 -key ssl/localhost.key -out ssl/localhost.crt -days 365 -subj "/C=US/ST=Development/L=Local/O=Nexus COS/CN=localhost"
   ```

2. **Using PowerShell (Windows)**:
   ```powershell
   # Run as Administrator
   $cert = New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation "cert:\LocalMachine\My"
   # Export certificate and key manually
   ```

### For Production
- Use Let's Encrypt with Certbot
- Configure automatic renewal
- Update nginx configuration with proper certificate paths

## Environment Variables
The following SSL-related environment variables are configured:

- `SSL_ENABLED=true` - Enable SSL support
- `SSL_CERT_PATH=./ssl/localhost.crt` - Certificate file path
- `SSL_KEY_PATH=./ssl/localhost.key` - Private key file path
- `HTTPS_PORT=443` - HTTPS port

## Next Steps
1. Install OpenSSL or generate certificates using alternative methods
2. Update nginx configuration to use SSL
3. Test HTTPS connectivity
4. Configure certificate auto-renewal for production

## Files Created
- `ssl-params.conf` - Nginx SSL configuration
- `README.md` - This documentation file