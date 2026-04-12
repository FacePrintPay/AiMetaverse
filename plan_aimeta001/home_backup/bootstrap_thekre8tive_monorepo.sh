#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ts(){ date +'%Y-%m-%d %H:%M:%S'; }
log(){ echo "[$(ts)] $*"; }
die(){ echo "[ERROR] $*" >&2; exit 1; }

# ==============================
# CONFIG
# ==============================
GIT_USER="FacePrintPay"
REPO_NAME="sovereign-architect"
REPO_DIR="$HOME/sovereign-architect"

APP_ROOT="$REPO_DIR/apps/thekre8tive"
API_DIR="$APP_ROOT/src/api"
WEB_DIR="$APP_ROOT/src/web"
OPS_DIR="$APP_ROOT/ops"
LOG_DIR="$REPO_DIR/logs"

API_PORT=8000
SWARM_PORT=8001
WEB_PORT=8765

# ==============================
# DEP CHECKS
# ==============================
need(){ command -v "$1" >/dev/null 2>&1 || die "Missing $1 (pkg install -y $2)"; }
need git git
need python python
need curl curl
need pkill procps

# ==============================
# PORT KILLER
# ==============================
kill_port(){
  local p="$1"
  pkill -f "uvicorn.*--port $p" 2>/dev/null || true
  pkill -f "http.server $p" 2>/dev/null || true
}

# ==============================
# BOOTSTRAP STRUCTURE
# ==============================
log "Creating monorepo structure..."
mkdir -p "$API_DIR" "$WEB_DIR" "$OPS_DIR" "$LOG_DIR"

# ==============================
# FASTAPI KEY API
# ==============================
cat > "$API_DIR/keys_api.py" << 'PY'
from datetime import datetime
import os, secrets
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="AGI KRE8TIVE Keys API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class RotateReq(BaseModel):
    service_name: str

@app.get("/health")
def health():
    return {"ok": True, "time": datetime.utcnow().isoformat()}

@app.post("/rotate-key")
def rotate(req: RotateReq):
    return {
        "service": req.service_name,
        "new_key": "ak_" + secrets.token_urlsafe(32),
        "rotated_at": datetime.utcnow().isoformat()
    }
PY

# ==============================
# SWARM API
# ==============================
cat > "$API_DIR/swarm_api.py" << 'PY'
from datetime import datetime
import json, os
from pathlib import Path
from fastapi import FastAPI
from pydantic import BaseModel

TASKS = Path.home() / "tasks"
TASKS.mkdir(exist_ok=True)
(TASKS/"incoming").mkdir(exist_ok=True)

app = FastAPI(title="AGI Swarm API")

class TaskReq(BaseModel):
    agent: str
    task_type: str
    description: str

@app.get("/health")
def health():
    return {"ok": True}

@app.get("/swarm/status")
def status():
    def c(d): return len(list(d.glob("*.json"))) if d.exists() else 0
    return {
        "incoming": c(TASKS/"incoming"),
        "processing": c(TASKS/"processing"),
        "completed": c(TASKS/"completed"),
        "failed": c(TASKS/"failed"),
    }

@app.post("/swarm/task")
def task(t: TaskReq):
    tid = f"{t.agent}_{int(datetime.utcnow().timestamp())}"
    f = TASKS/"incoming"/f"{tid}.json"
    f.write_text(json.dumps({
        "agent": t.agent,
        "type": t.task_type,
        "description": t.description,
        "created_at": datetime.utcnow().isoformat()
    }, indent=2))
    return {"task_id": tid, "status": "queued"}
PY

# ==============================
# WEB UI
# ==============================
cat > "$WEB_DIR/index.html" << 'HTML'
<!doctype html>
<html>
<head>
  <title>AGI KRE8TIVE</title>
  <meta charset="utf-8"/>
</head>
<body>
<h1>AGI KRE8TIVE Sovereign Swarm</h1>
<button onclick="send()">Send Test Task</button>
<pre id="out"></pre>

<script>
async function send(){
  const r = await fetch("http://127.0.0.1:8001/swarm/task",{
    method:"POST",
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify({
      agent:"valuation",
      task_type:"test",
      description:"Web triggered task"
    })
  });
  document.getElementById("out").innerText = await r.text();
}
</script>
</body>
</html>
HTML

# ==============================
# OPS: RUNNER
# ==============================
cat > "$OPS_DIR/run.sh" << 'BASH'
#!/data/data/com.termux/files/usr/bin/bash
set -e

API_PORT=8000
SWARM_PORT=8001
WEB_PORT=8765

kill_port(){ pkill -f "$1" 2>/dev/null || true; }

kill_port "uvicorn.*8000"
kill_port "uvicorn.*8001"
kill_port "http.server 8765"

nohup python -m uvicorn keys_api:app --host 127.0.0.1 --port 8000 > ../../logs/keys.log 2>&1 &
nohup python -m uvicorn swarm_api:app --host 127.0.0.1 --port 8001 > ../../logs/swarm.log 2>&1 &
nohup python -m http.server 8765 --directory ../src/web > ../../logs/web.log 2>&1 &

echo "Running:"
echo "  Web   http://127.0.0.1:8765/index.html"
echo "  Keys  http://127.0.0.1:8000/health"
echo "  Swarm http://127.0.0.1:8001/swarm/status"
BASH

chmod +x "$OPS_DIR/run.sh"

# ==============================
# GIT
# ==============================
cd "$REPO_DIR"
git add .
git commit -m "Add TheKre8tive full-stack sovereign AGI app" || true
git push -u origin main

# ==============================
# RUN
# ==============================
cd "$API_DIR"
"$OPS_DIR/run.sh"
