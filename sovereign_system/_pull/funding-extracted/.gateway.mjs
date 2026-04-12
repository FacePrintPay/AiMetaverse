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
