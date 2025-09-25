# V-Screen - Virtual Teleprompter with V-Prompter Pro & Hollywood Edition
FROM node:18-alpine

WORKDIR /app

# Install dependencies for teleprompter and video processing
RUN apk add --no-cache ffmpeg python3 py3-pip

# Copy package files
COPY package*.json ./
RUN npm install --production

# Copy source code
COPY . .

# Expose port
EXPOSE 3012

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3012/health || exit 1

# Environment variables for features
ENV PROMPTER_PRO_ENABLED=true
ENV HOLLYWOOD_EDITION=true
ENV AI_SYNC_ENABLED=true
ENV STUDIO_INTEGRATION=true

# Start the service
CMD ["npm", "start"]