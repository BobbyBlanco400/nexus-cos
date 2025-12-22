FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Configure npm and install dependencies
RUN npm config set strict-ssl false
RUN npm install --production

# Copy application code
COPY . .

# Expose port 8088
EXPOSE 8088

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8088/health', (r) => { process.exit(r.statusCode === 200 ? 0 : 1); }).on('error', () => process.exit(1));"

# Start the service
CMD ["npm", "start"]
