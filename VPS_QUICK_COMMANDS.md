# ⚡ NEXUS COS - VPS QUICK COMMANDS REFERENCE

**Version:** v2025.10.10 FINAL  
**Purpose:** Fast command reference for VPS deployment and management  
**Date:** 2025-10-11

---

## 🚀 PRE-DEPLOYMENT

### Verify Repository Readiness (Run Locally)

```bash
# Clone repo locally (if not already done)
git clone https://github.com/BobbyBlanco400/nexus-cos.git
cd nexus-cos

# Run readiness check
bash VPS_DEPLOYMENT_READINESS_CHECK.sh
# Expected: 100% readiness, 25/25 checks passed
```

---

## 🖥️ VPS SETUP

### SSH into VPS

```bash
ssh root@[YOUR_VPS_IP]
# Or: ssh [username]@[YOUR_VPS_IP]
```

### Install Prerequisites (One-Time Setup)

```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose Plugin
sudo apt-get install docker-compose-plugin -y

# Install Git
sudo apt-get install git -y

# Add user to docker group
sudo usermod -aG docker $USER

# Configure firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# Verify installations
docker --version
docker compose version
git --version
```

---

## 🚀 DEPLOYMENT

### One-Command Deployment

```bash
cd /opt && \
git clone https://github.com/BobbyBlanco400/nexus-cos.git && \
cd nexus-cos && \
bash EXECUTE_BETA_LAUNCH.sh
```

**Time:** ~25 minutes  
**Result:** 44 containers deployed

### Alternative: Step-by-Step Deployment

```bash
# Step 1: Clone repository
cd /opt
git clone https://github.com/BobbyBlanco400/nexus-cos.git
cd nexus-cos

# Step 2: Configure environment
cp .env.pf.example .env.pf
nano .env.pf  # Edit with your secure values

# Step 3: Run deployment script
bash EXECUTE_BETA_LAUNCH.sh
```

---

## ✅ VERIFICATION

### Quick Status Check

```bash
cd /opt/nexus-cos

# Check container count
docker compose -f docker-compose.unified.yml ps | wc -l
# Expected: 44+ (includes header)

# Run health checks
bash pf-health-check.sh
# Expected: All checks passing

# Check specific service
docker compose -f docker-compose.unified.yml ps [service-name]
```

### Service Health

```bash
# Test main endpoints
curl http://localhost:4000/health    # Gateway
curl http://localhost:3002/health    # AI SDK
curl http://localhost:3041/health    # PV Keys

# Test frontend
curl http://localhost/
```

### Database Connectivity

```bash
cd /opt/nexus-cos

# PostgreSQL
docker compose -f docker-compose.unified.yml exec nexus-cos-postgres pg_isready -U postgres

# Redis
docker compose -f docker-compose.unified.yml exec nexus-cos-redis redis-cli ping
```

---

## 📊 MONITORING

### View Logs

```bash
cd /opt/nexus-cos

# All services
docker compose -f docker-compose.unified.yml logs -f

# Specific service
docker compose -f docker-compose.unified.yml logs -f [service-name]

# Last 100 lines
docker compose -f docker-compose.unified.yml logs --tail=100

# Filter for errors
docker compose -f docker-compose.unified.yml logs | grep -i error
```

### Resource Usage

```bash
# Container stats
docker stats --no-stream

# System resources
free -h        # Memory
df -h          # Disk space
top            # CPU usage
```

### Container Details

```bash
cd /opt/nexus-cos

# List all containers
docker compose -f docker-compose.unified.yml ps

# List only running
docker compose -f docker-compose.unified.yml ps --status running

# Container details
docker inspect [container-name]
```

---

## 🔧 TROUBLESHOOTING

### Restart Services

```bash
cd /opt/nexus-cos

# Restart all services
docker compose -f docker-compose.unified.yml restart

# Restart specific service
docker compose -f docker-compose.unified.yml restart [service-name]

# Restart with rebuild
docker compose -f docker-compose.unified.yml up -d --build [service-name]
```

