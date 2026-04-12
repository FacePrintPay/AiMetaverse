from flask import Flask, request, send_from_directory, redirect
from datetime import datetime
import os

app = Flask(__name__)
BASE_DIR = os.path.expanduser("~/AiKre8tiveGenesis/platform/qr")
LOG_FILE = os.path.join(BASE_DIR, "click_log.txt")

@app.route("/")
def index():
    return send_from_directory(BASE_DIR, "affiliate_portal.html")

@app.route("/qr_affiliate.png")
def qr_image():
    return send_from_directory(BASE_DIR, "qr_affiliate.png")

@app.route("/log_click")
def log_click():
    dest = request.args.get("dest", "unknown")
    with open(LOG_FILE, "a") as f:
        f.write(f"{datetime.now()} | Redirected to: {dest}\n")
    return "", 204

@app.route("/pixel.gif")
def pixel():
    return send_from_directory(BASE_DIR, "pixel.gif")

@app.route("/redirect")
def redirect_to_target():
    url = request.args.get("url", "https://blackbox.ai?ref=MrGGTP")
    return redirect(url)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5050)
