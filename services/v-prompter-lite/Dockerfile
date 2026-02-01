FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
# If package.json doesn't exist, init minimal one
RUN if [ ! -f package.json ]; then npm init -y; fi
RUN npm install express cors

# Copy source
COPY server.js .

# Environment
ENV PORT=3000
ENV NODE_ENV=production

EXPOSE 3000

CMD ["node", "server.js"]
