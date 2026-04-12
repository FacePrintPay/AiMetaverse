<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Kre8tive Holdings — Master Gateway (#MrGGTP)</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="robots" content="noindex, nofollow" />
  <style>
    :root{
      --bg:#0c1022; --bg2:#0a0f1f; --card:#11162b; --ink:#e8edff; --muted:#a7b1d3;
      --line:rgba(255,255,255,.09); --accent:#7eb5ff; --accent2:#a36bff; --ok:#10b981; --warn:#f59e0b; --bad:#ef4444;
    }
    *{box-sizing:border-box}
    html,body{margin:0;background:linear-gradient(180deg,var(--bg),var(--bg2) 60%,var(--bg));
      color:var(--ink);font:15px/1.6 Inter,system-ui,Segoe UI,Roboto,Helvetica,Arial,sans-serif}
    a{color:var(--accent);text-decoration:none}
    a:hover{text-decoration:underline}
    .wrap{max-width:1180px;margin:0 auto;padding:28px 16px 60px}
    header{display:flex;gap:16px;align-items:center;margin:6px 0 20px}
    .logo{width:48px;height:48px;border-radius:14px;background:conic-gradient(from 210deg,#5b8cff,#a36bff,#5b8cff)}
    h1{margin:0;font-size:28px;letter-spacing:.2px}
    .muted{color:var(--muted)} .small{font-size:12px}
    nav{margin-left:auto;display:flex;gap:12px;align-items:center}
    .btn{display:inline-flex;gap:8px;align-items:center;padding:8px 12px;border:1px solid var(--line);
      border-radius:10px;background:rgba(255,255,255,.03)}
    .btn:hover{background:rgba(255,255,255,.06)}
    .hero{display:grid;gap:16px;grid-template-columns:1.05fr .95fr;margin:10px 0 18px}
    .card{background:var(--card);border:1px solid var(--line);border-radius:16px;padding:16px}
    .card h2{margin:0 0 8px;font-size:18px}
    .grid{display:grid;gap:14px;grid-template-columns:repeat(3,1fr)}
    .tile{padding:16px;border:1px solid var(--line);border-radius:16px;background:rgba(255,255,255,.02);
      display:flex;flex-direction:column;gap:10px}
    .tile h3{margin:0;font-size:16px}
    .pill{display:inline-block;font-size:12px;color:var(--muted);border:1px solid var(--line);border-radius:999px;padding:2px 8px}
    .row{display:flex;gap:10px;flex-wrap:wrap}
    details{border:1px dashed var(--line);border-radius:12px;padding:10px;background:rgba(255,255,255,.02)}
    details summary{cursor:pointer;font-weight:600;margin:0 0 6px}
    footer{margin:28px 0 8px;color:var(--muted);border-top:1px dashed var(--line);padding-top:10px}

    /* NDA overlay */
    .nda-mask{position:fixed;inset:0;background:rgba(0,0,0,.6);backdrop-filter:blur(4px);display:none}
    .nda{position:fixed;inset:0;display:grid;place-items:center;pointer-events:none}
    .nda .panel{pointer-events:auto;max-width:760px;margin:0 16px;background:var(--card);border:1px solid var(--line);
      border-radius:16px;padding:18px}
    .nda h2{margin:0 0 8px}
    .nda .text{max-height:40vh;overflow:auto;border:1px solid var(--line);border-radius:12px;padding:12px;background:rgba(255,255,255,.02)}
    .nda .actions{display:flex;gap:8px;justify-content:flex-end;margin-top:12px}
    .nda .danger{background:rgba(239,68,68,.15);border-color:#ef4444}
    .nda .primary{background:linear-gradient(135deg,var(--accent),var(--accent2));border:0}
    .nda .muted{flex:1}
    .kbd{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;background:rgba(255,255,255,.06);
      border:1px solid var(--line);padding:0 6px;border-radius:6px}
    @media(max-width:960px){
      .hero{grid-template-columns:1fr}
      .grid{grid-template-columns:1fr 1fr}
    }
    @media(max-width:640px){
      .grid{grid-template-columns:1fr}
    }
    @media print{
      .nda-mask,.nda,nav .btn{display:none !important}
      body{background:#fff;color:#111}
      .card,.tile{border-color:#ddd;background:#fff}
      a{color:#0645ad}
    }
  </style>
</head>
<body>
  <div class="nda-mask" id="ndaMask"></div>
  <div class="nda" id="ndaGate" aria-modal="true" role="dialog" aria-labelledby="ndaTitle" aria-describedby="ndaBody">
    <div class="panel">
      <h2 id="ndaTitle">Mutual NDA & Confidential Access</h2>
      <div class="small muted">Applies to all linked workspaces, portals and investor materials.</div>
      <div id="ndaBody" class="text small">
        <p><strong>Confidentiality.</strong> By accessing this portal, you agree to keep all non-public information confidential, to use it solely for evaluation purposes, and to refrain from sharing it without written consent.</p>
        <p><strong>Prohibited Uses.</strong> No reverse engineering, model extraction, scraping, or automated data collection. No redistribution of documents or credentials.</p>
        <p><strong>Monitoring.</strong> Access may be logged for security and compliance.</p>
        <p><strong>No Offer.</strong> Nothing herein constitutes an offer to sell or solicitation to buy securities. See Offering Circular for details.</p>
      </div>
      <label style="display:flex;gap:8px;align-items:center;margin-top:10px">
        <input id="ndaChk" type="checkbox" />
        <span>I agree to the terms above (NDA)</span>
      </label>
      <div class="actions">
        <button class="btn danger" id="ndaDecline">Decline</button>
        <button class="btn primary" id="ndaAccept" disabled>Accept & Continue</button>
      </div>
      <div class="small muted" style="margin-top:6px">
        Tip: press <span class="kbd">A</span> to accept (when the checkbox is ticked).
      </div>
    </div>
  </div>

  <div class="wrap" id="app">
    <header>
      <div class="logo" aria-hidden="true"></div>
      <div>
        <h1>Kre8tive Holdings — Master Gateway</h1>
        <div class="muted small">#MrGGTP · CyGeL (27 modules) · Planetary Agents (25) · Subsidiary: Hempchoices LLC</div>
      </div>
      <nav>
        <a class="btn" href="./regulatory-offering.html" target="_blank" rel="noopener">Offering Circular</a>
        <a class="btn" href="./governance.html" target="_blank" rel="noopener">Governance</a>
        <button class="btn" id="revokeNDA" type="button" title="Clear NDA acceptance for this browser">Revoke NDA</button>
      </nav>
    </header>

    <section class="hero">
      <div class="card">
        <h2>About This Portal</h2>
        <p>
          Welcome to the unified gateway for Kre8tive’s product stack and investor materials.
          Access is NDA-gated. Use the tiles to open each product workspace. Investor
          documents are available via the top-right links.
        </p>
        <div class="row">
          <span class="pill">Sovereign GTP</span>
          <span class="pill">PorTaled (Stargate)</span>
          <span class="pill">Identity · Payments · Records</span>
          <span class="pill">#MrGGTP</span>
        </div>
      </div>
      <div class="card">
        <h2>Quick Docs</h2>
        <ul style="margin:0 0 6px 18px">
          <li><a href="./regulatory-offering.html" target="_blank" rel="noopener">Preliminary Offering Circular (HTML)</a></li>
          <li><a href="./offering.txt" target="_blank" rel="noopener">Preliminary Offering (Plain-Text)</a></li>
          <li><a href="./nda.txt" target="_blank" rel="noopener">NDA (Text)</a></li>
          <li><a href="./security-privacy.html" target="_blank" rel="noopener">Security & Privacy Overview</a></li>
        </ul>
        <div class="small muted">Replace placeholders with counsel-approved content before any public use.</div>
      </div>
    </section>

    <section class="card" style="margin-bottom:14px">
      <h2>Products & Workspaces</h2>
      <div class="grid" id="tiles">
        <!-- Row 1 -->
        <div class="tile">
          <div class="row"><span class="pill">🎵 Media/IP</span></div>
          <h3>AiRecords</h3>
          <div class="muted small">Media registry · hashing · licensing workflow.</div>
          <div class="row">
            <a class="btn" href="https://ai-records.vercel.app/" target="_blank" rel="noopener">Open</a>
          </div>
        </div>
        <div class="tile">
          <div class="row"><span class="pill">⚖️ Justice</span></div>
          <h3>VideoCourts</h3>
          <div class="muted small">Hearing workflows · evidence intake · scheduling.</div>
          <div class="row">
            <a class="btn" href="https://videocourts.vercel.app/" target="_blank" rel="noopener">Open</a>
          </div>
        </div>
        <div class="tile">
          <div class="row"><span class="pill">🛒 Commerce</span></div>
          <h3>MyBuyO</h3>
          <div class="muted small">Marketplace + partner rails.</div>
          <div class="row">
            <a class="btn" href="https://mybuyo.vercel.app/" target="_blank" rel="noopener">Open</a>
          </div>
        </div>
        <!-- Row 2 -->
        <div class="tile">
          <div class="row"><span class="pill">🤖 Orchestration</span></div>
          <h3>Sovereign GTP</h3>
          <div class="muted small">Agentic control · policy runtime · audit.</div>
          <div class="row">
            <a class="btn" href="https://sovereigngtp.vercel.app/" target="_blank" rel="noopener">Open</a>
          </div>
        </div>
        <div class="tile">
          <div class="row"><span class="pill">🧭 Portal</span></div>
          <h3>PorTaled / Stargate</h3>
          <div class="muted small">Access router · SSO · policy enforcement.</div>
          <div class="row">
            <a class="btn" href="https://ai-kre8tive-stargate.vercel.app/" target="_blank" rel="noopener">Open</a>
          </div>
        </div>
        <div class="tile">
          <div class="row"><span class="pill">🪐 Agents</span></div>
          <h3>Planetary Agents</h3>
          <div class="muted small">Exec/Board mapping to 25 planetary roles.</div>
          <div class="row">
            <a class="btn" href="./agents.html" target="_blank" rel="noopener">Roster</a>
          </div>
        </div>
        <!-- Row 3 -->
        <div class="tile">
          <div class="row"><span class="pill">🕸️ Exp.</span></div>
          <h3>AiMetaverse</h3>
          <div class="muted small">Immersive AI experiences & presence.</div>
          <div class="row">
            <a class="btn" href="https://ai-metaverse-orgin.vercel.app/" target="_blank" rel="noopener">Open</a>
          </div>
        </div>
        <div class="tile">
          <div class="row"><span class="pill">🚀 R&D</span></div>
          <h3>ExplorerMars</h3>
          <div class="muted small">Exploration sandbox & demos.</div>
          <div class="row">
            <a class="btn" href="https://explorermars.vercel.app/" target="_blank" rel="noopener">Open</a>
          </div>
        </div>
        <div class="tile">
          <div class="row"><span class="pill">🧠 DevTools</span></div>
          <h3>NLP2CODE / PaTHos</h3>
          <div class="muted small">Natural-language coding · pipelines · testing.</div>
          <div class="row">
            <a class="btn" href="./devtools.html" target="_blank" rel="noopener">Docs</a>
          </div>
        </div>
        <!-- Row 4 -->
        <div class="tile">
          <div class="row"><span class="pill">🪪 Identity</span></div>
          <h3>FacePrint.Pay</h3>
          <div class="muted small">Identity · payments · attestations.</div>
          <div class="row">
            <a class="btn" href="https://platform.vercel.app/" target="_blank" rel="noopener">Open</a>
          </div>
        </div>
        <div class="tile">
          <div class="row"><span class="pill">🏢 Portfolio</span></div>
          <h3>Kre8tive Konceptz</h3>
          <div class="muted small">Corporate site & holdings overview.</div>
          <div class="row">
            <a class="btn" href="./holdings.html" target="_blank" rel="noopener">View</a>
          </div>
        </div>
        <div class="tile">
          <div class="row"><span class="pill">🌐 Gateway</span></div>
          <h3>Sovereign-Stargate</h3>
          <div class="muted small">External ingress (variant).</div>
          <div class="row">
            <a class="btn" href="https://sovereign-stargate.vercel.app/" target="_blank" rel="noopener">Open</a>
          </div>
        </div>
      </div>
      <div class="small muted" style="margin-top:10px">
        Note: Some endpoints may respond with <span style="color:#ffd28b">401 (protected)</span> until you disable Vercel Password Protection or test with a bypass token.
      </div>
    </section>

    <section class="card">
      <h2>Architecture Notes</h2>
      <details open>
        <summary>27 CyGeL Modules (high-level)</summary>
        <div class="row" style="margin-top:8px">
          <span class="pill">Identity</span><span class="pill">Payments</span><span class="pill">Records</span>
          <span class="pill">AuthZ</span><span class="pill">Audit</span><span class="pill">Media</span>
          <span class="pill">Search</span><span class="pill">Messaging</span><span class="pill">Storage</span>
          <span class="pill">Compliance</span><span class="pill">Analytics</span><span class="pill">Workflows</span>
          <span class="pill">Catalog</span><span class="pill">Checkout</span><span class="pill">KYC/AML</span>
          <span class="pill">Webhooks</span><span class="pill">Billing</span><span class="pill">Edge-AI</span>
          <span class="pill">Embeddings</span><span class="pill">Moderation</span><span class="pill">Observability</span>
          <span class="pill">Cache</span><span class="pill">Sync</span><span class="pill">Scheduler</span>
          <span class="pill">Secrets</span><span class="pill">Docs</span><span class="pill">Admin</span>
        </div>
      </details>
      <details style="margin-top:10px">
        <summary>Planetary Agents (25) — Exec & Board Mapping</summary>
        <p class="small muted">Representative mapping shown for internal planning; finalize titles/biographies in Governance.</p>
        <div class="row" style="margin-top:8px">
          <span class="pill">Agent-01 (CEO)</span><span class="pill">Agent-02 (Chair)</span><span class="pill">Agent-03 (CTO)</span>
          <span class="pill">Agent-04 (CPO)</span><span class="pill">Agent-05 (COO)</span><span class="pill">Agent-06 (CISO)</span>
          <span class="pill">Agent-07 (GC)</span><span class="pill">Agent-08 (CFO)</span><span class="pill">Agent-09 (CRO)</span>
          <span class="pill">Agent-10</span><span class="pill">Agent-11</span><span class="pill">Agent-12</span>
          <span class="pill">Agent-13</span><span class="pill">Agent-14</span><span class="pill">Agent-15</span>
          <span class="pill">Agent-16</span><span class="pill">Agent-17</span><span class="pill">Agent-18</span>
          <span class="pill">Agent-19</span><span class="pill">Agent-20</span><span class="pill">Agent-21</span>
          <span class="pill">Agent-22</span><span class="pill">Agent-23</span><span class="pill">Agent-24</span>
          <span class="pill">Agent-25</span>
        </div>
      </details>
    </section>

    <footer class="small">
      © <span id="yr"></span> Kre8tive Holdings · NDA-gated internal gateway · #MrGGTP
    </footer>
  </div>

  <script>
    (function(){
      // Timestamps
      document.getElementById('yr').textContent = new Date().getFullYear();

      // NDA gate
      const KEY = 'kre8tive_nda_v1';
      const ndaMask = document.getElementById('ndaMask');
      const nda = document.getElementById('ndaGate');
      const chk = document.getElementById('ndaChk');
      const accept = document.getElementById('ndaAccept');
      const decline = document.getElementById('ndaDecline');
      const revoke = document.getElementById('revokeNDA');

      function showNDA(){
        ndaMask.style.display = 'block';
        nda.style.display = 'grid';
      }
      function hideNDA(){
        ndaMask.style.display = 'none';
        nda.style.display = 'none';
      }
      function accepted(){
        try{ return localStorage.getItem(KEY) === 'yes'; }catch(e){ return false; }
      }
      function setAccepted(v){
        try{ localStorage.setItem(KEY, v ? 'yes' : 'no'); }catch(e){}
      }
      if(!accepted()){ showNDA(); }

      chk.addEventListener('change', () => { accept.disabled = !chk.checked; });
      accept.addEventListener('click', () => { if(!chk.checked) return; setAccepted(true); hideNDA(); });
      decline.addEventListener('click', () => { setAccepted(false); alert('Access requires accepting the NDA.'); });
      revoke.addEventListener('click', () => { setAccepted(false); showNDA(); });

      // Keyboard: A to accept (when checked)
      document.addEventListener('keydown', (e) => {
        if(nda.style.display === 'grid' && (e.key === 'a' || e.key === 'A')){
          if(!accept.disabled) accept.click();
        }
      });
    })();
  </script>
</body>
</html>