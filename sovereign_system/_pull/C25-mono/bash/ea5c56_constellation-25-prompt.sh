
#!/data/data/com.termux/files/usr/bin/bash

clear

while true; do
  cat <<'PROMPT_BOX'
╔════════════════════════════════════════════════════════════╗
║                  AGENT PROMPT BOX                          ║
╚════════════════════════════════════════════════════════════╝
Type your prompt / conversation data (press Enter twice to submit):

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
    echo "Dropping to bash terminal... (type 'exit' to return)"
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

    # Agent-specific response (expand as needed)
    case "$choice" in
      1) echo "Earth: Building foundational structure from prompt..." ;;
      2) echo "Moon: Fixing syntax errors in prompt..." ;;
      6) echo "Mars: Scanning prompt for security issues..." ;;
      11) echo "Cygnus: Compiling AI model logic from prompt..." ;;
      *) echo "$agent_name: Processing your request..." ;;
    esac

    echo ""
  else
    echo "Invalid choice. Enter 1-17, 'bash', or 'exit'."
  fi

  read -p "Press Enter to continue..." dummy
  clear
done
