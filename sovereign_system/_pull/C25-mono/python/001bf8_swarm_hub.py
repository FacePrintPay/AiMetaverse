import os, json, time
from datetime import datetime

TRANSMISSIONS_DIR = os.path.expanduser("~/PaTHos/transmissions")

def collect_transmissions():
    if not os.path.exists(TRANSMISSIONS_DIR):
        return []
    transmissions = []
    for f in os.listdir(TRANSMISSIONS_DIR):
        if f.endswith(".json"):
            path = os.path.join(TRANSMISSIONS_DIR, f)
            try:
                with open(path) as fp:
                    transmissions.append(json.load(fp))
            except Exception:
                pass
    return transmissions


def swarm_status():
    transmissions = collect_transmissions()
    active = [
        t for t in transmissions
        if t.get("status") == "active"
        or (t.get("payload", {}).get("status") == "active")
    ]
    print(f"🧬 Swarm Status @ {datetime.utcnow().isoformat()}")
    print(f"Active Agents: {len(active)} / {len(transmissions)}")
    for t in active:
        payload = t.get("payload", {})
        print(f" - {t['agent']}: {payload.get('message', '(no message)')}")
    print("-" * 40)


def live_monitor(interval=5):
    print("🔄 Starting live Swarm monitor... (Ctrl+C to exit)")
    try:
        while True:
            os.system("clear")
            swarm_status()
            time.sleep(interval)
    except KeyboardInterrupt:
        print("\n🧩 Monitor stopped by user.")
