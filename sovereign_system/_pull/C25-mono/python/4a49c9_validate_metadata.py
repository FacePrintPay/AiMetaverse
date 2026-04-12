import json
import os

DATA_DIR = os.path.expanduser("~/planetary_agents/data")

# Load and validate
with open(os.path.join(DATA_DIR, "api_metadata.json")) as f:
    apis = json.load(f)

validation_results = []
for api in apis:
    result = {
        "name": api.get("name"),
        "url": api.get("url"),
        "is_valid": bool(api.get("name") and api.get("url")),
        "issues": []
    }
    
    if not api.get("version"):
        result["issues"].append("Missing version")
    if not api.get("url").startswith("https://"):
        result["issues"].append("URL should use HTTPS")
    
    validation_results.append(result)
    status = "✓" if result["is_valid"] else "✗"
    print(f"[{status}] Validated: {api.get('name')} @ {api.get('url')}")

# Save validation results
val_path = os.path.join(DATA_DIR, "validation_results.json")
with open(val_path, 'w') as f:
    json.dump(validation_results, f, indent=2)

print(f"[✓] Validation complete: {val_path}")
