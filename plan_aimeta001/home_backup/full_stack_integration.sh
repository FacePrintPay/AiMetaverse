#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# ============================================================
# AGI KRE8TIVE - FULL STACK INTEGRATION (Termux)
# Ports:
#   Web UI     :8765
#   Keys API   :8000
#   Swarm API  :8001
#
# Commands:
#   bash ~/full_stack_integration.sh up
#   bash ~/full_stack_integration.sh down
#   bash ~/full_stack_integration.sh status
#   bash ~/full_stack_integration.sh logs
# ============================================================

WEB_PORT=8765
API_PORT=8000
SWARM_API_PORT=8001

REPO="$HOME/Kre8tiveKonceptz_RepoDepo"
LOG_DIR="$REPO/logs"

WEB_DIR="$HOME/outputs/web/agi-kre8tive"
INDEX_HTML="$WEB_DIR/index.html"

FASTAPI_DIR="$HOME/SOVEREIGN_VAULT/Z-36/ai-kre8tive-stargate/builds/code_gen"
FASTAPI_APP="$FASTAPI_DIR/output.py"

SWARM_DIR="$HOME/swarm_api"
SWARM_APP="$SWARM_DIR/swarm_api.py"

API_LOG="$LOG_DIR/uvicorn_key_rotation.log"
SWARM_LOG="$LOG_DIR/swarm_api.log"
WEB_LOG="$LOG_DIR/web_8765.log"

PID_DIR="$REPO/.pids"
PID_API="$PID_DIR/api_8000.pid"
PID_SWARM="$PID_DIR/swarm_8001.pid"
PID_WEB="$PID_DIR/web_8765.pid"

say(){ printf "[%s] %s\n" "$(date +'%H:%M:%S')" "$*"; }
die(){ say "ERROR: $*"; exit 1; }

need_cmd(){
  command -v "$1" >/dev/null 2>&1 || return 1
  return 0
}

need_pkg(){
  local bin="$1"
  local pkg="$2"
  if ! need_cmd "$bin"; then
    say "Installing missing dependency: $bin (pkg: $pkg)"
    pkg install -y "$pkg" >/dev/null 2>&1 || die "Failed to install package: $pkg"
  fi
}

ensure_dirs(){
  mkdir -p "$LOG_DIR" "$PID_DIR" "$FASTAPI_DIR" "$SWARM_DIR" "$WEB_DIR"
}

# Get PIDs listening on a TCP port using ss, return as space-separated list
pids_on_port(){
  local port="$1"
  # ss output example:
  # LISTEN 0 4096 0.0.0.0:8000 0.0.0.0:* users:(("python",pid=1234,fd=10))
  ss -ltnp 2>/dev/null \
    | awk -v p=":$port" '$0 ~ p && $0 ~ /users:\(\(/ {print $0}' \
    | sed -n 's/.*pid=\([0-9]\+\).*/\1/p' \
    | tr '\n' ' ' \
    | sed 's/[[:space:]]*$//'
}

kill_port(){
  local port="$1"
  local pids
  pids="$(pids_on_port "$port" || true)"
  if [ -n "${pids:-}" ]; then
    say "Port $port in use by PID(s): $pids"
    for pid in $pids; do
      kill "$pid" 2>/dev/null || true
    done
    sleep 0.4
    # If still alive, hard kill
    pids="$(pids_on_port "$port" || true)"
    if [ -n "${pids:-}" ]; then
      say "Port $port still in use; forcing kill: $pids"
      for pid in $pids; do
        kill -9 "$pid" 2>/dev/null || true
      done
      sleep 0.4
    fi
  fi
}

pid_alive(){
  local pid_file="$1"
  [ -f "$pid_file" ] || return 1
  local pid
  pid="$(cat "$pid_file" 2>/dev/null || true)"
  [ -n "${pid:-}" ] || return 1
  ps -p "$pid" >/dev/null 2>&1
}

