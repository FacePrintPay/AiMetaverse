import json
import os
from datetime import datetime

DATA_DIR = os.path.expanduser("~/planetary_agents/data")

def format_size(path):
    """Get file size in human-readable format"""
    if os.path.exists(path):
        size = os.path.getsize(path)
        for unit in ['B', 'KB', 'MB']:
            if size < 1024.0:
                return f"{size:.1f}{unit}"
            size /= 1024.0
        return f"{size:.1f}GB"
    return "N/A"

print("\n" + "="*70)
print("           🌍 PLANETARY AGENTS STATUS DASHBOARD v2.0")
print("="*70)
print(f"  Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print("="*70)

# System files
files_to_check = [
    ("api_metadata.json", "API Metadata"),
    ("assistants.json", "AI Assistants"),
    ("deployment_summary.json", "Deployments"),
    ("api_documentation.json", "Documentation"),
    ("health_report.json", "Health Report"),
]

print("\n📊 SYSTEM COMPONENTS:")
for filename, label in files_to_check:
    filepath = os.path.join(DATA_DIR, filename)
    if os.path.exists(filepath):
        try:
            with open(filepath) as f:
                data = json.load(f)
            
            # Get count
            if isinstance(data, list):
                count = len(data)
            elif "count" in data:
                count = data["count"]
            elif "summary" in data:
                count = data["summary"].get("total", len(data.keys()))
            else:
                count = len(data.keys())
            
            size = format_size(filepath)
            print(f"  ✓ {label:30} | {count:3} items | {size:>8}")
        except:
            print(f"  ⚠ {label:30} | ERROR reading file")
    else:
        print(f"  ✗ {label:30} | NOT FOUND")

# Health status
health_path = os.path.join(DATA_DIR, "health_report.json")
if os.path.exists(health_path):
    with open(health_path) as f:
        health = json.load(f)
    
    print("\n🏥 HEALTH STATUS:")
    print(f"  Overall: {health['overall_status'].upper()}")
    
    healthy_apis = sum(1 for h in health["api_health"] if h["health"]["status"] == "healthy")
    total_apis = len(health["api_health"])
    print(f"  APIs: {healthy_apis}/{total_apis} healthy")
    
    healthy_deploys = sum(1 for h in health["deployment_health"] if h["health"]["status"] == "healthy")
    total_deploys = len(health["deployment_health"])
    print(f"  Deployments: {healthy_deploys}/{total_deploys} healthy")

print("\n" + "="*70)
print(f"📂 Data directory: {DATA_DIR}")
print(f"📋 Logs directory: {os.path.expanduser('~/planetary_agents/logs')}")
print(f"💾 Backups: {os.path.expanduser('~/planetary_agents/backups')}")
print("="*70 + "\n")
