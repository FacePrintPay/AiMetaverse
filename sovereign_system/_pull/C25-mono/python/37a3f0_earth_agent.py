#!/usr/bin/env python3
"""Earth Agent - Central Orchestrator"""
import sys
import time
from pathlib import Path
from datetime import datetime

sys.path.insert(0, str(Path.home() / "tasks"))
from agent_bus import AgentBus

AGENT_NAME = "Earth"
LOG_FILE = Path.home() / "logs/agents" / f"{AGENT_NAME}.log"

def log(msg):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_msg = f"[{timestamp}] [{AGENT_NAME}] {msg}"
    print(log_msg)
    with open(LOG_FILE, 'a') as f:
        f.write(log_msg + "\n")

def orchestrate():
    """Coordinate between agents"""
    bus = AgentBus()
    agents = bus.get_active_agents()
    log(f"Active agents: {len(agents)}")
    return agents

def main():
    bus = AgentBus()
    bus.register_agent(AGENT_NAME, ["orchestration", "coordination", "management"])
    log(f"{AGENT_NAME} agent started (Central Orchestrator)")
    
    cycle = 0
    while True:
        cycle += 1
        
        # Orchestrate every 30 seconds
        if cycle % 10 == 0:
            agents = orchestrate()
            
        messages = bus.get_messages(AGENT_NAME)
        for msg in messages:
            log(f"Received: {msg['type']} from {msg['sender']}")
            bus.mark_processed(msg["id"])
        
        if cycle % 20 == 0:
            log(f"System status: {cycle} cycles, managing operations")
        
        time.sleep(3)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        log("Shutting down gracefully")
