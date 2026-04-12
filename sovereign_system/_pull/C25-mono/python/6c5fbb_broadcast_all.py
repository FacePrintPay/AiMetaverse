import os, json
from datetime import datetime

TRANSMISSIONS = os.path.expanduser("~/PaTHos/transmissions")
os.makedirs(TRANSMISSIONS, exist_ok=True)

PLANETS = [
  "Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres",
  "Eris","Haumea","Makemake","Gonggong","Sedna","Quaoar","Orcus","Ixion","Varuna","Triton",
  "Titania","Oberon","Ariel","Umbriel","Miranda","Callisto","Ganymede","Europa","Io","Phobos",
  "Deimos","Enceladus","Charon","Luna","Sun"
]

def write(agent, message):
    path = os.path.join(TRANSMISSIONS, f"{agent.lower()}.json")
    with open(path, "w") as f:
        json.dump({
          "agent": agent,
          "payload": {"message": message, "status": "active"},
          "timestamp": datetime.utcnow().isoformat()
        }, f, indent=2)
    return path

for i, p in enumerate(PLANETS, 1):
    write(p, f"Swarm link established [{i}/{len(PLANETS)}]")
print(f"✅ Broadcast sent to {len(PLANETS)} agents → {TRANSMISSIONS}")
