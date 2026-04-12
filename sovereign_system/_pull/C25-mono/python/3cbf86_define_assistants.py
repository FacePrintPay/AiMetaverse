import json
import os
from datetime import datetime

DATA_DIR = os.path.expanduser("~/planetary_agents/data")

assistants = {
    "CodeGeneratorAgent": {
        "id": "cga-001",
        "role": "Generate production-ready code",
        "capabilities": ["python", "javascript", "go", "rust"],
        "priority": "high",
        "memory_mb": 512,
        "timeout_sec": 300,
        "concurrency": 10,
        "cost_per_invocation": 0.0001
    },
    "DataAnalystAgent": {
        "id": "daa-002",
        "role": "Analyze datasets and generate insights",
        "capabilities": ["pandas", "numpy", "visualization", "statistical_analysis"],
        "priority": "medium",
        "memory_mb": 1024,
        "timeout_sec": 600,
        "concurrency": 5,
        "cost_per_invocation": 0.0002
    },
    "APIIntegrationAgent": {
        "id": "aia-003",
        "role": "Connect and integrate external APIs",
        "capabilities": ["rest", "graphql", "webhooks", "websockets"],
        "priority": "high",
        "memory_mb": 256,
        "timeout_sec": 180,
        "concurrency": 20,
        "cost_per_invocation": 0.00005
    },
    "MonitoringAgent": {
        "id": "moa-004",
        "role": "Monitor system health and performance",
        "capabilities": ["metrics", "alerts", "logging", "tracing"],
        "priority": "critical",
        "memory_mb": 256,
        "timeout_sec": 60,
        "concurrency": 1,
        "cost_per_invocation": 0.00001
    }
}

# Add metadata
output = {
    "assistants": assistants,
    "count": len(assistants),
    "total_memory_mb": sum(a["memory_mb"] for a in assistants.values()),
    "created_at": datetime.now().isoformat()
}

filepath = os.path.join(DATA_DIR, "assistants.json")
with open(filepath, 'w') as f:
    json.dump(output, f, indent=2)

print("[✓] AI Assistants defined and saved")
print(f"[✓] Total assistants: {output['count']}")
print(f"[✓] Total memory allocation: {output['total_memory_mb']} MB")
for name, info in assistants.items():
    print(f"  • {info['id']} - {name}: {info['role']}")
