#!/usr/bin/env bash
set -euo pipefail

say(){ printf "[%s] %s\n" "$(date +'%H:%M:%S')" "$*"; }
die(){ echo "ERROR: $*" >&2; exit 1; }

REPO="$HOME/Kre8tiveKonceptz_RepoDepo"
WEB_DIR="$HOME/outputs/web/agi-kre8tive"
HTML="$WEB_DIR/index.html"

API_APP="$HOME/SOVEREIGN_VAULT/Z-36/ai-kre8tive-stargate/builds/code_gen/output.py"
API_URL="http://127.0.0.1:8000"
WEB_URL="http://127.0.0.1:8765/index.html"

need(){ command -v "$1" >/dev/null 2>&1 || die "Missing $1"; }
need python
need grep
need sed

[ -f "$API_APP" ] || die "API app not found: $API_APP"
[ -f "$HTML" ] || die "Landing page not found: $HTML"

say "1) Patch FastAPI for CORS + /metrics …"

# Only patch once (idempotent)
if ! grep -q "BEGIN_REPODEPO_DEMO_PATCH" "$API_APP"; then
  tmp="$(mktemp)"
  awk '
    BEGIN{patched=0}
    {print}
  ' "$API_APP" > "$tmp"

  # Insert imports + middleware + metrics right after FastAPI app creation line
  # We’ll do this with a simple sed block around `app = FastAPI(`
  sed -i '
/^app = FastAPI/ a\
\
# BEGIN_REPODEPO_DEMO_PATCH\
from fastapi.middleware.cors import CORSMiddleware\
from threading import Lock\
\
_demo_lock = Lock()\
_demo_rotations = 0\
_demo_last_rotation = None\
\
app.add_middleware(\
    CORSMiddleware,\
    allow_origins=["http://127.0.0.1:8765","http://localhost:8765"],\
    allow_credentials=True,\
    allow_methods=["*"],\
    allow_headers=["*"],\
)\
\
@app.get("/metrics")\
def metrics():\
    global _demo_rotations, _demo_last_rotation\
    with _demo_lock:\
        return {\
            "rotations_total": _demo_rotations,\
            "last_rotation_at": _demo_last_rotation,\
        }\
# END_REPODEPO_DEMO_PATCH\
' "$tmp"

  # Increment metrics inside rotate_key before returning
  # Add just before `return KeyRotationResponse(`
  sed -i '
