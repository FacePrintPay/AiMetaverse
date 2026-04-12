#!/usr/bin/env python3
"""
CONSTELLATION25 — MCP Server v3
HTTP server on port 3000 (primary)
stdio MCP for Claude Desktop (secondary)
"""
import json, sys, os, hashlib, datetime, glob, threading, signal, time
from http.server import HTTPServer, BaseHTTPRequestHandler

C25   = os.path.expanduser("~/constellation25")
LOGS  = os.path.join(C25, "logs")
TASKS = os.path.join(C25, "tasks")
os.makedirs(LOGS, exist_ok=True)
os.makedirs(TASKS, exist_ok=True)

AGENTS = ["earth","mercury","venus","mars","jupiter","saturn","uranus",
          "neptune","pluto","luna","sol","sirius","vega","rigel","pleiades",
          "orion","hydra","lyra","cygnus","andromeda","perseus",
          "cassiopeia","aquila","draco","fomalhaut"]

def ts():
    return datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def sha(s):
    return hashlib.sha256(s.encode()).hexdigest()

def log(msg):
    try:
        with open(os.path.join(LOGS, "mcp.log"), "a") as f:
            f.write(f"[{ts()}] [MCP] {msg}\n")
    except:
        pass

def get_agents():
    agents_dir = os.path.join(C25, "agents")
    result = []
    for name in AGENTS:
        pid_file = os.path.join(agents_dir, f"{name}.pid")
        script   = os.path.join(agents_dir, f"{name}.sh")
        status   = "NO_PID"
        pid      = None
        if os.path.exists(pid_file):
            try:
                pid = int(open(pid_file).read().strip())
                os.kill(pid, 0)
                status = "UP"
            except:
                status = "DOWN"
        last_log = ""
        alog = os.path.join(LOGS, f"{name}.log")
        if os.path.exists(alog):
            try:
                lines = open(alog).readlines()
                if lines:
                    last_log = lines[-1].strip()
            except:
                pass
        result.append({
            "name": name,
            "status": status,
            "pid": pid,
            "has_script": os.path.exists(script),
            "last_log": last_log
        })
    return result

def get_snapshot():
    agents   = get_agents()
    up       = sum(1 for a in agents if a["status"] == "UP")
    down     = sum(1 for a in agents if a["status"] == "DOWN")
    no_pid   = sum(1 for a in agents if a["status"] == "NO_PID")
    pending  = len(glob.glob(os.path.join(TASKS, "*.json")))
    done     = len(glob.glob(os.path.join(TASKS, "*.done")))
    log_path = os.path.join(LOGS, "constellation25.log")
    log_lines, last_logs = 0, []
    if os.path.exists(log_path):
        with open(log_path) as f:
            ll = f.readlines()
            log_lines = len(ll)
            last_logs = [l.strip() for l in ll[-20:]]
    mpath = os.path.join(LOGS, "totalrecall_manifest.log")
    manifest_lines, last_manifest = 0, []
    if os.path.exists(mpath):
        with open(mpath) as f:
            ml = f.readlines()
            manifest_lines = len(ml)
            last_manifest  = [l.strip() for l in ml[-10:]]
    report = ""
    rpath = os.path.join(C25, "reports", "status_report.txt")
    if os.path.exists(rpath):
        report = open(rpath).read()
    return {
        "timestamp": ts(),
        "version": "25.0.0",
        "operator": "u0_a510",
        "agents": agents,
        "summary": {"up": up, "down": down, "no_pid": no_pid, "total": 25},
        "tasks": {"pending": pending, "done": done},
        "log": {"lines": log_lines, "recent": last_logs},
        "manifest": {"entries": manifest_lines, "recent": last_manifest},
        "mcp": "RUNNING",
        "report": report,
        "liftoff_sha": "ce188905c5ae4a5f4809dcf4669e666877f097850bb1942662d8830ff9060ec9",
        "build_date": "2026-03-07"
    }

def queue_task(agent, action, target="none"):
    now     = ts()
    task_id = f"task_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}_{agent}"
    tsha    = sha(f"{task_id}-{action}-{target}")
    task    = {"id":task_id,"agent":agent,"action":action,"target":target,
               "priority":1,"timestamp":now,"sha256":tsha,"status":"pending"}
    path = os.path.join(TASKS, f"{task_id}.json")
    with open(path,"w") as f:
        json.dump(task, f, indent=2)
    with open(os.path.join(LOGS,"totalrecall_manifest.log"),"a") as f:
        f.write(f"[{now}] [MCP] [QUEUE_TASK] SHA256:{tsha} agent:{agent} action:{action}\n")
    return task_id, tsha

