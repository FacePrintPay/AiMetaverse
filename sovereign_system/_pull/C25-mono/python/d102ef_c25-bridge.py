#!/usr/bin/env python3
"""🌌 Constellation 25 Bridge — Termux ↔ Dashboard"""
import http.server,socketserver,urllib.parse,subprocess,os,json,signal
AGENT_DIR=os.path.expanduser("~/constellation25/agents")
PORT=int(os.environ.get("C25_PORT",8080))
CORS={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"POST,GET,OPTIONS","Access-Control-Allow-Headers":"Content-Type"}
class H(http.server.BaseHTTPRequestHandler):
    protocol_version="HTTP/1.1"
    def _r(self,c=200,b=b"",t="text/plain"):
        self.send_response(c);self.send_header("Content-Type",t)
        for k,v in CORS.items():self.send_header(k,v)
        self.send_header("Content-Length",str(len(b)));self.end_headers()
        if b:self.wfile.write(b)
    def do_OPTIONS(self):self._r(204)
    def do_GET(self):
        p=urllib.parse.urlparse(self.path).path
        if p=="/health":self._r(200,b'{"status":"ok"}',"application/json")
        elif p=="/agents":
            a=[f.replace("-agent.sh","") for f in os.listdir(AGENT_DIR) if f.endswith("-agent.sh") and os.access(f"{AGENT_DIR}/{f}",os.X_OK)]
            self._r(200,json.dumps({"agents":a}).encode(),"application/json")
        else:self._r(404,b"Not found")
    def do_POST(self):
        p=urllib.parse.urlparse(self.path).path
        if p not in["/exec","/execute"]:self._r(404,b"POST /exec only");return
        l=int(self.headers.get("Content-Length",0));b=self.rfile.read(l).decode() if l else ""
        try:d=json.loads(b) if b.startswith("{") else dict(urllib.parse.parse_qsl(b));ag=d.get("agent","").lower().replace("-agent","");cmd=d.get("cmd","")
        except:ag=cmd=""
        if not ag:self._r(400,b"Missing agent");return
        s=f"{AGENT_DIR}/{ag}-agent.sh"
        if os.path.isfile(s) and os.access(s,os.X_OK):
            try:r=subprocess.run([s]+cmd.split(),capture_output=True,text=True,timeout=30,cwd=os.path.expanduser("~"));o=r.stdout+r.stderr;cd=200 if r.returncode==0 else 500
            except Exception as e:o=f"Error:{e}";cd=500
        else:o=f"Not found:{s}";cd=404
        self._r(cd,o.encode())
    def log_message(self,*a):pass
def shutdown(*_):exit(0)
signal.signal(signal.SIGINT,shutdown);signal.signal(signal.SIGTERM,shutdown)
if __name__=="__main__":
    socketserver.TCPServer.allow_reuse_address=True
    with socketserver.TCPServer(("",PORT),H) as httpd:print(f"🌌 Bridge on {PORT}",flush=True);httpd.serve_forever()
