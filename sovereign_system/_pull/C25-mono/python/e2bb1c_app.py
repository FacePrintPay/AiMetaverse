from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/')
def home():
    return "🚀 PaTHos-AI Core API Online"

@app.route('/run', methods=['POST'])
def run():
    data = request.json
    function = data.get('function')
    input_path = data.get('input')
    output_path = data.get('output')

    if not function:
        return jsonify({"error": "Function name is required."}), 400

    # Simulate logic call (replace with actual imports later)
    return jsonify({
        "status": "running",
        "function": function,
        "input": input_path,
        "output": output_path
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
