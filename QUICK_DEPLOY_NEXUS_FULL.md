# 🚀 Nexus COS - Quick Deploy Card

## One-Line Deployment

```bash
docker compose -f docker-compose.nexus-full.yml up -d && sleep 30 && ./verify-nexus-deployment.sh
```

## Step-by-Step Deployment

### 1. Environment Setup (30 seconds)

```bash
# Create .env file
cat > .env << 'EOF'
DB_NAME=nexus_cos
DB_USER=postgres
DB_PASSWORD=nexus_secure_2025
REDIS_PASSWORD=nexus_redis_2025
EOF
```

### 2. Build Services (5-10 minutes)

```bash
docker compose -f docker-compose.nexus-full.yml build
```

### 3. Start Services (1 minute)

```bash
docker compose -f docker-compose.nexus-full.yml up -d
```

### 4. Verify Deployment (30 seconds)

```bash
./verify-nexus-deployment.sh
```

## Quick Commands

### View Status
```bash
docker compose -f docker-compose.nexus-full.yml ps
```

### View Logs
```bash
# All services
docker compose -f docker-compose.nexus-full.yml logs -f

# Specific service
docker compose -f docker-compose.nexus-full.yml logs -f <service-name>
```

### Restart Service
```bash
docker compose -f docker-compose.nexus-full.yml restart <service-name>
```

### Stop All
```bash
docker compose -f docker-compose.nexus-full.yml down
```

### Rebuild Service
```bash
docker compose -f docker-compose.nexus-full.yml build <service-name>
docker compose -f docker-compose.nexus-full.yml up -d <service-name>
```

## Service Count

- **Total Containers**: 27+
- **Module Services**: 23
- **Infrastructure**: 2 (Auth, Scheduler)
- **Database**: PostgreSQL
- **Cache**: Redis

## Health Check URLs

| Service | URL |
|---------|-----|
| PUABO OS | http://localhost:8000/health |
| Fleet Service | http://localhost:8080/health |
| Auth Service | http://localhost:3100/health |
| V-Prompter | http://localhost:3002/health |
| DSP API | http://localhost:9000/health |
| BLAC API | http://localhost:9100/health |
| Studio API | http://localhost:9200/health |
| StreamCore | http://localhost:3016/health |
| GameCore | http://localhost:3020/health |
| Nexus AI | http://localhost:3030/health |
| Fashion API | http://localhost:9300/health |
| OTT API | http://localhost:9400/health |

## Troubleshooting

### Service Won't Start
```bash
# Check logs
docker compose -f docker-compose.nexus-full.yml logs <service-name>

# Rebuild and restart
docker compose -f docker-compose.nexus-full.yml build <service-name>
docker compose -f docker-compose.nexus-full.yml up -d <service-name>
```

### Port Conflicts
```bash
# Find conflicting process
sudo lsof -i :<port>

# Stop conflicting service
sudo systemctl stop <service-name>
```

### Database Connection Issues
```bash
# Restart database
docker compose -f docker-compose.nexus-full.yml restart nexus-cos-postgres

# Check database logs
docker compose -f docker-compose.nexus-full.yml logs nexus-cos-postgres
```

## Files

- `docker-compose.nexus-full.yml` - Main orchestration
- `scaffold-all-services.sh` - Re-scaffold if needed
- `verify-nexus-deployment.sh` - Health check script
- `NEXUS_COS_FULL_SCAFFOLD_README.md` - Full documentation
- `SCAFFOLD_COMPLETION_SUMMARY.md` - Completion summary

## Support

For issues, check:
1. Service logs: `docker compose -f docker-compose.nexus-full.yml logs <service>`
2. Container status: `docker ps -a`
3. Network: `docker network inspect cos-net`

---

**Ready for Beta Launch**: October 17, 2025  
**Global IP Launch**: November 17, 2025
