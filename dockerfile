FROM node:20

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies
RUN npm install --production --no-package-lock || npm install --production

# Copy application source
COPY . .

# The server.js is already JavaScript - no compilation needed
# Removed: RUN npx tsc

# Run the server directly
CMD ["node", "server.js"]
