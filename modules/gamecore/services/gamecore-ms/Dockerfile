FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production || npm install --only=production

COPY . .

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:${PORT}/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

CMD ["node", "index.js"]
