#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ts(){ date +'%H:%M:%S'; }
say(){ echo "[$(ts)] $*"; }

WEB_DIR="$HOME/outputs/web/agi-kre8tive"
HTML="$WEB_DIR/index.html"
REPO="$HOME/Kre8tiveKonceptz_RepoDepo"
WEB_PORT="8765"

API_URL="http://127.0.0.1:8000"

[ -f "$HTML" ] || { echo "Missing: $HTML"; exit 1; }

say "1) Re-patching Live Demo JS safely…"

python - <<'PY'
import re
from pathlib import Path

html_path = Path.home() / "outputs/web/agi-kre8tive/index.html"
API_URL = "http://127.0.0.1:8000"

html = html_path.read_text(encoding="utf-8")

js = f"""
<script id="AGI_KRE8TIVE_BACKEND_TIEIN">
(() => {{
  const API = "{API_URL}";

  const el = (id) => document.getElementById(id);

  const apiLight   = el("apiLight");
  const apiStatus  = el("apiStatus");
  const metricsBox = el("metricsBox");
  const rotateBox  = el("rotateBox");
  const btnRefresh = el("btnRefresh");
  const btnRotate  = el("btnRotate");

  async function getJSON(url, opts) {{
    const res = await fetch(url, opts);
    if (!res.ok) throw new Error(res.status + " " + res.statusText);
    return await res.json();
  }}

  async function ping() {{
    try {{
      await getJSON(API + "/health");
      if (apiLight) apiLight.style.background = "#22c55e";
      if (apiStatus) apiStatus.textContent = "API online";
      return true;
    }} catch (e) {{
      if (apiLight) apiLight.style.background = "#ef4444";
      if (apiStatus) apiStatus.textContent = "API offline";
      return false;
    }}
  }}

  async function loadMetrics() {{
    if (metricsBox) metricsBox.textContent = "loading…";
    try {{
      const data = await getJSON(API + "/metrics");
      if (metricsBox) metricsBox.textContent = JSON.stringify(data, null, 2);
    }} catch (e) {{
      if (metricsBox) metricsBox.textContent = "metrics error: " + e.message;
    }}
  }}

  async function rotateKey() {{
    if (rotateBox) rotateBox.textContent = "working…";
    try {{
      const payload = {{ service_name: "RepoDepo", key_type: "api_key" }};
      const data = await getJSON(API + "/rotate-key", {{
        method: "POST",
        headers: {{ "content-type": "application/json" }},
        body: JSON.stringify(payload)
      }});
      if (rotateBox) rotateBox.textContent = JSON.stringify(data, null, 2);
    }} catch (e) {{
      if (rotateBox) rotateBox.textContent = "rotate error: " + e.message;
    }}
  }}

  btnRefresh?.addEventListener("click", loadMetrics);
  btnRotate?.addEventListener("click", rotateKey);

  (async () => {{
    await ping();
    await loadMetrics();
    setInterval(ping, 4000);
  }})();
}})();
</script>
"""

# Replace existing block if present, else append before </body>
if 'id="AGI_KRE8TIVE_BACKEND_TIEIN"' in html:
    html = re.sub(
        r'<script id="AGI_KRE8TIVE_BACKEND_TIEIN">.*?</script>',
        js,
        html,
        flags=re.S
    )
else:
    html = html.replace("</body>", js + "\n</body>")

html_path.write_text(html, encoding="utf-8")
print("Fixed JS in:", html_path)
PY

say "2) Restarting web server on :$WEB_PORT …"
pkill -f "python -m http.server $WEB_PORT" 2>/dev/null || true
mkdir -p "$REPO/logs"
nohup python -m http.server "$WEB_PORT" --directory "$WEB_DIR" > "$REPO/logs/web_${WEB_PORT}.log" 2>&1 &
sleep 0.25

say "✅ Done."
say "Open: http://127.0.0.1:${WEB_PORT}/index.html"
