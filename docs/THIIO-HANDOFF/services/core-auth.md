# Core Authentication Service

## Overview

The Core Authentication Service provides unified authentication and authorization for the entire Nexus COS platform. It integrates multiple authentication services (auth-service, auth-service-v2, user-auth, session-mgr, token-mgr) into a cohesive authentication flow.

## Service Information

- **Service Group**: Core Authentication
- **Primary Services**: 
  - `auth-service` (Port 3001)
  - `auth-service-v2` (Port 3002)
  - `user-auth` (Port 3003)
  - `session-mgr` (Port 3004)
  - `token-mgr` (Port 3005)
- **Repository**: `services/auth/`
- **Owner Team**: Platform Security Team
- **On-Call Contact**: owner+auth@nexuscos.example.com

## Architecture

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       v
┌──────────────────┐
│  auth-service-v2 │  (OAuth 2.0, Social Auth)
│  (Port 3002)     │
└────────┬─────────┘
         │
         v
┌──────────────────┐
│  auth-service    │  (Primary Auth Logic)
│  (Port 3001)     │
└────────┬─────────┘
         │
    ┌────┴────┬────────┬────────┐
    v         v        v        v
┌─────────┐ ┌──────────┐ ┌─────────┐ ┌─────────┐
│user-auth│ │session-  │ │token-   │ │key-     │
│(3003)   │ │mgr(3004) │ │mgr(3005)│ │service  │
└─────────┘ └──────────┘ └─────────┘ └─────────┘
```

## Authentication Flow

### 1. User Registration

```
POST /api/v1/auth/register
{
  "email": "user@example.com",
  "password": "SecureP@ss123",
  "name": "John Doe"
}

Response:
{
  "userId": "uuid",
  "email": "user@example.com",
  "verified": false,
  "token": "jwt-token"
}
```

### 2. User Login

```
POST /api/v1/auth/login
{
  "email": "user@example.com",
  "password": "SecureP@ss123"
}

Response:
{
  "accessToken": "eyJhbG...",
  "refreshToken": "eyJhbG...",
  "expiresIn": 3600,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "roles": ["user"]
  }
}
```

### 3. Token Refresh

```
POST /api/v1/auth/refresh
{
  "refreshToken": "eyJhbG..."
}

Response:
{
  "accessToken": "new-jwt-token",
  "expiresIn": 3600
}
```

### 4. OAuth 2.0 Flow

```
# Initiate OAuth
GET /api/v1/auth/oauth/google

# Callback
GET /api/v1/auth/oauth/callback?code=xxx&state=yyy

Response: (Redirect to app with tokens)
```

## API Endpoints

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Register new user |
| POST | `/api/v1/auth/login` | User login |
| POST | `/api/v1/auth/logout` | User logout |
| POST | `/api/v1/auth/refresh` | Refresh access token |
| POST | `/api/v1/auth/verify-email` | Verify email address |
| POST | `/api/v1/auth/forgot-password` | Request password reset |
| POST | `/api/v1/auth/reset-password` | Reset password |
| GET | `/api/v1/auth/me` | Get current user |

### OAuth Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/auth/oauth/google` | Google OAuth |
| GET | `/api/v1/auth/oauth/github` | GitHub OAuth |
| GET | `/api/v1/auth/oauth/callback` | OAuth callback |

### Session Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/sessions` | List user sessions |
| DELETE | `/api/v1/sessions/:id` | Revoke session |
| DELETE | `/api/v1/sessions/all` | Revoke all sessions |

## Configuration

### Environment Variables

```bash
# Auth Service
AUTH_SERVICE_PORT=3001
JWT_SECRET=your-secret-key-change-in-production
JWT_EXPIRATION=1h
REFRESH_TOKEN_EXPIRATION=7d

# Auth Service V2
AUTH_V2_PORT=3002
OAUTH_GOOGLE_CLIENT_ID=your-google-client-id
OAUTH_GOOGLE_CLIENT_SECRET=your-google-secret
OAUTH_GOOGLE_CALLBACK_URL=https://api.nexuscos.example.com/auth/oauth/callback

# User Auth
USER_AUTH_PORT=3003
PASSWORD_MIN_LENGTH=8
PASSWORD_REQUIRE_SPECIAL_CHAR=true
EMAIL_VERIFICATION_REQUIRED=true

# Session Manager
SESSION_MGR_PORT=3004
SESSION_TTL=3600
MAX_SESSIONS_PER_USER=5

# Token Manager
TOKEN_MGR_PORT=3005
TOKEN_ISSUER=nexus-cos
TOKEN_AUDIENCE=nexus-cos-api
```

## Database Schema

