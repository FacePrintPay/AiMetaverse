#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ts(){ date +'%H:%M:%S'; }
say(){ echo "[$(ts)] $*"; }
die(){ echo "[ERROR] $*" >&2; exit 1; }

REPO="$HOME/Kre8tiveKonceptz_RepoDepo"
WEB_DIR="$HOME/outputs/web/agi-kre8tive"
HTML="$WEB_DIR/index.html"

VAULT="$HOME/SOVEREIGN_VAULT/Z-36/ai-kre8tive-stargate"
APP="$VAULT/builds/code_gen/output.py"

API_URL="http://127.0.0.1:8000"
WEB_PORT="8765"
WEB_URL="http://127.0.0.1:${WEB_PORT}/index.html"

command -v python >/dev/null || die "python missing"
command -v curl >/dev/null || die "curl missing"

[ -f "$APP" ]  || die "Missing app: $APP"
[ -f "$HTML" ] || die "Missing HTML: $HTML"

say "1) Patch FastAPI for CORS + /health + /metrics …"

python - <<PY
import re, pathlib

p = pathlib.Path("$APP")
s = p.read_text(encoding="utf-8")

# Ensure imports
if "from fastapi.middleware.cors import CORSMiddleware" not in s:
    s = s.replace("from fastapi import FastAPI, HTTPException",
                  "from fastapi import FastAPI, HTTPException\nfrom fastapi.middleware.cors import CORSMiddleware")

# Add CORS middleware after app = FastAPI(...)
if "app.add_middleware(CORSMiddleware" not in s:
    s = re.sub(r"(app\s*=\s*FastAPI\\([^\\)]*\\)\\s*)",
               r"\\1\n\n# CORS for local demo (Termux + browser)\napp.add_middleware(\n    CORSMiddleware,\n    allow_origins=['*'],\n    allow_credentials=True,\n    allow_methods=['*'],\n    allow_headers=['*'],\n)\n",
               s, count=1)

# Add /health endpoint if missing
if 'def health()' not in s and '@app.get("/health")' not in s:
    insert_after = '@app.get("/")'
    idx = s.find(insert_after)
    if idx != -1:
        # Insert after root endpoint block end: crude but safe enough for this generated app
        s += "\n\n@app.get('/health')\ndef health():\n    return {'ok': True}\n"
    else:
        s += "\n\n@app.get('/health')\ndef health():\n    return {'ok': True}\n"

# Add /metrics endpoint if missing
if '@app.get("/metrics")' not in s and "@app.get('/metrics')" not in s:
    s += "\n\n@app.get('/metrics')\ndef metrics():\n    # lightweight placeholder metrics (wire real RateLimitMetrics later)\n    return {\n        'service': 'agi-kre8tive',\n        'allowed': 0,\n        'blocked': 0,\n        'rps': 0.0,\n        'ts': __import__('datetime').datetime.now().isoformat()\n    }\n"

p.write_text(s, encoding="utf-8")
print("Patched:", p)
PY

say "2) Patch landing page with Live Demo panel + JS calls …"

python - <<PY
import pathlib, re

p = pathlib.Path("$HTML")
html = p.read_text(encoding="utf-8")

# Inject panel near top (after hero buttons if we can)
panel = f"""
<!-- LIVE DEMO PANEL (Backend tie-in) -->
<section id="live-demo" style="margin-top:24px;">
  <div style="
    border:1px solid rgba(255,255,255,0.08);
    background: rgba(0,0,0,0.25);
    backdrop-filter: blur(10px);
    border-radius: 16px;
    padding: 16px;
  ">
    <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;">
      <div>
        <div style="font-weight:700;">Live Demo</div>
        <div style="opacity:.8;font-size:12px;">Frontend → FastAPI @ <span id="apiUrl">{ "$API_URL" }</span></div>
      </div>
      <div style="display:flex;align-items:center;gap:10px;">
        <span id="apiLight" style="width:10px;height:10px;border-radius:999px;background:#666;display:inline-block;"></span>
        <span id="apiStatus" style="font-size:12px;opacity:.9;">checking…</span>
      </div>
    </div>

    <div style="margin-top:14px;display:grid;grid-template-columns:1fr;gap:12px;">
      <div>
        <div style="font-size:12px;opacity:.8;margin-bottom:6px;">Metrics</div>
        <pre id="metricsBox" style="white-space:pre-wrap;word-break:break-word;font-size:12px;line-height:1.35;
          background: rgba(255,255,255,0.05); padding:10px;border-radius:12px; border:1px solid rgba(255,255,255,0.06);
        ">{{}}</pre>
        <div style="display:flex;gap:10px;margin-top:10px;flex-wrap:wrap;">
          <button id="btnRefresh" style="padding:10px 12px;border-radius:12px;border:1px solid rgba(255,255,255,0.12);
            background: rgba(255,255,255,0.06);">Refresh metrics</button>
          <button id="btnRotate" style="padding:10px 12px;border-radius:12px;border:1px solid rgba(255,255,255,0.18);
            background: rgba(255,255,255,0.10); font-weight:700;">Rotate API key</button>
        </div>
      </div>

      <div>
        <div style="font-size:12px;opacity:.8;margin-bottom:6px;">Rotate-key output</div>
        <pre id="rotateBox" style="white-space:pre-wrap;word-break:break-word;font-size:12px;line-height:1.35;
          background: rgba(255,255,255,0.05); padding:10px;border-radius:12px; border:1px solid rgba(255,255,255,0.06);
        ">{{}}</pre>
      </div>
    </div>
  </div>
</section>
"""

