FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application files
COPY contracts ./contracts
COPY engine ./engine

# Start the executor
CMD ["npm", "start"]
