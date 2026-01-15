"""
v-SuperCore - Sovereign Runtime Brain / Governance Authority
Phase 5: FastAPI + Uvicorn with N3XUS Handshake 55-45-17

Role: Root authority for N3XUS COS
Stack: FastAPI + Uvicorn
Enforcement: Hard handshake at build, runtime, and request levels
"""
import os
import sys
from datetime import datetime, timezone
from typing import Dict, Any

from fastapi import FastAPI, Request, Response, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

from .handshake import (
    validate_handshake_env,
    validate_handshake_header,
    HandshakeMiddleware,
    REQUIRED_HANDSHAKE,
    HANDSHAKE_HEADER
)


# Service metadata
SERVICE_NAME = "v-supercore"
SERVICE_VERSION = "1.0.0-phase5"
SERVICE_ROLE = "Sovereign Runtime Brain / Governance Authority"

# Startup timestamp
START_TIME = datetime.now(timezone.utc)


# Validate handshake BEFORE creating app
# FAIL-FAST: No handshake → No boot
print("=" * 60)
print("v-SuperCore Phase 5: Runtime Activation")
print("=" * 60)
validate_handshake_env()
print("=" * 60)


# Create FastAPI application
app = FastAPI(
    title=SERVICE_NAME,
    version=SERVICE_VERSION,
    description=SERVICE_ROLE,
    docs_url="/api/docs",
    redoc_url="/api/redoc"
)


# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# N3XUS Handshake enforcement middleware
app.add_middleware(HandshakeMiddleware)


@app.get("/health")
async def health_check() -> Dict[str, Any]:
    """
    Health check endpoint (exempt from handshake).
    Used by Docker health checks and monitoring.
    """
    uptime = (datetime.now(timezone.utc) - START_TIME).total_seconds()
    
    return {
        "status": "ok",
        "service": SERVICE_NAME,
        "version": SERVICE_VERSION,
        "role": SERVICE_ROLE,
        "handshake_protocol": REQUIRED_HANDSHAKE,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "uptime_seconds": uptime,
        "phase": "5"
    }


@app.get("/law")
async def nexus_law(request: Request) -> Dict[str, Any]:
    """
    N3XUS Law endpoint - returns governance rules.
    REQUIRES HANDSHAKE.
    """
    return {
        "law": "N3XUS Law 55-45-17",
        "principle": "No N3XUS Handshake → No Build → No Boot → No Service",
        "enforcement": "STRICT",
        "bypass_allowed": False,
        "failure_behavior": "FAIL-FAST",
        "silent_failures": "PROHIBITED",
        "handshake_valid": True,
        "timestamp": datetime.now(timezone.utc).isoformat()
    }


@app.get("/handshake")
async def handshake_info(request: Request) -> Dict[str, Any]:
    """
    Handshake information endpoint.
    REQUIRES HANDSHAKE (validates you have it by the fact you can access this).
    """
    provided_handshake = request.headers.get(HANDSHAKE_HEADER, "")
    
    return {
        "handshake_protocol": REQUIRED_HANDSHAKE,
        "handshake_provided": provided_handshake,
        "handshake_valid": True,  # If you got here, it's valid
        "header_name": HANDSHAKE_HEADER,
        "enforcement_level": "STRICT",
        "checked_at": [
            "Docker build (ARG validation)",
            "Container runtime (ENTRYPOINT guard)",
            "API middleware (every request)",
            "Health checks (exempt)",
            "Reverse proxy (headers)"
        ],
        "timestamp": datetime.now(timezone.utc).isoformat()
    }


@app.get("/")
async def root() -> Dict[str, Any]:
    """
    Root endpoint - service information.
    REQUIRES HANDSHAKE.
    """
    return {
        "service": SERVICE_NAME,
        "version": SERVICE_VERSION,
        "role": SERVICE_ROLE,
        "status": "operational",
        "phase": "5",
        "handshake_required": True,
        "endpoints": {
            "health": "/health (no handshake required)",
            "law": "/law (handshake required)",
            "handshake": "/handshake (handshake required)",
            "docs": "/api/docs"
        },
        "timestamp": datetime.now(timezone.utc).isoformat()
    }


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """
    Global exception handler - fail visible, not silent.
    """
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "error": "Internal server error",
            "message": str(exc),
            "service": SERVICE_NAME,
            "timestamp": datetime.now(timezone.utc).isoformat()
        }
    )


def main():
    """
    Main entry point for v-SuperCore service.
    """
    port = int(os.environ.get("PORT", 8080))
    host = os.environ.get("HOST", "0.0.0.0")
    
    print(f"🚀 Starting {SERVICE_NAME} v{SERVICE_VERSION}")
    print(f"📍 Host: {host}:{port}")
    print(f"🔐 Handshake: {REQUIRED_HANDSHAKE}")
    print(f"⚖️  Role: {SERVICE_ROLE}")
    print(f"🎯 Phase: 5 - Runtime Core Activation")
    
    uvicorn.run(
        "app.main:app",
        host=host,
        port=port,
        log_level="info",
        access_log=True,
        # Fail-fast on errors
        reload=False
    )


if __name__ == "__main__":
    main()
