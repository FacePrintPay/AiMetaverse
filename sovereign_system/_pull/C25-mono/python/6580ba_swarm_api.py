from datetime import datetime
import json
import os
from pathlib import Path
from typing import List
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

TASKS_ROOT = Path.home() / "tasks"
LOGS_ROOT = Path.home() / "logs"

app = FastAPI(title="AGI KRE8TIVE Swarm API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TaskRequest(BaseModel):
    agent: str
    task_type: str
    description: str
    priority: str = "normal"

class TaskResponse(BaseModel):
    task_id: str
    agent: str
    status: str
    created_at: str

class SwarmStatus(BaseModel):
    orchestrator_running: bool
    agents_available: List[str]
    tasks_pending: int
    tasks_processing: int
    tasks_completed: int
    tasks_failed: int
    timestamp: str

@app.get("/")
async def root():
    return {
        "service": "AGI KRE8TIVE Swarm API",
        "version": "1.0.0",
        "status": "operational",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health")
async def health():
    return {
        "ok": True,
        "service": "swarm_api",
        "timestamp": datetime.now().isoformat(),
        "pid": os.getpid()
    }

@app.get("/swarm/status", response_model=SwarmStatus)
async def swarm_status():
    """Get current swarm orchestrator status"""
    
    daemon_pid = LOGS_ROOT / "orchestrator" / "daemon.pid"
    orchestrator_running = False
    
    if daemon_pid.exists():
        try:
            pid = int(daemon_pid.read_text().strip())
            os.kill(pid, 0)
            orchestrator_running = True
        except (ProcessLookupError, ValueError):
            pass
    
    incoming = len(list((TASKS_ROOT / "incoming").glob("*.json"))) if (TASKS_ROOT / "incoming").exists() else 0
    processing = len(list((TASKS_ROOT / "processing").glob("*.json"))) if (TASKS_ROOT / "processing").exists() else 0
    completed = len(list((TASKS_ROOT / "completed").glob("*.json"))) if (TASKS_ROOT / "completed").exists() else 0
    failed = len(list((TASKS_ROOT / "failed").glob("*.json"))) if (TASKS_ROOT / "failed").exists() else 0
    
    return SwarmStatus(
        orchestrator_running=orchestrator_running,
        agents_available=["valuation", "market", "finance", "pr", "outreach", "income"],
        tasks_pending=incoming,
        tasks_processing=processing,
        tasks_completed=completed,
        tasks_failed=failed,
        timestamp=datetime.now().isoformat()
    )

@app.post("/swarm/task", response_model=TaskResponse)
async def create_task(req: TaskRequest):
    """Create a new task for an agent"""
    
    ts = int(datetime.now().timestamp())
    task_id = f"{req.agent}_{ts}"
    
    task_data = {
        "agent": req.agent,
        "type": req.task_type,
        "description": req.description,
        "priority": req.priority,
        "created_at": datetime.now().isoformat(),
        "status": "queued"
    }
    
    incoming_dir = TASKS_ROOT / "incoming"
    incoming_dir.mkdir(parents=True, exist_ok=True)
    
    task_file = incoming_dir / f"{task_id}.json"
    task_file.write_text(json.dumps(task_data, indent=2))
    
    return TaskResponse(
        task_id=task_id,
        agent=req.agent,
        status="queued",
        created_at=task_data["created_at"]
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8889)
