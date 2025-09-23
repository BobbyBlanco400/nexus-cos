FROM node:20-alpine

# Install FFmpeg for streaming
RUN apk add --no-cache ffmpeg

# Create app directory
WORKDIR /usr/src/app

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nexus -u 1001

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Create necessary directories
RUN mkdir -p logs media hls && chown -R nexus:nodejs logs media hls

# Change ownership
RUN chown -R nexus:nodejs /usr/src/app

# Switch to non-root user
USER nexus

# Expose ports
EXPOSE 3043 1935 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3043/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Start the application
CMD ["node", "server.js"]