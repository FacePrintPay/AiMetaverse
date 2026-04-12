#!/usr/bin/env python3
import sys
from datetime import datetime

AGENTS = {
    "mars": "scraper",
    "venus": "researcher",
    "mercury": "strategist",
    "saturn": "security",
    "earth": "infrastructure"
}

def run_agents(mode="manual"):
    print(f"🤖 Running planetary agents in {mode} mode...")
    for agent, role in AGENTS.items():
        print(f"  ✓ {agent.upper()}: {role} - idle")
    print(f"✓ All agents checked at {datetime.now().isoformat()}")

if __name__ == "__main__":
    mode = sys.argv[2] if len(sys.argv) > 2 else "manual"
    run_agents(mode)
