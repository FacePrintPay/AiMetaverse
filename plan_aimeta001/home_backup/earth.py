#!/usr/bin/env python3
import time, sys
from datetime import datetime

name = "earth"
while True:
    print(f"{datetime.now().isoformat()} | {name.upper()} | Active")
    sys.stdout.flush()
    time.sleep(30)
