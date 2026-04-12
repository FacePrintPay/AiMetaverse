from datetime import datetime

def run(payload: dict) -> dict:
    return {
        "agent": "Earth",
        "input": payload,
        "status": "active",
        "timestamp": datetime.utcnow().isoformat()
    }
