from fastapi import FastAPI, Request, HTTPException

app = FastAPI(title="Earnings Oracle")

@app.middleware("http")
async def nexus_handshake(request: Request, call_next):
    if request.url.path == "/health":
        return await call_next(request)
    if request.headers.get("X-N3XUS-Handshake") != "55-45-17":
        raise HTTPException(status_code=451, detail="N3XUS LAW VIOLATION")
    return await call_next(request)

@app.get("/health")
async def health():
    return {"status": "ok", "service": "Earnings Oracle"}

@app.get("/")
async def root():
    return {"service": "Earnings Oracle", "phase": "9"}
