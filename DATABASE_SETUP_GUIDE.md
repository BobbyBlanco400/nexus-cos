# Database Setup Guide for Nexus COS

## Current Status

Based on the deployment feedback from PF:
- ✅ Application is running and serving HTTPS
- ⚠️ Database shows `db: "down"` because `DB_HOST=admin` doesn't resolve
- 📋 Action needed: Configure correct database host

## Quick Setup Options

### Option 1: Local PostgreSQL (Simplest for Single-Server Setup)

If you want to install PostgreSQL on the same server as your application:

```bash
# 1. Install PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib -y

# 2. Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# 3. Create database and user
sudo -u postgres psql << EOF
CREATE DATABASE nexuscos_db;
CREATE USER nexuscos WITH ENCRYPTED PASSWORD 'YourSecurePassword123!';
GRANT ALL PRIVILEGES ON DATABASE nexuscos_db TO nexuscos;
\q
EOF

# 4. Update .env file on server (/opt/nexus-cos/.env)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=nexuscos_db
DB_USER=nexuscos
DB_PASSWORD=YourSecurePassword123!

# 5. Restart application
pm2 restart nexus-cos

# 6. Verify database connection
curl -s https://n3xuscos.online/health | jq '.db'
# Should return: "up"
```

### Option 2: Docker PostgreSQL (As per PF_ARCHITECTURE.md)

If you prefer containerized database:

```bash
# 1. Ensure Docker is installed
docker --version

# 2. Create Docker network (if not exists)
docker network create nexus-network 2>/dev/null || true

# 3. Run PostgreSQL container
docker run -d \
  --name nexus-cos-postgres \
  --network nexus-network \
  -e POSTGRES_DB=nexus_db \
  -e POSTGRES_USER=nexus_user \
  -e POSTGRES_PASSWORD=Momoney2025$ \
  -v postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:15-alpine

# 4. Update .env file on server (/opt/nexus-cos/.env)
DB_HOST=nexus-cos-postgres  # Or use localhost if port is mapped
DB_PORT=5432
DB_NAME=nexus_db
DB_USER=nexus_user
DB_PASSWORD=Momoney2025$

# 5. Restart application
pm2 restart nexus-cos

# 6. Verify database connection
curl -s https://n3xuscos.online/health | jq '.db'
# Should return: "up"
```

### Option 3: Remote PostgreSQL Server

If your database is hosted elsewhere (managed service, separate server, etc.):

```bash
# 1. Get your database credentials from your provider
#    - Hostname/IP (e.g., db.example.com or 10.0.1.50)
#    - Port (usually 5432)
#    - Database name
#    - Username
#    - Password

# 2. Update .env file on server (/opt/nexus-cos/.env)
DB_HOST=your-db-host.example.com
DB_PORT=5432
DB_NAME=your_db_name
DB_USER=your_db_user
DB_PASSWORD=your_db_password

# 3. Ensure firewall allows connection (if needed)
# Check with your DB provider

# 4. Restart application
pm2 restart nexus-cos

# 5. Verify database connection
curl -s https://n3xuscos.online/health | jq '.db'
# Should return: "up"
```

## Verification Steps

After configuring the database, run these checks:

### 1. Check Health Endpoint

```bash
curl -s https://n3xuscos.online/health
```

Expected output:
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

### 2. Test Database Connection Manually

```bash
# For local PostgreSQL
psql -h localhost -U nexuscos -d nexuscos_db

# For remote PostgreSQL
psql -h your-db-host -U your-db-user -d your-db-name
```

### 3. Check Application Logs

```bash
# PM2 logs
pm2 logs nexus-cos --lines 50

# Look for database connection messages
pm2 logs nexus-cos | grep -i "database\|connection\|mysql"
```

## Database Schema Setup

Once the database connection is established, you may need to set up tables:

### Check if Tables Exist

```bash
psql -h localhost -U nexuscos -d nexuscos_db -c "\dt"
```

### Run Migrations (if you have them)

```bash
cd /opt/nexus-cos
npm run migrate
# or
node scripts/migrate.js
```

### Create Initial Schema Manually

If you don't have migrations, you can create tables manually:

```sql
-- Example user table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add other tables as needed
```

## Troubleshooting

### Issue: "Connection refused"

**Cause**: PostgreSQL is not running or not listening on the expected port.

**Solution**:
```bash
# Check if PostgreSQL is running
systemctl status postgresql

# Start PostgreSQL if stopped
sudo systemctl start postgresql

# Check listening ports
sudo netstat -plnt | grep 5432
```

### Issue: "password authentication failed"

**Cause**: Incorrect credentials in .env file.

**Solution**:
1. Verify credentials are correct
2. Check PostgreSQL user exists:
   ```bash
   sudo -u postgres psql -c "\du"
   ```
3. Reset password if needed:
   ```bash
   sudo -u postgres psql -c "ALTER USER nexuscos WITH PASSWORD 'new_password';"
   ```

### Issue: "database does not exist"

**Cause**: Database hasn't been created yet.

**Solution**:
```bash
sudo -u postgres psql -c "CREATE DATABASE nexuscos_db;"
```

### Issue: Still showing "db: down" after configuration

**Debugging steps**:
1. Check PM2 logs for error messages:
   ```bash
   pm2 logs nexus-cos --err --lines 100
   ```

2. Verify .env file is correctly loaded:
   ```bash
   cat /opt/nexus-cos/.env | grep DB_
   ```

3. Test database connection independently:
   ```bash
   node -e "
   const mysql = require('mysql2/promise');
   const pool = mysql.createPool({
     host: 'localhost',
     user: 'nexuscos',
     password: 'password',
     database: 'nexuscos_db'
   });
   pool.query('SELECT 1').then(() => {
     console.log('✅ Database connection successful');
     process.exit(0);
   }).catch(err => {
     console.error('❌ Database connection failed:', err.message);
     process.exit(1);
   });
   "
   ```

## Security Best Practices

1. **Use Strong Passwords**: Never use default passwords in production
2. **Restrict Access**: Configure PostgreSQL to only accept connections from localhost or specific IPs
3. **Enable SSL**: For remote connections, use SSL/TLS
4. **Regular Backups**: Set up automated database backups
5. **Update Regularly**: Keep PostgreSQL updated with security patches

## Next Steps After Database Setup

Once your database shows `db: "up"`:

1. ✅ Run database migrations/schema setup
2. ✅ Create initial admin user (if needed)
3. ✅ Test API endpoints that require database
4. ✅ Monitor application logs for any database-related errors
5. ✅ Set up database backup strategy

## Quick Reference: Common Commands

```bash
# Restart application
pm2 restart nexus-cos

# Check health
curl -s https://n3xuscos.online/health | jq

# View logs
pm2 logs nexus-cos

# Database status
systemctl status postgresql

# Connect to database
psql -h localhost -U nexuscos -d nexuscos_db

# Reload Nginx (if needed)
systemctl reload nginx
```

## Support

For additional help:
- Review NEXT_STEPS.md for comprehensive deployment guide
- Check PF_ARCHITECTURE.md for system architecture details
- View server.js for health endpoint implementation
