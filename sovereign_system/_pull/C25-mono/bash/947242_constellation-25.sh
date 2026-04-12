
#!/data/data/com.termux/files/usr/bin/bash

clear

while true; do
  cat <<'PROMPT_BOX'
╔════════════════════════════════════════════════════════════╗
║                  AGENT PROMPT BOX                          ║
╚════════════════════════════════════════════════════════════╝
Type your prompt (press Enter twice to submit):

PROMPT_BOX

  prompt=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && break
    prompt="$prompt$line\n"
  done

  clear

  cat <<'AGENT_BOX'
╔════════════════════════════════════════════════════════════╗
║           CONSTELLATION 25 - PLANETARY AGENTS              ║
║                Time: $(date '+%Y-%m-%d %H:%M:%S')          ║
║                                                            ║
║     Prompt fed to agent:                                   ║
║     $prompt                                                 ║
║                                                            ║
║     Select agent number + Enter to USE it                  ║
╠════════════════════════════════════════════════════════════╣
║  1  Earth      - Foundational code structure               ║
║  2  Moon       - Syntax error resolution                   ║
║  3  Sun        - Performance optimization                  ║
║  4  Mercury    - Unit test generation                      ║
║  5  Venus      - Regression testing                        ║
║  6  Mars       - Security vulnerability scanning           ║
║  7  Jupiter    - Code documentation & analysis             ║
║  8  Saturn     - Refactoring & modernization               ║
║  9  Uranus     - NLP documentation generation              ║
║ 10  Neptune    - Code deduplication                        ║
║ 11  Cygnus     - AI algorithm/model code                   ║
║ 12  Orion      - UI/UX optimization                        ║
║ 13  Andromeda  - External API/service integration          ║
║ 14  Pleiades   - Virtual env management                    ║
║ 15  Sirius     - Deployment & scaling                      ║
║ 16  Canis Major- Technical debt resolution                 ║
║ 17  Hydra      - CI/CD pipeline execution                  ║
╚════════════════════════════════════════════════════════════╝
🌌 Agent [1-17] or 'bash' for terminal or 'exit' to quit:
AGENT_BOX

  read -p "  " choice

  if [[ "$choice" == "exit" || "$choice" == "quit" || "$choice" == "q" ]]; then
    echo "Exiting Constellation 25."
    exit 0
  fi

  if [[ "$choice" == "bash" ]]; then
    echo "Dropping to bash... (type 'exit' to return)"
    bash
    clear
    continue
  fi

  if [[ "\( choice" =\~ ^[1-9] \)|^1[0-7]$ ]]; then
    agent_name=$(awk -v num="$choice" '
      $1 == num {print $2}
    ' <<'NAMES'
1 Earth
2 Moon
3 Sun
4 Mercury
5 Venus
6 Mars
7 Jupiter
8 Saturn
9 Uranus
10 Neptune
11 Cygnus
12 Orion
13 Andromeda
14 Pleiades
15 Sirius
16 Canis Major
17 Hydra
NAMES
    )

    echo ""
    echo "Activating $agent_name"
    echo "Prompt context: $prompt"
    echo "------------------------------------------------"

    case "$choice" in
      11)
        echo "Cygnus: Compiling AI/game code from prompt..."
        if echo "$prompt" | grep -qiE "mars|ticket|hunt|game|react"; then
          echo "Detected game prompt — generating full Mars Ticket Hunt React component..."
          mkdir -p \~/constellation-25-output
          cat > \~/constellation-25-output/MarsTicketHunt.jsx <<'GAME_CODE'
import React, { useState } from 'react';
import { Rocket, MapPin, Trophy, Coins, Star } from 'lucide-react';

export default function MarsTicketHunt() {
  const [score, setScore] = useState(0);
  const [tickets, setTickets] = useState(0);
  const [discovered, setDiscovered] = useState([]);

  const regions = [
    { id: 1, name: 'Olympus Mons', reward: 10 },
    { id: 2, name: 'Valles Marineris', reward: 15 },
    { id: 3, name: 'Hellas Basin', reward: 20 },
    { id: 4, name: 'Elysium Planitia', reward: 12 },
    { id: 5, name: 'Utopia Planitia', reward: 18 },
    { id: 6, name: 'Gale Crater', reward: 25 },
    { id: 7, name: 'Jezero Crater', reward: 30 },
    { id: 8, name: 'Tharsis Region', reward: 22 },
  ];

  const explore = (region) => {
    if (discovered.includes(region.id)) return;
    setScore(score + region.reward);
    setDiscovered([...discovered, region.id]);
    if (Math.random() > 0.7) setTickets(tickets + 1);
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-900 to-purple-900 text-white p-6">
      <h1 className="text-4xl font-bold text-center mb-8">Mars Ticket Hunt</h1>
      <div className="grid grid-cols-2 gap-4 mb-8">
        <div>Score: {score}</div>
        <div>Tickets: {tickets}</div>
      </div>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {regions.map(r => (
          <button key={r.id} onClick={() => explore(r)} className="bg-orange-600 p-4 rounded">
            {r.name} (+{r.reward})
          </button>
        ))}
      </div>
    </div>
  );
}
GAME_CODE
          echo "Full Mars Ticket Hunt React component saved to \~/constellation-25-output/MarsTicketHunt.jsx"
        else
          echo "Cygnus: Generating generic AI code stub..."
          mkdir -p \~/constellation-25-output
          echo "import torch" > \~/constellation-25-output/ai-stub.py
          echo "class Model(torch.nn.Module): pass" >> \~/constellation-25-output/ai-stub.py
        fi
        ;;
      *) echo "$agent_name: Processing request..." ;;
    esac

    echo ""
  else
    echo "Invalid choice. Enter 1-17, 'bash', or 'exit'."
  fi

  sleep 3
  clear
done
