#!/bin/bash
mkdir -p .vscode
cat > .vscode/tasks.json << 'TASKEOF'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "npm: watch",
      "type": "shell",
      "command": "npm run watch",
      "isBackground": true,
      "problemMatcher": ["$tsc-watch"],
      "group": "build"
    },
    {
      "label": "npm: build",
      "type": "shell",
      "command": "npm run build",
      "group": "build",
      "problemMatcher": ["$tsc"]
    }
  ]
}
TASKEOF
cat > .vscode/launch.json << 'LAUNCHED'
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "aws-sam",
      "request": "direct-invoke",
      "name": "Invoke Lambda",
      "invokeTarget": {
        "target": "code",
        "lambdaHandler": "app.lambdaHandler",
        "projectRoot": "${workspaceFolder}"
      },
      "lambda": {
        "runtime": "nodejs18.x",
        "payload": { "json": {} }
      }
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Launch Program",
      "program": "${file}",
      "skipFiles": ["<node_internals>/**"],
      "env": {
        "NODE_ENV": "development",
        "API_KEY": "${env:API_KEY}"
      }
    },
    {
      "type": "node",
      "request": "attach",
      "name": "Docker: Attach to Node",
      "remoteRoot": "/usr/src/app",
      "port": 9229,
      "localRoot": "${workspaceFolder}"
    },
    {
      "type": "python",
      "request": "launch",
      "name": "Python: Launch File",
      "program": "${file}",
      "console": "integratedTerminal",
      "env": {
        "PYTHONPATH": "${workspaceFolder}/src"
      }
    },
    {
      "name": "Python: Remote Attach",
      "type": "python",
      "request": "attach",
      "connect": {
        "host": "remote.server.com",
        "port": 5678
      },
      "pathMappings": [
        {
          "localRoot": "${workspaceFolder}",
          "remoteRoot": "/app"
        }
      ]
    },
    {
      "type": "node-terminal",
      "request": "launch",
      "name": "Run npm start",
      "command": "npm start"
    },
    {
      "type": "chrome",
      "request": "launch",
      "name": "Launch Chrome",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}"
    },
    {
      "type": "msedge",
      "request": "launch",
      "name": "Launch Edge",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}"
    },
    {
      "type": "dart",
      "request": "attach",
      "name": "Flutter: Attach to Device"
    },
    {
      "type": "dart",
      "request": "launch",
      "name": "Flutter",
      "program": "lib/main.dart",
      "flutterMode": "debug"
    },
    {
      "type": "extensionHost",
      "request": "launch",
      "name": "Launch Extension",
      "args": ["--extensionDevelopmentPath=${workspaceFolder}"],
      "outFiles": ["${workspaceFolder}/out/**/*.js"],
      "preLaunchTask": "npm: watch"
    }
  ]
}
LAUNCHED
echo "✅ VS Code launch.json and tasks.json generated in .vscode/"
chmod +x setup_vscode.sh
./setup_vscode.sh
chmod +x setup_vscode.sh
./setup_vscode.sh

#!/bin/bash

echo "🧹 Cleaning up stale Node debug sessions..."

# Find processes using port 9229 (Node debug)
pids=$(lsof -t -i :9229)

if [ -z "$pids" ]; then
  echo "✅ No stale debug processes found on port 9229."
else
  echo "⚠️ Killing Node debug processes with PIDs: $pids"
  kill -9 $pids
  echo "✅ Cleanup complete."
fi
./cleanup_debug.sh

#!/bin/bash
set -euo pipefail

REGISTRY="docker.io/yourdockerhubusername"  # Update this
LOGFILE="deploy_$(date +%Y%m%d_%H%M%S).log"
MAX_RETRIES=3

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

retry_cmd() {
  local retries=$1; shift
  local count=0
  until "$@"; do
    exit_code=$?
    count=$((count + 1))
    if [ $count -lt $retries ]; then
      log "⚠️ Command failed: $*. Retrying ($count/$retries)..."
      sleep 5
    else
      log "❌ Command failed after $retries attempts: $*"
      return $exit_code
    fi
  done
}

