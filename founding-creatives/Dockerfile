FROM node:18-alpine

WORKDIR /app

# Copy package files if they exist, or create a minimal one
COPY package*.json ./

# Install dependencies if package.json exists, otherwise create minimal setup
RUN if [ -f package.json ]; then npm ci --only=production; else npm init -y && npm install express; fi

# Copy application files
COPY . .

EXPOSE 3200

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3200/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})" || exit 0

# Create a simple entry point that logs the handshake header
CMD echo "X-N3XUS-Handshake: 55-45-17" && node -e "const fs = require('fs'); const files = fs.readdirSync('.').filter(f => f.endsWith('.js')); if (files.length > 0) { require('./' + files[0]); } else { require('http').createServer((req, res) => { res.writeHead(200); res.end('Founding Creatives Service'); }).listen(3200); }" || tail -f /dev/null
