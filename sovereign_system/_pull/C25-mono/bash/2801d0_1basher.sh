#!/data/data/com.termux/files/usr/bin/bash
# ---------------------------------------------
# 1BASHER — SovereignDeck quick bootstrap
# ---------------------------------------------
set -euo pipefail

echo "[🚀] Initializing SovereignDeck environment..."
cd ~
pkg update -y && pkg install -y nodejs git nano

PROJECT=~/SovereignDeck
mkdir -p "$PROJECT/pages" "$PROJECT/api"
cd "$PROJECT"

echo "[📦] Initializing npm..."
npm init -y >/dev/null
npm install react react-dom next >/dev/null

# --- write React landing page ---
cat > "$PROJECT/pages/index.jsx" <<'EOF'
import React from "react";

export default function Home() {
  return (
    <div className="min-h-screen bg-slate-950 text-white flex flex-col items-center justify-center p-6">
      <h1 className="text-5xl font-bold mb-4">Sovereign Agents</h1>
      <p className="max-w-md text-center text-slate-300 mb-6">
        Deploy your AI Agent in 24 hours — powered by PaTHos OS.
      </p>
      <a
        href="https://cash.app/$ThaCyg"
        target="_blank"
        rel="noopener noreferrer"
        className="bg-purple-600 hover:bg-purple-700 px-6 py-3 rounded-lg font-semibold"
      >
        Pay $ThaCyg
      </a>
    </div>
  );
}
EOF

# --- write minimal API route ---
mkdir -p "$PROJECT/pages/api"
cat > "$PROJECT/pages/api/health.js" <<'EOF'
export default function handler(req, res) {
  res.status(200).json({ ok: true, msg: "API online" });
}
EOF

# --- add start script to package.json ---
jq '.scripts.start="next dev"' package.json > tmp.$$.json && mv tmp.$$.json package.json

echo "[⚙️] Starting local dev server..."
npx next dev
