# Nexus Stream - Vite Frontend

## Overview

**Application**: Nexus Stream
**Type**: Netflix-Inspired Streaming Platform Frontend  
**Framework**: React 19 + TypeScript + Vite
**Purpose**: Primary user-facing entry point to Nexus COS Platform

## Technology Stack

### Frontend Framework
- **React**: 19.1.1 (Latest)
- **TypeScript**: Type-safe development
- **Vite**: 7.1.5 - Lightning-fast build tool

### Styling
- **Tailwind CSS**: 4.1.13 - Utility-first CSS
- **Custom CSS**: Netflix-inspired styling
- **PostCSS**: 8.5.6 - CSS processing
- **Autoprefixer**: 10.4.21 - Browser compatibility

### Additional Libraries
- **Stripe**: 18.5.0 - Payment processing integration
- **React DOM**: 19.1.1 - React rendering

## Features

### Main Application Sections

#### 1. Home / Landing Page
- Netflix-inspired hero section
- Content discovery interface
- Platform overview
- Service status display

#### 2. V-Suite Professional Tools
- **V-Prompter Pro**: `/v-suite/prompter` - Professional teleprompter
- **V-Caster Pro**: Casting and talent management
- **V-Screen Pro**: Screen production tools

#### 3. Creator Hub
- Content creation tools
- Publishing dashboard
- Analytics and metrics
- Revenue management

#### 4. Admin Panel
- Platform administration
- User management
- Service monitoring
- Configuration management

### User Experience Features
- **Loading Screen**: Platform initialization animation
- **Real-time Status**: Live service health monitoring
- **Responsive Design**: Mobile, tablet, desktop support
- **Dark Theme**: Netflix-inspired dark UI
- **Smooth Animations**: Professional transitions

## Directory Structure

```
frontend/
├── src/
│   ├── App.tsx                    # Main application component
│   ├── App.css                    # Application-specific styles (15KB)
│   ├── main.tsx                   # Application entry point
│   ├── index.css                  # Global styles
│   ├── vite-env.d.ts              # Vite environment types
│   ├── components/                # React components
│   │   └── CoreServicesStatus.tsx # Service status component
│   ├── services/                  # API service layer
│   └── assets/                    # Images, icons, media
├── public/                        # Public static assets
├── app/                           # Additional app modules
├── index.html                     # HTML template
├── package.json                   # Dependencies and scripts
├── vite.config.ts                 # Vite build configuration
├── tsconfig.json                  # TypeScript configuration
├── tsconfig.app.json              # App-specific TS config
├── tsconfig.node.json             # Node-specific TS config
├── eslint.config.js               # ESLint rules
├── Dockerfile                     # Container build
├── .env.example                   # Environment template
├── .env.development               # Dev environment
└── README.md                      # Documentation
```

## Installation & Setup

### Prerequisites
- **Node.js**: >= 18.18.0 (specified in `.nvmrc`)
- **npm** or **pnpm**: Package manager

### Installation Steps

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit environment variables
nano .env
```

### Environment Configuration

Create `.env` file:

```bash
# API Gateway
VITE_API_URL=http://localhost:3000
VITE_API_BASE_URL=http://localhost:3000/api

# Streaming Service
VITE_STREAMING_API_URL=http://localhost:3010
VITE_STREAM_CDN_URL=https://cdn.nexuscos.com

# Authentication
VITE_AUTH_SERVICE_URL=http://localhost:3001
VITE_JWT_REFRESH_INTERVAL=3600000

# Content Services
VITE_CONTENT_API_URL=http://localhost:3012
VITE_UPLOAD_API_URL=http://localhost:3015

# Payment Processing
VITE_STRIPE_PUBLIC_KEY=pk_test_your_stripe_key

# Creator Hub
VITE_CREATOR_HUB_URL=http://localhost:3090

# Feature Flags
VITE_ENABLE_ANALYTICS=true
VITE_ENABLE_LIVE_STREAMING=true
VITE_ENABLE_AI_FEATURES=true
VITE_ENABLE_CREATOR_TOOLS=true

# Analytics & Monitoring
VITE_ANALYTICS_ID=UA-XXXXXXXXX
VITE_SENTRY_DSN=https://your-sentry-dsn