### Stop/Start Services

```bash
cd /opt/nexus-cos

# Stop all services
docker compose -f docker-compose.unified.yml down

# Start all services
docker compose -f docker-compose.unified.yml up -d

# Stop specific service
docker compose -f docker-compose.unified.yml stop [service-name]

# Start specific service
docker compose -f docker-compose.unified.yml start [service-name]
```

### Clean Up

```bash
# Remove stopped containers
docker compose -f docker-compose.unified.yml rm

# Remove all (including volumes - CAUTION: destroys data)
docker compose -f docker-compose.unified.yml down -v

# Clean Docker system
docker system prune -a  # WARNING: removes all unused images
```

### Check Failed Container

```bash
cd /opt/nexus-cos

# See exit code
docker compose -f docker-compose.unified.yml ps [service-name]

# View logs
docker compose -f docker-compose.unified.yml logs [service-name]

# Inspect container
docker inspect [container-name]

# Try manual start with logs
docker compose -f docker-compose.unified.yml up [service-name]
```

---

## 🔄 UPDATES

### Pull Latest Changes

```bash
cd /opt/nexus-cos

# Stop services
docker compose -f docker-compose.unified.yml down

# Pull updates
git pull origin main

# Rebuild and restart
docker compose -f docker-compose.unified.yml up -d --build
```

### Update Single Service

```bash
cd /opt/nexus-cos

# Pull changes
git pull origin main

# Rebuild specific service
docker compose -f docker-compose.unified.yml up -d --build [service-name]
```

---

## 🗄️ DATABASE MANAGEMENT

### PostgreSQL Commands

```bash
cd /opt/nexus-cos

# Access PostgreSQL shell
docker compose -f docker-compose.unified.yml exec nexus-cos-postgres psql -U postgres

# List databases
docker compose -f docker-compose.unified.yml exec nexus-cos-postgres psql -U postgres -c "\l"

# Database backup
docker compose -f docker-compose.unified.yml exec nexus-cos-postgres pg_dump -U postgres [dbname] > backup.sql

# Database restore
cat backup.sql | docker compose -f docker-compose.unified.yml exec -T nexus-cos-postgres psql -U postgres [dbname]
```

### Redis Commands

```bash
cd /opt/nexus-cos

# Access Redis CLI
docker compose -f docker-compose.unified.yml exec nexus-cos-redis redis-cli

# Get Redis info
docker compose -f docker-compose.unified.yml exec nexus-cos-redis redis-cli info

# Flush cache (CAUTION)
docker compose -f docker-compose.unified.yml exec nexus-cos-redis redis-cli flushall
```

---

## 🔒 SECURITY

### Check Environment Variables

```bash
cd /opt/nexus-cos

# View .env.pf (contains secrets - be careful)
cat .env.pf

# Check file permissions
ls -la .env.pf
# Should be: -rw------- (600)

# Fix permissions if needed
chmod 600 .env.pf
```

### Firewall Status

```bash
# Check firewall status
sudo ufw status verbose

# Show allowed ports
sudo ufw status numbered
```

### Check Open Ports

```bash
# Show listening ports
sudo netstat -tulpn | grep LISTEN

# Check specific port
sudo netstat -tulpn | grep :80
```

---

## 📊 PERFORMANCE

### Monitor Real-Time

```bash
# Container resource usage (real-time)
docker stats

# System load
htop  # (install with: sudo apt-get install htop)

# Network connections
sudo netstat -an | grep ESTABLISHED | wc -l
```

### Disk Usage

```bash
# Overall disk usage
df -h

# Docker disk usage
docker system df

# Container sizes
docker ps --size
```

### Memory Usage

```bash
# System memory
free -h

# Per-container memory
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}"
```

---

## 🆘 EMERGENCY COMMANDS

### Complete Shutdown

```bash
cd /opt/nexus-cos
docker compose -f docker-compose.unified.yml down
```

### Force Kill All Containers

