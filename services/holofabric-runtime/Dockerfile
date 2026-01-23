FROM node:20-alpine

WORKDIR /app

ARG X_N3XUS_HANDSHAKE
ARG N3XUS_HANDSHAKE

RUN EFFECTIVE_HANDSHAKE="${X_N3XUS_HANDSHAKE:-$N3XUS_HANDSHAKE}" && \
    if [ "$EFFECTIVE_HANDSHAKE" != "55-45-17" ]; then \
        echo "❌ BUILD DENIED: Invalid or missing N3XUS Handshake"; \
        echo "❌ Required: --build-arg X_N3XUS_HANDSHAKE=55-45-17 or N3XUS_HANDSHAKE=55-45-17"; \
        exit 1; \
    fi && \
    echo "✅ Build-time handshake validated for HOLOFABRIC Runtime: $EFFECTIVE_HANDSHAKE"

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3700

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3700/health || exit 1

ENV NODE_ENV=production \
    PORT=3700

ENTRYPOINT ["/bin/sh", "-c", "\
    EFFECTIVE_HANDSHAKE=\"${X_N3XUS_HANDSHAKE:-$N3XUS_HANDSHAKE}\"; \
    if [ \"$EFFECTIVE_HANDSHAKE\" != \"55-45-17\" ]; then \
        echo '❌ RUNTIME DENIED: Invalid or missing handshake for HOLOFABRIC Runtime'; \
        exit 1; \
    fi && \
    echo \"✅ Runtime handshake validated for HOLOFABRIC Runtime: $EFFECTIVE_HANDSHAKE\" && \
    npm start"]

