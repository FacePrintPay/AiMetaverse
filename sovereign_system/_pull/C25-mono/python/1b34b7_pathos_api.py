from flask import Flask, request, jsonify
from typing import List, Dict
from datetime import datetime
import json, os

app = Flask(__name__)
MEMORY_FILE = os.path.join(os.path.dirname(__file__), "memory_log.json")

# ------------------------------
# Core Logic
# ------------------------------
def Cygnus(data: List[Dict], threshold: float) -> List[Dict]:
    return [d for d in data if d.get("value", 0) >= threshold]

def infer_with_pathos(text: str, threshold: float = 0.5):
    val = 0.8 if any(x in text.lower() for x in ["love", "great", "fantastic"]) else 0.3
    sentiment = "Positive" if val > threshold else "Negative"
    return {"text": text, "value": val, "sentiment": sentiment}

# ------------------------------
# Photographic Memory System
# ------------------------------
def save_to_memory(entry: Dict):
    log = []
    if os.path.exists(MEMORY_FILE):
        with open(MEMORY_FILE, "r") as f:
            try:
                log = json.load(f)
            except json.JSONDecodeError:
                log = []

    entry["timestamp"] = datetime.utcnow().isoformat() + "Z"
    log.append(entry)

    with open(MEMORY_FILE, "w") as f:
        json.dump(log, f, indent=2)

# ------------------------------
# Routes
# ------------------------------
@app.route("/analyze", methods=["POST"])
def analyze():
    data = request.get_json()
    text = data.get("text", "")
    result = infer_with_pathos(text)
    save_to_memory(result)
    return jsonify(result)

@app.route("/memory", methods=["GET"])
def memory():
    if not os.path.exists(MEMORY_FILE):
        return jsonify([])
    with open(MEMORY_FILE, "r") as f:
        log = json.load(f)
    return jsonify(log)

# ------------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
