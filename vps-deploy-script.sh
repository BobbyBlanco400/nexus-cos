#!/bin/bash
set -e

echo "🧹 Cleaning old deployment..."
sudo systemctl stop nginx || true
docker compose down 2>/dev/null || docker-compose down 2>/dev/null || true
rm -rf /opt/nexus-cos || true

echo "📁 Creating deployment directory..."
rm -rf /opt/nexus-cos
mkdir -p /opt/nexus-cos
cd /opt/nexus-cos

echo "📦 Installing basic dependencies..."
apt-get update
apt-get install -y git nginx certbot python3-certbot-nginx curl net-tools ufw

echo "🐳 Installing Docker if needed..."
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
else
    echo "Docker already installed"
fi

echo "🔧 Starting Docker service..."
systemctl start docker
systemctl enable docker

echo "🛡️ Configuring firewall..."
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 3000
ufw allow 3001
ufw allow 4000
ufw allow 4001
ufw allow 4002
ufw allow 8080
echo "y" | ufw enable

echo "📦 Unzipping project snapshot..."
unzip -o /tmp/nexus-cos-vps-deploy.zip -d /tmp/nexus-cos-upload
# Copy uploaded project files
if [ -d "/tmp/nexus-cos-upload" ]; then
    echo "Copying uploaded project files..."
    cp -r /tmp/nexus-cos-upload/nexus-cos/* .
    rm -rf /tmp/nexus-cos-upload
else
    echo "No uploaded files found, creating basic structure..."
    mkdir -p services/{v-suite,creator-hub,puaboverse}
    mkdir -p {frontend,backend,admin,database,nginx}
fi

echo "🔐 Setting up environment..."
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

echo "🐳 Building and starting containers..."
if command -v docker-compose &> /dev/null; then
    docker-compose -f docker-compose.prod.yml up -d --build
else
    docker compose -f docker-compose.prod.yml up -d --build
fi

echo "⏳ Waiting for services to start..."
sleep 30

echo "🌐 Configuring Nginx..."
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
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINXEOF

ln -sf /etc/nginx/sites-available/nexuscos.online /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

echo "🔒 Setting up SSL certificate..."
certbot --nginx -d nexuscos.online -d www.nexuscos.online --non-interactive --agree-tos --email admin@nexuscos.online

echo "🔄 Restarting Nginx..."
systemctl restart nginx
systemctl enable nginx

echo "✅ Deployment completed successfully!"
echo "🌐 Site should be live at: https://nexuscos.online"
echo "🔧 Admin panel: https://nexuscos.online/admin"

echo "📊 Service status:"
if command -v docker-compose &> /dev/null; then
    docker-compose ps
else
    docker compose ps
fi
systemctl status nginx --no-pager -l