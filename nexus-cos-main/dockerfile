FROM node:20

WORKDIR /app

# Copy package.json and package-lock.json first for dependency caching
COPY package*.json ./
RUN npm ci --omit=dev

# Copy all source files (including tsconfig.json and src directory)
COPY . .

# Compile all TypeScript files to /dist
RUN npx tsc

# Run the compiled server
CMD ["node", "dist/server.js"]
