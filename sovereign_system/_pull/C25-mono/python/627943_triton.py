from datetime import datetime

def run(payload: dict) -> dict:
    return {
        "agent": "Triton",
        "input": payload,
        "status": "active",
        "timestamp": datetime.utcnow().isoformat()
    }