write_fastapi(){
  say "Writing Keys API (FastAPI) app: $FASTAPI_APP"
  cat > "$FASTAPI_APP" <<'PY'
#!/usr/bin/env python3
"""
AGI KRE8TIVE - Key Rotation API (Clean, Termux-safe)
"""

from datetime import datetime
import secrets
import os
from typing import Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(
    title="AGI KRE8TIVE Key Rotation API",
    version="1.0.0",
    description="Secure key rotation service for RepoDepo"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # dev-only
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
    old_key_valid_until: Optional[str] = None

@app.get("/")
async def root():
    return {
        "service": "AGI KRE8TIVE Key Rotation API",
        "version": "1.0.0",
        "status": "operational",
        "endpoints": {
            "health": "/health",
            "metrics": "/metrics",
            "rotate_key": "/rotate-key (POST)"
        }
    }

@app.get("/health")
async def health():
    return {"ok": True, "ts": datetime.now().isoformat()}

@app.get("/metrics")
async def metrics():
    return {
        "service": "AGI KRE8TIVE Key Rotation",
        "timestamp": datetime.now().isoformat(),
        "pid": os.getpid(),
        "allowed": 0,
        "blocked": 0,
        "requests_per_second": 0.0,
    }

@app.post("/rotate-key", response_model=KeyRotationResponse)
async def rotate_key(request: KeyRotationRequest):
    try:
        new_key = f"ak_{secrets.token_urlsafe(32)}"
        rotated_at = datetime.now()
        return KeyRotationResponse(
            service_name=request.service_name,
            new_key=new_key,
            rotated_at=rotated_at.isoformat(),
            expires_in_days=90,
            old_key_valid_until=rotated_at.isoformat()
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Key rotation failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("output:app", host="0.0.0.0", port=8000, log_level="info")
PY
  chmod +x "$FASTAPI_APP"
}

write_swarm_api(){
  say "Writing Swarm API bridge: $SWARM_APP"
  cat > "$SWARM_APP" <<'PY'
#!/usr/bin/env python3
"""
AGI Swarm API Bridge - Connects web frontend to task queue
"""

from datetime import datetime
import json
import os
from pathlib import Path
from typing import List

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

TASKS_ROOT = Path.home() / "tasks"
OUTPUTS_ROOT = Path.home() / "outputs"
LOGS_ROOT = Path.home() / "logs"

app = FastAPI(
    title="AGI Swarm API",
    version="1.0.0",
    description="API bridge for AGI agent orchestration"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # dev-only
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

@app.get("/")
async def root():
    return {"service": "AGI Swarm API", "version": "1.0.0", "status": "operational"}

@app.get("/health")
async def health():
    return {"ok": True, "ts": datetime.now().isoformat()}

@app.get("/swarm/status", response_model=SwarmStatus)
async def swarm_status():
    try:
        daemon_pid = LOGS_ROOT / "orchestrator" / "daemon.pid"
        orchestrator_running = False
        if daemon_pid.exists():
            try:
                pid = int(daemon_pid.read_text().strip())
                os.kill(pid, 0)
                orchestrator_running = True
            except Exception:
                orchestrator_running = False

        incoming = len(list((TASKS_ROOT / "incoming").glob("*.json"))) if (TASKS_ROOT / "incoming").exists() else 0
        processing = len(list((TASKS_ROOT / "processing").glob("*.json"))) if (TASKS_ROOT / "processing").exists() else 0
        completed = len(list((TASKS_ROOT / "completed").glob("*.json"))) if (TASKS_ROOT / "completed").exists() else 0
        failed = len(list((TASKS_ROOT / "failed").glob("*.json"))) if (TASKS_ROOT / "failed").exists() else 0

        return SwarmStatus(
            orchestrator_running=orchestrator_running,
            agents_available=["valuation", "market", "finance", "pr", "outreach", "income", "bundle", "web_build"],
            tasks_pending=incoming,
            tasks_processing=processing,
            tasks_completed=completed,
            tasks_failed=failed
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/swarm/task", response_model=TaskResponse)
async def create_task(request: TaskRequest):
    try:
        ts = int(datetime.now().timestamp())
        task_id = f"{request.agent}_{ts}"

        task_data = {
            "agent": request.agent,
            "type": request.task_type,
            "description": request.description,
            "priority": request.priority,
            "created_at": datetime.now().isoformat()
        }

        incoming_dir = TASKS_ROOT / "incoming"
        incoming_dir.mkdir(parents=True, exist_ok=True)

        task_file = incoming_dir / f"{task_id}.json"
        task_file.write_text(json.dumps(task_data, indent=2))

        return TaskResponse(
            task_id=task_id,
            agent=request.agent,
            status="queued",
            created_at=task_data["created_at"]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
PY
  chmod +x "$SWARM_APP"
}

ensure_index_html(){
  if [ ! -f "$INDEX_HTML" ]; then
    say "Creating landing page: $INDEX_HTML"
    cat > "$INDEX_HTML" <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>AGI KRE8TIVE</title>
</head>
<body style="font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; padding: 24px;">
  <h1>AGI KRE8TIVE</h1>
  <p>Landing page placeholder. Live Demo panel will be injected below.</p>
</body>
</html>
HTML
  fi

  # Inject panel safely via python (no shell interpolation)
  python - <<'PY'
from pathlib import Path

index = Path.home() / "outputs/web/agi-kre8tive/index.html"
html = index.read_text(encoding="utf-8")

panel = r"""
<!-- AGI KRE8TIVE LIVE DEMO PANEL (injected) -->
<section id="liveDemo" style="margin-top:24px;padding:16px;border:1px solid #222;border-radius:12px;">
  <h2 style="margin:0 0 10px 0;">Live Demo</h2>
  <div style="display:flex;gap:10px;flex-wrap:wrap;align-items:center;">
    <span id="apiLight" style="display:inline-block;width:10px;height:10px;border-radius:50%;background:#999;"></span>
    <strong id="apiStatus">Checking APIs...</strong>
    <button id="btnRefresh" style="padding:8px 12px;border-radius:10px;border:1px solid #333;cursor:pointer;">Refresh</button>
    <button id="btnRotate" style="padding:8px 12px;border-radius:10px;border:1px solid #333;cursor:pointer;">Rotate Key</button>
  </div>

  <h3 style="margin:14px 0 6px 0;">Keys API Metrics (:8000)</h3>
  <pre id="metricsBox" style="background:#111;color:#0f0;padding:10px;border-radius:10px;overflow:auto;max-height:260px;">(loading)</pre>

  <h3 style="margin:14px 0 6px 0;">Rotate Result</h3>
  <pre id="rotateBox" style="background:#111;color:#0ff;padding:10px;border-radius:10px;overflow:auto;max-height:260px;">(none)</pre>

  <h3 style="margin:14px 0 6px 0;">Swarm Status (:8001)</h3>
  <pre id="swarmBox" style="background:#111;color:#fff;padding:10px;border-radius:10px;overflow:auto;max-height:260px;">(loading)</pre>
</section>

<script>
const API8000 = "http://127.0.0.1:8000";
const API8001 = "http://127.0.0.1:8001";

function setStatus(ok, msg){
  document.getElementById("apiLight").style.background = ok ? "#2ecc71" : "#e74c3c";
  document.getElementById("apiStatus").textContent = msg;
}

async function refresh(){
  try{
    const [metrics, swarm] = await Promise.all([
      fetch(API8000 + "/metrics").then(r => r.json()),
      fetch(API8001 + "/swarm/status").then(r => r.json())
    ]);

    setStatus(true, "APIs Online");
    document.getElementById("metricsBox").textContent = JSON.stringify(metrics, null, 2);
    document.getElementById("swarmBox").textContent = JSON.stringify(swarm, null, 2);
  } catch(e){
    setStatus(false, "API Offline");
    document.getElementById("metricsBox").textContent = String(e);
    document.getElementById("swarmBox").textContent = String(e);
  }
}

async function rotate(){
  try{
    const body = { service_name: "RepoDepo", key_type: "api_key" };
    const res = await fetch(API8000 + "/rotate-key", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(body)
    });
    const json = await res.json();
    document.getElementById("rotateBox").textContent = JSON.stringify(json, null, 2);
  } catch(e){
    document.getElementById("rotateBox").textContent = String(e);
  }
}

document.getElementById("btnRefresh").addEventListener("click", refresh);
document.getElementById("btnRotate").addEventListener("click", rotate);
refresh();
</script>
"""

if "AGI KRE8TIVE LIVE DEMO PANEL (injected)" not in html:
    if "</body>" in html:
        html = html.replace("</body>", panel + "\n</body>")
    else:
        html += panel
    index.write_text(html, encoding="utf-8")
PY
}

start_api(){
  kill_port "$API_PORT"
  say "Starting Keys API on :$API_PORT"
  nohup python -m uvicorn output:app --host 0.0.0.0 --port "$API_PORT" --app-dir "$FASTAPI_DIR" > "$API_LOG" 2>&1 &
  echo $! > "$PID_API"
}

start_swarm(){
  kill_port "$SWARM_API_PORT"
  say "Starting Swarm API on :$SWARM_API_PORT"
  nohup python -m uvicorn swarm_api:app --host 0.0.0.0 --port "$SWARM_API_PORT" --app-dir "$SWARM_DIR" > "$SWARM_LOG" 2>&1 &
  echo $! > "$PID_SWARM"
}

start_web(){
  kill_port "$WEB_PORT"
  say "Starting Web server on :$WEB_PORT"
  nohup python -m http.server "$WEB_PORT" --directory "$WEB_DIR" > "$WEB_LOG" 2>&1 &
  echo $! > "$PID_WEB"
}

wait_http(){
  local url="$1"
  local tries="${2:-40}"
  local i=0
  while [ "$i" -lt "$tries" ]; do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    i=$((i+1))
    sleep 0.15
  done
  return 1
}

up(){
  need_pkg python python
  need_pkg curl curl
  need_pkg jq jq
  need_pkg ss iproute2

  ensure_dirs
  write_fastapi
  write_swarm_api
  ensure_index_html

  # Clean slate on ports (actual port kills, not broad pkill)
  kill_port "$API_PORT"
  kill_port "$SWARM_API_PORT"
  kill_port "$WEB_PORT"

  start_api
  start_swarm
  start_web

  say "Verifying services..."
  wait_http "http://127.0.0.1:${API_PORT}/health" || { tail -n 80 "$API_LOG" || true; die "Keys API did not come up"; }
  wait_http "http://127.0.0.1:${SWARM_API_PORT}/health" || { tail -n 80 "$SWARM_LOG" || true; die "Swarm API did not come up"; }
  wait_http "http://127.0.0.1:${WEB_PORT}/index.html" || { tail -n 80 "$WEB_LOG" || true; die "Web server did not come up"; }

  curl -fsS "http://127.0.0.1:${API_PORT}/metrics" | jq . >/dev/null || die "Keys metrics failed"
  curl -fsS "http://127.0.0.1:${SWARM_API_PORT}/swarm/status" | jq . >/dev/null || die "Swarm status failed"

  echo ""
  echo "FULL STACK OPERATIONAL"
  echo ""
  echo "Landing Page:   http://127.0.0.1:${WEB_PORT}/index.html"
  echo "Keys API:       http://127.0.0.1:${API_PORT}"
  echo "Swarm API:      http://127.0.0.1:${SWARM_API_PORT}"
  echo ""
  echo "Logs:"
  echo "  Keys:  $API_LOG"
  echo "  Swarm: $SWARM_LOG"
  echo "  Web:   $WEB_LOG"
  echo ""
}

down(){
  say "Stopping services..."
  # Prefer PID files if present
  for pf in "$PID_API" "$PID_SWARM" "$PID_WEB"; do
    if [ -f "$pf" ]; then
      pid="$(cat "$pf" 2>/dev/null || true)"
      if [ -n "${pid:-}" ] && ps -p "$pid" >/dev/null 2>&1; then
        kill "$pid" 2>/dev/null || true
      fi
      rm -f "$pf" || true
    fi
  done
  # Also ensure ports are free
  kill_port "$API_PORT"
  kill_port "$SWARM_API_PORT"
  kill_port "$WEB_PORT"
  say "Stopped."
}

status(){
  need_pkg ss iproute2
  echo "Listeners:"
  ss -ltnp 2>/dev/null | grep -E ":(${WEB_PORT}|${API_PORT}|${SWARM_API_PORT})" || echo "(none)"
  echo ""
  echo "Health:"
  curl -fsS "http://127.0.0.1:${API_PORT}/health" 2>/dev/null | jq . || echo "Keys API down"
  curl -fsS "http://127.0.0.1:${SWARM_API_PORT}/health" 2>/dev/null | jq . || echo "Swarm API down"
  echo ""
  echo "Open:"
  echo "  http://127.0.0.1:${WEB_PORT}/index.html"
}

logs(){
  echo "Keys log (tail):"
  tail -n 80 "$API_LOG" 2>/dev/null || true
  echo ""
  echo "Swarm log (tail):"
  tail -n 80 "$SWARM_LOG" 2>/dev/null || true
  echo ""
  echo "Web log (tail):"
  tail -n 80 "$WEB_LOG" 2>/dev/null || true
}

case "${1:-up}" in
  up) up ;;
  down) down ;;
  restart) down; up ;;
  status) status ;;
  logs) logs ;;
  *)
    cat <<EOF
Usage: $(basename "$0") {up|down|restart|status|logs}

Landing Page: http://127.0.0.1:${WEB_PORT}/index.html
Keys API:     http://127.0.0.1:${API_PORT}
Swarm API:    http://127.0.0.1:${SWARM_API_PORT}
EOF
    ;;
esac
