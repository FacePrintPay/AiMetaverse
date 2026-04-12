#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🐝 [MOBILE TITAN HIVE] Initializing environment..."

# Create directories
mkdir -p ~/mobile-titan/public/bees ~/mobile-titan/data
cd ~/mobile-titan

# Create server.js
cat > server.js <<'JS'
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const compression = require("compression");
const morgan = require("morgan");
const fs = require("fs");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(helmet());
app.use(compression());
app.use(express.json());
app.use(morgan("tiny"));
app.use(express.static("public"));

const dataPath = path.join(__dirname, "data");
if (!fs.existsSync(dataPath)) fs.mkdirSync(dataPath);
const agentsFile = path.join(dataPath, "agents.json");

if (!fs.existsSync(agentsFile)) {
  const defaultAgents = [
    { id: "chronos", name: "Agent Chronos", role: "Timekeeper", bio: "Keeps the hive synchronized across systems." },
    { id: "mars", name: "Agent Mars", role: "Operations Commander", bio: "Turns friction into automation." },
    { id: "venus", name: "Agent Venus", role: "Creative Director", bio: "Drives empathy, design, and intelligence." }
  ];
  fs.writeFileSync(agentsFile, JSON.stringify(defaultAgents, null, 2));
}
let agents = JSON.parse(fs.readFileSync(agentsFile));

app.get("/api/health", (req, res) => res.json({ status: "ok", message: "Hive Core operational" }));
app.get("/api/agents", (req, res) => res.json(agents));
app.get("/api/status", (req, res) =>
  res.json({ system: "Mobile Titan Hive", activeAgents: agents.length, uptime: process.uptime(), timestamp: new Date().toISOString() })
);
app.get("/api/trigger/:agent", (req, res) => {
  const found = agents.find((a) => a.id === req.params.agent);
  if (!found) return res.status(404).json({ error: "Agent not found" });
  console.log(`🚀 Triggering ${found.name}`);
  res.json({ message: `${found.name} activated` });
});
app.get("/", (req, res) => res.sendFile(path.join(__dirname, "public", "index.html")));
app.listen(PORT, () => console.log(`🔥 Mobile Titan Hive Core running on port ${PORT}`));
JS

# Create index.html
cat > public/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Mobile Titan Hive Core</title>
  <style>
    html,body{height:100%;margin:0;background:#0a0a0a;color:#fff;display:flex;flex-direction:column;align-items:center;justify-content:center;font-family:system-ui,sans-serif;overflow:hidden;}
    .logo{width:180px;filter:drop-shadow(0 0 20px #ff9800);margin-bottom:20px;}
    .hive{position:relative;width:260px;height:260px;background:radial-gradient(circle,#ff9800 5%,#0a0a0a 70%);border-radius:50%;animation:pulse 4s infinite;}
    @keyframes pulse{0%,100%{transform:scale(1);filter:drop-shadow(0 0 15px #ffb300);}50%{transform:scale(1.05);filter:drop-shadow(0 0 35px #ff9800);}}
    .bee{position:absolute;width:60px;height:60px;animation:orbit 10s linear infinite;transform-origin:130px 130px;}
    @keyframes orbit{from{transform:rotate(0deg) translateX(130px) rotate(0deg);}to{transform:rotate(360deg) translateX(130px) rotate(-360deg);}}
    .bee img{width:100%;border-radius:50%;box-shadow:0 0 10px #ff9800;}
    .footer{position:absolute;bottom:20px;text-align:center;font-size:0.9em;opacity:0.7;}
  </style>
</head>
<body>
  <img src="bees/mobile-titan.png" class="logo" alt="Mobile Titan" />
  <div class="hive">
    <div class="bee" style="animation-delay:0s;"><img src="bees/chronos.png" alt="Chronos"></div>
    <div class="bee" style="animation-delay:2s;"><img src="bees/mars.png" alt="Mars"></div>
    <div class="bee" style="animation-delay:4s;"><img src="bees/venus.png" alt="Venus"></div>
  </div>
  <div class="footer">🐝 Mobile Titan Hive Core | AI Employees Online</div>
</body>
</html>
HTML

# Initialize Node project
npm init -y >/dev/null
npm install express cors helmet compression morgan >/dev/null

echo "✅ Setup complete. Launching Mobile Titan Hive Core..."
node server.js
