#!/data/data/com.termux/files/usr/bin/env python3
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import uvicorn, json, os, glob, time, subprocess
from typing import Optional, List, Dict

app = FastAPI(title="SovereignGTP Command Center", version="1.0")

HOME = os.path.expanduser("~")
TASKS_ROOT = f"{HOME}/tasks"
INCOMING = f"{TASKS_ROOT}/incoming"
PROCESSING = f"{TASKS_ROOT}/processing"
COMPLETED = f"{TASKS_ROOT}/completed"
FAILED = f"{TASKS_ROOT}/failed"
OUTPUTS = f"{HOME}/outputs"

os.makedirs(INCOMING, exist_ok=True)
os.makedirs(OUTPUTS, exist_ok=True)

class TaskRequest(BaseModel):
    agent: str
    message: str
    project_id: Optional[str] = None
    priority: Optional[int] = 0

class TaskResponse(BaseModel):
    task_id: str
    status: str
    message: str
    project_id: Optional[str] = None

def send_task(agent: str, message: str) -> str:
    task_id = f"{int(time.time()*1e9)}"
    task_file = f"{INCOMING}/task_{task_id}.json"
    data = {
        "task_id": task_id,
        "agent": agent,
        "message": message,
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "status": "pending"
    }
    with open(task_file, "w") as f:
        json.dump(data, f, indent=2)
    return task_id

@app.post("/tasks", response_model=TaskResponse)
async def create_task(req: TaskRequest):
    task_id = send_task(req.agent, req.message)
    return TaskResponse(
        task_id=task_id,
        status="queued",
        message=f"Task sent to {req.agent}",
        project_id=req.project_id
    )

@app.get("/tasks/{task_id}")
async def get_task(task_id: str):
    for folder in [PROCESSING, COMPLETED, FAILED]:
        path = f"{folder}/task_{task_id}.json"
        if os.path.exists(path):
            with open(path) as f:
                data = json.load(f)
            status = "processing" if folder == PROCESSING else \
                     "completed" if folder == COMPLETED else "failed"
            
            # Look for outputs
            outputs = glob.glob(f"{OUTPUTS}/*/{task_id}*") + \
                      glob.glob(f"{OUTPUTS}/{task_id}*")
            output_links = [p.replace(HOME, "~") for p in outputs]
            
            return {
                "task_id": task_id,
                "status": status,
                "agent": data.get("agent"),
                "message": data.get("message"),
                "output_files": output_links,
                "finished": status in ["completed", "failed"]
            }
    return {"task_id": task_id, "status": "pending", "output_files": []}

@app.get("/health")
async def health():
    return {"status": "SovereignGTP Command Center LIVE", "time": time.time()}

@app.get("/")
async def root():
    return {"message": "Welcome to SovereignGTP Command Center — your swarm is waiting."}

if __name__ == "__main__":
    print("Sovereign Command Center starting on http://0.0.0.0:8765")
    print("Use in any LLM tool calling interface right now.")
    uvicorn.run(app, host="0.0.0.0", port=8765)
