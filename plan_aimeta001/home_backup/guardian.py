#!/usr/bin/env python3
import time, sys
from datetime import datetime

name = "guardian"
print(f"🌟 Agent {name} starting...")
sys.stdout.flush()

try:
    while True:
        print(f"{datetime.now().isoformat()} | {name.upper()} | Active")
        sys.stdout.flush()
        time.sleep(30)
except KeyboardInterrupt:
    print(f"🌟 Agent {name} stopped")
    sys.exit(0)
