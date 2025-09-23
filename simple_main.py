from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from datetime import datetime
import psutil
import os
import sys

app = FastAPI(title="NEXUS COS Python API", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "message": "NEXUS COS Python API",
        "version": "1.0.0",
        "status": "running",
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/health")
async def health_check():
    try:
        memory_info = psutil.virtual_memory()
        cpu_percent = psutil.cpu_percent(interval=1)
        
        return {
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
                }
            }
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=3001)