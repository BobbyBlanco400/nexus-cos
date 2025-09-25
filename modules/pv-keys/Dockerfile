FROM node:20-alpine

# Create app directory
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nexus -u 1001

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

RUN ls -R /app

RUN chown -R nexus:nodejs /app

# Create logs directory
RUN mkdir -p logs && chown -R nexus:nodejs logs

# Switch to non-root user
USER nexus

# Expose port
EXPOSE 3041

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3041/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Start the application
CMD ["npm", "start"]