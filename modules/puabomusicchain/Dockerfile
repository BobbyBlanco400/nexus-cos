FROM node:20-alpine

# Install FFmpeg for video processing
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

# Create logs directory
RUN mkdir -p logs && chown -R nexus:nodejs logs

# Change ownership
RUN chown -R nexus:nodejs /usr/src/app

# Switch to non-root user
USER nexus

# Expose port
EXPOSE 3042

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3042/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Start the application
CMD ["node", "server.js"]