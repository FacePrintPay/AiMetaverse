# 🌌 Constellation 25 • AI Metaverse Dashboard
> Sovereign Agent Architecture • Pathos-Sovereign-1 • v3.0

## Architect
**Cygel White (TotalRecall)**  
GitHub: [FacePrintPay](https://github.com/FacePrintPay)  
© 2026 Kre8tive Holdings • Commercial License • Not Open Source

## 🚀 Quick Start

### Option A: View Live Dashboard
🔗 https://constellation25-dashboard.vercel.app/constellation/dashboard.html

### Option B: Local Demo (Termux)
```bash
# Extract tarball
tar -xzf ~/Constellation25-v3.0-DEPLOY.tar.gz -C ~
cd ~/Constellation25-v3.0-DEPLOY

# Start bridge for agent execution (optional)
./bridge/start.sh

# Serve static files
python3 -m http.server 8080

# Open in browser
termux-open http://localhost:8080/constellation
```

### Option C: Deploy to Vercel
```bash
cd ~/Constellation25-v3.0-DEPLOY
vercel login
vercel --prod
```

## 🤖 27-Planetary Agents
| Agent | Role |
|-------|------|
| 🌍 Earth-Agent | Scaffolding, project init |
| 🌙 Moon-Agent | Debugging, error handling |
| ☀️ Sun-Agent | Optimization, performance |
| ... | *(see agents/ directory for all 27)* |

## 🔗 Bridge Configuration
In dashboard console, set:
```javascript
C25.setBridge('http://192.168.1.X:8080') // Replace with Termux IP
C25.exec('Earth-Agent', 'scaffold demo --nextjs')
```

## 📦 Package Contents
- `constellation/` — Dashboard HTML (index.html + dashboard.html)
- `agents/` — 27 agent stubs (mock execution)
- `bridge/` — Python HTTP bridge (CORS + port-conflict safe)
- `vercel.json` — Modern static routing config
- `README.md` — This file

## 🔐 License
© 2026 Kre8tive Holdings • Commercial License • Not Open Source  
Architect attribution required in all derivatives.  
Commercial inquiries: hempchoices@gmail.com
