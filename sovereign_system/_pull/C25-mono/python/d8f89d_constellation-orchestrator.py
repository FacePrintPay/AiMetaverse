#!/usr/bin/env python3
"""
Constellation-25 Agent Orchestrator
25 Planetary AI Agents System
Architect: Cygel White (#MrGGTP / TotalRecall)
Version: 3.0-DEPLOY
"""

import os
import sys
import json
import time
import hashlib
import subprocess
from datetime import datetime, timezone, timezone
from pathlib import Path

class ConstellationOrchestrator:
    def __init__(self):
        self.base_dir = Path.home() / "constellation25"
        self.agents_dir = self.base_dir / "agents"
        self.logs_dir = self.base_dir / "logs"
        self.tasks_dir = self.base_dir / "tasks"
        self.config_dir = self.base_dir / "config"
        self.totalrecall_dir = Path.home() / "TotalRecall" / "constellation25"
        
        self.agents_dir.mkdir(parents=True, exist_ok=True)
        self.logs_dir.mkdir(parents=True, exist_ok=True)
        self.tasks_dir.mkdir(parents=True, exist_ok=True)
        self.config_dir.mkdir(parents=True, exist_ok=True)
        self.totalrecall_dir.mkdir(parents=True, exist_ok=True)
        
        self.agents = [
            "earth", "moon", "sun", "mercury", "venus", "mars",
            "jupiter", "saturn", "uranus", "neptune", "pluto",
            "cygnus", "orion", "andromeda", "pleiades", "sirius",
            "canismajor", "hydra", "vega", "polaris", "rigel",
            "capella", "altair", "deneb", "fomalhaut"
        ]
        
        self.config = self.load_config()
        
    def load_config(self):
        config_file = self.config_dir / "settings.json"
        if config_file.exists():
            with open(config_file, "r") as f:
                return json.load(f)
        return {"version": "3.0", "agent_count": 25}
    
    def log_forensic(self, message, agent="orchestrator"):
        timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        log_entry = f"[{timestamp}] [{agent.upper()}] {message}\n"
        
        log_file = self.logs_dir / f"constellation_{datetime.now().strftime('%Y%m%d')}.log"
        with open(log_file, "a") as f:
            f.write(log_entry)
        
        recall_entry = f"[{timestamp}] C25-{agent}: {message}\n"
        with open(self.totalrecall_dir / "orchestrator_log.txt", "a") as f:
            f.write(recall_entry)
        
        hash_value = hashlib.sha256(log_entry.encode()).hexdigest()
        with open(self.totalrecall_dir / "blockchain_manifest.txt", "a") as f:
            f.write(f"{hash_value}  {log_entry.strip()}\n")
        
        print(log_entry.strip())
    
    def check_ollama(self):
        try:
            result = subprocess.run(
                ["curl", "-s", "http://localhost:11434/api/tags"],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                self.log_forensic("Ollama detected and running")
                return True
            else:
                self.log_forensic("Ollama not responding", "warning")
                return False
        except Exception as e:
            self.log_forensic(f"Ollama check failed: {str(e)}", "error")
            return False
    
    def start_agent(self, agent_name):
        agent_script = self.agents_dir / f"{agent_name}-agent.sh"
        
        if agent_script.exists():
            self.log_forensic(f"Starting {agent_name} agent")
            subprocess.Popen(
                ["bash", str(agent_script)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            return True
        else:
            self.log_forensic(f"Agent script not found: {agent_name}", "error")
            return False
    
    def start_all_agents(self):
        self.log_forensic("Starting Constellation-25 Agent Swarm")
        
        for agent in self.agents:
            self.start_agent(agent)
            time.sleep(0.5)
        
        self.log_forensic(f"All {len(self.agents)} agents launched")
    
    def status(self):
        self.log_forensic("Constellation-25 Status Report")
        
        for agent in self.agents:
            agent_log = self.logs_dir / f"{agent}_status.log"
            if agent_log.exists():
                with open(agent_log, "r") as f:
                    lines = f.readlines()
                    if lines:
                        last_line = lines[-1].strip()
                        self.log_forensic(f"  {agent}: {last_line}")
                    else:
                        self.log_forensic(f"  {agent}: No status")
            else:
                self.log_forensic(f"  {agent}: Not running")

if __name__ == "__main__":
    orchestrator = ConstellationOrchestrator()
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "start":
            orchestrator.start_all_agents()
        elif command == "status":
            orchestrator.status()
        elif command == "ollama":
            orchestrator.check_ollama()
        else:
            print(f"Unknown command: {command}")
            print("Usage: python3 constellation-orchestrator.py [start|status|ollama]")
    else:
        print("Constellation-25 Orchestrator")
        print("Usage: python3 constellation-orchestrator.py [start|status|ollama]")