# Environment
VITE_NODE_ENV=development
```

## Development

### Start Development Server

```bash
npm run dev
```

- **URL**: http://localhost:5173
- **Hot Module Replacement**: Enabled
- **Fast Refresh**: React components auto-reload

### Build for Production

```bash
npm run build
```

- **Output**: `dist/` directory
- **Optimizations**: Minification, tree-shaking, code splitting
- **Asset Optimization**: Images, CSS, JS bundled

### Preview Production Build

```bash
npm run preview
```

Access production build locally before deployment.

## Components

### Main Components

#### App.tsx
**Purpose**: Root application component

**Features**:
- Loading state management
- Header with navigation
- Hero section with platform introduction
- Service status monitoring
- Main content routing

**Structure**:
```tsx
function App() {
  const [loading, setLoading] = useState(true)
  
  // Loading screen (1.5s initialization)
  if (loading) {
    return <LoadingScreen />
  }
  
  return (
    <div className="nexus-platform">
      <Header />
      <Hero />
      <CoreServicesStatus />
      <FeatureSections />
    </div>
  )
}
```

#### CoreServicesStatus.tsx
**Purpose**: Real-time service health monitoring

**Displays**:
- Authentication service status
- Streaming service status  
- AI services status
- Business services status
- Platform services status

**Integration**: Polls backend health endpoints

### Component Patterns

```tsx
// Service Status Component Example
interface ServiceStatus {
  name: string
  status: 'online' | 'offline' | 'degraded'
  uptime: number
}

const CoreServicesStatus: React.FC = () => {
  const [services, setServices] = useState<ServiceStatus[]>([])
  
  useEffect(() => {
    // Fetch service status
    fetchServiceStatus()
  }, [])
  
  return (
    <div className="services-grid">
      {services.map(service => (
        <ServiceCard key={service.name} {...service} />
      ))}
    </div>
  )
}
```

## API Integration

### Backend Services Integration

The frontend connects to all 43 backend services via the API Gateway:

```typescript
// API Client Configuration
const API_BASE = import.meta.env.VITE_API_URL

// Authentication
const authAPI = {
  login: (credentials) => fetch(`${API_BASE}/api/auth/login`, {...}),
  logout: () => fetch(`${API_BASE}/api/auth/logout`, {...}),
  register: (userData) => fetch(`${API_BASE}/api/auth/register`, {...}),
}

// Streaming
const streamingAPI = {
  getStream: (id) => fetch(`${API_BASE}/api/stream/${id}`, {...}),
  uploadContent: (file) => fetch(`${API_BASE}/api/dsp/upload`, {...}),
  getMetadata: (id) => fetch(`${API_BASE}/api/dsp/metadata/${id}`, {...}),
}

// Creator Hub
const creatorAPI = {
  getDashboard: () => fetch(`${API_BASE}/api/creator/dashboard`, {...}),
  publishContent: (content) => fetch(`${API_BASE}/api/creator/publish`, {...}),
}
```

### State Management

```typescript
// Using React hooks for state
import { useState, useEffect, useContext } from 'react'

// Authentication state
const [user, setUser] = useState(null)
const [isAuthenticated, setIsAuthenticated] = useState(false)

// Content state
const [content, setContent] = useState([])
const [loading, setLoading] = useState(true)
```

## Deployment

### Docker Deployment

```dockerfile
# Dockerfile (already exists)
FROM node:18-alpine as build

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Build and Run**:
```bash
# Build image
docker build -t nexus-stream-frontend:latest ./frontend

# Run container
docker run -p 8080:80 nexus-stream-frontend:latest
```

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nexus-stream-frontend
  namespace: nexus-platform
  labels:
    app: nexus-stream-frontend
    component: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nexus-stream-frontend
  template:
    metadata:
      labels:
        app: nexus-stream-frontend
    spec:
      containers:
      - name: frontend
        image: nexus-stream-frontend:latest
        ports:
        - containerPort: 80
          name: http
        env:
        - name: VITE_API_URL
          value: "http://backend-api:3000"
        - name: VITE_STREAMING_API_URL
          value: "http://streaming-service-v2:3010"
        resources:
          requests:
            cpu: "250m"
            memory: "512Mi"
          limits:
            cpu: "1000m"
            memory: "1Gi"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: nexus-stream-frontend
  namespace: nexus-platform
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  - port: 443
    targetPort: 80
    protocol: TCP
    name: https
  selector:
    app: nexus-stream-frontend