log "🚀 Starting Full-Stack Build & Deploy Sequence..."

# 1. Build & Deploy Frontend
log "🔧 Building frontend..."
pushd frontend > /dev/null
retry_cmd $MAX_RETRIES npm ci
retry_cmd $MAX_RETRIES npm run build
log "🚀 Deploying frontend to Vercel..."
retry_cmd $MAX_RETRIES vercel deploy --prod --confirm
popd > /dev/null

# 2. Build & Deploy Backend Docker
log "🔧 Building backend Docker image..."
retry_cmd $MAX_RETRIES docker build -t "$REGISTRY/airecords-backend:latest" ./backend
log "🔧 Pushing backend Docker image..."
retry_cmd $MAX_RETRIES docker push "$REGISTRY/airecords-backend:latest"

log "🚀 Deploy backend to Kubernetes..."
retry_cmd $MAX_RETRIES kubectl apply -f k8s/backend.yaml

# 3. Build & Deploy NLP2CODE Docker
log "🔧 Building NLP2CODE Docker image..."
retry_cmd $MAX_RETRIES docker build -t "$REGISTRY/nlp2code-service:latest" ./nlp2code
log "🔧 Pushing NLP2CODE Docker image..."
retry_cmd $MAX_RETRIES docker push "$REGISTRY/nlp2code-service:latest"

log "🚀 Deploy NLP2CODE service to Kubernetes..."
retry_cmd $MAX_RETRIES kubectl apply -f k8s/nlp2code.yaml

log "✅ All components deployed successfully!"
#!/bin/bash
set -euo pipefail

NAMESPACE=default   # Change if you use a different namespace
SECRET_NAME=airecords-secrets

# Replace these with your actual secret values or export them as env vars beforehand
DB_URL=${DATABASE_URL:-"your_database_url_here"}
API_KEY=${API_KEY:-"your_api_key_here"}

echo "🔐 Creating/updating Kubernetes secret '${SECRET_NAME}' in namespace '${NAMESPACE}'..."

kubectl create secret generic $SECRET_NAME \
  --from-literal=DATABASE_URL="$DB_URL" \
  --from-literal=API_KEY="$API_KEY" \
  --namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "📦 Applying backend deployment manifest..."

kubectl apply -f k8s/backend.yaml --namespace $NAMESPACE

echo "✅ Backend deployment complete!"

export DATABASE_URL="postgres://user:pass@host:5432/dbname"
export API_KEY="supersecretapikey"
#!/bin/bash
set -euo pipefail

NAMESPACE=default
SECRET_NAME=nlp2code-secrets

# Export or replace these values before running
MODEL_API_KEY=${MODEL_API_KEY:-"your_model_api_key_here"}
DB_URL=${DATABASE_URL:-"your_database_url_here"}

echo "🔐 Creating/updating Kubernetes secret '${SECRET_NAME}' in namespace '${NAMESPACE}'..."

kubectl create secret generic $SECRET_NAME \
  --from-literal=MODEL_API_KEY="$MODEL_API_KEY" \
  --from-literal=DATABASE_URL="$DB_URL" \
  --namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "📦 Applying NLP2CODE deployment manifest..."

kubectl apply -f k8s/nlp2code.yaml --namespace $NAMESPACE

echo "✅ NLP2CODE deployment complete!"
#!/bin/bash
set -euo pipefail

LOGFILE="fullstack_deploy_$(date +%Y%m%d_%H%M%S).log"
MAX_RETRIES=3

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

retry_cmd() {
  local retries=$1; shift
  local count=0
  until "$@"; do
    exit_code=$?
    count=$((count + 1))
    if [ $count -lt $retries ]; then
      log "⚠️ Command failed: $*. Retrying ($count/$retries)..."
      sleep 5
    else
      log "❌ Command failed after $retries attempts: $*"
      return $exit_code
    fi
  done
}

log "🚀 Starting full-stack deployment..."

# Deploy backend
log "🔹 Deploying backend..."
retry_cmd $MAX_RETRIES ./deploy_backend_k8s.sh

