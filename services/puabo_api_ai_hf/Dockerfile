# Phase 5: puabo_api_ai_hf - Node.js + Express
# N3XUS Handshake 55-45-17 ENFORCED at ALL layers
# Rule: No Handshake → No Build → No Boot → No Service

FROM node:20-alpine

WORKDIR /app

# N3XUS Handshake enforcement at BUILD time
ARG X_N3XUS_HANDSHAKE
RUN if [ "$X_N3XUS_HANDSHAKE" != "55-45-17" ]; then \
        echo "❌ BUILD DENIED: Invalid or missing N3XUS Handshake"; \
        echo "❌ Required: --build-arg X_N3XUS_HANDSHAKE=55-45-17"; \
        exit 1; \
    fi && \
    echo "✅ Build-time handshake validated: $X_N3XUS_HANDSHAKE"

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application code
COPY index.js ./
COPY handshake.js ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

# Expose port
EXPOSE 3401

# Health check with handshake validation
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3401/health || exit 1

# Environment variables
ENV NODE_ENV=production \
    PORT=3401

# ENTRYPOINT with runtime handshake validation
# Validates X_N3XUS_HANDSHAKE environment variable before starting service
ENTRYPOINT ["/bin/sh", "-c", "\
    if [ \"$X_N3XUS_HANDSHAKE\" != \"55-45-17\" ]; then \
        echo '❌ RUNTIME DENIED: Invalid or missing X_N3XUS_HANDSHAKE'; \
        exit 1; \
    fi && \
    echo '✅ Runtime handshake validated' && \
    node index.js"]
