import os, sys
from datetime import datetime
from flask import Flask, request, jsonify

# make sure Python can see ~/PaTHos/core and ~/PaTHos/planets
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from core.router import dispatch

app = Flask(__name__)

@app.route('/api/run', methods=['POST'])
def api_run():
    data = request.get_json(force=True)
    func_name = data.get("function")
    args = data.get("args", [])
    try:
        result = dispatch(func_name, *args) if isinstance(args, list) else dispatch(func_name, args)
        return jsonify({"status": "success", "result": result})
    except Exception as e:
        return jsonify({"status": "error", "error": str(e), "timestamp": datetime.utcnow().isoformat()})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
