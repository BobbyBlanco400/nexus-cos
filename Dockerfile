FROM node:20

WORKDIR /app

# Install curl for healthchecks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy package.json and package-lock.json first for dependency caching
# NOTE: This COPY command requires package.json and package-lock.json to exist
# in the build context (repository root). If you see ENOENT errors, verify:
# 1. You are building from the repository root: docker build -t nexus-cos .
# 2. package.json exists in the repository root
# 3. .dockerignore is not excluding package.json
COPY package*.json ./

# Validate that package.json was copied successfully
RUN test -f package.json || (echo "ERROR: package.json not found in /app. Check your build context." && exit 1)

# Configure npm and install dependencies
RUN npm config set strict-ssl false
ENV PUPPETEER_SKIP_DOWNLOAD=true
RUN npm ci --omit=dev || (echo "ERROR: npm ci failed. Check package.json and package-lock.json" && exit 1)

# Copy all source files
COPY . .

# Validate that server.js exists
RUN test -f server.js || (echo "ERROR: server.js not found. Check your build context and COPY command." && exit 1)

# Expose port for documentation (actual port binding is in docker-compose.yml)
EXPOSE 3000

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Run the server directly (JavaScript)
CMD ["node", "server.js"]