/return KeyRotationResponse\(/ i\
        global _demo_rotations, _demo_last_rotation\
        with _demo_lock:\
            _demo_rotations += 1\
            _demo_last_rotation = datetime.now().isoformat()\
' "$tmp"

  mv "$tmp" "$API_APP"
fi

say "2) Restart API (port 8000) …"
# stop any old instance
pkill -f "python .*builds/code_gen/output\.py" 2>/dev/null || true
nohup python "$API_APP" > "$REPO/logs/uvicorn_key_rotation.log" 2>&1 &
sleep 0.6

say "3) Patch landing page with Live Demo panel …"

if ! grep -q "id=\"live-demo\"" "$HTML"; then
  INSERT_BLOCK='
  <!-- Live Demo Panel -->
  <section id="live-demo" class="mt-10">
    <div class="rounded-2xl border border-white/10 bg-white/5 p-4 backdrop-blur">
      <div class="flex items-center justify-between gap-3">
        <div>
          <h3 class="text-lg font-semibold text-white">Live Demo: Key Rotation API</h3>
          <p class="text-sm text-white/70">Browser → FastAPI on <span class="font-mono">127.0.0.1:8000</span></p>
        </div>
        <span id="demoStatus" class="text-xs rounded-full bg-white/10 px-3 py-1 text-white/80">idle</span>
      </div>

      <div class="mt-4 flex flex-col gap-2 sm:flex-row">
        <button id="btnPing" class="rounded-xl bg-white text-black px-4 py-2 text-sm font-semibold hover:opacity-90">
          Ping /
        </button>
        <button id="btnRotate" class="rounded-xl bg-indigo-500 text-white px-4 py-2 text-sm font-semibold hover:opacity-90">
          POST /rotate-key
        </button>
        <button id="btnMetrics" class="rounded-xl bg-white/10 text-white px-4 py-2 text-sm font-semibold hover:bg-white/15">
          GET /metrics
        </button>
      </div>

      <div class="mt-4 grid gap-3 md:grid-cols-2">
        <div class="rounded-xl bg-black/30 p-3 border border-white/10">
          <div class="text-xs text-white/70 mb-2">Response</div>
          <pre id="demoOut" class="text-xs text-white/90 overflow-auto max-h-64 font-mono whitespace-pre-wrap">{"ready": true}</pre>
        </div>
        <div class="rounded-xl bg-black/30 p-3 border border-white/10">
          <div class="text-xs text-white/70 mb-2">Quick Metrics</div>
          <div class="text-sm text-white/90">
            <div class="flex items-center justify-between"><span class="text-white/70">rotations_total</span><span id="mRot" class="font-mono">—</span></div>
            <div class="flex items-center justify-between mt-2"><span class="text-white/70">last_rotation_at</span><span id="mLast" class="font-mono text-right">—</span></div>
          </div>
        </div>
      </div>

      <p class="mt-3 text-xs text-white/60">
        If you see CORS errors, refresh after the script restarts the API.
      </p>
    </div>
  </section>

  <script>
    const API = "http://127.0.0.1:8000";
    const s = (id)=>document.getElementById(id);
    const setStatus = (t)=>{ s("demoStatus").textContent=t; };
    const show = (obj)=>{ s("demoOut").textContent = JSON.stringify(obj, null, 2); };

    async function jget(path){
      const r = await fetch(API + path);
      const j = await r.json();
      if(!r.ok) throw j;
      return j;
    }
    async function jpost(path, body){
      const r = await fetch(API + path, {
        method:"POST",
        headers:{ "content-type":"application/json" },
        body: JSON.stringify(body)
      });
      const j = await r.json();
      if(!r.ok) throw j;
      return j;
    }

    async function refreshMetrics(){
      const m = await jget("/metrics");
      s("mRot").textContent = m.rotations_total;
      s("mLast").textContent = m.last_rotation_at || "—";
      return m;
    }

    s("btnPing").onclick = async ()=>{
      try{
        setStatus("pinging…");
        const j = await jget("/");
        show(j);
        setStatus("ok");
      }catch(e){
        show(e);
        setStatus("error");
      }
    };

    s("btnRotate").onclick = async ()=>{
      try{
        setStatus("rotating…");
        const j = await jpost("/rotate-key", { service_name:"RepoDepo", key_type:"api_key" });
        show(j);
        await refreshMetrics();
        setStatus("ok");
      }catch(e){
        show(e);
        setStatus("error");
      }
    };

    s("btnMetrics").onclick = async ()=>{
      try{
        setStatus("metrics…");
        const m = await refreshMetrics();
        show(m);
        setStatus("ok");
      }catch(e){
        show(e);
        setStatus("error");
      }
    };

    // auto-load metrics once
    refreshMetrics().catch(()=>{});
  </script>
'

  # Insert before </body>
  awk -v ins="$INSERT_BLOCK" '
    {print}
    tolower($0) ~ /<\/body>/ && !done {print ins; done=1}
  ' "$HTML" > "$HTML.tmp" && mv "$HTML.tmp" "$HTML"
fi

say "4) Ensure web server is up on :8765 …"
# Kill any old server on 8765
pkill -f "python -m http.server 8765" 2>/dev/null || true
nohup python -m http.server 8765 --directory "$WEB_DIR" > "$REPO/logs/web_8765.log" 2>&1 &
sleep 0.4

say "✅ Done."
say "Open: $WEB_URL"
