#!/data/data/com.termux/files/usr/bin/bash
# Sovereign GTP Dashboard - Constellation 25 with USE buttons
# Wake lock & heartbeat (background)
termux-wake-lock 2>/dev/null || true
(while true; do echo "[$(date '+%Y-%m-%d %H:%M:%S')] Heartbeat" >> ~/sovereign-gtp/logs/heartbeat.log 2>/dev/null; sleep 30; done) & 2>/dev/null
while true; do
  CHOICE=$(dialog --clear --backtitle "SOVEREIGN GTP DASHBOARD" \
    --title "Constellation 25 - Planetary Agents" \
    --menu "Time: $(date '+%Y-%m-%d %H:%M:%S')\nSelect agent number + Enter to USE it" \
    35 90 25 \
    1  "Earth      - Foundational code structures          [USE]" \
    2  "Moon       - Syntax error resolution               [USE]" \
    3  "Sun        - Performance optimization              [USE]" \
    4  "Mercury    - Unit test generation                  [USE]" \
    5  "Venus      - Regression testing                    [USE]" \
    6  "Mars       - Security vulnerability scanning       [USE]" \
    7  "Jupiter    - Code documentation & analysis         [USE]" \
    8  "Saturn     - Refactoring & modernization           [USE]" \
    9  "Uranus     - NL → documentation generation         [USE]" \
    10 "Neptune    - Code deduplication                    [USE]" \
    11 "Cygnus     - AI algorithm/model code gen           [USE]" \
    12 "Orion      - UI/UX optimization                    [USE]" \
    13 "Andromeda  - External API/service integration      [USE]" \
    14 "Pleiades   - Virtual env management                 [USE]" \
    15 "Sirius     - Deployment & scaling code              [USE]" \
    16 "Canis Major- Technical debt resolution              [USE]" \
    17 "Hydra      - CI/CD pipeline execution               [USE]" \
    18 "Centauri   - Data pipeline generation               [USE]" \
    19 "Draco      - Infrastructure monitoring              [USE]" \
    20 "Boötes     - Security incident resolution           [USE]" \
    21 "Corona Borealis - Safety & security code       [USE]" \
    22 "Ursa Major - Metaverse doc management             [USE]" \
    23 "Lynx       - Emerging tech trend scouting           [USE]" \
    24 "Perseus    - New feature code generation            [USE]" \
    25 "Cassiopeia - Ethical/legal compliance checks        [USE]" \
    0  "Exit Dashboard" \
  2>&1 >/dev/tty)
  clear
  case $CHOICE in
    0) echo "Exiting Sovereign GTP Dashboard..."; exit 0 ;;
    1) echo "USING Earth..."; ~/sovereign-gtp/agents/earth.sh 2>/dev/null || echo "Earth script not found - create ~/sovereign-gtp/agents/earth.sh" ;;
    2) echo "USING Moon...";  ~/sovereign-gtp/agents/moon.sh  2>/dev/null || echo "Moon script not found" ;;
    3) echo "USING Sun...";   ~/sovereign-gtp/agents/sun.sh   2>/dev/null || echo "Sun script not found" ;;
    4) echo "USING Mercury..."; ~/sovereign-gtp/agents/mercury.sh 2>/dev/null || echo "Mercury script not found" ;;
    5) echo "USING Venus..."; ~/sovereign-gtp/agents/venus.sh 2>/dev/null || echo "Venus script not found" ;;
    6) echo "USING Mars..."; ~/sovereign-gtp/agents/mars.sh 2>/dev/null || echo "Mars script not found" ;;
    7) echo "USING Jupiter..."; ~/sovereign-gtp/agents/jupiter.sh 2>/dev/null || echo "Jupiter script not found" ;;
    8) echo "USING Saturn..."; ~/sovereign-gtp/agents/saturn.sh 2>/dev/null || echo "Saturn script not found" ;;
    9) echo "USING Uranus..."; ~/sovereign-gtp/agents/uranus.sh 2>/dev/null || echo "Uranus script not found" ;;
    10) echo "USING Neptune..."; ~/sovereign-gtp/agents/neptune.sh 2>/dev/null || echo "Neptune script not found" ;;
    11) echo "USING Cygnus..."; ~/sovereign-gtp/agents/cygnus.sh 2>/dev/null || echo "Cygnus script not found" ;;
    12) echo "USING Orion..."; ~/sovereign-gtp/agents/orion.sh 2>/dev/null || echo "Orion script not found" ;;
    13) echo "USING Andromeda..."; ~/sovereign-gtp/agents/andromeda.sh 2>/dev/null || echo "Andromeda script not found" ;;
    14) echo "USING Pleiades..."; ~/sovereign-gtp/agents/pleiades.sh 2>/dev/null || echo "Pleiades script not found" ;;
    15) echo "USING Sirius..."; ~/sovereign-gtp/agents/sirius.sh 2>/dev/null || echo "Sirius script not found" ;;
    16) echo "USING Canis Major..."; ~/sovereign-gtp/agents/canis-major.sh 2>/dev/null || echo "Canis Major script not found" ;;
    17) echo "USING Hydra..."; ~/sovereign-gtp/agents/hydra.sh 2>/dev/null || echo "Hydra script not found" ;;
    18) echo "USING Centauri..."; ~/sovereign-gtp/agents/centauri.sh 2>/dev/null || echo "Centauri script not found" ;;
    19) echo "USING Draco..."; ~/sovereign-gtp/agents/draco.sh 2>/dev/null || echo "Draco script not found" ;;
    20) echo "USING Boötes..."; ~/sovereign-gtp/agents/bootes.sh 2>/dev/null || echo "Boötes script not found" ;;
    21) echo "USING Corona Borealis..."; ~/sovereign-gtp/agents/corona-borealis.sh 2>/dev/null || echo "Corona Borealis script not found" ;;
    22) echo "USING Ursa Major..."; ~/sovereign-gtp/agents/ursa-major.sh 2>/dev/null || echo "Ursa Major script not found" ;;
    23) echo "USING Lynx..."; ~/sovereign-gtp/agents/lynx.sh 2>/dev/null || echo "Lynx script not found" ;;
    24) echo "USING Perseus..."; ~/sovereign-gtp/agents/perseus.sh 2>/dev/null || echo "Perseus script not found" ;;
    25) echo "USING Cassiopeia..."; ~/sovereign-gtp/agents/cassiopeia.sh 2>/dev/null || echo "Cassiopeia script not found" ;;
    *) echo "Invalid selection - press Enter to continue" ;;
  esac
  echo ""
  read -p "Press Enter to return to dashboard..."
done
