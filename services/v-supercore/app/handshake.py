"""
N3XUS Handshake 55-45-17 Enforcement Module
Strict validation with zero bypass tolerance
"""
import os
import sys
from typing import Optional
from fastapi import Request, HTTPException, status
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse


# N3XUS Handshake constant
REQUIRED_HANDSHAKE = "55-45-17"
HANDSHAKE_HEADER = "X-N3XUS-Handshake"
HANDSHAKE_ENV = "X_N3XUS_HANDSHAKE"


class HandshakeError(Exception):
    """N3XUS Handshake violation exception"""
    pass


def validate_handshake_env() -> None:
    """
    Validate N3XUS Handshake from environment at startup.
    Exits immediately if invalid or missing.
    NO BYPASS. NO WARNINGS. NO SOFT FAILURE.
    """
    handshake = os.environ.get(HANDSHAKE_ENV, "").strip()
    
    if not handshake:
        print(f"❌ N3XUS LAW VIOLATION: Missing {HANDSHAKE_ENV} environment variable", file=sys.stderr)
        print(f"❌ BOOT DENIED: No N3XUS Handshake → No Boot", file=sys.stderr)
        sys.exit(1)
    
    if handshake != REQUIRED_HANDSHAKE:
        print(f"❌ N3XUS LAW VIOLATION: Invalid handshake '{handshake}'", file=sys.stderr)
        print(f"❌ BOOT DENIED: Expected '{REQUIRED_HANDSHAKE}'", file=sys.stderr)
        sys.exit(1)
    
    print(f"✅ N3XUS Handshake validated: {REQUIRED_HANDSHAKE}")


def validate_handshake_header(request: Request) -> Optional[str]:
    """
    Validate N3XUS Handshake from request header.
    Returns error message if invalid, None if valid.
    """
    handshake = request.headers.get(HANDSHAKE_HEADER, "").strip()
    
    if not handshake:
        return f"Missing required header: {HANDSHAKE_HEADER}"
    
    if handshake != REQUIRED_HANDSHAKE:
        return f"Invalid handshake: expected '{REQUIRED_HANDSHAKE}', got '{handshake}'"
    
    return None


class HandshakeMiddleware(BaseHTTPMiddleware):
    """
    FastAPI middleware for N3XUS Handshake enforcement.
    Validates handshake on EVERY request except health endpoints.
    """
    
    # Paths that bypass handshake check (health monitoring only)
    EXEMPT_PATHS = {"/health", "/metrics"}
    
    async def dispatch(self, request: Request, call_next):
        # Skip handshake for exempt paths
        if request.url.path in self.EXEMPT_PATHS:
            return await call_next(request)
        
        # Validate handshake
        error = validate_handshake_header(request)
        if error:
            return JSONResponse(
                status_code=status.HTTP_403_FORBIDDEN,
                content={
                    "success": False,
                    "error": "N3XUS LAW VIOLATION",
                    "message": error,
                    "required": f"{HANDSHAKE_HEADER}: {REQUIRED_HANDSHAKE}"
                }
            )
        
        # Handshake valid, proceed
        return await call_next(request)
