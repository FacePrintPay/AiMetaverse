from datetime import datetime

def run(payload: dict) -> dict:
    return {
        "agent": "Oberon",
        "input": payload,
        "status": "active",
        "timestamp": datetime.utcnow().isoformat()
    }
