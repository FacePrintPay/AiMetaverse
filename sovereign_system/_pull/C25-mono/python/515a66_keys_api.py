from datetime import datetime
import secrets
import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="AGI KRE8TIVE Keys API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class KeyRotationRequest(BaseModel):
    service_name: str
    key_type: str = "api_key"

class KeyRotationResponse(BaseModel):
    service_name: str
    new_key: str
    rotated_at: str
    expires_in_days: int = 90

@app.get("/")
async def root():
    return {
        "service": "AGI KRE8TIVE Keys API",
        "version": "1.0.0",
        "status": "operational",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health")
async def health():
    return {
        "ok": True,
        "service": "keys_api",
        "timestamp": datetime.now().isoformat(),
        "pid": os.getpid()
    }

@app.get("/metrics")
async def metrics():
    return {
        "service": "Keys API",
        "timestamp": datetime.now().isoformat(),
        "pid": os.getpid(),
        "requests_allowed": 0,
        "requests_blocked": 0,
        "requests_per_second": 0.0,
        "uptime_seconds": 0
    }

@app.post("/rotate-key", response_model=KeyRotationResponse)
async def rotate_key(req: KeyRotationRequest):
    """Rotate API key for a service"""
    new_key = f"ak_{secrets.token_urlsafe(32)}"
    
    return KeyRotationResponse(
        service_name=req.service_name,
        new_key=new_key,
        rotated_at=datetime.now().isoformat(),
        expires_in_days=90
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8888)