# Add panel only once
if "LIVE DEMO PANEL" not in html:
    # Try to inject after first big CTA button area; fallback to end of body
    m = re.search(r"(Get Started Now.*?</button>.*?</div>)", html, flags=re.S|re.I)
    if m:
        html = html[:m.end()] + panel + html[m.end():]
    else:
        html = html.replace("</body>", panel + "\n</body>")

# Inject JS only once
if "AGI_KRE8TIVE_BACKEND_TIEIN" not in html:
    js = f"""
<script id="AGI_KRE8TIVE_BACKEND_TIEIN">
(() => {{
  const API = "{ "$API_URL" }";
  const $ = (id) => document.getElementById(id);

  const apiLight = $("apiLight");
  const apiStatus = $("apiStatus");
  const metricsBox = $("metricsBox");
  const rotateBox = $("rotateBox");
  const btnRefresh = $("btnRefresh");
  const btnRotate = $("btnRotate");

  async function getJSON(url, opts) {{
    const res = await fetch(url, opts);
    if (!res.ok) throw new Error(res.status + " " + res.statusText);
    return await res.json();
  }}

  async function ping() {{
    try {{
      await getJSON(API + "/health");
      apiLight.style.background = "#22c55e";
      apiStatus.textContent = "API online";
      return true;
    }} catch (e) {{
      apiLight.style.background = "#ef4444";
      apiStatus.textContent = "API offline";
      return false;
    }}
  }}

  async function loadMetrics() {{
    try {{
      const data = await getJSON(API + "/metrics");
      metricsBox.textContent = JSON.stringify(data, null, 2);
    }} catch (e) {{
      metricsBox.textContent = "metrics error: " + e.message;
    }}
  }}

  async function rotateKey() {{
    rotateBox.textContent = "working…";
    try {{
      const payload = {{ service_name: "RepoDepo", key_type: "api_key" }};
      const data = await getJSON(API + "/rotate-key", {{
        method: "POST",
        headers: {{ "content-type": "application/json" }},
        body: JSON.stringify(payload)
      }});
      rotateBox.textContent = JSON.stringify(data, null, 2);
    }} catch (e) {{
      rotateBox.textContent = "rotate error: " + e.message;
    }}
  }}

  btnRefresh?.addEventListener("click", loadMetrics);
  btnRotate?.addEventListener("click", rotateKey);

  (async () => {{
    await ping();
    await loadMetrics();
    setInterval(async () => {{
      await ping();
    }}, 4000);
  }})();
}})();
</script>
"""
    html = html.replace("</body>", js + "\n</body>")

p.write_text(html, encoding="utf-8")
print("Patched:", p)
PY

say "3) Restart API (port 8000) …"
pkill -f "python .*builds/code_gen/output\.py" 2>/dev/null || true
nohup python "$APP" > "$REPO/logs/uvicorn_key_rotation.log" 2>&1 &
sleep 0.6

say "4) Ensure web server is up on :$WEB_PORT …"
pkill -f "python -m http.server $WEB_PORT" 2>/dev/null || true
mkdir -p "$REPO/logs"
nohup python -m http.server "$WEB_PORT" --directory "$WEB_DIR" > "$REPO/logs/web_${WEB_PORT}.log" 2>&1 &
sleep 0.3

say "✅ Backend tie-in done."
say "Open: $WEB_URL"
