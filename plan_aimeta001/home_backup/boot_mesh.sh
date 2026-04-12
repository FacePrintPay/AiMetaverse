#!/data/data/com.termux/files/usr/bin/bash

echo "🌍 SovereignGTP - Termux Boot"
echo "=============================="

# Setup
mkdir -p logs pids agents/totalrecall tasks/{incoming,processed} outputs

# Create venv
if [ ! -d "venv" ]; then
    python -m venv venv
fi
source venv/bin/activate

# Install deps
pip install -q redis pyyaml 2>/dev/null

echo "✓ Environment ready"

# Create TotalRecall logger
cat > agents/totalrecall/logger.py << 'PYLOGGER'
#!/usr/bin/env python3
import time, sys
from datetime import datetime

while True:
    print(f"{datetime.now().isoformat()} | TOTALRECALL | Active")
    sys.stdout.flush()
    with open("logs/totalrecall.log", "a") as f:
        f.write(f"{datetime.now().isoformat()} | HEARTBEAT\n")
    time.sleep(60)
PYLOGGER

# Create helio agent (with task handling)
cat > agents/helio.py << 'PYHELIO'
#!/usr/bin/env python3
import time, sys, os, json, shutil
from datetime import datetime

NAME = "helio"
TASK_IN = "tasks/incoming"
TASK_DONE = "tasks/processed"
OUTPUT_DIR = "outputs"

os.makedirs(TASK_IN, exist_ok=True)
os.makedirs(TASK_DONE, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

def log(msg):
    print(f"{datetime.now().isoformat()} | {NAME.upper()} | {msg}")
    sys.stdout.flush()

def handle_task(task, path):
    ttype = task.get("type")
    payload = task.get("payload", "")
    log(f"Task: {ttype} - {payload}")
    
    if ttype == "generate_html":
        out = f"{OUTPUT_DIR}/{NAME}_{int(time.time())}_output.txt"
        with open(out, "w") as f:
            f.write(f"Artifact from {NAME}\nType: {ttype}\nPayload: {payload}\n")
        log(f"Created: {out}")
    
    shutil.move(path, os.path.join(TASK_DONE, os.path.basename(path)))

def poll_tasks():
    for fname in os.listdir(TASK_IN):
        if fname.startswith(f"{NAME}_"):
            path = os.path.join(TASK_IN, fname)
            try:
                with open(path) as f:
                    task = json.load(f)
                handle_task(task, path)
            except Exception as e:
                log(f"Error: {e}")

log("Starting...")
while True:
    poll_tasks()
    log("Heartbeat")
    time.sleep(30)
PYHELIO

# Create other agents
for agent in vault echo chronos mercury venus earth mars; do
cat > agents/${agent}.py << PYAGENT
#!/usr/bin/env python3
import time, sys
from datetime import datetime

name = "${agent}"
while True:
    print(f"{datetime.now().isoformat()} | {name.upper()} | Active")
    sys.stdout.flush()
    time.sleep(30)
PYAGENT
done

echo "✓ Agents created"

# Start Redis
redis-server --daemonize yes --port 6379 --logfile logs/redis.log 2>/dev/null || echo "⚠ Redis optional"

# Start TotalRecall
python agents/totalrecall/logger.py > logs/totalrecall.log 2>&1 &
echo $! > pids/totalrecall.pid
echo "✓ TotalRecall started"

# Start agents
for agent in helio vault echo chronos mercury venus earth mars; do
    python agents/${agent}.py > logs/${agent}.log 2>&1 &
    echo $! > pids/${agent}.pid
    echo "✓ ${agent} started (PID: $!)"
    sleep 0.2
done

echo ""
echo "🟢 Mesh ONLINE"
echo ""
echo "Commands:"
echo "  tail -f logs/*.log  # View logs"
echo "  ./send_task.sh      # Send task to agent"
echo "  ./stop_mesh.sh      # Stop all"
echo ""
