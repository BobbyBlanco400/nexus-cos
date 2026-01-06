# Token Manager - Admin Auth Service

This microservice provides admin authentication and authorization endpoints for the Nexus COS platform. It runs on port 3102 and handles admin user management.

## Overview

The Token Manager (`token-mgr`) is a microservice under the auth-service that specifically handles:

- Admin user registration and creation
- Admin authentication with JWT tokens
- Role-based access control (ADMIN, SUPER_ADMIN)
- Permission-based authorization
- Secure password handling with bcrypt

## Fixed Issues

This service addresses the following issues mentioned in the problem statement:

✅ **Fixed: "Cannot POST /api/admin/register"** - Endpoint now exists and works  
✅ **Fixed: "Cannot POST /api/admin/create"** - Endpoint now exists and works  
✅ **Fixed: "SyntaxError: Bad escaped character in JSON"** - Proper JSON parsing middleware  
✅ **Fixed: "password: Path `password` is required"** - Comprehensive validation with clear error messages  

## API Endpoints

### Admin Registration
```http
POST /api/admin/register
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "Admin123!",
  "name": "Admin User",
  "role": "ADMIN",
  "permissions": ["MANAGE_USERS", "MANAGE_CONTENT"]
}
```

### Admin Creation (Super Admin Only)
```http
POST /api/admin/create
Authorization: Bearer <token>
Content-Type: application/json

{
  "username": "admin",
  "email": "admin@example.com",
  "password": "Admin123!",
  "role": "SUPER_ADMIN",
  "permissions": ["MANAGE_USERS", "MANAGE_CONTENT", "MANAGE_SETTINGS"]
}
```

### Admin Login
```http
POST /api/admin/login
Content-Type: application/json

{
  "login": "admin@example.com",
  "password": "Admin123!"
}
```

### Token Refresh
```http
POST /api/admin/refresh
Content-Type: application/json

{
  "refreshToken": "<refresh_token>"
}
```

### Admin Profile
```http
GET /api/admin/profile
Authorization: Bearer <token>
```

### Admin Logout
```http
POST /api/admin/logout
Authorization: Bearer <token>
```

### Health Check
```http
GET /health
```

## Validation Rules

### Password Requirements
- Minimum 6 characters
- At least one uppercase letter
- At least one lowercase letter  
- At least one number
- At least one special character (@$!%*?&)

### Email Requirements
- Valid email format
- Unique across all admin users

### Username Requirements (for create endpoint)
- 3-50 characters
- Alphanumeric only
- Unique across all admin users

## Roles and Permissions

### Roles
- `ADMIN`: Standard admin user
- `SUPER_ADMIN`: Full administrative access

### Available Permissions
- `MANAGE_USERS`: User management
- `MANAGE_CONTENT`: Content management
- `MANAGE_SETTINGS`: System settings
- `MANAGE_BILLING`: Billing operations
- `MANAGE_ANALYTICS`: Analytics access
- `MANAGE_SYSTEM`: System administration
- `VIEW_LOGS`: Log access
- `MANAGE_ROLES`: Role management

### Default Permissions
- `ADMIN`: MANAGE_USERS, MANAGE_CONTENT, MANAGE_SETTINGS, VIEW_LOGS
- `SUPER_ADMIN`: All permissions

## Security Features

- Password hashing with bcrypt (salt rounds: 12)
- JWT tokens with configurable expiration
- Account lockout after 5 failed login attempts (30 minutes)
- Request validation with Joi
- CORS protection
- Helmet security headers
- Rate limiting ready

## Environment Configuration

Copy `.env.example` to `.env` and configure:

```bash
# Server Configuration
PORT=3102
NODE_ENV=production

# Database Configuration  
MONGODB_URI=mongodb://localhost:27017/nexus-cos-admin

# JWT Configuration (CHANGE THESE IN PRODUCTION!)
JWT_SECRET=your-super-secret-key
JWT_EXPIRES_IN=24h
JWT_REFRESH_SECRET=your-refresh-secret-key
JWT_REFRESH_EXPIRES_IN=7d

# CORS Configuration
ALLOWED_ORIGINS=https://n3xuscos.online,https://beta.n3xuscos.online
```

## Deployment

### Using PM2
```bash
# Install dependencies
npm install

# Start with PM2
pm2 start ecosystem.config.js

# Check status
pm2 status nexus-admin-auth

# View logs
pm2 logs nexus-admin-auth
```

### Using npm
```bash
npm install
npm start
```

### Using Docker
```bash
# Build image
docker build -t nexus-admin-auth .

# Run container
docker run -p 3102:3102 nexus-admin-auth
```

## Integration with Nexus COS

This service integrates with the existing Nexus COS infrastructure:

1. **Port 3102**: As specified in `nexus-cos-services-v1.2.yml`
2. **PM2 Management**: Compatible with existing PM2 deployment
3. **MongoDB**: Uses shared MongoDB instance
4. **Load Balancer**: Nginx routes `/api/admin/*` to this service

## Testing

Run the test scripts to verify functionality:

```bash
# Comprehensive endpoint tests
node test-admin-auth-endpoints.js

# PM2 integration test
./test-pm2-integration.sh
```

## Monitoring and Logs

- Health endpoint: `http://localhost:3102/health`
- PM2 logs: `pm2 logs nexus-admin-auth`
- Service status: `pm2 status nexus-admin-auth`

## Troubleshooting

### Common Issues

1. **MongoDB Connection Error**
   - Ensure MongoDB is running
   - Check MONGODB_URI configuration
   - Verify network connectivity

2. **Port Already in Use**
   - Check if another service is using port 3102
   - Use `lsof -i :3102` to identify processes

3. **JWT Token Issues**
   - Verify JWT_SECRET is set
   - Check token expiration times
   - Ensure proper Authorization header format

4. **Validation Errors**
   - Check request body format
   - Verify all required fields are present
   - Ensure password meets complexity requirements

## Production Considerations

- Change default JWT secrets
- Set up MongoDB replica set for high availability
- Configure proper CORS origins
- Set up SSL/TLS termination
- Implement rate limiting
- Set up monitoring and alerting
- Regular security updates

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Admin Panel   │────│  Load Balancer  │────│  Token Manager  │
│  (Frontend)     │    │    (Nginx)      │    │   (Port 3102)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                               ┌─────────────────┐
                                               │    MongoDB      │
                                               │  Admin Users    │
                                               └─────────────────┘
```

This service is now ready for production deployment and resolves all issues mentioned in the original problem statement.