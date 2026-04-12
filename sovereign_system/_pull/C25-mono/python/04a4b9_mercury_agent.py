#!/usr/bin/env python3
"""Mercury Agent - Fast Response & Quick Tasks"""
import sys
import time
import json
from pathlib import Path
from datetime import datetime

sys.path.insert(0, str(Path.home() / "tasks"))
from agent_bus import AgentBus

AGENT_NAME = "Mercury"
LOG_FILE = Path.home() / "logs/agents" / f"{AGENT_NAME}.log"

def log(msg):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_msg = f"[{timestamp}] [{AGENT_NAME}] {msg}"
    print(log_msg)
    with open(LOG_FILE, 'a') as f:
        f.write(log_msg + "\n")

def process_task(content):
    """Process quick tasks"""
    log(f"Processing: {content}")
    # Simulate work
    time.sleep(1)
    return f"Mercury completed: {content}"

def main():
    bus = AgentBus()
    bus.register_agent(AGENT_NAME, ["quick_response", "fast_tasks", "monitoring"])
    log(f"{AGENT_NAME} agent started")
    
    cycle = 0
    while True:
        cycle += 1
        messages = bus.get_messages(AGENT_NAME)
        
        for msg in messages:
            if msg["type"] in ["quick_task", "info"]:
                result = process_task(msg["content"])
                bus.post_message(AGENT_NAME, "response", result, target=msg["sender"])
                bus.mark_processed(msg["id"])
                log(f"Processed message {msg['id']}")
        
        if cycle % 10 == 0:
            log(f"Heartbeat: {cycle} cycles completed")
        
        time.sleep(2)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        log("Shutting down gracefully")
