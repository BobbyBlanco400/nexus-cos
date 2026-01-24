# Phase 5: v-SuperCore - FastAPI + Uvicorn
# N3XUS Handshake 55-45-17 ENFORCED at ALL layers
# Rule: No Handshake → No Build → No Boot → No Service

FROM python:3.11-slim

WORKDIR /app

# N3XUS Handshake enforcement at BUILD time
ARG X_N3XUS_HANDSHAKE
RUN if [ "$X_N3XUS_HANDSHAKE" != "55-45-17" ]; then \
        echo "❌ BUILD DENIED: Invalid or missing N3XUS Handshake"; \
        echo "❌ Required: --build-arg X_N3XUS_HANDSHAKE=55-45-17"; \
        exit 1; \
    fi && \
    echo "✅ Build-time handshake validated: $X_N3XUS_HANDSHAKE"

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app ./app

# Create non-root user
RUN useradd -m -u 1001 -s /bin/bash nexus && \
    chown -R nexus:nexus /app

USER nexus

# Expose ports
EXPOSE 8080

# Health check with handshake validation
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Environment variables
ENV PYTHONUNBUFFERED=1 \
    PORT=8080

# ENTRYPOINT with runtime handshake validation
# Validates X_N3XUS_HANDSHAKE environment variable before starting service
ENTRYPOINT ["/bin/bash", "-c", "\
    if [ \"$X_N3XUS_HANDSHAKE\" != \"55-45-17\" ]; then \
        echo '❌ RUNTIME DENIED: Invalid or missing X_N3XUS_HANDSHAKE'; \
        exit 1; \
    fi && \
    echo '✅ Runtime handshake validated' && \
    python -m uvicorn app.main:app --host 0.0.0.0 --port 8080"]
