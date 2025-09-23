# Frontend Dockerfile for Nexus COS
# Multi-stage build: Build React app + Nginx production server

# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Build arguments for environment variables
ARG VITE_API_NODE_URL=http://localhost:3000
ARG VITE_API_PYTHON_URL=http://localhost:3001
ARG VITE_APP_TITLE="Nexus COS"

# Set build environment variables
ENV VITE_API_NODE_URL=$VITE_API_NODE_URL
ENV VITE_API_PYTHON_URL=$VITE_API_PYTHON_URL
ENV VITE_APP_TITLE=$VITE_APP_TITLE

# Build the application
RUN npm run build

# Production stage with Nginx
FROM nginx:alpine AS production

# Install security updates and additional tools
RUN apk update && apk upgrade && apk add --no-cache \
    curl \
    openssl \
    && rm -rf /var/cache/apk/*

# Copy built application
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create directories for SSL and logs
RUN mkdir -p /etc/nginx/ssl /var/log/nginx

# Copy default site configuration (will be overridden by volume mount)
COPY default.conf /etc/nginx/conf.d/default.conf

# Create health check endpoint
RUN echo '<!DOCTYPE html><html><head><title>Health Check</title></head><body><h1>OK</h1><p>Nexus COS Frontend is running</p></body></html>' > /usr/share/nginx/html/health.html

# Expose ports
EXPOSE 80 443

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/health.html || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]