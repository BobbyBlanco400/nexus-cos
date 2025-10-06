# Nexus COS - Next Steps After Deployment

## 🎉 Current Deployment Status

The deployment has been successfully completed by the Pre-Flight (PF) team. Here's what's live:

### ✅ What's Working

- **Application Status**: Running under PM2 on `0.0.0.0:3000`
- **HTTPS Access**: Available at https://nexuscos.online/
- **Health Endpoint**: https://nexuscos.online/health returns 200 with JSON
- **Root Domain**: https://nexuscos.online/ serves content (frontend or fallback)
- **PM2 Process**: Configured for auto-restart and reboot persistence
- **Nginx Configuration**: Properly configured with SSL/TLS
- **Security**: HTTPS enforced, security headers configured

### ⚠️ Known Issues

#### Database Connectivity
- **Status**: `db: "down"` 
- **Reason**: PM2 was caching old environment variables (`DB_HOST=admin`)
- **Impact**: Application runs but cannot connect to database
- **FIX AVAILABLE**: See **PM2_DB_FIX_DEPLOYMENT.md** for immediate resolution

## 🔧 Required Next Steps

### ⚡ QUICK FIX (RECOMMENDED - 3 minutes)

**The PM2 environment variable issue has been FIXED!**

Run this one-liner on the server:
```bash
cd /opt/nexus-cos && bash fix-db-deploy.sh
```

Or follow the complete guide: **[PM2_DB_FIX_DEPLOYMENT.md](PM2_DB_FIX_DEPLOYMENT.md)**

---

### 1. Database Configuration (Priority: HIGH)

You need to configure the database connection. Choose one of the following options:

#### Option A: Local PostgreSQL (Recommended for Production)

If PostgreSQL is installed on the same server:

```bash
# Update .env file
DB_HOST=localhost
DB_PORT=5432
DB_NAME=nexuscos_db
DB_USER=nexuscos
DB_PASSWORD=your_secure_password
```

#### Option B: Remote PostgreSQL Server

If using a remote PostgreSQL server:

```bash
# Update .env file with actual server details
DB_HOST=your-db-host.example.com  # or IP address like 192.168.1.100
DB_PORT=5432
DB_NAME=nexuscos_db
DB_USER=nexuscos
DB_PASSWORD=your_secure_password
```

#### Option C: Docker PostgreSQL Container

If using Docker (as per PF_ARCHITECTURE.md):

```bash
# Update .env file
DB_HOST=nexus-cos-postgres  # Docker container name
DB_PORT=5432
DB_NAME=nexus_db
DB_USER=nexus_user
DB_PASSWORD=Momoney2025$
```

### 2. Apply Database Configuration

After updating the `.env` file on the server (`/opt/nexus-cos/.env`):

```bash
# SSH into the server
ssh user@nexuscos.online

# Navigate to the application directory
cd /opt/nexus-cos

# Edit the .env file with correct DB configuration
nano .env

# Restart the PM2 process
pm2 restart nexus-cos

# Verify the health endpoint
curl -s https://nexuscos.online/health | jq
```

Expected output after successful database connection:
```json
{
  "status": "ok",
  "timestamp": "2024-01-XX...",
  "uptime": 123.45,
  "environment": "production",
  "version": "1.0.0",
  "db": "up"
}
```

### 3. Frontend Enhancement (Optional, Priority: MEDIUM)

Current state: Root domain serves a minimal fallback or basic frontend.

#### Option A: Build and Deploy React Frontends

If you want richer UIs for admin panel, creator hub, and main frontend:

```bash
# Build all frontends locally
cd /home/runner/work/nexus-cos/nexus-cos

# Build main frontend
cd frontend
npm install
npm run build
cd ..

# Build admin panel
cd admin
npm install
npm run build
cd ..

# Build creator hub
cd creator-hub
npm install
npm run build
cd ..

# Upload to server
scp -r frontend/dist user@nexuscos.online:/opt/nexus-cos/frontend/
scp -r admin/build user@nexuscos.online:/opt/nexus-cos/admin/
scp -r creator-hub/build user@nexuscos.online:/opt/nexus-cos/creator-hub/
```

#### Option B: Keep Minimal Fallback

The current setup with a minimal fallback is sufficient if you're focusing on API functionality first.

## 🧪 Verification Checklist

After applying database configuration:

- [ ] Health endpoint shows `db: "up"`: `curl -s https://nexuscos.online/health | jq`
- [ ] Root domain loads without errors: `curl -I https://nexuscos.online/`
- [ ] API endpoints are accessible: `curl https://nexuscos.online/api/auth/`
- [ ] PM2 process is running: `pm2 list | grep nexus-cos`
- [ ] Nginx is active: `systemctl is-active nginx`

## 📊 Monitoring and Maintenance

### Check Application Logs

```bash
# PM2 logs
pm2 logs nexus-cos

# Nginx access logs
tail -f /var/log/nginx/access.log

# Nginx error logs
tail -f /var/log/nginx/error.log
```

### Check Process Status

```bash
# PM2 status
pm2 status

# Nginx status
systemctl status nginx

# Database status (if local)
systemctl status postgresql
```

## 🚀 Advanced Configuration (Optional)

### Custom Routes and Headers

If you want to add custom routes, caching, or headers:

1. Edit Nginx configuration: `/etc/nginx/sites-available/nexuscos.conf`
2. Test configuration: `nginx -t`
3. Reload Nginx: `systemctl reload nginx`

### Custom Landing Page

To serve a custom landing page at the root:

1. Place your HTML file at `/opt/nexus-cos/frontend/dist/index.html`
2. Ensure Nginx is configured to serve it (already configured)
3. Reload Nginx: `systemctl reload nginx`

## 📝 Environment Variables Reference

Complete list of environment variables in `/opt/nexus-cos/.env`:

```bash
# Application
NODE_ENV=production
PORT=3000

# Database (UPDATE THESE!)
DB_HOST=localhost  # Change to actual DB host
DB_PORT=5432
DB_NAME=nexuscos_db
DB_USER=nexuscos
DB_PASSWORD=your_secure_password

# Authentication
JWT_SECRET=nexus-cos-secret-key-2024-secure
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# SSL/TLS
SSL_ENABLED=true
SSL_CERT_PATH=/etc/letsencrypt/live/nexuscos.online/fullchain.pem
SSL_KEY_PATH=/etc/letsencrypt/live/nexuscos.online/privkey.pem
```

## 🆘 Troubleshooting

### Database Connection Issues

If `db: "down"` persists after configuration:

1. **Check if database is running**:
   ```bash
   # For PostgreSQL
   systemctl status postgresql
   # OR check if container is running
   docker ps | grep postgres
   ```

2. **Test database connection manually**:
   ```bash
   psql -h localhost -U nexuscos -d nexuscos_db
   ```

3. **Check firewall rules**:
   ```bash
   # Allow PostgreSQL port
   sudo ufw allow 5432/tcp
   ```

4. **Verify database credentials**:
   - Ensure user exists in PostgreSQL
   - Verify password is correct
   - Check database exists

### Application Not Responding

```bash
# Restart PM2 process
pm2 restart nexus-cos

# Reload Nginx
systemctl reload nginx

# Check logs for errors
pm2 logs nexus-cos --lines 50
```

## 📞 Contact and Support

- **Repository**: https://github.com/BobbyBlanco400/nexus-cos
- **Domain**: https://nexuscos.online
- **Server IP**: 74.208.155.161

## 🎯 Immediate Action Required

**Priority 1**: Configure database connection (see Section 1 above)

Once the database is configured and the health check shows `db: "up"`, your application will be fully operational and ready for production use.
