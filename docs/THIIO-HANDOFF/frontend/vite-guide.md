# Vite Frontend Development Guide

## Overview

The Nexus COS frontend is built using Vite, React, and TypeScript. This guide covers setup, development, deployment, and best practices for the frontend application.

## Technology Stack

- **Build Tool**: Vite 4+
- **Framework**: React 18+
- **Language**: TypeScript 5+
- **State Management**: Redux Toolkit / Zustand
- **Styling**: Tailwind CSS 3+
- **UI Components**: Material-UI (MUI)
- **Routing**: React Router v6
- **API Client**: Axios / React Query
- **Testing**: Vitest, React Testing Library

## Project Structure

```
frontend/
├── public/                 # Static assets
│   ├── favicon.ico
│   └── logo.svg
├── src/
│   ├── api/               # API client and endpoints
│   │   ├── client.ts
│   │   ├── auth.ts
│   │   └── users.ts
│   ├── components/        # Reusable components
│   │   ├── common/
│   │   ├── layout/
│   │   └── features/
│   ├── hooks/             # Custom React hooks
│   │   ├── useAuth.ts
│   │   └── useApi.ts
│   ├── pages/             # Page components
│   │   ├── Home.tsx
│   │   ├── Dashboard.tsx
│   │   └── Login.tsx
│   ├── store/             # Redux store
│   │   ├── index.ts
│   │   ├── slices/
│   │   └── middleware/
│   ├── styles/            # Global styles
│   │   ├── index.css
│   │   └── tailwind.css
│   ├── types/             # TypeScript types
│   │   ├── api.ts
│   │   └── models.ts
│   ├── utils/             # Utility functions
│   │   ├── format.ts
│   │   └── validation.ts
│   ├── App.tsx            # Root component
│   ├── main.tsx           # Entry point
│   └── vite-env.d.ts      # Vite type declarations
├── .env.example           # Environment variables template
├── .eslintrc.js           # ESLint configuration
├── .prettierrc            # Prettier configuration
├── index.html             # HTML template
├── package.json           # Dependencies
├── tsconfig.json          # TypeScript configuration
├── vite.config.ts         # Vite configuration
└── tailwind.config.js     # Tailwind configuration
```

## Getting Started

### Prerequisites

```bash
# Node.js 18+
node --version

# npm 9+
npm --version
```

### Installation

```bash
# Clone repository
git clone https://github.com/nexus-cos/nexus-cos
cd nexus-cos/frontend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your configuration
nano .env
```

### Environment Variables

```bash
# .env
VITE_API_URL=http://localhost:3000/api/v1
VITE_APP_NAME=Nexus COS
VITE_APP_VERSION=2.0.0
VITE_ENABLE_DEVTOOLS=true
VITE_SENTRY_DSN=your-sentry-dsn
```

### Development Server

```bash
# Start development server
npm run dev

# Server starts at http://localhost:5173
```

### Building for Production

```bash
# Build for production
npm run build

# Preview production build
npm run preview

# Build output in dist/
```

## Vite Configuration

### vite.config.ts

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@api': path.resolve(__dirname, './src/api'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
      '@store': path.resolve(__dirname, './src/store'),
      '@utils': path.resolve(__dirname, './src/utils'),
      '@types': path.resolve(__dirname, './src/types'),
    },
  },

  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
    },
  },

  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor': ['react', 'react-dom', 'react-router-dom'],
          'ui': ['@mui/material', '@mui/icons-material'],
          'state': ['@reduxjs/toolkit', 'react-redux'],
          'utils': ['axios', 'lodash'],
        },
      },
    },
    chunkSizeWarningLimit: 1000,
  },

  optimizeDeps: {
    include: ['react', 'react-dom'],
  },
});
```

## State Management

### Redux Toolkit Setup

```typescript
// src/store/index.ts
import { configureStore } from '@reduxjs/toolkit';
import authReducer from './slices/authSlice';
import userReducer from './slices/userSlice';

