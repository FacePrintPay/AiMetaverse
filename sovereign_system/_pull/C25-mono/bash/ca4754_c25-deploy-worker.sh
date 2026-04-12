#!/data/data/com.termux/files/usr/bin/bash
# c25-deploy-worker.sh — Minimal working deploy (ES Module Fixed)
set -euo pipefail

C25_ROOT="${C25_ROOT:-$HOME/constellation25}"
BASE_PORT=3001
PID_DIR="$C25_ROOT/.pids"
LOG_DIR="$C25_ROOT/.logs"
GATEWAY_PORT=8080

mkdir -p "$PID_DIR" "$LOG_DIR"

start_repo() {
  local repo="$1" port="$2" path="$C25_ROOT/$repo"
  [[ ! -d "$path" ]] && return 1
  [[ -f "$PID_DIR/$repo.pid" ]] && kill $(cat "$PID_DIR/$repo.pid") 2>/dev/null || true
  (
    cd "$path"
    export PORT="$port" REPO_NAME="$repo"
    echo "[$(date)] [$repo] Starting on :$port" >> "$LOG_DIR/$repo.log"
    exec python3 -c "
import http.server, socketserver, os, sys, json
PORT=int(os.environ.get('PORT',3000));REPO=os.environ.get('REPO_NAME','unknown')
class H(http.server.SimpleHTTPRequestHandler):
  def do_GET(self):
    if self.path=='/health':
      self.send_response(200);self.send_header('Content-Type','application/json');self.end_headers()
      self.wfile.write(json.dumps({'status':'ok','repo':REPO}).encode());return
    if self.path=='/':
      self.send_response(200);self.send_header('Content-Type','text/html');self.end_headers()
      self.wfile.write(b'<h1>'+REPO.encode()+b'</h1><p>Port: '+str(PORT).encode()+b'</p>');return
    return super().do_GET()
  def log_message(self,f,*a):sys.stderr.write(f'[{REPO}] {f%a}\\n')
socketserver.TCPServer(('',PORT),H).serve_forever()
" >> "$LOG_DIR/$repo.log" 2>&1
  ) &
  echo $! > "$PID_DIR/$repo.pid"
  echo "✅ Started $repo on :$port (PID $!)"
}

start_all() {
  echo "🚀 Deploying local workers..."
  local port=$BASE_PORT
  for repo_dir in "$C25_ROOT"/*/; do
    local repo=$(basename "$repo_dir")
    [[ "$repo" == ".*" || ! -d "$repo_dir/.git" ]] && continue
    start_repo "$repo" "$port" && port=$((port + 1))
  done
  echo "✅ Workers started. Ports: $BASE_PORT-$((port-1))"
}

stop_all() {
  echo "🛑 Stopping..."
  for pidfile in "$PID_DIR"/*.pid; do
    [[ ! -f "$pidfile" ]] && continue
    local repo=$(basename "$pidfile" .pid) pid=$(cat "$pidfile")
    kill "$pid" 2>/dev/null && echo "⏹️  Stopped $repo" || true
    rm -f "$pidfile"
  done
  [[ -f "$PID_DIR/.gateway.pid" ]] && kill $(cat "$PID_DIR/.gateway.pid") 2>/dev/null && rm -f "$PID_DIR/.gateway.pid"
  echo "✅ All stopped"
}

status_all() {
  echo "📊 Status:"
  for pidfile in "$PID_DIR"/*.pid; do
    [[ ! -f "$pidfile" || "$(basename "$pidfile")" == ".gateway.pid" ]] && continue
    local repo=$(basename "$pidfile" .pid) pid=$(cat "$pidfile")
    kill -0 "$pid" 2>/dev/null && echo "✅ $repo" || echo "❌ $repo (dead)"
  done
  [[ -f "$PID_DIR/.gateway.pid" ]] && kill -0 $(cat "$PID_DIR/.gateway.pid") 2>/dev/null && echo "✅ Gateway" || echo "❌ Gateway"
}

start_gateway() {
  echo "🌐 Starting gateway on :$GATEWAY_PORT..."
  cat > "$C25_ROOT/.gateway.mjs" << 'GATEWAY'
import http from 'http';
import fs from 'fs';
import path from 'path';
const PORT = parseInt(process.env.GATEWAY_PORT) || 8080;
const PID_DIR = process.env.PID_DIR || path.join(process.env.HOME || '', 'constellation25', '.pids');
const LOG_DIR = process.env.LOG_DIR || path.join(process.env.HOME || '', 'constellation25', '.logs');
const getPorts = () => {
  const map = {};
  try {
    for (const f of fs.readdirSync(PID_DIR)) {
      if (f.endsWith('.pid') && !f.startsWith('.')) {
        const repo = f.slice(0, -4);
        const log = fs.readFileSync(path.join(LOG_DIR, repo + '.log'), 'utf8');
        const m = log.match(/Starting on :(\d+)/);
        if (m) map[repo] = parseInt(m[1]);
      }
    }
  } catch(e) {}
  return map;
};
http.createServer((req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  if (url.pathname === '/health') {
    res.writeHead(200, {'Content-Type': 'application/json'});
    return res.end(JSON.stringify({status:'ok', gateway:'c25-minimal'}));
  }
  if (url.pathname === '/discover') {
    const ports = getPorts();
    res.writeHead(200, {'Content-Type': 'application/json'});
    return res.end(JSON.stringify({gateway:'c25-minimal', services:Object.entries(ports).map(([n,p])=>({name:n,endpoint:`/api/${n}`,port:p}))}));
  }
  const m = url.pathname.match(/^\/api\/([^/]+)(\/.*)?$/);
  if (m) {
    const [,repo,subpath] = m;
    const ports = getPorts();
    const target = ports[repo];
    if (!target) { res.writeHead(404,{'Content-Type':'application/json'}); return res.end(JSON.stringify({error:`Service '${repo}' not running`})); }
    const opts = {hostname:'localhost',port:target,path:subpath||'/',method:req.method,headers:{...req.headers,host:`localhost:${target}`}};
    const preq = http.request(opts, pres => { res.writeHead(pres.statusCode,pres.headers); pres.pipe(res); });
    preq.on('error', e => { res.writeHead(502,{'Content-Type':'application/json'}); res.end(JSON.stringify({error:e.message})); });
    req.pipe(preq); return;
  }
  res.writeHead(404,{'Content-Type':'application/json'}); res.end(JSON.stringify({error:'Not found'}));
}).listen(PORT, '0.0.0.0', () => console.log(`🌐 Gateway: http://localhost:${PORT}`));
GATEWAY
  export GATEWAY_PORT PID_DIR LOG_DIR
  node "$C25_ROOT/.gateway.mjs" &
  echo $! > "$PID_DIR/.gateway.pid"
  echo "✅ Gateway started (PID $(cat "$PID_DIR/.gateway.pid"))"
}

case "${1:-start}" in
  start) start_all; start_gateway ;;
  stop) stop_all ;;
  status) status_all ;;
  *) echo "Usage: $0 {start|stop|status}"; exit 1 ;;
esac
