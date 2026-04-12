const http = require('http');
const PORT = process.env.GATEWAY_PORT || 8080;
const PID_DIR = process.env.PID_DIR || process.env.HOME + '/constellation25/.pids';
const fs = require('fs'), path = require('path');

// Build port map from pid files
const getPorts = () => {
  const map = {};
  try {
    for (const f of fs.readdirSync(PID_DIR)) {
      if (f.endsWith('.pid')) {
        const repo = f.slice(0, -4);
        const log = fs.readFileSync(process.env.LOG_DIR + '/' + repo + '.log', 'utf8');
        const port = log.match(/Starting on :(\d+)/)?.[1];
        if (port) map[repo] = parseInt(port);
      }
    }
  } catch(e) {}
  return map;
};

http.createServer((req, res) => {
  const url = new URL(req.url, 'http://localhost');
  
  if (url.pathname === '/health') {
    res.writeHead(200, {'Content-Type': 'application/json'});
    return res.end(JSON.stringify({status:'ok', gateway:'c25-minimal'}));
  }
  
  if (url.pathname === '/discover') {
    const ports = getPorts();
    res.writeHead(200, {'Content-Type': 'application/json'});
    return res.end(JSON.stringify({
      gateway: 'c25-minimal',
      services: Object.entries(ports).map(([name, port]) => ({name, endpoint: `/api/${name}`, port}))
    }));
  }
  
  const m = url.pathname.match(/^\/api\/([^/]+)(\/.*)?$/);
  if (m) {
    const [, repo, subpath] = m;
    const ports = getPorts();
    const target = ports[repo];
    
    if (!target) {
      res.writeHead(404, {'Content-Type': 'application/json'});
      return res.end(JSON.stringify({error: `Service '${repo}' not running`}));
    }
    
    // Simple proxy
    const opts = {hostname:'localhost', port:target, path:subpath||'/', method:req.method, headers:req.headers};
    const preq = http.request(opts, pres => {
      res.writeHead(pres.statusCode, pres.headers);
      pres.pipe(res);
    });
    preq.on('error', e => {
      res.writeHead(502, {'Content-Type': 'application/json'});
      res.end(JSON.stringify({error: e.message}));
    });
    req.pipe(preq);
    return;
  }
  
  res.writeHead(404, {'Content-Type': 'application/json'});
  res.end(JSON.stringify({error: 'Not found'}));
}).listen(PORT, '0.0.0.0', () => {
  console.log(`🌐 Gateway ready: http://localhost:${PORT}`);
  console.log(`📍 Endpoints: /health, /discover, /api/{repo}/*`);
});
