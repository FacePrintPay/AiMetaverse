import json
import os
from datetime import datetime
import random

DATA_DIR = os.path.expanduser("~/planetary_agents/data")

def check_api_health(api):
    """Simulate API health check"""
    # In production, this would make actual HTTP requests
    health_status = random.choice(["healthy", "healthy", "healthy", "degraded"])
    response_time = random.randint(50, 500)
    
    return {
        "status": health_status,
        "response_time_ms": response_time,
        "checked_at": datetime.now().isoformat()
    }

def check_deployment_health(deployment):
    """Simulate deployment health check"""
    is_healthy = random.choice([True, True, True, False])
    
    return {
        "status": "healthy" if is_healthy else "unhealthy",
        "checked_at": datetime.now().isoformat()
    }

# Check API health
with open(os.path.join(DATA_DIR, "api_metadata.json")) as f:
    api_data = json.load(f)

api_health = []
for api in api_data["metadata"]:
    health = check_api_health(api)
    api_health.append({
        "api_id": api["id"],
        "api_name": api["name"],
        "health": health
    })

# Check deployment health
with open(os.path.join(DATA_DIR, "deployment_summary.json")) as f:
    deploy_data = json.load(f)

deployment_health = []
for name, deployment in deploy_data["deployments"].items():
    health = check_deployment_health(deployment)
    deployment_health.append({
        "deployment_name": name,
        "function_id": deployment["function_id"],
        "health": health
    })

# Save health report
health_report = {
    "api_health": api_health,
    "deployment_health": deployment_health,
    "report_generated_at": datetime.now().isoformat(),
    "overall_status": "healthy" if all(h["health"]["status"] == "healthy" for h in api_health) else "degraded"
}

health_path = os.path.join(DATA_DIR, "health_report.json")
with open(health_path, 'w') as f:
    json.dump(health_report, f, indent=2)

print(f"[✓] Health check complete")
print(f"[✓] Overall status: {health_report['overall_status'].upper()}")
print(f"[✓] Report saved to: {health_path}")
