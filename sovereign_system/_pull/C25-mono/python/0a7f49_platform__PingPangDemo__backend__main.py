from fastapi import FastAPI, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import asyncio

app = FastAPI(title="Planetary Agent API")

# Allow CORS from local frontend server
origins = [
    "http://localhost:5500",  # default live-server port for frontend
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_methods=["*"],
    allow_headers=["*"],
)

is_ready = False

@app.on_event("startup")
async def startup_event():
    global is_ready
    await asyncio.sleep(1)
    is_ready = True

@app.get("/healthz")
async def healthz():
    if is_ready:
        return {"status": "ok"}
    else:
        return JSONResponse(status_code=503, content={"status": "starting"})

async def background_task():
    await asyncio.sleep(5)  # Simulate some work

@app.post("/run-task")
async def run_task(background_tasks: BackgroundTasks):
    background_tasks.add_task(background_task)
    return {"message": "Task started"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
