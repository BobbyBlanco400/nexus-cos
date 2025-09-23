@echo off
echo ========================================
echo TRAE SOLO - NEXUS COS Deployment Manager
echo ========================================
echo Target VPS: 74.208.155.161
echo Domain: nexuscos.online
echo.

REM Check if SSH client is available
where ssh >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: SSH client not found. Please install OpenSSH.
    pause
    exit /b 1
)

REM Check if SSH key exists
if not exist "C:\Users\wecon\.ssh\nexus-cos-vps" (
    echo Error: SSH key not found. Please run generate-ssh-key.bat first.
    pause
    exit /b 1
)

echo Setting up SSH key authentication...
echo You will need to enter the VPS password once to copy the SSH key.
echo.

REM Copy SSH key to VPS (this will require password input once)
ssh-copy-id -i C:\Users\wecon\.ssh\nexus-cos-vps.pub root@74.208.155.161
if %errorlevel% neq 0 (
    echo Error: Failed to copy SSH key. Trying alternative method...
    echo.
    echo Please manually copy the following public key to your VPS:
    type C:\Users\wecon\.ssh\nexus-cos-vps.pub
    echo.
    echo Add this key to /root/.ssh/authorized_keys on your VPS
    pause
)

echo.
echo Testing SSH key authentication...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "echo 'SSH key authentication successful'"
if %errorlevel% neq 0 (
    echo Error: SSH key authentication failed. Please check the key setup.
    pause
    exit /b 1
)

echo.
echo Starting deployment with SSH keys...
echo.

REM Step 1: Clean up old installations
echo [1/15] Cleaning up old installations...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "rm -rf /var/www/nexus-cos /opt/nexus-cos"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "systemctl stop nexus-backend-node nexus-backend-python nginx 2>/dev/null || true"

REM Step 2: Update system
echo [2/15] Updating system packages...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "apt update; apt upgrade -y"

REM Step 3: Install dependencies
echo [3/15] Installing system dependencies...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "apt install -y nginx nodejs npm python3 python3-pip git curl certbot python3-certbot-nginx"

REM Step 4: Install Node.js 18+
echo [4/15] Installing Node.js 18...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "curl -fsSL https://deb.nodesource.com/setup_18.x | bash -"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "apt install -y nodejs"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "npm install -g pm2"

REM Step 5: Clone repository
echo [5/15] Cloning NEXUS COS repository...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "cd /opt; git clone https://github.com/BobbyBlanco400/nexus-cos.git nexus-cos"

REM Step 6: Install backend dependencies
echo [6/15] Installing backend dependencies...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "cd /opt/nexus-cos/backend; npm install"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "cd /opt/nexus-cos/backend; pip3 install -r requirements.txt"

REM Step 7: Build frontend
echo [7/15] Building frontend...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "cd /opt/nexus-cos/da-boom-boom-room/frontend; npm install"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "cd /opt/nexus-cos/da-boom-boom-room/frontend; npm run build"

REM Step 8: Deploy frontend
echo [8/15] Deploying frontend...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "mkdir -p /var/www/nexus-cos"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "cp -r /opt/nexus-cos/da-boom-boom-room/frontend/dist/* /var/www/nexus-cos/"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "mkdir -p /var/www/nexus-cos/mobile"

REM Step 9: Create Nginx configuration
echo [9/15] Configuring Nginx...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "cat > /etc/nginx/sites-available/nexus-cos << 'EOF'
server {
    listen 80;
    server_name nexuscos.online *.nexuscos.online;
    
    location / {
        root /var/www/nexus-cos;
        try_files \$uri \$uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    location /py/ {
        proxy_pass http://localhost:3001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    location /health {
        proxy_pass http://localhost:3000/health;
    }
    
    location /py/health {
        proxy_pass http://localhost:3001/health;
    }
}
EOF"

REM Step 10: Enable Nginx site
echo [10/15] Enabling Nginx site...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "ln -sf /etc/nginx/sites-available/nexus-cos /etc/nginx/sites-enabled/"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "rm -f /etc/nginx/sites-enabled/default"

REM Step 11: Start backend services
echo [11/15] Starting backend services...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "cd /opt/nexus-cos/backend; pm2 start app.js --name nexus-backend-node"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "cd /opt/nexus-cos/backend; pm2 start main.py --name nexus-backend-python --interpreter python3"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "pm2 startup"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "pm2 save"

REM Step 12: Test and restart Nginx
echo [12/15] Testing and restarting Nginx...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "nginx -t"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "systemctl restart nginx"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "systemctl enable nginx"

REM Step 13: Setup SSL
echo [13/15] Setting up SSL certificates...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "certbot --nginx -d nexuscos.online --non-interactive --agree-tos --email puaboverse@gmail.com"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "systemctl enable certbot.timer"

REM Step 14: Health checks
echo [14/15] Running health checks...
timeout /t 10 /nobreak >nul
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "curl -f http://localhost:3000/health"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "curl -f http://localhost:3001/health"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "curl -f http://nexuscos.online/health"

REM Step 15: Display status
echo [15/15] Deployment status...
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "pm2 status"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "systemctl status nginx --no-pager"
ssh -i C:\Users\wecon\.ssh\nexus-cos-vps -o "StrictHostKeyChecking=no" root@74.208.155.161 "certbot certificates"

echo.
echo ========================================
echo NEXUS COS deployment completed!
echo Website: https://nexuscos.online
echo Node.js Health: https://nexuscos.online/health
echo Python Health: https://nexuscos.online/py/health
echo ========================================
echo.
pause