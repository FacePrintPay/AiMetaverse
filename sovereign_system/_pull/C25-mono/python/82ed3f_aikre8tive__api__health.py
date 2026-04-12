# REPO: aikre8tive | FILE: api/health.py | CONSTELLATION25

from flask import Flask, jsonify
app = Flask(__name__)

@app.get("/")
def root():
    return jsonify({"ok": True, "service": "aikre8tive"})