# Deploy NLP2CODE
log "🔹 Deploying NLP2CODE service..."
retry_cmd $MAX_RETRIES ./deploy_nlp2code_k8s.sh

# Deploy frontend
log "🔹 Deploying frontend..."
retry_cmd $MAX_RETRIES ./deploy_frontend.sh

log "✅ Full-stack deployment finished successfully!"
#!/bin/bash
set -euo pipefail

NAMESPACE=default
SECRET_NAME=airecords-secrets

DB_URL=${DATABASE_URL:-"your_database_url_here"}
API_KEY=${API_KEY:-"your_api_key_here"}

echo "🔐 Creating/updating Kubernetes secret '${SECRET_NAME}' in namespace '${NAMESPACE}'..."

kubectl create secret generic $SECRET_NAME \
  --from-literal=DATABASE_URL="$DB_URL" \
  --from-literal=API_KEY="$API_KEY" \
  --namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "🔧 Building backend Docker image..."

docker build -t docker.io/yourdockerhubusername/airecords-backend:latest ./backend
docker push docker.io/yourdockerhubusername/airecords-backend:latest

echo "📦 Deploying backend to Kubernetes..."

kubectl apply -f k8s/backend.yaml --namespace $NAMESPACE

echo "✅ Backend deployment complete!"
#!/bin/bash
set -euo pipefail

echo "🔧 Building frontend..."

cd frontend

npm ci
npm run build

echo "🚀 Deploying frontend to Vercel..."

vercel deploy --prod --confirm

cd -

echo "✅ Frontend deployed successfully!"
export DATABASE_URL="your_database_connection_string"
export API_KEY="your_backend_api_key"
export MODEL_API_KEY="your_nlp2code_model_api_key"
chmod +x deploy_backend_k8s.sh deploy_nlp2code_k8s.sh deploy_frontend.sh deploy_fullstack.sh

#!/bin/bash
set -e

BASE_DIR="AiRecords"
BACKEND_DIR="$BASE_DIR/backend"

echo "Creating project directories..."
mkdir -p "$BACKEND_DIR"

echo "Writing FastAPI backend app.py..."
cat > "$BACKEND_DIR/app.py" <<'EOF'
from fastapi import FastAPI, UploadFile, File, BackgroundTasks, Depends
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import asyncio
import logging

app = FastAPI(title="AiRecords Backend")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("AiRecords")

# Mock auth dependency
def get_current_user():
    return {"user_id": "user123", "username": "aiuser"}

class TrackMetadata(BaseModel):
    title: str
    artist: str
    genre: str
    description: str | None = None

@app.post("/upload-track")
async def upload_track(metadata: TrackMetadata, file: UploadFile = File(...), user=Depends(get_current_user)):
    logger.info(f"User {user['username']} uploading track {metadata.title}")
    # TODO: Save file & process
    return {"status": "processing", "track": metadata.title}

@app.post("/run-voice-clone")
async def run_voice_clone(voice_sample: UploadFile = File(...), user=Depends(get_current_user)):
    # TODO: Integrate voice clone API
    return {"voice_id": "voice123"}

@app.post("/start-whisper-session")
async def start_whisper_session(session_id: str):
    # TODO: Manage WhisperSync session
    return {"status": "session started", "session_id": session_id}

@app.post("/mint-nft")
async def mint_nft(track_id: str, user=Depends(get_current_user)):
    # TODO: Mint NFT smart contract interaction
    return {"status": "NFT minted", "token_id": "token123"}

@app.get("/healthz")
async def healthz():
    return JSONResponse(content={"status": "healthy"})

async def ai_mastering_task(track_id: str):
    logger.info(f"Mastering track {track_id} started.")
    await asyncio.sleep(10)
    logger.info(f"Mastering track {track_id} complete.")

@app.post("/start-mastering")
async def start_mastering(track_id: str, background_tasks: BackgroundTasks):
    background_tasks.add_task(ai_mastering_task, track_id)
    return {"status": "mastering started", "track_id": track_id}
