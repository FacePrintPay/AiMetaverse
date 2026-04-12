module.exports = {
  apps: [
    {
      name: "planetary-agents",
      script: "agent_handoff_loop.py",
      interpreter: "python3",
      autorestart: true,
      watch: false
    }
  ]
};mkdir -p ~/downloads/ARC.AI-Stargate/data/agents
nano ~/downloads/ARC.AI-Stargate/data/agents/system_agents.json
[
  "mars",
  "venus",
  "mercury",
  "earth",
  "jupiter",
  "saturn",
  "uranus",
  "neptune",
  "pluto",
  "lunar",
  "nova",
  "solar",
  "starlight",
  "blackhole",
  "quantum",
  "comet",
  "asteroid",
  "eclipse",
  "guardian",
  "orbit",
  "terra",
  "xenon",
  "alpha",
  "beta",
  "omega"
]
