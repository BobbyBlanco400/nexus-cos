FROM python:3.11-slim

# N3XUS LAW 55-45-17 Enforcement
ARG N3XUS_HANDSHAKE
ENV N3XUS_HANDSHAKE=${N3XUS_HANDSHAKE}

WORKDIR /app

# Build-time validation
RUN if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then \
    echo "❌ N3XUS HANDSHAKE VIOLATION" && exit 1; \
    fi

# Install dependencies
RUN pip install --no-cache-dir fastapi uvicorn pydantic

# Copy application
COPY main.py .

EXPOSE 3000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
