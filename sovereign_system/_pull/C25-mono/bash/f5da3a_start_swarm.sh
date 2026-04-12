#!/data/data/com.termux/files/usr/bin/bash
echo "🧬 Initializing PaTHos Swarm Orchestration..."
cd ~/PaTHos || exit 1

mkdir -p transmissions

echo "[•] Scanning Termux home for incomplete builds..."
find ~/ -maxdepth 3 -type d -name "PaTHos*" -o -name "NLP2CODE*" > ~/PaTHos/tmp/scan.log

echo "[•] Checking for orphaned agents..."
for agent in mercury venus earth mars jupiter saturn uranus neptune pluto luna ceres haumea makemake eris io europa ganymede callisto titan enceladus triton charon phobos deimos ariel; do
  if [ ! -f "planets/${agent}.py" ]; then
    echo "[⚠️] Missing agent: ${agent} — reconstructing..."
    cat > "planets/${agent}.py" <<EOPY
def run(payload):
    from datetime import datetime
    return {
        "agent": "${agent.capitalize()}",
        "input": payload,
        "status": "rebuilt",
        "timestamp": datetime.utcnow().isoformat()
    }
EOPY
  fi
done

echo "[•] Launching PaTHos API..."
pkill -f PaTHos_API.py 2>/dev/null
nohup python3 api/PaTHos_API.py > logs/api.log 2>&1 &

sleep 3
if pgrep -f PaTHos_API.py >/dev/null; then
  echo "[✓] API active at http://127.0.0.1:5000"
else
  echo "[✗] API failed to start. Check logs/api.log"
fi

echo "[•] Dispatching planetary tasks..."
python3 - <<'PY'
from core.router import dispatch
planets = ["mercury","venus","earth","mars","jupiter","saturn","neptune","pluto","ariel"]
for p in planets:
    try:
        res = dispatch(p, {"message": f"Swarm task initiated on {p.title()}"})
        print(res)
    except Exception as e:
        print(f"[!] {p}: {e}")
PY

echo "✅ PaTHos Swarm Initialization Complete."
