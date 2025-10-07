# API Routing and Health Chips Fix

## Problem
Core Services chips were displaying as "offline/unknown" during development due to:
- Inconsistent baseURL usage causing path duplication (`/api/api/...`)
- Missing standardized health endpoints
- Incorrect proxy configuration in Vite

## Solution

### Frontend Changes

#### 1. API Service (`frontend/src/services/api.ts`)
- Created centralized API client with smart baseURL detection
- In development (port 3000): auto-targets `http://localhost:3004`
- In production: uses `VITE_API_URL` or falls back to `/api`
- Prevents path duplication by handling endpoint paths consistently

#### 2. Core Services Status Component (`frontend/src/components/CoreServicesStatus.tsx`)
- Displays health status chips for all core services
- Auto-refreshes every 30 seconds
- Visual indicators: ✓ (healthy), ✗ (offline), ? (unknown)

#### 3. Vite Configuration (`frontend/vite.config.ts`)
- Added proxy configuration for `/api` and `/health` routes
- Targets backend on `http://localhost:3004` in development
- Ensures no self-proxy loops

### Backend Changes

#### 1. Health Endpoints (`backend/src/server.ts`)
Added three standardized endpoints:

- `GET /health` - Basic health check
  ```json
  { "status": "ok" }
  ```

- `GET /api/system/status` - Overall system health
  ```json
  {
    "services": {
      "auth": "healthy",
      "creator-hub": "healthy",
      ...
    },
    "updatedAt": "2025-10-07T06:06:02.409Z"
  }
  ```

- `GET /api/services/:service/health` - Individual service health
  ```json
  {
    "service": "auth",
    "status": "healthy",
    "updatedAt": "2025-10-07T06:06:02.409Z"
  }
  ```

### Testing
- Added comprehensive test suite (`backend/__tests__/health.test.js`)
- Tests verify endpoint responses and prevent path duplication
- All tests passing (8 tests)

## Development Setup

1. Start backend on port 3004:
   ```bash
   cd backend
   PORT=3004 npm run dev
   ```

2. Start frontend on port 3000:
   ```bash
   cd frontend
   npm run dev
   ```

3. Access the UI at `http://localhost:3000/`
   - Core Services Status section displays with health chips
   - All services show as "healthy" (green checkmarks)

## Production Configuration

In production, update `frontend/.env` to:
```
VITE_API_URL=https://nexuscos.online/api
```

The API client will automatically use this URL instead of `localhost:3004`.

## Key Benefits

✅ No path duplication (`/api/api/...`)  
✅ Clean separation of dev and prod configurations  
✅ Consistent health endpoint schema  
✅ Real-time service status monitoring  
✅ Comprehensive test coverage  
