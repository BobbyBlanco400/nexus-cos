# Nexus COS Manual Deployment Guide

## Prerequisites
- VPS with Ubuntu 22.04 LTS
- Root access to VPS (74.208.155.161)
- Domain name (nexuscos.online) pointing to VPS IP
- SSH client on local machine

## Step 1: Connect to VPS
```bash
ssh root@74.208.155.161
```

## Step 2: Update System and Install Dependencies
```bash
# Update system
apt-get update && apt-get upgrade -y

# Install basic dependencies
apt-get install -y git nginx certbot python3-certbot-nginx curl

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Start and enable Docker
systemctl start docker
systemctl enable docker
```

## Step 3: Create Deployment Directory
```bash
# Clean any existing deployment
systemctl stop nginx || true
docker compose down 2>/dev/null || docker-compose down 2>/dev/null || true
rm -rf /opt/nexus-cos

# Create new deployment directory
mkdir -p /opt/nexus-cos
cd /opt/nexus-cos
```

## Step 4: Upload Project Files
From your local machine, upload the project files:

```bash
# Create upload directory on VPS
ssh root@74.208.155.161 "mkdir -p /tmp/nexus-cos-upload"

# Upload all project files
scp -r C:\Users\wecon\Downloads\nexus-cos-main\* root@74.208.155.161:/tmp/nexus-cos-upload/

# On VPS, copy files to deployment directory
ssh root@74.208.155.161 "cp -r /tmp/nexus-cos-upload/* /opt/nexus-cos/ && rm -rf /tmp/nexus-cos-upload"
```

## Step 5: Set Up Environment Variables
On the VPS, create the production environment file:

```bash
cd /opt/nexus-cos
cat > .env.production << 'EOF'
ENVIRONMENT=production
NODE_ENV=production
POSTGRES_DB=nexus_cos
POSTGRES_USER=nexus_admin
POSTGRES_PASSWORD=Momoney2025$$
REDIS_PASSWORD=Momoney2025$$
JWT_SECRET=nexus-cos-jwt-secret-2025-production
DATABASE_URL=postgresql://nexus_admin:Momoney2025$$@postgres:5432/nexus_cos
REDIS_URL=redis://:Momoney2025$$@redis:6379
FRONTEND_URL=https://nexuscos.online
BACKEND_URL=https://nexuscos.online/api
ADMIN_URL=https://nexuscos.online/admin
V_SUITE_API_KEY=v-suite-api-key-2025
CREATOR_HUB_API_KEY=creator-hub-api-key-2025
PUABOVERSE_API_KEY=puaboverse-api-key-2025
OPENAI_API_KEY=your-openai-api-key
ANTHROPIC_API_KEY=your-anthropic-api-key
STRIPE_SECRET_KEY=your-stripe-secret-key
PAYPAL_CLIENT_ID=your-paypal-client-id
PAYPAL_CLIENT_SECRET=your-paypal-client-secret
MINIO_ROOT_USER=nexus_minio
MINIO_ROOT_PASSWORD=Momoney2025$$
RABBITMQ_DEFAULT_USER=nexus_rabbit
RABBITMQ_DEFAULT_PASS=Momoney2025$$
EOF
```

## Step 6: Start Docker Services
```bash
# Build and start all services
if command -v docker-compose &> /dev/null; then
    docker-compose -f docker-compose.prod.yml up -d --build
else
    docker compose -f docker-compose.prod.yml up -d --build
fi

# Wait for services to start
sleep 30

# Check service status
docker ps
```

## Step 7: Configure Nginx
```bash
# Create Nginx configuration
cat > /etc/nginx/sites-available/nexuscos.online << 'NGINXEOF'
server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name nexuscos.online www.nexuscos.online;

    ssl_certificate /etc/letsencrypt/live/nexuscos.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/nexuscos.online/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/ {
        proxy_pass http://localhost:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /admin/ {
        proxy_pass http://localhost:3001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /v-suite/ {
        proxy_pass http://localhost:4000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /creator-hub/ {
        proxy_pass http://localhost:4001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /puaboverse/ {
        proxy_pass http://localhost:4002/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_Set_header X-Forwarded-Proto $scheme;
    }
}
NGINXEOF

# Enable the site
ln -sf /etc/nginx/sites-available/nexuscos.online /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
```

## Step 8: Set Up SSL Certificate
```bash
# Get SSL certificate
certbot --nginx -d nexuscos.online -d www.nexuscos.online --non-interactive --agree-tos --email admin@nexuscos.online

# Restart Nginx
systemctl restart nginx
systemctl enable nginx
```

## Step 9: Verify Deployment
```bash
# Check Docker services
docker ps

# Check Nginx status
systemctl status nginx

# Check logs if needed
docker logs nexus-frontend
docker logs nexus-backend
docker logs nexus-admin
```

## Expected Live URLs
- **Main Site**: https://nexuscos.online
- **Admin Panel**: https://nexuscos.online/admin
- **V-Suite**: https://nexuscos.online/v-suite
- **Creator Hub**: https://nexuscos.online/creator-hub
- **Puaboverse**: https://nexuscos.online/puaboverse

## Troubleshooting

### If Docker services fail to start:
```bash
# Check logs
docker logs <container_name>

# Restart specific service
docker restart <container_name>

# Rebuild if needed
docker compose -f docker-compose.prod.yml up -d --build --force-recreate
```

### If SSL certificate fails:
```bash
# Check domain DNS
nslookup nexuscos.online

# Try manual certificate
certbot certonly --standalone -d nexuscos.online -d www.nexuscos.online
```

### If Nginx fails:
```bash
# Test configuration
nginx -t

# Check error logs
tail -f /var/log/nginx/error.log
```

## Maintenance Commands
```bash
# Update containers
cd /opt/nexus-cos
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d

# Backup database
docker exec nexus-postgres pg_dump -U nexus_admin nexus_cos > backup_$(date +%Y%m%d).sql

# View logs
docker compose -f docker-compose.prod.yml logs -f
```