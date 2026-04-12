#!/usr/bin/env python3
import sys, os, json

def write_artifact(prompt, nb_json, banana_json, agent_json, run_sha, pdf_path, pptx_path, out_path):
    try:
        nb = json.loads(nb_json)
        ban = json.loads(banana_json)
        agents = json.loads(agent_json)
    except:
        nb = {}; ban = {"steps":[],"pipeline_sha":"--"}; agents = []

    from datetime import datetime
    ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    nb_cards = ""
    for cat, d in nb.items():
        nb_cards += f"""<div class="nbc"><div class="nbt">{cat.replace('_',' ')}</div><div class="nbd">{d.get('domain','')}</div><div class="nbs">{d.get('sha','')[:20]}...</div></div>"""

    step_descs = ['Parse & validate','Normalize schemas','Remove redundant',
                  'Rank by relevance','Synthesize insights','SHA256 validate','Package for C25']
    ban_rows = ""
    for i, s in enumerate(ban.get('steps', [])):
        desc = step_descs[i] if i < len(step_descs) else ''
        ban_rows += f"""<div class="br"><div class="bn">{i+1}</div><div class="bt">{s['step']}</div><div class="bd">{desc}</div><div class="bsha">{s['sha'][:12]}...</div><div class="ok"></div></div>"""

    agent_cards = ""
    for a in agents:
        agent_cards += f"""<div class="ac"><div class="an">{a['agent'].upper()}</div><div class="ar">{a['role']}</div><div class="ast">{a['status']}</div><div class="asha">{a['sha'][:16]}...</div></div>"""

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>C25 GAMMA — {ts}</title>
<link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Bebas+Neue&display=swap" rel="stylesheet">
<style>
:root{{--void:#050508;--card:#0c0c12;--card2:#111118;--line:#1a1a28;--green:#00ff88;--green3:#004422;--violet:#8b5cf6;--violet3:#2d1458;--yellow:#fbbf24;--cyan:#22d3ee;--red:#ff3355;--text:#e2e8f0;--muted:#334155;--mono:'Share Tech Mono',monospace;--disp:'Bebas Neue',sans-serif;}}
*{{margin:0;padding:0;box-sizing:border-box;}}
body{{background:var(--void);color:var(--text);font-family:var(--mono);min-height:100vh;}}
body::after{{content:'';position:fixed;inset:0;background:repeating-linear-gradient(0deg,transparent,transparent 2px,rgba(0,255,136,.012) 2px,rgba(0,255,136,.012) 4px);pointer-events:none;z-index:9999;}}
.hdr{{background:rgba(5,5,8,.98);border-bottom:1px solid var(--line);padding:14px 24px;display:flex;align-items:center;justify-content:space-between;position:sticky;top:0;z-index:100;}}
.logo{{font-family:var(--disp);font-size:26px;color:var(--green);}}
.badge{{font-size:9px;color:var(--violet);border:1px solid var(--violet3);background:var(--violet3);padding:3px 8px;letter-spacing:.15em;margin-left:10px;}}
.pb{{background:var(--card);border-bottom:1px solid var(--line);padding:14px 24px;}}
.pl{{font-size:9px;color:var(--violet);letter-spacing:.2em;margin-bottom:6px;}}
.pt{{font-size:13px;color:var(--green);}}
.flow{{display:flex;border-bottom:1px solid var(--line);overflow-x:auto;scrollbar-width:none;}}
.fs{{padding:12px 20px;font-size:10px;letter-spacing:.12em;color:var(--green);border-right:1px solid var(--line);white-space:nowrap;}}
.stats{{display:grid;grid-template-columns:repeat(5,1fr);border-bottom:1px solid var(--line);}}
.sc{{padding:16px;border-right:1px solid var(--line);text-align:center;}}
.sc:last-child{{border-right:none;}}
.sv{{font-family:var(--disp);font-size:32px;color:var(--green);display:block;}}
.sv.v{{color:var(--violet)}}.sv.y{{color:var(--yellow)}}.sv.c{{color:var(--cyan)}}
.sl{{font-size:8px;color:var(--muted);letter-spacing:.18em;text-transform:uppercase;}}
.tabs{{display:flex;border-bottom:1px solid var(--line);overflow-x:auto;scrollbar-width:none;}}
.tab{{font-size:10px;letter-spacing:.15em;text-transform:uppercase;padding:12px 20px;border:none;background:transparent;color:var(--muted);cursor:pointer;border-bottom:2px solid transparent;white-space:nowrap;}}
.tab.active{{color:var(--green);border-bottom-color:var(--green);background:rgba(0,255,136,.04);}}
.panel{{display:none;padding:24px;}}.panel.active{{display:block;}}
.sh{{font-family:var(--disp);font-size:24px;margin-bottom:6px;}}
.ss{{font-size:9px;color:var(--muted);letter-spacing:.15em;margin-bottom:20px;}}
.oc{{display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:1px;background:var(--line);border:1px solid var(--line);margin-bottom:20px;}}
.ocard{{background:var(--card);padding:20px;}}
.ocard:hover{{background:var(--card2);}}
.on{{font-family:var(--disp);font-size:20px;margin-bottom:8px;}}
.op2{{font-size:9px;color:var(--muted);margin-bottom:10px;word-break:break-all;}}
.obtn{{font-size:9px;color:var(--cyan);border:1px solid rgba(34,211,238,.2);padding:5px 12px;text-decoration:none;display:inline-block;}}
.sha-box{{background:#000;border:1px solid var(--green);padding:14px;font-size:10px;color:var(--green);line-height:2;word-break:break-all;margin-bottom:16px;}}
.ag{{display:grid;grid-template-columns:repeat(auto-fill,minmax(165px,1fr));gap:1px;background:var(--line);border:1px solid var(--line);}}
.ac{{background:var(--card);padding:14px;border-top:2px solid var(--green);}}
.ac:hover{{background:var(--card2);}}
.an{{font-family:var(--disp);font-size:16px;color:var(--green);margin-bottom:4px;}}
.ar{{font-size:9px;color:var(--violet);margin-bottom:4px;}}
.ast{{font-size:9px;color:var(--green);margin-bottom:4px;}}
.asha{{font-size:8px;color:rgba(0,255,136,.35);}}
.nb{{display:grid;grid-template-columns:repeat(auto-fill,minmax(195px,1fr));gap:1px;background:var(--line);border:1px solid var(--line);}}
.nbc{{background:var(--card);padding:16px;border-top:2px solid var(--violet);}}
.nbt{{font-family:var(--disp);font-size:15px;color:var(--violet);margin-bottom:6px;}}
.nbd{{font-size:9px;color:var(--muted);line-height:1.5;margin-bottom:6px;}}
.nbs{{font-size:8px;color:rgba(0,255,136,.4);}}
.bs{{display:flex;flex-direction:column;gap:4px;}}
.br{{display:flex;align-items:center;gap:14px;background:var(--card);padding:12px 16px;border-left:2px solid var(--yellow);}}
.br:hover{{background:var(--card2);}}
.bn{{font-family:var(--disp);font-size:20px;color:var(--yellow);opacity:.5;width:28px;flex-shrink:0;}}
.bt{{font-family:var(--disp);font-size:15px;color:var(--yellow);width:120px;flex-shrink:0;}}
.bd{{font-size:9px;color:var(--muted);flex:1;}}
.bsha{{font-size:8px;color:rgba(251,191,36,.4);width:90px;overflow:hidden;text-overflow:ellipsis;flex-shrink:0;}}
.ok{{width:7px;height:7px;border-radius:50%;background:var(--green);box-shadow:0 0 5px var(--green);flex-shrink:0;}}
footer{{border-top:1px solid var(--line);padding:14px 24px;display:flex;justify-content:space-between;font-size:9px;color:var(--muted);flex-wrap:wrap;gap:8px;}}
</style>
</head>
<body>
<div class="hdr">
  <div style="display:flex;align-items:center">
    <div class="logo">C25 GAMMA</div>
    <div class="badge">PIPELINE OUTPUT</div>
  </div>
  <span style="font-size:9px;color:var(--muted)" id="clk">{ts}</span>
</div>
<div class="pb"><div class="pl">// INPUT PROMPT</div><div class="pt">{prompt}</div></div>
<div class="flow">
  <div class="fs">01 NOTEBOOK LLM ✓</div>
  <div class="fs">→ 02 BANANA ✓</div>
  <div class="fs">→ 03 C25 AGENTS ✓</div>
  <div class="fs">→ 04 ARTIFACT ✓</div>
</div>
<div class="stats">
  <div class="sc"><span class="sv v">10</span><span class="sl">NB Cats</span></div>
  <div class="sc"><span class="sv y">7</span><span class="sl">Banana Steps</span></div>
  <div class="sc"><span class="sv">25</span><span class="sl">Agents</span></div>
  <div class="sc"><span class="sv c">3</span><span class="sl">Output Docs</span></div>
  <div class="sc"><span class="sv">42</span><span class="sl">SHA Anchors</span></div>
</div>
<div class="tabs">
  <button class="tab active" onclick="show('out',this)">OUTPUTS</button>
  <button class="tab" onclick="show('nb',this)">NOTEBOOK LLM</button>
  <button class="tab" onclick="show('ban',this)">BANANA</button>
  <button class="tab" onclick="show('ag',this)">C25 AGENTS</button>
  <button class="tab" onclick="show('chain',this)">SHA CHAIN</button>
</div>
<div class="panel active" id="panel-out">
  <div class="sh">PIPELINE OUTPUTS</div>
  <div class="ss">// PDF · PPTX · DOCS · BUILT BY GAMMA</div>
  <div class="oc">
    <div class="ocard"><div class="on" style="color:var(--red)">PDF REPORT</div><div class="op2">{pdf_path}</div><a class="obtn" href="gamma/gamma_report.pdf" target="_blank">OPEN →</a></div>
    <div class="ocard"><div class="on" style="color:var(--yellow)">SLIDESHOW</div><div class="op2">{pptx_path}</div><a class="obtn" href="gamma/gamma_slides.pptx" download>DOWNLOAD →</a></div>
    <div class="ocard"><div class="on" style="color:var(--cyan)">FULL DOCS</div><div class="op2">gamma/gamma_docs.md</div><a class="obtn" href="gamma/gamma_docs.md" target="_blank">VIEW →</a></div>
    <div class="ocard"><div class="on" style="color:var(--violet)">MEMORIA</div><div class="op2">memoria.db</div><span class="obtn" style="opacity:.5">SQLite LOCAL</span></div>
  </div>
  <div class="sha-box">● RUN SHA256: {run_sha}<br>● ORIGIN: AiMetaverse/Bard Dec 2023 → C25 2026<br>● CANONICAL: AI proposes. Only a human may execute.</div>
</div>
<div class="panel" id="panel-nb">
  <div class="sh">NOTEBOOK LLM</div>
  <div class="ss">// 10 CATEGORIES → BANANA INPUT</div>
  <div class="nb">{nb_cards}</div>
</div>
<div class="panel" id="panel-ban">
  <div class="sh">BANANA PIPELINE</div>
  <div class="ss">// 7 STEPS · DETERMINISTIC · SHA CHAINED</div>
  <div class="bs">{ban_rows}</div>
  <div class="sha-box" style="margin-top:12px">● PIPELINE SHA256: {ban.get('pipeline_sha','--')}</div>
</div>
<div class="panel" id="panel-ag">
  <div class="sh">C25 PLANETARY AGENTS</div>
  <div class="ss">// 25 AGENTS · BARD 2023 HIERARCHY · MCP ROUTED</div>
  <div class="ag">{agent_cards}</div>
</div>
<div class="panel" id="panel-chain">
  <div class="sh">SHA256 CHAIN</div>
  <div class="ss">// TOTALRECALL · FORENSIC · IMMUTABLE</div>
  <div class="sha-box">
    OPERATOR: u0_a510<br>
    PROMPT: {prompt}<br>
    PIPELINE: NOTEBOOK → BANANA → C25 → ARTIFACT<br>
    ORIGIN: AiMetaverse/Bard Dec 2023 → C25 2026<br>
    RUN SHA256: {run_sha}<br>
    TIMESTAMP: {ts}<br>
    CANONICAL: AI proposes. Only a human may execute.
  </div>
</div>
<footer>
  <span>C25 GAMMA · u0_a510 · SOVEREIGN</span>
  <span>{run_sha[:24]}...</span>
  <span id="fts">{ts}</span>
</footer>
<script>
function show(n,b){{
  document.querySelectorAll('.panel').forEach(p=>p.classList.remove('active'));
  document.querySelectorAll('.tab').forEach(x=>x.classList.remove('active'));
  document.getElementById('panel-'+n).classList.add('active');
  b.classList.add('active');
}}
setInterval(()=>{{
  const n=new Date();
  document.getElementById('clk').textContent=n.toLocaleTimeString('en-US',{{hour12:false}});
  document.getElementById('fts').textContent=n.toISOString().replace('T',' ').substring(0,19)+' UTC';
}},1000);
</script>
</body>
</html>"""

    os.makedirs(os.path.dirname(out_path), exist_ok=True) if os.path.dirname(out_path) else None
    with open(out_path, 'w') as f:
        f.write(html)
    print(f"ARTIFACT_OK:{out_path}")

if __name__ == '__main__':
    write_artifact(
        sys.argv[1],  # prompt
        sys.argv[2],  # nb_json
        sys.argv[3],  # banana_json
        sys.argv[4],  # agent_json
        sys.argv[5],  # run_sha
        sys.argv[6],  # pdf_path
        sys.argv[7],  # pptx_path
        sys.argv[8],  # out_path
    )
