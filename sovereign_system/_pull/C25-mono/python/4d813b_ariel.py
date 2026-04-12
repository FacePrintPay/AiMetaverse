from datetime import datetime

def run(payload: dict) -> dict:
    return {
        "agent": "Ariel",
        "input": payload,
        "status": "active",
        "timestamp": datetime.utcnow().isoformat()
    }
