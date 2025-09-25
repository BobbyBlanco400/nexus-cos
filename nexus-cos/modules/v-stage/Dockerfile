# V-Stage - Virtual Studio Set Integration
FROM node:18-alpine

WORKDIR /app

# Install 3D rendering and video processing dependencies
RUN apk add --no-cache ffmpeg mesa-gl mesa-dri-gallium

# Copy package files
COPY package*.json ./
RUN npm install --production

# Copy source code
COPY . .

# Expose port
EXPOSE 3046

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3046/health || exit 1

# Environment variables
ENV VIRTUAL_SETS_ENABLED=true
ENV LIVE_STREAMING_INTEGRATION=true
ENV RENDER_QUALITY=high

# Start the service
CMD ["npm", "start"]