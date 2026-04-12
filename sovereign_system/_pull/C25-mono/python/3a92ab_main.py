from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
import subprocess
import asyncio
import os

app = FastAPI(title="Planetary Agents Deployment API")

app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
async def root():
    return FileResponse("static/index.html")

@app.post("/trigger-deployment")#!/bin/bash
set -e

BASE_DIR="planetary-deployment"
STATIC_DIR="$BASE_DIR/static"

echo "Creating project structure..."
mkdir -p "$STATIC_DIR"

echo "Writing deployment shell script..."
cat > "$BASE_DIR/deploy-agents.sh" <<'EOF'
#!/bin/bash
echo "Starting deployment..."
# Your real deployment commands go here
sleep 2
echo "Deployment script completed successfully."
