import json
import os
from datetime import datetime

DATA_DIR = os.path.expanduser("~/planetary_agents/data")

# Load all data
with open(os.path.join(DATA_DIR, "api_metadata.json")) as f:
    api_data = json.load(f)

with open(os.path.join(DATA_DIR, "assistants.json")) as f:
    assistant_data = json.load(f)

with open(os.path.join(DATA_DIR, "deployment_summary.json")) as f:
    deployment_data = json.load(f)

# Generate comprehensive documentation
documentation = {
    "title": "AI Metaverse API Documentation",
    "version": "2.0.0",
    "generated_at": datetime.now().isoformat(),
    "apis": {
        "count": api_data["count"],
        "endpoints": []
    },
    "assistants": {
        "count": assistant_data["count"],
        "agents": []
    },
    "deployments": {
        "total": deployment_data["summary"]["total"],
        "successful": deployment_data["summary"]["successful"],
        "functions": []
    }
}

# Document APIs
for api in api_data["metadata"]:
    documentation["apis"]["endpoints"].append({
        "id": api["id"],
        "name": api["name"],
        "url": api["url"],
        "version": api["version"],
        "authentication": api.get("auth_type", "none"),
        "rate_limit": api.get("rate_limit", "unlimited"),
        "status": api["status"]
    })

# Document Assistants
for name, info in assistant_data["assistants"].items():
    documentation["assistants"]["agents"].append({
        "id": info["id"],
        "name": name,
        "role": info["role"],
        "capabilities": info["capabilities"],
        "resources": {
            "memory_mb": info["memory_mb"],
            "timeout_sec": info["timeout_sec"],
            "concurrency": info["concurrency"]
        }
    })

# Document Deployments
for name, deploy in deployment_data["deployments"].items():
    documentation["deployments"]["functions"].append({
        "name": name,
        "id": deploy["function_id"],
        "runtime": deploy["runtime"],
        "version": deploy["version"],
        "status": deploy["status"]
    })

# Save documentation
doc_path = os.path.join(DATA_DIR, "api_documentation.json")
with open(doc_path, 'w') as f:
    json.dump(documentation, f, indent=2)

print(f"[✓] Comprehensive documentation generated")
print(f"[✓] APIs documented: {documentation['apis']['count']}")
print(f"[✓] Assistants documented: {documentation['assistants']['count']}")
print(f"[✓] Deployments documented: {documentation['deployments']['successful']}")
print(f"[✓] Saved to: {doc_path}")
