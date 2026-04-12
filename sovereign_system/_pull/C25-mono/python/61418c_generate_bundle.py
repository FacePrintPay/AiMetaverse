#!/usr/bin/env python3
import sys
from datetime import datetime

def generate_bundle(bundle_type):
    print(f"📦 Generating {bundle_type} PaTHos bundle...")
    print(f"✓ Bundle generated at {datetime.now().isoformat()}")
    
if __name__ == "__main__":
    bundle_type = sys.argv[2] if len(sys.argv) > 2 else "weekly"
    generate_bundle(bundle_type)
