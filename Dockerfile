FROM node:20

WORKDIR /app

# Install curl for healthchecks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy package.json and package-lock.json first for dependency caching
COPY package*.json ./
RUN npm config set strict-ssl false
ENV PUPPETEER_SKIP_DOWNLOAD=true
RUN npm ci --omit=dev

# Copy all source files
COPY . .

# Run the server directly (JavaScript)
CMD ["node", "server.js"]
