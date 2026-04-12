import os, json
from datetime import datetime

TRANSMISSIONS_DIR = os.path.expanduser("~/PaTHos/transmissions")

def write_transmission(agent, payload):
    os.makedirs(TRANSMISSIONS_DIR, exist_ok=True)
    path = os.path.join(TRANSMISSIONS_DIR, f"{agent.lower()}.json")
    with open(path, "w") as f:
        json.dump({
            "agent": agent,
            "payload": payload,
            "timestamp": datetime.utcnow().isoformat()
        }, f, indent=2)
    return {"status": "logged", "path": path}

def read_transmission(agent):
    path = os.path.join(TRANSMISSIONS_DIR, f"{agent.lower()}.json")
    if not os.path.exists(path):
        return None
    with open(path) as f:
        return json.load(f)
