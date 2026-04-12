import json
import threading
import time
from http.server import HTTPServer, BaseHTTPRequestHandler

state = {
    "running": False,
    "tasks_completed": 0,
    "earnings": 0.0,
    "active_agents": 0,
    "agents": [
        {"name": "EARTH", "status": "idle"},
        {"name": "MARS", "status": "idle"},
        {"name": "VENUS", "status": "idle"},
        {"name": "JUPITER", "status": "idle"},
        {"name": "SATURN", "status": "idle"}
    ],
    "platforms": [
        {"name": "Pawns.app", "earnings": 12.40},
        {"name": "Honeygain", "earnings": 8.75},
        {"name": "Prolific", "earnings": 7.20},
        {"name": "Clickworker", "earnings": 5.80},
        {"name": "Shutterstock", "earnings": 4.50},
        {"name": "Swagbucks", "earnings": 3.20},
        {"name": "InboxDollars", "earnings": 2.80},
        {"name": "UserTesting", "earnings": 2.50},
        {"name": "Second to None", "earnings": 2.20},
        {"name": "Studypool", "earnings": 1.90},
        {"name": "Teachable", "earnings": 1.80},
        {"name": "Printful", "earnings": 1.70},
        {"name": "Rover", "earnings": 1.60},
        {"name": "TaskRabbit", "earnings": 1.50},
        {"name": "Upwork", "earnings": 1.40},
        {"name": "Wrapify", "earnings": 1.30},
        {"name": "Decluttr", "earnings": 1.20},
        {"name": "Mistplay", "earnings": 1.10}
    ]
}

def simulate_agents():
    while True:
        if state["running"]:
            state["tasks_completed"] += 1
            state["earnings"] += 0.37
            state["active_agents"] = 5
            for agent in state["agents"]:
                agent["status"] = "running"
        else:
            state["active_agents"] = 0
            for agent in state["agents"]:
                agent["status"] = "idle"
        time.sleep(2)

threading.Thread(target=simulate_agents, daemon=True).start()

class AgentikHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            with open("/data/data/com.termux/files/home/agentik/dashboard.html", "rb") as f:
                self.wfile.write(f.read())
        elif self.path == "/api/v1/status":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(state).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path == "/api/v1/swarm/start":
            state["running"] = True
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(b'{"status":"started"}')
        elif self.path == "/api/v1/swarm/stop":
            state["running"] = False
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(b'{"status":"stopped"}')
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        return

if __name__ == "__main__":
    server = HTTPServer(("127.0.0.1", 8082), AgentikHandler)
    server.serve_forever()
