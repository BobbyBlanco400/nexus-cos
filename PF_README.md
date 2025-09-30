# PUABO / Nexus COS - Pre-Flight Deployment

This directory contains the Pre-Flight (PF) deployment configuration for the Nexus COS platform, matching the specifications from issue #49.

## 🚀 Quick Start

Deploy the entire platform with one command:

```bash
./deploy-pf.sh
```

This script will:
- Build and start all Docker containers
- Apply database migrations
- Verify all services are running
- Display service endpoints and status

## 📋 Services

The Pre-Flight deployment includes the following services:

| Service | Port | Description |
|---------|------|-------------|
| **puabo-api** | 4000 | Main API service |
| **nexus-cos-postgres** | 5432 | PostgreSQL database (nexus_db) |
| **nexus-cos-redis** | 6379 | Redis cache |
| **nexus-cos-puaboai-sdk** | 3002 | AI SDK service |
| **nexus-cos-pv-keys** | 3041 | Keys management service |

## 📁 Configuration Files

- **`docker-compose.pf.yml`** - Main Docker Compose configuration
- **`.env.pf`** - Environment variables
- **`database/schema.sql`** - Database schema
- **`database/apply-migrations.sh`** - Migration script
- **`deploy-pf.sh`** - Quick deployment script

## 🛠️ Manual Deployment

If you prefer to deploy manually:

### 1. Start Services

```bash
docker-compose -f docker-compose.pf.yml up -d
```

### 2. Apply Migrations

```bash
docker-compose -f docker-compose.pf.yml exec nexus-cos-postgres psql -U nexus_user -d nexus_db -f /docker-entrypoint-initdb.d/schema.sql
```

Or run the migration script from within the container:

```bash
cd database
./apply-migrations.sh
```

### 3. Verify Services

```bash
# Check service status
docker-compose -f docker-compose.pf.yml ps

# Test endpoints
curl http://localhost:4000/health
curl http://localhost:3002/health
curl http://localhost:3041/health
```

## 🔍 Service Details

### puabo-api (Port 4000)

Main API service providing core functionality.

**Endpoints:**
- `GET /health` - Health check
- `GET /` - Service info
- `GET /api/auth/*` - Authentication endpoints

**Environment Variables:**
```bash
NODE_ENV=production
PORT=4000
DB_HOST=nexus-cos-postgres
DB_NAME=nexus_db
DB_USER=nexus_user
```

### nexus-cos-postgres (Port 5432)

PostgreSQL database with the following configuration:

**Database:** `nexus_db`  
**User:** `nexus_user`  
**Password:** `Momoney2025$` (change in production!)

**Tables:**
- `users` - User accounts
- `sessions` - Session management
- `api_keys` - API key management
- `audit_log` - Audit logging

### nexus-cos-puaboai-sdk (Port 3002)

AI SDK service for machine learning integrations.

**Endpoints:**
- `GET /health` - Health check
- `GET /` - Service info

### nexus-cos-pv-keys (Port 3041)

Keys management service for authentication and encryption.

**Endpoints:**
- `GET /health` - Health check
- `GET /` - Service info

## 📊 Database

### Connect to Database

```bash
docker-compose -f docker-compose.pf.yml exec nexus-cos-postgres psql -U nexus_user -d nexus_db
```

### View Tables

```sql
\dt
```

### Query Users

```sql
SELECT * FROM users;
```

## 🔧 Common Commands

### View Logs

```bash
# All services
docker-compose -f docker-compose.pf.yml logs -f

# Specific service
docker-compose -f docker-compose.pf.yml logs -f puabo-api
```

### Restart Services

```bash
# All services
docker-compose -f docker-compose.pf.yml restart

# Specific service
docker-compose -f docker-compose.pf.yml restart puabo-api
```

### Stop Services

```bash
docker-compose -f docker-compose.pf.yml down
```

### Stop and Remove Volumes

```bash
docker-compose -f docker-compose.pf.yml down -v
```

## 🧪 Testing

### Test API Endpoints

