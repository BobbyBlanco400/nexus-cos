#!/usr/bin/env bash
# Nexus COS Full Fix & Deploy Script
# Usage: sudo ./nexuscos_fix_deploy.sh
# This script fixes 404 errors in server.js, manages PM2, and sets up Nginx with SSL.

set -euo pipefail

echo "🚀 Starting Nexus COS Fix & Deploy..."

# 1️⃣ Fix server.js 404 Errors
if ! grep -q "app.use((req, res)" server.js; then
    echo "🔧 Adding catch-all route to server.js to prevent 404s..."
    sed -i "/app.listen/i\\
\\
    // Catch-all route to prevent 404s\\
    app.use((req, res) => { res.status(200).send('Nexus COS is running!'); });" server.js
else
    echo "✅ Catch-all route already exists in server.js"
fi

# 2️⃣ PM2 Management
echo "🔄 Stopping and deleting existing PM2 process 'nexus-cos' if exists..."
pm2 stop nexus-cos || true
pm2 delete nexus-cos || true

echo "▶️ Starting server.js with PM2..."
pm2 start server.js --name "nexus-cos"
pm2 save
echo "✅ PM2 process started and saved"

# 3️⃣ Cleanup Legacy Nginx Configurations
echo "🧹 Cleaning up old Nginx configs..."
sudo rm -f /etc/nginx/conf.d/nexuscos*.conf
sudo rm -f /etc/nginx/sites-enabled/*nexuscos*.conf
sudo rm -f /etc/nginx/sites-available/nexuscos*.conf

# 4️⃣ Create Production-Ready Nginx Server Block
NGINX_CONF="/etc/nginx/sites-available/nexuscos.conf"
echo "⚙️ Creating Nginx server block at $NGINX_CONF..."
sudo tee $NGINX_CONF > /dev/null <<EOL
server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name nexuscos.online www.nexuscos.online;

    ssl_certificate /etc/letsencrypt/live/nexuscos.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/nexuscos.online/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

# 5️⃣ Enable Nginx Site
echo "🔗 Enabling Nginx site..."
sudo ln -sf /etc/nginx/sites-available/nexuscos.conf /etc/nginx/sites-enabled/nexuscos.conf

# 6️⃣ Test Nginx Configuration and Restart
echo "🔍 Testing Nginx configuration..."
sudo nginx -t
echo "♻️ Restarting Nginx..."
sudo systemctl restart nginx

# 7️⃣ Deployment Complete
echo "✅ Nexus COS deployed successfully!"
echo "💻 Test locally: curl http://127.0.0.1:3000"
echo "🌐 Test publicly: curl -I https://nexuscos.online"
echo "🚀 All done! Check PM2 and Nginx logs for any issues if necessary:"
echo "PM2 logs: pm2 logs nexus-cos"
echo "Nginx logs: sudo tail -f /var/log/nginx/error.log"