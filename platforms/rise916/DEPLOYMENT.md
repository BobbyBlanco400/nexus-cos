# Rise Sacramento Platform - Deployment Guide

## Quick Start

### Prerequisites
- Node.js 18+ and npm
- Git

### Local Development Setup

#### 1. Backend Setup

```bash
cd platforms/rise916/backend

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Start backend server
npm start
```

The backend will be available at `http://localhost:3001`

#### 2. Frontend Setup

```bash
cd platforms/rise916/frontend

# Install dependencies
npm install

# Create .env file
cp .env.example .env
# Edit .env and set REACT_APP_API_URL=http://localhost:3001

# Start frontend development server
npm start
```

The frontend will be available at `http://localhost:3000`

## Production Deployment

### Option 1: VPS Deployment (as specified in platform.json)

The platform is configured to be deployed to `/opt/nexus-cos/platforms/rise916` on a VPS.

#### Deployment Steps:

```bash
# 1. Create directory structure on VPS
mkdir -p /opt/nexus-cos/platforms/rise916/{frontend,backend,db,assets,modules,config}

# 2. Copy platform files to VPS
scp -r platforms/rise916/* user@your-vps:/opt/nexus-cos/platforms/rise916/

# 3. SSH into VPS
ssh user@your-vps

# 4. Setup backend
cd /opt/nexus-cos/platforms/rise916/backend
npm install
# Configure environment variables
cp .env.example .env
# Edit .env with production settings

# 5. Setup frontend
cd /opt/nexus-cos/platforms/rise916/frontend
npm install
npm run build
# The build output will be in the 'build' directory

# 6. Configure web server (nginx/Apache) to serve the frontend build
# and proxy API requests to the backend

# 7. Start backend with PM2 or systemd
pm2 start server.js --name rise916-backend
# or use the start command from platform.json
```

### Option 2: Docker Deployment

Create a docker-compose.yml file:

```yaml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=production
      - PORT=3001
    restart: always

  frontend:
    build:
      context: ./frontend
    ports:
      - "3000:80"
    environment:
      - REACT_APP_API_URL=http://backend:3001
    depends_on:
      - backend
    restart: always
```

Then run:
```bash
docker-compose up -d
```

### Option 3: Cloud Platform Deployment

#### Vercel (Frontend) + Heroku (Backend)

**Frontend (Vercel):**
```bash
cd platforms/rise916/frontend
vercel deploy --prod
```

**Backend (Heroku):**
```bash
cd platforms/rise916/backend
heroku create rise916-backend
git init
git add .
git commit -m "Initial commit"
heroku git:remote -a rise916-backend
git push heroku main
```

## Environment Variables

### Backend (.env)
```
PORT=3001
NODE_ENV=production
FRONTEND_URL=https://your-frontend-domain.com
```

### Frontend (.env)
```
REACT_APP_API_URL=https://your-backend-domain.com
REACT_APP_PLATFORM_NAME=Rise Sacramento: VoicesOfThe916
```

## Platform Configuration

The platform configuration is stored in `config/platform.json` and includes:
- Platform metadata
- Deployment settings
- Module definitions
- Branding information
- Feature flags

## Monitoring and Maintenance

### Health Checks
- Backend: `GET http://your-backend/api/health`
- Frontend: Access the main page

### Logs
- Backend logs: Check server console or log files
- Frontend logs: Browser console

### Updates
The platform supports auto-updates as specified in platform.json:
```json
{
  "deploy": {
    "auto_update": true
  }
}
```

## Troubleshooting

### Backend Issues
- Check if port 3001 is available
- Verify environment variables are set
- Check server logs for errors

### Frontend Issues
- Ensure REACT_APP_API_URL points to the correct backend
- Clear browser cache
- Check console for errors

### CORS Issues
If you encounter CORS errors:
- Verify backend CORS configuration in server.js
- Ensure FRONTEND_URL environment variable is correct

## Support

For issues or questions, refer to:
- Platform README.md
- Individual component documentation
- Nexus COS main documentation

## Security Notes

- Always use HTTPS in production
- Keep dependencies updated
- Set proper CORS origins
- Use environment variables for sensitive data
- Implement rate limiting for API endpoints
- Enable security headers (helmet.js for Express)

## Next Steps

After deployment:
1. Configure SSL certificates
2. Set up domain names
3. Implement analytics
4. Add monitoring (e.g., PM2, New Relic)
5. Configure backups
6. Set up CI/CD pipeline
7. Implement the remaining modules from the modules list
