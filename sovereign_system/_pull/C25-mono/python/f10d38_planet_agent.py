import json, time, os
from pathlib import Path
AGENT = os.environ.get("AGENT_NAME","Unknown")
LOG = Path.home()/ "logs"/"agents"/f"{AGENT}.log"
LOG.parent.mkdir(parents=True,exist_ok=True)
print(f"🌍 {AGENT} active")
def loop():
    LOG.touch(exist_ok=True)
    with open(LOG,"r") as f:
        f.seek(0,2)
        while True:
            line=f.readline()
            if not line:
                time.sleep(1); continue
            try: msg=json.loads(line.strip()); print(f"[{AGENT}] {msg['from']}: {msg['message']}")
            except: pass
loop()
