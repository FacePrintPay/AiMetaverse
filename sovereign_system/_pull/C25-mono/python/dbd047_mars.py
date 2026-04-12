from datetime import datetime

def run(payload: dict) -> dict:
    return {
        "agent": "Mars",
        "input": payload,
        "status": "active",
        "timestamp": datetime.utcnow().isoformat()
    }
