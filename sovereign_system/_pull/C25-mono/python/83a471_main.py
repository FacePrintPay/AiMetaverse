"""
VideoCourts Backend API
Optimized for Manus Computer cloud development environment
"""
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional
import os, json, sqlite3, time
from datetime import datetime
from pathlib import Path

# Configuration
MANUS_URL = os.getenv("CLOUD_IDE_URL", "")
DATABASE_PATH = Path("database.sqlite3")
OUTPUTS_DIR = Path("outputs")
TASKS_DIR = Path("tasks/incoming")

# Ensure directories exist
for d in [DATABASE_PATH.parent, OUTPUTS_DIR, TASKS_DIR]:
    d.mkdir(parents=True, exist_ok=True)

# Initialize FastAPI
app = FastAPI(
    title="VideoCourts API (Manus Edition)",
    description="Complete virtual court platform with cloud IDE integration",
    version="1.0.0-manus"
)

# CORS - Allow Manus Computer environment
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:8000",
        MANUS_URL,
        "*"  # Allow all for development
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize SQLite
def init_db():
    conn = sqlite3.connect(str(DATABASE_PATH))
    c = conn.cursor()
    
    c.execute("""
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            agent TEXT NOT NULL,
            type TEXT NOT NULL,
            payload TEXT NOT NULL,
            status TEXT DEFAULT 'pending',
            created_at TEXT NOT NULL,
            completed_at TEXT,
            manus_session TEXT
        )
    """)
    
    c.execute("""
        CREATE TABLE IF NOT EXISTS sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            case_id TEXT NOT NULL,
            judge_id TEXT,
            status TEXT DEFAULT 'scheduled',
            video_room_url TEXT,
            manus_instance TEXT,
            created_at TEXT NOT NULL
        )
    """)
    
    c.execute("""
        CREATE TABLE IF NOT EXISTS evidence (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            case_id TEXT NOT NULL,
            filename TEXT NOT NULL,
            hash TEXT NOT NULL,
            uploaded_at TEXT NOT NULL,
            manus_path TEXT
        )
    """)
    
    conn.commit()
    conn.close()

init_db()

# Models
class TaskCreate(BaseModel):
    agent: str = "helio"
    type: str = "A_landing_page"
    payload: str

class SessionCreate(BaseModel):
    case_id: str
    judge_id: Optional[str] = None

class EvidenceUpload(BaseModel):
    case_id: str
    filename: str
    content: str  # Base64 encoded

# WebSocket connections manager
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []
    
    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
    
    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)
    
    async def broadcast(self, message: dict):
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except:
                pass

manager = ConnectionManager()

# Routes
@app.get("/")
def root():
    return {
        "service": "VideoCourts API",
        "version": "1.0.0-manus",
        "environment": "Manus Computer Cloud IDE",
        "manus_url": MANUS_URL,
        "status": "operational",
        "endpoints": {
            "api_docs": "/docs",
            "health": "/api/health",
            "tasks": "/api/tasks",
            "sessions": "/api/sessions",
            "evidence": "/api/evidence"
        }
    }

@app.get("/api/health")
def health():
    return {
        "status": "healthy",
        "database": "connected" if DATABASE_PATH.exists() else "disconnected",
        "manus_integration": "active",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/api/manus/info")
def manus_info():
    """Information about Manus Computer integration"""
    return {
        "cloud_ide_url": MANUS_URL,
        "features": [
            "Real-time code collaboration",
            "Integrated terminal access",
            "Git integration",
            "Live preview",
            "Multi-user support"
        ],
        "status": "connected"
    }

@app.post("/api/tasks")
def create_task(task: TaskCreate):
    conn = sqlite3.connect(str(DATABASE_PATH))
    c = conn.cursor()
    
    # Save to database
    c.execute(
        "INSERT INTO tasks (agent, type, payload, status, created_at, manus_session) VALUES (?, ?, ?, ?, ?, ?)",
        (task.agent, task.type, task.payload, "pending", datetime.now().isoformat(), MANUS_URL)
    )
    task_id = c.lastrowid
    conn.commit()
    conn.close()
    
    # Create task file
    task_file = TASKS_DIR / f"{task.agent}_{int(time.time())}.json"
    with open(task_file, "w") as f:
        json.dump({
            "id": task_id,
            "agent": task.agent,
            "type": task.type,
            "payload": task.payload,
            "timestamp": datetime.now().isoformat(),
            "manus_session": MANUS_URL
        }, f, indent=2)
    
    return {
        "id": task_id,
        "status": "queued",
        "agent": task.agent,
        "task_file": str(task_file)
    }

@app.get("/api/tasks")
def list_tasks(limit: int = 50):
    conn = sqlite3.connect(str(DATABASE_PATH))
    c = conn.cursor()
    c.execute("SELECT * FROM tasks ORDER BY id DESC LIMIT ?", (limit,))
    
    tasks = []
    for row in c.fetchall():
        tasks.append({
            "id": row[0],
            "agent": row[1],
            "type": row[2],
            "payload": row[3],
            "status": row[4],
            "created_at": row[5],
            "completed_at": row[6],
            "manus_session": row[7]
        })
    
    conn.close()
    return {"tasks": tasks, "total": len(tasks)}

@app.post("/api/sessions")
def create_session(session: SessionCreate):
    conn = sqlite3.connect(str(DATABASE_PATH))
    c = conn.cursor()
    
    # Generate video room URL (integrate with actual video service)
    video_room_url = f"https://videocourts.com/room/{session.case_id}"
    
    c.execute(
        "INSERT INTO sessions (case_id, judge_id, status, video_room_url, manus_instance, created_at) VALUES (?, ?, ?, ?, ?, ?)",
        (session.case_id, session.judge_id, "scheduled", video_room_url, MANUS_URL, datetime.now().isoformat())
    )
    session_id = c.lastrowid
    conn.commit()
    conn.close()
    
    return {
        "id": session_id,
        "case_id": session.case_id,
        "status": "scheduled",
        "video_room_url": video_room_url,
        "manus_instance": MANUS_URL
    }

@app.get("/api/sessions")
def list_sessions(limit: int = 50):
    conn = sqlite3.connect(str(DATABASE_PATH))
    c = conn.cursor()
    c.execute("SELECT * FROM sessions ORDER BY id DESC LIMIT ?", (limit,))
    
    sessions = []
    for row in c.fetchall():
        sessions.append({
            "id": row[0],
            "case_id": row[1],
            "judge_id": row[2],
            "status": row[3],
            "video_room_url": row[4],
            "manus_instance": row[5],
            "created_at": row[6]
        })
    
    conn.close()
    return {"sessions": sessions}

@app.get("/api/outputs")
def list_outputs():
    try:
        files = sorted(OUTPUTS_DIR.glob("*"), key=lambda p: p.stat().st_mtime, reverse=True)[:50]
        return {
            "outputs": [
                {
                    "filename": f.name,
                    "size": f.stat().st_size,
                    "created": datetime.fromtimestamp(f.stat().st_mtime).isoformat()
                }
                for f in files if f.is_file()
            ]
        }
    except Exception as e:
        return {"outputs": [], "error": str(e)}

@app.websocket("/ws/live")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket for real-time updates"""
    await manager.connect(websocket)
    try:
        while True:
            # Send periodic updates
            await websocket.receive_text()
            await manager.broadcast({
                "type": "status_update",
                "timestamp": datetime.now().isoformat(),
                "manus_connected": True
            })
    except WebSocketDisconnect:
        manager.disconnect(websocket)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
