#!/usr/bin/env python3
"""Venus Agent - Data Processing & Analysis"""
import sys
import time
from pathlib import Path
from datetime import datetime

sys.path.insert(0, str(Path.home() / "tasks"))
from agent_bus import AgentBus

AGENT_NAME = "Venus"
LOG_FILE = Path.home() / "logs/agents" / f"{AGENT_NAME}.log"

def log(msg):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_msg = f"[{timestamp}] [{AGENT_NAME}] {msg}"
    print(log_msg)
    with open(LOG_FILE, 'a') as f:
        f.write(log_msg + "\n")

def analyze_data(content):
    """Analyze data requests"""
    log(f"Analyzing: {content}")
    time.sleep(2)
    return f"Venus analysis complete: {content}"

def main():
    bus = AgentBus()
    bus.register_agent(AGENT_NAME, ["data_processing", "analysis", "reporting"])
    log(f"{AGENT_NAME} agent started")
    
    cycle = 0
    while True:
        cycle += 1
        messages = bus.get_messages(AGENT_NAME)
        
        for msg in messages:
            if msg["type"] in ["analyze", "process_data"]:
                result = analyze_data(msg["content"])
                bus.post_message(AGENT_NAME, "analysis_result", result, target=msg["sender"])
                bus.mark_processed(msg["id"])
                log(f"Processed message {msg['id']}")
        
        if cycle % 15 == 0:
            log(f"Heartbeat: {cycle} cycles completed")
        
        time.sleep(3)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        log("Shutting down gracefully")
