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
