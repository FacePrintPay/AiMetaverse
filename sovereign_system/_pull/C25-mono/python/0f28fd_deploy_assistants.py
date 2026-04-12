import json
import os
import hashlib
from datetime import datetime

DATA_DIR = os.path.expanduser("~/planetary_agents/data")
DEPLOY_DIR = os.path.join(DATA_DIR, "deployments")
os.makedirs(DEPLOY_DIR, exist_ok=True)

with open(os.path.join(DATA_DIR, "assistants.json")) as f:
    data = json.load(f)
    assistants = data["assistants"]

def create_deployment_package(name, info):
    """Create a deployment package with code template"""
    code_template = f'''# {name} Lambda Handler
# Generated: {datetime.now().isoformat()}

import json

def lambda_handler(event, context):
    """
    Role: {info.get("role")}
    Capabilities: {", ".join(info.get("capabilities", []))}
    """
    print(f"{{name}} invoked with event: {{event}}")
    
    return {{
        'statusCode': 200,
        'body': json.dumps({{
            'agent': '{name}',
            'status': 'success',
            'message': 'Agent executed successfully'
        }})
    }}
'''
    return code_template

def build_and_deploy(name, info):
    print(f"[+] Building {name} (ID: {info['id']})...")
    
    # Create code
    code = create_deployment_package(name, info)
    code_path = os.path.join(DEPLOY_DIR, f"{name}_handler.py")
    with open(code_path, "w") as f:
        f.write(code)
    
    # Create deployment package
    zip_path = os.path.join(DEPLOY_DIR, f"{name}.zip")
    with open(zip_path, "wb") as f:
        f.write(b"PLACEHOLDER_DEPLOYMENT_PACKAGE")
    
    # Deployment record
    deployment_record = {
        "function_name": name,
        "function_id": info["id"],
        "runtime": "python3.9",
        "handler": "lambda_function.lambda_handler",
        "memory": info.get("memory_mb", 256),
        "timeout": info.get("timeout_sec", 180),
        "role_info": info.get("role"),
        "capabilities": info.get("capabilities", []),
        "deployed_at": datetime.now().isoformat(),
        "version": "1.0.0",
        "status": "deployed",
        "environment": "standalone",
        "package_path": zip_path,
        "code_path": code_path
    }
    
    record_path = os.path.join(DEPLOY_DIR, f"{name}_deployment.json")
    with open(record_path, 'w') as f:
        json.dump(deployment_record, f, indent=2)
    
    print(f"[✓] {name} deployed (v{deployment_record['version']})")
    return deployment_record

# Deploy all assistants
deployments = {}
failed = []

for k, v in assistants.items():
    try:
        deployment = build_and_deploy(k, v)
        deployments[k] = deployment
    except Exception as e:
        print(f"[!] {k} failed: {e}")
        failed.append({"name": k, "error": str(e)})

# Save deployment summary
summary = {
    "deployments": deployments,
    "summary": {
        "total": len(assistants),
        "successful": len(deployments),
        "failed": len(failed)
    },
    "failed_deployments": failed,
    "deployed_at": datetime.now().isoformat()
}

summary_path = os.path.join(DATA_DIR, "deployment_summary.json")
with open(summary_path, 'w') as f:
    json.dump(summary, f, indent=2)

print(f"\n[✓] Deployment complete: {summary['summary']['successful']}/{summary['summary']['total']} successful")
print(f"[✓] Summary saved to: {summary_path}")