export const store = configureStore({
  reducer: {
    auth: authReducer,
    user: userReducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: false,
    }),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

### Auth Slice Example

```typescript
// src/store/slices/authSlice.ts
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { authApi } from '@api/auth';

interface AuthState {
  user: User | null;
  token: string | null;
  loading: boolean;
  error: string | null;
}

const initialState: AuthState = {
  user: null,
  token: localStorage.getItem('token'),
  loading: false,
  error: null,
};

export const login = createAsyncThunk(
  'auth/login',
  async (credentials: LoginCredentials) => {
    const response = await authApi.login(credentials);
    localStorage.setItem('token', response.token);
    return response;
  }
);

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    logout: (state) => {
      state.user = null;
      state.token = null;
      localStorage.removeItem('token');
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(login.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(login.fulfilled, (state, action) => {
        state.loading = false;
        state.user = action.payload.user;
        state.token = action.payload.token;
      })
      .addCase(login.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || 'Login failed';
      });
  },
});

export const { logout } = authSlice.actions;
export default authSlice.reducer;
```

## API Integration

### API Client Setup

```typescript
// src/api/client.ts
import axios from 'axios';

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Redirect to login
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default apiClient;
```

### API Service Example

```typescript
// src/api/users.ts
import apiClient from './client';
import { User } from '@types/models';

export const userApi = {
  getProfile: async (): Promise<User> => {
    const { data } = await apiClient.get('/users/me');
    return data;
  },

  updateProfile: async (userData: Partial<User>): Promise<User> => {
    const { data } = await apiClient.put('/users/me', userData);
    return data;
  },

  getUsers: async (params?: {
    page?: number;
    limit?: number;
  }): Promise<{ users: User[]; total: number }> => {
    const { data } = await apiClient.get('/users', { params });
    return data;
  },
};
```

## Routing

### Router Setup

```typescript
// src/App.tsx
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { lazy, Suspense } from 'react';
import Layout from '@components/layout/Layout';
import Loading from '@components/common/Loading';
import ProtectedRoute from '@components/common/ProtectedRoute';

// Lazy load pages
const Home = lazy(() => import('@pages/Home'));
const Dashboard = lazy(() => import('@pages/Dashboard'));
const Login = lazy(() => import('@pages/Login'));
const NotFound = lazy(() => import('@pages/NotFound'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<Loading />}>
        <Routes>
          <Route path="/login" element={<Login />} />
          
          <Route path="/" element={<Layout />}>
            <Route index element={<Home />} />
            
            <Route
              path="/dashboard"
              element={
                <ProtectedRoute>
                  <Dashboard />
                </ProtectedRoute>
              }
            />
            
            <Route path="/404" element={<NotFound />} />
            <Route path="*" element={<Navigate to="/404" replace />} />
          </Route>
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}

export default App;
```

## Styling

### Tailwind CSS

```css
/* src/styles/index.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply bg-gray-50 text-gray-900 dark:bg-gray-900 dark:text-gray-100;
  }
}

@layer components {
  .btn-primary {
    @apply bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors;
  }

  .card {
    @apply bg-white dark:bg-gray-800 rounded-lg shadow-md p-6;
  }
}
```

### Tailwind Config

```javascript
// tailwind.config.js
module.exports = {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          900: '#1e3a8a',
        },
      },
    },
  },
  plugins: [],
};
```

## Testing

### Component Testing

```typescript
// src/components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import Button from './Button';

describe('Button', () => {
  it('renders button with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

## Performance Optimization

### Code Splitting

```typescript
// Lazy load routes
const Dashboard = lazy(() => import('./pages/Dashboard'));

// Lazy load components
const HeavyComponent = lazy(() => import('./components/HeavyComponent'));

// Use with Suspense
<Suspense fallback={<Loading />}>
  <HeavyComponent />
</Suspense>
```

### Image Optimization

```typescript
// Use WebP with fallback
<picture>
  <source srcSet="/images/hero.webp" type="image/webp" />
  <img src="/images/hero.jpg" alt="Hero" />
</picture>
```

## Deployment

### Build for Production

```bash
# Build
npm run build

# Preview
npm run preview
```

### Deploy to CDN

```bash
# Deploy to S3
aws s3 sync dist/ s3://nexus-cos-frontend/ --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id EXXXXXXXXXXXXX \
  --paths "/*"
```

### Nginx Configuration

```nginx
server {
    listen 80;
    server_name nexuscos.example.com;
    root /var/www/nexus-cos/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /assets {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
}
```

## Best Practices

1. **Use TypeScript**: Type safety prevents bugs
2. **Code Splitting**: Lazy load pages and heavy components
3. **Error Boundaries**: Graceful error handling
4. **Accessibility**: Use semantic HTML and ARIA labels
5. **Performance**: Monitor bundle size and optimize
6. **Testing**: Write tests for critical paths
7. **Security**: Sanitize user input, use CSP headers

---

**Last Updated**: December 2025  
**Vite Version**: 4+  
**React Version**: 18+
