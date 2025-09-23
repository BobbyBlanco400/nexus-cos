# NEXUS COS Python Backend Server
# FastAPI main application entry point

from fastapi import FastAPI, HTTPException, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse
from fastapi.security import HTTPBearer
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from datetime import datetime
import uvicorn
import os
import sys
import psutil
import logging
from health import router as health_router

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="NEXUS COS Python API",
    description="PUABO OS 2025 Python Backend API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Rate limiting
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://nexuscos.online", "http://localhost:3000", "http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Compression middleware
app.add_middleware(GZipMiddleware, minimum_size=1000)

# Security
security = HTTPBearer(auto_error=False)

# Request logging middleware
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = datetime.utcnow()
    
    # Log request
    logger.info(f"{request.method} {request.url.path} - IP: {request.client.host}")
    
    response = await call_next(request)
    
    # Log response time
    process_time = (datetime.utcnow() - start_time).total_seconds()
    logger.info(f"Response time: {process_time:.3f}s - Status: {response.status_code}")
    
    return response

# Include health router
app.include_router(health_router, tags=["Health"])

# Root endpoint
@app.get("/")
async def root():
    return {
        "message": "NEXUS COS Python API",
        "version": "1.0.0",
        "status": "running",
        "timestamp": datetime.utcnow().isoformat(),
        "docs": "/docs",
        "health": "/health"
    }

# API status endpoint
@app.get("/api/status")
@limiter.limit("30/minute")
async def api_status(request: Request):
    return {
        "status": "ok",
        "service": "nexus-cos-python-api",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "1.0.0",
        "environment": os.getenv("ENVIRONMENT", "production"),
        "python_version": sys.version
    }

# System information endpoint
@app.get("/api/system")
@limiter.limit("10/minute")
async def system_info(request: Request):
    try:
        memory_info = psutil.virtual_memory()
        cpu_percent = psutil.cpu_percent(interval=1)
        disk_usage = psutil.disk_usage('/')
        
        return {
            "system": {
                "platform": sys.platform,
                "python_version": sys.version,
                "cpu_percent": cpu_percent,
                "memory": {
                    "total_gb": round(memory_info.total / 1024 / 1024 / 1024, 2),
                    "used_gb": round(memory_info.used / 1024 / 1024 / 1024, 2),
                    "available_gb": round(memory_info.available / 1024 / 1024 / 1024, 2),
                    "percent": memory_info.percent
                },
                "disk": {
                    "total_gb": round(disk_usage.total / 1024 / 1024 / 1024, 2),
                    "used_gb": round(disk_usage.used / 1024 / 1024 / 1024, 2),
                    "free_gb": round(disk_usage.free / 1024 / 1024 / 1024, 2),
                    "percent": disk_usage.percent
                },
                "process_count": len(psutil.pids())
            },
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"System info error: {str(e)}")

# Data processing endpoint (placeholder)
@app.post("/api/process")
@limiter.limit("20/minute")
async def process_data(request: Request, data: dict):
    return {
        "message": "Data processing endpoint - implementation pending",
        "received_data": data,
        "timestamp": datetime.utcnow().isoformat()
    }

# AI/ML endpoint (placeholder)
@app.post("/api/ai/predict")
@limiter.limit("10/minute")
async def ai_predict(request: Request, input_data: dict):
    return {
        "message": "AI prediction endpoint - implementation pending",
        "input": input_data,
        "prediction": "placeholder_result",
        "confidence": 0.95,
        "timestamp": datetime.utcnow().isoformat()
    }

# Analytics endpoint (placeholder)
@app.get("/api/analytics")
@limiter.limit("15/minute")
async def analytics(request: Request):
    return {
        "analytics": {
            "total_requests": 0,
            "active_users": 0,
            "system_load": psutil.cpu_percent(interval=1),
            "memory_usage": psutil.virtual_memory().percent
        },
        "timestamp": datetime.utcnow().isoformat()
    }

# File processing endpoint (placeholder)
@app.post("/api/files/upload")
@limiter.limit("5/minute")
async def upload_file(request: Request):
    return {
        "message": "File upload endpoint - implementation pending",
        "timestamp": datetime.utcnow().isoformat()
    }

# Database operations endpoint (placeholder)
@app.get("/api/database/status")
@limiter.limit("20/minute")
async def database_status(request: Request):
    return {
        "database": {
            "status": "connected",
            "type": "placeholder",
            "connections": 0,
            "last_backup": datetime.utcnow().isoformat()
        },
        "timestamp": datetime.utcnow().isoformat()
    }

# Error handlers
@app.exception_handler(404)
async def not_found_handler(request: Request, exc: HTTPException):
    return JSONResponse(
        status_code=404,
        content={
            "error": "Endpoint not found",
            "path": str(request.url.path),
            "method": request.method,
            "timestamp": datetime.utcnow().isoformat()
        }
    )

@app.exception_handler(500)
async def internal_error_handler(request: Request, exc: HTTPException):
    logger.error(f"Internal server error: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal server error",
            "timestamp": datetime.utcnow().isoformat()
        }
    )

# Startup event
@app.on_event("startup")
async def startup_event():
    logger.info("🚀 NEXUS COS Python Backend started")
    logger.info(f"🐍 Python version: {sys.version}")
    logger.info(f"🌍 Environment: {os.getenv('ENVIRONMENT', 'production')}")
    logger.info(f"⏰ Started at: {datetime.utcnow().isoformat()}")

# Shutdown event
@app.on_event("shutdown")
async def shutdown_event():
    logger.info("🛑 NEXUS COS Python Backend shutting down")

if __name__ == "__main__":
    port = int(os.getenv("PORT", 3001))
    host = os.getenv("HOST", "0.0.0.0")
    
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=False,
        workers=1,
        log_level="info"
    )