### Users Table

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    email_verified BOOLEAN DEFAULT FALSE,
    phone VARCHAR(50),
    phone_verified BOOLEAN DEFAULT FALSE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_deleted ON users(deleted_at);
```

### Sessions Table

```sql
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    token_hash VARCHAR(255) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_token_hash ON sessions(token_hash);
CREATE INDEX idx_sessions_expires_at ON sessions(expires_at);
```

### OAuth Accounts Table

```sql
CREATE TABLE oauth_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    provider VARCHAR(50) NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    access_token TEXT,
    refresh_token TEXT,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(provider, provider_user_id)
);

CREATE INDEX idx_oauth_user_id ON oauth_accounts(user_id);
```

## Security Features

### Password Security

- **Hashing**: bcrypt with 12 rounds
- **Requirements**:
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
  - At least one special character
- **Password History**: Last 5 passwords stored
- **Lockout**: 5 failed attempts = 15-minute lockout

### Token Security

- **JWT Algorithm**: HS256 (HMAC with SHA-256)
- **Access Token**: 1 hour expiration
- **Refresh Token**: 7 days expiration
- **Token Rotation**: Refresh tokens rotated on use
- **Revocation**: Support for immediate token revocation

### Session Security

- **Session Tracking**: IP address and user agent
- **Max Sessions**: 5 concurrent sessions per user
- **Inactivity Timeout**: 30 minutes
- **Absolute Timeout**: 24 hours

### Two-Factor Authentication

- **TOTP**: Time-based one-time passwords
- **Backup Codes**: 10 single-use backup codes
- **Recovery**: Email-based account recovery

## Monitoring

### Key Metrics

```promql
# Login success rate
rate(auth_login_total{status="success"}[5m]) /
rate(auth_login_total[5m])

# Failed login attempts
rate(auth_login_total{status="failed"}[5m])

# Active sessions
auth_active_sessions_count

# Token generation rate
rate(auth_tokens_generated_total[5m])
```

### Alerts

- **HighFailedLogins**: > 100 failed logins/min (possible attack)
- **TokenGenerationSpike**: > 1000 tokens/min
- **SessionCountHigh**: > 10000 active sessions
- **AuthServiceDown**: Health check failing

## Rate Limiting

- **Login**: 5 attempts per 15 minutes per IP
- **Registration**: 3 attempts per hour per IP
- **Password Reset**: 3 attempts per hour per email
- **API Requests**: 1000 requests per hour per user

## Troubleshooting

### Common Issues

#### Users Can't Login

```bash
# Check auth service health
kubectl logs -n nexus-cos -l app=auth-service --tail=100

# Verify database connectivity
kubectl exec -it auth-service-xxx -n nexus-cos -- \
  psql $DATABASE_URL -c "SELECT count(*) FROM users"

# Check Redis (for rate limiting)
kubectl exec -it redis-0 -n nexus-cos -- redis-cli ping
```

#### Token Validation Failures

```bash
# Verify JWT secret is consistent across pods
kubectl get secret auth-secrets -n nexus-cos -o jsonpath='{.data.JWT_SECRET}' | base64 -d

# Check token expiration
# Decode JWT at https://jwt.io

# Verify token in database
kubectl exec -it postgres-0 -n nexus-cos -- \
  psql -d nexusdb -c "SELECT * FROM sessions WHERE token_hash='xxx'"
```

## Testing

### Manual Testing

```bash
# Register user
curl -X POST https://api.nexuscos.example.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!@#",
    "name": "Test User"
  }'

# Login
curl -X POST https://api.nexuscos.example.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!@#"
  }'

# Use token
TOKEN="your-jwt-token"
curl https://api.nexuscos.example.com/api/v1/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

## Performance

### Baseline Metrics

- **Login**: < 200ms (p95)
- **Token Generation**: < 50ms (p95)
- **Token Validation**: < 10ms (p95)
- **Throughput**: 1000 logins/second

### Optimization

- Cache user data in Redis (5-minute TTL)
- Connection pooling for database (20 connections per replica)
- JWT validation without database lookup (until expiration)

## Disaster Recovery

### Backup

- User database: Daily full backup
- Session data: Redis persistence every 5 minutes
- OAuth tokens: Encrypted backup daily

### Recovery

```bash
# Restore user database
kubectl exec -it postgres-0 -n nexus-cos -- \
  pg_restore -d nexusdb /backups/auth-db-latest.dump

# Clear session cache
kubectl exec -it redis-0 -n nexus-cos -- redis-cli FLUSHDB

# Restart auth services
kubectl rollout restart deployment -n nexus-cos -l component=auth
```

---

**Status**: Production  
**Last Updated**: December 2025  
**Critical Service**: Yes
