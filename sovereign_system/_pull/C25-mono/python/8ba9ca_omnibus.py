#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import json, subprocess, os, datetime, threading

HOME = os.path.expanduser("~")
AGENTS = os.path.join(HOME, "agents")
CORPUS_DIR = os.path.join(HOME, ".c25", "agent-corpus")
GH_TOKEN = ""
try:
    for line in open(os.path.join(HOME, ".env.tokens")):
        if "GITHUB_TOKEN" in line or "GH_TOKEN" in line:
            GH_TOKEN = line.split("=",1)[1].strip().strip('"')
            break
except: pass

ROUTES = {
    "build":["earth-agent","luna-agent","sol-agent"],
    "deploy":["mars-agent","enceladus-agent"],
    "push":["mars-agent"],
    "parse":["mercury-agent"],
    "scan":["earth-agent"],
    "fix":["hydra-agent"],
    "pages":["enceladus-agent"],
    "status":["polaris-agent"],
    "faceprintpay":["rigel-agent"],
    "aimetaverse":["vega-agent"],
    "mybuyo":["bootes-agent"],
    "videocourts":["deneb-agent"],
    "sovereign":["titan-agent","sol-agent"],
    "ollama":["jupiter-agent"],
}

def get_context(agent):
    name = agent.replace("-agent","")
    for fname in os.listdir(CORPUS_DIR) if os.path.exists(CORPUS_DIR) else []:
        if fname.endswith("-context.txt"):
            if name in fname:
                try:
                    return open(os.path.join(CORPUS_DIR,fname),
                        errors='ignore').read(3000)
                except: pass
    return ""

def query_ollama(prompt):
    try:
        import urllib.request
        models_r = urllib.request.urlopen(
            "http://localhost:11434/api/tags", timeout=3)
        models = json.loads(models_r.read())
        model = models["models"][0]["name"] if models.get("models") else "llama3"
        payload = json.dumps({
            "model": model,
            "prompt": f"You are PaTHos-Sovereign-1 for Constellation25. Commander: MrGGTP / Cygel White. Task: {prompt}. Respond with exact bash commands to execute.",
            "stream": False
        }).encode()
        req = urllib.request.Request(
            "http://localhost:11434/api/generate",
            data=payload,
            headers={"Content-Type":"application/json"})
        r = urllib.request.urlopen(req, timeout=25)
        return json.loads(r.read())["response"]
    except Exception as e:
        return f"Ollama: {e}"

def run_agent(agent, prompt):
    script = os.path.join(AGENTS, f"{agent}.sh")
    if not os.path.exists(script):
        script = os.path.join(AGENTS, f"{agent}-agent.sh")
    if os.path.exists(script):
        try:
            env = os.environ.copy()
            env["C25_PROMPT"] = prompt
            env["GH_TOKEN"] = GH_TOKEN
            r = subprocess.run(["bash", script],
                capture_output=True, text=True,
                timeout=60, env=env)
            return r.stdout[-500:] + r.stderr[-200:]
        except Exception as e:
            return str(e)
    return f"Agent not found: {agent}"

class Handler(BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin","*")
        self.send_header("Access-Control-Allow-Methods","GET,POST")
        self.send_header("Access-Control-Allow-Headers","Content-Type")
        self.end_headers()
    def do_GET(self):
        if self.path == "/health":
            self.reply({"status":"ok",
                "system":"C25-Omnibus",
                "operator":"Cygel White / MrGGTP",
                "corpus":"121MB loaded",
                "agents":len(os.listdir(AGENTS)) if os.path.exists(AGENTS) else 0,
                "ts":str(datetime.datetime.now())})
        elif self.path == "/agents":
            agents = sorted([f.replace(".sh","")
                for f in os.listdir(AGENTS)
                if f.endswith(".sh")]) if os.path.exists(AGENTS) else []
            self.reply({"agents":agents,"count":len(agents)})
        else:
            self.reply({"error":"unknown"}, 404)
    def do_POST(self):
        length = int(self.headers.get("Content-Length",0))
        body = json.loads(self.rfile.read(length) or b"{}")
        prompt = body.get("prompt","")
        action = body.get("action","prompt")
        if action == "prompt" and prompt:
            # Route to agents
            agents = []
            for kw, alist in ROUTES.items():
                if kw in prompt.lower():
                    agents.extend(alist)
            if not agents:
                agents = ["luna-agent","sol-agent"]
            agents = list(dict.fromkeys(agents))[:3]
            # Ollama intelligence
            ollama = query_ollama(prompt)
            # Run agents parallel
            results = {}
            def run(a):
                results[a] = run_agent(a, prompt)
            threads = [threading.Thread(target=run,args=(a,)) for a in agents]
            [t.start() for t in threads]
            [t.join(timeout=65) for t in threads]
            self.reply({
                "prompt": prompt,
                "agents": agents,
                "ollama": ollama[:600],
                "results": results,
                "ts": str(datetime.datetime.now())
            })
        elif action == "bash":
            cmd = body.get("cmd","")
            try:
                r = subprocess.run(cmd, shell=True,
                    capture_output=True, text=True, timeout=120)
                self.reply({"output":(r.stdout+r.stderr)[-2000:],
                    "code":r.returncode})
            except Exception as e:
                self.reply({"error":str(e)})
        else:
            self.reply({"error":"unknown action"})
    def reply(self, data, code=200):
        body = json.dumps(data,indent=2).encode()
        self.send_response(code)
        self.send_header("Content-Type","application/json")
        self.send_header("Access-Control-Allow-Origin","*")
        self.send_header("Content-Length",len(body))
        self.end_headers()
        self.wfile.write(body)

if __name__ == "__main__":
    import sys
    port = int(sys.argv[1]) if len(sys.argv)>1 else 9000
    print(f"[OMNIBUS] Port {port} | C25 v25.0.0 | MrGGTP")
    HTTPServer(("0.0.0.0", port), Handler).serve_forever()
