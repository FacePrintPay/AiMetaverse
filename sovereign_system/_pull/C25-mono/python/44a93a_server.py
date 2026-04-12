#!/usr/bin/env python3
"""Sovereign Deck - Planetary Agent Hub"""

from flask import Flask, jsonify
from planetary_agents import statuses

app = Flask(__name__)

@app.route('/')
def home():
    return "🛰️ Sovereign Deck - Planetary Agent Hub"

@app.route('/status')
def agent_status():
    return jsonify(statuses)

@app.route('/health')
def health():
    return jsonify({
        "status": "online",
        "agents": len(statuses),
        "protocol": "SOVEREIGN_GTP"
    })

if __name__ == '__main__':
    print("🛰️ Starting Sovereign Deck...")
    app.run(host='0.0.0.0', port=5555, debug=True)
