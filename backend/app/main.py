from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message": "PUABO Backend API Phase 3 is live"}

@app.get("/health")
def health():
    return {"status": "ok"}
