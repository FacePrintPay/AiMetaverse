from flask import Flask, request, jsonify
import os, json
from datetime import datetime

app = Flask(__name__)

@app.route('/api/run', methods=['POST'])
def run_pahtos():
    payload = request.get_json()
    func = payload.get("function")
    args = payload.get("args", [])
    # Here, call your planetary functions dynamically
    result = {"function": func, "args": args, "timestamp": datetime.utcnow().isoformat()}
    return jsonify({"status": "success", "result": result})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
