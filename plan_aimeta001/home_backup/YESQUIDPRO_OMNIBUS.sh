#!/usr/bin/env bash
set -e

echo "========================================"
echo " YESQUIDPRO OMNIBUS FULL-STACK BOOTSTRAP "
echo "========================================"

APP_NAME="yesquidpro"
SRC_DIR="$APP_NAME/src"
COMP_DIR="$SRC_DIR/components"

echo "[1/8] Checking Node & npm..."
command -v node >/dev/null 2>&1 || { echo "Node.js not found"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "npm not found"; exit 1; }

echo "[2/8] Creating Vite React app..."
npm create vite@latest "$APP_NAME" -- --template react >/dev/null
cd "$APP_NAME"

echo "[3/8] Installing dependencies..."
npm install
npm install react-helmet-async

echo "[4/8] Creating components directory..."
mkdir -p "$COMP_DIR"

echo "[5/8] Writing SEO.jsx..."
cat > "$COMP_DIR/SEO.jsx" <<'EOF'
import { Helmet } from "react-helmet-async";

export default function SEO({ title, description, url, image }) {
  return (
    <Helmet>
      <title>{title}</title>
      <meta name="description" content={description} />
      <link rel="canonical" href={url} />

      <meta property="og:type" content="website" />
      <meta property="og:title" content={title} />
      <meta property="og:description" content={description} />
      <meta property="og:url" content={url} />
      <meta property="og:image" content={image} />

      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:title" content={title} />
      <meta name="twitter:description" content={description} />
      <meta name="twitter:image" content={image} />
    </Helmet>
  );
}
EOF

echo "[6/8] Wiring HelmetProvider into main.jsx..."
cat > "$SRC_DIR/main.jsx" <<'EOF'
import React from "react";
import ReactDOM from "react-dom/client";
import { HelmetProvider } from "react-helmet-async";
import App from "./App";
import "./index.css";

ReactDOM.createRoot(document.getElementById("root")).render(
  <HelmetProvider>
    <App />
  </HelmetProvider>
);
EOF

echo "[7/8] Writing App.jsx with SEO active..."
cat > "$SRC_DIR/App.jsx" <<'EOF'
import SEO from "./components/SEO";

export default function App() {
  return (
    <>
      <SEO
        title="YesQuidPro – Autonomous AI Agents"
        description="Deploy autonomous AI agents that plan, execute, and test code."
        url="http://localhost:5173"
        image="https://placehold.co/1200x630/png"
      />

      <div style={{ padding: "3rem", fontFamily: "sans-serif" }}>
        <h1>YesQuidPro</h1>
        <p>Full-stack bootstrap complete. SEO is live.</p>
      </div>
    </>
  );
}
EOF

echo "[8/8] Launching dev server..."
npm run dev

echo "========================================"
echo " BUILD COMPLETE – YOU'RE LIVE "
echo "========================================"