```bash
# Health check
curl http://localhost:4000/health

# Service info
curl http://localhost:4000/

# Module status
curl http://localhost:4000/api/creator-hub/status
curl http://localhost:4000/api/v-suite/status
curl http://localhost:4000/api/puaboverse/status
```

### Test Database Connection

```bash
docker-compose -f docker-compose.pf.yml exec nexus-cos-postgres pg_isready -U nexus_user -d nexus_db
```

### Test Redis Connection

```bash
docker-compose -f docker-compose.pf.yml exec nexus-cos-redis redis-cli ping
```

## 🔐 Security Notes

**⚠️ Important:** The default configuration uses placeholder credentials for development.

**Before deploying to production:**

1. Change the database password in `.env.pf`:
   ```bash
   DB_PASSWORD=<your-secure-password>
   ```

2. Update OAuth credentials:
   ```bash
   OAUTH_CLIENT_ID=<your-client-id>
   OAUTH_CLIENT_SECRET=<your-client-secret>
   ```

3. Generate a secure JWT secret:
   ```bash
   JWT_SECRET=<your-secure-random-string>
   ```

4. Configure SSL/TLS certificates for HTTPS

## 📈 Monitoring

### Service Health Checks

All services include health checks:

```bash
# Check service health
curl http://localhost:4000/health
curl http://localhost:3002/health
curl http://localhost:3041/health
```

### View Container Status

```bash
docker-compose -f docker-compose.pf.yml ps
```

### Resource Usage

```bash
docker stats $(docker-compose -f docker-compose.pf.yml ps -q)
```

## 🐛 Troubleshooting

### Service won't start

1. Check logs:
   ```bash
   docker-compose -f docker-compose.pf.yml logs [service-name]
   ```

2. Verify ports are available:
   ```bash
   netstat -tulpn | grep -E '4000|5432|6379|3002|3041'
   ```

3. Rebuild containers:
   ```bash
   docker-compose -f docker-compose.pf.yml up -d --build --force-recreate
   ```

### Database connection issues

1. Check PostgreSQL is running:
   ```bash
   docker-compose -f docker-compose.pf.yml ps nexus-cos-postgres
   ```

2. Verify database exists:
   ```bash
   docker-compose -f docker-compose.pf.yml exec nexus-cos-postgres psql -U nexus_user -l
   ```

3. Check database logs:
   ```bash
   docker-compose -f docker-compose.pf.yml logs nexus-cos-postgres
   ```

### Migration issues

1. Re-run migrations:
   ```bash
   cd database
   ./apply-migrations.sh
   ```

2. Manual migration:
   ```bash
   docker-compose -f docker-compose.pf.yml exec nexus-cos-postgres psql -U nexus_user -d nexus_db -f /docker-entrypoint-initdb.d/schema.sql
   ```

## 📚 Documentation

For complete Pre-Flight deployment verification and details, see:
- **[PF_DEPLOYMENT_VERIFICATION.md](./PF_DEPLOYMENT_VERIFICATION.md)** - Complete deployment verification document

## 🎯 Next Steps

After successful deployment:

1. **Configure OAuth** - Update OAuth credentials with real values
2. **Set up SSL/TLS** - Configure HTTPS certificates
3. **Configure monitoring** - Set up logging and alerting
4. **Set up backups** - Configure database backups
5. **Load test** - Verify performance under load

## ✅ Verification Checklist

- [ ] All services start successfully
- [ ] Database migrations applied
- [ ] Health endpoints responding
- [ ] Database tables created
- [ ] Services can communicate with each other
- [ ] Environment variables configured
- [ ] Logs are accessible

## 📞 Support

For issues or questions:
1. Check the logs: `docker-compose -f docker-compose.pf.yml logs -f`
2. Verify configuration: Review `.env.pf` and `docker-compose.pf.yml`
3. Refer to: [PF_DEPLOYMENT_VERIFICATION.md](./PF_DEPLOYMENT_VERIFICATION.md)

---

**Last Updated:** 2025-09-30  
**Status:** ✅ Ready for Deployment
