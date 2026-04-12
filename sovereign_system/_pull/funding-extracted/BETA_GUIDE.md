# CONSTELLATION25 — Beta Tester Guide
**Version:** 25.0.0-beta  
**Date:** 2026-03-07 20:39:46 EST  
**Author:** u0_a510 (Sovereign)  
**SHA256:** 54ed080d1d29fa29e86db0e5b35025771fc0fc9ee219ddf42bdbd09eaeee3c6d

---

## What is Constellation25?

Constellation25 is a **sovereign AI agent orchestration system** running entirely
on your Android device via Termux. No cloud required. No external dependencies.
25 planetary agents, each with a dedicated role, coordinated through a pure Python
MCP (Model Context Protocol) server.

---

## System Architecture

```
Constellation25 Production Environment
======================================

Agents     : 25 planetary agents (earth → fomalhaut)
Status     : All scripts created, heartbeat functional
Orchestration : Bash-based with PID tracking
MCP Server : mcp-stdlib.py (pure Python, stdio protocol)
Task Queue : ~/constellation25/tasks/
Logging    : ~/constellation25/logs/ + TotalRecall blockchain manifest
Claude Desktop : ~/.config/Claude/claude_desktop_config.json
Android    : termux-notification-list-mcp-sse on port 3000
Architecture : Sovereign, local-first, cloud-optional
```

---

## Quick Start

### Step 1 — Verify System
```bash
bash ~/constellation25/verify.sh
```

### Step 2 — Start MCP Server
```bash
python3 ~/constellation25/mcp-stdlib.py
```

### Step 3 — Start All Agents
```bash
bash ~/constellation25/run_agent.sh all
```

### Step 4 — Check Heartbeat
```bash
bash ~/constellation25/c25_anchor.sh
```

### Step 5 — Monitor Logs
```bash
tail -f ~/constellation25/logs/constellation25.log
```

---

## The 25 Planetary Agents

| # | Agent | Role |
|---|-------|------|
| 1 | Earth | Ground truth, file system ops |
| 2 | Mercury | Fast messaging, notifications |
| 3 | Venus | UI/UX, frontend generation |
| 4 | Mars | Build, compile, deploy |
| 5 | Jupiter | Orchestration, scheduling |
| 6 | Saturn | Logging, forensics, TotalRecall |
| 7 | Uranus | API integration |
| 8 | Neptune | Network, cloud sync |
| 9 | Pluto | Archive, backup, storage |
| 10 | Luna | Memory, context management |
| 11 | Sol | Core AI inference |
| 12 | Sirius | Deployment & scaling |
| 13 | Vega | Data processing |
| 14 | Rigel | Code generation |
| 15 | Pleiades | Virtual env management |
| 16 | Orion | Task queue management |
| 17 | Hydra | CI/CD pipeline execution |
| 18 | Lyra | Audio/media processing |
| 19 | Cygnus | Evidence & legal docs |
| 20 | Andromeda | Multi-repo sync |
| 21 | Perseus | Security, vault ops |
| 22 | Cassiopeia | Dashboard & reporting |
| 23 | Aquila | Search & discovery |
| 24 | Draco | Automation scripts |
| 25 | Fomalhaut | Revenue & monetization |

---

## MCP Server — Claude Desktop Integration

Config at: `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "constellation25": {
      "command": "python3",
      "args": ["/data/data/com.termux/files/home/constellation25/mcp-stdlib.py"],
      "env": {
        "C25_HOME": "/data/data/com.termux/files/home/constellation25",
        "C25_LOGS": "/data/data/com.termux/files/home/constellation25/logs",
        "C25_TASKS": "/data/data/com.termux/files/home/constellation25/tasks"
      }
    }
  }
}
```

---

## Task Queue Format

Tasks are queued as JSON files in `~/constellation25/tasks/`

```json
{
  "id": "task_001",
  "agent": "mars",
  "action": "deploy",
  "target": "aikre8tive-stargate",
  "priority": 1,
  "timestamp": "2026-03-07 20:39:46 EST",
  "sha256": "54ed080d1d29fa29e86db0e5b35025771fc0fc9ee219ddf42bdbd09eaeee3c6d"
}
```

Queue a task:
```bash
bash ~/constellation25/queue_task.sh mars deploy aikre8tive-stargate
```

---

## TotalRecall Forensic Logging

Every action is logged with SHA256 hash to the TotalRecall blockchain manifest.

```bash
# View forensic log
cat ~/constellation25/logs/totalrecall_manifest.log

# Verify integrity
bash ~/constellation25/verify_integrity.sh
```

Log format:
```
[YYYY-MM-DD HH:MM:SS] [AGENT] [ACTION] SHA256:abc123...
```

---

## Android Notifications (Port 3000)

```bash
# Check SSE server status
curl http://localhost:3000/status

# Send test notification
curl -X POST http://localhost:3000/notify   -H "Content-Type: application/json"   -d '{"title":"C25","body":"Agent deployed"}'
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| MCP server not responding | `python3 /data/data/com.termux/files/home/constellation25/mcp-stdlib.py &` |
| Agent not starting | `bash /data/data/com.termux/files/home/constellation25/agents/[name].sh &` |
| Tasks not processing | Check `/data/data/com.termux/files/home/constellation25/tasks/` for pending .json files |
| Log missing | `mkdir -p /data/data/com.termux/files/home/constellation25/logs && touch /data/data/com.termux/files/home/constellation25/logs/constellation25.log` |
| Port 3000 busy | `kill $(lsof -t -i:3000) && restart` |

---

## Beta Feedback

Report issues via:
- GitHub: your constellation25 repo
- Log file: `~/constellation25/logs/beta_feedback.log`

```bash
echo "FEEDBACK: $YOUR_MESSAGE" >> ~/constellation25/logs/beta_feedback.log
```

---

*Constellation25 — Sovereign. Local-first. Cloud-optional.*  
*Built on Termux. Owned by u0_a510. SHA256 anchored.*
