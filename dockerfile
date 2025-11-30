FROM node:20

WORKDIR /app

# Copy package.json and package-lock.json first for dependency caching
COPY package*.json ./
# Skip puppeteer download in Docker
ENV PUPPETEER_SKIP_DOWNLOAD=true
# Install all dependencies including devDependencies for build
RUN npm ci

# Copy all source files (including tsconfig.json and src directory)
COPY . .

# Compile all TypeScript files to /dist
RUN npx tsc

# Remove devDependencies to reduce image size
RUN npm prune --production

# Run the compiled server
CMD ["node", "dist/server.js"]
