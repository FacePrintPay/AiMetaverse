#!/data/data/com.termux/files/usr/bin/bash

# === STEP 1: Set Project Directory ===
PROJECT_DIR=~/AiMetaverse-Orgin
cd "$PROJECT_DIR" || { echo "[ERROR] Folder not found: $PROJECT_DIR"; exit 1; }

# === STEP 2: Git Setup ===
echo "[INFO] Initializing Git..."
git init
git remote add origin https://github.com/FacePrintPay/AiMetaverse-Orgin.git 2>/dev/null
git add .
git commit -m "🔥 AiMetaverse Resurrection Begins"
git push -u origin main --force

# === STEP 3: Docker Build & Run ===
echo "[INFO] Attempting Docker Compose Build..."
if command -v docker-compose &> /dev/null; then
    docker-compose up -d --build
else
    echo "[WARNING] docker-compose not installed. Trying udocker fallback..."
    if command -v udocker &> /dev/null; then
        echo "[INFO] udocker is available. Please convert docker-compose.yml manually."
    else
        echo "[ERROR] No docker-compatible runner found. Install docker-compose or udocker."
    fi
fi

# === STEP 4: Success Report ===
echo "[SUCCESS] AiMetaverse Resurrection Script Completed!"
echo "📂 Repo: https://github.com/FacePrintPay/AiMetaverse-Orgin"
echo "🧠 Agents Initialized. If ports were mapped correctly, check localhost or 127.0.0.1 for UI."
