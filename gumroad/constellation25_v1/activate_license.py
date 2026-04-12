#!/usr/bin/env python3
import json, sys
def activate(key):
    with open(".license_config.json", "w") as f:
        json.dump({"key": key, "status": "active"}, f)
    print("✅ License activated:", key)
if __name__ == "__main__":
    if len(sys.argv) >= 3:
        activate(sys.argv[2])
    else:
        print("Usage: python activate_license.py --key YOUR_KEY")
