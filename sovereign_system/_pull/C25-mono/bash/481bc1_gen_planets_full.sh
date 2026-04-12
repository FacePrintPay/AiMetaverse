#!/data/data/com.termux/files/usr/bin/bash
PLANETS=("Mercury" "Venus" "Earth" "Mars" "Jupiter" "Saturn" "Uranus" "Neptune" "Pluto" "Ceres" "Haumea" "Makemake" "Eris" "Io" "Europa" "Ganymede" "Callisto" "Titan" "Enceladus" "Triton" "Charon" "Phobos" "Deimos" "Oberon" "Ariel")

mkdir -p ~/PaTHos/planets

for p in "${PLANETS[@]}"; do
  cat > ~/PaTHos/planets/${p,,}.py <<PY
from datetime import datetime

def run(payload: dict) -> dict:
    return {
        "agent": "${p}",
        "input": payload,
        "status": "active",
        "timestamp": datetime.utcnow().isoformat()
    }
PY
  echo "[✓] Generated ${p,,}.py"
done