# ── HTTP HANDLER ──────────────────────────────────────────────
class C25Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        log(f"HTTP {fmt % args}")

    def cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def do_OPTIONS(self):
        self.send_response(200)
        self.cors()
        self.end_headers()

    def do_GET(self):
        p = self.path.split("?")[0]
        if p == "/health":
            self._ok({"status":"ok","ts":ts(),"version":"25.0.0","operator":"u0_a510"})
        elif p == "/status":
            self._ok(get_snapshot())
        elif p == "/agents":
            self._ok(get_agents())
        elif p == "/log":
            lp = os.path.join(LOGS,"constellation25.log")
            lines = []
            if os.path.exists(lp):
                with open(lp) as f:
                    lines = [l.strip() for l in f.readlines()[-100:]]
            self._ok({"lines": lines})
        elif p == "/manifest":
            mp = os.path.join(LOGS,"totalrecall_manifest.log")
            entries = []
            if os.path.exists(mp):
                with open(mp) as f:
                    entries = [l.strip() for l in f.readlines()[-50:]]
            self._ok({"entries": entries})
        elif p == "/report":
            rp = os.path.join(C25,"reports","status_report.txt")
            text = open(rp).read() if os.path.exists(rp) else "No report yet."
            self._ok({"report": text})
        else:
            self._ok({"error":"not found"}, 404)

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body   = self.rfile.read(length) if length else b"{}"
        try:
            data = json.loads(body)
        except:
            data = {}
        p = self.path
        if p == "/task":
            agent  = data.get("agent","earth")
            action = data.get("action","ping")
            target = data.get("target","none")
            task_id, tsha = queue_task(agent, action, target)
            self._ok({"task_id": task_id, "sha256": tsha})
        elif p == "/message":
            msg   = data.get("message","")
            inbox = os.path.join(C25,"mercury_inbox")
            os.makedirs(inbox, exist_ok=True)
            fname = os.path.join(inbox,f"msg_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.msg")
            with open(fname,"w") as f:
                f.write(msg)
            self._ok({"queued": fname})
        else:
            self._ok({"error":"not found"}, 404)

    def _ok(self, data, code=200):
        body = json.dumps(data, indent=2).encode()
        self.send_response(code)
        self.cors()
        self.send_header("Content-Type","application/json")
        self.send_header("Content-Length", len(body))
        self.end_headers()
        self.wfile.write(body)

def http_server():
    server = HTTPServer(("0.0.0.0", 3000), C25Handler)
    log("HTTP server started on 0.0.0.0:3000")
    print(f"[{ts()}] [MCP] HTTP live on port 3000", flush=True)
    server.serve_forever()

def stdio_loop():
    log("stdio loop started")
    try:
        for line in sys.stdin:
            line = line.strip()
            if not line:
                continue
            try:
                req = json.loads(line)
            except:
                continue
            method = req.get("method","")
            req_id = req.get("id")
            if method == "initialize":
                resp = {"jsonrpc":"2.0","id":req_id,"result":{
                    "protocolVersion":"2024-11-05",
                    "capabilities":{"tools":{}},"serverInfo":{"name":"constellation25","version":"25.0.0"}}}
            elif method == "tools/list":
                resp = {"jsonrpc":"2.0","id":req_id,"result":{"tools":[]}}
            elif method == "tools/call":
                resp = {"jsonrpc":"2.0","id":req_id,"result":{"content":[{"type":"text","text":"ok"}]}}
            elif method == "notifications/initialized":
                continue
            else:
                resp = {"jsonrpc":"2.0","id":req_id,"error":{"code":-32601,"message":"unknown"}}
            sys.stdout.write(json.dumps(resp)+"\n")
            sys.stdout.flush()
    except:
        pass
    log("stdio loop ended — HTTP continues")

if __name__ == "__main__":
    # HTTP on non-daemon thread — keeps process alive
    t_http = threading.Thread(target=http_server, daemon=False)
    t_http.start()
    # stdio on daemon thread — dies on EOF, process stays up
    t_stdio = threading.Thread(target=stdio_loop, daemon=True)
    t_stdio.start()
    # Keep main thread alive
    try:
        while True:
            time.sleep(60)
    except KeyboardInterrupt:
        log("MCP server shutdown")
