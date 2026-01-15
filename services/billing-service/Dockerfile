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

# Create minimal service structure
RUN mkdir -p app
COPY . ./app/ 2>/dev/null || true

# Create minimal main.py if none exists
RUN if [ ! -f app/main.py ]; then \
    echo 'from fastapi import FastAPI, Request, HTTPException\nfrom fastapi.responses import JSONResponse\n\napp = FastAPI()\n\n@app.middleware("http")\nasync def nexus_handshake(request: Request, call_next):\n    if request.url.path == "/health":\n        return await call_next(request)\n    if request.headers.get("X-N3XUS-Handshake") != "55-45-17":\n        raise HTTPException(status_code=451, detail="N3XUS LAW VIOLATION")\n    return await call_next(request)\n\n@app.get("/health")\nasync def health():\n    return {"status": "ok", "service": "billing-service"}\n\n@app.get("/")\nasync def root():\n    return {"service": "billing-service", "phase": "extended"}' > app/main.py; \
    fi

EXPOSE 3000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "3000"]
