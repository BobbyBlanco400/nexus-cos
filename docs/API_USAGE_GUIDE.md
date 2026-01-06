# API Usage Guide

## Quick Start

### Import the API Client

```typescript
import { api, healthApi } from '../services/api';
```

### Making API Calls

#### Basic GET Request
```typescript
const response = await api.get('/api/endpoint');
if (response.data) {
  console.log(response.data);
}
```

#### POST Request
```typescript
const response = await api.post('/api/endpoint', { 
  key: 'value' 
});
```

#### PUT Request
```typescript
const response = await api.put('/api/endpoint', { 
  key: 'updated value' 
});
```

#### DELETE Request
```typescript
const response = await api.delete('/api/endpoint');
```

### Health Check APIs

#### Get System Status
```typescript
const response = await healthApi.getSystemStatus();
// Returns: { services: { auth: 'healthy', ... }, updatedAt: '...' }
```

#### Get Service Health
```typescript
const response = await healthApi.getServiceHealth('auth');
// Returns: { service: 'auth', status: 'healthy', updatedAt: '...' }
```

#### Basic Health Check
```typescript
const response = await healthApi.getHealth();
// Returns: { status: 'ok' }
```

## Important Notes

### Endpoint Paths

✅ **Correct:** Use relative paths starting with `/`
```typescript
api.get('/api/system/status')  // ✅
api.get('/api/services/auth/health')  // ✅
```

❌ **Incorrect:** Don't duplicate `/api` in paths
```typescript
api.get('/api/api/system/status')  // ❌ Path duplication
```

### BaseURL Behavior

The API client automatically determines the correct baseURL:

- **Development (localhost:3000):** `http://localhost:3004`
- **Production:** `VITE_API_URL` env var or `/api`

You don't need to specify the full URL - just the endpoint path.

### Error Handling

```typescript
const response = await api.get('/api/endpoint');

if (response.error) {
  console.error('API Error:', response.error);
  // Handle error
} else if (response.data) {
  // Success - use response.data
}
```

### TypeScript Types

```typescript
import type { SystemStatus, ServiceHealth } from '../services/api';

// Use the types
const [status, setStatus] = useState<SystemStatus | null>(null);
```

## Environment Configuration

### Development
File: `frontend/.env.development`
```env
VITE_API_URL=http://localhost:3004
```

### Production
File: `frontend/.env`
```env
VITE_API_URL=https://n3xuscos.online/api
```

## Testing API Endpoints

### Using curl
```bash
# Health check
curl http://localhost:3004/health

# System status
curl http://localhost:3004/api/system/status

# Service health
curl http://localhost:3004/api/services/auth/health
```

### Using the browser
Navigate to:
- http://localhost:3000/health (via Vite proxy)
- http://localhost:3000/api/system/status (via Vite proxy)

## Common Patterns

### Polling for Updates
```typescript
useEffect(() => {
  const fetchStatus = async () => {
    const response = await healthApi.getSystemStatus();
    if (response.data) {
      setStatus(response.data);
    }
  };

  fetchStatus();
  const interval = setInterval(fetchStatus, 30000); // 30 seconds

  return () => clearInterval(interval);
}, []);
```

### Loading States
```typescript
const [loading, setLoading] = useState(true);

const fetchData = async () => {
  try {
    setLoading(true);
    const response = await api.get('/api/endpoint');
    // Process response
  } finally {
    setLoading(false);
  }
};
```

## Best Practices

1. **Always handle errors:** Check for `response.error` before using `response.data`
2. **Use TypeScript types:** Import and use the provided interfaces
3. **Don't duplicate paths:** The baseURL includes `/api` in production
4. **Clean up intervals:** Always clear intervals in useEffect cleanup
5. **Use the health APIs:** Don't make manual fetch calls for health checks
