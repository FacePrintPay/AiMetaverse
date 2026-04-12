from datetime import datetime

def run(payload: dict) -> dict:
    return {
        "agent": "Venus",
        "input": payload,
        "status": "active",
        "timestamp": datetime.utcnow().isoformat()
    }
