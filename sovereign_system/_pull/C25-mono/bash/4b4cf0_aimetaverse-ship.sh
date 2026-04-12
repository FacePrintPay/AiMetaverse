#!/bin/bash
set -e
echo "🚀 Constellation-25 Demo Shipper • v1.0"
echo "👤 Founder: Cygel \"TotalRecall\" White • Kre8tive Konceptz LTD"
echo ""

# Create demo file
cat > ~/aimetaverse-demo-single.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>AI-Metaverse | Constellation-25 Demo</title>
  <style>
    *{box-sizing:border-box;margin:0;padding:0}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:linear-gradient(135deg,#0f0f1a,#1a1a2e);color:#fff;min-height:100vh;padding:1.5rem}.hero{text-align:center;padding:2.5rem 1rem;max-width:800px;margin:0 auto}h1{font-size:2.2rem;margin-bottom:.5rem;background:linear-gradient(90deg,#6366f1,#a855f7,#22d3ee);-webkit-background-clip:text;-webkit-text-fill-color:transparent}.subtitle{color:#94a3b8;margin:.5rem 0 1.5rem;font-size:1.1rem}#biometric-auth{background:linear-gradient(135deg,#6366f1,#8b5cf6);border:none;padding:1rem 2rem;color:#fff;border-radius:12px;font-weight:600;font-size:1rem;cursor:pointer;margin:1rem 0;transition:all .3s ease;box-shadow:0 4px 14px rgba(99,102,241,.4)}#biometric-auth:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(99,102,241,.6)}#biometric-auth:disabled{opacity:.8;cursor:wait;transform:none}#agent-status{margin-top:1.5rem;font-family:"SF Mono","Fira Code",monospace;font-size:.95rem;line-height:1.6;text-align:left;background:rgba(30,30,46,.7);padding:1rem;border-radius:10px;border-left:3px solid #6366f1}.agent-row{display:flex;align-items:center;gap:.5rem;margin:.3rem 0}.dot{width:10px;height:10px;border-radius:50%;display:inline-block}.online{background:#22c55e;box-shadow:0 0 8px #22c55e}.offline{background:#ef4444}.footer{text-align:center;margin-top:2rem;color:#64748b;font-size:.9rem}.badge{display:inline-block;background:rgba(99,102,241,.2);color:#a5b4fc;padding:.25rem .75rem;border-radius:20px;font-size:.85rem;margin:.25rem;border:1px solid rgba(99,102,241,.3)}@media(max-width:600px){h1{font-size:1.8rem}.hero{padding:1.5rem}}
  </style>
</head>
<body>
  <div class="hero">
    <h1>🌐 AI-METAVEARSE</h1>
    <p class="subtitle">Constellation-25 • FacePrint Auth • Sovereign Agents</p>
    <div style="margin:1rem 0">
      <span class="badge">Termux-Ready</span><span class="badge">Biometric-Secured</span><span class="badge">25 Agents</span>
    </div>
    <button id="biometric-auth">🔐 Authenticate with FacePrint</button>
    <div id="agent-status">⏳ Initializing Pathos-Sovereign-1...</div>
    <div class="footer">
      <strong>Founder:</strong> Cygel "TotalRecall" White • Kre8tive Konceptz LTD<br/>
      <small>Demo Artifact • v1.0 • Constellation-25 Framework</small>
    </div>
  </div>
  <script>
    const AGENTS=["Pathos-Sovereign-1","DevOps-Agent","Legal-Compliance","Biometric-Guardian","VC-Scout","Market-Analyst","Code-Synthesizer","Deploy-Agent","Security-Audit","Investor-Relations","UX-Optimizer","Data-Orchestrator","API-Gateway","Cache-Manager","Log-Analyst","Test-Automation","Doc-Generator","Compliance-Check","Billing-Agent","Support-Triage","Growth-Hacker","Research-Agent","Partner-Connector","Risk-Assessor","Self-Heal-Module"];
    function updateAgentStatus(){const e=document.getElementById("agent-status");let t="<strong>🛰️ Agent Network Status</strong><br/><small>Live Sync • Pathos-Sovereign-1</small><hr style=\"border:0;border-top:1px solid #334155;margin:.5rem 0\"/> ";AGENTS.slice(0,6).forEach(a=>{const o=Math.random()>.05,n=o?"online":"offline",s=o?"Active":"Standby";t+=`<div class="agent-row"><span class="dot ${n}"></span><strong>${a}</strong> <small style="color:#64748b">• ${s}</small></div>`}),AGENTS.length>6&&(t+=`<div style="margin-top:.5rem;color:#94a3b8;font-size:.9rem">+ ${AGENTS.length-6} more agents online</div>`),e.innerHTML=t}
    async function verifyFacePrint(e){console.log("🔐 FacePrintPay Payload:",e);return new Promise(t=>{setTimeout(()=>{t({verified:!0,signature:"0x"+Array.from({length:40},()=>Math.floor(16*Math.random()).toString(16)).join(""),timestamp:Date.now(),deviceId:"termux-demo-"+Math.random().toString(36).slice(2,8)})},1800)})}
    document.addEventListener("DOMContentLoaded",()=>{const e=document.getElementById("agent-status"),t=document.getElementById("biometric-auth");setTimeout(()=>{updateAgentStatus(),setInterval(updateAgentStatus,4e3)},1200),t.addEventListener("click",async()=>{t.disabled=!0;const a=t.innerHTML;t.innerHTML="🔐 Capturing Biometric Signature...";try{const o={captureMethod:"mock-faceprint",timestamp:Date.now(),deviceFingerprint:btoa(navigator.userAgent+Date.now()).slice(0,32),consent:!0},n=await verifyFacePrint(o);n.verified?(t.innerHTML="✅ FacePrint Verified • Agents Activated",t.style.background="linear-gradient(135deg,#22c55e,#16a34a)",t.style.boxShadow="0 4px 14px rgba(34,197,94,.4)",window.dispatchEvent(new CustomEvent("constellation:authenticated",{detail:n})),setTimeout(()=>{e.innerHTML="<strong style=\"color:#22c55e\">✅ CONSTELLATION-25 ACTIVE</strong><br/>All 25 agents synchronized • Ready for investor demo"},800)):(t.innerHTML="❌ Verification Failed • Retry",t.disabled=!1)}catch(a){console.error("Auth error:",a),t.innerHTML="❌ Verification Failed • Retry",t.disabled=!1}}),const a=document.querySelector(".hero");a.style.opacity="0",a.style.transform="translateY(10px)",setTimeout(()=>{a.style.transition="opacity .4s ease, transform .4s ease",a.style.opacity="1",a.style.transform="translateY(0)"},100)}),setTimeout(()=>{const e=document.getElementById("biometric-auth");!e.disabled&&e.textContent.includes("Authenticate")&&(console.log("🎬 Investor Demo Mode: Auto-authenticating..."),e.click())},8e3);
  </script>
</body>
</html>
HTMLEOF

echo "✅ Generated: ~/aimetaverse-demo-single.html"
echo ""
echo "🎯 LAUNCH OPTIONS:"
echo "   1️⃣  Open directly: termux-open ~/aimetaverse-demo-single.html"
echo "   2️⃣  Serve locally: python3 -m http.server 8080 --directory ~ &"
echo "   3️⃣  Share with investors: cp ~/aimetaverse-demo-single.html ~/shared/"
echo ""
echo "🔗 Investor URL (after ngrok):"
echo "   ngrok http 8080  # then send the https://*.ngrok.io link"
echo ""
echo "💡 Pro Tip: Auto-demo activates after 8 seconds for investor loops."
echo "🚀 Constellation-25 • FacePrintPay • Sovereign AI • SHIPPED"
