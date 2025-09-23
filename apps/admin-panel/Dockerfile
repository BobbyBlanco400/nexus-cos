# Admin Panel Frontend Application
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install dependencies for React build
RUN apk add --no-cache curl

# Copy package files
COPY package*.json ./
RUN npm install --production

# Copy source code
COPY . .

# Build the React application
RUN npm run build

# Build stage
FROM node:18-alpine as build

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install --production

# Copy source code
COPY . .

# Build the React application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built files from build stage
COPY --from=build /app/build /usr/share/nginx/html

# Copy nginx configuration
RUN echo 'server { \
    listen 3000; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    location /health.json { \
        default_type application/json; \
        return 200 "{\"status\":\"healthy\",\"service\":\"admin-panel\"}"; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health.json || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]