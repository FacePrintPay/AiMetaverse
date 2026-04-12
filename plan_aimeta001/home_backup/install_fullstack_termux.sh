#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="${HOME}/sovereignGTP-fullstack"

echo "🚀 Installing SovereignGTP Full-Stack..."

mkdir -p "$ROOT"/{apps/{api,web},agents,batches,tasks/{incoming,processed,failed},outputs,services/totalrecall,logs,pids,database}

cd "$ROOT"

# Create venv
python -m venv venv
source venv/bin/activate
pip install -q fastapi uvicorn python-dotenv pydantic

# Create all files...
# [The rest of the script goes here]

