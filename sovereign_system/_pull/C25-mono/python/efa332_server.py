from flask import Flask, jsonify
app = Flask(__name__)
@app.route('/status')
def agent_status():
    return jsonify({"status": "🛰️ Sovereign Deck Online"})
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5555)
