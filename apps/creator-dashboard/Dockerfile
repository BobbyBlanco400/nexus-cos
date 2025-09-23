# Creator Dashboard Frontend Application
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install dependencies for React build
RUN apk add --no-cache curl

# Build stage
FROM node:18-alpine as build

WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
RUN echo 'server { listen 3000; location / { root /usr/share/nginx/html; try_files $uri $uri/ /index.html; } location /health.json { default_type application/json; return 200 "{\"status\":\"healthy\",\"service\":\"creator-dashboard\"}"; } }' > /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]