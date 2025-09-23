# Health endpoint for Python backend
# This file provides health check endpoints for FastAPI

from fastapi import APIRouter, HTTPException
from datetime import datetime
import psutil
import os
import sys

router = APIRouter()

@router.get("/health")
async def health_check():
    """Main health check endpoint"""
    try:
        # Get system information
        memory_info = psutil.virtual_memory()
        cpu_percent = psutil.cpu_percent(interval=1)
        
        health_data = {
            "status": "ok",
            "timestamp": datetime.utcnow().isoformat(),
            "service": "nexus-cos-python",
            "version": "1.0.0",
            "environment": os.getenv("ENVIRONMENT", "production"),
            "python_version": sys.version,
            "pid": os.getpid(),
            "system": {
                "cpu_percent": cpu_percent,
                "memory": {
                    "used_mb": round(memory_info.used / 1024 / 1024, 2),
                    "available_mb": round(memory_info.available / 1024 / 1024, 2),
                    "percent": memory_info.percent
                },
                "disk_usage": {
                    "percent": psutil.disk_usage('/').percent
                }
            }
        }
        
        return health_data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Health check failed: {str(e)}")

@router.get("/ready")
async def readiness_check():
    """Readiness check endpoint"""
    try:
        # Add any readiness checks here (database connections, etc.)
        readiness_data = {
            "status": "ready",
            "timestamp": datetime.utcnow().isoformat(),
            "service": "nexus-cos-python",
            "checks": {
                "database": "ok",  # Add actual database check
                "external_services": "ok",  # Add external service checks
                "file_system": "ok"  # Add file system checks
            }
        }
        
        return readiness_data
        
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Service not ready: {str(e)}")

@router.get("/live")
async def liveness_check():
    """Liveness check endpoint"""
    return {
        "status": "alive",
        "timestamp": datetime.utcnow().isoformat(),
        "service": "nexus-cos-python",
        "uptime": psutil.boot_time()
    }

@router.get("/metrics")
async def metrics():
    """Basic metrics endpoint"""
    try:
        memory_info = psutil.virtual_memory()
        cpu_percent = psutil.cpu_percent(interval=1)
        disk_usage = psutil.disk_usage('/')
        
        metrics_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "service": "nexus-cos-python",
            "metrics": {
                "cpu_percent": cpu_percent,
                "memory_percent": memory_info.percent,
                "memory_used_bytes": memory_info.used,
                "memory_available_bytes": memory_info.available,
                "disk_percent": disk_usage.percent,
                "disk_used_bytes": disk_usage.used,
                "disk_free_bytes": disk_usage.free,
                "process_count": len(psutil.pids())
            }
        }
        
        return metrics_data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Metrics collection failed: {str(e)}")