from datetime import datetime

def run(payload: dict) -> dict:
    return {
        "agent": "Io",
        "input": payload,
        "status": "active",
        "timestamp": datetime.utcnow().isoformat()
    }