```bash
# CAUTION: Kills ALL Docker containers on system
docker kill $(docker ps -q)
```

### Emergency Restart

```bash
cd /opt/nexus-cos
docker compose -f docker-compose.unified.yml down
sleep 5
docker compose -f docker-compose.unified.yml up -d
```

### Recover from Crash

```bash
cd /opt/nexus-cos

# Stop everything
docker compose -f docker-compose.unified.yml down

# Clean up
docker system prune -f

# Restart
bash EXECUTE_BETA_LAUNCH.sh
```

---

## 📁 USEFUL FILE LOCATIONS

```
/opt/nexus-cos/                          # Main directory
/opt/nexus-cos/.env.pf                   # Environment config
/opt/nexus-cos/docker-compose.unified.yml # Container config
/opt/nexus-cos/EXECUTE_BETA_LAUNCH.sh    # Deploy script
/opt/nexus-cos/pf-health-check.sh        # Health check
/opt/nexus-cos/modules/                  # Module code
/opt/nexus-cos/services/                 # Service code
/opt/nexus-cos/web/beta/                 # Frontend files
```

---

## 🔗 COMMON SERVICE PORTS

| Service | Port | Endpoint |
|---------|------|----------|
| Gateway | 4000 | http://localhost:4000/health |
| AI SDK | 3002 | http://localhost:3002/health |
| PV Keys | 3041 | http://localhost:3041/health |
| PostgreSQL | 5432 | Internal only |
| Redis | 6379 | Internal only |
| Web Frontend | 80 | http://localhost/ |

---

## 📞 SUPPORT COMMANDS

### Generate Support Report

```bash
cd /opt/nexus-cos

# System info
echo "=== SYSTEM INFO ===" > support-report.txt
uname -a >> support-report.txt
docker --version >> support-report.txt
docker compose version >> support-report.txt

# Container status
echo -e "\n=== CONTAINERS ===" >> support-report.txt
docker compose -f docker-compose.unified.yml ps >> support-report.txt

# Recent logs
echo -e "\n=== RECENT LOGS ===" >> support-report.txt
docker compose -f docker-compose.unified.yml logs --tail=50 >> support-report.txt

# Health check
echo -e "\n=== HEALTH CHECK ===" >> support-report.txt
bash pf-health-check.sh >> support-report.txt 2>&1

echo "Report saved to support-report.txt"
```

### Save All Logs

```bash
cd /opt/nexus-cos
docker compose -f docker-compose.unified.yml logs > full-logs-$(date +%Y%m%d-%H%M%S).txt
```

---

## 💡 TIPS & TRICKS

### Quick Health Check

```bash
alias health='cd /opt/nexus-cos && bash pf-health-check.sh'
# Usage: health
```

### Quick Status

```bash
alias cosstatus='cd /opt/nexus-cos && docker compose -f docker-compose.unified.yml ps'
# Usage: cosstatus
```

### Watch Logs

```bash
# Follow logs with auto-scroll
cd /opt/nexus-cos
docker compose -f docker-compose.unified.yml logs -f --tail=20
```

### Find Container IP

```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' [container-name]
```

---

**Quick Reference Card**

```
┌─────────────────────────────────────────────┐
│ NEXUS COS VPS QUICK COMMANDS                │
├─────────────────────────────────────────────┤
│ Deploy:      bash EXECUTE_BETA_LAUNCH.sh    │
│ Health:      bash pf-health-check.sh        │
│ Status:      docker compose ps              │
│ Logs:        docker compose logs -f         │
│ Restart:     docker compose restart         │
│ Stop:        docker compose down            │
│ Start:       docker compose up -d           │
└─────────────────────────────────────────────┘
```

---

**END OF QUICK COMMANDS**

For detailed documentation, see:
- `VPS_DEPLOYMENT_CHECKLIST.md`
- `VPS_POST_DEPLOYMENT_VERIFICATION.md`
- `PF_FINAL_BETA_LAUNCH_v2025.10.10.md`