```

### Nginx Configuration for Production

```nginx
server {
    listen 80;
    server_name nexusstream.com www.nexusstream.com;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name nexusstream.com www.nexusstream.com;
    
    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    root /usr/share/nginx/html;
    index index.html;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # SPA routing - serve index.html for all routes
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # API proxy to backend
    location /api/ {
        proxy_pass http://backend-api:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Static assets caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

## Performance Optimization

### Vite Build Optimizations

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  
  build: {
    // Code splitting
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom'],
          'ui-vendor': ['tailwindcss'],
        }
      }
    },
    
    // Minification
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
      }
    },
    
    // Chunk size warnings
    chunkSizeWarningLimit: 1000,
  },
  
  // Development server
  server: {
    port: 5173,
    host: true,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      }
    }
  }
})
```

### Performance Metrics

**Target Metrics**:
- First Contentful Paint: < 1.5s
- Time to Interactive: < 3s
- Largest Contentful Paint: < 2.5s
- Cumulative Layout Shift: < 0.1
- First Input Delay: < 100ms

### Optimization Techniques
1. **Code Splitting**: Separate vendor and app bundles
2. **Lazy Loading**: Dynamic imports for routes
3. **Image Optimization**: WebP format, lazy loading
4. **Tree Shaking**: Remove unused code
5. **CDN**: Static assets served from CDN
6. **Caching**: Browser and service worker caching

## Security

### Security Measures

#### Environment Variables
- Never commit `.env` files
- Use `.env.example` as template
- Secrets managed via Kubernetes secrets

#### Content Security Policy
```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self' 'unsafe-inline'; 
               style-src 'self' 'unsafe-inline'; 
               img-src 'self' data: https:; 
               connect-src 'self' https://api.nexuscos.com;">
```

#### HTTPS Enforcement
- All production traffic over HTTPS
- HSTS headers enabled
- Secure cookies

#### XSS Protection
- React's built-in XSS protection
- Input sanitization
- Output encoding

## Testing

### Unit Tests
```bash
npm run test
```

### E2E Tests
```bash
npm run test:e2e
```

### Lint & Type Check
```bash
# ESLint
npm run lint

# TypeScript check
tsc --noEmit
```

## Monitoring & Analytics

### Error Tracking
- Integration with glitch service (port 3082)
- Client-side error boundary
- Automatic error reporting

### Performance Monitoring
```typescript
// Report Web Vitals
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals'

getCLS(console.log)
getFID(console.log)
getFCP(console.log)
getLCP(console.log)
getTTFB(console.log)
```

### User Analytics
- Page view tracking
- User interaction events
- Conversion tracking
- A/B testing support

## Browser Support

### Supported Browsers
- Chrome/Edge: Last 2 versions
- Firefox: Last 2 versions  
- Safari: Last 2 versions
- iOS Safari: Last 2 versions
- Android Chrome: Last 2 versions

### Polyfills
Vite automatically includes necessary polyfills based on browserslist configuration.

## Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Kill process on port 5173
lsof -ti:5173 | xargs kill -9

# Or use different port
npm run dev -- --port 5174
```

#### Build Failures
```bash
# Clear cache
rm -rf node_modules dist .vite
npm install
npm run build
```

#### API Connection Issues
```bash
# Check backend services
curl http://localhost:3000/health

# Verify environment variables
cat .env | grep VITE_
```

#### TypeScript Errors
```bash
# Regenerate types
npm run type-check
```

## Integration with THIIO Handoff

### Included in ZIP Bundle
✅ Complete frontend source code
✅ All configuration files
✅ Dockerfile for containerization
✅ Environment templates
✅ Documentation

### Quick Start for THIIO
```bash
# Extract from bundle
cd Nexus-COS-THIIO-FullHandoff/frontend

# Install and run
npm install
npm run dev

# Or deploy with Docker
docker build -t nexus-stream .
docker run -p 80:80 nexus-stream
```

## Future Enhancements

### Planned Features
- Progressive Web App (PWA) support
- Offline mode with service workers
- Real-time notifications via WebSocket
- Advanced search with Elasticsearch
- Personalization engine
- Multi-language support (i18n)
- Mobile app (React Native)

## Contact & Support

For frontend issues:
- Check operational runbooks
- Review architecture documentation
- Monitor service status dashboard

---

**Nexus Stream** - Modern, Fast, Netflix-Inspired Frontend for Nexus COS
**Built with**: React 19 + TypeScript + Vite 7 + Tailwind CSS 4
