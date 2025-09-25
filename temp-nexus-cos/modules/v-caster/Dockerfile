# V-Caster - Live Streaming & Broadcasting Platform
FROM node:18-alpine

WORKDIR /app

# Install FFmpeg for video processing
RUN apk add --no-cache ffmpeg

# Copy package files
COPY package*.json ./
RUN npm install --production

# Copy source code
COPY . .

# Expose ports
EXPOSE 3011
EXPOSE 1935

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3011/health || exit 1

# Start the service
CMD ["npm", "start"]