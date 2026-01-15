FROM node:20-alpine

# N3XUS LAW 55-45-17 Enforcement
ARG N3XUS_HANDSHAKE
ENV N3XUS_HANDSHAKE=${N3XUS_HANDSHAKE}

WORKDIR /app

# Build-time validation
RUN if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then \
    echo "❌ N3XUS HANDSHAKE VIOLATION" && exit 1; \
    fi

# Install dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy application
COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
