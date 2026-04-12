// Constellation-25 Agent Monitor (Demo Mode)
const AGENTS = [
  'Pathos-Sovereign-1', 'DevOps-Agent', 'Legal-Compliance', 
  'Biometric-Guardian', 'VC-Scout', 'Market-Analyst'
];

function updateAgentStatus() {
  const container = document.getElementById('agent-status') || (() => {
    const el = document.createElement('div');
    el.id = 'agent-status';
    document.querySelector('.hero').appendChild(el);
    return el;
  })();
  
  let html = '<strong>🛰️ Agent Network</strong><br>';
  AGENTS.forEach(agent => {
    const online = Math.random() > 0.1; // 90% uptime demo
    html += `<span style="color:${online?'#22c55e':'#ef4444'}">●</span> ${agent}<br>`;
  });
  container.innerHTML = html;
}

// Update every 3s for live feel
setInterval(updateAgentStatus, 3000);
updateAgentStatus(); // Initial render
