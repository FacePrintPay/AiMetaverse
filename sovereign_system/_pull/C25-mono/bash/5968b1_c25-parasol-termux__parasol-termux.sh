# REPO: c25-parasol-termux | FILE: parasol-termux.sh | CONSTELLATION25

#!/data/data/com.termux/files/usr/bin/bash
set -e
echo "🚀 Starting Parasol Insurance AI Workshop Setup in Termux..."
# === 1. Install required packages ===
echo "📦 Installing dependencies..."
pkg update -y
pkg install -y git nodejs python openssh curl
# Upgrade pip and install virtualenv (pip is built into Termux's python)
python -m pip install --upgrade pip virtualenv
# === 2. Clone the repo ===
if [ ! -d "parasol-insurance" ]; then
  echo "📥 Cloning Parasol Insurance repo..."
  git clone https://github.com/rh-aiservices-bu/parasol-insurance.git
else
  echo "📁 Repo already exists. Pulling latest..."
  cd parasol-insurance && git pull && cd ..
fi
cd parasol-insurance
# === 3. Frontend setup ===
echo "🎨 Setting up frontend..."
cd frontend
npm install || npm install --force
cd ..
# === 4. Backend setup ===
echo "⚙️ Setting up backend..."
cd backend
# Create virtual environment
python -m venv venv
source venv/bin/activate
# Install Python deps
if [ -f "Pipfile" ]; then
  pip install pipenv
  pipenv install
else
  if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
  else
    echo "⚠️ No requirements.txt or Pipfile – manual install may be needed"
  fi
fi
# Create .env if missing
if [ ! -f ".env" ]; then
  cp .env.example .env
  echo "🔧 Please edit backend/.env to set INFERENCE_SERVER_URL (e.g., http://localhost:11434/v1)"
fi
deactivate
cd ..
# === 5. Launch dev servers ===
echo "🔥 Launching frontend and backend..."
# Start backend
cd backend
source venv/bin/activate
nohup python app/main.py > backend.log 2>&1 &
BACKEND_PID=$!
echo "   Backend running on http://localhost:5000 (PID: $BACKEND_PID)"
cd ..
# Start frontend
cd frontend
nohup npm start > frontend.log 2>&1 &
FRONTEND_PID=$!
echo "   Frontend running on http://localhost:9000 (PID: $FRONTEND_PID)"
cd ..
# === 6. Final instructions ===
echo ""
echo "✅ Parasol Lab is RUNNING!"
echo "🔗 Frontend: http://localhost:9000"
echo "📚 API Docs: http://localhost:5000/docs"
echo ""
echo "❗ Ensure Ollama is running: ollama serve (in another session)"
echo "🛑 To stop: kill $FRONTEND_PID $BACKEND_PID"
if command -v termux-open-url &> /dev/null; then
  termux-open-url http://localhost:9000
fi
