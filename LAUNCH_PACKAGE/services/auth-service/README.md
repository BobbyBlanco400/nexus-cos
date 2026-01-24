# Auth Service - Nexus COS

Core authentication and authorization service providing secure access control across the entire Nexus COS platform.

## Overview

The Auth Service is a foundational core service that handles:
- User authentication and authorization
- Session management and lifecycle
- JWT token generation and validation
- Permission and role-based access control

## Microservices

### session-mgr (Port 3101)
- Session creation and validation
- Session timeout and cleanup
- Multi-device session management
- Session analytics and monitoring

### token-mgr (Port 3102)
- JWT token generation
- Token validation and verification
- Token refresh and renewal
- Token revocation and blacklisting

## Dependencies

This service has **no dependencies** on other core services as it provides foundational authentication capabilities.

### Dependent Modules
The following modules depend on this service:
- `core-os` - System-level authentication
- `puabo-dsp` - Platform user access
- `puabo-blac` - Financial service authentication
- `v-suite` - Creative tool access control
- `media-community` - Community platform authentication
- `business-tools` - Enterprise tool access

## API Endpoints

### Authentication
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `GET /auth/validate` - Token validation
- `POST /auth/refresh` - Token refresh

### Health
- `GET /health` - Service health check

## Events

### Published Events
- `auth.user.login` - User successfully logged in
- `auth.user.logout` - User logged out
- `auth.session.expired` - Session has expired

## Database Schema

- `users` - User account information
- `sessions` - Active user sessions
- `tokens` - JWT tokens and metadata
- `permissions` - User permissions and roles

## Configuration

```yaml
AUTH_SERVICE_PORT: 3100
SESSION_TIMEOUT: 3600
TOKEN_EXPIRY: 1800
JWT_SECRET: ${JWT_SECRET}
DATABASE_URL: ${DATABASE_URL}
```

## Getting Started

1. Install dependencies: `npm install`
2. Configure environment variables
3. Run database migrations
4. Start the service: `npm start`
5. Verify health: `curl http://localhost:3100/health`